#!/usr/bin/env python3
"""Run one T2 command in a fresh, resource-guarded attempt and hash its inputs."""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import subprocess
import sys


ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")
ATTEMPTS = ROOT / "results/compute_throughput_optimization_20261010/attempts"
GUARD = ROOT / "results/offline_validation_20261009/tools/guard_16g.py"
GUARD_HELPER = GUARD.with_name("hls_guard_helpers.py")


def identity(path: Path) -> dict[str, object]:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while block := stream.read(8 << 20):
            digest.update(block)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": digest.hexdigest()}


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", type=Path, required=True)
    parser.add_argument("--rss-gib", type=int, choices=(4, 8, 16, 32), required=True)
    parser.add_argument("--timeout-seconds", type=int, required=True)
    parser.add_argument("--input", type=Path, action="append", default=[])
    parser.add_argument("--input-tree", type=Path, action="append", default=[])
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command and args.command[0] == "--" else []
    attempt = args.attempt.resolve()
    if not command or args.timeout_seconds <= 0:
        parser.error("command must follow -- and timeout must be positive")
    if attempt.parent != ATTEMPTS or not attempt.name.startswith("t2_") or attempt.exists():
        parser.error("attempt must be fresh t2_* directory in the active phase")
    inputs = [p.resolve() for p in args.input]
    for tree in args.input_tree:
        if not tree.is_dir():
            parser.error(f"input tree missing: {tree}")
        inputs.extend(p.resolve() for p in tree.rglob("*") if p.is_file())
    inputs.extend((Path(__file__).resolve(), GUARD, GUARD_HELPER))
    if any(not path.is_file() for path in inputs):
        parser.error("all inputs must be regular files")
    attempt.mkdir()
    work = attempt / "work"
    work.mkdir()
    manifest = {
        "schema": "t2_guarded_attempt_v1",
        "attempt": attempt.name,
        "started_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "command": command,
        "rss_gib": args.rss_gib,
        "timeout_seconds": args.timeout_seconds,
        "inputs": [identity(p) for p in sorted(set(inputs))],
    }
    write_json(attempt / "input_manifest.json", manifest)
    guarded = [sys.executable, str(GUARD), "--out", str(attempt / "guard"),
               "--cwd", str(work), "--rss-gib", str(args.rss_gib),
               "--timeout-seconds", str(args.timeout_seconds), "--", *command]
    exit_code = subprocess.run(guarded, check=False).returncode
    manifest["finished_utc"] = dt.datetime.now(dt.timezone.utc).isoformat()
    manifest["exit_code"] = exit_code
    outputs = []
    for path in [attempt / "guard/guard_result.json", attempt / "guard/driver.log",
                 *work.glob("*.log")]:
        if path.is_file():
            outputs.append(identity(path))
    manifest["outputs"] = outputs
    write_json(attempt / "input_manifest.json", manifest)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
