#!/usr/bin/env python3
"""Freeze real one-row quant16 inputs and an independent NumPy oracle."""

import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

import numpy as np


ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "tests"))
import numeric_reference  # noqa: E402


def identity(path):
    path = Path(path)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def checked_product(record):
    path = Path(record["path"])
    actual = identity(path)
    if actual["bytes"] != record["bytes"] or actual["sha256"] != record["sha256"]:
        raise RuntimeError(f"source product changed: {path}")
    return path, actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    source_manifest = (ROOT / "results/compute_throughput_optimization_20261010"
                       "/attempts/t2_widown_av_fixtures_01/work/fixtures/manifest.json")
    original = json.loads(source_manifest.read_text())
    selected = {item["name"]: item for item in original["cases"]}
    output = args.out.resolve()
    output.mkdir(parents=True, exist_ok=False)
    frozen = {
        "schema": "laya-quant16-real-one-row-fixture-v1",
        "scope": "one real LN_FFN-to-Wi K1024 row and one GEGLU-to-Down K2624 row",
        "oracle": identity(Path(numeric_reference.__file__)),
        "freeze_script": identity(Path(__file__)),
        "source_manifest": identity(source_manifest),
        "cases": {},
    }
    numeric_reference.half_boundary_selftest()
    for name, k in (("wi_rows4", 1024), ("down_rows4", 2624)):
        case = selected[name]
        if case["K"] != k or case["rows"] != 4 or case["row0"] != 0:
            raise RuntimeError(f"source case shape changed: {name}")
        paths = {}
        upstream = {}
        for label in ("source_f32", "a8_q", "a8_scale"):
            paths[label], upstream[label] = checked_product(case["products"][label])
        raw = paths["source_f32"].read_bytes()[:k * 4]
        source = np.frombuffer(raw, dtype="<f4").reshape(1, k)
        encoded, diagnostics = numeric_reference.quantize(source)
        gold_q = b"".join(encoded[g * 34 + 2:g * 34 + 34] for g in range(k // 32))
        gold_scale = b"".join(encoded[g * 34:g * 34 + 2] for g in range(k // 32))
        if gold_q != paths["a8_q"].read_bytes()[:k]:
            raise RuntimeError(f"independent q differs from T2 fixture: {name}")
        if gold_scale != paths["a8_scale"].read_bytes()[:k // 16]:
            raise RuntimeError(f"independent scale differs from T2 fixture: {name}")
        scalar = b"".join(struct.pack("<III", *(numeric_reference.bits(np.float32(v))
                                                  for v in triple))
                          for triple in diagnostics)
        short = name.split("_")[0]
        products = {}
        for label, content in (("source_f32", raw), ("q", gold_q),
                               ("scale", gold_scale), ("scalar_u32x3", scalar)):
            path = output / f"{short}_{label}.bin"
            path.write_bytes(content)
            products[label] = identity(path)
        frozen["cases"][short] = {
            "K": k, "rows": 1, "groups": k // 32,
            "source_producer": "LN_FFN" if short == "wi" else "GEGLU",
            "upstream_products": upstream,
            "actual_producer_full_source": case["actual_producer_full_source"],
            "products": products,
        }
    (output / "manifest.json").write_text(json.dumps(frozen, indent=2, sort_keys=True) + "\n")
    print(f"QUANT16_FIXTURE_PASS cases=2 oracle={frozen['oracle']['sha256']}")


if __name__ == "__main__":
    main()
