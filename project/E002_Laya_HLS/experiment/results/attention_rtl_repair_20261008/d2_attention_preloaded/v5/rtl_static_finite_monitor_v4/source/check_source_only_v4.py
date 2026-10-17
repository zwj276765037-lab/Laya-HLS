#!/usr/bin/env python3
"""Text/hash audit only. This script never invokes an HDL tool or simulator."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parent.parent
V3 = ROOT.parent / "rtl_static_finite_monitor_v3"
BASE = ROOT.parents[2]
GATE = BASE / "reviewer_attention_v5_head15_monitor_v4_boundary_diagnostic_source_preparation_release.json"
OUT = ROOT / "source/source_static_audit.json"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition: bool, label: str, checks: dict) -> None:
    checks[label] = bool(condition)
    if not condition:
        raise AssertionError(label)


def main() -> None:
    gate = json.loads(GATE.read_text())
    archive = json.loads((ROOT / "source/v3_preimage_archive.json").read_text())
    checks = {}
    for entry in gate["exact_preimage_required"]:
        path = Path(entry["path"])
        require(path.stat().st_size == entry["bytes"] and digest(path) == entry["sha256"],
                "gate_preimage:" + path.name, checks)
    for entry in archive["files"]:
        original, archived = Path(entry["original_path"]), Path(entry["archived_path"])
        require(original.read_bytes() == archived.read_bytes() and
                original.stat().st_size == entry["bytes"] and
                digest(archived) == entry["sha256"] and
                oct(archived.stat().st_mode & 0o777) == entry["mode"],
                "archive:" + str(archived.relative_to(ROOT)), checks)

    tb = ROOT / "tb"
    old = V3 / "tb"
    for name in ("att_axi_monitor.sv", "att_finite_base_h15_r63_top.sv",
                 "att_finite_changed_h0_r0_top.sv"):
        require((tb / name).read_bytes() == (old / name).read_bytes(),
                "byte_identical:" + name, checks)
    control = (tb / "att_finite_control.svh").read_text()
    old_control = (old / "att_finite_control.svh").read_text()
    marker = "    if (!resetn) begin r_hold_reg<=0; b_hold_reg<=0; end"
    require(control[control.index(marker):] == old_control[old_control.index(marker):],
            "unchanged_hold_debt_association_numerical_tail", checks)
    require(control.count('`include "att_r_boundary_diagnostic.svh"') == 1 and
            control.index("att_dump_all_boundaries();") <
            control.index("u_port_descriptor.check_reset_record();") <
            control.index('ATT_R_RECORD_TOP_RESET port=%0d'),
            "raw_before_wrapper_and_top_reset_fatal", checks)
    ports = ["descriptor", "io", "aux", "qkv0", "qkv1", "att_out", "observed"]
    require(all(control.count(f"u_port_{p}.check_reset_record();") == 1 for p in ports),
            "seven_wrapper_checks_centralized", checks)
    old_pred = old_control[old_control.index("        for (int p=0;p<7;p++)\n          if ($isunknown({ram_accepted_r_record[p]"):old_control.index("        $display(\"ATT_R_RECORD_TOP_RESET selected_port")]
    require(old_pred in control, "original_top_reset_predicate", checks)
    port = (tb / "att_axi_port.sv").read_text()
    old_port = (old / "att_axi_port.sv").read_text()
    start = "if ($isunknown({dut_monitor_accepted_r_record,"
    stop = "port_reset_diag_emitted=1'b1;"
    require(re.sub(r"\s+", "", old_port[old_port.index(start):old_port.index(stop)+len(stop)]) ==
            re.sub(r"\s+", "", port[port.index(start):port.index(stop)+len(stop)]),
            "original_wrapper_reset_predicate_display_flag", checks)
    first = "      if (!port_first_r_diag_emitted && ram_r_count !== 32'd0) begin"
    require(old_port[old_port.index(first):old_port.index("\n    end\n  end", old_port.index(first))] ==
            port[port.index(first):port.index("\n    end\n  end", port.index(first))],
            "unchanged_wrapper_first_r", checks)
    diagnostic = (tb / "att_r_boundary_diagnostic.svh").read_text()
    require(all(re.search(rf"\b{i}: att_dump_one\({i},u_port_{name}\.port_reset_seen_posedge", diagnostic)
                for i, name in enumerate(ports)), "seven_literal_diagnostic_arms", checks)
    require(diagnostic.count("{ram_accepted_r_record[p],ram_r_count[p]}") >= 7 and
            "record_reduction_x" in diagnostic and "packed_isunknown" in diagnostic and
            "record_hex=%h record_bin=%b count_hex=%h count_bin=%b" in diagnostic,
            "raw_four_state_and_expression_variants", checks)
    probe = (ROOT / "diagnostic/record_boundary_probe.sv").read_text()
    require(all(re.search(rf"att_probe_wrapper #\(\.PORT\({i}\)\) u_port_{name} ", probe)
                for i, name in enumerate(ports)), "probe_seven_named_connections", checks)
    require("logic [31:0] ram_r_count [0:6];" in probe and
            "logic [118:0] ram_accepted_r_record [0:6];" in probe and
            "assign ram_accepted_r_record = ram_monitor_accepted_r_record;" in probe,
            "probe_same_connection_types_and_assign", checks)
    require(all(re.search(rf"\b{i}: begin", probe) for i in range(1, 6)) and
            "repeat (8) @(negedge clk);" in probe and
            "assert_captured();" in probe and
            probe.rindex("        assert_captured();") > probe.index("att_dump_all_boundaries();"),
            "probe_finite_diagnostics_before_assertions", checks)
    require("accepted_r_record[40]=1'bx;" in probe and
            "inject_x && PORT==4 && SIDE==1" in probe and
            all(x not in probe for x in ("attention_preloaded_slice", "axi_static_memory", "$readmemh", 'import "DPI-C"')),
            "probe_no_dut_and_labelled_x_only", checks)
    require(not (ROOT / "runs").exists() and not (ROOT / "build").exists(),
            "no_v4_runtime_or_build_directory", checks)

    report = {
        "schema": "head15_v4_source_only_text_hash_audit_v1",
        "status": "SOURCE_CHECKS_PASS_NO_HDL_TOOL_EXECUTION",
        "checks": checks,
        "checks_passed": len(checks),
        "compiler_invoked": False,
        "elaborator_invoked": False,
        "simulator_invoked": False,
        "numerical_dut_executed": False,
        "source_only_limit": "Text and hash checks cannot establish SystemVerilog syntax, elaboration, or runtime values.",
    }
    OUT.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"HEAD15_V4_SOURCE_AUDIT checks={len(checks)} status=SOURCE_ONLY")


if __name__ == "__main__":
    main()
