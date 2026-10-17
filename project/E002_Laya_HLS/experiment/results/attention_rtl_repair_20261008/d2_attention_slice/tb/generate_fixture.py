#!/usr/bin/env python3
"""Freeze the B1/S64 Decision attention slice from native model evidence."""

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
from full_forward_dut_run import source_payloads  # noqa: E402
import full_reference as reference  # noqa: E402


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def align64(value: int) -> int:
    return (value + 63) & ~63


def write(output: Path, name: str, payload: bytes) -> dict:
    path = output / name
    path.write_bytes(payload)
    return {"path": str(path), "bytes": len(payload), "sha256": digest(payload)}


def request_b1_s64(source: bytes, tags: bytes) -> bytes:
    parts = source_payloads(source)
    token = parts[0][:64 * 4]
    mask = parts[1][:64]
    markers = parts[2][:16 * 4]
    marker_mask = parts[3][:16]
    qtype = parts[4][:4]
    for index, active in enumerate(marker_mask):
        marker = struct.unpack_from("<i", markers, 4 * index)[0]
        if active:
            assert 0 <= marker < 64 and mask[marker] == 1
        else:
            assert marker == 0
    assert sum(mask) and any(marker_mask)
    payloads = (token, mask, markers, marker_mask, qtype)
    output = bytearray(source[:320])
    output[40:104] = tags
    struct.pack_into("<HH", output, 20, 1, 64)
    struct.pack_into("<Q", output, 24, 301)
    offset = 320
    for index, payload in enumerate(payloads):
        dtype = 2 if index in (1, 3) else 1
        rank = 1 if index == 4 else 2
        dim1 = 64 if index < 2 else 1 if index == 4 else 16
        stride0 = (256, 64, 64, 16, 4)[index]
        stride1 = (4, 1, 4, 1, 0)[index]
        elements = 1 if index == 4 else 64 if index < 2 else 16
        struct.pack_into("<HBBIIHHIIII", output, 128 + index * 32,
                         index + 1, dtype, rank, offset, len(payload),
                         1, dim1, stride0, stride1, elements, 0)
        output.extend(b"\x00" * (offset - len(output)))
        output.extend(payload)
        output.extend(b"\x00" * (align64(len(output)) - len(output)))
        offset = len(output)
    struct.pack_into("<I", output, 16, len(output))
    assert len(output) == 832
    return bytes(output)


def main() -> int:
    if len(sys.argv) != 3:
        raise SystemExit("usage: generate_fixture.py PACKAGE OUTPUT_DIR")
    package = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((package / "manifest.json").read_text())
    aux = (package / "aux.bin").read_bytes()
    tags = aux[32:96]
    assert tags.hex()[96:128] == manifest["tags"]["build"]
    source_path = ROOT / "reference/runs/typed_q8_ref_20261005/abi_replay/request_v1.bin"
    source = source_path.read_bytes()
    request = request_b1_s64(source, tags)
    mask = np.frombuffer(source_payloads(source)[1][:64], dtype="u1").copy()
    evidence = Evidence(ROOT, output)
    try:
        native = evidence.node("ir_1415")
        assert native.shape == (3072, 128, 2, 1)
        qkv = np.transpose(native[:, :64, 0:1, 0], (2, 1, 0)).astype("<f4", copy=True)
        assert qkv.shape == (1, 64, 3072) and np.isfinite(qkv).all()
        key = qkv[0, :, 1024:1088]
        value = qkv[0, :, 2048:2112]
        query = qkv[0, 0, :64]
        score = np.asarray(reference.qk_row(query, key, mask, 64, 0, False),
                           dtype="<f4")
        probability = np.asarray(reference.softmax_row(score, 64), dtype="<f4")
        av = np.asarray(reference.av_row(probability, value, 64), dtype="<f4")
        assert score.shape == probability.shape == av.shape == (64,)
        files = {
            "request": write(output, "request.bin", request),
            "qkv": write(output, "qkv_final.f32.bin", qkv.tobytes()),
            "mask": write(output, "attention_mask.u8.bin", mask.tobytes()),
            "score": write(output, "score.f32.bin", score.tobytes()),
            "probability": write(output, "probability.f32.bin", probability.tobytes()),
            "av": write(output, "av.f32.bin", av.tobytes()),
        }
        report = {
            "status": "GENERATED_NO_DUT_COMPARISON",
            "scope": "native decision0 QKV intermediate; first batch and first 64 rows; stage4/head0/query0 operator slice",
            "upstream_q8_projection_rtl_proven": False,
            "complete_model_s64_inference_proven": False,
            "source_request": {"path": str(source_path), "sha256": digest(source)},
            "package": str(package),
            "package_manifest_sha256": digest((package / "manifest.json").read_bytes()),
            "build_tag": manifest["tags"]["build"],
            "qkv_native_node": "ir_1415",
            "qkv_shape": list(qkv.shape),
            "files": files,
            "checked_reference_files": evidence.checked,
        }
        (output / "fixture_report.json").write_text(json.dumps(report, indent=2) + "\n")
        print("D2_ATTENTION_FIXTURE_GENERATED", files["qkv"]["sha256"])
    finally:
        evidence.model.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
