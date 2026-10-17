#!/usr/bin/env python3
"""Freeze, build, and run the bounded request admission, snapshot schema, and program/executor host combination."""

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


def rec(path: Path) -> dict:
    path = path.resolve()
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def limited() -> None:
    resource.setrlimit(resource.RLIMIT_AS, (MEMORY_LIMIT, MEMORY_LIMIT))


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
        state["cpu_affinity"] == [0, 1, 2, 3] and state["nice"] == 19 and
        state["ionice"].startswith("idle") and available is not None and
        available > state["required_mem_available_kib"])
    return state


def run(command: list[str], cwd: Path, log: Path) -> dict:
    started = time.monotonic()
    try:
        with log.open("w") as output:
            result = subprocess.run(
                command, cwd=cwd, stdout=output, stderr=subprocess.STDOUT,
                timeout=1800, preexec_fn=limited)
        return {"command": command, "exit_code": result.returncode,
                "timeout": False, "elapsed_seconds": time.monotonic() - started,
                "log": rec(log)}
    except subprocess.TimeoutExpired:
        return {"command": command, "exit_code": None, "timeout": True,
                "elapsed_seconds": time.monotonic() - started,
                "log": rec(log)}


def cmake_sources(path: Path) -> list[Path]:
    return [Path(value) for value in re.findall(
        r"^\s*(hls/[^\s]+\.cpp)\s*$", path.read_text(), re.M)]


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

    source_config = Path("config/executor_bootstrap_sources.cmake")
    lifecycle_sources = cmake_sources(ROOT / source_config)
    required = {"task_lifecycle_fsm.cpp", "task_lifecycle_port.cpp",
                "executor_bootstrap.cpp", "bootstrap_snapshot_protocol.cpp", "controller_transaction_codec.cpp",
                "generated_provenance_events.cpp", "producer_engine_client.cpp"}
    forbidden = {"task_lifecycle_executor.cpp", "full_forward_controller.cpp",
                 "controller_transaction_dispatch.cpp", "controller_transaction_hls.cpp",
                 "controller_transaction_adapter.cpp", "compute_portal_codec.cpp",
                 "generated_provenance_codec.cpp", "producer_engine_codec.cpp"}
    names = {path.name for path in lifecycle_sources}
    if not required.issubset(names) or names & forbidden:
        raise RuntimeError("lifecycle FSM source closure is incomplete or contaminated")
    integration_sources = [Path("hls/control/graph_program_sequencer.cpp"),
        Path("hls/control/graph_program_protocol.cpp"),
        Path("hls/control/graph_program_hls.cpp"),
        Path("hls/platform/controller_transaction_adapter.cpp"),
        Path("hls/platform/compute_portal_codec.cpp"),
        Path("hls/platform/generated_provenance_codec.cpp"),
        Path("hls/platform/producer_engine_codec.cpp")]
    sources = lifecycle_sources + integration_sources
    test = Path("tests/executor_bootstrap_test.cpp")
    flags = [
        "-std=c++17", "-O1", "-Wall", "-Wextra", "-Werror",
        "-Wno-unknown-pragmas", "-Wno-unused-parameter",
        "-Wno-aggressive-loop-optimizations", "-fno-fast-math",
        "-fno-associative-math", "-ffp-contract=off",
        "-DLAYA_PARTITIONED_PRODUCTION_CALLER",
        "-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER", "-pthread",
    ]
    vitis = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include")
    live_includes = [f"-I{ROOT / 'include'}", f"-I{ROOT / 'hls'}",
                     f"-I{ROOT / 'hls/platform'}", f"-I{ROOT / MODEL}",
                     "-isystem", str(vitis)]
    closure: set[Path] = set()
    for unit in sources + [test]:
        deps = subprocess.check_output(
            ["g++", *flags, *live_includes, "-MM", str(ROOT / unit)],
            cwd=ROOT, text=True, timeout=1800, preexec_fn=limited)
        for item in deps.replace("\\\n", " ").split(":", 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path)
    fixed = [
        ROOT / source_config,
        ROOT / "config/graph_action_registry.json",
        ROOT / "config/production_hls_partitions.json",
        ROOT / "config/full_module_registry.json",
        ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_graph_action_layout_v1.sv",
        ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_graph_program_layout_v1.sv",
        Path(__file__).resolve(), ROOT / MODEL / "manifest.json",
        ROOT / MODEL / "aux.bin", ROOT / "tests/executor_bootstrap_fixture.py",
        ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_bootstrap_snapshot_layout_v1.sv",
    ]
    closure.update(path.resolve() for path in fixed)
    contract = PROJECT / "results/production_hls_partition_contract_20261012.md"
    frozen = attempt / "frozen"
    records = []
    for source in sorted(closure):
        target = frozen / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        records.append({"relative": str(source.relative_to(ROOT)),
                        "original": rec(source), "frozen": rec(target)})
    contract_copy = frozen / "external/production_hls_partition_contract_20261012.md"
    contract_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_copy)

    bootstrap_contract = PROJECT / "results/executor_bootstrap_source_contract_20261012.md"
    bootstrap_copy = frozen / "external/executor_bootstrap_source_contract_20261012.md"
    shutil.copyfile(bootstrap_contract, bootstrap_copy)
    scope = ("host unique executor request admission using actual LYRQ and selected "
             "LYMP header bytes, ten parse/model negatives, 768B LBS1/LBR1 "
             "independent byte oracle and 23 stale/header/semantic response reset negatives; "
             "guard/cancel/live-base rejection, read-only logical snapshot mirror, "
             "controlled four prior typed completions then actual C++ program/port/adapter "
             "four-window NORM with retirements 5..8, old-action admission preservation "
             "and same-session request/snapshot/action/protocol high water recovery. "
             "Snapshot and remote responses plus physical/guard inputs are controlled "
             "host fixtures: no hub snapshot or shell source protection RTL, no actual "
             "encoder/LN arithmetic or AXI, accepted-request HLS top, hardware depth2, "
             "complete request or graph, resources/timing or physical recovery claim.")
    compiler = Path(shutil.which("g++") or "")
    binary = attempt / "executor_bootstrap_test"
    compile_command = [
        str(compiler), *flags, f"-I{frozen / 'include'}",
        f"-I{frozen / 'hls'}", f"-I{frozen / 'hls/platform'}",
        f"-I{frozen / MODEL}", "-isystem", str(vitis),
        str(frozen / test), *[str(frozen / source) for source in sources],
        "-o", str(binary),
    ]
    fixture = attempt / "fixture"
    fixture_command = ["python3", str(frozen / "tests/executor_bootstrap_fixture.py"),
        "--model-header", str(frozen / MODEL / "laya_model_layout_generated.h"),
        "--model-aux", str(frozen / MODEL / "aux.bin"), "--output", str(fixture)]
    manifest = {
        "schema": "laya-executor-bootstrap-host-input-v1",
        "scope": scope, "files": records,
        "contract": {"original": rec(contract), "frozen": rec(contract_copy)},
        "bootstrap_contract": {"original": rec(bootstrap_contract), "frozen": rec(bootstrap_copy)},
        "lifecycle_sources": [str(path) for path in lifecycle_sources],
        "host_integration_sources": [str(path) for path in integration_sources],
        "required_sources": sorted(required), "forbidden_present": [],
        "launcher": rec(attempt / "launcher.json"),
        "compiler": rec(compiler),
        "external_headers": [rec(vitis / "ap_int.h"), rec(vitis / "hls_stream.h")],
        "planned_commands": [
            fixture_command, compile_command, [str(binary), str(fixture)],
        ],
        "profile": {"kind": "static_host", "maximum_seconds": 1800,
                    "maximum_rss_gib": 24},
    }
    manifest_path = attempt / "input_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")

    commands = [run(fixture_command, ROOT, attempt / "fixture.log")]
    if commands[-1]["exit_code"] == 0:
        commands.append(run(compile_command, ROOT, attempt / "build.log"))
    if len(commands) == 2 and commands[-1]["exit_code"] == 0:
        commands.append(run([str(binary), str(fixture)], ROOT, attempt / "run.log"))
    marker = "FULL_CURRENT_EXECUTOR_BOOTSTRAP_HOST_PASS"
    markers = []
    if (attempt / "run.log").is_file():
        markers = [line for line in (attempt / "run.log").read_text(
            errors="replace").splitlines() if marker in line]
    passed = (len(commands) == 3 and
              all(item["exit_code"] == 0 and not item["timeout"]
                  for item in commands) and len(markers) == 1)
    receipt = {
        "schema": "laya-executor-bootstrap-host-receipt-v1",
        "status": "PASS" if passed else "FAIL", "scope": scope,
        "launcher": rec(attempt / "launcher.json"),
        "input_manifest": rec(manifest_path), "commands": commands,
        "markers": markers, "lifecycle_source_count": len(lifecycle_sources),
        "fixture_files": [rec(path) for path in sorted(fixture.glob("*"))],
    }
    if binary.is_file():
        receipt["executable"] = rec(binary)
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_EXECUTOR_BOOTSTRAP_HOST_HOST_" +
          ("PASS" if passed else "FAIL"), flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
