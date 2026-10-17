#!/usr/bin/env python3
"""Independent physical images and S64 gold for the external-QKV boundary."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import struct
import sys

import numpy as np


ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / "tests"))
import full_reference as reference  # noqa: E402

OLD = ROOT / "results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision"
HERE = Path(__file__).resolve().parent
OUT = HERE / "fixture_preloaded"
PREFIX = 10_240_064
HOST = 12 << 20
SOURCE = 786_432


def digest(data: bytes | bytearray) -> str:
    return hashlib.sha256(data).hexdigest()


def expected_image(raw: bytes, absent: set[tuple[int, int, int]]) -> tuple[bytearray, bytearray]:
    # Explicit forward layout, independent of production qkv_address.
    banks = (bytearray(b"\xa5" * HOST), bytearray(b"\xa5" * HOST))
    for plane in range(3):
        for head in range(16):
            shard, local_head = head & 1, head // 2
            for row in range(64):
                if (plane, head, row) in absent:
                    continue
                src = 4 * (row * 3072 + plane * 1024 + head * 64)
                dst = 4 * ((((plane * 2) * 8 + local_head) * 1024 + row) * 64)
                banks[shard][dst:dst + 256] = raw[src:src + 256]
    return banks


def gold(raw: bytes, mask: np.ndarray, head: int, query: int) -> tuple[bytes, bytes, bytes]:
    qkv = np.frombuffer(raw, dtype="<f4").reshape(64, 3072)
    q = qkv[query, head * 64:(head + 1) * 64]
    k = qkv[:, 1024 + head * 64:1024 + (head + 1) * 64]
    v = qkv[:, 2048 + head * 64:2048 + (head + 1) * 64]
    score = reference.qk_row(q, k, mask, 64, query, False)
    probability = reference.softmax_row(score, 64)
    av = reference.av_row(probability, v, 64)
    return tuple(np.asarray(x, dtype="<f4").tobytes() for x in (score, probability, av))


def main() -> None:
    OUT.mkdir(exist_ok=True)
    source = (OLD / "qkv_final.f32.bin").read_bytes()
    request = (OLD / "request.bin").read_bytes()
    mask = np.frombuffer((OLD / "attention_mask.u8.bin").read_bytes(), dtype="u1")
    assert len(source) == SOURCE and len(request) == 832 and mask.shape == (64,)
    changed = np.frombuffer(source, dtype="<f4").copy().reshape(64, 3072)
    changed[:, :64] = np.multiply(changed[:, :64], np.float32(1.25), dtype=np.float32)
    changed[:, 1024:1088] = np.multiply(changed[:, 1024:1088], np.float32(0.9), dtype=np.float32)
    changed[:, 2048:2112] = np.add(changed[:, 2048:2112], np.float32(0.125), dtype=np.float32)
    assert np.isfinite(changed).all()
    changed_raw = changed.astype("<f4", copy=False).tobytes()
    (OUT / "qkv_changed.f32.bin").write_bytes(changed_raw)

    cases = {
        "base": (source, set()),
        "changed": (changed_raw, set()),
        "missing_plane": (source, {(2, h, r) for h in range(16) for r in range(64)}),
        "missing_row": (source, {(1, 1, 63)}),
    }
    report: dict = {
        "schema": "d2_attention_preloaded_fixture_v1",
        "source_fixture": str(OLD),
        "source_request_sha256": digest(request),
        "source_raw_sha256": digest(source),
        "package_manifest_sha256": digest((ROOT / "build/model-attention-rtl-repair-20261008/manifest.json").read_bytes()),
        "build_tag": request[88:104].hex(),
        "sha_word_serialization": "digest byte 4*i at word i bits 7:0, byte 4*i+3 at bits 31:24",
        "cases": {},
        "gold": {},
        "independent_reference_sha256": digest((ROOT / "tests/full_reference.py").read_bytes()),
    }
    text_lines = []
    for name, (raw, absent) in cases.items():
        bank0, bank1 = expected_image(raw, absent)
        row_masks = [0] * 48
        for plane in range(3):
            for head in range(16):
                row_masks[plane * 16 + head] = sum(1 << row for row in range(64)
                                                     if (plane, head, row) not in absent)
        info = {
            "source_sha256": digest(raw),
            "bank_prefix_sha256": [digest(bank0[:PREFIX]), digest(bank1[:PREFIX])],
            "bank_host_sha256": [digest(bank0), digest(bank1)],
            "row_masks_hex": [f"{value:016x}" for value in row_masks],
            "absent_rows": sorted([list(x) for x in absent]),
        }
        report["cases"][name] = info
        text_lines.append("CASE " + " ".join([name, info["source_sha256"],
                           *info["bank_prefix_sha256"], *info["bank_host_sha256"]]))
    for name, raw, head, query in (("base_h0_r0", source, 0, 0),
                                   ("base_h15_r63", source, 15, 63),
                                   ("changed_h0_r0", changed_raw, 0, 0)):
        arrays = gold(raw, mask, head, query)
        for label, payload in zip(("score", "probability", "av"), arrays):
            (OUT / f"{name}_{label}.f32.bin").write_bytes(payload)
        report["gold"][name] = {label: digest(payload)
                                 for label, payload in zip(("score", "probability", "av"), arrays)}
        text_lines.append("GOLD " + " ".join([name, str(head), str(query),
                           report["gold"][name]["score"],
                           report["gold"][name]["probability"],
                           report["gold"][name]["av"]]))
    # Freeze the exact first two logical descriptor pages independently of
    # the C++ serializer. Later test calls carry their returned ticket/epochs.
    first = [0] * 160
    first[0:4] = [0x50514B56, 1, 0, (1 << 16) | 64]
    first[4:8] = [301, 0, 1, 0]
    first[10:16] = [0, 1, 0, 0, SOURCE, PREFIX]
    for start, hex_sha in ((16, report["cases"]["base"]["source_sha256"]),
                           (24, report["cases"]["base"]["bank_prefix_sha256"][0]),
                           (32, report["cases"]["base"]["bank_prefix_sha256"][1])):
        raw_digest = bytes.fromhex(hex_sha)
        for i in range(8):
            first[start + i] = int.from_bytes(raw_digest[4*i:4*i+4], "little")
    for i in range(4):
        first[40 + i] = int.from_bytes(request[88 + 4*i:92 + 4*i], "little")
    first[44:48] = [0, 0, 160, 302]
    begin_bytes = struct.pack("<160I", *first)
    run = first.copy()
    run[2] = 1
    run[8:10] = [1, 0]
    run[12:14] = [1, 1]
    for i in range(48):
        run[64 + 2*i:66 + 2*i] = [0xffffffff, 0xffffffff]
    run_bytes = struct.pack("<160I", *run)
    (OUT / "base_h0_r0_begin.u32le.bin").write_bytes(begin_bytes)
    (OUT / "base_h0_r0_run_ticket1_epoch1.u32le.bin").write_bytes(run_bytes)
    report["first_descriptor_pages"] = {
        "begin_sha256": digest(begin_bytes),
        "run_sha256": digest(run_bytes),
        "request_id": 301,
        "generation": 1,
        "scenario_id": 302,
        "ticket": 1,
        "epochs": [1, 1],
    }
    for label, expected in (("score", "base_h0_r0_score"),
                            ("probability", "base_h0_r0_probability"),
                            ("av", "base_h0_r0_av")):
        assert (OLD / f"{label}.f32.bin").read_bytes() == (OUT / f"{expected}.f32.bin").read_bytes()
    assert report["cases"]["base"]["bank_prefix_sha256"] != report["cases"]["changed"]["bank_prefix_sha256"]
    assert report["gold"]["base_h0_r0"] != report["gold"]["changed_h0_r0"]
    (OUT / "expected_hashes.txt").write_text("\n".join(text_lines) + "\n")
    (OUT / "fixture_manifest.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print("D2_PRELOADED_FIXTURE_PASS", digest(source), digest(changed_raw), len(text_lines))


if __name__ == "__main__":
    main()
