#!/usr/bin/env python3
"""Owned-process SM009 guard: one project lock, CPU0..3, 120s and 16GiB RSS.

Each invocation creates a fresh AT directory. Receipts preserve all failures and
charge child wall time to the matching 600s reference_unit/compile budget.
"""
from __future__ import annotations
import argparse
import ctypes
from datetime import datetime, timezone
import fcntl
import hashlib
import json
import os
from pathlib import Path
import platform
import resource
import signal
import subprocess
import sys
import tarfile
import time

ROOT = Path(__file__).resolve().parents[5]
RUNS_BASE = ROOT / "project/E009_m007_host_tail_contract/experiment_results/runs"
BUDGETS = {"R001": {"reference_unit": 600, "compile": 600},
           "R002": {"reference_unit": 600, "compile": 900, "cpu_profile": 180}}
LOCK = ROOT / ".research-agent/m007_heavy.lock"


def utc():
    return datetime.now(timezone.utc).isoformat()


def memory_available():
    return int(next(line.split()[1] for line in Path("/proc/meminfo").read_text().splitlines()
                    if line.startswith("MemAvailable:"))) * 1024


def descendants(pid):
    result = [pid]
    try:
        for child in Path(f"/proc/{pid}/task/{pid}/children").read_text().split():
            result.extend(descendants(int(child)))
    except (FileNotFoundError, ProcessLookupError):
        pass
    return result


def rss_bytes(pid):
    total = 0
    for owned in descendants(pid):
        try:
            lines = Path(f"/proc/{owned}/status").read_text().splitlines()
            total += sum(int(line.split()[1]) * 1024 for line in lines if line.startswith("VmRSS:"))
        except (FileNotFoundError, ProcessLookupError):
            pass
    return total


def child_limits():
    os.setsid()
    os.sched_setaffinity(0, {0, 1, 2, 3})
    os.nice(19)
    resource.setrlimit(resource.RLIMIT_AS, (16 << 30, 16 << 30))
    # Linux ioprio_set(IOPRIO_WHO_PROCESS, 0, IOPRIO_CLASS_IDLE << 13).
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.syscall(251, 1, 0, 3 << 13) != 0:
        raise OSError(ctypes.get_errno(), "ioprio_set idle failed")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--run", choices=tuple(BUDGETS), default="R001")
    parser.add_argument("--phase", choices=("reference_unit", "compile", "cpu_profile"), required=True)
    parser.add_argument("--seconds", type=float, default=120)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if not args.attempt.startswith("AT") or "/" in args.attempt or not 0 < args.seconds <= 120:
        parser.error("fresh AT name and <=120s required")
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command:
        parser.error("command required")
    if args.phase not in BUDGETS[args.run]:
        parser.error("phase not authorized for selected run")
    RUNS = RUNS_BASE / args.run
    budget = BUDGETS[args.run][args.phase]
    RUNS.mkdir(parents=True, exist_ok=True)
    attempt = RUNS / args.attempt
    attempt.mkdir(exist_ok=False)
    receipt = {"schema": "m007-sm009-guard-v2", "run": args.run, "attempt": args.attempt,
               "phase_budget_s": budget,
               "phase": args.phase, "command": command, "cwd": str(Path.cwd()),
               "host": platform.node(), "python": platform.python_version(),
               "guard_started": utc(), "limit_s": args.seconds,
               "CPU_requested": [0, 1, 2, 3], "nice": 19, "io_priority": "idle",
               "RSS_limit_bytes": 16 << 30, "lock": str(LOCK),
               "status": "NOT_STARTED", "child_wall_s": 0.0, "exit_code": None}
    lock = LOCK.open("a+")
    fcntl.flock(lock, fcntl.LOCK_EX)
    receipt["lock_acquired"] = utc()
    try:
        spent = 0.0
        for old in RUNS.glob("AT*/receipt.json"):
            record = json.loads(old.read_text())
            if record.get("phase") == args.phase:
                spent += record.get("child_wall_s", 0)
        receipt["previous_phase_spent_s"] = spent
        if spent + args.seconds > budget:
            raise RuntimeError("requested limit exceeds remaining selected-run phase budget")
        receipt["MemAvailable_bytes"] = memory_available()
        if receipt["MemAvailable_bytes"] <= 192 << 30:
            raise RuntimeError("MemAvailable <=192 GiB")
        if not {0, 1, 2, 3} <= os.sched_getaffinity(0):
            raise RuntimeError("requested CPU0..3 unavailable")
        source_root = ROOT / "project/E002_Laya_HLS/experiment"
        paths = [*sorted((source_root / "host/m007_deploy").glob("*.py")),
                 *sorted((source_root / "host/m007_deploy").glob("*.cpp")),
                 *sorted((source_root / "host/m007_deploy").glob("*.json")),
                 *sorted((source_root / "host/m007_deploy").glob("*.h")),
                 *sorted((source_root / "host/m007_deploy").glob("*.sv")),
                 *sorted((source_root / "tests/m007_deploy").glob("*.py")),
                 *sorted((source_root / "tests/m007_deploy").glob("*.cpp")),
                 source_root / "tools/m007_deploy_identity.py",
                 source_root / "tests/full_reference.py"]
        receipt["source_sha256"] = {str(path.relative_to(source_root)):
            hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
        if args.run == "R002":
            snapshot = attempt / "owned_sources.tar.gz"
            with tarfile.open(snapshot, "w:gz") as archive:
                for path in paths:
                    archive.add(path, arcname=str(path.relative_to(source_root)), recursive=False)
            receipt["recoverable_owned_sources"] = {"path": str(snapshot),
                "sha256": hashlib.sha256(snapshot.read_bytes()).hexdigest(),
                "created_before_child": True}
        start = time.monotonic()
        receipt["child_started"] = utc()
        with (attempt / "stdout.log").open("wb") as out, (attempt / "stderr.log").open("wb") as err:
            child = subprocess.Popen(command, stdout=out, stderr=err, preexec_fn=child_limits,
                                     env=dict(os.environ, OPENBLAS_NUM_THREADS="1", OMP_NUM_THREADS="1",
                                              PYTHONDONTWRITEBYTECODE="1"))
            receipt["pid"] = child.pid
            receipt["actual_CPU_affinity"] = sorted(os.sched_getaffinity(child.pid))
            receipt["actual_nice"] = os.getpriority(os.PRIO_PROCESS, child.pid)
            receipt["actual_ioprio"] = ctypes.CDLL(None).syscall(252, 1, child.pid)
            receipt["status"] = "RUNNING"
            (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
            high = 0
            while child.poll() is None:
                high = max(high, rss_bytes(child.pid))
                if time.monotonic() - start >= args.seconds:
                    receipt["status"] = "COST_STOP"
                    os.killpg(child.pid, signal.SIGKILL)
                    break
                if high > 16 << 30:
                    receipt["status"] = "RSS_STOP"
                    os.killpg(child.pid, signal.SIGKILL)
                    break
                time.sleep(0.05)
            receipt["exit_code"] = child.wait()
            receipt["child_wall_s"] = time.monotonic() - start
            receipt["RSS_sampled_peak_bytes"] = high
            receipt["wait4_child_maxRSS_KiB"] = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
            if receipt["status"] == "RUNNING":
                receipt["status"] = "EXIT_ZERO" if child.returncode == 0 else "FAIL"
    except Exception as error:
        receipt["status"] = "INFRASTRUCTURE_FAILURE"
        receipt["error"] = f"{type(error).__name__}: {error}"
    finally:
        receipt["guard_finished"] = utc()
        (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
        fcntl.flock(lock, fcntl.LOCK_UN)
        lock.close()
    print(json.dumps(receipt, indent=2))
    return 0 if receipt["status"] == "EXIT_ZERO" else 1


if __name__ == "__main__":
    raise SystemExit(main())
