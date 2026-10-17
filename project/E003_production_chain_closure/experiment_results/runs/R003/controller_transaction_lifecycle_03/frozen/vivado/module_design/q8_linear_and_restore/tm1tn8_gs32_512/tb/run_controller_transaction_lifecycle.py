#!/usr/bin/env python3
"""Freeze, build, and run the bounded sequencer/adapter lifecycle regression."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shutil
import subprocess
import time


ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODEL = Path("build/model-current-production-v2-20261011")
MEMORY_LIMIT = 24 * 1024**3


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


def run(command: list[str], cwd: Path, log: Path) -> dict:
    started = time.monotonic()
    with log.open("w") as stream:
        result = subprocess.run(
            command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT,
            timeout=1800, preexec_fn=limit_child)
    return {"command": command, "exit_code": result.returncode,
            "elapsed_seconds": time.monotonic() - started,
            "log": record(log)}


def source_list(path: Path) -> list[Path]:
    values = [Path(value) for value in re.findall(
        r"^\s*(hls/[^\s]+\.cpp)\s*$", path.read_text(), re.M)]
    if len(values) < 15 or len(values) != len(set(values)):
        raise RuntimeError("invalid graph sequencer source list")
    extras = [
        Path("hls/platform/controller_transaction_adapter.cpp"),
        Path("hls/platform/compute_portal_codec.cpp"),
        Path("hls/platform/generated_provenance_codec.cpp"),
        Path("hls/platform/producer_engine_codec.cpp"),
    ]
    for value in extras:
        if value not in values:
            values.append(value)
    return values


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

    source_config = Path("config/graph_sequencer_sources.cmake")
    sources = source_list(ROOT / source_config)
    test = Path("tests/controller_transaction_lifecycle_test.cpp")
    runner = Path(__file__).resolve().relative_to(ROOT)
    roots = sources + [test]
    flags = [
        "-std=c++17", "-O1", "-Wall", "-Wextra", "-Werror",
        "-Wno-aggressive-loop-optimizations", "-Wno-unknown-pragmas",
        "-Wno-unused-parameter", "-fno-fast-math",
        "-fno-associative-math", "-ffp-contract=off",
        "-DLAYA_PARTITIONED_PRODUCTION_CALLER",
        "-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER", "-pthread",
    ]
    vitis_include = Path(
        "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include")
    live_include = [f"-I{ROOT / 'include'}", f"-I{ROOT / 'hls'}",
                    f"-I{ROOT / 'hls/platform'}", f"-I{ROOT / MODEL}",
                    "-isystem", str(vitis_include)]

    closure: set[Path] = set()
    for unit in roots:
        deps = subprocess.check_output(
            ["g++", *flags, *live_include, "-MM", str(ROOT / unit)],
            cwd=ROOT, text=True, preexec_fn=limit_child)
        for item in deps.replace("\\\n", " ").split(":", 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path)
    for rel in (source_config, Path("config/full_module_registry.json"),
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

    contract = PROJECT / "results/production_hls_partition_contract_20261012.md"
    contract_copy = frozen / "external/production_hls_partition_contract_20261012.md"
    contract_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_copy)

    frozen_include = [f"-I{frozen / 'include'}", f"-I{frozen / 'hls'}",
                      f"-I{frozen / 'hls/platform'}", f"-I{frozen / MODEL}",
                      "-isystem", str(vitis_include)]
    commands = []
    objects = []
    started = time.monotonic()
    build_ok = True
    for index, unit in enumerate(roots):
        obj = attempt / f"unit_{index:02d}.o"
        result = run(
            ["g++", *flags, *frozen_include, "-c", str(frozen / unit),
             "-o", str(obj)], frozen, attempt / f"build_{index:02d}.log")
        commands.append(result)
        if result["exit_code"]:
            build_ok = False
            break
        objects.append(obj)

    executable = attempt / "controller_transaction_lifecycle_test"
    link = {"exit_code": None}
    execute = {"exit_code": None}
    if build_ok:
        link = run(["g++", "-pthread", *map(str, objects), "-o",
                    str(executable)], frozen, attempt / "link.log")
    if link["exit_code"] == 0:
        execute = run([str(executable)], frozen, attempt / "run.log")

    scope = (
        "actual Controller transaction-sequencer LayerNorm lifecycle joined to "
        "the host command/provenance adapter: successful CLAIM/BEGIN, fully "
        "bound cancel LOCAL_REJECT before any external producer beat, zero "
        "issued-store accounting, exact source read-lease release, repeated "
        "same-identity END after one bound undrained response, safe terminal "
        "cleanup and one typed retirement, destination non-publication, plus a "
        "same-runtime higher NumericIdentity successful recovery; controlled "
        "external provenance/producer responses and no HLS RTL, real AXI "
        "payload/fence, whole request, resources, timing, performance, or board claim")
    manifest = {
        "schema": "laya-controller-transaction-lifecycle-input-v1",
        "scope": scope, "files": files,
        "contract": {"original": record(contract),
                     "frozen": record(contract_copy)},
        "external_headers": [record(vitis_include / "ap_int.h"),
                             record(vitis_include / "hls_stream.h")],
        "compiler": subprocess.check_output(["g++", "--version"], text=True),
        "launcher": record(attempt / "launcher.json"),
        "commands": commands, "link": link, "execute": execute,
        "source_count": len(sources),
        "profile": {"kind": "static_host", "maximum_seconds": 1800,
                    "maximum_rss_gib": 24, "cpu_count": 4, "nice": 19,
                    "io_class": "idle", "minimum_mem_available_gib": 192},
    }
    manifest_path = attempt / "input_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    marker = "FULL_CURRENT_CONTROLLER_TRANSACTION_LIFECYCLE_PASS"
    passed_marker = ((attempt / "run.log").is_file() and
                     marker in (attempt / "run.log").read_text(errors="replace"))
    status = "PASS" if execute["exit_code"] == 0 and passed_marker else "FAIL"
    receipt = {
        "schema": "laya-controller-transaction-lifecycle-receipt-v1",
        "status": status, "scope": scope,
        "elapsed_seconds": time.monotonic() - started,
        "max_rss_kib": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
        "launcher": record(attempt / "launcher.json"),
        "input_manifest": record(manifest_path), "builds": commands,
        "link": link, "execute": execute,
        "markers": [line for line in (attempt / "run.log").read_text(
            errors="replace").splitlines() if marker in line]
            if (attempt / "run.log").is_file() else [],
    }
    if executable.is_file():
        receipt["executable"] = record(executable)
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_CONTROLLER_TRANSACTION_LIFECYCLE_RUN status=" + status,
          flush=True)
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
