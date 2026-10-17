#!/usr/bin/env python3
"""Create and verify an isolated Vivado OOC project from the frozen HLS archive."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import threading
import time
from datetime import datetime, timezone
from pathlib import Path


PROJECT = Path(__file__).resolve().parents[1]
BASELINE = PROJECT.parents[1]
ARCHIVE = BASELINE / "results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full"
MANIFEST = ARCHIVE / "artifact_manifest.json"
RTL_SOURCE = ARCHIVE / "artifacts/rtl_verilog"
IP_ZIP = ARCHIVE / "artifacts/ip/xilinx_com_hls_laya_typed_q8_forward_1_0.zip"
BUILD = PROJECT / "build"
VIVADO_DEFAULT = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
TAG = "04934c15b3f83e842ec2e92ac2a81bf2"
COUNTS = {".v": 679, ".dat": 201, ".tcl": 13}
GIB = 1024**3
RUN_ID_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9_-]{0,63}\Z")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def atomic_json(path: Path, data: dict) -> None:
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    temporary.replace(path)


def mem_available_bytes() -> int:
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1]) * 1024
    raise RuntimeError("/proc/meminfo has no MemAvailable")


def process_snapshot() -> dict[int, tuple[int, int, int, int]]:
    """Return pid -> (parent pid, process group, start ticks, RSS bytes)."""
    processes: dict[int, tuple[int, int, int, int]] = {}
    for item in Path("/proc").iterdir():
        if not item.name.isdigit():
            continue
        pid = int(item.name)
        try:
            stat = (item / "stat").read_text()
            fields = stat[stat.rfind(")") + 2 :].split()
            if fields[0] == "Z":
                continue
            ppid, pgrp, started = int(fields[1]), int(fields[2]), int(fields[19])
            rss = 0
            for line in (item / "status").read_text().splitlines():
                if line.startswith("VmRSS:"):
                    rss = int(line.split()[1]) * 1024
                    break
            processes[pid] = (ppid, pgrp, started, rss)
        except (OSError, ValueError, IndexError):
            continue
    return processes


def owned_processes(snapshot: dict[int, tuple[int, int, int, int]], root_pid: int,
                    root_started: int, known: dict[int, int]) -> set[int]:
    descendants = {pid for pid, identity in known.items()
                   if pid in snapshot and snapshot[pid][2] == identity}
    if root_pid in snapshot and snapshot[root_pid][2] == root_started:
        descendants.add(root_pid)
    descendants.update(pid for pid, (_, group, _, _) in snapshot.items() if group == root_pid)
    changed = True
    while changed:
        prior = len(descendants)
        descendants.update(pid for pid, (ppid, _, _, _) in snapshot.items() if ppid in descendants)
        changed = len(descendants) != prior
    known.update({pid: snapshot[pid][2] for pid in descendants})
    return descendants


def terminate_owned(proc: subprocess.Popen[str], root_started: int, known: dict[int, int]) -> None:
    """Signal only recorded task descendants, checking PID start time before each signal."""
    for sig in (signal.SIGTERM, signal.SIGKILL):
        snapshot = process_snapshot()
        owned = owned_processes(snapshot, proc.pid, root_started, known)
        if proc.pid in owned and snapshot[proc.pid][2] == root_started:
            try:
                os.killpg(proc.pid, sig)
            except ProcessLookupError:
                pass
        for pid in sorted(owned, reverse=True):
            if pid in snapshot and snapshot[pid][2] == known.get(pid):
                try:
                    os.kill(pid, sig)
                except ProcessLookupError:
                    pass
        deadline = time.monotonic() + (10 if sig == signal.SIGTERM else 2)
        while time.monotonic() < deadline:
            snapshot = process_snapshot()
            if not owned_processes(snapshot, proc.pid, root_started, known):
                break
            time.sleep(0.25)
        if not owned_processes(process_snapshot(), proc.pid, root_started, known):
            break
    try:
        proc.wait(timeout=3)
    except subprocess.TimeoutExpired:
        pass


def check_archive() -> tuple[list[dict], dict]:
    manifest = json.loads(MANIFEST.read_text())
    if manifest.get("build_tag") != TAG:
        raise RuntimeError("archive build tag mismatch")
    files = manifest.get("files", [])
    if len(files) != 2197:
        raise RuntimeError(f"manifest file count mismatch: {len(files)}")
    by_kind: dict[str, int] = {}
    used: list[dict] = []
    for item in files:
        kind = item["kind"]
        name = Path(item["capture"]).name
        source = ARCHIVE / "artifacts" / kind / name
        if not source.is_file() or source.stat().st_size != item["bytes"] or sha256(source) != item["sha256"]:
            raise RuntimeError(f"archive hash/size mismatch: {kind}/{name}")
        by_kind[kind] = by_kind.get(kind, 0) + 1
        if kind == "rtl_verilog":
            used.append({"path": source, "sha256": item["sha256"], "bytes": item["bytes"]})
    if by_kind != {"rtl_verilog": 893, "rtl_vhdl": 692, "reports": 610, "ip": 2}:
        raise RuntimeError(f"archive kind counts mismatch: {by_kind}")
    by_suffix = {suffix: sum(x["path"].suffix == suffix for x in used) for suffix in COUNTS}
    if by_suffix != COUNTS:
        raise RuntimeError(f"RTL input counts mismatch: {by_suffix}")
    if len({x["path"].name for x in used}) != len(used):
        raise RuntimeError("archive contains duplicate RTL basenames")
    if not IP_ZIP.is_file():
        raise RuntimeError("frozen HLS IP zip is missing")
    dependency = check_static_dependencies([x["path"] for x in used])
    return used, {"archive_files_verified": len(files), "kinds": by_kind, "rtl_inputs": by_suffix,
                  "static_dependencies": dependency}


def check_static_dependencies(paths: list[Path]) -> dict:
    verilog = [p for p in paths if p.suffix == ".v"]
    data_names = {p.name for p in paths if p.suffix == ".dat"}
    scripts = [p for p in paths if p.suffix == ".tcl"]
    modules: set[str] = set()
    instances: set[str] = set()
    references: list[str] = []
    for path in verilog:
        source = path.read_text(errors="replace")
        modules.update(re.findall(r"^\s*(?:\(\*[^\n]*?\*\)\s*)?module\s+([A-Za-z_]\w*)\b", source, re.M))
        instances.update(re.findall(r"^\s*([A-Za-z_]\w*)\s+[A-Za-z_]\w*\s*\(", source, re.M))
        references.extend(re.findall(r'\$readmemh\s*\(\s*"([^"]+)"', source))
    if len(modules) < 679 or "laya_typed_q8_forward" not in modules:
        raise RuntimeError(f"generated module declarations unexpected: {len(modules)}")
    if len(references) != 201 or any(not name.startswith("./") or Path(name).name not in data_names for name in references):
        raise RuntimeError("readmemh does not resolve to the 201 staged DAT files")
    if {Path(name).name for name in references} != data_names:
        raise RuntimeError("some DAT inputs are not referenced")
    ip_names = {p.stem for p in scripts}
    if len(ip_names) != 13:
        raise RuntimeError("expected 13 unique IP scripts")
    unknown = instances - modules - {"begin", "else", "end", "endgenerate", "generate", "module"}
    if unknown != ip_names:
        raise RuntimeError(f"unresolved module types differ from the 13 IP: {sorted(unknown ^ ip_names)}")
    return {"declared_modules": len(modules), "readmemh_calls": len(references),
            "unresolved_module_types": sorted(unknown)}


def input_hashes(run_dir: Path, archive_used: list[dict], output: Path | None = None) -> Path:
    inputs = [x["path"] for x in archive_used]
    inputs += [MANIFEST, IP_ZIP]
    inputs += sorted((PROJECT / "scripts").glob("*.tcl"))
    inputs += [Path(__file__).resolve(), PROJECT / "constraints/top_ooc.xdc"]
    lines = [f"{sha256(path)}  {path.relative_to(BASELINE)}" for path in sorted(inputs)]
    staged_hook = run_dir / "prepare_dat.tcl"
    if staged_hook.is_file():
        lines.append(f"{sha256(staged_hook)}  {staged_hook.relative_to(BASELINE)}")
    result = output or run_dir / "input_hashes.sha256"
    result.write_text("\n".join(lines) + "\n")
    return result


def stage_inputs(run_dir: Path, archive_used: list[dict]) -> Path:
    target = run_dir / "stage/rtl_verilog"
    target.mkdir(parents=True)
    for item in archive_used:
        source = item["path"]
        dest = target / source.name
        shutil.copy2(source, dest)
        if dest.stat().st_size != item["bytes"] or sha256(dest) != item["sha256"]:
            raise RuntimeError(f"staging checksum mismatch: {dest}")
    shutil.copy2(PROJECT / "scripts/prepare_dat.tcl", run_dir / "prepare_dat.tcl")
    return target


def generated_ip_paths(run_dir: Path) -> list[Path]:
    project_dir = run_dir / "vivado"
    paths = sorted(project_dir.glob("laya_ooc.srcs/sources_1/ip/**/*.xci"))
    paths += sorted(project_dir.glob("laya_ooc.gen/sources_1/ip/**/*"))
    paths = [p for p in paths if p.is_file()]
    if len([p for p in paths if p.suffix == ".xci"]) != 13:
        raise RuntimeError("generated project does not contain 13 XCI files")
    return paths


def generated_ip_hashes(run_dir: Path) -> None:
    paths = generated_ip_paths(run_dir)
    lines = [f"{sha256(p)}  {p.relative_to(run_dir)}" for p in paths]
    (run_dir / "generated_ip_hashes.sha256").write_text("\n".join(lines) + "\n")


def check_generated_ip_hashes(run_dir: Path) -> int:
    recorded = run_dir / "generated_ip_hashes.sha256"
    if not recorded.is_file():
        raise RuntimeError("created IP output hash record is missing")
    expected: dict[str, str] = {}
    for line in recorded.read_text().splitlines():
        digest, path = line.split("  ", 1)
        expected[path] = digest
    actual_paths = generated_ip_paths(run_dir)
    actual = {str(path.relative_to(run_dir)): path for path in actual_paths}
    if set(expected) != set(actual):
        raise RuntimeError("generated IP output file set drifted from create record")
    for name, path in actual.items():
        if sha256(path) != expected[name]:
            raise RuntimeError(f"generated IP output hash drift: {name}")
    return len(actual)


def check_created_inputs(run_dir: Path, xdc: Path) -> None:
    original = run_dir / "input_hashes.sha256"
    if not original.is_file():
        raise RuntimeError("original create input hash record is missing")
    hashes = {name: digest for digest, name in
              (line.split("  ", 1) for line in original.read_text().splitlines())}
    key = str(xdc.relative_to(BASELINE))
    if hashes.get(key) != sha256(xdc):
        raise RuntimeError("clock constraint changed since project creation")
    staged_hook = run_dir / "prepare_dat.tcl"
    if not staged_hook.is_file() or sha256(staged_hook) != sha256(PROJECT / "scripts/prepare_dat.tcl"):
        raise RuntimeError("staged DAT pre-hook differs from the maintained script")


def read_tool_version(vivado: Path) -> str:
    if not vivado.is_file() or not os.access(vivado, os.X_OK):
        raise RuntimeError(f"Vivado executable unavailable: {vivado}")
    completed = subprocess.run([str(vivado), "-version"], text=True, capture_output=True, timeout=30)
    if completed.returncode:
        raise RuntimeError(f"Vivado -version failed: {completed.returncode}")
    version = completed.stdout.strip()
    if not version.startswith("vivado v2025.2"):
        raise RuntimeError(f"unexpected Vivado version: {version.splitlines()[0]}")
    return version


def guarded_vivado(phase: str, tcl: Path, arguments: list[str], run_dir: Path,
                   vivado: Path, threads: int, limit_gib: float, timeout_seconds: int,
                   min_available_gib: float) -> dict:
    available_at_start = mem_available_bytes()
    if available_at_start < min_available_gib * GIB:
        raise RuntimeError(f"MemAvailable below reserve of {min_available_gib:g} GiB")
    logs = run_dir / "logs"
    logs.mkdir(exist_ok=True)
    label = phase
    if (logs / f"{label}.console.log").exists():
        label = f"{phase}_{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}_{os.getpid()}"
    log_path = logs / f"{label}.console.log"
    command = [str(vivado), "-mode", "batch", "-source", str(tcl),
               "-log", str(logs / f"{label}.vivado.log"),
               "-journal", str(logs / f"{label}.vivado.jou"), "-tclargs", *arguments]
    started_utc = datetime.now(timezone.utc).isoformat()
    started = time.monotonic()
    proc = subprocess.Popen(command, cwd=run_dir, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True, bufsize=1, start_new_session=True)
    first_snapshot = process_snapshot()
    root_started = first_snapshot.get(proc.pid, (0, 0, 0, 0))[2]
    known: dict[int, int] = {proc.pid: root_started} if root_started else {}
    peak_rss = 0
    minimum_available = available_at_start
    reason = None
    with log_path.open("x") as log:
        def consume() -> None:
            assert proc.stdout is not None
            for line in proc.stdout:
                log.write(line)
                log.flush()
                if "LAYA_" in line or "ERROR:" in line or "CRITICAL WARNING:" in line:
                    print(line.rstrip(), flush=True)

        reader = threading.Thread(target=consume, daemon=True)
        reader.start()
        try:
            while True:
                snapshot = process_snapshot()
                owned = owned_processes(snapshot, proc.pid, root_started, known)
                peak_rss = max(peak_rss, sum(snapshot[pid][3] for pid in owned))
                minimum_available = min(minimum_available, mem_available_bytes())
                if proc.poll() is not None:
                    break
                if peak_rss > limit_gib * GIB:
                    reason = f"task process tree exceeded {limit_gib:g} GiB RSS"
                elif time.monotonic() - started > timeout_seconds:
                    reason = f"task exceeded {timeout_seconds} seconds"
                elif minimum_available < min_available_gib * GIB:
                    reason = f"MemAvailable fell below {min_available_gib:g} GiB"
                if reason:
                    break
                time.sleep(2)
        except KeyboardInterrupt:
            reason = "interrupted by user"
        finally:
            snapshot = process_snapshot()
            remaining = owned_processes(snapshot, proc.pid, root_started, known)
            if reason is None and proc.poll() is not None and remaining:
                reason = "task descendants remained after Vivado exited"
            if reason or proc.poll() is None:
                terminate_owned(proc, root_started, known)
            reader.join(timeout=10)
        return_code = proc.wait()
    result = {"phase": phase, "exit_code": return_code, "guard_reason": reason,
              "started_at_utc": started_utc, "finished_at_utc": datetime.now(timezone.utc).isoformat(),
              "elapsed_seconds": round(time.monotonic() - started, 2),
              "peak_task_tree_rss_bytes": peak_rss,
              "min_mem_available_bytes": minimum_available,
              "host_start": {"mem_available_bytes": available_at_start, "cpu_count": os.cpu_count()},
              "limits": {"threads": threads, "task_tree_rss_gib": limit_gib,
                         "timeout_seconds": timeout_seconds, "min_mem_available_gib": min_available_gib},
              "root_pid": proc.pid, "root_start_ticks": root_started,
              "console_log": str(log_path.relative_to(run_dir)),
              "vivado_log": str((logs / f"{label}.vivado.log").relative_to(run_dir)),
              "command": command}
    if reason or return_code:
        raise PhaseError(result)
    return result


class PhaseError(RuntimeError):
    def __init__(self, result: dict):
        super().__init__(f"{result['phase']} failed (exit {result['exit_code']}): {result['guard_reason'] or 'see log'}")
        self.result = result


def run_id_or_raise(value: str) -> str:
    if not RUN_ID_RE.fullmatch(value):
        raise RuntimeError("run id must use letters, digits, underscore or hyphen (1–64 chars)")
    return value


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="verify frozen archive, RTL dependencies, and Vivado; with --run-id also reopen that project")
    mode.add_argument("--create", action="store_true", help="stage sources, create XPR and 13 IP, then reopen and verify (no top synthesis)")
    mode.add_argument("--synth", action="store_true", help="explicit full top OOC synthesis of an existing --run-id project")
    parser.add_argument("--run-id", help="existing run for --synth/--check; optional new name for --create")
    parser.add_argument("--threads", type=int, default=4, help="Vivado maxThreads; default 4")
    parser.add_argument("--create-memory-gib", type=float, default=16, help="create/verify task tree RSS limit; default 16 GiB")
    parser.add_argument("--create-timeout-seconds", type=int, default=1800, help="per create or verify Vivado invocation; default 1800")
    parser.add_argument("--synth-memory-gib", type=float, default=64, help="synthesis task tree RSS limit; default 64 GiB")
    parser.add_argument("--synth-timeout-seconds", type=int, default=14400, help="synthesis timeout; default 14400")
    parser.add_argument("--min-available-gib", type=float, default=128, help="required host MemAvailable reserve; default 128 GiB")
    parser.add_argument("--vivado-bin", type=Path, default=Path(os.environ.get("VIVADO_BIN", VIVADO_DEFAULT)), help="Vivado executable (or VIVADO_BIN)")
    args = parser.parse_args()
    if args.threads < 1 or any(v <= 0 for v in (args.create_memory_gib, args.create_timeout_seconds,
                                                  args.synth_memory_gib, args.synth_timeout_seconds,
                                                  args.min_available_gib)):
        parser.error("thread and resource limits must be positive")
    if args.synth and not args.run_id:
        parser.error("--synth requires --run-id")
    try:
        archive_used, archive_status = check_archive()
        version = read_tool_version(args.vivado_bin)
        print(f"Archive verified: {archive_status['archive_files_verified']} files; RTL {archive_status['rtl_inputs']}; Vivado {version.splitlines()[0]}", flush=True)
        if args.check and not args.run_id:
            return 0

        run_id = run_id_or_raise(args.run_id or datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ") + f"-{os.getpid()}")
        run_dir = BUILD / run_id
        stage = run_dir / "stage/rtl_verilog"
        reports = run_dir / "reports"
        xdc = PROJECT / "constraints/top_ooc.xdc"
        metadata_path = run_dir / "metadata.json"
        if args.create:
            run_dir.mkdir(parents=True, exist_ok=False)
            reports.mkdir()
            metadata = {"run_id": run_id, "build_tag": TAG, "mode": "create", "status": "running",
                        "created_at_utc": datetime.now(timezone.utc).isoformat(),
                        "tool_version": version, "tool_path": str(args.vivado_bin.resolve()),
                        "archive": archive_status, "phases": []}
            atomic_json(metadata_path, metadata)
            print(f"LAYA_RUN_ID {run_id}", flush=True)
            input_hashes(run_dir, archive_used)
            stage_inputs(run_dir, archive_used)
        else:
            if not (run_dir / "vivado/laya_ooc.xpr").is_file():
                raise RuntimeError(f"existing XPR unavailable: {run_dir / 'vivado/laya_ooc.xpr'}")
            metadata = json.loads(metadata_path.read_text())
            if metadata.get("build_tag") != TAG:
                raise RuntimeError("existing run build tag mismatch")
            for item in archive_used:
                staged = stage / item["path"].name
                if not staged.is_file() or sha256(staged) != item["sha256"]:
                    raise RuntimeError(f"staged input drift: {staged}")
            check_created_inputs(run_dir, xdc)
            check_generated_ip_hashes(run_dir)
            print(f"LAYA_RUN_ID {run_id}", flush=True)

        limits = dict(run_dir=run_dir, vivado=args.vivado_bin, threads=args.threads,
                      min_available_gib=args.min_available_gib)
        def invoke(phase: str, script: str, script_args: list[str], synth: bool = False) -> None:
            (run_dir / "logs").mkdir(exist_ok=True)
            stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
            phase_hash = input_hashes(run_dir, archive_used,
                                      run_dir / "logs" / f"{phase}_{stamp}_{os.getpid()}.inputs.sha256")
            try:
                result = guarded_vivado(phase, PROJECT / "scripts" / script, script_args,
                                        limit_gib=args.synth_memory_gib if synth else args.create_memory_gib,
                                        timeout_seconds=args.synth_timeout_seconds if synth else args.create_timeout_seconds,
                                        **limits)
            except PhaseError as exc:
                exc.result["phase_input_hashes"] = str(phase_hash.relative_to(run_dir))
                raise
            result["phase_input_hashes"] = str(phase_hash.relative_to(run_dir))
            if phase.startswith("verify"):
                result["report_dir"] = str(Path(script_args[3]).relative_to(run_dir))
            metadata["phases"].append(result)
            atomic_json(metadata_path, metadata)

        if args.create:
            invoke("create", "create_project.tcl", [str(run_dir), str(stage), str(xdc), str(args.threads)])
        if args.create or args.check or args.synth:
            verify_reports = reports if args.create else reports / f"verify_{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}_{os.getpid()}"
            verify_reports.mkdir(parents=True, exist_ok=args.create)
            invoke("verify", "verify_project.tcl", [str(run_dir), str(stage), str(xdc), str(verify_reports), str(args.threads)])
            if args.create:
                generated_ip_hashes(run_dir)
            else:
                check_generated_ip_hashes(run_dir)
        if args.synth:
            synth_reports = reports / f"synth_{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}_{os.getpid()}"
            synth_reports.mkdir()
            invoke("synth", "synth_ooc.tcl", [str(run_dir), str(synth_reports), str(args.threads)], synth=True)
        metadata["status"] = "complete" if args.create else metadata.get("status", "complete")
        metadata["last_mode"] = "synth" if args.synth else "verify" if args.check else "create"
        metadata["last_completed_at_utc"] = datetime.now(timezone.utc).isoformat()
        atomic_json(metadata_path, metadata)
        print(f"LAYA_XPR {run_dir / 'vivado/laya_ooc.xpr'}", flush=True)
        return 0
    except PhaseError as exc:
        if "metadata" in locals():
            metadata["phases"].append(exc.result)
            metadata["status"] = "failed"
            metadata["error"] = str(exc)
            atomic_json(metadata_path, metadata)
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except (OSError, RuntimeError, KeyError, ValueError, json.JSONDecodeError) as exc:
        if "metadata" in locals():
            metadata["status"] = "failed"
            metadata["error"] = str(exc)
            atomic_json(metadata_path, metadata)
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
