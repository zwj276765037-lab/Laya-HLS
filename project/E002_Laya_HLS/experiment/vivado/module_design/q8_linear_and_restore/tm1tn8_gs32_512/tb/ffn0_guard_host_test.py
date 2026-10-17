#!/usr/bin/env python3
"""Logical-time FFN1 watchdog checks using the exact production parser."""
import json
from pathlib import Path
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


def run():
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
    return {"schema": "ffn1_guard_logic_time_v1", "verdict": "PASS",
            "cases": cases, "case_count": len(cases),
            "simulator_spawned": False, "logical_stall_seconds": STALL}


if __name__ == "__main__":
    result = run()
    if len(sys.argv) == 3 and sys.argv[1] == "--out":
        Path(sys.argv[2]).write_text(json.dumps(result, indent=2) + "\n")
    print(f"FFN1_GUARD_HOST_PASS cases={result['case_count']}")
