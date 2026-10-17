#!/usr/bin/env python3
"""Build an independent binary32 tree-LayerNorm fixture from a real checkpoint."""

import argparse
import hashlib
import json
from pathlib import Path
import struct

import numpy as np


def rec(path: Path) -> dict:
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def add(a, b):
    return np.add(a, b, dtype=np.float32)


def mul(a, b):
    return np.multiply(a, b, dtype=np.float32)


def tree_sum(values: np.ndarray) -> np.float32:
    tree = values.astype(np.float32, copy=True)
    width = 1024
    while width > 1:
        tree[:width // 2] = add(tree[:width:2], tree[1:width:2])
        width //= 2
    return np.float32(tree[0])


def layernorm(row: np.ndarray) -> np.ndarray:
    mean = np.float32(tree_sum(row) / np.float32(1024.0))
    delta = np.subtract(row, mean, dtype=np.float32)
    variance = np.float32(tree_sum(mul(delta, delta)) / np.float32(1024.0))
    eps = np.frombuffer(struct.pack("<I", 0x3727C5AC), dtype="<f4")[0]
    root = np.float32(np.sqrt(add(variance, eps)))
    inverse = np.float32(np.float32(1.0) / root)
    return mul(delta, inverse)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    source_path = args.input.resolve()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    whole = np.fromfile(source_path, dtype="<f4")
    if whole.size != 128 * 1024 or not np.isfinite(whole).all():
        raise RuntimeError("expected finite B1/S128 checkpoint")
    source = whole.reshape(128, 1024)[:16].copy()
    gold = np.stack([layernorm(row) for row in source]).astype("<f4")
    source_file = out / "source_rows16.f32.bin"
    gold_file = out / "gold_rows16.f32.bin"
    source.tofile(source_file)
    gold.tofile(gold_file)
    manifest = {
        "schema": "laya-layernorm-producer-fixture-v1",
        "scope": "real encoder_00_out rows0..15 and independent Python float32 adjacent-tree gamma0 LayerNorm",
        "input_checkpoint": rec(source_path),
        "source": rec(source_file),
        "gold": rec(gold_file),
        "shape": [16, 1024],
        "eps_bits": "0x3727c5ac",
        "algorithm": "float32 adjacent binary tree mean and centered variance, sqrt, reciprocal, normalize",
    }
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print("FULL_CURRENT_LAYERNORM_PRODUCER_FIXTURE_PASS rows=16 cols=1024")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
