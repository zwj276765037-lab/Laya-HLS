#!/usr/bin/env python3
"""Materialize the first real full-K/N Scorer pilot after a separate run gate.

This source is deliberately dormant at the source-preparation checkpoint. It
reads original BO/GGUF/checkpoints, makes its gold with the independent R0
reference, and writes only into a fresh output directory supplied by the run.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import struct
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[6]
MODEL = ROOT / "build/model-attention-rtl-repair-20261008"
ACCEPTED = ROOT / "results/engineering_p2/full_cpu_final_20261007"
PAGE = 4096
GUARD = 0xA5
K = N = 1024
G = 32
T = 128
BATCH = 1
ROW = 15
COLUMN = 7
OBS_WORDS = 32768
PORTS = ("descriptor", "w_q0", "w_q1", "w_scale", "aux",
         "activation", "out0", "out1", "observed")
PORT_POINTERS = {name: (0x10 + idx) << 32 for idx, name in enumerate(PORTS)}
CHECKPOINT_SHA = {
    "marker_norm.f32.bin": "969cf212034ccf7a5d6bb785e59ccbfce84cbd2fa9233591f506176076f7c10a",
    "scorer_fc1_baked.f32.bin": "d28bd65f45910d32ff3de4cea1fcdc583b2cff8635b95bd03677e855b5d9f14f",
}


def need(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def check_file(path: Path, size: int | None = None,
               sha256: str | None = None) -> bytes:
    data = path.read_bytes()
    need(size is None or len(data) == size, f"size: {path}")
    need(sha256 is None or digest(data) == sha256, f"SHA256: {path}")
    return data


def record(path: Path, data: bytes | None = None) -> dict:
    raw = path.read_bytes() if data is None else data
    return {"path": str(path), "bytes": len(raw), "sha256": digest(raw)}


def le32(values) -> bytes:
    return b"".join(struct.pack("<I", int(v) & 0xFFFFFFFF) for v in values)


def word(raw: bytes, index: int) -> int:
    return struct.unpack_from("<I", raw, 4 * index)[0]


def fbits(value) -> int:
    return struct.unpack("<I", struct.pack("<f", float(value)))[0]


def u64(words: list[int], index: int, value: int) -> None:
    need(0 <= value < 1 << 64, "u64")
    words[index:index + 2] = [value & 0xFFFFFFFF, value >> 32]


def guarded(data: bytes = b"", offset: int = 0) -> bytes:
    need(0 <= offset and offset + len(data) <= PAGE, "page bounds")
    result = bytearray([GUARD] * PAGE)
    result[offset:offset + len(data)] = data
    return bytes(result)


def save(out: Path, relative: str, raw: bytes) -> dict:
    path = out / relative
    need(not path.exists(), f"fresh output required: {path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(raw)
    return {"relative_path": relative, "bytes": len(raw), "sha256": digest(raw)}


def descriptor(tags: dict, command: int, task: int, quant: int,
               ps_epoch: int, trace: bool) -> bytes:
    w = [0] * 128
    w[0:4] = [0x51384A50, 1, command, int(trace)]
    u64(w, 4, 0x0123456789ABCDEF)
    u64(w, 6, 1)
    w[8:21] = [task, 0x80 if command == 0 else 0x36,
               5, 255, 2, 128, 0 if command == 0 else BATCH,
               0 if command == 0 else ROW, 1, K, N, 9, 255]
    if command == 0:
        w[25:29] = [0x23, 0, 1, 0]
    else:
        w[21:25] = [10, 0, 1, 0]
        w[25:29] = [10, 0, ps_epoch, 0]
        u64(w, 54, PAGE)
        u64(w, 56, PAGE)
        w[60:62] = [0, COLUMN if trace else 0]
    w[29:32] = [1, ps_epoch, quant]
    for index, key in zip((32, 36, 40, 44), ("model", "numeric", "layout", "build")):
        tag = bytes.fromhex(tags[key])
        need(len(tag) == 16, f"tag {key}")
        w[index:index + 4] = struct.unpack("<4I", tag)
    w[62] = OBS_WORDS
    return le32(w)


def expected_header(desc: bytes, cmd: int, trace: bool, bias_bits: int,
                    final_bits: int, reuses: int) -> bytes:
    d = [word(desc, i) for i in range(128)]
    h = [0] * 256
    h[0:14] = [0x51384F42, 1, d[2], 0, 0, 0xFFFFFFFF, 0xFFFFFFFF,
               d[8], d[8], d[8], 0, 1,
               T * G * 8 * 34 if cmd == 0 else N, 3 if cmd == 0 else 1]
    h[14:29] = [d[4], d[5], d[6], d[7], d[12], d[13], d[10], d[11],
                d[14], d[15], d[16], d[17], d[18], d[19], d[20]]
    h[29:40] = [1, 0 if cmd == 0 else reuses + 1,
                0 if cmd == 0 else d[30], d[21], d[22], d[23], d[24],
                d[25], d[26], d[27], d[28]]
    h[40:50] = [2, 6 if cmd == 0 else 2, 6 if cmd == 0 else 2,
                6 if cmd == 0 else 2, 1, 0 if cmd == 0 else reuses + 1,
                0 if cmd == 0 else d[30], 0 if cmd == 0 else d[27],
                1, reuses]
    if cmd:
        h[50:58] = [G, K, T * G, 0, T * G, N, K * N, 0]
    h[58:64] = ([0, COLUMN, bias_bits, 1, final_bits, G]
                if trace else [0] * 6)
    port_counts = ({"descriptor": 512, "w_q0": 524288, "w_q1": 524288,
                    "w_scale": 65536, "aux": 128 + 4096, "observed": 1024}
                   if cmd == 0 else
                   {"descriptor": 512, "activation": PAGE, "out0": PAGE,
                    "observed": 1024 + (G * 32 + G * 2 + G * 32 if trace else 0)})
    for i, port in enumerate(PORTS):
        h[64 + 4 * i] = h[64 + 4 * i + 2] = port_counts.get(port, 0)
    h[100:116] = d[32:48]
    h[116:122] = [0 if cmd == 0 else d[31], 0, 0 if cmd == 0 else 1,
                  int(cmd != 0), int(cmd == 0), 0]
    return le32(h)


def trace_oracle(reference, activation: bytes, weights: bytes,
                 bias: bytes) -> tuple[bytes, bytes, int, int]:
    aq = np.frombuffer(activation, dtype=reference.Q8_DTYPE).reshape(G)
    wq = np.frombuffer(weights, dtype=reference.Q8_DTYPE).reshape(N, G)
    gold, triples = reference.q8_linear_full(
        activation, weights, 1, K, N, np.frombuffer(bias, dtype="<f4"),
        trace=(0, COLUMN))
    trace = bytearray()
    ps = reference.F32(0)
    for g in range(G):
        dot = sum(int(aq["q"][g, k]) * int(wq["q"][COLUMN, g, k])
                  for k in range(32))
        sa = reference.F32(aq["scale"][g])
        sw = reference.F32(wq["scale"][COLUMN, g])
        product = reference.mul(sa, sw)
        term = reference.mul(reference.F32(dot), product)
        ps = reference.add(ps, term)
        need((dot, fbits(term), fbits(ps)) == triples[g],
             f"independent full-N/trace discrepancy g={g}")
        trace += le32((dot, fbits(sa), fbits(sw), fbits(product),
                       fbits(term), fbits(ps), g, 1))
    need(fbits(reference.add(ps, np.frombuffer(bias, dtype="<f4")[COLUMN])) ==
         fbits(gold[0, COLUMN]), "bias trace final")
    return gold.tobytes(), bytes(trace), word(bias, COLUMN), fbits(gold[0, COLUMN])


def main() -> int:
    need(len(sys.argv) == 2, "usage: materialize_scorer_pilot.py FRESH_OUTPUT_DIR")
    out = Path(sys.argv[1]).resolve()
    need(not out.exists(), "fixture output must be fresh")
    manifest_raw = check_file(MODEL / "manifest.json", 147765,
                              "128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa")
    model = json.loads(manifest_raw)
    header = check_file(MODEL / "laya_model_layout_generated.h", 106348,
                        "c2fd1da7b00c7361d616ac15af431dea14c4979ac2aded6b37888fb1d633630a")
    weight = next(w for w in model["weights"] if w["family"] == 9 and w["layer"] == 255)
    need((weight["name"], weight["K"], weight["N"], weight["dtype"],
          weight["bias_name"], weight["q_span"], weight["scale_span"],
          weight["bias_span"]) ==
         ("scorer_fc1.weight", K, N, 8, "linear_120_baked_bias",
          [524288, 524288], 65536, 4096), "current full weight record")
    expected_fragment = (f'{{"scorer_fc1.weight", {{9, 255}}, {K}, {N}, 8, 1, '
                         f'{{{weight["q_base"][0]}, {weight["q_base"][1]}}}, '
                         f'{{{weight["q_span"][0]}, {weight["q_span"][1]}}}, '
                         f'{weight["scale_base"]}, {weight["scale_span"]}, 0, 0, '
                         f'{weight["bias_base"]}, {weight["bias_span"]},')
    need(expected_fragment in header.decode(), "generated kFullWeights record")
    source_records = [record(MODEL / "manifest.json", manifest_raw),
                      record(MODEL / "laya_model_layout_generated.h", header)]
    bo = {}
    for name in ("w_q0", "w_q1", "w_scale", "aux"):
        entry = model["bo"][name]
        raw = check_file(MODEL / entry["file"], entry["size"], entry["sha256"])
        bo[name] = raw
        source_records.append(record(MODEL / entry["file"], raw))
    gguf_entry = model["source_model"]
    gguf_path = Path(gguf_entry["path"])
    gguf = check_file(gguf_path, gguf_entry["size"], gguf_entry["sha256"])
    source_records.append(record(gguf_path, gguf))
    tensors = {t["name"]: t for t in model["tensors"]}
    raw_weight = gguf[tensors["scorer_fc1.weight"]["source_offset"]:
                      tensors["scorer_fc1.weight"]["source_offset"] + 1114112]
    raw_bias = gguf[tensors["linear_120_baked_bias"]["source_offset"]:
                    tensors["linear_120_baked_bias"]["source_offset"] + PAGE]
    need(digest(raw_weight) == weight["source_sha256"] ==
         tensors["scorer_fc1.weight"]["source_sha256"], "original GGUF weight")
    need(digest(raw_bias) == weight["bias_sha256"] ==
         tensors["linear_120_baked_bias"]["source_sha256"], "baked bias GGUF")
    need(raw_bias == bo["aux"][weight["bias_base"]:weight["bias_base"] + PAGE],
         "baked bias BO/GGUF")
    aux_end = len(bo["aux"])
    bias_end = weight["bias_base"] + weight["bias_span"]
    need(aux_end == bias_end == 1671872 and weight["bias_base"] == 1667776,
         "original AUX bias reaches exact BO end")
    need(128 <= aux_end and weight["bias_span"] == PAGE,
         "original AUX header/bias bounds")
    final_aux_page = 1671168
    final_aux_prefix = 704
    need(final_aux_page == (bias_end - 1) // PAGE * PAGE and
         aux_end - final_aux_page == final_aux_prefix,
         "original AUX final page layout")
    for n in range(N):
        tile, cc = divmod(n, 8)
        shard = tile % 2
        for g in range(G):
            raw = raw_weight[(n * G + g) * 34:(n * G + g + 1) * 34]
            qoff = weight["q_base"][shard] + (((tile // 2) * G + g) * 8 + cc) * 32
            soff = weight["scale_base"] + ((tile * G + g) * 8 + cc) * 2
            need(raw[2:] == bo[f"w_q{shard}"][qoff:qoff + 32], f"Q8 q n={n} g={g}")
            need(raw[:2] == bo["w_scale"][soff:soff + 2], f"Q8 scale n={n} g={g}")
    oracle_dir = ACCEPTED / "oracle/B2_S128"
    dut_dir = ACCEPTED / "dut/dut/B2_S128"
    checkpoints = {}
    for name, expected_sha in CHECKPOINT_SHA.items():
        original = check_file(oracle_dir / name, 2 * 16 * K * 4, expected_sha)
        comparison = check_file(dut_dir / name, len(original), expected_sha)
        need(original == comparison, f"accepted oracle/DUT checkpoint {name}")
        checkpoints[name] = original
        source_records.extend((record(oracle_dir / name, original),
                               record(dut_dir / name, comparison)))
    off = (BATCH * 16 + ROW) * K * 4
    activation = checkpoints["marker_norm.f32.bin"][off:off + PAGE]
    frozen_gold = checkpoints["scorer_fc1_baked.f32.bin"][off:off + PAGE]
    sys.path.insert(0, str(ROOT / "tests"))
    import full_reference as reference
    source_records.append(record(ROOT / "tests/full_reference.py"))
    packed = reference.quantize_rows(np.frombuffer(activation, dtype="<f4").reshape(1, K))
    need(len(packed) == G * 34, "full-K quantized row")
    gold, groups, bias_bits, final_bits = trace_oracle(reference, packed, raw_weight, raw_bias)
    need(gold == frozen_gold, "independent full-N bit identity with frozen scorer node")
    aq = b"".join(packed[g * 34 + 2:(g + 1) * 34] for g in range(G))
    scales = b"".join(packed[g * 34:g * 34 + 2] for g in range(G))

    out.mkdir(parents=True)
    products = {"input": save(out, "gold/input_row_4096.bin", activation),
                "expected": save(out, "gold/scorer_row_4096.bin", gold),
                "a8_q": save(out, "gold/a8_q_1024.bin", aq),
                "a8_scale": save(out, "gold/a8_scale_64.bin", scales),
                "trace": save(out, "gold/column7_groups_1024.bin", groups)}
    pages = {}
    partial_model_pages = []
    for port in PORTS:
        offsets = ([0] if port == "descriptor" else
                   [weight["q_base"][0] + i * PAGE for i in range(128)] if port == "w_q0" else
                   [weight["q_base"][1] + i * PAGE for i in range(128)] if port == "w_q1" else
                   [weight["scale_base"] + i * PAGE for i in range(16)] if port == "w_scale" else
                   [0, weight["bias_base"] // PAGE * PAGE,
                    (weight["bias_base"] // PAGE + 1) * PAGE] if port == "aux" else
                   [i * PAGE for i in range(32 if port == "observed" else
                                           1 if port == "out1" else 16)])
        data = []
        for slot, offset in enumerate(offsets):
            if port in bo:
                page = bo[port][offset:offset + PAGE]
                if port == "aux" and slot == 2:
                    need(offset == final_aux_page and len(page) == final_aux_prefix,
                         "AUX final page source bounds")
                    partial_model_pages.append({
                        "port": port, "slot": slot, "bo_offset": offset,
                        "source_prefix_interval": [offset, aux_end],
                        "source_prefix_bytes": final_aux_prefix,
                        "forbidden_suffix_interval": [aux_end, offset + PAGE],
                        "forbidden_suffix_bytes": PAGE - final_aux_prefix,
                        "sentinel": GUARD})
                    page = guarded(page)
                else:
                    need(len(page) == PAGE, f"BO page bounds {port} {offset}")
            elif port == "activation" and slot == 0:
                page = activation
            else:
                page = guarded()
            data.append(page)
        blob = b"".join(data)
        pages[port] = {"image": save(out, f"pages/{port}.bin", blob),
                       "offsets": offsets,
                       "absolute_bases": [PORT_POINTERS[port] + x for x in offsets],
                       "page_sha256": [digest(x) for x in data]}
    need(sum(len(p["offsets"]) for p in pages.values()) == 341, "static page count")
    need(len(partial_model_pages) == 1, "only the known AUX final page may be partial")
    commands = []
    for name, cmd, task, quant, ps_epoch, trace, reuse in (
        ("load_w", 0, 1, 0, 0, False, 0),
        ("run_trace_on", 1, 3, 2, 1, True, 0),
        ("run_trace_off", 1, 5, 4, 2, False, 1),
    ):
        desc = descriptor(model["tags"], cmd, task, quant, ps_epoch, trace)
        need(len(desc) == 512, "descriptor length")
        h = expected_header(desc, cmd, trace, bias_bits, final_bits, reuse)
        obs = bytearray([GUARD] * (OBS_WORDS * 4))
        obs[:1024] = h
        if trace:
            obs[1024:2048] = aq
            obs[66560:66624] = scales
            obs[70656:71680] = groups
        commands.append({
            "name": name, "command": cmd, "task_id": task,
            "quant_task_id": quant, "ps_epoch": ps_epoch, "trace": trace,
            "descriptor": save(out, f"commands/{name}/descriptor_page.bin", guarded(desc)),
            "header": save(out, f"commands/{name}/expected_header_1024.bin", h),
            "observed": save(out, f"commands/{name}/expected_observed_131072.bin", bytes(obs)),
            "out0": save(out, f"commands/{name}/expected_out0_65536.bin",
                         (gold if cmd else guarded()) + guarded() * 15),
            "out1": save(out, f"commands/{name}/expected_out1_4096.bin", guarded()),
            "useful_bytes": ({"descriptor": 512, "w_q0": 524288,
                              "w_q1": 524288, "w_scale": 65536,
                              "aux": 4224, "observed": 1024} if cmd == 0 else
                             {"descriptor": 512, "activation": 4096,
                              "out0": 4096, "observed": 3136 if trace else 1024}),
        })
    report = {"schema": "q8_full_scorer_first_pilot_fixture_v1",
              "status": "INDEPENDENT_FULL_K_N_R0_AND_FROZEN_NODE_BIT_EXACT",
              "source_only_until_separate_gate": False,
              "shape": {"B": 2, "S": 128, "batch": BATCH, "row": ROW,
                        "rows": 1, "K": K, "N": N, "G": G, "T": T},
              "weight": weight, "gguf_slices": [
                  {"name": "scorer_fc1.weight", "offset": tensors["scorer_fc1.weight"]["source_offset"],
                   "bytes": len(raw_weight), "sha256": digest(raw_weight)},
                  {"name": "linear_120_baked_bias", "offset": tensors["linear_120_baked_bias"]["source_offset"],
                   "bytes": len(raw_bias), "sha256": digest(raw_bias)}],
              "source_records": source_records, "products": products,
              "pages": pages, "page_count": 341,
              "partial_model_pages": partial_model_pages,
              "commands": commands, "trace_column": COLUMN,
              "logical_work_per_run": {"quant_groups": 32, "quant_inputs": 1024,
                                       "issued": 4096, "retired": 4096,
                                       "integer_macs": 1048576,
                                       "output_f32": 1024}}
    save(out, "fixture_report.json", (json.dumps(report, indent=2, sort_keys=True) + "\n").encode())
    print("Q8_SCORER_PILOT_FIXTURE_PASS commands=3 K=1024 N=1024")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
