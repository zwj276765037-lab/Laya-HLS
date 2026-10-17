#!/usr/bin/env python3
"""Freeze and run the bounded ordinary-source provenance ledger test."""

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
MEMORY_LIMIT = 24 * 1024 * 1024 * 1024


def rec(path: Path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def limit_child():
    resource.setrlimit(resource.RLIMIT_AS, (MEMORY_LIMIT, MEMORY_LIMIT))


def run(command, *, cwd, capture=False):
    return subprocess.run(
        command, check=True, cwd=cwd, timeout=120,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT if capture else None,
        text=capture, preexec_fn=limit_child)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--work", type=Path, required=True)
    work = parser.parse_args().work.resolve()
    work.mkdir(exist_ok=False)
    frozen = work / "frozen"
    units = [
        "hls/common/laya_numeric.cpp",
        "hls/common/laya_tasks.cpp",
        "hls/common/laya_full_owner.cpp",
        "tests/source_provenance_test.cpp",
    ]
    flags = ["-std=c++17", "-O2", "-Wall", "-Wextra", "-Werror",
             "-Wno-unknown-pragmas", "-fno-fast-math",
             "-fno-associative-math", "-ffp-contract=off"]
    include = ["-I" + str(ROOT / "include"),
               "-I" + str(ROOT / "build/model-repair")]
    closure = set()
    for unit in units:
        deps = subprocess.check_output(
            ["/usr/bin/g++", *flags, *include, "-MM", str(ROOT / unit)],
            text=True, cwd=ROOT, preexec_fn=limit_child)
        for item in deps.replace("\\\n", " ").split(":", 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path)
    files = []
    for source in sorted(closure):
        target = frozen / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        files.append({"original": rec(source), "frozen": rec(target)})
    commands = []
    manifest = {
        "schema": "laya-source-provenance-input-v1",
        "scope": "fixed-capacity C++ source provenance ledger: B1/B2 attention, ordinary, QKV pair and scorer in-place windows; atomic publication, RoPE shard close and inherited V proof, scorer LN-to-FC1-to-GELU epochs, identity, duplicate/failure and old-epoch lease boundaries",
        "files": files,
        "runner": rec(Path(__file__)),
        "compiler": subprocess.check_output(
            ["/usr/bin/g++", "--version"], text=True),
        "commands": commands,
    }
    started = time.monotonic()
    status = "PASS"
    exit_code = 0
    run_log = work / "run.log"
    objects = []
    try:
        frozen_include = ["-I" + str(frozen / "include"),
                          "-I" + str(frozen / "build/model-repair")]
        for index, unit in enumerate(units):
            obj = work / f"{index}.o"
            command = ["/usr/bin/g++", *flags, *frozen_include,
                       "-c", str(frozen / unit), "-o", str(obj)]
            commands.append(command)
            run(command, cwd=frozen)
            objects.append(obj)
            print("FULL_CURRENT_SOURCE_PROVENANCE_COMPILED unit=" + unit,
                  flush=True)
        executable = work / "source_provenance_test"
        command = ["/usr/bin/g++", *map(str, objects), "-o", str(executable)]
        commands.append(command)
        run(command, cwd=frozen)
        command = [str(executable)]
        commands.append(command)
        result = run(command, cwd=frozen, capture=True)
        run_log.write_text(result.stdout)
        print(result.stdout, end="", flush=True)
        if "FULL_CURRENT_SOURCE_PROVENANCE_PASS" not in result.stdout:
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
        "schema": "laya-source-provenance-receipt-v1",
        "status": status,
        "exit_code": exit_code,
        "scope": manifest["scope"] +
                 "; software metadata/retirement evidence only, no generated physical source ledger, numerical payload, RTL service, persistent hub, full graph, or hardware claim",
        "elapsed_seconds": elapsed,
        "max_rss_kib": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
        "manifest": rec(work / "input_manifest.json"),
        "runner": rec(Path(__file__)),
        "run_log": rec(run_log),
    }
    if status == "PASS":
        receipt["executable"] = rec(work / "source_provenance_test")
    (work / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_SOURCE_PROVENANCE_RUN status=" + status +
          f" elapsed={elapsed:.6f} rss_kib={receipt['max_rss_kib']}",
          flush=True)
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
