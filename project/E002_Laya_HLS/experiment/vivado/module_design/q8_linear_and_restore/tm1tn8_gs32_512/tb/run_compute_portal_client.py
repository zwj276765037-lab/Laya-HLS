#!/usr/bin/env python3
"""Freeze and run the bounded portable portal caller/builder test."""

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
        "tests/compute_portal_client_test.cpp",
    ]
    flags = ["-std=c++17", "-O2", "-Wall", "-Wextra", "-Werror",
             "-fno-fast-math", "-fno-associative-math", "-ffp-contract=off"]
    include = ["-I" + str(ROOT / "include"),
               "-I" + str(ROOT / "build/model-repair")]
    closure = set()
    for unit in units:
        deps = subprocess.check_output(
            ["/usr/bin/g++", *flags, *include, "-MM", str(ROOT / unit)],
            text=True, cwd=ROOT)
        closure.update(Path(item).resolve() for item in
                       deps.replace("\\\n", " ").split(":", 1)[1].split())
    closure.update({(ROOT / "config/full_sources.cmake").resolve(),
                    (ROOT / "config/full_module_registry.json").resolve()})
    files = []
    for source in sorted(closure):
        target = frozen / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        files.append({"original": rec(source), "frozen": rec(target)})
    registry = json.loads((frozen / "config/full_module_registry.json").read_text())
    kernel = registry["modules"]["kernel_wrapper"]
    required = {"hls/platform/compute_portal_codec.cpp",
                "hls/platform/compute_portal_client.cpp"}
    if not required.issubset(kernel):
        raise RuntimeError("production module registry omits portal client")
    sources = (frozen / "config/full_sources.cmake").read_text()
    if not all(item in sources for item in required):
        raise RuntimeError("production HLS source closure omits portal client")
    commands = []
    manifest = {
        "schema": "laya-portal-client-input-v1",
        "scope": "portable 512-bit transport, exact response binding, canonical L13M v1/LYMP v1 oracles, four command builders, ordinary cross-stage producer acceptance, and strict GATE producer rejection",
        "files": files,
        "runner": rec(Path(__file__)),
        "compiler": subprocess.check_output(["/usr/bin/g++", "--version"], text=True),
        "commands": commands,
    }
    objects = []
    started = time.monotonic()
    status = "PASS"
    exit_code = 0
    try:
        for index, unit in enumerate(units):
            obj = work / f"{index}.o"
            command = ["/usr/bin/g++", *flags,
                       "-I" + str(frozen / "include"),
                       "-I" + str(frozen / "build/model-repair"),
                       "-c", str(frozen / unit), "-o", str(obj)]
            commands.append(command)
            subprocess.run(command, check=True, cwd=frozen)
            objects.append(obj)
            print("FULL_CURRENT_PORTAL_CLIENT_COMPILED unit=" + unit, flush=True)
        executable = work / "portal_client_test"
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
        "schema": "laya-portal-client-receipt-v1",
        "status": status,
        "exit_code": exit_code,
        "scope": manifest["scope"] + "; no generated HLS FIFO, RTL hub, controller retirement, or numerical-service claim",
        "elapsed_seconds": elapsed,
        "max_rss_kib": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
        "manifest": rec(work / "input_manifest.json"),
        "runner": rec(Path(__file__)),
    }
    if status == "PASS":
        receipt["executable"] = rec(work / "portal_client_test")
    (work / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_PORTAL_CLIENT_RUN status=" + status +
          f" elapsed={elapsed:.6f} rss_kib={receipt['max_rss_kib']}", flush=True)
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
