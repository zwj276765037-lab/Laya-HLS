#!/usr/bin/env python3
"""Fresh Task2 attempt with guarded execution and automatic input identity.

Example: record_attempt.py --attempt .../attempts/task2_tree_01 --rss-gib 8
 --timeout-seconds 120 --input source.sv --input tb.sv -- COMMAND ARGS...
All hashing and the command run inside the inherited CPU/RSS/Mem guard.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")
GUARD = ROOT / "results/encoder_decision_validation_20261009/tools/guard_runtime.py"
MODULE = ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512"


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def identity(path: Path) -> dict:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while block := f.read(8 << 20):
            h.update(block)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": h.hexdigest()}


def write(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def worker(control: Path) -> int:
    plan = json.loads(control.read_text())
    attempt = Path(plan["attempt"])
    cmd = plan["command"]
    manifest = {"schema": "tm1tn8_guarded_attempt_v1", "started_at": now(),
                "plan": plan, "inputs": [identity(Path(x)) for x in plan["inputs"]],
                "runner": identity(Path(__file__)),
                "guard_source": identity(GUARD)}
    tool = Path(cmd[0])
    if tool.is_file():
        manifest["tool_file"] = identity(tool)
        try:
            version = subprocess.run([str(tool), "--version"], capture_output=True,
                                     text=True, timeout=15)
            manifest["tool_version"] = {"exit": version.returncode,
                                        "stdout": version.stdout[:4096],
                                        "stderr": version.stderr[:4096]}
        except (OSError, subprocess.TimeoutExpired) as exc:
            manifest["tool_version_error"] = str(exc)
    write(attempt / "input_manifest.json", manifest)
    try:
        exit_code = subprocess.run(cmd, cwd=attempt / "work", check=False).returncode
    except OSError as exc:
        exit_code = 127
        manifest["exec_error"] = str(exc)
    manifest["finished_at"] = now()
    manifest["exit_code"] = exit_code
    write(attempt / "input_manifest.json", manifest)
    return exit_code


def main() -> int:
    if len(sys.argv) == 3 and sys.argv[1] == "--worker":
        return worker(Path(sys.argv[2]))
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--attempt", type=Path, required=True)
    ap.add_argument("--rss-gib", type=int, choices=(4, 8, 16, 24), required=True)
    ap.add_argument("--timeout-seconds", type=int, required=True)
    ap.add_argument("--input", type=Path, action="append", default=[])
    ap.add_argument("command", nargs=argparse.REMAINDER)
    args = ap.parse_args()
    command = args.command[1:] if args.command and args.command[0] == "--" else []
    if not command or args.timeout_seconds <= 0:
        ap.error("command must follow -- and timeout must be positive")
    attempt = args.attempt.resolve()
    if attempt.exists() or not str(attempt).startswith(str(ROOT / "results/cpu_embedding_q8_validation_20261010/attempts/task2_")):
        ap.error("attempt must be a fresh task2_* directory under the new phase")
    inputs = [p.resolve() for p in args.input]
    if any(not p.is_file() for p in inputs):
        ap.error("all --input files must exist")
    attempt.mkdir(parents=True)
    (attempt / "work").mkdir()
    plan = {"attempt": str(attempt), "command": command,
            "inputs": [str(p) for p in inputs], "rss_gib": args.rss_gib,
            "timeout_seconds": args.timeout_seconds,
            "root": str(ROOT), "module": str(MODULE)}
    control = attempt / "control.json"
    write(control, plan)
    guard_cmd = [sys.executable, str(GUARD), "--out", str(attempt / "guard"),
                 "--cwd", str(attempt / "work"), "--rss-gib", str(args.rss_gib),
                 "--timeout-seconds", str(args.timeout_seconds), "--",
                 sys.executable, str(Path(__file__).resolve()), "--worker",
                 str(control)]
    return subprocess.run(guard_cmd, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
