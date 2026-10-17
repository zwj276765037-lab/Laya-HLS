#!/usr/bin/env python3
"""Freeze finite depth2 control-transport checks with the original shell."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys

import run_executor_checkpoint_rtl as common

ROOT = common.ROOT
PROJECT = common.PROJECT
MODULE = common.MODULE
SCOPE = (
    "Finite RTL control bridge with actual original handoff shell and depth2 512-bit "
    "request, request-echo and response FIFOs. Full 16-beat request collection precedes "
    "the shell's actual 8192-bit consumer handshake; only that handshake emits the "
    "original 16-beat echo. Real response FIFO writes and actual pops are counted "
    "separately; neither last write nor last pop acknowledges the shell. An independent "
    "8192-bit accepted record must match the retained stable full response after all "
    "16 writes and reads before accepted-lane full_n allows its actual write to "
    "acknowledge the shell. Early/foreign/replayed accepted attempts have full_n=0, "
    "no actual fire and no receipt count increment; only the separate rejection lane "
    "actually consumes and counts bounded notifications without release. Tail2/tail1 "
    "waits12, blocked early/foreign/replayed accepted attempts, matching "
    "rejection, cancellation in a partial request, immutable GRANT with pending ABORT, "
    "and persistent cancel old-response/cleanup progress. Exact accepted CLOSED receipt "
    "also supplies the original managed shell's complete closed-consumer record once. "
    "Offline actual C++ helper control stimuli and independent literal response gold "
    "are frozen from a verified helper-only host attempt. The executor-side full "
    "consumer is a TB byte-oracle peer, not generated executor RTL. Predecessor/safety/"
    "protection, query bytes/consumer pulses, terminal work and Host facts are controlled. "
    "Reset separates diagnostic cases; no reset is used to clear an active canceled "
    "half-frame or presented response. No same-runtime HLS executor/helper, real hub/"
    "monitor/LPV/AXI, production source protection, actual request retirement, physical "
    "safe closure/rearm, full model/graph, arithmetic, OOC, resources, timing or board claim."
)


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", type=Path, required=True)
    parser.add_argument("--helper-attempt", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    frozen = attempt / "frozen"
    result = {"schema": "laya-executor-control-transport-rtl-receipt-v1",
              "status": "RUNNING", "scope": SCOPE}
    write_json(attempt / "receipt.json", result)
    records = []

    def freeze(source, relative):
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        original = common.rec(source)
        shutil.copyfile(source, target)
        captured = common.rec(target)
        if original["sha256"] != captured["sha256"]:
            raise RuntimeError("input changed while freezing: " + str(source))
        records.append({"relative": str(relative), "original": original, "frozen": captured})

    try:
        launcher = common.launcher_state()
        write_json(attempt / "launcher.json", launcher)
        result["launcher"] = common.rec(attempt / "launcher.json")
        if not launcher["pass"]:
            raise RuntimeError("CPU0-3/nice19/idle I/O/MemAvailable>192GiB launcher rejected")
        helper = args.helper_attempt.resolve()
        helper_receipt = json.loads((helper / "receipt.json").read_text())
        if (helper_receipt["status"] != "PASS" or not any(
                "FULL_CURRENT_EXECUTOR_SHELL_HELPER_PASS" in line
                for line in helper_receipt.get("run", {}).get("markers", []))):
            raise RuntimeError("verified actual C++ helper-only host attempt required")
        helper_names = ["actual_helper_hold.bin", "actual_helper_query.bin",
                        "helper_proof_stimulus.bin", "actual_helper_import_ok.bin",
                        "actual_helper_abort.bin", "control_2.bin", "control_3.bin",
                        "control_4.bin", "control_6.bin"]
        for name in helper_names:
            source = helper / "fixture" / name
            identity = common.rec(source)
            if not any(record["path"] == str(source) and record["sha256"] == identity["sha256"]
                       for record in helper_receipt["fixture_files"]):
                raise RuntimeError("helper fixture identity mismatch: " + name)
            freeze(source, Path("external/helper") / name)
        for name in ["input_manifest.json", "receipt.json"]:
            freeze(helper / name, Path("external/helper_run") / name)
        files = [MODULE / "rtl/laya_executor_handoff_layout_v1.sv",
                 MODULE / "rtl/laya_private_fifo2_v1.sv",
                 MODULE / "rtl/laya_executor_handoff_shell_v1.sv",
                 MODULE / "rtl/laya_executor_control_transport_v1.sv",
                 MODULE / "tb/laya_executor_control_transport_tb_v1.sv",
                 MODULE / "tb/run_executor_control_transport.tcl",
                 MODULE / "tb/run_executor_control_transport_rtl.py",
                 MODULE / "tb/run_executor_checkpoint_rtl.py",
                 MODULE / "tb/production_guard.py", Path("tools/hls_guard_helpers.py"),
                 Path("tests/executor_handoff_shell_fixture.py"),
                 Path("include/laya_executor_hls.h"), Path("include/laya_executor_stream.h"),
                 Path("hls/control/executor_stream.cpp")]
        for relative in files:
            freeze(ROOT / relative, relative)
        for name in ["executor_checkpoint_import_handshake_contract_20261013.md",
                     "executor_checkpoint_high_water_contract_20261012.md",
                     "executor_close_rearm_contract_20261013.md",
                     "executor_minimum_hardware_chain_reply_20261013.md"]:
            freeze(PROJECT / "results" / name, Path("external/contracts") / name)

        fixture = attempt / "fixture"
        oracle = [sys.executable, str(frozen / "tests/executor_handoff_shell_fixture.py"),
                  "--helper", str(frozen / "external/helper"), "--output", str(fixture)]
        vivado = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
        rtl = [str(vivado), "-mode", "batch", "-notrace", "-log", str(attempt / "vivado.log"),
               "-journal", str(attempt / "vivado.jou"), "-source",
               str(frozen / MODULE / "tb/run_executor_control_transport.tcl"),
               "-tclargs", str(attempt / "work"), str(frozen), str(fixture)]
        commands = {"oracle": oracle, "rtl": rtl}
        manifest = {"schema": "laya-executor-control-transport-rtl-input-v1", "scope": SCOPE,
                    "files": records, "helper_attempt": str(helper),
                    "helper_manifest": common.rec(helper / "input_manifest.json"),
                    "helper_receipt": common.rec(helper / "receipt.json"),
                    "launcher": common.rec(attempt / "launcher.json"), "tool": common.rec(vivado),
                    "planned_commands": commands, "cycle_cap": 5000,
                    "profile": {"kind": "finite_rtl_pilot", "rss_gib": 8,
                                "timeout_seconds": 120, "semantic_stall_seconds": 120}}
        manifest_path = attempt / "input_manifest.json"
        write_json(manifest_path, manifest)
        result["input_manifest"] = common.rec(manifest_path)
        write_json(attempt / "receipt.json", result)
        for stage, command in commands.items():
            output = attempt / ("guard_" + stage)
            guarded = [sys.executable, str(frozen / MODULE / "tb/production_guard.py"),
                       "--out", str(output), "--cwd", str(frozen), "--rss-gib", "8",
                       "--timeout-seconds", "120", "--semantic-stall-seconds", "120", "--", *command]
            process = subprocess.run(guarded)
            guard_path = output / "guard_result.json"
            guard = json.loads(guard_path.read_text()) if guard_path.is_file() else None
            log = output / "driver.log"
            body = log.read_text(errors="replace") if log.is_file() else ""
            marker = ("FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_FIXTURE_PASS" if stage == "oracle"
                      else "FULL_CURRENT_EXECUTOR_CONTROL_TRANSPORT_RTL_PASS")
            passed = (process.returncode == 0 and guard is not None and
                      guard["child_exit_code"] == 0 and guard["trigger"] is None and body.count(marker) == 1)
            result[stage] = {"status": "PASS" if passed else "FAIL", "started": True,
                             "command": command, "guard_command": guarded,
                             "runner_exit_code": process.returncode, "guard": guard,
                             "markers": [line for line in body.splitlines() if marker in line],
                             "raw_files": [common.rec(path) for path in sorted(output.rglob("*")) if path.is_file()]}
            result["status"] = "PASS" if stage == "rtl" and passed else "RUNNING" if passed else "FAIL"
            result["fixture_files"] = [common.rec(path) for path in sorted(fixture.rglob("*")) if path.is_file()]
            result["vivado_raw_files"] = [common.rec(path) for path in
                                         sorted((attempt / "work").rglob("*.log")) if path.is_file()]
            for path in [attempt / "vivado.log", attempt / "vivado.jou"]:
                if path.is_file():
                    result["vivado_raw_files"].append(common.rec(path))
            write_json(attempt / "receipt.json", result)
            print("FULL_CURRENT_EXECUTOR_CONTROL_TRANSPORT_" + stage.upper() + "_" +
                  ("PASS" if passed else "FAIL"), flush=True)
            if not passed:
                return 1
        return 0
    except Exception as error:
        result["status"] = "FAIL"
        result["error"] = {"type": type(error).__name__, "message": str(error)}
        result["frozen_files_at_failure"] = records
        write_json(attempt / "receipt.json", result)
        raise


if __name__ == "__main__":
    raise SystemExit(main())
