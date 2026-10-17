#!/usr/bin/env python3
"""Freeze and run the generated Controller G/Down portal integration test."""

import argparse
import hashlib
import json
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
MEMORY_LIMIT = 24 * 1024 * 1024 * 1024


def rec(path: Path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def limit_child():
    resource.setrlimit(resource.RLIMIT_AS, (MEMORY_LIMIT, MEMORY_LIMIT))


def run(command, *, cwd, capture=False):
    return subprocess.run(command, check=True, cwd=cwd,
                          stdout=subprocess.PIPE if capture else None,
                          stderr=subprocess.STDOUT if capture else None,
                          text=capture, preexec_fn=limit_child)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--work", type=Path, required=True)
    args = parser.parse_args()
    work = args.work.resolve()
    work.mkdir(exist_ok=False)
    frozen = work / "frozen"

    source_list = (ROOT / "config/full_sources.cmake").read_text()
    units = re.findall(r"^\s*((?:hls|vivado)/[^\s]+\.cpp)\s*$",
                       source_list, re.M)
    if len(units) != len(set(units)) or not units:
        raise RuntimeError("invalid production source list")
    units.append("tests/compute_portal_controller_test.cpp")

    flags = ["-std=c++17", "-O2", "-Wall", "-Wextra", "-Werror",
             "-Wno-aggressive-loop-optimizations", "-Wno-unused-parameter",
             "-Wno-unused-but-set-variable", "-Wno-unknown-pragmas",
             "-fno-fast-math",
             "-fno-associative-math", "-ffp-contract=off"]
    include = ["-I" + str(ROOT / "include"),
               "-I" + str(ROOT / "hls"),
               "-I" + str(ROOT / "build/model-repair"),
               "-isystem", str(VITIS_INCLUDE)]
    for header in ("ap_int.h", "hls_stream.h"):
        if not (VITIS_INCLUDE / header).is_file():
            raise RuntimeError("Vitis header is absent: " + header)

    closure = set()
    for unit in units:
        deps = subprocess.check_output(
            ["/usr/bin/g++", *flags, *include, "-MM", str(ROOT / unit)],
            text=True, cwd=ROOT, preexec_fn=limit_child)
        for item in deps.replace("\\\n", " ").split(":", 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path)
    closure.update({(ROOT / "config/full_sources.cmake").resolve(),
                    (ROOT / "config/full_module_registry.json").resolve()})

    files = []
    for source in sorted(closure):
        target = frozen / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        files.append({"original": rec(source), "frozen": rec(target)})

    required = {
        "hls/control/full_forward_controller.cpp",
        "hls/platform/compute_portal_client.cpp",
        "hls/platform/compute_portal_hls.cpp",
        "hls/platform/compute_portal_dispatch.cpp",
        "hls/platform/compute_portal_commit.cpp",
    }
    if not required.issubset(set(units)):
        raise RuntimeError("production source list omits Controller portal path")
    registry = json.loads(
        (frozen / "config/full_module_registry.json").read_text())
    registered = set()
    for entries in registry["modules"].values():
        registered.update(entries)
    if not required.issubset(registered):
        raise RuntimeError("production registry omits Controller portal path")

    commands = []
    manifest = {
        "schema": "laya-portal-controller-input-v1",
        "scope": "current production source closure and generated Controller portal integration for B1/S64: G -> LOAD -> Q -> four-view MATRIX plus ordinary per-window P -> Q -> parent L with cross-stage producer contexts; generated END terminality including legal undrained errors with both closed and active physical scopes that preserve the store tracker, binding, issued bytes, and typed counters",
        "files": files,
        "external_headers": [rec(VITIS_INCLUDE / "ap_int.h"),
                             rec(VITIS_INCLUDE / "hls_stream.h")],
        "runner": rec(Path(__file__)),
        "compiler": subprocess.check_output(
            ["/usr/bin/g++", "--version"], text=True),
        "commands": commands,
    }
    objects = []
    started = time.monotonic()
    status = "PASS"
    exit_code = 0
    run_log = work / "run.log"
    try:
        frozen_include = ["-I" + str(frozen / "include"),
                          "-I" + str(frozen / "hls"),
                          "-I" + str(frozen / "build/model-repair"),
                          "-isystem", str(VITIS_INCLUDE)]
        for index, unit in enumerate(units):
            obj = work / f"{index}.o"
            command = ["/usr/bin/g++", *flags, *frozen_include,
                       "-c", str(frozen / unit), "-o", str(obj)]
            commands.append(command)
            run(command, cwd=frozen)
            objects.append(obj)
            print("FULL_CURRENT_PORTAL_CONTROLLER_COMPILED unit=" + unit,
                  flush=True)
        executable = work / "portal_controller_test"
        command = ["/usr/bin/g++", *map(str, objects), "-o", str(executable)]
        commands.append(command)
        run(command, cwd=frozen)
        command = [str(executable)]
        commands.append(command)
        result = run(command, cwd=frozen, capture=True)
        run_log.write_text(result.stdout)
        print(result.stdout, end="", flush=True)
        if "FULL_CURRENT_PORTAL_CONTROLLER_PASS" not in result.stdout:
            raise RuntimeError("test exited without PASS marker")
    except subprocess.CalledProcessError as error:
        status = "FAIL"
        exit_code = error.returncode
        message = error.stdout or (
            "CalledProcessError: returncode=" + str(error.returncode) +
            " command=" + json.dumps(error.cmd) + "\n")
        run_log.write_text(message)
        print(message, end="", flush=True)
    except Exception as error:
        status = "FAIL"
        exit_code = 1
        run_log.write_text(type(error).__name__ + ": " + str(error) + "\n")
        print(run_log.read_text(), end="", flush=True)

    if not run_log.exists():
        run_log.write_text("No executable output; status=" + status + "\n")

    elapsed = time.monotonic() - started
    (work / "input_manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n")
    receipt = {
        "schema": "laya-portal-controller-receipt-v1",
        "status": status,
        "exit_code": exit_code,
        "scope": manifest["scope"] +
                 "; controlled service responses and C++ metadata/retirement path, no numerical payload, generated physical source ledger, persistent hub, full graph, RTL, or hardware claim",
        "elapsed_seconds": elapsed,
        "max_rss_kib": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
        "manifest": rec(work / "input_manifest.json"),
        "runner": rec(Path(__file__)),
        "run_log": rec(run_log),
    }
    if status == "PASS":
        receipt["executable"] = rec(work / "portal_controller_test")
    (work / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_PORTAL_CONTROLLER_RUN status=" + status +
          f" elapsed={elapsed:.6f} rss_kib={receipt['max_rss_kib']}",
          flush=True)
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
