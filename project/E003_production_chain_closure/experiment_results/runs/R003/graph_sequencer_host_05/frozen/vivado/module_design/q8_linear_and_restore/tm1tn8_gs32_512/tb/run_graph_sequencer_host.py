#!/usr/bin/env python3
"""Freeze, link, and run the graph-sequencer transaction closure test."""

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


def rec(path):
    path = path.resolve()
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def launcher_state():
    available_kib = None
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            available_kib = int(line.split()[1])
            break
    state = {
        "pid": os.getpid(),
        "cpu_affinity": sorted(os.sched_getaffinity(0)),
        "nice": os.getpriority(os.PRIO_PROCESS, 0),
        "ionice": subprocess.run(
            ["ionice", "-p", str(os.getpid())], check=True, text=True,
            capture_output=True).stdout.strip(),
        "mem_available_kib": available_kib,
        "required_mem_available_kib": 192 * 1024 * 1024,
    }
    state["pass"] = (
        state["cpu_affinity"] == [0, 1, 2, 3] and state["nice"] == 19 and
        state["ionice"].startswith("idle") and available_kib is not None and
        available_kib > state["required_mem_available_kib"])
    return state


def bounded_child():
    maximum = 24 * 1024**3
    resource.setrlimit(resource.RLIMIT_AS, (maximum, maximum))


def run(command, cwd, log):
    started = time.monotonic()
    try:
        with log.open("w") as stream:
            result = subprocess.run(
                command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT,
                timeout=1800, preexec_fn=bounded_child)
        exit_code = result.returncode
        timeout = False
    except subprocess.TimeoutExpired:
        exit_code = None
        timeout = True
    return {"command": command, "exit_code": exit_code, "timeout": timeout,
            "elapsed_seconds": time.monotonic() - started, "log": rec(log)}


def copy_one(rel, frozen, records):
    source = ROOT / rel
    if not source.is_file():
        raise RuntimeError(f"missing input: {rel}")
    target = frozen / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    records.append({"relative": str(rel), "original": rec(source),
                    "frozen": rec(target)})


def freeze_includes(frozen, records):
    suffixes = {".c", ".cc", ".cpp", ".cxx", ".h", ".hpp"}
    queue = [Path(item["relative"]) for item in records
             if Path(item["relative"]).suffix in suffixes]
    seen = set()
    while queue:
        rel = queue.pop(0)
        if rel in seen:
            continue
        seen.add(rel)
        source = ROOT / rel
        if not source.is_file():
            continue
        for name in re.findall(r'^\s*#include\s+"([^"]+)"',
                               source.read_text(errors="replace"), re.M):
            choices = [source.parent / name, ROOT / "include" / name,
                       ROOT / "hls" / name, ROOT / "hls/platform" / name,
                       ROOT / MODEL / name]
            found = None
            for candidate in choices:
                if candidate.is_file():
                    try:
                        found = candidate.resolve().relative_to(ROOT.resolve())
                    except ValueError:
                        found = None
                    if found is not None:
                        break
            if found is None:
                continue
            if not (frozen / found).exists():
                copy_one(found, frozen, records)
            if found.suffix in suffixes and found not in seen:
                queue.append(found)


def main():
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
    sources = [Path(value) for value in re.findall(
        r"^\s*(hls/[^\s]+\.cpp)\s*$",
        (ROOT / source_config).read_text(), re.M)]
    if len(sources) < 15 or len(sources) != len(set(sources)):
        raise RuntimeError("invalid graph sequencer source list")
    forbidden_names = {
        "compute_portal_codec.cpp", "generated_provenance_codec.cpp",
        "producer_engine_codec.cpp", "compute_portal_hls.cpp",
        "generated_provenance_hls.cpp", "producer_engine_hls.cpp",
    }
    forbidden = [str(path) for path in sources if path.name in forbidden_names]
    if forbidden:
        raise RuntimeError("external protocol codec/exchange entered sequencer")

    runner_rel = Path(__file__).resolve().relative_to(ROOT)
    inputs = sources + [
        source_config, Path("tests/controller_transaction_dispatch_test.cpp"),
        Path("config/production_hls_partitions.json"),
        Path("config/full_module_registry.json"), runner_rel,
        MODEL / "laya_model_layout_generated.h", MODEL / "manifest.json",
    ]
    frozen = attempt / "frozen"
    records = []
    for rel in inputs:
        copy_one(rel, frozen, records)
    freeze_includes(frozen, records)

    contract = PROJECT / "results/production_hls_partition_contract_20261012.md"
    contract_copy = frozen / "external/production_hls_partition_contract_20261012.md"
    contract_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_copy)

    compiler = shutil.which("g++")
    if compiler is None:
        raise RuntimeError("g++ absent")
    vitis_include = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include")
    binary = attempt / "graph_sequencer_host_test"
    command = [
        compiler, "-std=c++17", "-O1", "-Wall", "-Wextra", "-Werror",
        "-Wno-unknown-pragmas", "-Wno-unused-parameter",
        "-Wno-aggressive-loop-optimizations", "-fno-fast-math",
        "-fno-associative-math", "-ffp-contract=off",
        "-DLAYA_PARTITIONED_PRODUCTION_CALLER",
        "-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER",
        "-DLAYA_TRANSACTION_SEQUENCER_CODEC",
        "-I" + str(frozen / "include"), "-I" + str(frozen / "hls"),
        "-I" + str(frozen / "hls/platform"),
        "-I" + str(frozen / MODEL), "-isystem", str(vitis_include),
        str(frozen / "tests/controller_transaction_dispatch_test.cpp"),
        *[str(frozen / source) for source in sources], "-o", str(binary),
    ]
    scope = (
        "graph sequencer host link closure with the full graph/control source "
        "list and only the normalized transaction request/completion pair; "
        "compute/provenance/producer external codecs and exchanges are absent; "
        "transaction success, stale-key rejection, cleanup flag, undrained "
        "nonterminal response, and producer local rejection are exercised; no "
        "HLS RTL generation, real depth2 concurrent backpressure, engine AXI, "
        "full request, resources, timing, performance, or board claim")
    manifest = {
        "schema": "laya-graph-sequencer-host-input-v1", "scope": scope,
        "top": "laya_typed_q8_forward_graph_sequencer",
        "files": records,
        "contract": {"original": rec(contract), "frozen": rec(contract_copy)},
        "compiler": rec(Path(compiler)),
        "external_headers": [rec(vitis_include / "ap_int.h"),
                             rec(vitis_include / "hls_stream.h")],
        "launcher": rec(attempt / "launcher.json"),
        "source_count": len(sources), "forbidden_sources": forbidden,
        "planned_compile_command": command,
        "profile": {"kind": "static_host", "maximum_seconds": 1800,
                    "maximum_rss_gib": 24},
    }
    manifest_path = attempt / "input_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")

    commands = [run(command, ROOT, attempt / "build.log")]
    if commands[0]["exit_code"] == 0:
        commands.append(run([str(binary)], ROOT, attempt / "run.log"))
    markers = []
    for item in commands:
        for line in Path(item["log"]["path"]).read_text().splitlines():
            if "FULL_CURRENT_CONTROLLER_TRANSACTION_DISPATCH_" in line:
                markers.append(line)
    passed = (len(commands) == 2 and
              all(item["exit_code"] == 0 and not item["timeout"]
                  for item in commands) and
              any("DISPATCH_PASS" in line and
                  "external_protocol_codecs=0" in line and
                  "transaction_signals=6" in line for line in markers))
    receipt = {
        "schema": "laya-graph-sequencer-host-receipt-v1",
        "status": "PASS" if passed else "FAIL", "scope": scope,
        "launcher": rec(attempt / "launcher.json"),
        "input_manifest": rec(manifest_path), "commands": commands,
        "markers": markers, "source_count": len(sources),
        "forbidden_sources": forbidden,
    }
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_GRAPH_SEQUENCER_HOST_" +
          ("PASS" if passed else "FAIL"), flush=True)
    raise SystemExit(0 if passed else 1)


if __name__ == "__main__":
    main()
