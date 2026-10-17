#!/usr/bin/env python3
"""Freeze and guard the finite FIRST executor's real host wire consumers."""
import argparse
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import sys

import run_executor_bootstrap_host as host

ROOT = host.ROOT
PROJECT = host.PROJECT
MODEL = host.MODEL
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
RUNNER = MODULE / "tb/run_executor_stream_host.py"
GUARD = MODULE / "tb/production_guard.py"
FLAGS = ["-std=c++17", "-O1", "-Wall", "-Wextra", "-Werror",
         "-Wno-unknown-pragmas", "-Wno-unused-parameter",
         "-Wno-aggressive-loop-optimizations", "-fno-fast-math",
         "-fno-associative-math", "-ffp-contract=off",
         "-DLAYA_PARTITIONED_PRODUCTION_CALLER",
         "-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER", "-pthread"]
VITIS = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include")
SCOPE = (
    "Finite FIRST-only host executor stream preparation: actual LYRQ/LYMP admission and "
    "full LAD1 A; actual 16-beat control request read/codec/echo receipt, 16-beat response "
    "collection and actor validation, complete response receipt with accepted sideband "
    "derived from the actor's semantic consumption count, or a late revoked GRANT fully "
    "bound to the retained actual IMPORT receipt solely for old cleanup without starting "
    "work. CLOSED has no such fallback and requires the actor's exact validator. "
    "Independent response/request "
    "receipt backpressure and response-before-receipt; 12-step tail2/tail1 waits; early, "
    "foreign, duplicate, malformed and semantic rejection; both response-before-receipt "
    "and receipt-before-late-response GRANT under persistent revoke with zero start; "
    "actual full LBR2 codec/helper "
    "IMPORT and controlled matching GRANT. Actual C++ program, lifecycle port/FSM and "
    "transaction adapter complete four diagnostic NORM windows with controlled producer "
    "and provenance terminals. Actual program LAC1 full codec acceptance generates four "
    "echo beats with tail2/tail1 waits; abstract completion and Host/control bools cannot "
    "bypass the bridge. Actual old partial LGP1 drains under persistent cancel and the "
    "program emits a bound LOCAL_REJECT result. Actual four-beat Host result read/codec/echo "
    "precedes CLOSE; wrong/old/commit/terminal CLOSED never has accepted authority; whole "
    "receipt bytes and accepted remain stable while backpressured, including revocation. "
    "Malformed response raw bytes produce only a stable accepted=false notification and "
    "sticky isolation, with no lock release or automatic recovery. "
    "Correct CLOSED is consumed once and FIRST prevents a second request. Shell replies, "
    "session/base/fences, physical safety and remote producer results remain software "
    "controlled; host hls streams are unbounded. No physical shell protection, depth2 "
    "RTL, generated executor/HLS result, LN arithmetic/AXI, complete model/graph, physical "
    "CLOSE safety, no-LGP local error, full error matrix, hardware rearm, second-request "
    "handover, OOC, timing, resources or board claim."
)


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def dependency_driver(spec_path):
    """Run all -MM units inside one sampled 24GiB/1800s/120s guard."""
    spec = json.loads(spec_path.read_text())
    output = Path(spec["output"])
    output.mkdir(parents=True, exist_ok=False)
    for index, unit in enumerate(spec["units"]):
        command = [spec["compiler"], *spec["flags"], *spec["includes"], "-MM", unit]
        result = subprocess.run(command, cwd=spec["root"], text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output / (f"unit_{index:03d}.d")).write_text(result.stdout)
        (output / (f"unit_{index:03d}.stderr")).write_text(result.stderr)
        write_json(output / (f"unit_{index:03d}.json"),
                   {"unit": unit, "command": command, "exit_code": result.returncode})
        if result.stderr:
            print(result.stderr, end="", flush=True)
        if result.returncode:
            return result.returncode
        print(f"FULL_CURRENT_EXECUTOR_STREAM_DEPENDENCY_PROGRESS units={index + 1}", flush=True)
    print("FULL_CURRENT_EXECUTOR_STREAM_DEPENDENCIES_PASS", flush=True)
    return 0


def guarded(attempt, frozen, stage, command, marker=None):
    directory = attempt / ("guard_" + stage)
    launch = [sys.executable, str(frozen / GUARD), "--out", str(directory),
              "--cwd", str(frozen), "--rss-gib", "24", "--timeout-seconds", "1800",
              "--semantic-stall-seconds", "120", "--", *command]
    process = subprocess.run(launch)
    state_path = directory / "guard_result.json"
    state = json.loads(state_path.read_text()) if state_path.is_file() else None
    log = directory / "driver.log"
    body = log.read_text(errors="replace") if log.is_file() else ""
    passed = (process.returncode == 0 and state is not None and
              state["child_exit_code"] == 0 and state["trigger"] is None)
    if marker is not None:
        passed = passed and body.count(marker) == 1
    return {"status": "PASS" if passed else "FAIL", "started": True,
            "command": command, "guard_command": launch,
            "runner_exit_code": process.returncode, "guard": state,
            "markers": [line for line in body.splitlines() if marker and marker in line],
            "raw_files": [host.rec(path) for path in sorted(directory.rglob("*")) if path.is_file()]}


def execute(args):
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)  # Every attempt is immutable history.
    frozen = attempt / "frozen"
    receipt = {"schema": "laya-executor-stream-host-receipt-v1", "status": "RUNNING",
               "scope": SCOPE, "first_only_macro": args.first_only,
               "profile": {"cpu": [0, 1, 2, 3], "nice": 19, "io": "idle",
                           "mem_available_required_gib_exclusive": 192,
                           "rss_gib": 24, "timeout_seconds": 1800,
                           "semantic_stall_seconds": 120}}
    receipt_path = attempt / "receipt.json"
    write_json(receipt_path, receipt)
    records = []
    copied = set()

    def copy(source, relative):
        if str(relative) in copied:
            return
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        original = host.rec(source)
        shutil.copyfile(source, target)
        captured = host.rec(target)
        if original["sha256"] != captured["sha256"]:
            raise RuntimeError("input changed while freezing: " + str(source))
        records.append({"relative": str(relative), "original": original, "frozen": captured})
        copied.add(str(relative))

    try:
        launcher = host.launcher_state()
        write_json(attempt / "launcher.json", launcher)
        receipt["launcher"] = host.rec(attempt / "launcher.json")
        write_json(receipt_path, receipt)
        if not launcher["pass"]:
            raise RuntimeError("CPU0-3/nice19/idle I/O/MemAvailable>192GiB launcher rejected")

        config = Path("config/executor_actor_sources.cmake")
        production = host.cmake_sources(ROOT / config)
        required = {"executor_stream.cpp", "executor_actor.cpp", "executor_checkpoint.cpp",
                    "executor_checkpoint_protocol.cpp", "executor_handoff_protocol.cpp",
                    "executor_bootstrap.cpp", "bootstrap_snapshot_protocol.cpp",
                    "task_lifecycle_fsm.cpp", "task_lifecycle_port.cpp",
                    "admission_owner_protocol.cpp", "graph_program_protocol.cpp"}
        forbidden = {"task_lifecycle_executor.cpp", "full_forward_controller.cpp",
                     "controller_transaction_dispatch.cpp", "controller_transaction_hls.cpp",
                     "controller_transaction_adapter.cpp", "compute_portal_codec.cpp",
                     "generated_provenance_codec.cpp", "producer_engine_codec.cpp"}
        names = {path.name for path in production}
        if len(production) != 24 or names & forbidden or not required.issubset(names):
            raise RuntimeError("24-source executor stream production closure rejected")
        integration = [Path(name) for name in [
            "hls/control/graph_program_sequencer.cpp", "hls/control/graph_program_hls.cpp",
            "hls/platform/controller_transaction_adapter.cpp", "hls/platform/compute_portal_codec.cpp",
            "hls/platform/generated_provenance_codec.cpp", "hls/platform/producer_engine_codec.cpp"]]
        sources = production + integration
        test = Path("tests/executor_stream_test.cpp")
        flags = list(FLAGS)
        if args.first_only:
            flags.append("-DLAYA_EXECUTOR_FIRST_REQUEST")
        compiler_name = shutil.which("g++")
        if compiler_name is None:
            raise RuntimeError("g++ unavailable")
        compiler = Path(compiler_name).resolve()
        includes = ["-I" + str(ROOT / "include"), "-I" + str(ROOT / "hls"),
                    "-I" + str(ROOT / "hls/platform"), "-I" + str(ROOT / MODEL),
                    "-isystem", str(VITIS)]

        # Freeze the guard and its imports before any compiler preprocessing.
        seeds = [RUNNER, GUARD, Path("tools/hls_guard_helpers.py"),
                 MODULE / "tb/run_executor_bootstrap_host.py"]
        for relative in seeds:
            copy(ROOT / relative, relative)
        dependency_spec = attempt / "dependency_spec.json"
        write_json(dependency_spec, {"root": str(ROOT), "compiler": str(compiler),
                   "flags": flags, "includes": includes,
                   "units": [str(ROOT / unit) for unit in sources + [test]],
                   "output": str(attempt / "dependencies")})
        dep_command = [sys.executable, str(frozen / RUNNER),
                       "--dependency-spec", str(dependency_spec)]
        receipt["dependencies"] = guarded(attempt, frozen, "dependencies", dep_command,
                                          "FULL_CURRENT_EXECUTOR_STREAM_DEPENDENCIES_PASS")
        receipt["dependency_spec"] = host.rec(dependency_spec)
        receipt["dependency_files"] = [host.rec(path) for path in
                                       sorted((attempt / "dependencies").rglob("*")) if path.is_file()]
        write_json(receipt_path, receipt)
        if receipt["dependencies"]["status"] != "PASS":
            receipt["status"] = "FAIL"
            write_json(receipt_path, receipt)
            return 1

        closure = set()
        for raw in sorted((attempt / "dependencies").glob("*.d")):
            dependencies = raw.read_text().replace("\\\n", " ").split(":", 1)[1]
            for name in shlex.split(dependencies):
                path = Path(name)
                path = (path if path.is_absolute() else ROOT / path).resolve()
                if ROOT in path.parents:
                    closure.add(path)
        fixed = [config, test, Path("tests/lifecycle_fixture_helpers.h"),
                 Path("config/full_module_registry.json"),
                 Path("config/production_hls_partitions.json"), Path("config/graph_action_registry.json"),
                 MODEL / "manifest.json", MODEL / "aux.bin",
                 Path("tests/executor_handoff_fixture.py"), Path("tests/executor_checkpoint_fixture.py"),
                 Path("tests/executor_bootstrap_fixture.py"), Path("tests/admission_owner_fixture.py"),
                 Path("tests/program_pending_fixture.py"),
                 MODULE / "rtl/laya_admission_owner_layout_v1.sv",
                 MODULE / "rtl/laya_executor_handoff_layout_v1.sv",
                 MODULE / "rtl/laya_executor_checkpoint_layout_v2.sv",
                 MODULE / "rtl/laya_bootstrap_snapshot_layout_v1.sv",
                 MODULE / "rtl/laya_graph_action_layout_v1.sv",
                 MODULE / "rtl/laya_graph_program_layout_v1.sv",
                 MODULE / "rtl/laya_program_pending_layout_v1.sv",
                 MODULE / "rtl/laya_generated_provenance_layout_v1.sv",
                 MODULE / "rtl/laya_model_identity_13bo_generated_v1.sv", *seeds]
        closure.update((ROOT / path).resolve() for path in fixed)
        closure.update((ROOT / path).resolve() for path in sources)
        for source in sorted(closure):
            copy(source, source.relative_to(ROOT))
        for name in ["production_hls_partition_contract_20261012.md",
                     "executor_bootstrap_source_contract_20261012.md",
                     "executor_checkpoint_high_water_contract_20261012.md",
                     "executor_checkpoint_import_handshake_contract_20261013.md",
                     "executor_revoke_unaccepted_action_contract_20261013.md",
                     "executor_close_rearm_contract_20261013.md",
                     "executor_managed_lpv_owner_contract_20261013.md",
                     "executor_minimum_hardware_chain_reply_20261013.md"]:
            copy(PROJECT / "results" / name, Path("external/contracts") / name)

        build = [str(compiler), *flags, "-I" + str(frozen / "include"),
                 "-I" + str(frozen / "hls"), "-I" + str(frozen / "hls/platform"),
                 "-I" + str(frozen / MODEL), "-isystem", str(VITIS),
                 str(frozen / test), *[str(frozen / unit) for unit in sources],
                 "-o", str(attempt / "test")]
        oracle = [sys.executable, str(frozen / "tests/executor_handoff_fixture.py"),
                  "--model-header", str(frozen / MODEL / "laya_model_layout_generated.h"),
                  "--model-aux", str(frozen / MODEL / "aux.bin"),
                  "--output", str(attempt / "fixture")]
        commands = {"oracle": oracle, "build": build,
                    "run": [str(attempt / "test"), str(attempt / "fixture")]}
        manifest = {"schema": "laya-executor-stream-host-input-v1", "scope": SCOPE,
                    "first_only_macro": args.first_only, "files": records,
                    "production_sources": [str(path) for path in production],
                    "host_integration_sources": [str(path) for path in integration],
                    "required_sources": sorted(required), "forbidden_present": [],
                    "planned_commands": commands, "dependency_command": dep_command,
                    "dependency_spec": host.rec(dependency_spec),
                    "dependency_files": receipt["dependency_files"],
                    "dependency_guard": receipt["dependencies"],
                    "launcher": host.rec(attempt / "launcher.json"),
                    "compiler": host.rec(compiler),
                    "external_headers": [host.rec(VITIS / "ap_int.h"), host.rec(VITIS / "hls_stream.h")],
                    "profile": receipt["profile"]}
        manifest_path = attempt / "input_manifest.json"
        write_json(manifest_path, manifest)
        receipt["input_manifest"] = host.rec(manifest_path)
        write_json(receipt_path, receipt)
        for stage, command in commands.items():
            marker = {"oracle": "FULL_CURRENT_EXECUTOR_HANDOFF_FIXTURE_PASS",
                      "run": "FULL_CURRENT_EXECUTOR_STREAM_HOST_PASS"}.get(stage)
            receipt[stage] = guarded(attempt, frozen, stage, command, marker)
            passed = receipt[stage]["status"] == "PASS"
            receipt["status"] = "PASS" if stage == "run" and passed else "RUNNING" if passed else "FAIL"
            receipt["fixture_files"] = [host.rec(path) for path in
                                         sorted((attempt / "fixture").rglob("*")) if path.is_file()]
            if (attempt / "test").is_file():
                receipt["executable"] = host.rec(attempt / "test")
            write_json(receipt_path, receipt)
            print("FULL_CURRENT_EXECUTOR_STREAM_" + stage.upper() + "_" +
                  ("PASS" if passed else "FAIL"), flush=True)
            if not passed:
                return 1
        return 0
    except Exception as error:
        receipt["status"] = "FAIL"
        receipt["error"] = {"type": type(error).__name__, "message": str(error)}
        receipt["frozen_files_at_failure"] = records
        write_json(receipt_path, receipt)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", type=Path)
    parser.add_argument("--first-only", action="store_true")
    parser.add_argument("--dependency-spec", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_spec is not None:
        if args.attempt is not None:
            parser.error("dependency driver is an exclusive internal mode")
        return dependency_driver(args.dependency_spec)
    if args.attempt is None:
        parser.error("--attempt is required")
    return execute(args)


if __name__ == "__main__":
    raise SystemExit(main())
