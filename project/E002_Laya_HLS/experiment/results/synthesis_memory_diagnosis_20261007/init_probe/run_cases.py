#!/usr/bin/env python3
"""Run the reviewed four-case initializer contrast under the owned-tree guard."""

import csv
import datetime as dt
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import time


OUT = Path(__file__).resolve().parent
SOURCE = OUT / "init_probe.cpp"
VPP = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++")
PART = "xcu55c-fsvh2892-2L-e"
MIN_AVAILABLE_KB = 192 * 1024 * 1024
HARD_RSS_KB = 8 * 1024 * 1024
SIGNIFICANT_RSS_KB = 4 * 1024 * 1024
MAX_SECONDS = 20 * 60
SAMPLE_SECONDS = 0.1

spec = importlib.util.spec_from_file_location("guard_helpers", OUT / "guard_helpers.py")
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def save(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def make_config(case_dir, n, flag):
    config = case_dir / "init_probe.cfg"
    config.write_text("\n".join((
        f"part={PART}", "freqhz=150000000", "[hls]",
        "flow_target=vivado", "syn.top=init_probe_top",
        "syn.compile.pipeline_loops=0",
        "syn.array_partition.throughput_driven=off",
        "syn.array_partition.complete_threshold=0",
        f"syn.file={SOURCE}",
        f"syn.cflags=-DN={n} -DINITIAL_FLAG={flag} -std=c++17",
    )) + "\n")
    return config


def run_case(n, flag, selected, source_sha256, env, stop_requested):
    case_dir = OUT / f"n{n}_flag{flag}"
    case_dir.mkdir(exist_ok=True)
    guard.OUT = case_dir
    config = make_config(case_dir, n, flag)
    command = ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
               "/usr/bin/taskset", "-c", ",".join(map(str, selected)),
               str(VPP), "--compile", "--mode", "hls",
               "--config", str(config), "--work_dir", str(case_dir / "work")]
    save(case_dir / "plan.json", {
        "at": now(), "command": command, "cwd": str(case_dir),
        "source_sha256": source_sha256, "n": n, "initial_flag": flag,
        "part": PART, "frequency_hz": 150000000,
        "selected_cpu_ids": selected, "hard_rss_kb": HARD_RSS_KB,
        "minimum_available_kb": MIN_AVAILABLE_KB,
        "maximum_seconds": MAX_SECONDS,
    })
    known = {}
    last_items = {}
    checked_policy = {}
    child = None
    leader = None
    trigger = None
    peak = 0
    peak_clang = 0
    min_available = guard.mem_available_kb()
    began = time.monotonic()
    exit_code = None
    try:
        if min_available <= MIN_AVAILABLE_KB:
            raise RuntimeError("MemAvailable at or below 192 GiB before launch")
        with (case_dir / "driver.log").open("w") as driver, \
             (case_dir / "memory_timeline.csv").open("w", newline="") as timeline:
            writer = csv.writer(timeline)
            writer.writerow(("utc", "mem_available_kb", "owned_rss_kb",
                             "process_count", "largest_pid", "largest_rss_kb",
                             "largest_command", "clang_pid", "clang_rss_kb"))
            timeline.flush()
            child = subprocess.Popen(command, cwd=case_dir, env=env,
                                     stdout=driver, stderr=subprocess.STDOUT,
                                     start_new_session=True)
            leader = child.pid
            tick = guard.process_start(leader)
            if tick is None or os.getpgid(leader) != leader or \
                    os.getsid(leader) != leader:
                child.kill()
                child.wait()
                raise RuntimeError("case did not enter unique owned session")
            known[leader] = tick
            save(case_dir / "launch.json", {
                "at": now(), "leader_pid": leader,
                "leader_start_time_ticks": tick,
                "process_group_id": leader, "session_id": leader,
            })
            while child.poll() is None:
                if stop_requested():
                    trigger = {"at": now(), "reason": "sigterm_requested"}
                    break
                available = guard.mem_available_kb()
                min_available = min(min_available, available)
                items = guard.owned_processes(guard.process_table(), leader,
                                               known)
                last_items = items
                total = sum(item["rss_kb"] for item in items.values())
                peak = max(peak, total)
                largest = max(items.values(), key=lambda x: x["rss_kb"],
                              default=None)
                clang = max((item for item in items.values()
                             if item["command"] == "clang"),
                            key=lambda x: x["rss_kb"], default=None)
                peak_clang = max(peak_clang,
                                 clang["rss_kb"] if clang else 0)
                writer.writerow((now(), available, total, len(items),
                                 largest["pid"] if largest else "",
                                 largest["rss_kb"] if largest else "",
                                 largest["command"] if largest else "",
                                 clang["pid"] if clang else "",
                                 clang["rss_kb"] if clang else ""))
                timeline.flush()
                if available <= MIN_AVAILABLE_KB:
                    trigger = {"at": now(), "reason":
                               "mem_available_at_or_below_192_GiB"}
                    break
                if total >= HARD_RSS_KB:
                    trigger = {"at": now(), "reason":
                               "owned_rss_at_or_above_8_GiB"}
                    break
                if time.monotonic() - began >= MAX_SECONDS:
                    trigger = {"at": now(), "reason": "wall_time_at_or_above_20m"}
                    break
                for item in items.values():
                    pid = item["pid"]
                    if pid in checked_policy or not guard.still_owned(item):
                        continue
                    try:
                        affinity = sorted(os.sched_getaffinity(pid))
                        ionice = subprocess.run(
                            ["/usr/bin/ionice", "-p", str(pid)],
                            capture_output=True, text=True, timeout=5)
                    except (ProcessLookupError, FileNotFoundError,
                            subprocess.TimeoutExpired):
                        continue
                    policy = {
                        "pid": pid, "command": item["command"],
                        "nice": item["nice"], "affinity": affinity,
                        "ionice": (ionice.stdout or ionice.stderr).strip(),
                        "ionice_exit": ionice.returncode,
                        "matches": item["nice"] == 19 and bool(affinity) and
                            set(affinity).issubset(selected) and
                            ionice.returncode == 0 and
                            "idle" in (ionice.stdout or ionice.stderr).lower(),
                    }
                    checked_policy[pid] = policy
                    save(case_dir / "policy_checks.json",
                         list(checked_policy.values()))
                    if not policy["matches"]:
                        trigger = {"at": now(), "reason":
                                   "owned_process_policy_mismatch",
                                   "policy": policy}
                        break
                if trigger is not None:
                    break
                time.sleep(SAMPLE_SECONDS)
            if trigger is not None:
                trigger.update({"leader_pid": leader,
                                "process_group_id": leader,
                                "mem_available_kb": min_available,
                                "peak_owned_rss_kb": peak})
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
                                            "reason": "orphaned_case",
                                            "leader_pid": leader,
                                            "process_group_id": leader}
                    guard.stop_and_kill(leader, known, remaining, emergency)
            if child is not None and child.poll() is None:
                child.kill()
                child.wait(timeout=30)
        finally:
            result = {
                "finished_at": now(), "n": n, "initial_flag": flag,
                "exit_code": exit_code, "trigger": trigger["reason"]
                if trigger else None,
                "peak_owned_rss_kb": peak,
                "peak_clang_rss_kb": peak_clang,
                "minimum_mem_available_kb": min_available,
                "elapsed_seconds": time.monotonic() - began,
            }
            save(case_dir / "result.json", result)
    return result


def main():
    if not VPP.is_file() or not SOURCE.is_file():
        raise RuntimeError("Vitis or experiment source missing")
    selected = sorted(os.sched_getaffinity(0))[:4]
    if len(selected) != 4:
        raise RuntimeError("fewer than four allowed CPUs")
    source_sha256 = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
    env = {key: os.environ[key] for key in
           ("PATH", "HOME", "USER", "LOGNAME", "LANG", "LC_ALL",
            "LC_CTYPE", "SHELL") if key in os.environ}
    env.update({"OMP_NUM_THREADS": "2", "MKL_NUM_THREADS": "2",
                "OPENBLAS_NUM_THREADS": "2", "NUMEXPR_NUM_THREADS": "2"})
    requested_term = False

    def on_term(signum, frame):
        nonlocal requested_term
        requested_term = True

    previous = signal.signal(signal.SIGTERM, on_term)
    try:
        stop_larger = False
        results = []
        for n in (4096, 16384):
            if stop_larger:
                break
            for flag in (0, 1):
                result = run_case(n, flag, selected, source_sha256,
                                  env, lambda: requested_term)
                results.append(result)
                save(OUT / "results.json", results)
                print(json.dumps(result, sort_keys=True), flush=True)
                if result["trigger"] or result["exit_code"] != 0:
                    return 1
                if result["peak_owned_rss_kb"] >= SIGNIFICANT_RSS_KB:
                    stop_larger = True
        return 0
    finally:
        signal.signal(signal.SIGTERM, previous)


if __name__ == "__main__":
    raise SystemExit(main())
