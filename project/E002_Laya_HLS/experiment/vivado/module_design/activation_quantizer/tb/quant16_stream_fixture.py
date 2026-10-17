#!/usr/bin/env python3
"""Convert the frozen independent one-row fixture to XSim memory files."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct


ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / "vivado/module_design/activation_quantizer/rtl/quant16_fixture_01"


def identity(path: Path) -> dict:
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    frozen = json.loads((SOURCE / "manifest.json").read_text())
    inputs: dict[str, dict] = {}
    products: dict[str, dict] = {}
    for case, groups in (("wi", 32), ("down", 82)):
        for field, unit, fmt in (("source_f32", 4, "I"), ("q", 1, "B"),
                                 ("scale", 2, "H")):
            path = SOURCE / f"{case}_{field}.bin"
            data = path.read_bytes()
            expected = groups * (32 if field != "scale" else 1) * unit
            if len(data) != expected:
                raise ValueError(f"{path}: {len(data)} != {expected}")
            inputs[path.name] = identity(path)
            if inputs[path.name]["sha256"] != frozen["cases"][case]["products"][field]["sha256"]:
                raise ValueError(f"{path}: frozen input identity drift")
            width = unit * 2
            values = (item[0] for item in struct.iter_unpack("<" + fmt, data))
            target = out / f"{case}_{field}.mem"
            target.write_text("".join(f"{value:0{width}x}\n" for value in values))
            products[target.name] = identity(target)
        path = SOURCE / f"{case}_scalar_u32x3.bin"
        data = path.read_bytes()
        if len(data) != groups * 12:
            raise ValueError(f"{path}: scalar count")
        inputs[path.name] = identity(path)
        if inputs[path.name]["sha256"] != frozen["cases"][case]["products"]["scalar_u32x3"]["sha256"]:
            raise ValueError(f"{path}: frozen scalar identity drift")
        triples = list(struct.iter_unpack("<III", data))
        for name, index in (("amax", 0), ("d_full", 1), ("reciprocal", 2)):
            target = out / f"{case}_{name}.mem"
            target.write_text("".join(f"{row[index]:08x}\n" for row in triples))
            products[target.name] = identity(target)
    (out / "manifest.json").write_text(json.dumps({
        "schema": "laya-quant16-stream-xsim-fixture-v1",
        "frozen_manifest": identity(SOURCE / "manifest.json"),
        "generator": identity(Path(__file__)),
        "inputs": inputs, "products": products,
        "groups": {"wi": 32, "down": 82},
    }, indent=2, sort_keys=True) + "\n")
    print("QUANT16_STREAM_FIXTURE_PASS wi=32 down=82")


if __name__ == "__main__":
    main()
