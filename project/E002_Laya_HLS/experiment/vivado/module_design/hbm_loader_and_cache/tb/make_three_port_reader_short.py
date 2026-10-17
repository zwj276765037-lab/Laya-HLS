#!/usr/bin/env python3
"""Freeze small, real v4 Wi/Down byte windows for the three-port RTL TB."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from three_port_reader_model import q_byte, scale_byte

MANIFEST_SHA256 = "093bd662096f8c539529072d09d33f3b5a7f666125e21adaaf7ece20348c5915"
PAGE = 4096
WINDOW = 2 * PAGE
CASES = (
    ("wi_boundary", "mlp_wi.0.weight", (512, 0), (511, 0), (511, 0)),
    ("wi_tail", "mlp_wi.0.weight", (654, 31), (655, 31), (655, 31)),
    ("down_boundary", "mlp_wo.0.weight", (0, 64), (1, 64), (0, 64)),
    ("down_tail", "mlp_wo.0.weight", (126, 81), (127, 81), (127, 81)),
)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def window(point: int, first: int, span: int) -> int:
    assert first % PAGE == 0 and span % PAGE == 0 and span >= WINDOW
    start = point // PAGE * PAGE
    return min(max(start, first), first + span - WINDOW)


def emit_hex(raw: bytes) -> str:
    assert len(raw) == WINDOW
    return "".join(f"{int.from_bytes(raw[i:i+64], 'little'):0128x}\n"
                   for i in range(0, len(raw), 64))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    manifest = args.manifest.resolve(strict=True)
    raw_manifest = manifest.read_bytes()
    if sha(raw_manifest) != MANIFEST_SHA256:
        raise ValueError("expected frozen v4 manifest SHA256")
    package = json.loads(raw_manifest)
    package_dir = manifest.parent
    weights = {w["name"]: w for w in package["weights"]}
    output = args.output.resolve()
    if output.exists():
        raise FileExistsError("fixture output must be fresh")
    output.mkdir(parents=True)
    case_records = []
    for ordinal, (label, name, q0_key, q1_key, scale_key) in enumerate(CASES, 1):
        weight = weights[name]
        q0_shard, q0_point = q_byte(weight, *q0_key, 0, 0)
        q1_shard, q1_point = q_byte(weight, *q1_key, 0, 0)
        if (q0_shard, q1_shard) != (0, 1):
            raise AssertionError("case does not exercise both physical q ports")
        scale_point = scale_byte(weight, *scale_key, 0)
        sources = (
            ("q0", "w_q0.bin", q0_point, weight["q_base"][0], weight["q_span"][0]),
            ("q1", "w_q1.bin", q1_point, weight["q_base"][1], weight["q_span"][1]),
            ("scale", "w_scale.bin", scale_point,
             weight["scale_base"], weight["scale_span"]),
        )
        case_dir = output / label
        case_dir.mkdir()
        starts = []
        streams = []
        for role, filename, point, first, span in sources:
            start = window(point, first, span)
            with (package_dir / filename).open("rb") as source:
                source.seek(start)
                raw = source.read(WINDOW)
            if len(raw) != WINDOW or not start <= point < start + WINDOW:
                raise AssertionError("fixture byte window misses target")
            hex_text = emit_hex(raw)
            (case_dir / f"{role}.hex").write_text(hex_text)
            starts.append(start)
            streams.append({"role": role, "source": filename,
                            "source_offset": start, "bytes": WINDOW,
                            "target_offset": point, "window_sha256": sha(raw),
                            "hex_sha256": sha(hex_text.encode())})
        (case_dir / "config.hex").write_text(
            "".join(f"{x:016x}\n" for x in (*starts, WINDOW, WINDOW, WINDOW, ordinal)))
        case_records.append({"name": label, "weight": name, "epoch": ordinal,
                             "streams": streams})
    receipt = {"schema": "t4_three_port_reader_short_fixture_v1",
               "source_manifest": str(manifest),
               "source_manifest_sha256": sha(raw_manifest),
               "generator_sha256": sha(Path(__file__).read_bytes()),
               "cases": case_records}
    (output / "fixture_manifest.json").write_text(
        json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    print(f"T4_READER_FIXTURE_PASS cases={len(case_records)} "
          f"bytes_per_case={3*WINDOW}")


if __name__ == "__main__":
    main()
