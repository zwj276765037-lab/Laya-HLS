#!/usr/bin/env python3
"""Run one frozen full-top synthesis in its own session with bounded memory."""

import csv
import datetime as dt
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
BUILD = ROOT / "build/full-hls-csynth-expanded-memory-20261007T071141Z"
MODEL = ROOT / "build/model-p2-final"
BASELINE_HASHES = (ROOT / "results/engineering_p2/"
                   "csynth_array_f0_final_20261007/input_hashes.sha256")
MIN_AVAILABLE_KB = 64 * 1024 * 1024
MAX_TREE_RSS_KB = 380 * 1024 * 1024


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def write_json(name: str, value: object) -> None:
    (OUT / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def mem_available_kb() -> int:
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1])
    raise RuntimeError("MemAvailable missing")


def process_start(pid: int) -> int | None:
    try:
        stat = Path(f"/proc/{pid}/stat").read_text()
        return int(stat[stat.rfind(")") + 2:].split()[19])
    except (FileNotFoundError, ProcessLookupError, ValueError, IndexError):
        return None


def process_table() -> dict[int, dict]:
    output = subprocess.check_output(
        ["/usr/bin/ps", "-eo", "pid=,ppid=,pgid=,rss=,ni=,stat=,comm="],
        text=True)
    table = {}
    for line in output.splitlines():
        parts = line.split(maxsplit=6)
        if len(parts) != 7:
            continue
        pid, ppid, pgid, rss, nice, state, command = parts
        table[int(pid)] = {"pid": int(pid), "ppid": int(ppid),
                           "pgid": int(pgid), "rss_kb": int(rss),
                           "nice": int(nice), "state": state,
                           "command": command}
    return table


def owned_processes(table: dict[int, dict], leader: int,
                    known: dict[int, int]) -> dict[int, dict]:
    def accept(pid: int) -> bool:
        tick = process_start(pid)
        if tick is None or (pid in known and known[pid] != tick):
            return False
        known[pid] = tick
        return True

    # Known descendants remain ours after reparenting; a reused PID does not.
    owned = {pid for pid, tick in known.items()
             if pid in table and tick is not None and process_start(pid) == tick}
    if any(table[pid]["pgid"] == leader for pid in owned):
        owned.update(pid for pid, item in table.items()
                     if item["pgid"] == leader and accept(pid))
    changed = True
    while changed:
        size = len(owned)
        owned.update(pid for pid, item in table.items()
                     if item["ppid"] in owned and accept(pid))
        changed = len(owned) != size
    result = {}
    for pid in owned:
        if pid in table:
            item = dict(table[pid])
            item["start_time_ticks"] = known[pid]
            result[pid] = item
    return result


def still_owned(item: dict) -> bool:
    tick = item.get("start_time_ticks")
    return tick is not None and process_start(item["pid"]) == tick


def verified_group(leader: int, known: dict[int, int]) -> bool:
    for pid, tick in known.items():
        if tick is None or process_start(pid) != tick:
            continue
        try:
            if os.getpgid(pid) == leader and os.getsid(pid) == leader:
                return True
        except ProcessLookupError:
            pass
    return False


def policy_sample(items: dict[int, dict], selected: list[int]) -> dict:
    sample = {"at": now(), "selected_affinity": selected, "processes": []}
    for item in items.values():
        if item["command"] not in ("v++", "vitis_hls", "clang", "bash"):
            continue
        if not still_owned(item):
            continue
        pid = item["pid"]
        try:
            affinity = sorted(os.sched_getaffinity(pid))
            ionice = subprocess.run(
                ["/usr/bin/ionice", "-p", str(pid)], capture_output=True,
                text=True, timeout=5)
            sample["processes"].append({
                **item, "affinity": affinity,
                "ionice": (ionice.stdout or ionice.stderr).strip(),
                "ionice_exit": ionice.returncode,
                "nice_matches": item["nice"] == 19,
                "affinity_matches": bool(affinity) and
                    set(affinity).issubset(selected),
                "ionice_matches": ionice.returncode == 0 and
                    "idle" in (ionice.stdout or ionice.stderr).lower()})
        except (FileNotFoundError, ProcessLookupError, OSError,
                subprocess.TimeoutExpired):
            continue
    return sample


def log_tail(path: Path) -> list[str]:
    with path.open("rb") as stream:
        size = stream.seek(0, 2)
        stream.seek(max(0, size - 65536))
        return stream.read().decode("utf-8", errors="replace").splitlines()[-25:]


def stop_and_kill(leader: int, known: dict[int, int],
                  items: dict[int, dict], reason: dict) -> None:
    # The child was created with start_new_session=True, so this process group
    # contains only this synthesis and its descendants. Stop first to make the
    # diagnostic snapshot stable, then kill; TERM would leave stopped jobs hung.
    snapshot = dict(items)
    try:
        if verified_group(leader, known):
            try:
                os.killpg(leader, signal.SIGSTOP)
            except ProcessLookupError:
                pass
        for item in items.values():
            if item["pgid"] != leader and still_owned(item):
                try:
                    os.kill(item["pid"], signal.SIGSTOP)
                except ProcessLookupError:
                    pass
        try:
            snapshot = owned_processes(process_table(), leader, known)
        except Exception as exc:
            reason["snapshot_error"] = repr(exc)
        reason["snapshot_count"] = len(snapshot)
        reason["snapshot"] = list(snapshot.values())[:128]
        for name in ("csynth.log", "driver.log"):
            path = OUT / name
            if path.exists():
                reason[name + "_tail"] = log_tail(path)
        write_json("guard_trigger.json", reason)
    finally:
        # Diagnostics may fail (including a full disk); task termination must
        # still proceed. Every PID is checked against its saved start time.
        for item in list(snapshot.values()) + list(items.values()):
            if item["pgid"] != leader and still_owned(item):
                try:
                    os.kill(item["pid"], signal.SIGKILL)
                except ProcessLookupError:
                    pass
        if verified_group(leader, known):
            try:
                os.killpg(leader, signal.SIGKILL)
            except ProcessLookupError:
                pass


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    BUILD.mkdir(parents=True, exist_ok=True)
    selected = sorted(os.sched_getaffinity(0))[:4]
    if len(selected) != 4:
        raise RuntimeError("fewer than four allowed logical CPUs")
    if mem_available_kb() <= MIN_AVAILABLE_KB:
        raise RuntimeError("prelaunch MemAvailable at or below 64 GiB floor")
    with (OUT / "baseline_hash_check.log").open("w") as stream:
        verified = subprocess.run(["sha256sum", "-c", str(BASELINE_HASHES)],
                                  cwd=ROOT, stdout=stream,
                                  stderr=subprocess.STDOUT)
    if verified.returncode:
        raise RuntimeError("frozen prior inputs no longer match")
    manifest = json.loads((MODEL / "manifest.json").read_text())
    if manifest["tags"]["build"] != "4f12ecfe940ecf2a8998a8626fc1ed1c":
        raise RuntimeError("frozen build tag changed")
    env = {key: os.environ[key] for key in
           ("PATH", "HOME", "USER", "LOGNAME", "LANG", "LC_ALL",
            "LC_CTYPE", "SHELL") if key in os.environ}
    env.update({"LAYA_FULL_MODEL_DIR": str(MODEL),
                "LAYA_FULL_HLS_BUILD": str(BUILD),
                "LAYA_FULL_HLS_RESULTS": str(OUT),
                "LAYA_FULL_PART": "xcu55c-fsvh2892-2L-e",
                "LAYA_GUARD_CPU_IDS": ",".join(map(str, selected)),
                "OMP_NUM_THREADS": "2", "MKL_NUM_THREADS": "2",
                "OPENBLAS_NUM_THREADS": "2", "NUMEXPR_NUM_THREADS": "2"})
    command = ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
               "/usr/bin/taskset", "-c", ",".join(map(str, selected)),
               sys.executable, str(OUT / "priority_exec.py"),
               str(ROOT / "scripts/run_full_hls.sh"), "--csynth"]
    write_json("wrapper_plan.json", {
        "at": now(), "cwd": str(ROOT), "command": command,
        "environment": env, "allowed_cpu_count": len(os.sched_getaffinity(0)),
        "selected_cpu_ids": selected, "sample_interval_seconds": 2,
        "minimum_mem_available_kb": MIN_AVAILABLE_KB,
        "maximum_task_tree_rss_kb": MAX_TREE_RSS_KB,
        "baseline_hashes": str(BASELINE_HASHES),
        "baseline_hash_check_exit": verified.returncode,
        "build_tag": manifest["tags"]["build"]})
    trigger = None
    peak_rss = 0
    peak_largest_rss = 0
    minimum_available = mem_available_kb()
    if minimum_available <= MIN_AVAILABLE_KB:
        raise RuntimeError("prelaunch MemAvailable fell to 64 GiB floor")
    child = None
    leader = None
    known: dict[int, int] = {}
    last_items: dict[int, dict] = {}
    try:
        with (OUT / "driver.log").open("w") as driver, \
             (OUT / "memory_timeline.csv").open("w", newline="") as timeline, \
             (OUT / "policy_samples.jsonl").open("w") as policy:
            writer = csv.writer(timeline)
            writer.writerow(("utc", "mem_available_kb", "tree_rss_kb",
                             "process_count", "largest_pid", "largest_rss_kb",
                             "largest_command"))
            timeline.flush()
            child = subprocess.Popen(command, cwd=ROOT, env=env, stdout=driver,
                                     stderr=subprocess.STDOUT,
                                     start_new_session=True)
            leader = child.pid
            leader_start = process_start(leader)
            if leader_start is None or os.getpgid(leader) != leader or \
                    os.getsid(leader) != leader:
                child.kill()
                child.wait()
                raise RuntimeError("task did not enter verified unique session")
            known[leader] = leader_start
            write_json("launch.json", {"at": now(), "leader_pid": leader,
                                       "leader_start_time_ticks": leader_start,
                                       "process_group_id": leader,
                                       "session_id": leader,
                                       "command": command})
            last_policy = 0.0
            while child.poll() is None:
                try:
                    available = mem_available_kb()
                    minimum_available = min(minimum_available, available)
                    if available <= MIN_AVAILABLE_KB:
                        trigger = {"at": now(), "reason":
                                   "mem_available_at_or_below_64_GiB",
                                   "mem_available_kb": available,
                                   "task_tree_rss_kb_last_sample":
                                       sum(item["rss_kb"] for item in
                                           last_items.values()),
                                   "leader_pid": leader,
                                   "process_group_id": leader}
                        stop_and_kill(leader, known, last_items, trigger)
                        break
                    table = process_table()
                    items = owned_processes(table, leader, known)
                    last_items = items
                    total_rss = sum(item["rss_kb"] for item in items.values())
                    peak_rss = max(peak_rss, total_rss)
                    largest = max(items.values(),
                                  key=lambda item: item["rss_kb"],
                                  default=None)
                    if largest:
                        peak_largest_rss = max(peak_largest_rss,
                                               largest["rss_kb"])
                    writer.writerow((now(), available, total_rss, len(items),
                                     largest["pid"] if largest else "",
                                     largest["rss_kb"] if largest else "",
                                     largest["command"] if largest else ""))
                    timeline.flush()
                    if total_rss >= MAX_TREE_RSS_KB:
                        trigger = {"at": now(), "reason":
                                   "task_tree_rss_at_or_above_380_GiB",
                                   "mem_available_kb": available,
                                   "task_tree_rss_kb": total_rss,
                                   "leader_pid": leader,
                                   "process_group_id": leader}
                        stop_and_kill(leader, known, items, trigger)
                        break
                    if time.monotonic() - last_policy >= 60:
                        one_policy = policy_sample(items, selected)
                        policy.write(json.dumps(one_policy) + "\n")
                        policy.flush()
                        last_policy = time.monotonic()
                        bad_policy = [item for item in one_policy["processes"]
                                      if not (item["nice_matches"] and
                                              item["affinity_matches"] and
                                              item["ionice_matches"])]
                        if bad_policy:
                            trigger = {"at": now(), "reason":
                                       "task_priority_policy_violation",
                                       "violations": bad_policy,
                                       "leader_pid": leader,
                                       "process_group_id": leader}
                            stop_and_kill(leader, known, items, trigger)
                            break
                except BaseException as exc:
                    if trigger is None:
                        trigger = {"at": now(), "reason": "monitor_failure",
                                   "error": repr(exc), "leader_pid": leader,
                                   "process_group_id": leader}
                    stop_and_kill(leader, known, last_items, trigger)
                    break
                time.sleep(2)
            try:
                exit_code = child.wait(timeout=30 if trigger else None)
            except subprocess.TimeoutExpired:
                stop_and_kill(leader, known, last_items,
                              {"at": now(), "reason":
                               "post_guard_task_not_exited"})
                exit_code = child.wait()
    finally:
        # Covers exceptions and interruptions outside the monitor loop too.
        if child is not None and child.poll() is None and leader is not None:
            emergency = {"at": now(), "reason": "wrapper_unexpected_exit",
                         "leader_pid": leader, "process_group_id": leader}
            try:
                stop_and_kill(leader, known, last_items, emergency)
            finally:
                child.wait()
    write_json("wrapper_result.json", {
        "finished_at": now(), "exit_code": exit_code,
        "guard_triggered": trigger is not None,
        "guard_reason": trigger["reason"] if trigger else None,
        "outcome": "memory_or_policy_guard" if trigger else
                   "success" if exit_code == 0 else "tool_failure",
        "peak_task_tree_rss_kb": peak_rss,
        "peak_largest_process_rss_kb": peak_largest_rss,
        "minimum_mem_available_kb": minimum_available,
        "csynth_exit_file": (OUT / "csynth.exit").read_text().strip()
        if (OUT / "csynth.exit").exists() else None})
    return 0 if exit_code == 0 and trigger is None else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        write_json("wrapper_error.json", {"at": now(), "error": repr(exc)})
        raise
