#!/usr/bin/env python3
"""E016 R006 guard v2: RTL progress is monotonic independently checked work only."""

import argparse
import csv
import ctypes
import datetime as dt
import json
import os
from pathlib import Path
import signal
import re
import subprocess
import time

import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[5] / 'tools'))
import hls_guard_helpers as guard


MIN_AVAILABLE_KB = 192 * 1024 * 1024
SAMPLE_SECONDS = 0.2
ARTIFACT_SAMPLE_SECONDS = 5.0
SPLIT_PROGRESS = re.compile(
    r"FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS work=(\d+).*"
    r"writes=(\d+) reads=(\d+) qrows=(\d+)")
STAGED_LN_PROGRESS = re.compile(
    r"STAGED_LN_PROGRESS gamma=(\d+) raw=(\d+) norm=(\d+) B=(\d+)")


def split_progress_work(line):
    """Return only monotonic completed work; cycle/state heartbeats return None."""
    match = SPLIT_PROGRESS.search(line)
    if match is None:
        match = STAGED_LN_PROGRESS.search(line)
        if match is None:
            return None
    return tuple(int(value) for value in match.groups())


PARENT_PROGRESS = re.compile(r"^M007_PARENT_CHECKED checked=(\d+) phase=([A-Za-z0-9_]+) cycle=(\d+)$")

def semantic_progress_advances(line, split_highwater, phase="static"):
    if phase == "rtl":
        match = PARENT_PROGRESS.fullmatch(line)
        if not match:
            return False, split_highwater
        checked, cycle = int(match.group(1)), int(match.group(3))
        previous = split_highwater or (0, 0)
        if checked <= previous[0] or cycle < previous[1]:
            return False, split_highwater
        return True, (checked, cycle)
    """Classify the split marker by completed work, excluding clock/state churn."""
    work = split_progress_work(line)
    if work is None:
        if ("FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS" in line or
                "STAGED_LN_PROGRESS" in line):
            return False, split_highwater
        return True, split_highwater
    advanced = split_highwater is None or any(
        value > old for value, old in zip(work, split_highwater))
    if advanced:
        split_highwater = tuple(max(value, old) for value, old in
            zip(work, split_highwater or (0, 0, 0, 0)))
    return advanced, split_highwater


def artifact_progress_work(root):
    """Return monotonic HLS output work as regular-file count and total bytes."""
    if root is None or not root.exists():
        return (0, 0)
    count = 0
    total_bytes = 0
    for path in root.rglob("*"):
        try:
            if path.is_file():
                count += 1
                total_bytes += path.stat().st_size
        except OSError:
            # A compiler temporary may disappear between enumeration and stat.
            continue
    return (count, total_bytes)


def artifact_progress_advances(work, highwater):
    """Refresh only when generated file count or bytes exceeds its high-water."""
    if highwater is None:
        return work != (0, 0), work
    advanced = any(value > old for value, old in zip(work, highwater))
    return advanced, tuple(max(value, old) for value, old in
                           zip(work, highwater))


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
    parser.add_argument("--artifact-progress-root", type=Path)
    parser.add_argument("--phase", choices=("static", "rtl"), required=True)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if not args.command or args.command[0] != "--" or len(args.command) < 2:
        parser.error("command must follow --")
    command = args.command[1:]
    output = args.out.resolve()
    cwd = args.cwd.resolve()
    artifact_root = (args.artifact_progress_root.resolve()
                     if args.artifact_progress_root is not None else None)
    if args.phase == "rtl" and artifact_root is not None:
        parser.error("RTL artifact progress is forbidden")
    if not cwd.is_dir() or args.timeout_seconds <= 0:
        raise RuntimeError("invalid working directory or timeout")
    if artifact_root is not None and not artifact_root.is_relative_to(cwd):
        raise RuntimeError("artifact progress root must be inside working directory")
    output.mkdir(parents=True, exist_ok=True)
    guard.OUT = output
    selected = sorted(os.sched_getaffinity(0))[:4]
    if len(selected) != 4 or guard.mem_available_kb() <= MIN_AVAILABLE_KB:
        raise RuntimeError("CPU affinity or MemAvailable preflight failed")
    wrapped = ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
               "/usr/bin/taskset", "-c", ",".join(map(str, selected)),
               *command]
    max_rss_kb = args.rss_gib * 1024 * 1024
    write_json(output / "guard_plan.json", {
        "at": now(), "cwd": str(cwd), "command": wrapped,
        "phase": args.phase,
        "semantic_policy": "strict checked-word highwater; no artifact or generic logs" if args.phase == "rtl" else "compile progress only; not numeric evidence",
        "selected_cpu_ids": selected, "sample_seconds": SAMPLE_SECONDS,
        "maximum_owned_rss_kb": max_rss_kb,
        "minimum_mem_available_kb": MIN_AVAILABLE_KB,
        "maximum_seconds": args.timeout_seconds,
        "semantic_stall_seconds": args.semantic_stall_seconds,
        "artifact_progress_root": (str(artifact_root)
                                   if artifact_root is not None else None),
        "artifact_sample_seconds": ARTIFACT_SAMPLE_SECONDS,
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
    split_highwater = None
    artifact_highwater = None
    artifact_next_sample = started
    semantic_pattern = re.compile(
        r"(?:ACT_(?:PRODUCTION|RTL)|TM4_REAL_PROGRESS|TM4_SYNC|MATRIX_PROGRESS|LNQ_WI_PROGRESS|PERSISTENT_CPU|FULL_CURRENT|Building CXX|Built target|TANH_(?:PROGRESS|PROFILE|BRANCH|LIBM)|FIXTURE_PASS|RNE_ZERO_DIRECTED_PASS|"
        r"STAGED_LN_PROGRESS|Finished|Start |completed|Complete|Analyzing|Compiling|Built simulation|"
        r"Processing|Initializing|DSP Report:|optimization accepted|Writing timing|"
        r"checkpoint.*generated|Analyzing design file)", re.IGNORECASE)
    if args.phase == "rtl":
        semantic_pattern = PARENT_PROGRESS
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
                        advanced, split_highwater = semantic_progress_advances(
                            line, split_highwater, args.phase)
                        if advanced:
                            semantic_last = current
                            semantic_line = line[:800]
                if artifact_root is not None and current >= artifact_next_sample:
                    artifact_next_sample = current + ARTIFACT_SAMPLE_SECONDS
                    artifact_work = artifact_progress_work(artifact_root)
                    advanced, artifact_highwater = artifact_progress_advances(
                        artifact_work, artifact_highwater)
                    if advanced:
                        semantic_last = current
                        semantic_line = ("artifact_work files="
                                         f"{artifact_highwater[0]} bytes="
                                         f"{artifact_highwater[1]}")
                if current >= semantic_next_record:
                    semantic_next_record = current + 60
                    with (output / "semantic_timeline.jsonl").open("a") as semantic:
                        semantic.write(json.dumps({"utc": now(),
                            "elapsed_seconds": current-started,
                            "owned_rss_kb": total,
                            "mem_available_kb": available,
                            "last_progress_line": semantic_line,
                            "seconds_since_progress": current-semantic_last,
                            "driver_offset": semantic_offset,
                            "artifact_highwater": artifact_highwater, "checked_highwater": split_highwater}) + "\n")
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
                    policy_key = str(pid) + ":" + str(item["start_time_ticks"])
                    if item["state"].startswith("Z") or \
                            not guard.still_owned(item):
                        continue
                    try:
                        affinity = sorted(os.sched_getaffinity(pid))
                        actual_nice = os.getpriority(os.PRIO_PROCESS, pid)
                        actual_ioprio = ctypes.CDLL(None, use_errno=True).syscall(252, 1, pid)
                        if actual_ioprio < 0:
                            raise ProcessLookupError("owned process exited during ioprio sample")
                    except (ProcessLookupError, FileNotFoundError, OSError):
                        continue
                    previous_policy = checked_policy.get(policy_key, {})
                    policy = {"pid": pid, "start_time_ticks": item["start_time_ticks"],
                              "pgid": item["pgid"], "checked_at": now(),
                              "first_checked_at": previous_policy.get("first_checked_at", now()),
                              "samples": previous_policy.get("samples", 0) + 1,
                              "command": item["command"],
                              "nice": actual_nice, "affinity": affinity,
                              "ioprio_encoded": actual_ioprio,
                              "ioprio_class": actual_ioprio >> 13,
                              "matches": actual_nice == 19 and
                                  bool(affinity) and
                                  set(affinity).issubset(selected) and
                                  actual_ioprio >> 13 == 3}
                    if not policy["matches"]:
                        latest = guard.process_table().get(pid)
                        if latest is None or latest["state"].startswith("Z") or \
                                not guard.still_owned(item):
                            continue
                    checked_policy[policy_key] = policy
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
                "semantic_phase": args.phase,
                "checked_highwater": split_highwater if args.phase == "rtl" else None,
                "last_progress_line": semantic_line,
                "artifact_progress_enabled": artifact_root is not None,
                "policy_identity_basis": "repeated actual syscall checks of observed owned pid/start_ticks; no leader inheritance inference",
                "observed_owned_identities": [{"pid": pid, "start_time_ticks": tick} for pid, tick in sorted(known.items())],
                "policy_checked_identities": [{"pid": row["pid"], "start_time_ticks": row["start_time_ticks"]} for row in checked_policy.values()],
            })
    return 0 if exit_code == 0 and trigger is None else 1


if __name__ == "__main__":
    raise SystemExit(main())
