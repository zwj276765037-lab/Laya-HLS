#!/usr/bin/env python3
"""Validate one guarded 20,000-clock diagnostic run from retained evidence."""

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import re


def record(path):
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices="MSVD")
    parser.add_argument("run", type=Path)
    parser.add_argument("--source-packet", type=Path, required=True)
    parser.add_argument("--runtime-gate", type=Path, required=True)
    parser.add_argument("--snapshot", type=Path, required=True)
    args = parser.parse_args()
    run = args.run.resolve()
    source = json.loads(args.source_packet.read_text())
    gate = json.loads(args.runtime_gate.read_text())
    expected_snapshot = gate["release"]["snapshot_xsimk"]["sha256"]
    assert record(args.snapshot)["sha256"] == expected_snapshot
    for item in source["source_files"] + source["v1_inputs"]:
        actual = record(Path(item["path"]))
        assert actual["sha256"] == item["sha256"] and actual["bytes"] == item["bytes"]
    for pair in source["copied_source_pairs"]:
        assert Path(pair["copy"]["path"]).read_bytes() == \
               Path(pair["original"]["path"]).read_bytes()

    guard = run / "guard"
    result = json.loads((guard / "guard_result.json").read_text())
    plan = json.loads((guard / "guard_plan.json").read_text())
    policies = json.loads((guard / "policy_checks.json").read_text())
    assert result["child_exit_code"] == 0 and result["trigger"] is None
    assert result["rss_captured"] and 0 < result["peak_owned_rss_kb"] < 4 * 1024 * 1024
    assert result["elapsed_seconds"] < 30
    assert result["minimum_mem_available_kb"] > 192 * 1024 * 1024
    assert policies and all(item["matches"] for item in policies)
    assert plan["selected_cpu_ids"] == [0, 1, 2, 3]
    assert plan["command"][-13:] == source["planned_runtime"][args.mode]["argv"][-13:]
    log = (run / "xsim.log").read_text()
    driver = (guard / "driver.log").read_text()
    assert not re.search(r"ERROR|FATAL|Fatal|CLOCK_WAIT_INVALID|CLOCK_WAIT_.*MISMATCH|CLOCK_WAIT_INCOMPLETE", log + "\n" + driver)
    pass_marker = f"CLOCK_WAIT_MODE_PASS mode={args.mode} clocks=20000 workers=32"
    assert log.count(pass_marker) == 1
    assert f"CLOCK_WAIT_CONFIG mode={args.mode} seed=1 clocks=20000 workers=32 interfaces=7" in log

    clocks = {"memory_ready": 0, "reset_release": 0, "clock_1": 1,
              "clock_16": 16, "clock_256": 256, "clock_1024": 1024,
              "clock_5000": 5000, "clock_10000": 10000,
              "clock_15000": 15000, "clock_20000": 20000}
    sample = re.compile(rf"^CLOCK_WAIT_SAMPLE mode={args.mode} label=(\S+) clocks=(\d+) workers=(\d+) constructors=(\d+) tick_sum=(\d+)$", re.M)
    samples = sample.findall(log)
    assert len(samples) == len(clocks)
    assert [item[0] for item in samples] == list(clocks)
    for label, cycle, workers, constructors, total in samples:
        assert int(cycle) == clocks[label]
        assert int(workers) == int(constructors) == 32
        assert int(total) == 32 * clocks[label]
    stage = re.compile(rf"^D2_PHASE_STAGE .*clock=(\d+) label=clock_wait_{args.mode}_(\S+) value0=(\d+) value1=(\d+) rss_kb=(-?\d+) hwm_kb=(-?\d+)$", re.M)
    stages = stage.findall(log)
    assert len(stages) == len(clocks)
    assert [item[1] for item in stages] == list(clocks)
    for cycle, label, constructors, total, rss, hwm in stages:
        assert int(cycle) == clocks[label]
        assert int(constructors) == 32 and int(total) == 32 * clocks[label]
        assert int(rss) > 0 and int(hwm) >= int(rss)

    evidence = {"schema": "clock_wait_v2_mode_validation_v1",
                "at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                "mode": args.mode, "status": "PASS", "samples": len(samples),
                "stages": len(stages), "guard_result": result,
                "policy_count": len(policies), "pass_marker": pass_marker,
                "source_packet": record(args.source_packet),
                "runtime_gate": record(args.runtime_gate),
                "snapshot_xsimk": record(args.snapshot),
                "logs": [record(run / "xsim.log"), record(guard / "driver.log")],
                "guard_files": [record(p) for p in sorted(guard.iterdir()) if p.is_file()]}
    out = run / "validation.json"
    out.write_text(json.dumps(evidence, indent=2) + "\n")
    print(args.mode, "PASS", record(out)["sha256"])


if __name__ == "__main__":
    main()
