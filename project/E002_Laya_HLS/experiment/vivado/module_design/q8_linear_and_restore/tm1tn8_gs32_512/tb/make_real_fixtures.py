#!/usr/bin/env python3
"""Independent ACT/QKV inputs and bit-exact group oracle from the frozen GGUF.

The source tensors are frozen full-forward oracle *inputs*. Expected Q8, dot,
FP intermediates, partial sums and output are computed here, never copied from
a DUT dump. The model BO slices retain the production shard/scale layout.
Run only under the stage CPU resource guard; QKV materializes a full matrix.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import sys

import numpy as np


def require(ok: bool, why: str) -> None:
    if not ok:
        raise AssertionError(why)


def digest(path: Path) -> dict:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while chunk := f.read(8 << 20):
            h.update(chunk)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": h.hexdigest()}


def write(out: Path, name: str, value: bytes) -> dict:
    path = out / name
    path.write_bytes(value)
    return digest(path)


def window(path: Path, offset: int, count: int) -> bytes:
    require(0 <= offset and 0 <= count and offset + count <= path.stat().st_size,
            f"{path}: BO bounds")
    with path.open("rb") as f:
        f.seek(offset)
        value = f.read(count)
    require(len(value) == count, f"{path}: short read")
    return value


def model_record(header: Path, name: str) -> dict:
    text = header.read_text()
    pat = (r'\{"' + re.escape(name) + r'", \{(\d+), (\d+)\}, '
           r'(\d+), (\d+), (\d+), (\d+), '
           r'\{(\d+), (\d+)\}, \{(\d+), (\d+)\}, '
           r'(\d+), (\d+), (\d+), (\d+), (\d+), (\d+)')
    match = re.search(pat, text)
    require(match is not None, f"model layout record {name}")
    fields = [int(x) for x in match.groups()]
    return dict(zip(("family", "layer", "K", "N", "dtype", "bias_kind",
                     "q0_offset", "q1_offset", "q0_span", "q1_span",
                     "scale_offset", "scale_span", "unused0", "unused1",
                     "bias_offset", "bias_span"), fields))


def package_tag(header: str, name: str) -> str:
    match = re.search(r"\b" + re.escape(name) +
                      r"\[16\]\s*=\s*\{([^}]+)\}", header)
    require(match is not None, f"package tag {name}")
    value = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]+)",
                                                  match[1]))
    require(len(value) == 16, f"package tag width {name}")
    return value.hex()


def bo_weights(model_dir: Path, record: dict, gguf: bytes) -> tuple[bytes, bytes, bytes, bytes]:
    K, N = record["K"], record["N"]
    G, T = K // 32, (N + 7) // 8
    q0 = window(model_dir / "w_q0.bin", record["q0_offset"], record["q0_span"])
    q1 = window(model_dir / "w_q1.bin", record["q1_offset"], record["q1_span"])
    scale = window(model_dir / "w_scale.bin", record["scale_offset"], record["scale_span"])
    bias = (window(model_dir / "aux.bin", record["bias_offset"], record["bias_span"])
            if record["bias_kind"] else b"")
    require(len(gguf) == N * G * 34, "GGUF Q8 shape")
    require(len(q0) + len(q1) == T * G * 8 * 32 and
            len(scale) == T * G * 8 * 2, "production BO shape")
    require(len(bias) == (N * 4 if record["bias_kind"] else 0), "bias shape")
    for n in range(N):
        tile, lane = divmod(n, 8)
        shard = tile & 1
        local_tile = tile // 2
        for g in range(G):
            block = gguf[(n * G + g) * 34:(n * G + g + 1) * 34]
            qoff = ((local_tile * G + g) * 8 + lane) * 32
            soff = ((tile * G + g) * 8 + lane) * 2
            require((q1 if shard else q0)[qoff:qoff + 32] == block[2:],
                    f"GGUF/BO q n={n} g={g}")
            require(scale[soff:soff + 2] == block[:2],
                    f"GGUF/BO half n={n} g={g}")
    return q0, q1, scale, bias


def oracle(reference, source: bytes, gguf: bytes, bias: bytes,
           rows: int, K: int, N: int) -> tuple[bytes, bytes, bytes, bytes, bytes]:
    G = K // 32
    x = np.frombuffer(source, dtype="<f4").reshape(rows, K)
    require(np.isfinite(x).all(), "source finite")
    aq_bytes = reference.quantize_rows(x)
    aq = np.frombuffer(aq_bytes, dtype=reference.Q8_DTYPE).reshape(rows, G)
    w = np.frombuffer(gguf, dtype=reference.Q8_DTYPE).reshape(N, G)
    aq_q = aq["q"].tobytes()
    aq_scale = aq["scale"].view("<u2").tobytes()
    ps = np.zeros((rows, N), dtype="<f4")
    # Stored [row,group,column,6]: dot, sa, sw, product, term, committed PS.
    steps = np.empty((rows, G, N, 6), dtype="<u4")
    wq = w["q"].astype(np.int32)
    ws = w["scale"].astype("<f4")
    require(np.isfinite(ws).all() and np.all(ws >= 0), "weight scale domain")
    for r in range(rows):
        for g in range(G):
            aa = aq["q"][r, g].astype(np.int32)
            dot = np.sum(wq[:, g, :] * aa, axis=1, dtype=np.int32)
            sa = np.float32(aq["scale"][r, g])
            require(np.isfinite(sa) and sa >= 0, "activation scale domain")
            product = np.multiply(sa, ws[:, g], dtype=np.float32)
            term = np.multiply(dot.astype("<f4"), product, dtype=np.float32)
            ps[r] = np.add(ps[r], term, dtype=np.float32)
            require(np.isfinite(product).all() and np.isfinite(term).all() and
                    np.isfinite(ps[r]).all(), f"nonfinite group r={r} g={g}")
            steps[r, g, :, 0] = dot.view("<u4")
            steps[r, g, :, 1] = np.asarray(sa, dtype="<f4").view("<u4")
            steps[r, g, :, 2] = ws[:, g].view("<u4")
            steps[r, g, :, 3] = product.view("<u4")
            steps[r, g, :, 4] = term.view("<u4")
            steps[r, g, :, 5] = ps[r].view("<u4")
    if bias:
        b = np.frombuffer(bias, dtype="<f4")
        require(np.isfinite(b).all(), "bias finite")
        ps = np.add(ps, b[None, :], dtype=np.float32)
    require(np.isfinite(ps).all(), "final finite")
    return aq_q, aq_scale, steps.tobytes(), ps.tobytes(), aq_bytes


def scatter_qkv(output: bytes, row0: int, rows: int, N: int, batch: int = 0) -> bytes:
    # Four U32 per expected write: shard, byte offset, value bits, row-local.
    values = np.frombuffer(output, dtype="<u4").reshape(rows, N)
    records = bytearray()
    for r in range(rows):
        for n in range(N):
            plane, rem = divmod(n, 1024)
            head, d = divmod(rem, 64)
            shard = head & 1
            local_head = head // 2
            offset = (((((plane * 2 + batch) * 8 + local_head) * 1024 +
                        row0 + r) * 64) + d) * 4
            records += struct.pack("<4I", shard, offset, int(values[r, n]), r)
    return bytes(records)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    ap.add_argument("model_package", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    root, model_dir, out = args.root.resolve(), args.model_package.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    sys.path.insert(0, str(root / "tests"))
    from full_fixture_test import Evidence
    import full_reference as ref
    evidence = Evidence(root, out)
    header = model_dir / "laya_model_layout_generated.h"
    header_text = header.read_text()
    tags = {name: package_tag(header_text, name) for name in
            ("kFullModelTag", "kFullNumericTag", "kFullLayoutTag",
             "kFullBuildTag")}
    cases = (("act", "act_fc2.weight", "act_fc2.bias", "act_hidden", 0, 1, 256, 2),
             ("qkv_row1", "qkv.0.weight", None, "embedding_norm", 0, 1, 1024, 3072),
             ("qkv_rows4", "qkv.0.weight", None, "embedding_norm", 0, 4, 1024, 3072))
    records = []
    frozen = root / "results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128"
    for name, weight_name, bias_name, source_name, row0, rows, K, N in cases:
        record = model_record(header, weight_name)
        require((record["K"], record["N"], record["dtype"]) == (K, N, 8), "record shape")
        weight = evidence.weight(weight_name)
        bias_gguf = evidence.weight(bias_name) if bias_name else b""
        q0, q1, scale, bias = bo_weights(model_dir, record, weight)
        require(bias == bias_gguf, "GGUF/BO bias")
        source_path = frozen / (source_name + ".f32.bin")
        raw = source_path.read_bytes()
        require(len(raw) == (1024 if name == "act" else 128 * 1024 * 4),
                "frozen source full extent")
        source_offset = row0 * K * 4
        source = raw[source_offset:source_offset + rows * K * 4]
        require(len(source) == rows * K * 4, "source shape")
        aq_q, aq_scale, steps, final, packed_a = oracle(
            ref, source, weight, bias, rows, K, N)
        second, _ = ref.q8_linear_full(
            packed_a, weight, rows, K, N,
            np.frombuffer(bias, dtype="<f4") if bias else None)
        require(second.tobytes() == final, "independent full-reference cross-check")
        prefix = name + "_"
        products = {key: write(out, prefix + key + ".bin", data)
                    for key, data in (("q0", q0), ("q1", q1), ("w_scale", scale),
                                      ("bias", bias), ("source_f32", source),
                                      ("a8_q", aq_q), ("a8_scale", aq_scale),
                                      ("steps_u32x6", steps), ("output_f32", final))}
        if name.startswith("qkv"):
            products["scatter_u32x4"] = write(out, prefix + "scatter_u32x4.bin",
                                                scatter_qkv(final, row0, rows, N))
        source_spec = ({"id": 10, "bank": 0, "region": 2, "epoch": 1,
                        "stage": 6, "layer": 255, "row_space": "BATCH",
                        "width": 256} if name == "act" else
                       {"id": 1, "bank": 1, "region": 0, "epoch": 1,
                        "stage": 1, "layer": 255, "row_space": "TOKEN",
                        "width": 1024})
        source_spec.update({"batch": 0, "row0": row0, "rows": rows,
                            "dtype": "F32", "semantic_node": source_name})
        records.append({"name": name, "shape": {"rows": rows, "K": K, "N": N,
                                                  "row0": row0, "batch": 0},
                        "consumer": {"op": 0x37 if name == "act" else 0x30,
                                     "stage": 6 if name == "act" else 2,
                                     "layer": 255 if name == "act" else 0},
                        "source_profile": source_spec,
                        "source_slice": {"byte_offset": source_offset,
                                         "bytes": len(source),
                                         "sha256": hashlib.sha256(source).hexdigest()},
                        "weight_key": [record["family"], record["layer"]],
                        "model_record": record, "products": products,
                        "group_records": rows * (K // 32) * N,
                        "valid_macs": rows * K * N,
                        "source": digest(source_path)})
    manifest = {"schema": "tm1tn8_real_fixtures_v2", "model": evidence.checked,
                "model_package": str(model_dir), "layout_header": digest(header),
                "fixture_profile_version": 1,
                "session": {"request_id": 3, "generation": 1, "B": 1, "S": 128},
                "package_tags_hex": tags,
                "cases": records,
                "oracle_source": digest(root / "tests/full_reference.py"),
                "generator_source": digest(Path(__file__))}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print("TM1TN8_REAL_FIXTURE_PASS cases=3 QKV_rows=1,4")


if __name__ == "__main__":
    main()
