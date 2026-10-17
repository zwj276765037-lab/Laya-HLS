#!/usr/bin/env python3
"""Freeze and run the first partitioned producer/Controller transaction test."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shutil
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[5]
VITIS_INCLUDE = Path(
    "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include")
MODEL = Path("build/model-current-production-v2-20261011")
MEMORY_LIMIT = 24 * 1024 * 1024 * 1024


def record(path: Path) -> dict:
    path = path.resolve()
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def launcher_state() -> dict:
    available = None
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            available = int(line.split()[1])
            break
    state = {
        "pid": os.getpid(),
        "cpu_affinity": sorted(os.sched_getaffinity(0)),
        "nice": os.getpriority(os.PRIO_PROCESS, 0),
        "ionice": subprocess.run(
            ["ionice", "-p", str(os.getpid())], check=True, text=True,
            capture_output=True).stdout.strip(),
        "mem_available_kib": available,
        "required_mem_available_kib": 192 * 1024 * 1024,
    }
    state["pass"] = (
        state["cpu_affinity"] == [0, 1, 2, 3] and
        state["nice"] == 19 and state["ionice"].startswith("idle") and
        available is not None and available > state["required_mem_available_kib"])
    return state


def limit_child() -> None:
    resource.setrlimit(resource.RLIMIT_AS, (MEMORY_LIMIT, MEMORY_LIMIT))


def run(command: list[str], cwd: Path, log: Path | None = None) -> dict:
    started = time.monotonic()
    stream = log.open("w") if log else subprocess.DEVNULL
    try:
        result = subprocess.run(
            command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT,
            preexec_fn=limit_child)
    finally:
        if log:
            stream.close()
    output = {"command": command, "exit_code": result.returncode,
              "elapsed_seconds": time.monotonic() - started}
    if log:
        output["log"] = record(log)
    return output


def source_list(path: Path) -> list[Path]:
    units = [Path(value) for value in re.findall(
        r"^\s*(hls/[^\s]+\.cpp)\s*$", path.read_text(), re.M)]
    if len(units) < 20 or len(units) != len(set(units)):
        raise RuntimeError("invalid partitioned Controller source list")
    return units


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--attempt", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = launcher_state()
    (attempt / "launcher.json").write_text(json.dumps(launcher, indent=2) + "\n")
    if not launcher["pass"]:
        raise RuntimeError("launcher/resource preflight failed")

    source_file = Path("config/partitioned_controller_sources.cmake")
    units = source_list(ROOT / source_file)
    test = Path("tests/producer_engine_controller_test.cpp")
    runner = Path(__file__).resolve().relative_to(ROOT)
    roots = units + [test]
    flags = ["-std=c++17", "-O2", "-Wall", "-Wextra", "-Werror",
             "-Wno-aggressive-loop-optimizations", "-Wno-unknown-pragmas",
             "-Wno-unused-parameter", "-Wno-unused-but-set-variable",
             "-fno-fast-math", "-fno-associative-math", "-ffp-contract=off",
             "-DLAYA_PARTITIONED_PRODUCTION_CALLER"]
    live_include = [f"-I{ROOT / 'include'}", f"-I{ROOT / 'hls'}",
                    f"-I{ROOT / 'hls/platform'}", f"-I{ROOT / MODEL}",
                    "-isystem", str(VITIS_INCLUDE)]
    closure = set()
    for unit in roots:
        deps = subprocess.check_output(
            ["g++", *flags, *live_include, "-MM", str(ROOT / unit)],
            cwd=ROOT, text=True, preexec_fn=limit_child)
        for item in deps.replace("\\\n", " ").split(":", 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path)
    for rel in (source_file, Path("config/full_module_registry.json"),
                Path("config/production_hls_partitions.json"), runner):
        closure.add((ROOT / rel).resolve())

    frozen = attempt / "frozen"
    files = []
    for source in sorted(closure):
        target = frozen / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        files.append({"relative": str(source.relative_to(ROOT)),
                      "original": record(source), "frozen": record(target)})

    frozen_include = [f"-I{frozen / 'include'}", f"-I{frozen / 'hls'}",
                      f"-I{frozen / 'hls/platform'}", f"-I{frozen / MODEL}",
                      "-isystem", str(VITIS_INCLUDE)]
    commands = []
    objects = []
    build_ok = True
    started = time.monotonic()
    for index, unit in enumerate(roots):
        obj = attempt / f"unit_{index:02d}.o"
        command = ["g++", *flags, *frozen_include, "-c",
                   str(frozen / unit), "-o", str(obj)]
        result = run(command, frozen, attempt / f"build_{index:02d}.log")
        commands.append(result)
        if result["exit_code"]:
            build_ok = False
            break
        objects.append(obj)

    executable = attempt / "producer_engine_controller_test"
    link = {"exit_code": None}
    execute = {"exit_code": None}
    if build_ok:
        link = run(["g++", *map(str, objects), "-o", str(executable)],
                   frozen, attempt / "link.log")
    if link["exit_code"] == 0:
        execute = run([str(executable)], frozen, attempt / "run.log")

    manifest = {
        "schema": "laya-producer-engine-controller-input-v1",
        "scope": ("partitioned gamma0 LayerNorm Controller transaction: exact "
                  "source lease, BEGIN before engine request, bound completion "
                  "store-byte import, END, one-window P, deferred typed retirement, "
                  "partial numerical failure, and malformed-completion safe hold; "
                  "controlled physical responses and no actual producer AXI payload, "
                  "RTL shell, whole request, resource, or performance claim"),
        "files": files,
        "external_headers": [record(VITIS_INCLUDE / "ap_int.h"),
                             record(VITIS_INCLUDE / "hls_stream.h")],
        "compiler": subprocess.check_output(["g++", "--version"], text=True),
        "launcher": record(attempt / "launcher.json"),
        "commands": commands, "link": link, "execute": execute,
        "profile": {"kind": "host_cpp_transaction", "maximum_seconds": 1800,
                    "maximum_rss_gib": 24, "cpu_count": 4, "nice": 19,
                    "io_class": "idle", "minimum_mem_available_gib": 192},
    }
    (attempt / "input_manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n")
    passed_marker = False
    if (attempt / "run.log").is_file():
        passed_marker = "FULL_CURRENT_PRODUCER_ENGINE_CONTROLLER_PASS" in (
            attempt / "run.log").read_text(errors="replace")
    status = "PASS" if execute["exit_code"] == 0 and passed_marker else "FAIL"
    receipt = {
        "schema": "laya-producer-engine-controller-receipt-v1",
        "status": status, "scope": manifest["scope"],
        "elapsed_seconds": time.monotonic() - started,
        "max_rss_kib": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
        "launcher": record(attempt / "launcher.json"),
        "input_manifest": record(attempt / "input_manifest.json"),
        "builds": commands, "link": link, "execute": execute,
    }
    if executable.is_file():
        receipt["executable"] = record(executable)
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_PRODUCER_ENGINE_CONTROLLER_RUN status=" + status,
          flush=True)
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
