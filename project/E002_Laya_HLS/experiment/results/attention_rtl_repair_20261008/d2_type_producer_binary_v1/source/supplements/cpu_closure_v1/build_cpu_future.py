#!/usr/bin/env python3
"""Exact future CPU build driver; default is a read-only closure check.

No current release authorizes --execute. A new CPU-build release and a root
heavy-tool slot assignment are both required before this script can compile.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

import make_closure


HERE = Path(__file__).resolve().parent
MANIFEST = HERE / "closure_manifest.json"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def checked_manifest() -> dict:
    packet = json.loads(MANIFEST.read_text())
    require(packet == make_closure.construct(packet["created_utc"]),
            "frozen local-header and CPU argv closure changed")
    return packet


def future_build(packet: dict, release_path: Path) -> int:
    release = json.loads(release_path.read_text())
    require(release.get("schema") == "d2_type_producer_binary_cpu_build_release_v1" and
            release.get("status") == "CPU_BUILD_RELEASED" and
            release.get("closure_manifest_sha256") == sha(MANIFEST) and
            release.get("source_packet_sha256") ==
            packet["frozen_source_packet"]["sha256"] and
            release.get("build_argv_sha256") ==
            packet["future_cpu_build_argv_sha256"],
            "independent future CPU build release is absent or does not bind this closure")
    slot = release.get("root_heavy_slot_token")
    require(isinstance(slot, str) and slot and
            os.environ.get("LAYA_D2_HEAVY_SLOT") == slot,
            "root has not assigned the sole heavy-tool slot")
    budget = release.get("finite_budget", {})
    rss = budget.get("rss_gib")
    timeout = budget.get("wall_seconds")
    require(type(rss) is int and type(timeout) is int and
            0 < rss <= 32 and 0 < timeout <= 3600,
            "signed finite CPU build budget")
    reviewed = json.loads(make_closure.GATE.read_text())
    guard = Path(reviewed["finite_stage"]["guard"]["path"])
    helper = Path(reviewed["finite_stage"]["helper"]["path"])
    require(sha(guard) == reviewed["finite_stage"]["guard"]["sha256"] and
            sha(helper) == reviewed["finite_stage"]["helper"]["sha256"],
            "reviewed finite guard identity")
    output = Path(packet["future_output"])
    work = Path(packet["future_control_dir"])
    require(not output.parent.exists() and not work.exists(),
            "fresh CPU build and control directories")
    output.parent.mkdir(parents=True)
    work.mkdir(parents=True)
    argv = packet["future_cpu_build_argv"]
    guard_argv = [
        "/usr/bin/taskset", "-c", "0,1,2,3", "/usr/bin/python3", str(guard),
        "--out", str(work / "guard"), "--cwd", str(work),
        "--rss-gib", str(rss), "--timeout-seconds", str(timeout), "--",
        "/usr/bin/env", "-u", "PYTHONHOME", "-u", "PYTHONPATH",
        "/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
    ] + argv
    (work / "launch.json").write_text(json.dumps({
        "release_path": str(release_path.resolve()),
        "release_sha256": sha(release_path),
        "closure_manifest_sha256": sha(MANIFEST),
        "compile_argv": argv,
        "guard_argv": guard_argv,
    }, indent=2, sort_keys=True) + "\n")
    return subprocess.run(guard_argv, cwd=work, check=False).returncode


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--execute", action="store_true")
    parser.add_argument("--release", type=Path)
    args = parser.parse_args()
    packet = checked_manifest()
    if not args.execute:
        require(args.release is None, "--release requires --execute")
        print("D2_TYPE_FUTURE_CPU_BUILD_SOURCE_CHECK_PASS "
              f"argv_sha256={packet['future_cpu_build_argv_sha256']}")
        return 0
    require(args.release is not None, "new signed CPU release required")
    return future_build(packet, args.release)


if __name__ == "__main__":
    raise SystemExit(main())
