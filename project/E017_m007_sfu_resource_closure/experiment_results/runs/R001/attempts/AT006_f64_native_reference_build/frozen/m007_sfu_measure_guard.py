#!/usr/bin/env python3
"""Run one isolated HLS command with a bounded owned process tree."""

import argparse
import csv
import datetime as dt
import json
import os
from pathlib import Path
import signal
import re
import subprocess
import time

import hls_guard_helpers as guard


MIN_AVAILABLE_KB = 192 * 1024 * 1024
SAMPLE_SECONDS = 0.2


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--cwd", type=Path, required=True)
    parser.add_argument("--rss-gib", type=int, choices=(4, 8, 16, 24, 32), required=True)
    parser.add_argument("--timeout-seconds", type=int, required=True)
    parser.add_argument("--semantic-stall-seconds", type=int, default=120)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if not args.command or args.command[0] != "--" or len(args.command) < 2:
        parser.error("command must follow --")
    command = args.command[1:]
    output = args.out.resolve()
    cwd = args.cwd.resolve()
    if not cwd.is_dir() or args.timeout_seconds <= 0:
        raise RuntimeError("invalid working directory or timeout")
    output.mkdir(parents=True, exist_ok=True)
    guard.OUT = output
    selected = [0, 1, 2, 3]
    if not set(selected).issubset(os.sched_getaffinity(0)):
        raise RuntimeError("CPU0-3 unavailable")
    if len(selected) != 4 or guard.mem_available_kb() <= MIN_AVAILABLE_KB:
        raise RuntimeError("CPU affinity or MemAvailable preflight failed")
    wrapped = ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
               "/usr/bin/taskset", "-c", ",".join(map(str, selected)),
               *command]
    max_rss_kb = args.rss_gib * 1024 * 1024
    write_json(output / "guard_plan.json", {
        "at": now(), "cwd": str(cwd), "command": wrapped,
        "selected_cpu_ids": selected, "sample_seconds": SAMPLE_SECONDS,
        "maximum_owned_rss_kb": max_rss_kb,
        "minimum_mem_available_kb": MIN_AVAILABLE_KB,
        "maximum_seconds": args.timeout_seconds,
        "semantic_stall_seconds": args.semantic_stall_seconds,
    })

    stop_requested = False

    def on_term(signum, frame):
        nonlocal stop_requested
        stop_requested = True

    old_term = signal.signal(signal.SIGTERM, on_term)
    child = None
    leader = None
    known = {}
    last_items = {}
    checked_policy = {}
    trigger = None
    peak_rss = 0
    rss_sample_count = 0
    rss_capture_count = 0
    minimum_available = guard.mem_available_kb()
    exit_code = None
    started = time.monotonic()
    semantic_last = started
    semantic_offset = 0
    semantic_pending = ""
    semantic_line = "launch"
    semantic_next_record = started
    semantic_pattern = re.compile(
        r"(?:SFU_(?:REFERENCE_PASS|PHASE_PASS|RTL_PASS|OOC_PASS)|"
        r"Finished|Start |completed|Complete|Analyzing|Compiling|Built simulation|"
        r"Processing|Initializing|DSP Report:|optimization accepted|Writing timing|"
        r"checkpoint.*generated|Analyzing design file)", re.IGNORECASE)
    try:
        with (output / "driver.log").open("wb") as driver, \
             (output / "memory_timeline.csv").open("w", newline="") as stream:
            writer = csv.writer(stream)
            writer.writerow(("utc", "mem_available_kb", "owned_rss_kb",
                             "process_count", "largest_pid", "largest_rss_kb",
                             "largest_command"))
            stream.flush()
            child = subprocess.Popen(wrapped, cwd=cwd, stdout=driver,
                                     stderr=subprocess.STDOUT,
                                     start_new_session=True)
            leader = child.pid
            tick = guard.process_start(leader)
            if tick is None or os.getpgid(leader) != leader or \
                    os.getsid(leader) != leader:
                child.kill()
                child.wait()
                raise RuntimeError("task did not enter a unique session")
            known[leader] = tick
            write_json(output / "launch.json", {
                "at": now(), "leader_pid": leader,
                "leader_start_time_ticks": tick,
                "process_group_id": leader, "session_id": leader,
            })
            next_sample = time.monotonic()
            while child.poll() is None:
                current = time.monotonic()
                if current < next_sample:
                    time.sleep(min(next_sample - current, 0.05))
                    continue
                next_sample = current + SAMPLE_SECONDS
                available = guard.mem_available_kb()
                minimum_available = min(minimum_available, available)
                items = guard.owned_processes(guard.process_table(), leader,
                                               known)
                last_items = items
                total = sum(item["rss_kb"] for item in items.values())
                peak_rss = max(peak_rss, total)
                rss_sample_count += 1
                if any(item["rss_kb"] > 0 and
                       not item["state"].startswith("Z")
                       for item in items.values()):
                    rss_capture_count += 1
                largest = max(items.values(), key=lambda x: x["rss_kb"],
                              default=None)
                writer.writerow((now(), available, total, len(items),
                                 largest["pid"] if largest else "",
                                 largest["rss_kb"] if largest else "",
                                 largest["command"] if largest else ""))
                stream.flush()
                with (output / "driver.log").open("rb") as progress:
                    progress.seek(semantic_offset)
                    new_bytes = progress.read()
                    semantic_offset = progress.tell()
                semantic_pending += new_bytes.decode("utf-8", "replace")
                complete_lines = semantic_pending.split("\n")
                semantic_pending = complete_lines.pop()
                for line in complete_lines:
                    if semantic_pattern.search(line):
                        semantic_last = current
                        semantic_line = line[:800]
                if current >= semantic_next_record:
                    semantic_next_record = current + 60
                    with (output / "semantic_timeline.jsonl").open("a") as semantic:
                        semantic.write(json.dumps({"utc": now(),
                            "elapsed_seconds": current-started,
                            "owned_rss_kb": total,
                            "mem_available_kb": available,
                            "last_progress_line": semantic_line,
                            "seconds_since_progress": current-semantic_last,
                            "driver_offset": semantic_offset}) + "\n")
                if stop_requested:
                    trigger = {"at": now(), "reason": "sigterm_requested"}
                elif available <= MIN_AVAILABLE_KB:
                    trigger = {"at": now(), "reason":
                               "mem_available_at_or_below_192_GiB"}
                elif total >= max_rss_kb:
                    trigger = {"at": now(), "reason":
                               "owned_rss_at_or_above_limit"}
                elif current - started >= args.timeout_seconds:
                    trigger = {"at": now(), "reason": "timeout"}
                elif current - semantic_last >= args.semantic_stall_seconds:
                    trigger = {"at": now(), "reason": "semantic_stall",
                               "seconds_since_progress": current-semantic_last,
                               "last_progress_line": semantic_line}
                if trigger is not None:
                    break
                for item in items.values():
                    pid = item["pid"]
                    if pid in checked_policy or item["state"].startswith("Z") or \
                            not guard.still_owned(item):
                        continue
                    try:
                        affinity = sorted(os.sched_getaffinity(pid))
                        ionice = subprocess.run(
                            ["/usr/bin/ionice", "-p", str(pid)],
                            capture_output=True, text=True, timeout=5)
                    except (ProcessLookupError, FileNotFoundError,
                            subprocess.TimeoutExpired):
                        continue
                    policy = {"pid": pid, "command": item["command"],
                              "nice": item["nice"], "affinity": affinity,
                              "ionice": (ionice.stdout or ionice.stderr).strip(),
                              "ionice_exit": ionice.returncode,
                              "matches": item["nice"] == 19 and
                                  bool(affinity) and
                                  set(affinity).issubset(selected) and
                                  ionice.returncode == 0 and
                                  "idle" in (ionice.stdout or
                                             ionice.stderr).lower()}
                    if not policy["matches"]:
                        latest = guard.process_table().get(pid)
                        if latest is None or latest["state"].startswith("Z") or \
                                not guard.still_owned(item):
                            continue
                    checked_policy[pid] = policy
                    write_json(output / "policy_checks.json",
                               list(checked_policy.values()))
                    if not policy["matches"]:
                        trigger = {"at": now(), "reason":
                                   "owned_process_policy_mismatch",
                                   "policy": policy}
                        break
                if trigger is not None:
                    break
            if trigger is not None:
                trigger.update({"leader_pid": leader,
                                "process_group_id": leader,
                                "peak_owned_rss_kb": peak_rss,
                                "minimum_mem_available_kb": minimum_available})
                guard.stop_and_kill(leader, known, last_items, trigger)
            exit_code = child.wait(timeout=30)
    finally:
        try:
            if leader is not None:
                try:
                    remaining = guard.owned_processes(guard.process_table(),
                                                       leader, known)
                    remaining = {pid: item for pid, item in remaining.items()
                                 if not item["state"].startswith("Z")}
                except Exception:
                    remaining = {pid: item for pid, item in last_items.items()
                                 if guard.still_owned(item)}
                if remaining or guard.verified_group(leader, known):
                    emergency = trigger or {"at": now(),
                                            "reason": "orphaned_task",
                                            "leader_pid": leader,
                                            "process_group_id": leader}
                    trigger = emergency
                    guard.stop_and_kill(leader, known, remaining, emergency)
            if child is not None and child.poll() is None:
                child.kill()
                child.wait(timeout=30)
        finally:
            signal.signal(signal.SIGTERM, old_term)
            write_json(output / "guard_result.json", {
                "finished_at": now(), "child_exit_code": exit_code,
                "trigger": trigger["reason"] if trigger else None,
                "peak_owned_rss_kb": peak_rss if rss_capture_count else None,
                "rss_captured": rss_capture_count > 0,
                "rss_sample_count": rss_sample_count,
                "rss_capture_count": rss_capture_count,
                "minimum_mem_available_kb": minimum_available,
                "elapsed_seconds": time.monotonic() - started,
            })
    return 0 if exit_code == 0 and trigger is None else 1


if __name__ == "__main__":
    raise SystemExit(main())
