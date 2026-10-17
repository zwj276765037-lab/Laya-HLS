#!/usr/bin/env python3
"""Future-gated cold qtype1 input and independent original-R0 oracle.

Source preparation only: this script must not be executed under the current
gate. It never feeds decoded type rows to the DUT.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

import numpy as np


ROOT = Path(__file__).resolve().parents[4]
MODULE = Path(__file__).resolve().parents[1]
GATE = ROOT / "results/attention_rtl_repair_20261008/reviewer_d2_type_producer_binary_source_preparation_release.json"
EXPECTED_GATE_SHA = "d50e1f2c346bf8d1ed0c86ef661582a75f47b6301bec5401877a749ae3d0509c"
sys.path.insert(0, str(ROOT / "tests"))
import full_reference as reference  # noqa: E402


def digest(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def checked(path: Path, entry: dict) -> bytes:
    if path.resolve() != Path(entry["path"]).resolve():
        raise ValueError(f"bound path differs: {path}")
    raw = path.read_bytes()
    if (len(raw), digest(raw)) != (entry["bytes"], entry["sha256"]):
        raise ValueError(f"bound bytes differ: {path}")
    return raw


def write_new(path: Path, raw: bytes) -> dict:
    with path.open("xb") as out:
        out.write(raw)
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": digest(raw)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("fresh_output", type=Path)
    args = parser.parse_args()
    if args.fresh_output.exists():
        raise FileExistsError(args.fresh_output)
    gate_raw = GATE.read_bytes()
    if digest(gate_raw) != EXPECTED_GATE_SHA:
        raise ValueError("signed source-only release changed")
    gate = json.loads(gate_raw)
    if gate["root"] != str(MODULE):
        raise ValueError("module root binding changed")
    fixture_path = Path(gate["fixture_report"]["path"])
    fixture = json.loads(checked(fixture_path, gate["fixture_report"]))
    frozen = fixture_path.parent
    request = bytearray(checked(frozen / "request.bin", fixture["files"]["request"]))
    hidden = checked(frozen / "type_src0.f32.bin", gate["hidden_ingress"])
    baseline = checked(frozen / "type_gold.f32.bin", gate["baseline_gold"])
    if len(request) != 832 or struct.unpack_from("<HH", request, 20) != (1, 64):
        raise ValueError("frozen B1/S64 request shape")
    if (struct.unpack_from("<I", request, 128 + 4 * 32 + 4)[0] != 768 or
            struct.unpack_from("<i", request, 768)[0] != 2):
        raise ValueError("frozen qtype2 directory and payload")
    capture = next((Path(path) for path in fixture["checked_reference_files"]
                    if path.endswith("/native/forward_0/ir_1410.bin")), None)
    if capture is None:
        raise ValueError("native HIDDEN provenance missing")
    capture_entry = fixture["checked_reference_files"][str(capture)]
    checked(capture, {"path": str(capture), "bytes": capture_entry["bytes"],
                      "sha256": capture_entry["sha256"]})

    manifest_raw = checked(Path(gate["model_manifest"]["path"]),
                           gate["model_manifest"])
    manifest = json.loads(manifest_raw)
    tensor = next(item for item in manifest["tensors"]
                  if item["name"] == "type_emb.weight")
    if tensor != gate["type_weight_tensor"]:
        raise ValueError("bound type embedding descriptor changed")
    embedding_path = Path(gate["embedding_bo"]["path"])
    embedding = checked(embedding_path, gate["embedding_bo"])
    weight = embedding[tensor["base"]:tensor["base"] + tensor["span"]]
    if len(weight) != 3264 or digest(weight) != tensor["source_sha256"]:
        raise ValueError("packaged Q8 type weights changed")
    gguf_entry = next((path for path in fixture["checked_reference_files"]
                       if path.endswith(".gguf::type_emb.weight")), None)
    if gguf_entry is None:
        raise ValueError("original GGUF tensor provenance missing")
    source_path = Path(gguf_entry.split("::", 1)[0])
    with source_path.open("rb") as source:
        source.seek(tensor["source_offset"])
        original = source.read(tensor["source_bytes"])
    if original != weight or digest(original) != gate["type_weight_tensor"]["source_sha256"]:
        raise ValueError("packaged and GGUF type bytes differ")
    if digest((ROOT / "tests/full_reference.py").read_bytes()) != fixture["reference_sha256"]:
        raise ValueError("independent original-R0 reference changed")

    type_row = reference.embedding_row(weight[1088:2176])
    hidden_rows = np.frombuffer(hidden, dtype="<f4").reshape((64, 1024))
    gold = reference.add(hidden_rows, type_row[None, :])
    row_raw = np.asarray(type_row, dtype="<f4").tobytes()
    gold_raw = np.asarray(gold, dtype="<f4").tobytes()
    if len(row_raw) != 4096 or len(gold_raw) != 262144 or gold_raw == baseline:
        raise ValueError("qtype1 independent oracle shape or dependence")
    struct.pack_into("<Q", request, 24, 311)
    struct.pack_into("<i", request, 768, 1)
    args.fresh_output.mkdir(parents=True)
    files = {
        "request": write_new(args.fresh_output / "qtype1_request.bin", bytes(request)),
        "row_reference": write_new(args.fresh_output / "qtype1_row_reference.f32.bin", row_raw),
        "gold": write_new(args.fresh_output / "qtype1_gold.f32.bin", gold_raw),
    }
    report = {
        "schema": "d2_type_producer_binary_qtype1_future_materialization_v1",
        "status": "INDEPENDENT_ORACLE_NOT_DUT_RESULT",
        "signed_source_gate_sha256": digest(gate_raw),
        "source_fixture_report_sha256": gate["fixture_report"]["sha256"],
        "hidden_ingress_sha256": gate["hidden_ingress"]["sha256"],
        "original_reference_sha256": fixture["reference_sha256"],
        "type_weight_sha256": digest(weight),
        "qtype": 1, "request_id": 311, "generation": struct.unpack_from("<Q", request, 32)[0],
        "files": files,
    }
    (args.fresh_output / "qtype1_fixture_report.json").write_text(
        json.dumps(report, indent=2, sort_keys=True) + "\n")
    print("D2_TYPE_QTYPE1_ORACLE_PREPARED request_id=311 words=65536")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
