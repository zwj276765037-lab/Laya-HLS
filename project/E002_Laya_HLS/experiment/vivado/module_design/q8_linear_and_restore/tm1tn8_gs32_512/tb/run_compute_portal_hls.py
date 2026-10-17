#!/usr/bin/env python3
"""Freeze and run the bounded ap_uint<512>/hls::stream portal adapter test."""

import argparse
import hashlib
import json
from pathlib import Path
import resource
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[5]
VITIS_INCLUDE = Path(
    "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include")


def rec(path: Path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--work", type=Path, required=True)
    args = parser.parse_args()
    work = args.work.resolve()
    work.mkdir(exist_ok=False)
    frozen = work / "frozen"
    units = [
        "hls/common/laya_numeric.cpp",
        "hls/common/laya_tasks.cpp",
        "hls/common/laya_memory_map.cpp",
        "hls/common/laya_full_memory.cpp",
        "hls/platform/compute_portal_codec.cpp",
        "hls/platform/compute_portal_client.cpp",
        "hls/platform/compute_portal_hls.cpp",
        "hls/platform/compute_portal_dispatch.cpp",
        "tests/compute_portal_hls_test.cpp",
    ]
    flags = ["-std=c++17", "-O2", "-Wall", "-Wextra", "-Werror",
             "-Wno-aggressive-loop-optimizations", "-fno-fast-math",
             "-fno-associative-math", "-ffp-contract=off"]
    include = ["-I" + str(ROOT / "include"),
               "-I" + str(ROOT / "build/model-repair"),
               "-isystem", str(VITIS_INCLUDE)]
    if not (VITIS_INCLUDE / "ap_int.h").is_file() or not (
            VITIS_INCLUDE / "hls_stream.h").is_file():
        raise RuntimeError("Vitis ap_int/hls_stream headers are absent")
    closure = set()
    for unit in units:
        deps = subprocess.check_output(
            ["/usr/bin/g++", *flags, *include, "-MM", str(ROOT / unit)],
            text=True, cwd=ROOT)
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
    registry = json.loads((frozen / "config/full_module_registry.json").read_text())
    required = {"hls/platform/compute_portal_hls.cpp",
                "hls/platform/compute_portal_dispatch.cpp"}
    registered = set(registry["modules"]["kernel_wrapper"])
    if not required.issubset(registered):
        raise RuntimeError("production registry omits HLS portal caller")
    sources = (frozen / "config/full_sources.cmake").read_text()
    if not all(item in sources for item in required):
        raise RuntimeError("production source closure omits HLS portal caller")
    commands = []
    manifest = {
        "schema": "laya-portal-hls-input-v1",
        "scope": "actual ap_uint<512>/hls::stream adapter and four-service typed dispatch with multi-view parent retirement",
        "files": files,
        "external_headers": [rec(VITIS_INCLUDE / "ap_int.h"),
                             rec(VITIS_INCLUDE / "hls_stream.h")],
        "runner": rec(Path(__file__)),
        "compiler": subprocess.check_output(["/usr/bin/g++", "--version"], text=True),
        "commands": commands,
    }
    objects = []
    started = time.monotonic()
    status = "PASS"
    exit_code = 0
    try:
        frozen_include = ["-I" + str(frozen / "include"),
                          "-I" + str(frozen / "build/model-repair"),
                          "-isystem", str(VITIS_INCLUDE)]
        for index, unit in enumerate(units):
            obj = work / f"{index}.o"
            command = ["/usr/bin/g++", *flags, *frozen_include,
                       "-c", str(frozen / unit), "-o", str(obj)]
            commands.append(command)
            subprocess.run(command, check=True, cwd=frozen)
            objects.append(obj)
            print("FULL_CURRENT_PORTAL_HLS_COMPILED unit=" + unit, flush=True)
        executable = work / "portal_hls_test"
        command = ["/usr/bin/g++", *map(str, objects), "-o", str(executable)]
        commands.append(command)
        subprocess.run(command, check=True, cwd=frozen)
        command = [str(executable)]
        commands.append(command)
        subprocess.run(command, check=True, cwd=frozen)
    except subprocess.CalledProcessError as error:
        status = "FAIL"
        exit_code = error.returncode
    elapsed = time.monotonic() - started
    (work / "input_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    receipt = {
        "schema": "laya-portal-hls-receipt-v1",
        "status": status,
        "exit_code": exit_code,
        "scope": manifest["scope"] + "; no generated RTL port, persistent hub, controller retirement, or numerical-service claim",
        "elapsed_seconds": elapsed,
        "max_rss_kib": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
        "manifest": rec(work / "input_manifest.json"),
        "runner": rec(Path(__file__)),
    }
    if status == "PASS":
        receipt["executable"] = rec(work / "portal_hls_test")
    (work / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_PORTAL_HLS_RUN status=" + status +
          f" elapsed={elapsed:.6f} rss_kib={receipt['max_rss_kib']}", flush=True)
    return exit_code


if __name__ == "__main__":
    sys.exit(main())

