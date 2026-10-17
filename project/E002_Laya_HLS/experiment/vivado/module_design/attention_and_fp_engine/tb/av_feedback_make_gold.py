#!/usr/bin/env python3
"""Build independent enc0/head0 feature-0 AV projection gold from v4 BO inputs."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

import numpy as np

ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")
sys.path.insert(0, str(ROOT / "tests"))
import full_reference as reference  # noqa: E402


def identity(path: Path) -> dict[str, object]:
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def read_plane(path: Path) -> np.ndarray:
    data = path.read_bytes()
    if len(data) != 128 * 64 * 4:
        raise ValueError(f"wrong QKV plane shape: {path}")
    plane = np.frombuffer(data, dtype="<f4").reshape(128, 64)
    if not np.isfinite(plane).all():
        raise ValueError(f"nonfinite producer plane: {path}")
    return plane


def read_mask(path: Path) -> tuple[np.ndarray, dict[str, object]]:
    data = path.read_bytes()
    if (data[:4] != b"LYRQ" or
        struct.unpack_from("<HHQQ", data, 20) != (1, 128, 3, 1) or
        struct.unpack_from("<I", data, 16)[0] != len(data)):
        raise ValueError("request-3 B1/S128 identity or frame mismatch")
    entry = 128 + 32
    if struct.unpack_from("<H", data, entry)[0] != 2:
        raise ValueError("attention mask directory ID")
    offset, length = struct.unpack_from("<II", data, entry + 4)
    if length != 128 or offset + length > len(data):
        raise ValueError("attention mask directory span")
    mask = np.frombuffer(data[offset:offset + length], dtype=np.uint8)
    if np.any(mask > 1) or not np.any(mask):
        raise ValueError("attention mask values")
    tags = {name: data[start:start + 16].hex() for name, start in
            (("model", 40), ("numeric", 56), ("layout", 72), ("build", 88))}
    return mask, {"request": identity(path), "mask_offset": offset,
                  "mask_ones": int(mask.sum()), "tags": tags}


def write_mem(path: Path, values: np.ndarray) -> dict[str, object]:
    bits = np.asarray(values, dtype="<f4").reshape(-1).view("<u4")
    path.write_text("".join(f"{int(value):08x}\n" for value in bits))
    return identity(path)


def write_numeric_identity(path: Path, request_info: dict[str, object]) -> dict[str, object]:
    value = 3 | (1 << 64) | (1 << 128) | (128 << 144)
    tags = request_info["tags"]
    for index, name in enumerate(("model", "numeric", "layout", "build")):
        value |= int.from_bytes(bytes.fromhex(tags[name]), "little") << (160 + 128 * index)
    path.write_text(f"{value:0168x}\n")
    return identity(path)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path)
    parser.add_argument("capture_manifest", type=Path)
    parser.add_argument("request", type=Path)
    parser.add_argument("prior_v", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    capture = args.capture.resolve()
    manifest = json.loads(args.capture_manifest.read_text())
    if manifest["schema"] != "av_feedback_qkv_capture_sources_v1":
        raise ValueError("QKV capture source identity schema")
    source_manifest = identity(args.capture_manifest)
    planes: dict[str, np.ndarray] = {}
    plane_ids: dict[str, dict[str, object]] = {}
    for name in "qkv":
        path = capture / f"t2_enc0_{name}_head0_source.f32.bin"
        planes[name] = read_plane(path)
        plane_ids[name] = identity(path)
    if plane_ids["v"]["sha256"] != identity(args.prior_v)["sha256"]:
        raise ValueError("V no longer matches the prior proven v4 producer capture")
    mask, request_info = read_mask(args.request)
    prob = np.empty((32, 128), dtype="<f4")
    product = np.empty_like(prob)
    partial = np.empty_like(prob)
    for projected_row, row in enumerate(range(0, 128, 4)):
        score = reference.qk_row(planes["q"][row], planes["k"],
                                 mask, 128, row, False)
        p = reference.softmax_row(score, 128)
        acc = np.float32(0)
        for key in range(128):
            value = reference.mul(p[key], planes["v"][key, 0])
            acc = reference.add(acc, value)
            prob[projected_row, key] = p[key]
            product[projected_row, key] = value
            partial[projected_row, key] = acc
        final = reference.av_row(p, planes["v"], 128)[0]
        if reference.bits(final) != reference.bits(acc):
            raise AssertionError(f"independent AV final mismatch row={row}")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    files = {name: write_mem(output / f"{name}.mem", values) for name, values in
             (("prob", prob), ("product", product), ("partial", partial),
              ("v_feature0", planes["v"][:, 0]))}
    files["numeric_identity"] = write_numeric_identity(
        output / "numeric_identity.mem", request_info)
    result = {
        "schema": "av_feedback_real_gold_v1",
        "scope": "request3/generation1/B1/S128 encoder0/head0 projected rows 0,4,...,124 feature0",
        "projected_rows": 32, "keys": 128, "products": 4096,
        "mask_mode": "encoder0 full finite mask",
        "capture_source_manifest": source_manifest,
        "producer_planes": plane_ids, "prior_v": identity(args.prior_v),
        "request": request_info,
        "reference": identity(ROOT / "tests/full_reference.py"),
        "generator": identity(Path(__file__)), "files": files,
        "gold_role": "external QK/softmax oracle prob and independent ascending AV product/partial",
    }
    (output / "manifest.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print("AV_FEEDBACK_REAL_GOLD_READY rows=32 keys=128 contributions=4096")


if __name__ == "__main__":
    main()
