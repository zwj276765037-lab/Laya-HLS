#!/usr/bin/env python3
"""Seal and read-only check the compact checkpoint-only Ws source candidate."""

from __future__ import annotations

import argparse
import ast
import datetime as dt
import hashlib
import json
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[1]
OOC = ROOT.parent
BASE = OOC.parents[4]  # Laya-baseline
RESULTS = BASE / "results/attention_rtl_repair_20261008"
VIVADO_ROOT = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado")
MAN = VIVADO_ROOT / "doc/eng/man"
UNISIMS = VIVADO_ROOT / "data/verilog/src/unisims"
OUT = ROOT / "source/source_packet.json"
ARCHIVE = ROOT / "source/preimages/v1"
ARCHIVE_MANIFEST = ARCHIVE / "archive_manifest.json"
V1_PACKET = ARCHIVE / "source/source_packet.json"
V1_PACKET_SHA = "79aedbc99483c0ce001740b969aed3f35d607daeb921ad5e919e5c37499cea4a"
ARCHIVE_SHA = "a9505149825262eeaedfef2969eed57b8b7726bf85d11d8941e618d587906f0c"
DESIGN = ROOT / "source/design.md"
TCL = ROOT / "tb/extract_ws_graph.tcl"
DCP = OOC / "runs/top_synth_v1_entry_a2_reports/q8_joint_tm4tn8_ooc_synth.dcp"
PRIOR_ACTUAL = OOC / "runs/top_dcp_report_recovery_v1_control/recovery_actual_result_evidence.json"
DESIGN_GATE = RESULTS / "reviewer_q8_ws_compact_dcp_connectivity_source_preparation_release.json"
TIMEOUT_REVIEW = RESULTS / "reviewer_q8_dcp_report_timeout_and_partial_timing_characterization_acceptance.json"
FUTURE_CONTROL = OOC / "runs/ws_dcp_connectivity_v1_control"
FUTURE_REPORTS = OOC / "runs/ws_dcp_connectivity_v1_reports"

EXPECTED = {
    DESIGN: "8fc286ed01954732961da8b13ecaa3106ad44045222d351d980466f16aaeefa2",
    DCP: "c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce",
    PRIOR_ACTUAL: "72e2c049186233e84a374c1e645bc0af21d6bcf2be56d00bf27b8fed5d67c843",
    DESIGN_GATE: "a204feb53401ba8ff27edff3d890befe65cbde40a189da70e8c876640398e1ee",
    TIMEOUT_REVIEW: "3a1a351c418d774eb63a7ba223ba1ec7ef58b8576e709faf575ed4dffa000f75",
}


def record(path: Path) -> dict:
    sha = hashlib.sha256()
    size = 0
    with path.open("rb") as stream:
        while block := stream.read(8 * 1024 * 1024):
            sha.update(block)
            size += len(block)
    return {"path": str(path), "bytes": size, "sha256": sha.hexdigest()}


def validate_archive() -> dict:
    if record(ARCHIVE_MANIFEST)["sha256"] != ARCHIVE_SHA:
        raise RuntimeError("compact v1 archive manifest drift")
    manifest = json.loads(ARCHIVE_MANIFEST.read_text())
    if (manifest["schema"] != "q8_compact_ws_source_v1_preimage_archive_v1" or
            manifest["status"] != "BYTE_IDENTICAL_V1_BEFORE_ASTRA_REVIEW_FIXES" or
            manifest["source_packet_sha256"] != V1_PACKET_SHA or
            len(manifest["files"]) != 9 or
            record(V1_PACKET)["sha256"] != V1_PACKET_SHA):
        raise RuntimeError("compact v1 source archive drift")
    names = set()
    for item in manifest["files"]:
        relative = Path(item["relative_path"])
        if (relative.is_absolute() or ".." in relative.parts or
                item["original_path"] != str(ROOT / relative) or
                item["archive_path"] != str(ARCHIVE / relative) or
                str(relative) in names):
            raise RuntimeError("compact v1 archive path/uniqueness drift")
        names.add(str(relative))
        if record(Path(item["archive_path"])) != {
                "path": item["archive_path"], "bytes": item["bytes"],
                "sha256": item["sha256"]}:
            raise RuntimeError(f"compact v1 archive file drift: {relative}")
    if "source/source_packet.json" not in names:
        raise RuntimeError("compact v1 packet not archived")
    return manifest


def validate_bound_inputs() -> dict:
    validate_archive()
    for path, expected in EXPECTED.items():
        if record(path)["sha256"] != expected:
            raise RuntimeError(f"bound input drift: {path}")
    gate = json.loads(DESIGN_GATE.read_text())
    if (gate["execution_released"] is not False or
            gate["resynthesis_released"] is not False or
            gate["design"] != record(DESIGN) or
            gate["sealed_dcp"] != record(DCP)):
        raise RuntimeError("source-preparation gate drift")
    actual = json.loads(PRIOR_ACTUAL.read_text())
    if (actual["guard_result"]["trigger"] != "timeout" or
            actual["guard_result"]["child_exit_code"] != -9 or
            actual["ws_first_pass_complete_marker"] is not True or
            actual["ws_full_primitive_pass_complete_marker"] is not False or
            actual["recovery_done_marker"] is not False):
        raise RuntimeError("prior actual-result status drift")
    for item in actual["report_files"]:
        if record(Path(item["path"])) != item:
            raise RuntimeError(f"prior immutable report drift: {item['path']}")
    review = json.loads(TIMEOUT_REVIEW.read_text())
    if review.get("schema") is None:
        raise RuntimeError("timeout acceptance review missing schema")
    return actual


def validate_source() -> None:
    script = TCL.read_text()
    if (script.count("open_checkpoint $dcp") != 1 or
            script.count("sha256_file $dcp") != 2 or
            "get_cells -quiet -hierarchical -include_replicated_objects *" not in script or
            "get_nets -quiet -segments -of_objects $pin" not in script or
            "get_nets -quiet -segments -of_objects [lindex $local 0]" in script or
            "UNKNOWN_PRIMITIVE_SEMANTICS" not in script or
            "UNDRIVEN_COMPONENT" not in script or
            "classify_driver_owner" not in script or
            "-hierarchical_min_primitive_count 0" not in script or
            "Q8_WS_COMPACT_GRAPH_EXTRACTED" not in script or
            str(DCP) not in script or str(FUTURE_REPORTS) not in script):
        raise RuntimeError("compact Tcl source contract drift")
    forbidden = re.compile(
        r"\b(open_project|launch_runs|synth_design|generate_target|"
        r"opt_design|place_design|route_design|write_checkpoint|"
        r"read_xdc|create_clock|set_clock_uncertainty|set_property)\b")
    for line_number, line in enumerate(script.splitlines(), 1):
        if forbidden.search(line.split("#", 1)[0]):
            raise RuntimeError(f"forbidden Tcl command at line {line_number}")
    tcl_static = (
        f"set f [open {{{TCL}}} r]\n"
        "set s [read $f]\nclose $f\nputs [info complete $s]\n"
    )
    completed = subprocess.run(["/usr/bin/tclsh"], input=tcl_static,
                               text=True, capture_output=True, timeout=20)
    if completed.returncode or completed.stdout.strip() != "1":
        raise RuntimeError(f"Tcl structural syntax failed: {completed.stderr}")
    for source in (ROOT / "tb/audit_graph.py", Path(__file__)):
        ast.parse(source.read_text(), filename=str(source))


def construct(created_utc: str) -> dict:
    actual = validate_bound_inputs()
    validate_source()
    maintained = [ROOT / name for name in (
        "source/design.md", "source/design_supplement.md", "source/results.md",
        "rtl/README.md", "tb/README.md", "tb/extract_ws_graph.tcl",
        "tb/audit_graph.py", "tb/make_source_packet.py")]
    manuals = [MAN / name for name in (
        "open_checkpoint", "get_cells", "get_nets", "get_pins", "get_ports",
        "report_utilization")]
    semantics = [UNISIMS / f"{name}.v" for name in (
        "RAMB36E2", "RAMB18E2", "URAM288", "LUT1", "LUT2", "LUT3", "LUT4", "LUT5", "LUT6",
        "MUXF7", "MUXF8", "MUXF9", "FDRE", "FDCE", "FDSE", "FDPE",
        "VCC", "GND", "CARRY8", "RAM128X1D", "RAM32X1D", "RAM64X1D")]
    return {
        "schema": "q8_compact_ws_dcp_connectivity_source_packet_v2",
        "created_utc": created_utc,
        "status": "SOURCE_ONLY_NO_DCP_EXECUTION_NO_CAPACITY_ACCEPTANCE",
        "v1_archive_manifest": record(ARCHIVE_MANIFEST),
        "v1_source_packet": record(V1_PACKET),
        "v1_archived_file_count": 9,
        "source_preparation_gate": record(DESIGN_GATE),
        "prior_timeout_acceptance": record(TIMEOUT_REVIEW),
        "prior_actual_result": record(PRIOR_ACTUAL),
        "prior_report_file_count_rehashed": len(actual["report_files"]),
        "sealed_input_checkpoint": record(DCP),
        "original_ws_tcl": record(Path(json.loads(DESIGN_GATE.read_text())["original_ws_tcl"]["path"])),
        "maintained_source": [record(path) for path in maintained],
        "installed_vivado_launcher": record(VIVADO_ROOT / "bin/vivado"),
        "installed_command_manuals": [record(path) for path in manuals],
        "installed_primitive_semantics": [record(path) for path in semantics],
        "future_control": str(FUTURE_CONTROL),
        "future_reports": str(FUTURE_REPORTS),
        "future_paths_absent_at_seal": True,
        "tcl_info_complete": True,
        "python_AST": "PASS",
        "execution_released": False,
        "resynthesis_released": False,
        "ws_capacity_and_high_address_acceptance": "HELD_REQUIRES_INDEPENDENT_EXHAUSTIVE_MAPPING",
        "timing_board_acceptance": "NOT_ESTABLISHED_OOC_ONLY",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--revise-v2", action="store_true")
    args = parser.parse_args()
    if args.check == args.revise_v2:
        parser.error("choose exactly one of --check and --revise-v2")
    if args.revise_v2:
        if record(OUT)["sha256"] != V1_PACKET_SHA:
            raise RuntimeError("current source packet is not sealed v1")
        if (FUTURE_CONTROL.exists() or FUTURE_CONTROL.is_symlink() or
                FUTURE_REPORTS.exists() or FUTURE_REPORTS.is_symlink()):
            raise RuntimeError("future execution path is not fresh")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        temporary = OUT.with_name("source_packet_v2.tmp")
        if temporary.exists():
            raise RuntimeError(f"temporary packet path collision: {temporary}")
        temporary.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
        temporary.replace(OUT)
        print(f"Q8_WS_COMPACT_SOURCE_PACKET_CREATED sha256={record(OUT)['sha256']}")
    else:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise RuntimeError("compact source packet drift")
        print(f"Q8_WS_COMPACT_SOURCE_PACKET_PASS sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
