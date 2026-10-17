#!/usr/bin/env python3
"""Freeze and run a finite real-shell/control-transport v2 source guard pilot."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
MARKER = "FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_PASS"
CASE_MARKER = "FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_CASE_PASS"
SCOPE = (
    "Finite new v2 internal source guard plus actual control transport and handoff "
    "shell. Initial old K/B is the complete real shell retained HOLD with allocated "
    "H; only an actual complete GRANTED receipt, after 16 real response FIFO pops "
    "and the independent TB consumer whole-byte validation, can open action/producer. "
    "Full original B1/S64 identity, model, source HIDDEN STATE0 and target NORM "
    "STATE0 declaration are retained. Four rows16 producer windows and a controlled "
    "S64-success LAC exercise full owner/task-count rules; the finite memory peer "
    "issues four AR bursts of four beats, NOT the full tensor or generated LN. "
    "Actual depth2 F9-validated-completion and LAC peer FIFOs with tail2/tail1 "
    "waits12 supply final physical consumer edges. F9 validation, query, physical "
    "fences, source-match and original NORM action/producer/completion peers are "
    "controlled; F9 raw-engine codec execution is NOT_RUN. Six reset-separated "
    "cases cover wrong/stale K, commit, reserved/status/source/base receipt "
    "backpressure; zero AR before real grant; four declared windows; source write "
    "isolation while permitting the exact accepted NORM producer target window; "
    "old VALID AR retained under backpressure, persistent cancel/live base change "
    "and old final R/F9/LAC drain; sticky source mutation revoke; RRESP/RLAST "
    "error debt drain with diagnostic isolation; and a malformed full old K "
    "actually retained by the real shell. No reset while producer/R/FIFO debt "
    "exists. Local guard completion leaves old shell request locks installed. "
    "No Host/service wire, publication table, logical-version correction, D, "
    "QUANT, CLOSE/rearm, generated executor/program/adapter/LN same-runtime "
    "chain, full numeric tensor, hub/monitor retirement, OOC/timing or board claim."
)
TCL = r'''if {[llength $argv]!=4} {error "usage: WORK ROOT FIXTURE CAPTURE"}
lassign $argv work root fixture capture
set_param general.maxThreads 4
create_project executor_source_guard_v2 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach name {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_executor_handoff_layout_v1 laya_private_fifo2_v1 laya_executor_control_transport_v1 laya_executor_handoff_shell_v1 laya_executor_source_guard_v2} {
  add_files -norecurse [file join $module rtl ${name}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_source_guard_v2_tb.sv]
set_property top laya_executor_source_guard_v2 [get_filesets sources_1]
set_property top laya_executor_source_guard_v2_tb [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture -testplusarg CAPTURE=$capture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set path [file join $work vivado executor_source_guard_v2.sim sim_1 behav xsim simulate.log]
set f [open $path r]
set body [read $f]
close $f
if {[string first FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_PASS $body]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {
  error "v2 source guard assertion failed: $path"
}
puts FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_SCRIPT_PASS
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
        raise RuntimeError("literal is not a complete 512-bit frame: " + str(path))
    return b"".join(int(line, 16).to_bytes(64, "little") for line in lines)


def independent_peer_literals(action, producer, error, hold):
    """Controlled protocol peers, derived offline; no RTL-generated gold."""
    if len(action) != 512 or len(producer) != 1024 or len(error) != 256 or len(hold) != 1024:
        raise RuntimeError("complete controlled action/producer/LAC/B records required")
    u16 = lambda p, o: struct.unpack_from("<H", p, o)[0]
    u64 = lambda p, o: struct.unpack_from("<Q", p, o)[0]
    if (u16(hold, 80), u16(hold, 82), u16(hold, 598)) != (1, 64, 64):
        raise RuntimeError("full B1/S64 source declaration required")
    if action[64:148] != hold[64:148] or producer[64:148] != hold[64:148] or \
            producer[160:576] != hold[160:576]:
        raise RuntimeError("frozen original LAX/LPE full identity/model differs from real HOLD B")
    if action[176:184] != hold[576:584] or producer[576:584] != hold[576:584] or \
            action[184:195] != hold[592:603]:
        raise RuntimeError("frozen original complete source owner differs from real HOLD B")
    if hold[674:678] != bytes([2, 0, 0, 6]) or u64(hold, 712) != 8388608 or \
            u64(hold, 640) != 262144 or u64(hold, 720) != 262144 or \
            hold[688:712] != hold[40:64] or u64(hold, 624) != 4096 or \
            u64(hold, 632) != 4194304:
        raise RuntimeError("real HIDDEN/NORM B/base/extent/stride binding incompatible")
    if action[225:228] != hold[674:677] or producer[588:591] != hold[674:677] or \
            producer[597:599] != bytes([6, 6]):
        raise RuntimeError("original NORM target reference/role is not the declared B target")
    if error[8:13] != action[8:13] or error[24:32] != action[24:32] or \
            error[64:148] != action[64:148] or u16(error, 148) != 7 or \
            struct.unpack_from("<I", error, 16)[0] != 15:
        raise RuntimeError("independent original safe-error LAC is incompatible")
    p = bytearray(producer)
    # v1 controlled fixture used a separate target offset. Only the physical
    # destination offset is rebased to the real existing K target description.
    # Full original B1/S64, op, LAX slot/version and target BufferRef are retained.
    struct.pack_into("<Q", p, 616, u64(hold, 712))
    outputs = {"action": action, "producer": bytes(p), "completion_error": error}
    complete = bytearray(error)
    struct.pack_into("<I", complete, 16, 63)
    struct.pack_into("<H", complete, 148, 0)
    struct.pack_into("<I", complete, 152, 0)
    struct.pack_into("<IIH", complete, 164, 5, 8, 4)
    complete[176] = action[224]
    complete[184:192] = action[232:240]
    complete[192:200] = p[584:592]
    complete[200:204] = bytes([action[11], action[12], 255, 0])
    struct.pack_into("<HHH", complete, 204, 0, 64, 1024)
    complete[210] = 1
    outputs["completion_success"] = bytes(complete)
    for window in range(4):
        q = bytearray(p)
        struct.pack_into("<QQ", q, 16, 1 + window, 12 + window)
        struct.pack_into("<I", q, 148, 5 + window)
        struct.pack_into("<H", q, 157, 16 * window)
        struct.pack_into("<QQ", q, 608, 65536 * window, 8388608 + 65536 * window)
        c = bytearray(512)
        struct.pack_into("<IHHHHBB", c, 0, 0x3143504c, 1, 8, 1, 7, 0, 1)
        c[16:32] = q[16:32]
        struct.pack_into("<I", c, 32, 0x0700000e)
        struct.pack_into("<Q", c, 40, (1 << 64) - 1)
        struct.pack_into("<Q", c, 56, 256)  # finite mock-R bytes, not full window
        c[64:160] = q[64:160]
        c[160:176] = q[576:592]
        c[176:180] = bytes([q[597], q[598], q[595], q[596]])
        c[180:182] = q[592:594]
        c[182] = q[594]
        c[184:192] = q[600:608]
        c[192:224] = q[608:640]
        outputs["f9_window" + str(window)] = bytes(c)
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--attempt", type=Path, required=True)
    parser.add_argument("--control-attempt", type=Path, required=True)
    parser.add_argument("--bootstrap-guard-attempt", type=Path, required=True)
    parser.add_argument("--prepare-only", action="store_true")
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    frozen = attempt / "frozen"
    result = {"schema": "laya-executor-source-guard-v2-receipt-v1", "status": "RUNNING",
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

    def prior_pass(prior, label):
        receipt = json.loads((prior / "receipt.json").read_text())
        manifest = json.loads((prior / "input_manifest.json").read_text())
        guard = receipt.get("guard_result", receipt.get("rtl", {}).get("guard", {}))
        if (receipt.get("status") != "PASS" or guard.get("child_exit_code") != 0 or
                guard.get("trigger") is not None or
                receipt["input_manifest"] != rec(prior / "input_manifest.json")):
            raise RuntimeError("completed unmodified PASS " + label + " literal source required")
        for name in ["receipt.json", "input_manifest.json"]:
            freeze(prior / name, Path("external") / label / name)
        return receipt, manifest

    try:
        launcher = launcher_state()
        write_json(attempt / "launcher.json", launcher)
        result["launcher"] = rec(attempt / "launcher.json")
        if not launcher["pass"]:
            raise RuntimeError("CPU0-3/nice19/idle I/O/MemAvailable>192GiB preflight failed")
        control = args.control_attempt.resolve()
        bootstrap = args.bootstrap_guard_attempt.resolve()
        cr, cm = prior_pass(control, "control")
        br, bm = prior_pass(bootstrap, "bootstrap")
        c_expected = {Path(row["path"]).name: row for row in cr["fixture_files"]}
        fixture = frozen / "external/fixture"
        packets = {}
        for name in ["hold", "query", "proof", "import_ok", "abort", "held_gold", "grant_gold"]:
            target = freeze(control / "fixture" / (name + ".hex"),
                            Path("external/fixture") / (name + ".hex"), c_expected[name + ".hex"])
            packets[name] = literal_bytes(target, 16)
        actual_grant = freeze(control / "fixture/actual_success_grant.hex",
                             Path("external/control/actual_success_grant.hex"),
                             c_expected["actual_success_grant.hex"])
        if literal_bytes(actual_grant, 16) != packets["grant_gold"]:
            raise RuntimeError("prior actual accepted GRANTED differs from independent whole-record gold")
        helper_binary = {}
        for row in cm["files"]:
            if row["relative"].startswith("external/helper/"):
                helper_binary[Path(row["relative"]).name] = freeze(Path(row["frozen"]["path"]),
                    Path("external/control") / row["relative"], row["frozen"])
        for name, binary in [("hold", "actual_helper_hold.bin"), ("query", "actual_helper_query.bin"),
                             ("proof", "helper_proof_stimulus.bin"), ("import_ok", "actual_helper_import_ok.bin"),
                             ("abort", "actual_helper_abort.bin")]:
            if helper_binary[binary].read_bytes() != packets[name]:
                raise RuntimeError("actual C++ helper full control source identity mismatch: " + name)
        for name, binary in [("held_gold", "control_2.bin"), ("grant_gold", "control_4.bin")]:
            independent = bytearray(helper_binary[binary].read_bytes())
            struct.pack_into("<Q", independent, 680, 1)
            if bytes(independent) != packets[name]:
                raise RuntimeError("independent complete control response literal mismatch: " + name)
        # Full K equality, without normalizing away reserved, commit or status.
        expected = bytearray(packets["hold"])
        struct.pack_into("<Q", expected, 680, 1)
        expected[8] = 4
        expected[792] = 1
        if bytes(expected) != packets["grant_gold"]:
            raise RuntimeError("real GRANTED does not exactly echo complete old HOLD K/B")
        b_expected = {Path(row["path"]).name: row for row in bm["fixture_files"]}
        independent = {}
        for name, beats in [("snapshot", 12), ("guard_action", 8), ("guard_producer", 16),
                            ("guard_completion", 4)]:
            for ext in ["bin", "hex"]:
                target = freeze(bootstrap / "fixture" / (name + "." + ext),
                    Path("external/bootstrap/fixture") / (name + "." + ext), b_expected[name + "." + ext])
                if ext == "bin":
                    independent[name] = target.read_bytes()
                elif literal_bytes(target, beats) != independent[name]:
                    raise RuntimeError("independent original binary/hex literal mismatch: " + name)
        if independent["snapshot"][40:664] != packets["hold"][40:664]:
            raise RuntimeError("v1 controlled source B differs from real old shell full B")
        derived = independent_peer_literals(independent["guard_action"], independent["guard_producer"],
                                            independent["guard_completion"], packets["hold"])
        derived_records = []
        for name, data in derived.items():
            binary = fixture / (name + ".bin")
            hexf = fixture / (name + ".hex")
            binary.write_bytes(data)
            hexf.write_text("".join(data[i:i+64][::-1].hex() + "\n" for i in range(0, len(data), 64)))
            if literal_bytes(hexf, len(data) // 64) != data:
                raise RuntimeError("derived independent byte/hex roundtrip mismatch")
            derived_records.extend([rec(binary), rec(hexf)])
        names = ["laya_model_identity_13bo_generated_v1", "laya_compute_portal_layout_v1",
                 "laya_generated_provenance_layout_v1", "laya_executor_handoff_layout_v1",
                 "laya_private_fifo2_v1", "laya_executor_control_transport_v1",
                 "laya_executor_handoff_shell_v1", "laya_executor_source_guard_v2"]
        for name in names:
            relative = MODULE / "rtl" / (name + ".sv")
            freeze(ROOT / relative, relative)
        for relative in [MODULE / "tb/laya_executor_source_guard_v2_tb.sv",
                         MODULE / "tb/run_executor_source_guard_v2.py", MODULE / "tb/production_guard.py",
                         Path("tools/hls_guard_helpers.py"), Path("tests/bootstrap_source_guard_fixture.py"),
                         Path("tests/executor_handoff_shell_fixture.py")]:
            freeze(ROOT / relative, relative)
        for name in ["executor_checkpoint_import_handshake_contract_20261013.md",
                     "executor_minimum_hardware_chain_reply_20261013.md",
                     "executor_first_baseline_program_q_reply_20261013.md",
                     "executor_managed_lpv_owner_contract_20261013.md"]:
            freeze(PROJECT / "results" / name, Path("external/contracts") / name)
        capture = attempt / "captures"
        capture.mkdir()
        script = attempt / "run_executor_source_guard_v2.tcl"
        script.write_text(TCL)
        vivado = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
        rtl = [str(vivado), "-mode", "batch", "-notrace", "-log", str(attempt / "vivado.log"),
               "-journal", str(attempt / "vivado.jou"), "-source", str(script),
               "-tclargs", str(attempt / "work"), str(frozen), str(fixture), str(capture)]
        guard = [sys.executable, str(frozen / MODULE / "tb/production_guard.py"),
                 "--out", str(attempt / "guard_rtl"), "--cwd", str(frozen), "--rss-gib", "8",
                 "--timeout-seconds", "120", "--semantic-stall-seconds", "120", "--", *rtl]
        manifest = {"schema": "laya-executor-source-guard-v2-input-v1", "scope": SCOPE,
                    "files": records, "derived_tcl": rec(script), "derived_controlled_peer_files": derived_records,
                    "tool": rec(vivado), "launcher": rec(attempt / "launcher.json"),
                    "planned_rtl_command": rtl, "planned_guard_command": guard,
                    "case_count": 6, "cycle_cap": 8000,
                    "literal_sources": {"control": str(control), "bootstrap": str(bootstrap)},
                    "profile": {"kind": "finite_rtl_pilot", "rss_gib": 8,
                                "timeout_seconds": 120, "semantic_stall_seconds": 120}}
        write_json(attempt / "input_manifest.json", manifest)
        result["input_manifest"] = rec(attempt / "input_manifest.json")
        if args.prepare_only:
            result["status"] = "PREPARED_NOT_RUN"
            write_json(attempt / "receipt.json", result)
            print("FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_PREPARED_NOT_RUN", flush=True)
            return 0
        result["rtl"] = {"status": "RUNNING", "started": True}
        write_json(attempt / "receipt.json", result)
        process = subprocess.run(guard, cwd=frozen)
        output = attempt / "guard_rtl"
        guard_path = output / "guard_result.json"
        observed_guard = json.loads(guard_path.read_text()) if guard_path.is_file() else None
        log = output / "driver.log"
        body = log.read_text(errors="replace") if log.is_file() else ""
        markers = [line for line in body.splitlines() if line.startswith(MARKER + " ")]
        case_lines = [line for line in body.splitlines() if line.startswith(CASE_MARKER + " ")]
        complete_cases = len(case_lines) == 6 and all(
            sum(line.startswith(CASE_MARKER + " case=" + str(i) + " ") for line in case_lines) == 1
            for i in range(6))
        passed = (process.returncode == 0 and observed_guard is not None and
                  observed_guard["child_exit_code"] == 0 and observed_guard["trigger"] is None and
                  len(markers) == 1 and complete_cases and "Fatal:" not in body and "ERROR:" not in body)
        result["rtl"] = {"status": "PASS" if passed else "FAIL", "started": True,
                         "runner_exit_code": process.returncode, "guard": observed_guard,
                         "markers": markers, "case_markers": case_lines,
                         "raw_files": [rec(p) for p in sorted(output.rglob("*")) if p.is_file()]}
        result["actual_control_captures"] = [rec(p) for p in sorted(capture.rglob("*")) if p.is_file()]
        result["vivado_logs"] = [rec(p) for p in sorted((attempt / "work").rglob("*.log")) if p.is_file()]
        for p in [attempt / "vivado.log", attempt / "vivado.jou"]:
            if p.is_file():
                result["vivado_logs"].append(rec(p))
        result["status"] = "PASS_SCOPED_RTL_SOURCE_GUARD" if passed else \
            "COST_STOP" if observed_guard and observed_guard["trigger"] is not None else "FAIL"
        write_json(attempt / "receipt.json", result)
        print("FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_RUN_" + result["status"], flush=True)
        return 0 if passed else 1
    except Exception as error:
        result["status"] = "FAIL"
        result["error"] = {"type": type(error).__name__, "message": str(error)}
        result["frozen_files_at_failure"] = records
        write_json(attempt / "receipt.json", result)
        raise


if __name__ == "__main__":
    raise SystemExit(main())
