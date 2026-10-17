#!/usr/bin/env python3
"""Deterministic logical-time tests of FFR1 simulator stall accounting."""

import argparse
import json
from pathlib import Path

from ffr1_guard import PROGRESS_KEYS, progress_decision


def line(values):
    return "FFR1_PROGRESS " + " ".join(
        f"{key}={value}" for key, value in zip(PROGRESS_KEYS, values))


def check(name, samples, expected_stall_at, expected_regression=False):
    previous = None
    last_progress = 0
    observed_stall = None
    regression_seen = False
    trace = []
    for second, text in samples:
        previous, advanced, regression = progress_decision(previous, text)
        regression_seen |= regression
        if advanced:
            last_progress = second
        stall = second - last_progress >= 120
        if stall and observed_stall is None:
            observed_stall = second
        trace.append({"logical_second": second, "line": text,
                      "advanced": advanced, "regression": regression,
                      "stall": stall})
    if observed_stall != expected_stall_at or regression_seen != expected_regression:
        raise AssertionError(name)
    return {"name": name, "samples": trace,
            "expected_stall_at": expected_stall_at,
            "observed_stall_at": observed_stall,
            "regression_seen": regression_seen, "spawned": False,
            "verdict": "PASS"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    zero = (0,) * len(PROGRESS_KEYS)
    first_r = tuple(1 if key in ("cfg", "sar", "sr") else 0
                    for key in PROGRESS_KEYS)
    next_r = tuple(2 if key in ("sar", "sr") else value
                   for key, value in zip(PROGRESS_KEYS, first_r))
    cases = [
        check("cycle_heartbeat_after_first_r",
              [(1, line(first_r)), (40, "FFR1_SNAPSHOT cycle=40000"),
               (80, "FFR1_PROGRESS cycle=80000"),
               (121, "FFR1_SNAPSHOT cycle=121000")], 121),
        check("repeated_identical_progress",
              [(1, line(first_r)), (45, line(first_r)),
               (90, line(first_r)), (121, line(first_r))], 121),
        check("real_handshake_renews",
              [(1, line(first_r)), (60, line(next_r)),
               (150, "FFR1_SNAPSHOT cycle=150000"),
               (180, "FFR1_SNAPSHOT cycle=180000")], 180),
        check("regression_not_progress",
              [(1, line(first_r)), (40, line(zero)),
               (121, "FFR1_SNAPSHOT")], 121, True),
    ]
    args.out.write_text(json.dumps({"schema": 1, "cases": cases,
                                    "spawned": False, "verdict": "PASS"},
                                   indent=2) + "\n")
    print("FFR1_GUARD_HOST_PASS cases=4 spawned=0")


if __name__ == "__main__":
    main()
