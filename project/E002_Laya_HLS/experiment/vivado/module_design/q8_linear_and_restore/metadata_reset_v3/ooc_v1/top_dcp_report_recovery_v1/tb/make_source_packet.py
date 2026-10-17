#!/usr/bin/env python3
"""Bind the sealed DCP and read-only report-recovery source for Astra review."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
OOC = ROOT.parent
RESULTS = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/"
               "Laya-baseline/results/attention_rtl_repair_20261008")
RUNS = OOC / "runs"
ACTUAL = RUNS / "top_synth_v1_entry_a2_control/top_synth_actual_result_evidence.json"
DCP = RUNS / "top_synth_v1_entry_a2_reports/q8_joint_tm4tn8_ooc_synth.dcp"
WS_TCL = RUNS / "top_synth_v1_entry_a2/stage/scripts/report_ws_banks.tcl"
GATE = RESULTS / "reviewer_q8_top_ooc_zero_launch_fresh_entry_a2_execution_addendum.json"
BASE_GATE = RESULTS / "reviewer_q8_same_source_top_ooc_single_synthesis_execution_release.json"
TOP_PACKET = OOC / "top_synth_v1/source/source_packet.json"
GUARD = OOC / "top_synth_v1/source/guard_48g_v1/guard_runtime_48g.py"
GUARD_HELPER = OOC / "top_synth_v1/source/guard_48g_v1/hls_guard_helpers.py"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
MAN = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/doc/eng/man")
OUT = ROOT / "source/source_packet.json"
ARCHIVE = ROOT / "source/preimages/v1"
ARCHIVE_MANIFEST = ARCHIVE / "archive_manifest.json"
V1_PACKET = ARCHIVE / "source/source_packet.json"
RUNME = RUNS / "top_synth_v1_entry_a2_reports/runme.log"
FINAL_WARNING_LINE = "1139 Infos, 5 Warnings, 0 Critical Warnings and 0 Errors encountered."


def record(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def require(item: dict) -> None:
    actual = record(Path(item["path"]))
    if actual != item:
        raise RuntimeError(f"bound file drift: {item['path']}")


def validate_archive() -> dict:
    archive = json.loads(ARCHIVE_MANIFEST.read_text())
    if (archive["schema"] != "q8_dcp_report_recovery_v1_preimage_archive_v1" or
            archive["status"] !=
            "BYTE_IDENTICAL_PREIMAGES_BEFORE_FINAL_WARNING_COUNT_CORRECTION" or
            archive["source_packet_sha256"] !=
            "d32c2bae795a054b72a8a62f20e8c1665dc01e0631814b0d680d573da1bc6274" or
            len(archive["files"]) != 7 or
            record(V1_PACKET)["sha256"] != archive["source_packet_sha256"]):
        raise RuntimeError("v1 recovery source archive drift")
    paths = set()
    for item in archive["files"]:
        relative = Path(item["relative_path"])
        if (relative.is_absolute() or ".." in relative.parts or
                item["archive_path"] != str(ARCHIVE / relative) or
                item["original_path"] != str(ROOT / relative) or
                str(relative) in paths):
            raise RuntimeError("v1 recovery archive path drift")
        paths.add(str(relative))
        require({"path": item["archive_path"], "bytes": item["bytes"],
                 "sha256": item["sha256"]})
    if ("source/source_packet.json" not in paths or
            json.loads(V1_PACKET.read_text())["schema"] !=
            "q8_top_dcp_only_report_recovery_source_packet_v1"):
        raise RuntimeError("v1 recovery packet preimage drift")
    return {"v1_archive_manifest": record(ARCHIVE_MANIFEST),
            "v1_source_packet": record(V1_PACKET),
            "v1_archived_file_count": len(archive["files"])}


def validate() -> None:
    validate_archive()
    if record(ACTUAL)["sha256"] != \
            "52f5039f79733e7494446afd6b1c410c552647bc297045e5d2132871138572be":
        raise RuntimeError("actual synthesis evidence drift")
    actual = json.loads(ACTUAL.read_text())
    if (actual["status"] !=
            "SYNTHESIS_COMPLETE_DCP_SAVED_REPORT_SCRIPT_ABORT_UNSUPPORTED_UNCONSTRAINED_OPTION" or
            actual["saved_checkpoint"] != record(DCP) or
            actual["source_packet"] != record(TOP_PACKET) or
            actual["missing_ws_reports"] is not True or
            actual["actual_launch_runs_count"] != 1):
        raise RuntimeError("sealed synthesis/DCP lineage drift")
    runme = RUNME.read_text(errors="replace")
    if (record(RUNME) != actual["report_copy_runme"] or
            FINAL_WARNING_LINE not in runme or
            "synth_design completed successfully" not in runme or
            sum(line.startswith("WARNING:") for line in runme.splitlines()) != 5 or
            any(line.startswith(("CRITICAL WARNING:", "ERROR:"))
                for line in runme.splitlines())):
        raise RuntimeError("final synth runme warning/status drift")
    if record(DCP)["sha256"] != \
            "c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce":
        raise RuntimeError("sealed DCP drift")
    if record(WS_TCL)["sha256"] != \
            "f10f83514749cc3c39d07a83ccd7693dae59c21c42bbb6aabaf2c4e8c421dbd8":
        raise RuntimeError("unchanged Ws report Tcl drift")
    gate = json.loads(GATE.read_text())
    if (record(GATE)["sha256"] !=
            "3182e93fc62172e5fd484da241931430d3a5e9e570993c20af55bedc7425284f" or
            gate["base_gate"] != record(BASE_GATE) or
            gate["source_packet"] != record(TOP_PACKET)):
        raise RuntimeError("reviewed gate lineage drift")
    timing = (MAN / "report_timing").read_text()
    summary = (MAN / "report_timing_summary").read_text()
    opening = (MAN / "open_checkpoint").read_text()
    if ("  -report_unconstrained - (Optional)" not in summary or
            re.search(r"(?m)^  -unconstrained\b", timing) or
            "Non-Project Mode" not in opening):
        raise RuntimeError("installed Vivado report/open command manual drift")
    tcl = (ROOT / "tb/recover_reports_from_dcp.tcl").read_text()
    if (tcl.count("open_checkpoint $dcp") != 1 or
            tcl.count("report_timing_summary -report_unconstrained -max_paths 100") != 1 or
            "report_timing -unconstrained" in tcl or
            str(DCP) not in tcl or str(WS_TCL) not in tcl or
            "c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce" not in tcl or
            "f10f83514749cc3c39d07a83ccd7693dae59c21c42bbb6aabaf2c4e8c421dbd8" not in tcl):
        raise RuntimeError("DCP-only Tcl route drift")
    forbidden = re.compile(r"\b(open_project|launch_runs|synth_design|generate_target|"
                           r"opt_design|place_design|route_design|write_checkpoint)\b")
    for number, line in enumerate(tcl.splitlines(), 1):
        if forbidden.search(line.split("#", 1)[0]):
            raise RuntimeError(f"forbidden report-recovery command at Tcl line {number}")


def construct(created_utc: str) -> dict:
    validate()
    archive = validate_archive()
    maintained = [ROOT / name for name in (
        "source/design.md", "source/results.md", "rtl/README.md",
        "tb/README.md", "tb/recover_reports_from_dcp.tcl",
        "tb/make_source_packet.py")]
    return {
        "schema": "q8_top_dcp_only_report_recovery_source_packet_v2",
        "created_utc": created_utc,
        "status": "SOURCE_ONLY_NO_VIVADO_RECOVERY_EXECUTION",
        **archive,
        "review_addendum": record(GATE), "base_gate": record(BASE_GATE),
        "actual_synthesis_evidence": record(ACTUAL),
        "final_synthesis_runme": record(RUNME),
        "final_synthesis_warning_count": 5,
        "final_synthesis_critical_warning_count": 0,
        "final_synthesis_error_count": 0,
        "sealed_synthesis_dcp": record(DCP),
        "unchanged_ws_report_tcl": record(WS_TCL),
        "accepted_top_source_packet": record(TOP_PACKET),
        "installed_vivado_launcher": record(VIVADO),
        "installed_command_manuals": [record(MAN / name) for name in
                                      ("open_checkpoint", "report_timing",
                                       "report_timing_summary")],
        "reviewed_guard": record(GUARD),
        "reviewed_guard_helper": record(GUARD_HELPER),
        "maintained_source": [record(path) for path in maintained],
        "future_control_and_cwd": str(RUNS / "top_dcp_report_recovery_v1_control"),
        "future_fresh_reports": str(RUNS / "top_dcp_report_recovery_v1_reports"),
        "recovery_execution_release": False,
        "ws_capacity_and_high_address_acceptance": "REVIEW_REQUIRED",
        "top_resynthesis": "FORBIDDEN_IN_THIS_RECOVERY",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise RuntimeError("DCP-only recovery source packet drift")
        print(f"Q8_DCP_REPORT_SOURCE_PACKET_PASS sha256={record(OUT)['sha256']}")
    else:
        if (not OUT.is_file() or
                record(OUT) != record(V1_PACKET) | {"path": str(OUT)}):
            raise RuntimeError("current packet is not the archived exact v1 preimage")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        temporary = OUT.with_name("source_packet_v2.tmp")
        if temporary.exists():
            raise RuntimeError(f"fresh temporary packet path required: {temporary}")
        temporary.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
        temporary.replace(OUT)
        print(f"Q8_DCP_REPORT_SOURCE_PACKET_CREATED sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
