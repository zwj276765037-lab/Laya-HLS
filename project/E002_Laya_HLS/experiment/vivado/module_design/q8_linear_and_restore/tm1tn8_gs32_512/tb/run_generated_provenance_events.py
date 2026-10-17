#!/usr/bin/env python3
"""Freeze and run generated-producer provenance builder/accounting tests."""

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
WALL_LIMIT_SECONDS = 1800


def rec(path: Path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def limit_child():
    resource.setrlimit(resource.RLIMIT_AS, (MEMORY_LIMIT, MEMORY_LIMIT))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--work", type=Path, required=True)
    args = parser.parse_args()
    work = args.work.resolve()
    work.mkdir(exist_ok=False)
    frozen = work / "frozen"

    source_list = (ROOT / "config/full_sources.cmake").read_text()
    production = re.findall(r"^\s*((?:hls|vivado)/[^\s]+\.cpp)\s*$",
                            source_list, re.M)
    if len(production) != len(set(production)) or not production:
        raise RuntimeError("invalid production source list")
    test = "tests/generated_provenance_events_test.cpp"
    units = [test, *production]
    flags = ["-std=c++17", "-O2", "-Wall", "-Wextra", "-Werror",
             "-Wno-aggressive-loop-optimizations", "-Wno-unused-parameter",
             "-Wno-unused-but-set-variable", "-Wno-unknown-pragmas",
             "-fno-fast-math", "-fno-associative-math", "-ffp-contract=off"]
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
            text=True, cwd=ROOT, preexec_fn=limit_child,
            timeout=WALL_LIMIT_SECONDS)
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
        "hls/common/laya_task_retirement.cpp",
        "hls/platform/generated_provenance_codec.cpp",
        "hls/platform/generated_provenance_events.cpp",
    }
    if not required.issubset(set(production)):
        raise RuntimeError("production source list omits provenance path")
    registry = json.loads(
        (frozen / "config/full_module_registry.json").read_text())
    registered = set()
    for entries in registry["modules"].values():
        registered.update(entries)
    if not required.issubset(registered):
        raise RuntimeError("production registry omits provenance path")

    commands = []
    manifest = {
        "schema": "laya-generated-provenance-events-input-v1",
        "scope": "generated provenance CLAIM/PUBLISH, LN/AV/RoPE geometry, persistent event allocation, store accounting, error priority, and deferred typed retirement",
        "files": files,
        "external_headers": [rec(VITIS_INCLUDE / "ap_int.h"),
                             rec(VITIS_INCLUDE / "hls_stream.h")],
        "runner": rec(Path(__file__)),
        "compiler": subprocess.check_output(
            ["/usr/bin/g++", "--version"], text=True),
        "limits": {"memory_bytes": MEMORY_LIMIT,
                   "wall_seconds": WALL_LIMIT_SECONDS},
        "commands": commands,
    }
    objects = []
    started = time.monotonic()
    deadline = started + WALL_LIMIT_SECONDS
    status = "PASS"
    exit_code = 0
    run_log = work / "run.log"

    def run(command):
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise subprocess.TimeoutExpired(command, WALL_LIMIT_SECONDS)
        return subprocess.run(
            command, check=True, cwd=frozen, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, text=True, preexec_fn=limit_child,
            timeout=remaining)

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
            result = run(command)
            if result.stdout:
                print(result.stdout, end="", flush=True)
            objects.append(obj)
            print("FULL_CURRENT_GENERATED_PROVENANCE_EVENTS_COMPILED unit=" +
                  unit, flush=True)
        executable = work / "generated_provenance_events_test"
        command = ["/usr/bin/g++", *map(str, objects), "-o", str(executable)]
        commands.append(command)
        run(command)
        command = [str(executable)]
        commands.append(command)
        result = run(command)
        run_log.write_text(result.stdout)
        print(result.stdout, end="", flush=True)
        if "FULL_CURRENT_GENERATED_PROVENANCE_EVENTS_PASS" not in result.stdout:
            raise RuntimeError("test exited without PASS marker")
    except subprocess.CalledProcessError as error:
        status = "FAIL"
        exit_code = error.returncode
        message = error.stdout or (
            "CalledProcessError: returncode=" + str(error.returncode) +
            " command=" + json.dumps(error.cmd) + "\n")
        run_log.write_text(message)
        print(message, end="", flush=True)
    except subprocess.TimeoutExpired as error:
        status = "FAIL"
        exit_code = 124
        message = "TimeoutExpired: " + str(error) + "\n"
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
    manifest_path = work / "input_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    receipt = {
        "schema": "laya-generated-provenance-events-receipt-v1",
        "status": status,
        "exit_code": exit_code,
        "scope": manifest["scope"] +
                 "; CPU builder/accounting evidence only, no physical hub, AXI adapter fence, RTL, numerical full graph, or hardware claim",
        "elapsed_seconds": elapsed,
        "max_rss_kib": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
        "manifest": rec(manifest_path),
        "runner": rec(Path(__file__)),
        "run_log": rec(run_log),
    }
    if status == "PASS":
        receipt["executable"] = rec(work / "generated_provenance_events_test")
    (work / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_GENERATED_PROVENANCE_EVENTS_RUN status=" + status +
          f" elapsed={elapsed:.6f} rss_kib={receipt['max_rss_kib']}",
          flush=True)
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
