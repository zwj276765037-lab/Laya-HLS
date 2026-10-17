#!/usr/bin/env python3
"""Expose frozen independent quant16 scalar bits as XSim memory files."""

import hashlib
import json
from pathlib import Path
import struct


ROOT = Path(__file__).resolve().parents[4]
MODULE = ROOT / "vivado/module_design/activation_quantizer"
SOURCE = MODULE / "rtl/quant16_fixture_01"
OUT = MODULE / "rtl/quant16_divider_fixture_01"


def identity(path):
    path = Path(path)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    OUT.mkdir(parents=True, exist_ok=False)
    products = {}
    inputs = {}
    for case, groups in (("wi", 32), ("down", 82)):
        source = SOURCE / f"{case}_scalar_u32x3.bin"
        data = source.read_bytes()
        if len(data) != groups * 12:
            raise RuntimeError(f"{case} independent scalar size")
        inputs[case] = identity(source)
        triples = struct.iter_unpack("<III", data)
        fields = list(zip(*triples))
        for name, values in zip(("amax", "d_full", "reciprocal"), fields):
            path = OUT / f"{case}_{name}.mem"
            path.write_text("".join(f"{value:08x}\n" for value in values))
            products[path.name] = identity(path)
    (OUT / "manifest.json").write_text(json.dumps({
        "schema": "laya-quant16-independent-divider-xsim-fixture-v1",
        "source_manifest": identity(SOURCE / "manifest.json"),
        "generator": identity(Path(__file__)),
        "inputs": inputs,
        "products": products,
        "groups": {"wi": 32, "down": 82},
    }, indent=2, sort_keys=True) + "\n")
    print("QUANT16_DIVIDER_FIXTURE_PASS wi=32 down=82")


if __name__ == "__main__":
    main()
