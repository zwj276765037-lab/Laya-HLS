#!/usr/bin/env python3
"""Freeze and guard a FIRST-only actual-portal admission transport RTL pilot."""
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

import run_executor_checkpoint_rtl as common

ROOT = common.ROOT
PROJECT = common.PROJECT
MODULE = common.MODULE
MARKER = "FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_RTL_PASS"
SCRIPT_MARKER = "FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_SCRIPT_PASS"
HOST_MARKER = "FULL_CURRENT_EXECUTOR_REQUEST_CLOSE_PASS"
SCOPE = (
    "Finite FIRST-only 16x512-bit LAD1 ingress and original receipt through two actual "
    "depth2 FIFOs, bounded complete 8192-bit collector, and the existing managed "
    "laya_generated_provenance_axi_portal_v1 full validator/owner install for STATE0. "
    "The exclusive actual executor A producer lane owns its sole frame at the first "
    "real FIFO write; the producer emits only after real LYRQ/LYMP admission. Wrapper "
    "integration must route that exclusive lane; no new validation bool or receipt-"
    "dependent admission_valid is introduced. Only actual complete valid/ready/accepted "
    "authorizes echo. Real FIFO ingress writes/pops, portal handshakes/accepts, and "
    "receipt writes/reads are independently counted. Ready-only rejection retains the "
    "original A and isolates; a second A is always blocked. Cancel before first write "
    "blocks new ingress, cancel after first write completes the old collection, and "
    "cancel/live physical changes after acceptance preserve the exact original echo "
    "until all 16 actual reads. Tail2/tail1 waits12, blocked portal stability, malformed "
    "reserved bytes, absent STATE0, physical epoch/address/capacity mismatch, and "
    "persistent cancel before acceptance are finite reset-separated diagnostics. "
    "Offline actual C++ executor A and independent literal from a verified host PASS "
    "are frozen and whole-byte compared. The source/receipt peer is TB; physical "
    "STATE0 configuration, adapter idle, and no-work inputs are controlled. No local "
    "validator clone, generated executor same-runtime, full 13BO mapping, source "
    "protection, business retirement, physical request closure, CLOSED/REARM/second "
    "request, complete model/graph, arithmetic, resource/timing or board claim."
)
RTL_NAMES = [
    "laya_model_identity_13bo_generated_v1", "laya_compute_portal_layout_v1",
    "laya_generated_provenance_layout_v1", "laya_private_fifo2_v1",
    "laya_generated_provenance_v1", "laya_generated_provenance_hub_v1",
    "laya_generated_provenance_portal_v1", "laya_generated_store_monitor_v1",
    "laya_generated_provenance_axi_portal_v1", "laya_admission_owner_layout_v1",
    "laya_executor_admission_transport_v1",
]
CAPTURES = [
    "actual_installed_admission", "actual_admission_receipt", "actual_rejected_reserved",
    "actual_rejected_unknown_state0", "actual_rejected_epoch", "actual_rejected_address",
    "actual_rejected_capacity", "actual_canceled_partial", "actual_canceled_waiting",
]
TCL = r'''if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project executor_admission_transport [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach file {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1 laya_generated_store_monitor_v1 laya_generated_provenance_axi_portal_v1 laya_admission_owner_layout_v1 laya_executor_admission_transport_v1} {
  add_files -norecurse [file join $module rtl ${file}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_admission_transport_tb_v1.sv]
set_property top laya_executor_admission_transport_v1 [get_filesets sources_1]
set_property top laya_executor_admission_transport_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado executor_admission_transport.sim sim_1 behav xsim simulate.log]
set stream [open $log r]
set content [read $stream]
close $stream
if {[regexp -all -line {^FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_RTL_PASS(?: |$)} $content]!=1 || [regexp -nocase {(^|\n)[ \t]*(Fatal:|ERROR:)} $content]} {
  error "executor admission transport assertion/marker failed: $log"
}
puts FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_SCRIPT_PASS
close_project
'''


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def read_hex(path):
    lines = path.read_text().splitlines()
    if len(lines) != 16 or any(re.fullmatch(r"[0-9a-fA-F]{128}", line) is None for line in lines):
        raise RuntimeError("not an exact 16-beat 512-bit hex packet: " + str(path))
    return b"".join(int(line, 16).to_bytes(64, "little") for line in lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", type=Path, required=True)
    parser.add_argument("--admission-host", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    frozen = attempt / "frozen"
    result = {"schema": "laya-executor-admission-transport-rtl-receipt-v1",
              "status": "RUNNING", "scope": SCOPE}
    write_json(attempt / "receipt.json", result)
    records = []

    def freeze(source, relative, expected=None):
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        original = common.rec(source)
        if expected is not None and original != expected:
            raise RuntimeError("verified input changed before freezing: " + str(source))
        shutil.copyfile(source, target)
        captured = common.rec(target)
        after = common.rec(source)
        if original["sha256"] != captured["sha256"] or original != after:
            raise RuntimeError("input changed while freezing: " + str(source))
        records.append({"relative": str(relative), "original": original, "frozen": captured})
        return target

    try:
        launcher = common.launcher_state()
        write_json(attempt / "launcher.json", launcher)
        result["launcher"] = common.rec(attempt / "launcher.json")
        if not launcher["pass"]:
            raise RuntimeError("CPU0-3/nice19/idle I/O/MemAvailable>192GiB launcher rejected")
        host = args.admission_host.resolve()
        host_receipt_identity = common.rec(host / "receipt.json")
        host_receipt = json.loads((host / "receipt.json").read_text())
        if common.rec(host / "receipt.json") != host_receipt_identity:
            raise RuntimeError("host receipt changed while reading")
        host_markers = [line for line in host_receipt.get("run", {}).get("markers", [])
                        if line.startswith(HOST_MARKER + " ") or line == HOST_MARKER]
        if (host_receipt.get("status") != "PASS" or len(host_markers) != 1 or
                host_receipt.get("run", {}).get("status") != "PASS"):
            raise RuntimeError("verified actual C++ admission host PASS with unique run marker required")
        for name in ["actual_admission_owner.bin", "admission_owner.bin"]:
            source = host / "fixture" / name
            identity = common.rec(source)
            matches = [record for record in host_receipt.get("fixture_files", [])
                       if record.get("path") == str(source) and
                       record.get("sha256") == identity["sha256"] and
                       record.get("bytes") == identity["bytes"]]
            if len(matches) != 1 or identity["bytes"] != 1024:
                raise RuntimeError("unique 1024-byte host receipt fixture identity required: " + name)
            freeze(source, Path("external/admission_host") / name, identity)
        for name in ["input_manifest.json", "receipt.json"]:
            expected = host_receipt_identity if name == "receipt.json" else None
            freeze(host / name, Path("external/admission_host_run") / name, expected)
        actual = (frozen / "external/admission_host/actual_admission_owner.bin").read_bytes()
        literal = (frozen / "external/admission_host/admission_owner.bin").read_bytes()
        if len(actual) != 1024 or actual != literal:
            raise RuntimeError("complete actual C++ A differs from frozen independent literal")

        files = [MODULE / ("rtl/" + name + ".sv") for name in RTL_NAMES]
        files += [MODULE / "tb/laya_executor_admission_transport_tb_v1.sv",
                  MODULE / "tb/run_executor_admission_transport.py",
                  MODULE / "tb/run_executor_checkpoint_rtl.py",
                  MODULE / "tb/production_guard.py", Path("tools/hls_guard_helpers.py"),
                  Path("include/laya_executor_hls.h"), Path("include/laya_executor_stream.h"),
                  Path("hls/control/executor_stream.cpp")]
        for relative in files:
            freeze(ROOT / relative, relative)
        for name in ["executor_minimum_hardware_chain_reply_20261013.md",
                     "production_hls_partition_contract_20261012.md",
                     "executor_managed_lpv_owner_contract_20261013.md",
                     "executor_bootstrap_source_contract_20261012.md",
                     "executor_first_baseline_program_q_reply_20261013.md"]:
            freeze(PROJECT / "results" / name, Path("external/contracts") / name)
        # This Tcl is a generated attempt input, not a shared standalone file.
        tcl = frozen / MODULE / "tb/run_executor_admission_transport.tcl"
        tcl.write_text(TCL)
        generated = [{"relative": str(tcl.relative_to(frozen)), "identity": common.rec(tcl),
                      "source": "TCL string in frozen run_executor_admission_transport.py"}]
        fixture = attempt / "fixture"
        fixture.mkdir()
        for name, packet in [("actual_admission_owner", actual), ("admission_owner", literal)]:
            path = fixture / (name + ".hex")
            path.write_text("".join(format(int.from_bytes(packet[beat*64:(beat+1)*64], "little"),
                                           "0128x") + "\n" for beat in range(16)))
            if read_hex(path) != packet:
                raise RuntimeError("fixture byte conversion changed A: " + name)
            generated.append({"relative": str(path.relative_to(attempt)), "identity": common.rec(path),
                              "source": "byte-preserving hex of frozen " + name + ".bin"})
        vivado = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
        command = [str(vivado), "-mode", "batch", "-notrace", "-log", str(attempt / "vivado.log"),
                   "-journal", str(attempt / "vivado.jou"), "-source", str(tcl),
                   "-tclargs", str(attempt / "work"), str(frozen), str(fixture)]
        output = attempt / "guard_rtl"
        guarded = [sys.executable, str(frozen / MODULE / "tb/production_guard.py"),
                   "--out", str(output), "--cwd", str(frozen), "--rss-gib", "8",
                   "--timeout-seconds", "120", "--semantic-stall-seconds", "120", "--", *command]
        manifest = {"schema": "laya-executor-admission-transport-rtl-input-v1", "scope": SCOPE,
                    "files": records, "generated_inputs": generated, "admission_host": str(host),
                    "host_run_marker": host_markers[0],
                    "host_manifest": common.rec(frozen / "external/admission_host_run/input_manifest.json"),
                    "host_receipt": common.rec(frozen / "external/admission_host_run/receipt.json"),
                    "launcher": common.rec(attempt / "launcher.json"), "tool": common.rec(vivado),
                    "planned_command": command, "planned_guard_command": guarded,
                    "expected_captures": CAPTURES, "cycle_cap": 5000, "diagnostics": 8,
                    "profile": {"kind": "finite_rtl_pilot", "rss_gib": 8,
                                "timeout_seconds": 120, "semantic_stall_seconds": 120}}
        manifest_path = attempt / "input_manifest.json"
        write_json(manifest_path, manifest)
        result["input_manifest"] = common.rec(manifest_path)
        result["fixture_files"] = [common.rec(path) for path in sorted(fixture.iterdir())]
        write_json(attempt / "receipt.json", result)
        process = subprocess.run(guarded, cwd=frozen)
        guard_path = output / "guard_result.json"
        guard = json.loads(guard_path.read_text()) if guard_path.is_file() else None
        driver = output / "driver.log"
        body = driver.read_text(errors="replace") if driver.is_file() else ""
        log = attempt / "work/vivado/executor_admission_transport.sim/sim_1/behav/xsim/simulate.log"
        sim_body = log.read_text(errors="replace") if log.is_file() else ""
        # Vivado may display simulation output in both logs. Enforce uniqueness
        # independently in simulate.log and for the outer script completion.
        markers = [line for line in sim_body.splitlines() if line.startswith(MARKER + " ")]
        script_markers = [line for line in body.splitlines() if line.strip() == SCRIPT_MARKER]
        passed = (process.returncode == 0 and guard is not None and guard["child_exit_code"] == 0 and
                  guard["trigger"] is None and len(markers) == 1 and len(script_markers) == 1 and
                  re.search(r"(^|\n)[ \t]*(Fatal:|ERROR:)", body + "\n" + sim_body, re.I) is None)
        capture_checks = []
        for name in CAPTURES:
            path = fixture / (name + ".hex")
            item = {"name": name, "present": path.is_file()}
            if path.is_file():
                item["identity"] = common.rec(path)
                try:
                    packet = read_hex(path)
                except (RuntimeError, ValueError) as error:
                    item["decode_error"] = str(error)
                    passed = False
                    capture_checks.append(item)
                    continue
                expected = bytearray(actual)
                if name == "actual_rejected_reserved":
                    expected[888] = 1
                elif name == "actual_rejected_unknown_state0":
                    expected[12:16] = (32).to_bytes(4, "little")
                    expected[696:720] = actual[720:744]
                    expected[720:744] = bytes(24)
                elif name in ["actual_rejected_epoch", "actual_rejected_address", "actual_rejected_capacity"]:
                    offset = {"actual_rejected_epoch": 720, "actual_rejected_address": 728,
                              "actual_rejected_capacity": 736}[name]
                    delta = 1 if offset == 720 else 64
                    expected[offset:offset+8] = (int.from_bytes(actual[offset:offset+8], "little") +
                                                 delta).to_bytes(8, "little")
                item["exact_expected_packet"] = packet == expected
                passed = passed and item["exact_expected_packet"]
            else:
                passed = False
            capture_checks.append(item)
        result["rtl"] = {"status": "PASS" if passed else "FAIL", "started": True,
                         "command": command, "guard_command": guarded,
                         "runner_exit_code": process.returncode, "guard": guard,
                         "markers": markers, "script_markers": script_markers,
                         "capture_checks": capture_checks,
                         "raw_files": [common.rec(path) for path in sorted(output.rglob("*")) if path.is_file()]}
        result["status"] = "PASS" if passed else "COST_STOP" if guard and guard["trigger"] else "FAIL"
        result["fixture_files"] = [common.rec(path) for path in sorted(fixture.iterdir()) if path.is_file()]
        result["vivado_raw_files"] = [common.rec(path) for path in sorted((attempt / "work").rglob("*.log"))
                                      if path.is_file()]
        for path in [attempt / "vivado.log", attempt / "vivado.jou"]:
            if path.is_file():
                result["vivado_raw_files"].append(common.rec(path))
        write_json(attempt / "receipt.json", result)
        print("FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_" + result["status"], flush=True)
        return 0 if passed else 1
    except Exception as error:
        result["status"] = "FAIL"
        result["error"] = {"type": type(error).__name__, "message": str(error)}
        result["frozen_files_at_failure"] = records
        write_json(attempt / "receipt.json", result)
        raise


if __name__ == "__main__":
    raise SystemExit(main())
