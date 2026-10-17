#!/usr/bin/env python3
"""Export the frozen Laya GGUF into the fixed P2 five-BO model layout.

This is an offline build tool. Its JSON manifest and generated C++ table are
read-only build inputs; the forward kernel never parses JSON or GGUF metadata.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import mmap
import os
from pathlib import Path
import platform
import struct
import subprocess
import sys

import numpy as np


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_GGUF = (ROOT.parents[1] / "model/quantized/gguf/mys/"
                "laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf")
MODEL_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"
GRAPH_SHA = "f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9"
MODEL_SIZE = 455179648
TOTAL_PAYLOAD = 453123852
OMITTED_BIAS_BYTES = 4202500
BO_NAMES = ("embedding", "w_q0", "w_q1", "w_scale", "aux")
BO_INDEX = {"embedding": 0, "aux": 5}

FAMILIES = (
    (1, "qkv", 28, 1024, 3072, 8),
    (2, "wo", 28, 1024, 1024, 8),
    (3, "mlp_wi", 28, 1024, 5248, 8),
    (4, "mlp_wo", 28, 2624, 1024, 8),
    (5, "head_qkv", 2, 1024, 3072, 8),
    (6, "head_wo", 2, 1024, 1024, 8),
    (7, "head_fc1", 2, 1024, 4096, 8),
    (8, "head_fc2", 2, 4096, 1024, 8),
    (9, "scorer_fc1", 1, 1024, 1024, 8),
    (10, "scorer_fc2", 1, 1024, 1, 0),
    (11, "act_fc1", 1, 1028, 256, 1),
    (12, "act_fc2", 1, 256, 2, 8),
)


def sha256(data: bytes | memoryview) -> str:
    return hashlib.sha256(data).hexdigest()


def file_sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for part in iter(lambda: f.read(1 << 20), b""):
            h.update(part)
    return h.hexdigest()


def canonical_json(obj: object) -> bytes:
    return (json.dumps(obj, sort_keys=True, separators=(",", ":"),
                       ensure_ascii=False) + "\n").encode("utf-8")


class GGUF:
    def __init__(self, data: mmap.mmap):
        self.data = data
        self.pos = 0

    def take(self, count: int) -> bytes:
        if count < 0 or self.pos + count > len(self.data):
            raise ValueError("truncated GGUF metadata")
        out = self.data[self.pos:self.pos + count]
        self.pos += count
        return out

    def unpack(self, fmt: str):
        size = struct.calcsize("<" + fmt)
        value = struct.unpack("<" + fmt, self.take(size))[0]
        return value

    def string(self) -> str:
        count = self.unpack("Q")
        return self.take(count).decode("utf-8")

    def value(self, kind: int):
        if kind == 8:
            return self.string()
        if kind == 9:
            elem_type = self.unpack("I")
            count = self.unpack("Q")
            return [self.value(elem_type) for _ in range(count)]
        formats = {0: "B", 1: "b", 2: "H", 3: "h", 4: "I", 5: "i",
                   6: "f", 7: "?", 10: "Q", 11: "q", 12: "d"}
        if kind not in formats:
            raise ValueError(f"unknown GGUF metadata type {kind}")
        return self.unpack(formats[kind])

    def inventory(self):
        if self.take(4) != b"GGUF":
            raise ValueError("not GGUF")
        version = self.unpack("I")
        count = self.unpack("Q")
        kv_count = self.unpack("Q")
        if version != 3 or count != 153:
            raise ValueError(f"unexpected GGUF version/tensor count {version}/{count}")
        metadata = {}
        for _ in range(kv_count):
            key = self.string()
            kind = self.unpack("I")
            value = self.value(kind)
            if key in ("general.alignment", "ggmlc.graph_spec"):
                metadata[key] = value
        tensors = []
        for _ in range(count):
            name = self.string()
            rank = self.unpack("I")
            ne = [self.unpack("Q") for _ in range(rank)]
            typ = self.unpack("I")
            relative = self.unpack("Q")
            if rank > 4 or typ not in (0, 1, 8):
                raise ValueError(f"unsupported tensor {name}: rank={rank} type={typ}")
            ne += [1] * (4 - rank)
            elements = int(np.prod(ne, dtype=np.int64))
            size = (elements * 34 // 32 if typ == 8 else
                    elements * (4 if typ == 0 else 2))
            if typ == 8 and elements % 32:
                raise ValueError(f"Q8 group incomplete: {name}")
            tensors.append({"name": name, "ggml_type_id": typ,
                            "ggml_ne": ne, "relative_offset": relative,
                            "source_bytes": size})
        alignment = int(metadata.get("general.alignment", 32))
        if alignment < 1 or alignment & (alignment - 1):
            raise ValueError("invalid GGUF data alignment")
        data_base = (self.pos + alignment - 1) & -alignment
        for t in tensors:
            t["source_offset"] = data_base + t.pop("relative_offset")
            if t["source_offset"] + t["source_bytes"] > len(self.data):
                raise ValueError(f"tensor outside GGUF: {t['name']}")
        graph_text = metadata.get("ggmlc.graph_spec")
        if not isinstance(graph_text, str) or sha256(graph_text.encode()) != GRAPH_SHA:
            raise ValueError("frozen graph_spec hash mismatch")
        graph = json.loads(graph_text)
        if (len(graph.get("nodes", [])) != 1364 or
            len(graph.get("parameters", [])) != 153 or
            len(graph.get("inputs", [])) != 5 or
            len(graph.get("outputs", [])) != 2):
            raise ValueError("graph_spec topology mismatch")
        graph_tensors = graph.get("tensors", {})
        graph_by_name = {x.get("name"): x for x in graph_tensors.values()
                         if isinstance(x, dict) and x.get("name")}
        for t in tensors:
            gt = graph_by_name.get(t["name"], {})
            if (gt.get("type") != t["ggml_type_id"] or
                [x.get("val") for x in gt.get("ne", [])] != t["ggml_ne"]):
                raise ValueError(f"graph tensor mismatch: {t['name']}")
        return tensors


def align64(handle) -> int:
    pos = handle.tell()
    extra = (-pos) & 63
    if extra:
        handle.write(bytes(extra))
    return handle.tell()


def tensor_bytes(data: mmap.mmap, tensor: dict) -> memoryview:
    start = tensor["source_offset"]
    return memoryview(data)[start:start + tensor["source_bytes"]]


def expected_weights(by_name: dict[str, dict]):
    specs = []
    used = set()
    for family, prefix, layers, K, N, typ in FAMILIES:
        for layer in range(layers):
            suffix = f".{layer}" if family <= 8 else ""
            name = f"{prefix}{suffix}.weight"
            t = by_name.get(name)
            if not t or t["ggml_type_id"] != typ or t["ggml_ne"] != [K, N, 1, 1]:
                raise ValueError(f"missing/malformed weight {name}")
            used.add(name)
            bias_name = (f"{prefix}{suffix}.bias" if 5 <= family <= 8 else
                         "linear_120_baked_bias" if family == 9 else
                         "scorer_fc2.bias" if family == 10 else
                         "act_fc2.bias" if family == 12 else None)
            if bias_name:
                b = by_name.get(bias_name)
                if not b or b["ggml_type_id"] != 0 or b["ggml_ne"] != [N, 1, 1, 1]:
                    raise ValueError(f"missing/malformed bias {bias_name}")
                used.add(bias_name)
            specs.append((family, layer if family <= 8 else 255, t, bias_name))
    extra = [name for name in by_name if name.endswith(".weight") and
             name not in used and name not in ("tok_emb.weight", "type_emb.weight")]
    if extra:
        raise ValueError(f"unknown Linear binding(s): {extra}")
    for name, n in (("scorer_fc1.bias", 1024), ("act_fc1.bias", 256)):
        b = by_name.get(name)
        if not b or b["ggml_type_id"] != 0 or b["ggml_ne"] != [n, 1, 1, 1]:
            raise ValueError(f"missing post-GELU bias {name}")
    if len(specs) != 124:
        raise ValueError("expected 124 matrix descriptors")
    return specs


def check_slide_bias(payload: memoryview):
    values = np.frombuffer(payload, dtype="<f4").reshape(1025, 1025)
    index = np.arange(1025, dtype=np.int32)
    expected = np.where(np.abs(index[:, None] - index[None, :]) <= 64,
                        np.float32(0.0), np.float32(-10000.0))
    if not np.array_equal(values, expected):
        mismatch = np.argwhere(values != expected)[0]
        raise ValueError(f"slide_bias mismatch at {tuple(mismatch)}")
    return {"rule": "abs(query-key)<=64 ? +0 : -10000",
            "verified_elements": 1025 * 1025,
            "count_zero": int(np.count_nonzero(values == 0)),
            "count_negative_10000": int(np.count_nonzero(values == -10000))}


def place_payloads(data: mmap.mmap, tensors: list[dict],
                   specs: list[tuple], out: Path):
    q8_names = {t["name"] for _, _, t, _ in specs if t["ggml_type_id"] == 8}
    output = {name: (out / f"{name}.bin").open("w+b") for name in BO_NAMES}
    output["aux"].write(bytes(128))
    records = []
    placed = {}
    slide_rule = None
    try:
        for t in tensors:
            payload = tensor_bytes(data, t)
            source_hash = sha256(payload)
            item = {"name": t["name"], "ggml_type_id": t["ggml_type_id"],
                    "ggml_ne": t["ggml_ne"],
                    "source_offset": t["source_offset"],
                    "source_bytes": t["source_bytes"],
                    "source_sha256": source_hash,
                    "omitted": False, "omission_rule": None,
                    "bo": None, "base": 0, "span": 0,
                    "restored_sha256": source_hash}
            name = t["name"]
            if name == "slide_bias":
                if t["source_bytes"] != OMITTED_BIAS_BYTES:
                    raise ValueError("slide_bias byte count mismatch")
                slide_rule = check_slide_bias(payload)
                item.update(omitted=True, omission_rule=slide_rule,
                            restored_sha256=None)
            elif name in ("tok_emb.weight", "type_emb.weight"):
                if t["ggml_type_id"] != 8 or t["ggml_ne"][0] != 1024:
                    raise ValueError(f"bad embedding table {name}")
                f = output["embedding"]
                base = align64(f)
                f.write(payload)
                item.update(bo="embedding", base=base, span=len(payload))
            elif name in q8_names:
                K, N = t["ggml_ne"][:2]
                G = K // 32
                tiles = (N + 7) // 8
                padded_n = tiles * 8
                raw = np.frombuffer(payload, dtype=np.uint8).reshape(N, G, 34)
                padded = np.zeros((padded_n, G, 34), dtype=np.uint8)
                padded[:N] = raw
                q = padded[:, :, 2:34].reshape(tiles, 8, G, 32).transpose(0, 2, 1, 3)
                scales = padded[:, :, 0:2].reshape(tiles, 8, G, 2).transpose(0, 2, 1, 3)
                chunks = {"w_q0": q[::2].tobytes(),
                          "w_q1": q[1::2].tobytes(),
                          "w_scale": scales.tobytes()}
                target = {}
                for bo, blob in chunks.items():
                    f = output[bo]
                    target[f"{bo}_base"] = align64(f) if blob else 0
                    target[f"{bo}_span"] = len(blob)
                    if blob:
                        f.write(blob)
                placed[name] = target
                item.update(bo="q8_matrix", base=0, span=0)
            else:
                f = output["aux"]
                base = align64(f)
                f.write(payload)
                item.update(bo="aux", base=base, span=len(payload))
            records.append(item)
        for f in output.values():
            f.flush()
    finally:
        for f in output.values():
            f.close()
    if slide_rule is None:
        raise ValueError("missing slide_bias")
    return records, placed, slide_rule


def verify_placed(data: mmap.mmap, records: list[dict],
                  placed: dict[str, dict], out: Path):
    handles = {name: (out / f"{name}.bin").open("rb") for name in BO_NAMES}
    try:
        for t in records:
            if t["omitted"]:
                continue
            if t["bo"] != "q8_matrix":
                f = handles[t["bo"]]
                f.seek(t["base"])
                actual = f.read(t["span"])
                if len(actual) != t["source_bytes"] or sha256(actual) != t["source_sha256"]:
                    raise ValueError(f"copied tensor did not restore: {t['name']}")
                continue
            K, N = t["ggml_ne"][:2]
            G = K // 32
            tiles = (N + 7) // 8
            p = placed[t["name"]]
            q = np.zeros((tiles, G, 8, 32), dtype=np.uint8)
            for bo, selection in (("w_q0", slice(0, None, 2)),
                                  ("w_q1", slice(1, None, 2))):
                f = handles[bo]
                f.seek(p[f"{bo}_base"])
                blob = f.read(p[f"{bo}_span"])
                if blob:
                    q[selection] = np.frombuffer(blob, dtype=np.uint8).reshape(-1, G, 8, 32)
            f = handles["w_scale"]
            f.seek(p["w_scale_base"])
            scale_blob = f.read(p["w_scale_span"])
            scales = np.frombuffer(scale_blob, dtype=np.uint8).reshape(tiles, G, 8, 2)
            restored = np.empty((tiles, 8, G, 34), dtype=np.uint8)
            restored[:, :, :, :2] = scales.transpose(0, 2, 1, 3)
            restored[:, :, :, 2:] = q.transpose(0, 2, 1, 3)
            actual = restored.reshape(tiles * 8, G, 34)[:N].tobytes()
            if sha256(actual) != t["source_sha256"]:
                raise ValueError(f"Q8 inverse mismatch: {t['name']}")
            t["restored_sha256"] = sha256(actual)
    finally:
        for f in handles.values():
            f.close()


def make_weights(specs: list[tuple], records: list[dict],
                 placed: dict[str, dict]):
    by_name = {x["name"]: x for x in records}
    result = []
    for family, layer, tensor, bias_name in specs:
        t = by_name[tensor["name"]]
        K, N = t["ggml_ne"][:2]
        loc = placed.get(t["name"], {})
        bias = by_name.get(bias_name) if bias_name else None
        entry = {"family": family, "layer": layer, "name": t["name"],
                 "K": K, "N": N, "dtype": t["ggml_type_id"],
                 "q_base": [loc.get("w_q0_base", 0), loc.get("w_q1_base", 0)],
                 "q_span": [loc.get("w_q0_span", 0), loc.get("w_q1_span", 0)],
                 "scale_base": loc.get("w_scale_base", 0),
                 "scale_span": loc.get("w_scale_span", 0),
                 "aux_base": t["base"] if t["bo"] == "aux" else 0,
                 "aux_span": t["span"] if t["bo"] == "aux" else 0,
                 "bias_name": bias_name,
                 "bias_base": bias["base"] if bias else 0,
                 "bias_span": bias["span"] if bias else 0,
                 "source_sha256": t["source_sha256"],
                 "bias_sha256": bias["source_sha256"] if bias else None}
        result.append(entry)
    return result


def source_manifest() -> list[dict]:
    paths = [ROOT / "CMakeLists.txt"]
    for folder, suffixes in (("include", (".h",)),
                             ("hls", (".h", ".cpp")),
                             ("host", (".h", ".cpp")),
                             ("config", (".cmake", ".cfg", ".tcl", ".json")),
                             ("scripts", (".sh",)),
                             ("tools", (".py",))):
        paths += [p for p in (ROOT / folder).rglob("*")
                  if p.is_file() and p.suffix in suffixes]
    return [{"path": str(p.relative_to(ROOT)), "sha256": file_sha(p)}
            for p in sorted(set(paths))]


def tool_manifest() -> dict:
    def version(command: list[str]) -> str:
        try:
            p = subprocess.run(command, check=False, capture_output=True,
                               text=True, timeout=20)
            return p.stdout.strip() or p.stderr.strip() or f"exit={p.returncode}"
        except (OSError, subprocess.TimeoutExpired) as e:
            return f"MISSING:{type(e).__name__}"
    vitis = "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run"
    return {"compiler": version(["g++", "--version"]).splitlines()[0],
            "vitis_run": version([vitis, "--version"]).splitlines()[0],
            "glibc": platform.libc_ver(),
            "python": platform.python_version(),
            "numpy": np.__version__,
            "part": "xcu55c-fsvh2892-2L-e",
            "requested_clock_hz": 150000000,
            "fp_flags": ["-fno-fast-math", "-ffp-contract=off"],
            "hls_csim_stdmath": True,
            "hls_csim_optimization": "-O2",
            "hls_syn_pipeline_loops": 0,
            "hls_syn_array_partition_throughput_driven": "off",
            "hls_syn_array_partition_complete_threshold": 0,
            "libm": "system glibc",
            "math_functions": ["expf", "tanhf", "logf"]}


def tag_bytes(digest_hex: str) -> bytes:
    return bytes.fromhex(digest_hex)[:16]


def write_model_header(path: Path, tags: dict[str, str]):
    header = bytearray(128)
    struct.pack_into("<4sHHIII", header, 0, b"LYMP", 1, 0, 128, 13, 1)
    for offset, key in ((32, "model"), (48, "numeric"),
                        (64, "layout"), (80, "build")):
        header[offset:offset + 16] = bytes.fromhex(tags[key])
    header[96:128] = bytes.fromhex(MODEL_SHA)
    with path.open("r+b") as f:
        f.seek(0)
        f.write(header)


def c_bytes(hex_value: str) -> str:
    return "{" + ", ".join("0x" + hex_value[i:i + 2]
                            for i in range(0, len(hex_value), 2)) + "}"


def c_array(values: list[int]) -> str:
    return "{" + ", ".join(str(x) for x in values) + "}"


def write_generated_header(path: Path, records: list[dict],
                           weights: list[dict], tags: dict[str, str],
                           sizes: dict[str, int]):
    with path.open("w", encoding="utf-8") as f:
        f.write("#pragma once\n#include \"laya_full_runtime.h\"\n\n")
        f.write("namespace laya::full {\n")
        f.write("// Generated by tools/export_gguf.py from the frozen GGUF.\n")
        for key in ("model", "numeric", "layout", "build"):
            f.write(f"inline constexpr uint8_t kFull{key.title()}Tag[16] = "
                    f"{c_bytes(tags[key])};\n")
        f.write("inline constexpr uint8_t kFullSourceSha256[32] = "
                f"{c_bytes(MODEL_SHA)};\n")
        f.write("inline constexpr uint32_t kFullModelBoSizes[5] = "
                f"{c_array([sizes[x] for x in BO_NAMES])};\n")
        f.write("inline constexpr FullTensorDescriptor kFullTensors[153] = {\n")
        for t in records:
            bo = BO_INDEX.get(t["bo"], 255)
            f.write("  {" + ", ".join((json.dumps(t["name"]),
                str(t["ggml_type_id"]), str(bo), str(int(t["omitted"])), "0",
                c_array(t["ggml_ne"]), str(t["source_offset"]),
                str(t["source_bytes"]), str(t["base"]), str(t["span"]),
                c_bytes(t["source_sha256"]))) + "},\n")
        f.write("};\n")
        f.write("inline constexpr FullWeightDescriptor kFullWeights[124] = {\n")
        for w in weights:
            f.write("  {" + ", ".join((json.dumps(w["name"]),
                c_array([w["family"], w["layer"]]), str(w["K"]), str(w["N"]),
                str(w["dtype"]), str(int(w["bias_name"] is not None)),
                c_array(w["q_base"]), c_array(w["q_span"]),
                str(w["scale_base"]), str(w["scale_span"]),
                str(w["aux_base"]), str(w["aux_span"]),
                str(w["bias_base"]), str(w["bias_span"]),
                c_bytes(w["source_sha256"]),
                c_bytes(w["bias_sha256"] or "00" * 32))) + "},\n")
        f.write("};\n} // namespace laya::full\n")


def export(gguf_path: Path, out: Path):
    gguf_path = gguf_path.resolve()
    if gguf_path.stat().st_size != MODEL_SIZE or file_sha(gguf_path) != MODEL_SHA:
        raise ValueError("frozen GGUF size/SHA-256 mismatch")
    out.mkdir(parents=True, exist_ok=True)
    with gguf_path.open("rb") as source:
        data = mmap.mmap(source.fileno(), 0, access=mmap.ACCESS_READ)
        inventory = GGUF(data).inventory()
        if len({x["name"] for x in inventory}) != 153:
            raise ValueError("duplicate tensor names")
        if sum(x["source_bytes"] for x in inventory) != TOTAL_PAYLOAD:
            raise ValueError("frozen tensor payload total mismatch")
        by_name = {x["name"]: x for x in inventory}
        specs = expected_weights(by_name)
        records, placed, slide_rule = place_payloads(data, inventory, specs, out)
        verify_placed(data, records, placed, out)
        data.close()
    if sum(x["source_bytes"] for x in records if not x["omitted"]) != 448921352:
        raise ValueError("preserved payload total mismatch")
    weights = make_weights(specs, records, placed)
    if (sum(t["ggml_type_id"] == 8 for t in records) != 124 or
        sum(t["ggml_type_id"] == 0 for t in records) != 28 or
        sum(t["ggml_type_id"] == 1 for t in records) != 1):
        raise ValueError("tensor type counts mismatch")
    sizes = {name: (out / f"{name}.bin").stat().st_size for name in BO_NAMES}
    for name, size in sizes.items():
        if size > 0xffffffff:
            raise ValueError(f"{name} exceeds u32 address range")

    task_bytes = (ROOT / "hardware_agent/task.md").read_bytes()
    numeric_start = task_bytes.index(b"### 12.2 ")
    numeric_end = task_bytes.index(b"### 12.3 ", numeric_start)
    numeric_preimage = task_bytes[numeric_start:numeric_end]
    (out / "numeric_preimage.txt").write_bytes(numeric_preimage)
    numeric_sha = sha256(numeric_preimage)
    layout_preimage = canonical_json({
        "schema": "laya-layout-v1", "source_model_sha256": MODEL_SHA,
        "bo_sizes": sizes, "tensors": records, "weights": weights})
    (out / "layout_preimage.json").write_bytes(layout_preimage)
    layout_sha = sha256(layout_preimage)
    build_preimage = canonical_json({
        "schema": "laya-build-v1", "model_sha256": MODEL_SHA,
        "numeric_sha256": numeric_sha, "layout_sha256": layout_sha,
        "sources": source_manifest(), "tool_config": tool_manifest()})
    (out / "build_preimage.json").write_bytes(build_preimage)
    build_sha = sha256(build_preimage)
    tags = {"model": MODEL_SHA[:32], "numeric": numeric_sha[:32],
            "layout": layout_sha[:32], "build": build_sha[:32]}
    write_model_header(out / "aux.bin", tags)
    bo = {name: {"file": f"{name}.bin", "size": sizes[name],
                 "sha256": file_sha(out / f"{name}.bin")}
          for name in BO_NAMES}
    manifest = {
        "schema": "laya-model-p2-v1",
        "source_model": {"path": str(gguf_path), "size": MODEL_SIZE,
                         "sha256": MODEL_SHA,
                         "graph_spec_sha256": GRAPH_SHA,
                         "tensor_count": 153, "payload_bytes": TOTAL_PAYLOAD,
                         "preserved_payload_bytes": TOTAL_PAYLOAD - OMITTED_BIAS_BYTES},
        "tags": tags,
        "tag_preimages": {
            "numeric": {"file": "numeric_preimage.txt", "sha256": numeric_sha},
            "layout": {"file": "layout_preimage.json", "sha256": layout_sha},
            "build": {"file": "build_preimage.json", "sha256": build_sha}},
        "bo": bo, "tensors": records, "weights": weights,
        "slide_bias_verification": slide_rule,
        "generated_header": "laya_model_layout_generated.h",
    }
    write_generated_header(out / manifest["generated_header"], records,
                           weights, tags, sizes)
    (out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False,
                                                indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "EXPORTED_AND_RESTORED", "directory": str(out),
                      "tensors": len(records), "weights": len(weights),
                      "q8_matrices": len(placed), "bo_sizes": sizes,
                      "tags": tags}, sort_keys=True))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gguf", type=Path, default=DEFAULT_GGUF)
    parser.add_argument("--out", type=Path, default=ROOT / "build/model-p2")
    args = parser.parse_args()
    export(args.gguf, args.out)


if __name__ == "__main__":
    main()


