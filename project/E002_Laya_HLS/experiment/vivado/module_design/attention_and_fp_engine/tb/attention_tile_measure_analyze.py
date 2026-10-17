#!/usr/bin/env python3
"""Check ATN0 terminals and summarize comparable, scoped cycle evidence."""

import argparse
import hashlib
import json
import re
from pathlib import Path


PREFIX = "ATTENTION_SERVICE_TILE_"


def record(path):
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def rows_for(log, tag):
    pattern = re.compile(r"^" + re.escape(PREFIX + tag) + r"\s+(.+)$", re.MULTILINE)
    result = []
    for match in pattern.finditer(log):
        row = {}
        for key, value in re.findall(r"([A-Za-z_][A-Za-z_0-9]*)=(-?\d+)", match.group(1)):
            row[key] = int(value)
        result.append(row)
    return result


def only(log, tag):
    rows = rows_for(log, tag)
    if len(rows) != 1:
        raise RuntimeError(f"Expected one {tag}, got {len(rows)}")
    return rows[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("attempt", type=Path)
    parser.add_argument("run")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--guard", help="Guard directory for a protocol replay")
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    run = attempt / args.run
    runtime = json.loads((run / "input_manifest.json").read_text())
    protocol = bool(runtime.get("protocol", 0))
    log_path = run / "simulate.log"
    log = log_path.read_text(errors="replace")
    terminal = only(log, "RTL_PASS")
    sm = only(log, "SM_MEASURE")
    op_counts = only(log, "SM_OP_COUNTS")
    commands = rows_for(log, "CMD_MEASURE")
    workers = rows_for(log, "EXP_MEASURE")
    tiles = rows_for(log, "PASS")
    ledger = only(log, "LEDGER_PASS")
    guard_name = args.guard or f"guard_{'full' if args.run.startswith('full') else 'pilot'}_01"
    guard = json.loads((attempt / guard_name / "guard_result.json").read_text())
    if guard["child_exit_code"] != 0 or guard["trigger"] is not None:
        raise RuntimeError("Guard did not finish cleanly")
    rows = terminal["rows"]
    if len(tiles) != (rows + 15) // 16 or len(commands) != 3 or len(workers) != 4:
        raise RuntimeError("Missing normal tile, command, or worker markers")
    if sorted(row["cmd"] for row in commands) != [19, 20, 21]:
        raise RuntimeError("Command coverage is incomplete")
    if sum(sm[key] for key in ("MAX", "EXP", "TREE", "DIV", "launch_report")) != sm["enabled_to_done"]:
        raise RuntimeError("Mutually exclusive SM states do not sum to the measured interval")
    sm_interval = "enabled_to_done" if protocol else "wall_to_done"
    if sm[sm_interval] != terminal["sm"] or sm["commands"] != len(tiles):
        raise RuntimeError("SM interval does not match the original command profile")
    for command, field in ((19, "qk"), (20, "sm"), (21, "av")):
        entry = next(item for item in commands if item["cmd"] == command)
        if entry["calls"] != len(tiles) or entry[sm_interval] != terminal[field]:
            raise RuntimeError(f"Command {command} does not match terminal cycles")
    for field, multiplier in (("products", 8192), ("trees", 8064), ("av_steps", 8192), ("exp", 128)):
        if terminal[field] != rows * multiplier:
            raise RuntimeError(f"Original {field} operation coverage changed")
    if ledger["accepted"] != ledger["retired"] + ledger["cancelled"]:
        raise RuntimeError("Accepted commands did not retire or cancel")
    if sum(w["launch"] for w in workers) != terminal["exp"] or any(
        w["launch"] != w["done"] or w["done"] != w["commit"] for w in workers
    ):
        raise RuntimeError("EXP service observations did not match original output coverage")
    if any(sum(w[key] for key in ("input_wait", "core_busy", "commit_wait", "idle")) != sm["EXP"] for w in workers):
        raise RuntimeError("Worker slot occupancy is not a complete EXP-stage partition")
    if op_counts["A_sub_issue"] != op_counts["A_sub_retire"] or op_counts["A_tree_issue"] != op_counts["A_tree_retire"]:
        raise RuntimeError("A service issue/return count differs")
    if op_counts["D_return_lanes"] != op_counts["D_issue"] * 4:
        raise RuntimeError("DIV issue/return lane count differs")
    core = [w["core_busy"] for w in workers]
    result = {
        "schema": "attention-tile-scoped-measurement-v1",
        "scope": ("One PROTOCOL=1 replay plus normal enc0/head0 B1/S128 Attention sample; no AXI master or complete request"
                  if protocol else "One normal enc0/head0 B1/S128 Attention sample; no AXI master or complete request"),
        "protocol_enabled": protocol,
        "status": "PASS_SCOPED_NUMERIC_AND_MEASUREMENT",
        "source_manifest": record(attempt / "source_manifest.json"),
        "input_manifest": record(run / "input_manifest.json"),
        "raw_log": record(log_path),
        "guard": guard,
        "guard_directory": guard_name,
        "terminal": terminal,
        "tiles": tiles,
        "commands": commands,
        "softmax_mutually_exclusive_enabled": sm,
        "softmax_operation_counts": op_counts,
        "workers": workers,
        "ledger": ledger,
        "four_worker_aggregate_core_bound_enabled": (sum(core) + 3) // 4,
        "observed_max_worker_core_busy_enabled": max(core),
        "optimistic_noncore_gap_enabled": sm["EXP"] - (sum(core) + 3) // 4,
        "bound_caveat": "Four-worker core service gives only a conditional arithmetic lower bound. Input, commit, and idle slots overlap across workers; the optimistic gap is not guaranteed removable delay or physical throughput.",
        "physical_resources_and_timing": "UNKNOWN",
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print("ATTENTION_TILE_ANALYZE_PASS", args.out, flush=True)


if __name__ == "__main__":
    main()
