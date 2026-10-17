#!/usr/bin/env python3
"""Freeze and run the finite adapter LPV owner sidecar; no generated core claim."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
MARKER = "FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_PASS"
CASE_MARKER = "FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_CASE_PASS"
SCOPE = (
    "Finite raw-byte LPV sidecar with complete LAD1/installed-A match at a controlled "
    "txn_start representing the real first LTX1 pop, immutable A/route through an "
    "actual depth2 mock-LTC FIFO final caller pop, generated-command peer depth2 "
    "input, full 16-beat collector before any portal first beat, tagged immutable "
    "pending and candidate, and exactly eight response ingress/consumer pops with "
    "a private depth2 return FIFO. Independent frozen managed-LPV literals verify "
    "every raw command/response byte. Four reset-separated cases cover invalid "
    "new A, two no-LPV compute/producer local transactions, request/response/LTC "
    "tail2/tail1 waits12, persistent revoke and live A/route changes after two "
    "command pushes, premature actual mock-LTC end during a half frame or response "
    "tail, continuing old cleanup and blocking new transactions. No reset within "
    "an active case. Peers and txn_start/A installation are controlled; no actual "
    "generated adapter or executor, LTX/LTC codec evidence, hub operation/retirement, "
    "physical monitor fence, source AR/F9, full tensor/production chain, CLOSED, "
    "rearm, resources, timing or board claim. txn_drained is an old-adapter local "
    "transport fact, not monitor.adapter_pending_zero. External A remains installed."
)
TCL = r'''if {[llength $argv]!=3} {error "usage: WORK ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project executor_adapter_lpv_owner [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach name {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_executor_adapter_lpv_owner_v1} {
  add_files -norecurse [file join $module rtl ${name}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_adapter_lpv_owner_tb_v1.sv]
set_property top laya_executor_adapter_lpv_owner_v1 [get_filesets sources_1]
set_property top laya_executor_adapter_lpv_owner_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set path [file join $work vivado executor_adapter_lpv_owner.sim sim_1 behav xsim simulate.log]
set f [open $path r]
set body [read $f]
close $f
if {[string first FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_PASS $body]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {
  error "adapter LPV sidecar assertion failed: $path"
}
puts FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_SCRIPT_PASS
close_project
'''


def rec(path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def launcher_state():
    available = next(int(line.split()[1]) for line in
                     Path("/proc/meminfo").read_text().splitlines()
                     if line.startswith("MemAvailable:"))
    value = {"pid": os.getpid(), "cpu_affinity": sorted(os.sched_getaffinity(0)),
             "nice": os.getpriority(os.PRIO_PROCESS, 0),
             "ionice": subprocess.run(["ionice", "-p", str(os.getpid())],
                                      check=True, text=True, capture_output=True).stdout.strip(),
             "mem_available_kib": available,
             "required_mem_available_kib": 192 * 1024 * 1024}
    value["pass"] = (value["cpu_affinity"] == [0, 1, 2, 3] and value["nice"] == 19 and
                     value["ionice"].startswith("idle") and
                     available > value["required_mem_available_kib"])
    return value


def literal_bytes(path, beats):
    lines = path.read_text().splitlines()
    if len(lines) != beats or any(len(line) != 128 or
                                any(c not in "0123456789abcdefABCDEF" for c in line)
                                for line in lines):
        raise RuntimeError("literal is not the required complete 512-bit frame: " + str(path))
    return b"".join(int(line, 16).to_bytes(64, "little") for line in lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", type=Path, required=True)
    parser.add_argument("--managed-lpv-attempt", type=Path, required=True)
    parser.add_argument("--prepare-only", action="store_true")
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    frozen = attempt / "frozen"
    result = {"schema": "laya-executor-adapter-lpv-owner-receipt-v1", "status": "RUNNING",
              "scope": SCOPE, "rtl": {"status": "NOT_RUN", "started": False}}
    write_json(attempt / "receipt.json", result)
    records = []

    def freeze(source, relative, expected=None):
        original = rec(source)
        if expected is not None and (original["sha256"] != expected["sha256"] or
                                     original["bytes"] != expected["bytes"]):
            raise RuntimeError("referenced frozen identity mismatch: " + str(source))
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        identity = rec(target)
        if (identity["sha256"], identity["bytes"]) != (original["sha256"], original["bytes"]):
            raise RuntimeError("input changed during freeze: " + str(source))
        records.append({"relative": str(relative), "original": original, "frozen": identity})
        return target

    try:
        launcher = launcher_state()
        write_json(attempt / "launcher.json", launcher)
        result["launcher"] = rec(attempt / "launcher.json")
        if not launcher["pass"]:
            raise RuntimeError("CPU0-3/nice19/idle I/O/MemAvailable>192GiB preflight failed")
        prior = args.managed_lpv_attempt.resolve()
        prior_receipt = json.loads((prior / "receipt.json").read_text())
        prior_manifest = json.loads((prior / "input_manifest.json").read_text())
        guard_result = prior_receipt.get("guard_result", {})
        if (prior_receipt.get("status") != "PASS" or guard_result.get("child_exit_code") != 0 or
                guard_result.get("trigger") is not None):
            raise RuntimeError("completed PASS managed LPV literal source required")
        if prior_receipt["input_manifest"] != rec(prior / "input_manifest.json"):
            raise RuntimeError("managed LPV manifest no longer matches its completed receipt")
        for name in ["receipt.json", "input_manifest.json"]:
            freeze(prior / name, Path("external/managed_lpv") / name)
        fixture = frozen / "external/fixture"
        expected = {Path(row["path"]).name: row for row in prior_manifest["fixture_files"]}
        names = ["admission.hex", "claim.hex", "claim_gold.hex",
                 "preowned_claim.hex", "preowned_claim_gold.hex"]
        for name in names:
            freeze(prior / "fixture" / name, Path("external/fixture") / name, expected[name])
        admission_binary = {}
        for row in prior_manifest["admission_host"]:
            name = Path(row["frozen"]["path"]).name
            if name in ["actual_admission_owner.bin", "admission_owner.bin"]:
                admission_binary[name] = freeze(Path(row["frozen"]["path"]),
                    Path("external/managed_lpv") / name, row["frozen"])
        if set(admission_binary) != {"actual_admission_owner.bin", "admission_owner.bin"}:
            raise RuntimeError("actual A plus independent admission literal provenance missing")
        owner = literal_bytes(fixture / "admission.hex", 16)
        if owner != admission_binary["actual_admission_owner.bin"].read_bytes() or \
                owner != admission_binary["admission_owner.bin"].read_bytes():
            raise RuntimeError("actual C++ A/independent literal/hex bytes differ")
        for name in ["claim", "preowned_claim"]:
            literal_bytes(fixture / (name + ".hex"), 16)
            literal_bytes(fixture / (name + "_gold.hex"), 8)
        files = [MODULE / "rtl/laya_model_identity_13bo_generated_v1.sv",
                 MODULE / "rtl/laya_compute_portal_layout_v1.sv",
                 MODULE / "rtl/laya_generated_provenance_layout_v1.sv",
                 MODULE / "rtl/laya_private_fifo2_v1.sv",
                 MODULE / "rtl/laya_executor_adapter_lpv_owner_v1.sv",
                 MODULE / "tb/laya_executor_adapter_lpv_owner_tb_v1.sv",
                 MODULE / "tb/run_executor_adapter_lpv_owner.py",
                 MODULE / "tb/production_guard.py", Path("tools/hls_guard_helpers.py")]
        for relative in files:
            freeze(ROOT / relative, relative)
        freeze(PROJECT / "results/executor_managed_lpv_owner_contract_20261013.md",
               Path("external/contracts/executor_managed_lpv_owner_contract_20261013.md"))
        script = attempt / "run_executor_adapter_lpv_owner.tcl"
        script.write_text(TCL)
        vivado = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
        rtl = [str(vivado), "-mode", "batch", "-notrace", "-log", str(attempt / "vivado.log"),
               "-journal", str(attempt / "vivado.jou"), "-source", str(script),
               "-tclargs", str(attempt / "work"), str(frozen), str(fixture)]
        guard = [sys.executable, str(frozen / MODULE / "tb/production_guard.py"),
                 "--out", str(attempt / "guard_rtl"), "--cwd", str(frozen), "--rss-gib", "8",
                 "--timeout-seconds", "120", "--semantic-stall-seconds", "120", "--", *rtl]
        manifest = {"schema": "laya-executor-adapter-lpv-owner-input-v1", "scope": SCOPE,
                    "files": records, "derived_tcl": rec(script), "tool": rec(vivado),
                    "launcher": rec(attempt / "launcher.json"), "planned_rtl_command": rtl,
                    "planned_guard_command": guard, "case_count": 4, "cycle_cap": 4000,
                    "literal_source": str(prior),
                    "profile": {"kind": "finite_rtl_pilot", "rss_gib": 8,
                                "timeout_seconds": 120, "semantic_stall_seconds": 120}}
        write_json(attempt / "input_manifest.json", manifest)
        result["input_manifest"] = rec(attempt / "input_manifest.json")
        if args.prepare_only:
            result["status"] = "PREPARED_NOT_RUN"
            write_json(attempt / "receipt.json", result)
            print("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_PREPARED_NOT_RUN", flush=True)
            return 0
        write_json(attempt / "receipt.json", result)
        process = subprocess.run(guard, cwd=frozen)
        output = attempt / "guard_rtl"
        guard_path = output / "guard_result.json"
        observed_guard = json.loads(guard_path.read_text()) if guard_path.is_file() else None
        log = output / "driver.log"
        body = log.read_text(errors="replace") if log.is_file() else ""
        markers = [line for line in body.splitlines() if line.startswith(MARKER + " ")]
        case_lines = [line for line in body.splitlines() if line.startswith(CASE_MARKER + " ")]
        complete_cases = len(case_lines) == 4 and all(
            sum(line.startswith(CASE_MARKER + " case=" + str(i) + " ") for line in case_lines) == 1
            for i in range(4))
        passed = (process.returncode == 0 and observed_guard is not None and
                  observed_guard["child_exit_code"] == 0 and observed_guard["trigger"] is None and
                  len(markers) == 1 and complete_cases and "Fatal:" not in body and "ERROR:" not in body)
        result["rtl"] = {"status": "PASS" if passed else "FAIL", "started": True,
                         "runner_exit_code": process.returncode, "guard": observed_guard,
                         "markers": markers, "case_markers": case_lines,
                         "raw_files": [rec(p) for p in sorted(output.rglob("*")) if p.is_file()]}
        result["vivado_logs"] = [rec(p) for p in sorted((attempt / "work").rglob("*.log")) if p.is_file()]
        for p in [attempt / "vivado.log", attempt / "vivado.jou"]:
            if p.is_file():
                result["vivado_logs"].append(rec(p))
        result["status"] = "PASS_SCOPED_RTL_SIDECAR" if passed else \
            "COST_STOP" if observed_guard and observed_guard["trigger"] is not None else "FAIL"
        write_json(attempt / "receipt.json", result)
        print("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_RUN_" + result["status"], flush=True)
        return 0 if passed else 1
    except Exception as error:
        result["status"] = "FAIL"
        result["error"] = {"type": type(error).__name__, "message": str(error)}
        result["frozen_files_at_failure"] = records
        write_json(attempt / "receipt.json", result)
        raise


if __name__ == "__main__":
    raise SystemExit(main())
