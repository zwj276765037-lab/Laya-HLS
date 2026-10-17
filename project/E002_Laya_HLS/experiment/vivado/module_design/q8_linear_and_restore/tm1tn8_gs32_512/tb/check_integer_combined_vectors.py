#!/usr/bin/env python3
"""Reject truncated or drifted ACT8 + QKV128 replay before XSim starts."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: check_integer_combined_vectors.py VECTOR_DIRECTORY")
    directory = Path(sys.argv[1]).resolve(strict=True)
    manifest = json.loads((directory / "manifest.json").read_text())
    if (manifest.get("schema") != "tm1tn8_integer_real_replay_v1" or
            (manifest.get("issues"), manifest.get("act_issues"),
             manifest.get("qkv_issues")) != (136, 8, 128)):
        raise ValueError("replay manifest must identify ACT8 + QKV128")
    outputs = manifest.get("outputs", {})
    widths = {"a": 64, "w": 512, "mask": 2, "dot": 64}
    if set(outputs) != set(widths):
        raise ValueError("replay output set drift")
    masks: list[int] = []
    for name, width in widths.items():
        path = directory / f"{name}.hex"
        raw = path.read_bytes()
        record = outputs[name]
        if (Path(record["path"]).resolve() != path or
                record["bytes"] != len(raw) or
                record["sha256"] != hashlib.sha256(raw).hexdigest()):
            raise ValueError(f"{name} identity does not match source manifest")
        rows = raw.decode("ascii").splitlines()
        if len(rows) != 136:
            raise ValueError(f"{name} has {len(rows)} records, expected 136")
        for index, row in enumerate(rows):
            if len(row) != width or any(ch not in "0123456789abcdefABCDEF"
                                        for ch in row):
                raise ValueError(f"{name} malformed hex issue {index}")
        if name == "mask":
            masks = [int(row, 16) for row in rows]
    if masks != [3] * 8 + [255] * 128:
        raise ValueError("ACT/QKV lane masks do not match replay scope")
    print("TM1TN8_COMBINED_INPUT_PASS act=8 qkv=128 issues=136 sha_verified=4")


if __name__ == "__main__":
    main()
