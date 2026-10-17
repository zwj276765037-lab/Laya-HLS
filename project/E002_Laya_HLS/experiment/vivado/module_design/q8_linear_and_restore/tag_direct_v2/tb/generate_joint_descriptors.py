#!/usr/bin/env python3
"""Emit the isolated joint prototype's ACT command stream, byte by byte.

This generator intentionally does not import C++ layouts or serialize structs.
Its fixed vector catches ABI index, endian and reserved-word drift.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import struct
import sys


MAGIC = 0x51384A50
WORDS = 128
OBSERVED_WORDS = 32768
REQUEST = 0x0123456789ABCDEF
GENERATION = 1
TAG_HEX = (
    "6eb6ef58bc4f99bd9db40381604108af",
    "aeb13e7937d29fe6a2c68c407249f294",
    "f927881686d9d11c91b7f11ac59e2cc7",
    "fe067c8aa0627ad770096f9721394645",
)
TAG_NAMES = ("kFullModelTag", "kFullNumericTag", "kFullLayoutTag", "kFullBuildTag")
FIXED_LOAD_PREFIX_HEX = (
    "504a3851010000000000000000000000efcdab89674523010100000000000000"
    "010000008000000006000000ff00000002000000800000000000000000000000"
)
FIXED_LOAD_SHA256 = "f929ed6e433207f17a559151da7362462d8a14dbdf097874bb63eccef829ceb2"


def require(ok: bool, why: str) -> None:
    if not ok:
        raise AssertionError(why)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def put64(words: list[int], at: int, value: int) -> None:
    require(0 <= value < 1 << 64, "U64 overflow")
    words[at] = value & 0xFFFFFFFF
    words[at + 1] = value >> 32


def put_tag(words: list[int], at: int, tag: str) -> None:
    words[at:at + 4] = struct.unpack("<4I", bytes.fromhex(tag))


def descriptor(command: int, *, batch: int = 0, quant: int = 0,
               linear: int = 0, ps_epoch: int = 0, trace: bool = False,
               column: int = 0) -> bytes:
    w = [0] * WORDS
    w[0:4] = [MAGIC, 1, command, int(trace)]
    put64(w, 4, REQUEST)
    put64(w, 6, GENERATION)
    w[8] = 1 if command == 0 else linear
    w[9:21] = [0x80 if command == 0 else 0x37, 6, 255, 2, 128,
               batch, 0, 1, 256, 2, 12, 255]
    if command == 0:
        w[25:29] = [0x23, 0, 1, 0]  # WEIGHT destination
    else:
        w[21:25] = [10, 0, batch + 1, 2]  # HEAD_WORK ACT_HIDDEN source
        w[25:29] = [10, 0, ps_epoch, 4]  # HEAD_WORK ACT_LOGITS destination
    w[29:32] = [1, ps_epoch, quant]
    for at, tag in zip((32, 36, 40, 44), TAG_HEX):
        put_tag(w, at, tag)
    if command:
        put64(w, 54, 1024)  # one actual 256-F32 activation row
        put64(w, 56, 8)  # two actual F32 outputs
        w[60:62] = [0, column if trace else 0]
    w[62] = OBSERVED_WORDS
    return b"".join(struct.pack("<I", value) for value in w)


def check_frozen_tags(header: Path) -> None:
    text = header.read_text()
    for name, expected in zip(TAG_NAMES, TAG_HEX):
        match = re.search(rf"\b{name}\[16\]\s*=\s*\{{([^}}]+)\}}", text)
        require(match is not None, f"missing {name}")
        actual = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]+)", match.group(1)))
        require(actual.hex() == expected, f"frozen {name} mismatch")


def main() -> int:
    require(len(sys.argv) == 3, "usage: generate_joint_descriptors.py ROOT OUTPUT_DIR")
    root = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    fixture = root / "vivado/module_design/q8_linear_and_restore/runs/fixture_act_v1/fixture"
    report = json.loads((fixture / "fixture_report.json").read_text())
    require(report["status"] == "INDEPENDENT_R0_AND_ACCEPTED_CPU_BIT_EXACT", "fixture status")
    require(report["weight_key"] == {"family": 12, "layer": 255}, "fixture key")
    require(report["shape"] == {"K": 256, "N": 2, "rows_per_run": 1,
                                "B": 2, "S": 128}, "fixture shape")
    require([row["batch"] for row in report["runs"]] == [0, 1], "fixture batch order")
    require([row["trace_column"] for row in report["runs"]] == [0, 1],
            "fixture trace selection")
    check_frozen_tags(root / "build/model-attention-rtl-repair-20261008/laya_model_layout_generated.h")
    for row in report["runs"]:
        for key in ("input", "q", "scale", "expected"):
            entry = row[key]
            require(sha(Path(entry["path"]).read_bytes()) == entry["sha256"], f"fixture {key}")
    sequence = ["load_w", "run_b0_trace_n0", "run_b1_trace_n1", "run_b0_trace_off"]
    commands = {
        "load_w": descriptor(0),
        "run_b0_trace_n0": descriptor(1, batch=0, quant=2, linear=3, ps_epoch=1, trace=True, column=0),
        "run_b1_trace_n1": descriptor(1, batch=1, quant=4, linear=5, ps_epoch=2, trace=True, column=1),
        "run_b0_trace_off": descriptor(1, batch=0, quant=6, linear=7, ps_epoch=3),
    }
    require(commands["load_w"][:64].hex() == FIXED_LOAD_PREFIX_HEX, "fixed endian prefix")
    require(sha(commands["load_w"]) == FIXED_LOAD_SHA256, "fixed 128-word vector")
    output.mkdir(parents=True, exist_ok=True)
    records = {}
    for name in sequence:
        data = commands[name]
        path = output / f"{name}.bin"
        path.write_bytes(data)
        records[name] = {"path": str(path), "bytes": len(data), "sha256": sha(data)}
    selected_traces = {}
    for row in report["runs"]:
        batch = row["batch"]
        trace = row["traces"][row["trace_column"]]
        require(trace["column"] == row["trace_column"] and
                len(trace["groups"]) == 8, "selected ACT trace")
        payload = bytearray()
        for group in trace["groups"]:
            require(group["group"] == len(payload) // 32, "ACT group order")
            payload.extend(struct.pack("<8I", group["dot_i32"] & 0xFFFFFFFF,
                                       group["sa_f32_bits"], group["sw_f32_bits"],
                                       group["product_f32_bits"], group["term_f32_bits"],
                                       group["ps_f32_bits"], group["group"], 1))
        path = output / f"act_b{batch}_selected_trace_256.bin"
        path.write_bytes(payload)
        selected_traces[str(batch)] = {"path": str(path), "bytes": len(payload),
                                       "sha256": sha(payload),
                                       "bias_bits": trace["bias_f32_bits"],
                                       "final_bits": trace["final_f32_bits"]}
    manifest = {
        "schema": "q8_joint_descriptor_vectors_v1", "endianness": "little",
        "words": WORDS, "request_id": REQUEST, "generation": GENERATION,
        "fixture_report_sha256": sha((fixture / "fixture_report.json").read_bytes()),
        "fixed_load_prefix_hex": FIXED_LOAD_PREFIX_HEX,
        "fixed_load_sha256": FIXED_LOAD_SHA256,
        "sequence": sequence,
        "commands": records,
        "selected_traces": selected_traces,
    }
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print("Q8_JOINT_DESCRIPTOR_VECTOR_PASS commands=4 words=128")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
