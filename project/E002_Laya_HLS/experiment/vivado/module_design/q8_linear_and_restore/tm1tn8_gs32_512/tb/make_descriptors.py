#!/usr/bin/env python3
"""Serialize isolated Q8T1 ACT and layer0 QKV commands from the new package.

The byte layout is written independently of the C++ ABI header. Source refs
are bound to the frozen first CPU request and the production controller's
LN_EMB -> layer0 QKV source: HIDDEN bank1, not an invented NORM buffer.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

MAGIC = 0x31543851
OBSERVED_WORDS = 32768
REQUEST_ID = 3
GENERATION = 1
SOURCE_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"


def require(ok: bool, why: str) -> None:
    if not ok:
        raise AssertionError(why)


def sha(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def tag(header: str, name: str, n: int) -> bytes:
    m = re.search(r"\b" + re.escape(name) + r"\[" + str(n) +
                  r"\]\s*=\s*\{([^}]+)\}", header)
    require(m is not None, name)
    out = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]+)", m[1]))
    require(len(out) == n, name + " byte count")
    return out


def u64(words: list[int], at: int, value: int) -> None:
    require(0 <= value < 1 << 64, "u64")
    words[at] = value & 0xffffffff
    words[at + 1] = value >> 32


def command(tags: list[bytes], *, family: int, load: bool, rows: int,
            task: int, w_epoch: int, ps_epoch: int, trace: bool,
            trace_col: int = 0, activation_base: int = 0,
            out0_base: int = 0, out1_base: int = 0) -> bytes:
    require(family in (1, 12) and rows in (1, 4), "supported case")
    qkv = family == 1
    K, N, stage, layer = (1024, 3072, 2, 0) if qkv else (256, 2, 6, 255)
    require(not load or rows == 1, "LOAD row shape")
    w = [0] * 128
    w[:4] = [MAGIC, 1, 0 if load else 1, 1 if trace else 0]
    u64(w, 4, REQUEST_ID)
    u64(w, 6, GENERATION)
    w[8:21] = [task, 0x80 if load else (0x30 if qkv else 0x37),
               stage, layer, 1, 128, 0, 0, rows, K, N, family, layer]
    if load:
        w[25:29] = [0x23, 0, w_epoch, 0]
    elif qkv:
        w[21:25] = [1, 1, 1, 0]  # LN_EMB HIDDEN bank1, first claim
        w[25:29] = [5, 0, ps_epoch, 0]  # local QKV row, both shards
    else:
        w[21:25] = [10, 0, 1, 2]  # ACT_HIDDEN source
        w[25:29] = [10, 0, ps_epoch, 4]  # ACT_LOGITS destination
    w[29:32] = [w_epoch, ps_epoch, 0 if load else task - 1]
    for i, value in enumerate(tags):
        w[32 + 4*i:36 + 4*i] = struct.unpack("<4I", value)
    if not load:
        u64(w, 48, activation_base)
        u64(w, 50, out0_base)
        u64(w, 52, out1_base if qkv else 0)
        u64(w, 54, rows * K * 4)
        u64(w, 56, 12 * 1024 * 1024 if qkv else 8)
        u64(w, 58, 12 * 1024 * 1024 if qkv else 0)
        w[60:62] = [0, trace_col if trace else 0]
    w[62] = OBSERVED_WORDS
    return struct.pack("<128I", *w)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    ap.add_argument("model_package", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    root, package, out = args.root.resolve(), args.model_package.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    header = package / "laya_model_layout_generated.h"
    text = header.read_text()
    require(tag(text, "kFullSourceSha256", 32).hex() == SOURCE_SHA,
            "model package source GGUF")
    tags = [tag(text, name, 16) for name in
            ("kFullModelTag", "kFullNumericTag", "kFullLayoutTag", "kFullBuildTag")]
    fixtures = root / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512"
    records = {}
    cases = (("act_load", 12, True, 1, 1, 1, 0, False, 0),
             ("act_run_trace", 12, False, 1, 3, 1, 1, True, 0),
             ("qkv_load", 1, True, 1, 1, 1, 0, False, 0),
             ("qkv_run1_trace", 1, False, 1, 3, 1, 1, True, 0),
             ("qkv_run4_trace", 1, False, 4, 5, 1, 2, True, 0),
             ("qkv_run4_off", 1, False, 4, 7, 1, 3, False, 0))
    for name, family, load, rows, task, w_epoch, ps_epoch, trace, trace_col in cases:
        payload = command(tags, family=family, load=load, rows=rows,
                          task=task, w_epoch=w_epoch, ps_epoch=ps_epoch,
                          trace=trace, trace_col=trace_col)
        path = out / (name + ".bin")
        path.write_bytes(payload)
        records[name] = sha(path)
    report = {"schema": "tm1tn8_q8t1_descriptors_v1", "source": sha(Path(__file__)),
              "package_header": sha(header), "controller_source": sha(
                  root / "hls/control/full_forward_controller.cpp"),
              "contract": sha(root / "results/cpu_embedding_q8_validation_20261010/contract/design.md"),
              "request_id": REQUEST_ID, "generation": GENERATION,
              "tags_hex": [x.hex() for x in tags], "files": records,
              "module": str(fixtures)}
    (out / "manifest.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print("TM1TN8_Q8T1_DESCRIPTORS_PASS count=6")


if __name__ == "__main__":
    main()
