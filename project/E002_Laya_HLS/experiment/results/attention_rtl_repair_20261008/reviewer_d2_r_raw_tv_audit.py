#!/usr/bin/env python3
"""Read-only independent audit of one completed D2-R RTL output transaction.

This script never launches the DUT or a project oracle. It accepts only complete
binary TV frames, checks physical output memories, and computes AV from the
returned probability words with scalar binary32 multiply-then-add arithmetic.
It is a raw-output check, not standalone approval of a simulation run.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import struct


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def f32(value: float) -> float:
    return struct.unpack("<f", struct.pack("<f", value))[0]


def words(data: bytes) -> tuple[int, ...]:
    return struct.unpack("<" + "I" * (len(data) // 4), data)


def floats(data: bytes) -> tuple[float, ...]:
    return struct.unpack("<" + "f" * (len(data) // 4), data)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tv_dir", type=Path)
    parser.add_argument("fixture_dir", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--io-depth", type=int, default=32768)
    parser.add_argument("--qkv-depth", type=int, default=12582912)
    parser.add_argument("--att-depth", type=int, default=8388608)
    args = parser.parse_args()
    report = {"status": "RAW_OUTPUT_CHECK_PENDING", "checks": 0,
              "failures": [], "artifacts": {}, "metrics": {},
              "simulation_guard_or_completion_accepted_by_this_script": False}

    def check(ok: bool, label: str) -> None:
        report["checks"] += 1
        if not ok:
            report["failures"].append(label)

    def read(path: Path) -> bytes:
        data = path.read_bytes()
        report["artifacts"][str(path.resolve())] = {
            "bytes": len(data), "sha256": sha(data)}
        return data

    def tv(port: str, count: int, item_bytes: int = 1) -> bytes:
        path = args.tv_dir / "rtldatafile" / (
            "rtl.attention_slice.autotvout_" + port + ".dat")
        data = read(path)
        if len(data) != count * item_bytes + 16:
            raise ValueError(f"incomplete/unexpected TV length: {path}: {len(data)}")
        if struct.unpack(">II", data[:8]) != (0, count):
            raise ValueError(f"wrong transaction header/count: {path}")
        if data[-8:] != bytes.fromhex("5a5aa5a50f0ff0f0"):
            raise ValueError(f"wrong transaction trailer: {path}")
        check(True, port + " transaction 0 complete and count exact")
        return data[8:-8]

    try:
        fixture = read(args.fixture_dir / "qkv_final.f32.bin")
        check(sha(fixture) ==
              "ce3f0ee0969b2e1493730b6d4fd75912d113b0e37130a0196df9771713051406",
              "frozen real native QKV identity")
        request = read(args.fixture_dir / "request.bin")
        check(sha(request) ==
              "47e2c2418b41ad4491ea20da54f5ba5aabc8eb4f17bc070796e9c1202dea33b5",
              "frozen request identity")
        expected_score = read(args.fixture_dir / "score.f32.bin")
        expected_prob = read(args.fixture_dir / "probability.f32.bin")
        expected_av = read(args.fixture_dir / "av.f32.bin")
        for label, data, digest in (
            ("score", expected_score,
             "0be4771502fadfb4788346e215b0a0b4c4474877bfa4cde7979c5fcc630c4d97"),
            ("probability", expected_prob,
             "42becacb863a907a0453930875065f96652a63996665e969cd4d418711b2ec04"),
            ("AV", expected_av,
             "2c6e2789b157cafccd734c933f981be3c99aacddcc872f1172d0032a74239533")):
            check(sha(data) == digest, label + " independently reviewed frozen gold")

        observed_wire = tv("observed", 256, 4)
        observed = struct.unpack(">256I", observed_wire)
        check(observed[:11] == (0, 0, 13, 4, 1, 1, 32768, 5,
                                0x04080009, 4, 0),
              "all completion, owner, task and partial publication words exact")
        check(observed[11:16] == (0xDEADBEEF,) * 5,
              "unused prefix observation words untouched")
        check(observed[208:] == (0xDEADBEEF,) * 48,
              "entire observed tail untouched")
        score_raw = struct.pack("<64I", *observed[16:80])
        prob_raw = struct.pack("<64I", *observed[80:144])
        av_raw = struct.pack("<64I", *observed[144:208])
        check(score_raw == expected_score, "all 64 QK scores bit exact")
        probability = floats(prob_raw)
        actual_av = floats(av_raw)
        gold_probability = floats(expected_prob)
        gold_av = floats(expected_av)
        for label, actual, gold in (("probability", probability, gold_probability),
                                    ("AV end-to-end", actual_av, gold_av)):
            for index, (value, reference) in enumerate(zip(actual, gold)):
                check(math.isfinite(value) and math.isfinite(reference) and
                      abs(value - reference) <= 1e-4 + 1e-4 * abs(reference),
                      f"{label} tolerance at {index}")
            report["metrics"][label + " max absolute error"] = max(
                abs(a - b) for a, b in zip(actual, gold))
        check(all(0.0 <= value <= 1.0 for value in probability),
              "all probabilities in [0,1]")
        report["metrics"]["probability real sum"] = sum(probability)

        exact_av = []
        for channel in range(64):
            acc = 0.0
            for key in range(64):
                value = struct.unpack_from(
                    "<f", fixture, (key * 3072 + 2048 + channel) * 4)[0]
                product = f32(probability[key] * value)
                acc = f32(acc + product)
            exact_av.append(acc)
        exact_av_raw = struct.pack("<64f", *exact_av)
        check(av_raw == exact_av_raw,
              "all 64 AV words bit exact from actual RTL probability and original V")
        report["metrics"]["AV recomputed words sha256"] = sha(exact_av_raw)

        att = tv("att_out", args.att_depth)
        check(att[:256] == av_raw, "ATT_OUT numerical AXI words equal observations")
        check(att[256:] == b"\xa5" * (len(att) - 256),
              "entire ATT_OUT outside first 64 channels untouched")
        check(args.att_depth >= 4100, "head and next-row sentinel span retained")
        io = tv("io", args.io_depth)
        check(args.io_depth >= len(request), "complete request retained")
        check(io == request + bytes(args.io_depth - len(request)),
              "IO request and all padding unchanged")

        check(args.qkv_depth >= 10240000, "all active fixed-stride QKV addresses fit")
        expected = [bytearray(b"\xa5" * args.qkv_depth) for _ in range(2)]
        highest = [0, 0]
        copied = 0
        for plane in range(3):
            for head in range(16):
                bank = head % 2
                local_head = head // 2
                for token in range(64):
                    dst = (((plane * 2 * 8 + local_head) * 1024 + token) * 64) * 4
                    src = (token * 3072 + plane * 1024 + head * 64) * 4
                    expected[bank][dst:dst + 256] = fixture[src:src + 256]
                    highest[bank] = max(highest[bank], dst + 256)
                    copied += 256
        check(copied == 786432, "all physical QKV fixture bytes reconstructed")
        for bank in range(2):
            actual = tv("qkv" + str(bank), args.qkv_depth)
            check(actual == expected[bank],
                  f"all QKV{bank} scatter bytes and every unused byte exact")
        report["metrics"]["QKV highest address exclusive"] = highest
        report["metrics"]["QKV bytes reconstructed"] = copied
        report["status"] = "PASS_RAW_OUTPUT_ONLY" if not report["failures"] else "FAIL"
    except (OSError, ValueError, struct.error, OverflowError) as exc:
        report["status"] = "INCOMPLETE_OR_INVALID_RAW_OUTPUT"
        report["failures"].append(str(exc))
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"status": report["status"], "checks": report["checks"],
                      "failures": report["failures"], "report": str(args.output)}, indent=2))
    raise SystemExit(0 if report["status"] == "PASS_RAW_OUTPUT_ONLY" else 1)


if __name__ == "__main__":
    main()
