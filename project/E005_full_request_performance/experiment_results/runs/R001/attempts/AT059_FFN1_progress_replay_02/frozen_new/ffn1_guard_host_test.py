#!/usr/bin/env python3
"""Logical-time FFN1 watchdog checks using the exact production parser."""
import argparse
import json
from pathlib import Path
import re
import sys

from ffn0_guard import PROGRESS_FIELDS, progress_decision, sim_start_decision

STALL = 120


def progress(**changes):
    values = {name: 0 for name in PROGRESS_FIELDS}
    values.update(changes)
    return "FFN1_PROGRESS work={} {}".format(
        sum(values.values()),
        " ".join(f"{name}={values[name]}" for name in PROGRESS_FIELDS))


def replay(events):
    """Model the production loop's parse-before-120-second comparison."""
    started = False
    previous = None
    last = 0
    records = []
    for at, line in events:
        next_started, first, duplicate = sim_start_decision(started, line)
        action = "ignored"
        if duplicate:
            action = "duplicate_start"
        elif first:
            started = next_started
            last = at
            action = "start"
        elif started:
            previous, advanced, regression, malformed = progress_decision(
                previous, line)
            if malformed:
                action = "schema_error"
            elif regression:
                action = "regression"
            elif advanced:
                last = at
                action = "progress"
            elif line.startswith("FFN1_PROGRESS"):
                action = "repeat"
        if action not in {"duplicate_start", "schema_error", "regression"}:
            if at - last >= STALL:
                action = "semantic_stall"
        records.append({"at": at, "line": line, "action": action,
                        "last_real_progress_at": last,
                        "seconds_since_progress": at - last})
        if action in {"duplicate_start", "schema_error", "regression",
                      "semantic_stall"}:
            break
    return records


def check(name, events, expected):
    actual = replay(events)
    actions = [item["action"] for item in actual]
    assert actions == expected, (name, actions, expected)
    return {"name": name, "events": actual, "accepted_progress":
            actions.count("progress"), "last_action": actions[-1]}


def inspect_micro(path):
    lines = [line for line in path.read_text(errors="replace").splitlines()
             if line.startswith("FFN1_PROGRESS ")]
    if len(lines) != 1:
        raise AssertionError(("micro progress count", len(lines)))
    snapshot, advanced, regression, malformed = progress_decision(None, lines[0])
    expected = [1] * len(PROGRESS_FIELDS)
    for name in ("w0r", "w1r", "wsr"):
        expected[PROGRESS_FIELDS.index(name)] = 2
    if malformed or regression or not advanced or snapshot != tuple(expected):
        raise AssertionError("micro output did not reach the actual parser")
    events = [(0, "FFN0_SIM_START"), (1, lines[0]), (120, lines[0]),
              (121, lines[0])]
    return check("actual_micro_output_through_logical_time", events,
                 ["start", "progress", "repeat", "semantic_stall"])


def inspect_old_w_log(path):
    pattern = re.compile(
        r"^MATRIX_PROGRESS cycle=(\d+) stage=0 W_q0_R=(\d+) "
        r"W_q1_R=(\d+) W_scale_R=(\d+)$")
    samples = []
    previous = None
    for line in path.read_text(errors="replace").splitlines():
        match = pattern.fullmatch(line)
        if match is None:
            continue
        cycle, q0, q1, scale = map(int, match.groups())
        snapshot, advanced, regression, malformed = progress_decision(
            previous, progress(w0r=q0, w1r=q1, wsr=scale))
        if malformed or regression or not advanced:
            raise AssertionError(("old W replay", cycle, q0, q1, scale))
        previous = snapshot
        samples.append({"original_cycle": cycle, "q0_R": q0,
                        "q1_R": q1, "scale_R": scale,
                        "new_schema_would_advance": True})
    if len(samples) != 52:
        raise AssertionError(("old W sample count", len(samples)))
    return {"source": str(path), "observed_samples": samples,
            "sample_count": len(samples), "original_timestamps_reused": False,
            "old_guard_accepted_w_progress": False,
            "new_schema_counters_would_advance": True}


def run(micro_log=None, old_w_log=None):
    start = (0, "FFN0_SIM_START")
    r = progress(lnr=1)
    cases = [
        check("first_r_then_heartbeat_does_not_extend",
              [start, (1, r), (10, "cycle=20000 heartbeat"),
               (50, "MATRIX_PROGRESS cycle=9999 W_q0_R=99"),
               (119, "ordinary completed"), (121, "cycle=40000 heartbeat")],
              ["start", "progress", "ignored", "ignored", "ignored",
               "semantic_stall"]),
        check("same_work_repeated_until_threshold",
              [start, (1, r), (119, r), (121, r)],
              ["start", "progress", "repeat", "semantic_stall"]),
        check("duplicate_start_rejected",
              [start, (1, r), (2, "FFN0_SIM_START")],
              ["start", "progress", "duplicate_start"]),
        check("unknown_family_rejected",
              [start, (1, r),
               (2, progress(lnr=2).replace("lnr=2", "unknown=2"))],
              ["start", "progress", "schema_error"]),
        check("regression_rejected",
              [start, (1, progress(w0r=2)), (2, progress(w0r=1))],
              ["start", "progress", "regression"]),
        check("q0_only_progress",
              [start, (1, progress(w0r=1)), (2, progress(w0r=2))],
              ["start", "progress", "progress"]),
        check("q1_only_progress",
              [start, (1, progress(w1r=1)), (2, progress(w1r=2))],
              ["start", "progress", "progress"]),
        check("scale_only_progress",
              [start, (1, progress(wsr=1)), (2, progress(wsr=2))],
              ["start", "progress", "progress"]),
        check("real_progress_before_threshold_then_silence",
              [start, (1, r), (119, progress(lnr=1,w1r=1)),
               (238, "ordinary completed"), (239, "ordinary completed")],
              ["start", "progress", "progress", "ignored", "semantic_stall"]),
        check("real_progress_at_threshold_then_silence",
              [start, (120, progress(wsr=1)), (239, "cycle heartbeat"),
               (240, "cycle heartbeat")],
              ["start", "progress", "ignored", "semantic_stall"]),
        check("quiet_exact_threshold",
              [start, (119, "cycle heartbeat"), (120, "cycle heartbeat")],
              ["start", "ignored", "semantic_stall"]),
    ]
    if micro_log is not None:
        cases.append(inspect_micro(micro_log))
    result = {"schema": "ffn1_guard_logic_time_v1", "verdict": "PASS",
            "cases": cases, "case_count": len(cases),
            "simulator_spawned": False, "logical_stall_seconds": STALL}
    if old_w_log is not None:
        result["old_w_readonly_replay"] = inspect_old_w_log(old_w_log)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--micro-log", type=Path)
    parser.add_argument("--old-w-log", type=Path)
    args = parser.parse_args()
    result = run(args.micro_log, args.old_w_log)
    args.out.write_text(json.dumps(result, indent=2) + "\n")
    print(f"FFN1_GUARD_HOST_PASS cases={result['case_count']}")
