#!/usr/bin/env python3
"""Owned-process discovery and termination helpers for guarded HLS jobs."""

import datetime as dt
import json
import os
from pathlib import Path
import signal
import subprocess


OUT = Path(__file__).resolve().parent


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
        try:
            pid, ppid, pgid, rss = map(int, (pid, ppid, pgid, rss))
        except ValueError:
            # A process can disappear while ps reads it; do not abort the guard.
            continue
        try:
            nice = int(nice)
        except ValueError:
            # Kernel threads may report '-' here. Owned HLS tasks still need 19.
            nice = None
        table[pid] = {"pid": pid, "ppid": ppid,
                      "pgid": pgid, "rss_kb": rss,
                      "nice": nice, "state": state,
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
            stat = Path(f"/proc/{pid}/stat").read_text()
            if stat[stat.rfind(")") + 2:].split()[0] == "Z":
                continue
            if os.getpgid(pid) == leader and os.getsid(pid) == leader:
                return True
        except (FileNotFoundError, ProcessLookupError, IndexError):
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
