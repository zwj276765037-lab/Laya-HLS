#!/usr/bin/env python3
"""Measure large bit concatenation operands in one bounded reflow replay."""

import csv
import datetime as dt
import importlib.util
import json
import os
from pathlib import Path
import re
import selectors
import signal
import subprocess
import time


OUT = Path(__file__).resolve().parent
BUILD = OUT.parents[2] / "build/diagnosis-reflow-width-probe-20261007"
MIN_AVAILABLE_KB = 192 * 1024 * 1024
HARD_RSS_KB = 8 * 1024 * 1024
SAMPLE_SECONDS = 1.0
HLSGEN_ENTRY = "*0x23b0ea0"
BITCONCAT_ENTRY = "*0x14b0da0"
OFFSET_CALL = "*0x14b0edc"
MIN_WIDTH_BITS = 1_048_576
RUNTIME_CANDIDATE_BITS = 50_000_000
MAX_BIG_ENTRIES = 3

spec = importlib.util.spec_from_file_location("guard_helpers", OUT / "guard_helpers.py")
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def save(name, obj):
    (OUT / name).write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n")


def main():
    source = json.loads((OUT / "cc1_argv.json").read_text())
    cc1 = source["argv"]
    if source["source_db"] in " ".join(cc1):
        raise RuntimeError("source build path remains in replay argv")
    if str(BUILD / "db/a.g.ld.5.gdce.bc") != cc1[-1]:
        raise RuntimeError("diagnosis bitcode path mismatch")
    if not (BUILD / "db/a.g.ld.5.gdce.bc").is_file():
        raise RuntimeError("copied bitcode missing")
    if guard.mem_available_kb() <= MIN_AVAILABLE_KB:
        raise RuntimeError("prelaunch memory below 192 GiB floor")
    selected = sorted(os.sched_getaffinity(0))[:4]
    if len(selected) != 4:
        raise RuntimeError("fewer than four allowed CPUs")

    vitis = "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis"
    env = {key: os.environ[key] for key in
           ("PATH", "HOME", "USER", "LOGNAME", "LANG", "LC_ALL",
            "LC_CTYPE", "SHELL") if key in os.environ}
    env.update({
        "LD_LIBRARY_PATH": vitis + "/lib/lnx64.o:" +
                           vitis + "/lnx64/tools/clang-3.9-csynth/lib",
        "OMP_NUM_THREADS": "2", "MKL_NUM_THREADS": "2",
        "OPENBLAS_NUM_THREADS": "2", "NUMEXPR_NUM_THREADS": "2",
    })
    command = ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
               "/usr/bin/taskset", "-c", ",".join(map(str, selected)),
               "/usr/bin/gdb", "-nx", "-q", "--interpreter=mi2",
               "--args", *cc1]
    save("probe_plan.json", {
        "at": now(), "cwd": str(BUILD), "command": command,
        "selected_cpu_ids": selected, "sample_seconds": SAMPLE_SECONDS,
        "hard_rss_kb": HARD_RSS_KB,
        "minimum_available_kb": MIN_AVAILABLE_KB,
        "hlsgen_entry": HLSGEN_ENTRY,
        "bitconcat_entry": BITCONCAT_ENTRY,
        "offset_call": OFFSET_CALL,
        "minimum_width_bits": MIN_WIDTH_BITS,
        "source_bitcode_sha256": source["source_sha256"],
        "compiler_sha256": "563bb572fb40c3a6298824942effad3eb78ebdabb13c2901454fe5e44110192a",
        "probe_scope": "one copied cc1 reflow, GDB reads registers and memory only",
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
    trigger = None
    peak_rss = 0
    peak_clang_rss = 0
    min_available = guard.mem_available_kb()
    captures = []
    phase = "starting"
    entry_breakpoint = None
    current_capture = None
    sequence = 0
    pending = {}
    checked_policy = {}
    mi_buffer = b""
    last_lines = []
    last_sample = 0.0
    began = time.monotonic()
    completed = False
    exit_code = None

    with (OUT / "gdb_mi.log").open("wb") as mi_log, \
         (OUT / "memory_timeline.csv").open("w", newline="") as timeline:
        writer = csv.writer(timeline)
        writer.writerow(("utc", "mem_available_kb", "owned_rss_kb",
                         "process_count", "largest_pid", "largest_rss_kb",
                         "largest_command"))
        timeline.flush()

        def send(command_text, kind):
            nonlocal sequence
            sequence += 1
            pending[sequence] = kind
            wire = f"{sequence}{command_text}\n"
            child.stdin.write(wire.encode())
            child.stdin.flush()
            mi_log.write(("# SENT " + wire).encode())
            mi_log.flush()
            return sequence

        def owned_rss_at_stop():
            nonlocal peak_rss, peak_clang_rss, last_items
            items = guard.owned_processes(guard.process_table(), leader, known)
            last_items = items
            total = sum(item["rss_kb"] for item in items.values())
            clang = max((item["rss_kb"] for item in items.values()
                         if item["command"] == "clang"), default=0)
            peak_rss = max(peak_rss, total)
            peak_clang_rss = max(peak_clang_rss, clang)
            return {"owned_rss_kb": total, "clang_rss_kb": clang}

        def process_line(line):
            nonlocal phase, completed, trigger, entry_breakpoint
            nonlocal current_capture
            decoded = line.decode("utf-8", errors="replace").rstrip("\r\n")
            last_lines.append(decoded)
            del last_lines[:-80]
            if current_capture is not None and phase in ("entry_reads",
                                                          "call_reads") and \
                    decoded.startswith(("~", "&")):
                current_capture.setdefault("mi_stream", []).append(decoded)
            if decoded.startswith("*stopped"):
                if 'reason="exited' in decoded:
                    trigger = {"at": now(), "reason": "inferior_exited_early",
                               "phase": phase}
                elif 'reason="breakpoint-hit"' in decoded:
                    if phase == "await_hls":
                        phase = "hls_reads"
                        save("hlsgen_entry.json", {"at": now(),
                             **owned_rss_at_stop(),
                             "sampled_peak_rss_kb": peak_rss,
                             "stopped_record": decoded})
                        send('-interpreter-exec console "bt 8"', "hls_bt")
                    elif phase == "await_entry":
                        phase = "entry_reads"
                        current_capture = {"at": now(),
                            **owned_rss_at_stop(),
                            "sampled_peak_rss_kb": peak_rss,
                            "entry_stopped_record": decoded}
                        for field, expr in (
                                ("entry_width_bits",
                                 "(*(unsigned int*)($rcx+8)>>8)"),
                                ("arrayref_element_count", "$rdx"),
                                ("arrayref_begin", "$rsi"),
                                ("builder_this", "$rdi"),
                                ("target_type_pointer", "$rcx")):
                            send(f'-data-evaluate-expression "{expr}"',
                                 ("field", field))
                        send('-interpreter-exec console "info registers rdi rsi rdx rcx r12 r15 rbx rsp"',
                             "entry_regs")
                        send('-interpreter-exec console "bt 35"', "entry_bt")
                    elif phase == "await_call":
                        phase = "call_reads"
                        current_capture["call_at"] = now()
                        current_capture["call_memory"] = owned_rss_at_stop()
                        current_capture["call_sampled_peak_rss_kb"] = peak_rss
                        current_capture["call_stopped_record"] = decoded
                        for field, expr in (
                                ("call_width_bits",
                                 "(*(unsigned int*)($rdi+8)>>8)"),
                                ("bit_offset", "$r12"),
                                ("r15", "$r15"), ("rbx", "$rbx"),
                                ("rsp", "$rsp"), ("call_type_pointer", "$rdi")):
                            send(f'-data-evaluate-expression "{expr}"',
                                 ("field", field))
                        send('-data-read-memory-bytes "$rdi" 16', "type_memory")
                        send('-interpreter-exec console "info registers rdi rsi rdx rcx r12 r15 rbx rsp"',
                             "call_regs")
                        send('-interpreter-exec console "bt 35"', "call_bt")
                    else:
                        trigger = {"at": now(), "reason":
                                   "unexpected_breakpoint", "phase": phase,
                                   "stopped_record": decoded}
                else:
                    trigger = {"at": now(), "reason": "unexpected_stop",
                               "phase": phase, "stopped_record": decoded}

            for number, kind in list(pending.items()):
                if not decoded.startswith(str(number) + "^"):
                    continue
                pending.pop(number, None)
                if "^error" in decoded:
                    trigger = {"at": now(), "reason": "gdb_mi_error",
                               "phase": phase, "command_kind": kind,
                               "response": decoded}
                    break
                if isinstance(kind, tuple) and kind[0] == "field":
                    match = re.search(r'value="([^"]*)"', decoded)
                    current_capture[kind[1]] = match.group(1) if match else decoded
                elif kind == "type_memory":
                    current_capture["type_memory_response"] = decoded
                elif kind == "insert_hls":
                    match = re.search(r'number="(\d+)"', decoded)
                    if not match:
                        trigger = {"at": now(), "reason":
                                   "missing_hls_breakpoint_number"}
                    else:
                        entry_breakpoint = match.group(1)
                        phase = "await_hls"
                        send("-exec-run", "run")
                elif kind == "hls_bt":
                    send(f"-break-delete {entry_breakpoint}", "delete_hls")
                elif kind == "delete_hls":
                    send('-break-insert -t -c "((*(unsigned int*)($rcx+8))>>8)>=1048576" '
                         + BITCONCAT_ENTRY, "insert_entry")
                elif kind == "insert_entry":
                    phase = "await_entry"
                    send("-exec-continue", "continue")
                elif kind == "entry_bt":
                    save("partial_capture.json", current_capture)
                    send('-break-insert -t -c "((*(unsigned int*)($rdi+8))>>8)>=1048576" '
                         + OFFSET_CALL, "insert_call")
                elif kind == "insert_call":
                    phase = "await_call"
                    send("-exec-continue", "continue")
                elif kind == "call_bt":
                    captures.append(current_capture)
                    save("width_captures.json", captures)
                    try:
                        width = int(current_capture["call_width_bits"], 0)
                    except (KeyError, ValueError):
                        width = 0
                    current_capture = None
                    if width >= RUNTIME_CANDIDATE_BITS or \
                            len(captures) >= MAX_BIG_ENTRIES:
                        completed = True
                    else:
                        send('-break-insert -t -c "((*(unsigned int*)($rcx+8))>>8)>=1048576" '
                             + BITCONCAT_ENTRY, "insert_entry")
                break

        try:
            child = subprocess.Popen(command, cwd=BUILD, env=env,
                                     stdin=subprocess.PIPE,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT,
                                     start_new_session=True, bufsize=0)
            leader = child.pid
            tick = guard.process_start(leader)
            if tick is None or os.getpgid(leader) != leader or \
                    os.getsid(leader) != leader:
                child.kill()
                child.wait()
                raise RuntimeError("GDB did not enter unique owned session")
            known[leader] = tick
            save("launch.json", {"at": now(), "leader_pid": leader,
                                 "leader_start_time_ticks": tick,
                                 "process_group_id": leader,
                                 "session_id": leader})
            os.set_blocking(child.stdout.fileno(), False)
            selector = selectors.DefaultSelector()
            selector.register(child.stdout, selectors.EVENT_READ)
            send("-gdb-set pagination off", "setup")
            send("-gdb-set confirm off", "setup")
            send("-gdb-set debuginfod enabled off", "setup")
            send("-gdb-set disable-randomization off", "setup")
            send("-gdb-set mi-async on", "setup")
            send("-break-insert " + HLSGEN_ENTRY, "insert_hls")

            while child.poll() is None and not completed and trigger is None:
                if requested_term:
                    trigger = {"at": now(), "reason": "sigterm_requested"}
                    break
                if time.monotonic() - began >= 15 * 60:
                    trigger = {"at": now(), "reason": "wall_time_at_or_above_15m"}
                    break
                current = time.monotonic()
                if current - last_sample >= SAMPLE_SECONDS:
                    available = guard.mem_available_kb()
                    min_available = min(min_available, available)
                    table = guard.process_table()
                    items = guard.owned_processes(table, leader, known)
                    last_items = items
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
                            "matches": item["nice"] == 19 and
                                bool(affinity) and set(affinity).issubset(selected)
                                and ionice.returncode == 0 and
                                "idle" in (ionice.stdout or ionice.stderr).lower(),
                        }
                        checked_policy[pid] = policy
                        save("policy_checks.json", list(checked_policy.values()))
                        if not policy["matches"]:
                            trigger = {"at": now(), "reason":
                                       "owned_process_policy_mismatch",
                                       "policy": policy}
                            break
                    if trigger is not None:
                        break
                    total = sum(item["rss_kb"] for item in items.values())
                    peak_rss = max(peak_rss, total)
                    clang_rss = max((item["rss_kb"] for item in items.values()
                                     if item["command"] == "clang"), default=0)
                    peak_clang_rss = max(peak_clang_rss, clang_rss)
                    largest = max(items.values(), key=lambda x: x["rss_kb"],
                                  default=None)
                    writer.writerow((now(), available, total, len(items),
                                     largest["pid"] if largest else "",
                                     largest["rss_kb"] if largest else "",
                                     largest["command"] if largest else ""))
                    timeline.flush()
                    last_sample = current
                    if available <= MIN_AVAILABLE_KB:
                        trigger = {"at": now(), "reason":
                                   "mem_available_at_or_below_192_GiB"}
                        break
                    if total >= HARD_RSS_KB:
                        trigger = {"at": now(), "reason":
                                   "owned_rss_at_or_above_8_GiB"}
                        break
                for key, mask in selector.select(timeout=0.1):
                    try:
                        chunk = os.read(child.stdout.fileno(), 262144)
                    except BlockingIOError:
                        continue
                    if not chunk:
                        continue
                    mi_log.write(chunk)
                    mi_log.flush()
                    mi_buffer += chunk
                    while b"\n" in mi_buffer:
                        line, mi_buffer = mi_buffer.split(b"\n", 1)
                        process_line(line)
            if trigger is None and completed:
                trigger = {"at": now(), "reason":
                           "width_capture_complete" if captures
                           else "gdb_inferior_completed"}
            if trigger is None and child.poll() is not None:
                trigger = {"at": now(), "reason": "gdb_exited"}
            if trigger is not None:
                if child.poll() is None:
                    try:
                        owned_rss_at_stop()
                    except Exception as exc:
                        trigger["final_rss_sample_error"] = repr(exc)
                trigger.update({"leader_pid": leader,
                                "process_group_id": leader,
                                "mem_available_kb": min_available,
                                "peak_owned_rss_kb": peak_rss,
                                "peak_clang_rss_kb": peak_clang_rss,
                                "captures": len(captures), "phase": phase,
                                "mi_tail": last_lines[-35:]})
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
                    "finished_at": now(), "gdb_exit_code": exit_code,
                    "trigger": trigger["reason"] if trigger else None,
                    "peak_owned_rss_kb": peak_rss,
                    "peak_clang_rss_kb": peak_clang_rss,
                    "minimum_mem_available_kb": min_available,
                    "width_capture_count": len(captures),
                    "phase": phase,
                })


if __name__ == "__main__":
    main()
