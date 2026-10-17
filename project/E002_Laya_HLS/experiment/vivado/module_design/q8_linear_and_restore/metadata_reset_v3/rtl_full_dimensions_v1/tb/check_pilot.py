#!/usr/bin/env python3
"""Offline audit of the first Scorer XSim log and sealed runtime inputs.

This checker is downstream of the source-only gate. DUT output is never used
to construct expected values; the SystemVerilog bench compares independent
gold byte-for-byte before it emits each PASS marker.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def captures(pattern: str, text: str) -> list[dict]:
    return [m.groupdict() for m in re.finditer(pattern, text, re.M)]


def dump_bytes(path: Path, expected_length: int) -> bytes:
    lines = path.read_text().splitlines()
    if len(lines) != expected_length or any(not re.fullmatch(r"[0-9a-fA-F]{2}", x)
                                                for x in lines):
        raise ValueError(f"raw dump shape: {path}")
    return bytes.fromhex("".join(lines))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("runtime_dir", type=Path)
    ap.add_argument("output_json", type=Path)
    args = ap.parse_args()
    runtime = args.runtime_dir.resolve()
    metadata = json.loads((runtime / "runtime_input.json").read_text())
    if metadata["schema"] != "q8_full_scorer_first_pilot_runtime_input_v1":
        raise ValueError("runtime schema")
    for entry in metadata["files"].values():
        path = Path(entry["path"])
        if path.stat().st_size != entry["bytes"] or sha(path) != entry["sha256"]:
            raise ValueError(f"runtime input changed: {path}")
    fixture = runtime.parent / "fixture"
    # The caller may store fixture elsewhere. Bind it through an explicit
    # runtime-input field when creating the prepared runtime directory.
    fixture = Path(metadata["fixture_root"])
    report_path = fixture / "fixture_report.json"
    if sha(report_path) != metadata["fixture_report_sha256"]:
        raise ValueError("fixture report changed")
    fixture_report = json.loads(report_path.read_text())
    logpath = runtime / "xsim.log"
    log = logpath.read_text(errors="replace")
    if re.search(r"(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)", log, re.M):
        raise ValueError("simulator failure marker")
    commands = captures(r"^Q8_SCORER_COMMAND_PASS cmd=(?P<cmd>\d+) cycles=(?P<cycles>\d+)$", log)
    times = captures(r"^Q8_SCORER_OBSERVER_TIME cmd=(?P<cmd>\d+) lite_aw=(?P<lite_aw>\d+) lite_w=(?P<lite_w>\d+) ap_accept=(?P<accept>\d+) ap_done=(?P<done>\d+) ap_cycles=(?P<ap_cycles>\d+) pre_issue_unknown=(?P<pre>\d+) issue_span=(?P<span>\d+) post_issue_unknown=(?P<post>\d+)$", log)
    issues = captures(r"^Q8_SCORER_OBSERVER_ISSUE cmd=(?P<cmd>\d+) count=(?P<count>\d+) retired=(?P<retired>\d+) first=(?P<first>\d+) last=(?P<last>\d+) first_retire=(?P<first_retire>\d+) last_retire=(?P<last_retire>\d+) max_gap=(?P<gap>\d+) hist=(?P<hist>[\d,]+)$", log)
    if ([int(x["cmd"]) for x in commands] != [0, 1, 2] or
        [int(x["cmd"]) for x in times] != [0, 1, 2] or
        [int(x["cmd"]) for x in issues] != [0, 1, 2]):
        raise ValueError("three-command evidence missing or reordered")
    for index in range(3):
        t, q = times[index], issues[index]
        if (int(t["accept"]) <= 0 or int(t["done"]) < int(t["accept"]) or
            int(t["ap_cycles"]) != int(t["done"]) - int(t["accept"])):
            raise ValueError(f"AP timing {index}")
        if index == 0:
            if int(q["count"]) != 0 or int(q["retired"]) != 0:
                raise ValueError("LOAD issued linear work")
        else:
            if (int(q["count"]) != 4096 or int(q["retired"]) != 4096 or
                int(t["pre"]) + int(t["span"]) + int(t["post"]) !=
                int(t["ap_cycles"]) or
                sum(map(int, q["hist"].split(","))) != 4095):
                raise ValueError(f"issue/phase count {index}")
    if "Q8_SCORER_PILOT_PASS commands=3 K=1024 N=1024" not in log:
        raise ValueError("terminal PASS missing")
    dumps = []
    for index, command in enumerate(fixture_report["commands"]):
        for field, count, tag in (("observed", 131072, "observed"),
                                  ("out0", 65536, "out0"),
                                  ("out1", 4096, "out1")):
            gold_entry = command[field]
            gold = fixture / gold_entry["relative_path"]
            if sha(gold) != gold_entry["sha256"] or gold.stat().st_size != count:
                raise ValueError(f"frozen expected image {index}/{field}")
            raw_path = runtime / f"{tag}_cmd{index}.hex"
            actual = dump_bytes(raw_path, count)
            if actual != gold.read_bytes():
                first = next(i for i, (a, b) in enumerate(zip(actual,gold.read_bytes())) if a != b)
                raise ValueError(f"raw mismatch {index}/{field} first byte {first}")
            dumps.append({"case": index, "field": field, "path": str(raw_path),
                          "bytes": raw_path.stat().st_size, "sha256": sha(raw_path),
                          "payload_sha256": hashlib.sha256(actual).hexdigest()})
    result = {"schema": "q8_full_scorer_first_pilot_log_audit_v1",
              "status": "PASS", "log": {"path": str(logpath),
                                            "bytes": logpath.stat().st_size,
                                            "sha256": sha(logpath)},
              "runtime_input_sha256": sha(runtime / "runtime_input.json"),
              "commands": commands, "ap_times": times, "issues": issues,
              "raw_dumps": dumps}
    args.output_json.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print("Q8_SCORER_PILOT_LOG_AUDIT_PASS commands=3 issue_per_run=4096")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
