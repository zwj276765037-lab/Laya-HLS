#!/usr/bin/env python3
"""Freeze D2-I operator inputs and independent R0 gold from captured GGUF data.

Captured native tensors are inputs or diagnostics only. The QKV expectation is
computed from the frozen GGUF Q8 weight and F32 bias with full_reference.py.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import struct
import sys

import numpy as np


ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "tests"))
from full_fixture_test import Evidence  # noqa: E402
import full_reference as reference  # noqa: E402


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write(output: Path, name: str, array: bytes | np.ndarray) -> dict:
    payload = array if isinstance(array, bytes) else np.asarray(array, dtype="<f4").tobytes()
    path = output / name
    path.write_bytes(payload)
    return {"path": str(path), "bytes": len(payload), "sha256": digest(payload)}


def rows(evidence: Evidence, node_id: str, width: int = 1024) -> np.ndarray:
    tensor = evidence.node(node_id)
    assert tensor.shape == (width, 128, 2, 1), (node_id, tensor.shape)
    derived = np.stack([tensor[:, row, 0, 0] for row in range(64)]).astype("<f4")
    assert derived.shape == (64, width) and np.isfinite(derived).all()
    return derived


def request_value(request: bytes, index: int, dtype: str) -> np.ndarray:
    offset = struct.unpack_from("<I", request, 128 + index * 32 + 4)[0]
    length = struct.unpack_from("<I", request, 128 + index * 32 + 8)[0]
    return np.frombuffer(request[offset:offset + length], dtype=dtype)


def main() -> int:
    if len(sys.argv) != 3:
        raise SystemExit("usage: generate_fixture.py PACKAGE OUTPUT_DIR")
    package = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    source_request = (ROOT / "results/attention_rtl_repair_20261008/"
                      "d2_attention_slice/tb/fixture_b1_s64_decision/request.bin")
    request = source_request.read_bytes()
    assert len(request) == 832 and struct.unpack_from("<HH", request, 20) == (1, 64)
    aux = (package / "aux.bin").read_bytes()
    assert len(aux) == 1671872 and request[40:104] == aux[32:96]
    qtype = int(request_value(request, 4, "<i4")[0])
    marker_mask = request_value(request, 3, "u1")
    assert 0 <= qtype < 3 and marker_mask.shape == (16,)

    evidence = Evidence(ROOT, output)
    try:
        norm = rows(evidence, "ir_1414")
        residual_src0 = rows(evidence, "ir_1428")
        residual_src1 = rows(evidence, "ir_1413")
        type_src0 = rows(evidence, "ir_1410")
        norm_changed = norm.copy()
        norm_changed[0, :32] = reference.add(norm_changed[0, :32],
                                               np.float32(0.5))
        residual_src1_changed = residual_src1.copy()
        residual_src1_changed[0, 0] = reference.add(
            residual_src1_changed[0, 0], np.float32(1.0))

        weight = evidence.weight("head_qkv.0.weight")
        bias_bytes = evidence.weight("head_qkv.0.bias")
        assert len(weight) == 3072 * 32 * 34 and len(bias_bytes) == 3072 * 4
        bias = np.frombuffer(bias_bytes, dtype="<f4")
        qkv_gold = reference.q8_linear_many(norm, weight, 3072, bias)
        qkv_changed_gold = reference.q8_linear_many(norm_changed, weight,
                                                     3072, bias)
        assert qkv_gold.shape == (64, 3072)
        assert np.any(qkv_gold.view("<u4") != qkv_changed_gold.view("<u4"))

        type_q8 = evidence.weight("type_emb.weight")
        assert len(type_q8) == 3 * 1088
        type_rows = np.stack([reference.embedding_row(type_q8[t * 1088:
                                                          (t + 1) * 1088])
                              for t in range(3)]).astype("<f4")
        type_gold = reference.add(type_src0, type_rows[qtype][None, :])
        residual_gold = reference.add(residual_src0, residual_src1)
        residual_changed_gold = reference.add(residual_src0,
                                              residual_src1_changed)
        assert np.any(residual_gold.view("<u4") !=
                      residual_changed_gold.view("<u4"))

        candidate = evidence.alias("candidate_raw_logits")[:, 0, 0, 0].astype("<f4")
        candidate_gold = reference.candidate_mask(candidate, marker_mask)
        files = {
            "request": write(output, "request.bin", request),
            "norm": write(output, "norm.f32.bin", norm),
            "norm_changed": write(output, "norm_changed.f32.bin", norm_changed),
            "qkv_gold": write(output, "qkv_gold.f32.bin", qkv_gold),
            "qkv_changed_gold": write(output, "qkv_changed_gold.f32.bin",
                                      qkv_changed_gold),
            "residual_src0": write(output, "residual_src0.f32.bin", residual_src0),
            "residual_src1": write(output, "residual_src1.f32.bin", residual_src1),
            "residual_src1_changed": write(output,
                                            "residual_src1_changed.f32.bin",
                                            residual_src1_changed),
            "residual_gold": write(output, "residual_gold.f32.bin", residual_gold),
            "residual_changed_gold": write(output,
                                            "residual_changed_gold.f32.bin",
                                            residual_changed_gold),
            "type_src0": write(output, "type_src0.f32.bin", type_src0),
            "type_rows": write(output, "type_rows.f32.bin", type_rows),
            "type_gold": write(output, "type_gold.f32.bin", type_gold),
            "candidate": write(output, "candidate.f32.bin", candidate),
            "candidate_gold": write(output, "candidate_gold.f32.bin",
                                    candidate_gold),
        }
        report = {
            "status": "GENERATED_NO_DUT_COMPARISON",
            "scope": "D2-I stage4 Decision0 B1/S64 and stage3 type-add vector",
            "controller_sha256": digest((ROOT / "hls/control/"
                                         "full_forward_controller.cpp").read_bytes()),
            "reference_sha256": digest((ROOT / "tests/full_reference.py").read_bytes()),
            "package": str(package),
            "package_manifest_sha256": digest((package / "manifest.json").read_bytes()),
            "source_request": {"path": str(source_request),
                               "sha256": digest(request)},
            "source_nodes": {"qkv_input": "ir_1414", "residual_src0": "ir_1428",
                             "residual_src1": "ir_1413", "type_src0": "ir_1410"},
            "capture_shape": [1024, 128, 2, 1],
            "derived_shape": [1, 64, 1024],
            "source_stride_bytes": evidence.checked[str(
                ROOT / "reference/runs/typed_q8_ref_20261005/abi_replay/"
                "native/forward_0/ir_1414.bin")]["ggml_nb_bytes"],
            "qtype": qtype,
            "weight_names": ["head_qkv.0.weight", "head_qkv.0.bias",
                             "type_emb.weight"],
            "files": files,
            "checked_reference_files": evidence.checked,
        }
        (output / "fixture_report.json").write_text(json.dumps(report, indent=2) + "\n")
        print("D2_I_FIXTURE_GENERATED", files["qkv_gold"]["sha256"])
    finally:
        evidence.model.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
