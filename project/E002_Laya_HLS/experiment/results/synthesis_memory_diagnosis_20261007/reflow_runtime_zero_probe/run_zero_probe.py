#!/usr/bin/env python3
"""Run one modified copied bitcode through original reflow with a strict guard."""

import csv
import datetime as dt
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import resource
import signal
import subprocess
import time


OUT = Path(__file__).resolve().parent
BUILD = OUT.parents[2] / "build/diagnosis-reflow-runtime-zero-20261007"
MIN_AVAILABLE_KB = 192 * 1024 * 1024
HARD_RSS_KB = 8 * 1024 * 1024
SAMPLE_SECONDS = 0.2
MAX_SECONDS = 15 * 60
PASS_ENTER = b"Executing Pass 'Generate HLS compatible IR'"
PASS_DONE = (b"Made Modification 'Generate HLS compatible IR'",
             b"Freeing Pass 'Generate HLS compatible IR'")

spec = importlib.util.spec_from_file_location("guard_helpers", OUT / "guard_helpers.py")
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def save(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def main():
    setup = json.loads((OUT / "cc1_argv.json").read_text())
    argv = setup["argv"]
    bitcode = BUILD / "db/a.g.ld.5.gdce.bc"
    if argv[-1] != str(bitcode) or not bitcode.is_file():
        raise RuntimeError("altered bitcode path mismatch")
    actual_hash = hashlib.sha256(bitcode.read_bytes()).hexdigest()
    if actual_hash != setup["modified_bitcode_sha256"]:
        raise RuntimeError("altered bitcode hash mismatch")
    if "full-hls-csynth-expanded-memory" in " ".join(argv):
        raise RuntimeError("production build path in cc1 argv")
    if guard.mem_available_kb() <= MIN_AVAILABLE_KB:
        raise RuntimeError("MemAvailable below 192 GiB floor")
    selected = sorted(os.sched_getaffinity(0))[:4]
    if len(selected) != 4:
        raise RuntimeError("fewer than four allowed CPUs")
    vitis = "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis"
    env = {key: os.environ[key] for key in
           ("PATH", "HOME", "USER", "LOGNAME", "LANG", "LC_ALL",
            "LC_CTYPE", "SHELL") if key in os.environ}
    env.update({"LD_LIBRARY_PATH": vitis + "/lib/lnx64.o:" +
                                  vitis + "/lnx64/tools/clang-3.9-csynth/lib",
                "OMP_NUM_THREADS": "2", "MKL_NUM_THREADS": "2",
                "OPENBLAS_NUM_THREADS": "2", "NUMEXPR_NUM_THREADS": "2"})
    command = ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
               "/usr/bin/taskset", "-c", ",".join(map(str, selected)), *argv]
    save("probe_plan.json", {
        "at": now(), "command": command, "cwd": str(BUILD),
        "modified_bitcode_sha256": actual_hash,
        "source_bitcode_sha256": setup["original_bitcode_sha256"],
        "selected_cpu_ids": selected, "sample_seconds": SAMPLE_SECONDS,
        "hard_rss_kb": HARD_RSS_KB,
        "minimum_available_kb": MIN_AVAILABLE_KB,
        "maximum_seconds": MAX_SECONDS,
        "scope": "one altered copied reflow cc1 only",
    })

    requested_term = False

    def on_term(signum, frame):
        nonlocal requested_term
        requested_term = True

    previous_term = signal.signal(signal.SIGTERM, on_term)
    child = None
    leader = None
    known = {}
    last_items = {}
    checked_policy = {}
    trigger = None
    peak_tree = 0
    peak_clang = 0
    min_available = guard.mem_available_kb()
    pass_entered = False
    pass_completed = False
    pass_entered_at = None
    pass_completed_at = None
    exit_code = None
    start = time.monotonic()
    log_offset = 0
    log_carry = b""

    def scan_log(log_reader):
        nonlocal log_offset, log_carry, pass_entered, pass_completed
        nonlocal pass_entered_at, pass_completed_at
        size = os.fstat(log_reader.fileno()).st_size
        while log_offset < size:
            count = min(4 * 1024 * 1024, size - log_offset)
            chunk = os.pread(log_reader.fileno(), count, log_offset)
            if not chunk:
                break
            log_offset += len(chunk)
            block = log_carry + chunk
            if not pass_entered and PASS_ENTER in block:
                pass_entered = True
                pass_entered_at = now()
            if pass_entered and any(marker in block for marker in PASS_DONE):
                pass_completed = True
                pass_completed_at = now()
            log_carry = block[-128:]

    try:
        with (OUT / "driver.log").open("wb") as driver, \
             (OUT / "driver.log").open("rb") as log_reader, \
             (OUT / "memory_timeline.csv").open("w", newline="") as timeline:
            writer = csv.writer(timeline)
            writer.writerow(("utc", "mem_available_kb", "owned_rss_kb",
                             "clang_rss_kb", "process_count", "largest_pid",
                             "largest_command"))
            timeline.flush()
            child = subprocess.Popen(command, cwd=BUILD, env=env,
                                     stdout=driver, stderr=subprocess.STDOUT,
                                     start_new_session=True)
            leader = child.pid
            tick = guard.process_start(leader)
            if tick is None or os.getpgid(leader) != leader or \
                    os.getsid(leader) != leader:
                child.kill()
                child.wait()
                raise RuntimeError("cc1 did not enter a unique owned session")
            known[leader] = tick
            save("launch.json", {"at": now(), "leader_pid": leader,
                                 "leader_start_time_ticks": tick,
                                 "process_group_id": leader,
                                 "session_id": leader})
            next_sample = time.monotonic()
            while child.poll() is None:
                current = time.monotonic()
                if current < next_sample:
                    time.sleep(min(next_sample - current, 0.05))
                    continue
                next_sample = current + SAMPLE_SECONDS
                available = guard.mem_available_kb()
                min_available = min(min_available, available)
                items = guard.owned_processes(guard.process_table(), leader,
                                               known)
                last_items = items
                total = sum(item["rss_kb"] for item in items.values())
                clang_rss = max((item["rss_kb"] for item in items.values()
                                 if item["command"] == "clang"), default=0)
                peak_tree = max(peak_tree, total)
                peak_clang = max(peak_clang, clang_rss)
                largest = max(items.values(), key=lambda x: x["rss_kb"],
                              default=None)
                writer.writerow((now(), available, total, clang_rss, len(items),
                                 largest["pid"] if largest else "",
                                 largest["command"] if largest else ""))
                timeline.flush()
                if requested_term:
                    trigger = {"at": now(), "reason": "sigterm_requested"}
                    break
                if available <= MIN_AVAILABLE_KB:
                    trigger = {"at": now(), "reason":
                               "mem_available_at_or_below_192_GiB"}
                    break
                if total >= HARD_RSS_KB:
                    trigger = {"at": now(), "reason":
                               "owned_rss_at_or_above_8_GiB"}
                    break
                if current - start >= MAX_SECONDS:
                    trigger = {"at": now(), "reason": "wall_time_at_or_above_15m"}
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
                    checked_policy[pid] = policy
                    save("policy_checks.json", list(checked_policy.values()))
                    if not policy["matches"]:
                        trigger = {"at": now(), "reason":
                                   "owned_process_policy_mismatch",
                                   "policy": policy}
                        break
                if trigger is not None:
                    break
                scan_log(log_reader)
                if pass_completed:
                    trigger = {"at": now(), "reason": "hlsgen_pass_completed"}
                    break
            if trigger is None and child.poll() is not None:
                scan_log(log_reader)
                trigger = {"at": now(), "reason": "cc1_exited"}
            if trigger is not None and trigger["reason"] != "cc1_exited":
                trigger.update({"leader_pid": leader,
                                "process_group_id": leader,
                                "peak_owned_rss_kb": peak_tree,
                                "peak_clang_rss_kb": peak_clang,
                                "mem_available_kb": min_available,
                                "hlsgen_entered": pass_entered,
                                "hlsgen_completed": pass_completed})
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
                                            "reason": "orphaned_probe",
                                            "leader_pid": leader,
                                            "process_group_id": leader}
                    guard.stop_and_kill(leader, known, remaining, emergency)
            if child is not None and child.poll() is None:
                child.kill()
                child.wait(timeout=30)
        finally:
            signal.signal(signal.SIGTERM, previous_term)
            save("probe_result.json", {
                "finished_at": now(), "cc1_exit_code": exit_code,
                "trigger": trigger["reason"] if trigger else None,
                "peak_owned_rss_kb": peak_tree,
                "peak_clang_rss_kb": peak_clang,
                "minimum_mem_available_kb": min_available,
                "hlsgen_entered": pass_entered,
                "hlsgen_entered_at": pass_entered_at,
                "hlsgen_completed": pass_completed,
                "hlsgen_completed_at": pass_completed_at,
                "elapsed_seconds": time.monotonic() - start,
                "child_rusage_maxrss_kb":
                    resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
            })


if __name__ == "__main__":
    main()
