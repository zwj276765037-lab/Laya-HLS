#!/usr/bin/env python3
"""Seal/read-only check the v4 Ws batch-source candidate; never open a DCP."""

from __future__ import annotations

import argparse
import ast
import datetime as dt
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
OOC = ROOT.parent
BASE = OOC.parents[4]
RESULTS = BASE / "results/attention_rtl_repair_20261008"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado")
OUT = ROOT / "source/source_packet.json"
DESIGN_GATE = RESULTS / "reviewer_q8_ws_v4_semantic_property_batch_source_preparation_release.json"
V3_REVIEW = RESULTS / "reviewer_q8_ws_v3_timeout_and_partial_graph_characterization_acceptance.json"
V3_ACTUAL = OOC / "runs/ws_dcp_connectivity_v1_control/ws_dcp_v3_extraction_actual_result_evidence.json"
V3_PACKET = OOC / "ws_dcp_connectivity_v1/source/source_packet.json"
V3_GATE = RESULTS / "reviewer_q8_ws_compact_dcp_v3_source_and_extraction_execution_release.json"
DCP = OOC / "runs/top_synth_v1_entry_a2_reports/q8_joint_tm4tn8_ooc_synth.dcp"
XDC = OOC / "runs/top_synth_v1/stage/constraints/q8_joint_tm4tn8_ooc.xdc"
FUTURE_CONTROL = OOC / "runs/ws_dcp_connectivity_v4_control"
FUTURE_REPORTS = OOC / "runs/ws_dcp_connectivity_v4_reports"
GUARD = OOC / "top_synth_v1/source/guard_48g_v1/guard_runtime_48g.py"
GUARD_HELPER = OOC / "top_synth_v1/source/guard_48g_v1/hls_guard_helpers.py"
EXPECTED = {
    ROOT / "source/design.md": "44aa60205e6270514f478b4e0463ac57c2017a06867b41ba65c0170c42705b09",
    ROOT / "source/semantic_property_contract.json": "9d198c5fc5032771aadc9e97571a5acd631af517bb8e8fa666b82dcc6b7b4a77",
    DESIGN_GATE: "4d46c084b0201035e5c3ffdaa8038d93da25187fc3c8a9ac9cc4ebcfe95dd946",
    V3_ACTUAL: "a004f4b1c4cb3948525b1a4f232003280337fa7c7574d206b2f0271859ed004c",
    V3_REVIEW: "63ae5f2843428f9a26753aad39a092876387e2662330b45aa406d898862c6355",
    V3_PACKET: "57fb8dbcf5071c2aa031d0fed31c34554de131aeb4407b502bf65f5d095b0d55",
    V3_GATE: "a43f1daa22f2ae85d5874b59814af855d3185f6f23521849549b03eb8652ec29",
    DCP: "c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce",
    XDC: "660a1b1d2fd32b9f4b72bbe6f7015fcb0e5983d20d39419207c836883f07ede0",
}


def record(path: Path) -> dict:
    digest = hashlib.sha256()
    count = 0
    with path.open("rb") as stream:
        while block := stream.read(8 * 1024 * 1024):
            digest.update(block)
            count += len(block)
    return {"path": str(path), "bytes": count, "sha256": digest.hexdigest()}


def same(item: dict) -> bool:
    return record(Path(item["path"])) == item


def validate_bound_inputs() -> tuple[dict, dict]:
    for path, sha in EXPECTED.items():
        if record(path)["sha256"] != sha:
            raise RuntimeError(f"bound input drift: {path}")
    gate = json.loads(DESIGN_GATE.read_text())
    if (gate["status"] != "SOURCE_PREPARATION_ONLY_NO_DCP_OR_PROOF_EXECUTION" or
            gate["design"] != record(ROOT / "source/design.md") or
            gate["semantic_property_contract"] != record(ROOT / "source/semantic_property_contract.json")):
        raise RuntimeError("v4 design gate drift")
    review = json.loads(V3_REVIEW.read_text())
    actual = json.loads(V3_ACTUAL.read_text())
    if (review["status"] != "BOUNDED_TIMEOUT_AND_PARTIAL_EVIDENCE_ACCEPTED_MAPPING_HELD" or
            actual["status"] != "GUARD_TIMEOUT_PARTIAL_GRAPH_STRUCTURAL_FAIL_MAPPING_PROOF_HELD" or
            actual["offline_structural_audit"]["error_count"] != 8626 or
            actual["offline_structural_audit"]["nets"] != 0 or
            actual["offline_structural_audit"]["boundary_pins"] != 0):
        raise RuntimeError("v3 terminal interpretation drift")
    if len(actual["prior_report_files_rehashed"]) != 18 or not all(map(same, actual["prior_report_files_rehashed"])):
        raise RuntimeError("prior report drift")
    for version in ("v1", "v2"):
        archive = actual["archived_v1_v2_preimages_rehashed"][version]
        if not same(archive["manifest"]) or len(archive["files"]) != 9 or not all(map(same, archive["files"])):
            raise RuntimeError(f"v3 archived source drift: {version}")
    if "create_clock -name ap_clk -period 6.667 [get_ports ap_clk]" not in XDC.read_text():
        raise RuntimeError("original OOC clock constraint drift")
    contract = json.loads((ROOT / "source/semantic_property_contract.json").read_text())
    if len(contract["primitive_contracts"]) != 22 or sum(len(x["required_property_names"]) for x in contract["primitive_contracts"]) != 348:
        raise RuntimeError("primitive contract cardinality drift")
    for item in contract["installed_command_manuals"]:
        if not same(item):
            raise RuntimeError("installed Tcl manual drift")
    for primitive in contract["primitive_contracts"]:
        if not same(primitive["semantics_file"]):
            raise RuntimeError("installed UNISIM semantics drift")
    return actual, contract


def validate_source() -> None:
    generated = subprocess.run(
        ["/usr/bin/python3", str(ROOT / "tb/generate_contract_tcl.py"), "--check"],
        capture_output=True, text=True, timeout=20, check=True,
    )
    if generated.stdout.strip() != "Q8_WS_V4_CONTRACT_TCL_PASS":
        raise RuntimeError("contract Tcl generation check failed")
    script = (ROOT / "tb/extract_ws_graph.tcl").read_text()
    if (script.count("open_checkpoint $dcp") != 1 or
            script.count("sha256_file $dcp") != 2 or
            "get_property $key $objects" not in script or
            "set group_names [property_values NAME $objects property_group]" not in script or
            "get_nets -quiet -segments -of_objects $pin" not in script or
            "REQUIRED_PROPERTY_GAP" not in script or
            "UNKNOWN_PRIMITIVE_SEMANTICS" not in script or
            "UNDRIVEN_COMPONENT" not in script or
            "phase_ledger.tsv" not in script or
            str(DCP) not in script or str(FUTURE_REPORTS) not in script or
            "list_property $cell" in script):
        raise RuntimeError("v4 Tcl extraction contract drift")
    forbidden = re.compile(
        r"\b(open_project|launch_runs|synth_design|generate_target|opt_design|"
        r"place_design|route_design|write_checkpoint|read_xdc|create_clock|"
        r"set_clock_uncertainty|set_property)\b"
    )
    for number, line in enumerate(script.splitlines(), 1):
        if forbidden.search(line.split("#", 1)[0]):
            raise RuntimeError(f"forbidden Tcl command at {number}")
    paths = (ROOT / "tb/extract_ws_graph.tcl", ROOT / "source/required_properties.tcl")
    for path in paths:
        tcl = f"set f [open {{{path}}} r]\nset s [read $f]\nclose $f\nputs [info complete $s]\n"
        result = subprocess.run(["/usr/bin/tclsh"], input=tcl, text=True, capture_output=True, timeout=20)
        if result.returncode or result.stdout.strip() != "1":
            raise RuntimeError(f"Tcl completeness failed: {path}: {result.stderr}")
    tcl = f"source {{{ROOT / 'source/required_properties.tcl'}}}\nputs \"$required_ref_count $required_contract_count\"\n"
    result = subprocess.run(["/usr/bin/tclsh"], input=tcl, text=True, capture_output=True, timeout=20)
    if result.returncode or result.stdout.strip() != "22 348":
        raise RuntimeError("literal Tcl contract load failed")
    for path in (ROOT / "tb/generate_contract_tcl.py", ROOT / "tb/audit_graph.py", Path(__file__)):
        ast.parse(path.read_text(), filename=str(path))
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location("ws_v4_audit", ROOT / "tb/audit_graph.py")
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    with tempfile.TemporaryDirectory(prefix="q8_ws_v4_parser_") as scratch:
        root = Path(scratch)
        cells = root / "cells.tsv"
        cells.write_text(module.HEADERS["cells"].replace(" ", "\t") + "\n"
                         "c1\tws_U\t77735f55\t\t52414d4233364532\t\t1\n")
        parsed = list(module.rows(root, "cells"))
        if len(parsed) != 1 or module.unhex(parsed[0]["ref_hex"]) != "RAMB36E2":
            raise RuntimeError("synthetic table parser failed")
        cells.write_text(module.HEADERS["cells"].replace(" ", "\t") + "\n" "c1\tws_U\n")
        try:
            list(module.rows(root, "cells"))
        except ValueError:
            pass
        else:
            raise RuntimeError("synthetic malformed table was accepted")


def construct(created: str) -> dict:
    actual, contract = validate_bound_inputs()
    validate_source()
    maintained = [ROOT / name for name in (
        "source/design.md", "source/results.md", "source/implementation_notes.md",
        "source/semantic_property_contract.json",
        "source/required_properties.tcl", "rtl/README.md", "tb/README.md",
        "tb/extract_ws_graph.tcl", "tb/audit_graph.py", "tb/generate_contract_tcl.py",
        "tb/make_source_packet.py",
    )]
    return {
        "schema": "q8_ws_v4_semantic_batch_source_packet_v1",
        "created_utc": created,
        "status": "SOURCE_ONLY_NO_DCP_OR_NUMERICAL_PROOF_EXECUTION",
        "design_gate": record(DESIGN_GATE),
        "v3_terminal_actual": record(V3_ACTUAL),
        "v3_independent_timeout_review": record(V3_REVIEW),
        "v3_source_packet": record(V3_PACKET),
        "v3_execution_gate": record(V3_GATE),
        "sealed_input_checkpoint": record(DCP),
        "unchanged_ooc_constraint": record(XDC),
        "prior_report_files_rehashed": actual["prior_report_files_rehashed"],
        "prior_report_file_count": 18,
        "installed_command_manuals": contract["installed_command_manuals"],
        "installed_primitive_semantics": [x["semantics_file"] for x in contract["primitive_contracts"]],
        "installed_vivado_launcher": record(VIVADO / "bin/vivado"),
        "candidate_guard": record(GUARD),
        "candidate_guard_helper": record(GUARD_HELPER),
        "candidate_execution_tools": [record(Path(name)) for name in (
            "/usr/bin/taskset", "/usr/bin/nice", "/usr/bin/ionice",
            "/usr/bin/python3", "/usr/bin/sha256sum")],
        "maintained_source": [record(p) for p in maintained],
        "candidate_control": str(FUTURE_CONTROL),
        "candidate_reports": str(FUTURE_REPORTS),
        "candidate_paths_absent_at_seal": True,
        "candidate_budget_not_released": {"maximum_invocations": 1, "wall_seconds": 900, "owned_rss_gib": 12},
        "candidate_argv_not_released": [
            "/usr/bin/taskset", "-c", "0-3", "/usr/bin/nice", "-n", "19",
            "/usr/bin/ionice", "-c", "3", "/usr/bin/python3", str(GUARD),
            "--out", str(FUTURE_CONTROL / "extraction_guard"),
            "--cwd", str(FUTURE_CONTROL), "--rss-gib", "12", "--timeout-seconds", "900",
            "--", str(VIVADO / "bin/vivado"), "-mode", "batch", "-notrace",
            "-source", str(ROOT / "tb/extract_ws_graph.tcl"),
            "-log", str(FUTURE_CONTROL / "vivado.log"),
            "-journal", str(FUTURE_CONTROL / "vivado.jou"),
            "-tclargs", str(DCP), str(FUTURE_REPORTS),
        ],
        "tcl_info_complete": True,
        "python_AST": "PASS",
        "synthetic_table_parser": "PASS",
        "contract_tcl_exact": True,
        "execution_released": False,
        "resynthesis_released": False,
        "ws_mapping_acceptance": "HELD_ALL_8x20992x16_BITS_INCLUDING_ADDRESSES_16384_TO_20991",
        "timing_150MHz_board_acceptance": "NOT_ESTABLISHED",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seal", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.seal == args.check:
        parser.error("choose exactly one of --seal or --check")
    if args.seal:
        if OUT.exists() or FUTURE_CONTROL.exists() or FUTURE_REPORTS.exists():
            raise RuntimeError("packet or future execution roots are not fresh")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        with OUT.open("x", encoding="utf-8") as stream:
            json.dump(packet, stream, indent=2, sort_keys=True)
            stream.write("\n")
        print(f"Q8_WS_V4_SOURCE_PACKET_CREATED sha256={record(OUT)['sha256']}")
    else:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise RuntimeError("v4 source packet or bound inputs drift")
        print(f"Q8_WS_V4_SOURCE_PACKET_PASS sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
