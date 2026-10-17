#!/usr/bin/env python3
"""One-use controller for the independently released finite Scorer XSim run."""

import csv
import datetime as dt
import hashlib
import json
from pathlib import Path
import re
import signal
import subprocess
import time


RELEASE = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v6_finite_runtime_release.json")
RELEASE_SHA256 = "c10b29f150956744738f59bee8e7f70ea79b2c20d18da4b3b465761a815e0a89"
RUN = Path(__file__).resolve().parent
PROGRESS = RUN / "runtime/progress.log"
GUARD = RUN / "rtl_guard_v5"
MONITOR = RUN / "rtl_v5_progress_monitor.jsonl"
EXIT = RUN / "rtl_v5_guard_driver_exit.json"
RX = re.compile(r"Q8_SCORER_PROGRESS cmd=(\d+) total_clock=(\d+) command_clock=(\d+)")


def utc() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def last_rss_kb() -> int | None:
    path = GUARD / "memory_timeline.csv"
    if not path.exists():
        return None
    rows = list(csv.DictReader(path.open()))
    return int(rows[-1]["owned_rss_kb"]) if rows else None


def records() -> list[tuple[int, int, int]]:
    if not PROGRESS.exists():
        return []
    return [tuple(map(int, m.groups())) for line in PROGRESS.read_text(errors="replace").splitlines()
            if (m := RX.search(line))]


def main() -> int:
    if hashlib.sha256(RELEASE.read_bytes()).hexdigest() != RELEASE_SHA256:
        raise RuntimeError("finite runtime release identity mismatch")
    release = json.loads(RELEASE.read_text())
    command = release["single_use_runtime"]["command"]
    argv, cwd = command["argv"], command["cwd"]
    if GUARD.exists() or MONITOR.exists() or EXIT.exists() or (RUN / "runtime/xsim.log").exists():
        raise RuntimeError("this single-use runtime has already started")
    if json.loads((RUN / "rtl_v5_binding_pre_exit.json").read_text())["exit_code"] != 0:
        raise RuntimeError("pre-binding did not pass")
    start = utc()
    monitor_reason = None
    first_record = None
    first_advancing_at = None
    last_progress_at = None
    last_tuple = None
    milestone_reported = False
    last_emit = 0.0
    with (RUN / "rtl_v5_guard_driver.stdout").open("xb") as stdout, \
         (RUN / "rtl_v5_guard_driver.stderr").open("xb") as stderr, \
         MONITOR.open("x") as log:
        proc = subprocess.Popen(argv, cwd=cwd, stdout=stdout, stderr=stderr)
        print(f"RUNTIME_GUARD_STARTED pid={proc.pid} utc={start}", flush=True)
        while proc.poll() is None:
            time.sleep(10)
            now = dt.datetime.now(dt.timezone.utc)
            launch_path = GUARD / "launch.json"
            launch = json.loads(launch_path.read_text()) if launch_path.exists() else None
            elapsed = (now - dt.datetime.fromisoformat(launch["at"])).total_seconds() if launch else 0.0
            current = records()
            if current:
                if first_record is None:
                    first_record = current[0]
                    last_progress_at = time.monotonic()
                latest = current[-1]
                if latest != last_tuple:
                    if last_tuple is not None and (latest[1] > last_tuple[1] or latest[0] > last_tuple[0]):
                        if first_advancing_at is None:
                            first_advancing_at = time.monotonic()
                        last_progress_at = time.monotonic()
                    last_tuple = latest
            rss = last_rss_kb()
            if not milestone_reported and (any(c == 0 and cc >= 131072 for c, _, cc in current) or any(c > 0 for c, _, _ in current)):
                milestone_reported = True
                clock = next(((c, tc, cc) for c, tc, cc in current if c == 0 and cc >= 131072), current[-1])
                rate = round(clock[2] / elapsed, 2) if elapsed > 0 and clock[0] == 0 else None
                print(f"FIRST_131072_OR_LATER utc={utc()} elapsed_s={elapsed:.1f} clock={clock} clock_per_s={rate} owned_rss_kb={rss}", flush=True)
            if launch and elapsed >= 120 and not current:
                monitor_reason = "no_initial_progress_by_120s"
            elif launch and elapsed >= 300 and not milestone_reported:
                monitor_reason = "no_131072_or_command_completion_by_300s"
            elif first_advancing_at is not None and last_progress_at is not None and time.monotonic() - last_progress_at > 240:
                monitor_reason = "no_clock_or_command_advance_for_240s"
            if time.monotonic() - last_emit >= 30 or monitor_reason:
                entry = {"utc": utc(), "runtime_child_elapsed_seconds": round(elapsed, 2),
                         "latest_progress": current[-1] if current else None,
                         "progress_records": len(current), "owned_rss_kb": rss,
                         "guard_pid": proc.pid, "monitor_reason": monitor_reason}
                log.write(json.dumps(entry, sort_keys=True) + "\n")
                log.flush()
                print("RUNTIME_MONITOR " + json.dumps(entry, sort_keys=True), flush=True)
                last_emit = time.monotonic()
            if monitor_reason:
                # The guard catches SIGTERM and stops its verified owned XSim tree.
                proc.send_signal(signal.SIGTERM)
                break
        code = proc.wait(timeout=90)
    result = {"stage": "rtl_first_three_commands", "release": str(RELEASE),
              "release_sha256": RELEASE_SHA256, "argv": argv, "cwd": cwd,
              "start_utc": start, "end_utc": utc(), "exit_code": code,
              "monitor_reason": monitor_reason, "first_progress": first_record,
              "last_progress": last_tuple, "milestone_reported": milestone_reported}
    EXIT.write_text(json.dumps(result, indent=2) + "\n")
    print("RUNTIME_GUARD_EXIT " + json.dumps({"exit_code": code, "monitor_reason": monitor_reason,
                                         "last_progress": last_tuple}, sort_keys=True), flush=True)
    return 0 if code == 0 and monitor_reason is None else 1


if __name__ == "__main__":
    raise SystemExit(main())
