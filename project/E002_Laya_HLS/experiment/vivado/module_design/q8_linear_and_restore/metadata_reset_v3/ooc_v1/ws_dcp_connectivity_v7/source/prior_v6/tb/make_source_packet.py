#!/usr/bin/env python3
"""Seal or check the Ws v6 SOURCE-ONLY packet; never invoke Vivado."""

from __future__ import annotations

import argparse
import ast
import datetime as dt
import difflib
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
OOC = ROOT.parent
BASE = OOC.parents[4]
RESULTS = BASE / "results/attention_rtl_repair_20261008"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado")
OUT = ROOT / "source/source_packet.json"
RELEASE = RESULTS / "reviewer_q8_ws_v6_strict_parser_correction_source_preparation_release.json"
V3_REVIEW = RESULTS / "reviewer_q8_ws_v3_timeout_and_partial_graph_characterization_acceptance.json"
V5_PACKET = OOC / "ws_dcp_connectivity_v5/source/source_packet.json"
MANIFEST = ROOT / "source/prior_v5/manifest.json"
DESIGN = ROOT / "source/design.md"
CONTRACT = ROOT / "source/semantic_property_contract.json"
DIFF = ROOT / "source/v5_to_v6.diff"
DCP = OOC / "runs/top_synth_v1_entry_a2_reports/q8_joint_tm4tn8_ooc_synth.dcp"
XDC = OOC / "runs/top_synth_v1/stage/constraints/q8_joint_tm4tn8_ooc.xdc"
CONTROL = ROOT / "runs/export_graph_v1/control"
REPORTS = ROOT / "runs/export_graph_v1/reports"
GUARD = OOC / "top_synth_v1/source/guard_48g_v1/guard_runtime_48g.py"
GUARD_HELPER = OOC / "top_synth_v1/source/guard_48g_v1/hls_guard_helpers.py"
SOURCE_NAMES = (
    "source/design.md", "source/results.md", "source/implementation_notes.md",
    "source/semantic_property_contract.json", "source/required_properties.tcl",
    "rtl/README.md", "tb/README.md", "tb/extract_ws_graph.tcl",
    "tb/audit_graph.py", "tb/generate_contract_tcl.py",
    "tb/funcsim_structure.py", "tb/join_funcsim_graph.py",
    "tb/test_funcsim_synthetic.py", "tb/make_source_packet.py",
    "source/v5_to_v6.diff",
)
EXPECTED = {
    RELEASE: "6ff13c9a1356d48400a57dbb13454339fbf88050bda6d92b118135eb62175cdf",
    DESIGN: "050c840b789cbc04d98a72ffd7fb435041b4223ef2e972202596aeb3b9d577e6",
    CONTRACT: "9d198c5fc5032771aadc9e97571a5acd631af517bb8e8fa666b82dcc6b7b4a77",
    MANIFEST: "c5ac33a8e17f9f225a0a96a70d696ebdc75d2a184f43a299c8fe06c26bd2eebd",
    V5_PACKET: "213a2634cd447d32eed21140835b54b7eb7cd2a278d47d726d9c3e520453bd12",
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


def bound_inputs() -> tuple[dict, dict, dict, dict]:
    for path, digest in EXPECTED.items():
        if record(path)["sha256"] != digest:
            raise RuntimeError(f"bound preimage drift: {path}")
    release = json.loads(RELEASE.read_text())
    if (release["status"] != "SOURCE_PREPARATION_ONLY_NO_EXPORT_OR_ACTUAL_PARSER_EXECUTION" or
            release["design"] != record(DESIGN) or
            release["prior_packet"] != record(V5_PACKET) or
            not same(release["independent_counterexamples"]) or
            not same(release["actual_review"])):
        raise RuntimeError("v6 source release binding drift")
    manifest = json.loads(MANIFEST.read_text())
    v5_packet = json.loads(V5_PACKET.read_text())
    if (manifest["schema"] != "q8_ws_v6_exact_v5_preimages_v1" or
            manifest["file_count"] != 15 or len(manifest["records"]) != 15 or
            len(v5_packet["maintained_source"]) != 14 or
            v5_packet["sealed_input_checkpoint"] != record(DCP) or
            v5_packet["unchanged_ooc_constraint"] != record(XDC)):
        raise RuntimeError("v5 archive inventory or inherited input drift")
    originals = {}
    for entry in manifest["records"]:
        original, copy = entry["original"], entry["copy"]
        if original["sha256"] != copy["sha256"] or original["bytes"] != copy["bytes"]:
            raise RuntimeError("v5 original/archive identity mismatch")
        if not same(original) or not same(copy):
            raise RuntimeError(f"v5 archived source drift: {original['path']}")
        originals[original["path"]] = original
    if set(originals) != {str(V5_PACKET)} | {item["path"] for item in v5_packet["maintained_source"]}:
        raise RuntimeError("v5 archive does not contain exact packet plus maintained files")
    original_contract = next(item for item in v5_packet["maintained_source"]
                             if item["path"].endswith("/semantic_property_contract.json"))
    if (record(CONTRACT)["bytes"], record(CONTRACT)["sha256"]) != (
            original_contract["bytes"], original_contract["sha256"]):
        raise RuntimeError("inherited semantic contract drift")
    review = json.loads(V3_REVIEW.read_text())
    if (review["status"] != "BOUNDED_TIMEOUT_AND_PARTIAL_EVIDENCE_ACCEPTED_MAPPING_HELD" or
            review["partial_graph"]["cells"] != 139 or
            review["partial_graph"]["primitives"] != 135 or
            review["partial_graph"]["pins"] != 14266 or
            review["partial_graph"]["partial_cell_bank_counts"] !=
            {"ws_10_U": 46, "ws_11_U": 46, "ws_12_U": 46, "ws_13_U": 1}):
        raise RuntimeError("source-limit observation drift")
    contract = json.loads(CONTRACT.read_text())
    entries = contract["primitive_contracts"]
    if len(entries) != 22 or sum(len(x["required_property_names"]) for x in entries) != 348:
        raise RuntimeError("semantic contract cardinality drift")
    for item in contract["installed_command_manuals"]:
        if not same(item):
            raise RuntimeError("installed Tcl manual drift")
    for entry in entries:
        if not same(entry["semantics_file"]):
            raise RuntimeError("installed UNISIM semantics drift")
    if "create_clock -name ap_clk -period 6.667 [get_ports ap_clk]" not in XDC.read_text():
        raise RuntimeError("unchanged OOC clock constraint drift")
    for item in v5_packet["prior_report_files_rehashed"]:
        if not same(item):
            raise RuntimeError("accepted prior report drift")
    if (v5_packet["installed_command_manuals"] != contract["installed_command_manuals"] or
            v5_packet["installed_primitive_semantics"] !=
            [entry["semantics_file"] for entry in entries] or
            v5_packet["installed_vivado_launcher"] != record(VIVADO / "bin/vivado") or
            v5_packet["candidate_guard"] != record(GUARD) or
            v5_packet["candidate_guard_helper"] != record(GUARD_HELPER)):
        raise RuntimeError("inherited installed-tool identity drift")
    for item in v5_packet["candidate_execution_tools"]:
        if not same(item):
            raise RuntimeError("inherited execution-tool identity drift")
    return release, manifest, v5_packet, contract


def run_checked(argv: list[str], *, input_text: str | None = None) -> subprocess.CompletedProcess:
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
    result = subprocess.run(argv, input=input_text, text=True, capture_output=True,
                            timeout=30, env=env)
    if result.returncode:
        raise RuntimeError(f"source check failed {argv}: {result.stderr[-1000:]}")
    return result


def literal_diff(v5_packet: dict) -> str:
    before_root = V5_PACKET.parents[1]
    chunks = []
    for item in v5_packet["maintained_source"]:
        before = Path(item["path"])
        after = ROOT / before.relative_to(before_root)
        chunks.extend(difflib.unified_diff(
            before.read_text().splitlines(keepends=True),
            after.read_text().splitlines(keepends=True),
            fromfile=str(before), tofile=str(after)))
    return "".join(chunks)


def source_checks(contract: dict, v5_packet: dict) -> dict:
    if DIFF.read_text() != literal_diff(v5_packet):
        raise RuntimeError("literal v5-to-v6 diff drift")
    generated = run_checked(["/usr/bin/python3", str(ROOT / "tb/generate_contract_tcl.py"), "--check"])
    if generated.stdout.strip() != "Q8_WS_V4_CONTRACT_TCL_PASS":
        raise RuntimeError("exact contract Tcl check failed")
    script = (ROOT / "tb/extract_ws_graph.tcl").read_text()
    exact_export = "write_verilog -mode funcsim -write_all_overrides true -keep_vcc_gnd -cell $exact_cell $export_file"
    required_fragments = (
        str(DCP), str(REPORTS), "set banks {ws_U ws_8_U ws_9_U ws_10_U ws_11_U ws_12_U ws_13_U ws_14_U}",
        "set export_cap_bytes 268435456", "if {$length > 67108864}",
        "REQUIRED_PROPERTY_GAP", "UNKNOWN_PRIMITIVE_SEMANTICS",
        "UNDRIVEN_COMPONENT", "phase_ledger.tsv", "get_nets -quiet -segments -of_objects $pin",
        "set group_names [property_values NAME $objects property_group]",
    )
    if (script.count("open_checkpoint $dcp") != 1 or
            script.count("sha256_file $dcp") != 2 or
            script.count(exact_export) != 1 or
            any(fragment not in script for fragment in required_fragments) or
            "list_property $cell" in script or
            "write_verilog -force" in script):
        raise RuntimeError("v6 extractor static contract drift")
    forbidden = re.compile(
        r"\b(open_project|launch_runs|synth_design|generate_target|opt_design|"
        r"place_design|route_design|write_checkpoint|read_xdc|create_clock|"
        r"set_clock_uncertainty|set_property)\b")
    for number, line in enumerate(script.splitlines(), 1):
        if forbidden.search(line.split("#", 1)[0]):
            raise RuntimeError(f"forbidden Tcl command at {number}")
    for path in (ROOT / "tb/extract_ws_graph.tcl", ROOT / "source/required_properties.tcl"):
        tcl = f"set f [open {{{path}}} r]\nset s [read $f]\nclose $f\nputs [info complete $s]\n"
        if run_checked(["/usr/bin/tclsh"], input_text=tcl).stdout.strip() != "1":
            raise RuntimeError(f"Tcl completeness failed: {path}")
    tcl = f"source {{{ROOT / 'source/required_properties.tcl'}}}\nputs \"$required_ref_count $required_contract_count\"\n"
    if run_checked(["/usr/bin/tclsh"], input_text=tcl).stdout.strip() != "22 348":
        raise RuntimeError("literal Tcl contract load failed")
    for name in SOURCE_NAMES:
        if name.endswith(".py"):
            path = ROOT / name
            ast.parse(path.read_text(), filename=str(path))
    test = run_checked(["/usr/bin/python3", str(ROOT / "tb/test_funcsim_synthetic.py")])
    if "Ran 19 tests" not in test.stderr or not test.stderr.rstrip().endswith("OK"):
        raise RuntimeError("synthetic parser/join test result changed")
    sys.path.insert(0, str(ROOT / "tb"))
    from join_funcsim_graph import unisim_port_signature
    from funcsim_structure import (MAX_BUS_INDEX, MAX_EDGES, MAX_EXPRESSION_DEPTH,
                                   MAX_FILE_BYTES, MAX_HIERARCHY_DEPTH,
                                   MAX_HIERARCHY_INSTANCES, MAX_IDENTIFIER_BYTES,
                                   MAX_INSTANCE_DECLARATIONS, MAX_LITERAL_BITS,
                                   MAX_MODULES, MAX_NODES, MAX_NUMERIC_TOKEN_BYTES,
                                   MAX_PRIMITIVES, MAX_TOKENS)
    signatures = {entry["reference"]: unisim_port_signature(entry)
                  for entry in contract["primitive_contracts"]}
    if len(signatures) != 22:
        raise RuntimeError("UNISIM signature count changed")
    limits = {
        "maximum_file_bytes_per_bank": MAX_FILE_BYTES,
        "maximum_tokens_per_bank": MAX_TOKENS,
        "maximum_module_definitions_per_bank": MAX_MODULES,
        "maximum_expanded_primitives_per_bank": MAX_PRIMITIVES,
        "maximum_graph_nodes_per_bank": MAX_NODES,
        "maximum_alias_edges_per_bank": MAX_EDGES,
        "maximum_literal_bits": MAX_LITERAL_BITS,
        "maximum_numeric_token_bytes": MAX_NUMERIC_TOKEN_BYTES,
        "maximum_identifier_bytes": MAX_IDENTIFIER_BYTES,
        "maximum_bus_index": MAX_BUS_INDEX,
        "maximum_expression_depth": MAX_EXPRESSION_DEPTH,
        "maximum_expanded_hierarchy_instances": MAX_HIERARCHY_INSTANCES,
        "maximum_expanded_hierarchy_depth": MAX_HIERARCHY_DEPTH,
        "maximum_instance_declarations_per_module": MAX_INSTANCE_DECLARATIONS,
    }
    if limits != {
        "maximum_file_bytes_per_bank": 67108864,
        "maximum_tokens_per_bank": 1000000,
        "maximum_module_definitions_per_bank": 128,
        "maximum_expanded_primitives_per_bank": 256,
        "maximum_graph_nodes_per_bank": 32768,
        "maximum_alias_edges_per_bank": 65536,
        "maximum_literal_bits": 4096,
        "maximum_numeric_token_bytes": 8192,
        "maximum_identifier_bytes": 1024,
        "maximum_bus_index": 32767,
        "maximum_expression_depth": 64,
        "maximum_expanded_hierarchy_instances": 1024,
        "maximum_expanded_hierarchy_depth": 16,
        "maximum_instance_declarations_per_module": 4096,
    }:
        raise RuntimeError("parser source limits drift")
    return {"python_ast": "PASS", "tcl_info_complete": True,
            "contract_tcl_exact": True, "synthetic_parser_join_tests": 19,
            "hash_bound_unisim_pin_signatures": {
                "reference_types": len(signatures),
                "port_count": sum(map(len, signatures.values())),
                "bit_count": sum(len(port["indices"]) for signature in signatures.values()
                                 for port in signature.values())},
            "limits": limits}


def construct(created: str) -> dict:
    release, manifest, v5_packet, contract = bound_inputs()
    checks = source_checks(contract, v5_packet)
    if CONTROL.exists() or REPORTS.exists():
        raise RuntimeError("candidate control/report root is not fresh")
    tools = [Path(name) for name in ("/usr/bin/taskset", "/usr/bin/nice",
             "/usr/bin/ionice", "/usr/bin/python3", "/usr/bin/sha256sum",
             "/usr/bin/tclsh")]
    return {
        "schema": "q8_ws_v6_strict_parser_source_packet_v1",
        "created_utc": created,
        "status": "SOURCE_ONLY_NO_DCP_VIVADO_EXPORT_OR_ACTUAL_JOIN_EXECUTION",
        "source_reviewer_gate": record(RELEASE),
        "exact_v5_archive_manifest": record(MANIFEST),
        "archived_v5_preimages_rehashed": manifest["records"],
        "v5_source_packet": record(V5_PACKET),
        "v3_terminal_review": record(V3_REVIEW),
        "sealed_input_checkpoint": record(DCP),
        "unchanged_ooc_constraint": record(XDC),
        "prior_report_files_rehashed": v5_packet["prior_report_files_rehashed"],
        "installed_command_manuals": contract["installed_command_manuals"],
        "installed_primitive_semantics": [entry["semantics_file"] for entry in contract["primitive_contracts"]],
        "installed_vivado_launcher": record(VIVADO / "bin/vivado"),
        "candidate_guard": record(GUARD),
        "candidate_guard_helper": record(GUARD_HELPER),
        "candidate_execution_tools": [record(path) for path in tools],
        "inherited_v5_installed_bindings": {
            "installed_command_manuals": v5_packet["installed_command_manuals"],
            "installed_primitive_semantics": v5_packet["installed_primitive_semantics"],
            "installed_vivado_launcher": v5_packet["installed_vivado_launcher"],
            "candidate_guard": v5_packet["candidate_guard"],
            "candidate_guard_helper": v5_packet["candidate_guard_helper"],
            "candidate_execution_tools": v5_packet["candidate_execution_tools"],
        },
        "maintained_source": [record(ROOT / name) for name in SOURCE_NAMES],
        "source_checks": checks,
        "candidate_control": str(CONTROL),
        "candidate_reports": str(REPORTS),
        "candidate_paths_absent_at_seal": True,
        "candidate_budget_not_released": {
            "checkpoint_opens": 1, "functional_exports": 8,
            "aggregate_export_bytes": 268435456,
            "per_bank_export_bytes": 67108864,
            "owned_rss_gib": 12, "wall_seconds": 900,
            "cpu_ids": [0, 1, 2, 3], "nice": 19, "ionice_class": 3,
            "sampling_seconds": 0.2, "minimum_mem_available_gib_strictly_above": 192,
        },
        "candidate_argv_not_released": [
            "/usr/bin/taskset", "-c", "0-3", "/usr/bin/nice", "-n", "19",
            "/usr/bin/ionice", "-c", "3", "/usr/bin/python3", str(GUARD),
            "--out", str(CONTROL / "extraction_guard"), "--cwd", str(CONTROL),
            "--rss-gib", "12", "--timeout-seconds", "900", "--",
            str(VIVADO / "bin/vivado"), "-mode", "batch", "-notrace",
            "-source", str(ROOT / "tb/extract_ws_graph.tcl"),
            "-log", str(CONTROL / "vivado.log"),
            "-journal", str(CONTROL / "vivado.jou"),
            "-tclargs", str(DCP), str(REPORTS),
        ],
        "candidate_postcheck": "DCP SHA256 unchanged; 8 exact export files and per-export ledger hashes; 11 graph tables; terminal extraction COMPLETE; archive partial outputs on first failure",
        "actual_parser_join_execution_released": False,
        "actual_parser_join_budget_and_argv": "SEPARATE_INDEPENDENT_GATE_REQUIRED",
        "mapping_evaluator_released": False,
        "ws_mapping_acceptance": "HELD_ALL_8x20992x16_BITS_INCLUDING_ADDRESSES_16384_TO_20991",
        "timing_150MHz_board_acceptance": "NOT_ESTABLISHED",
        "execution_released": False,
        "resynthesis_released": False,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seal", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.seal == args.check:
        parser.error("choose exactly one of --seal or --check")
    if args.seal:
        if OUT.exists():
            raise RuntimeError("source packet already exists")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        with OUT.open("x", encoding="utf-8") as stream:
            json.dump(packet, stream, indent=2, sort_keys=True)
            stream.write("\n")
        print(f"Q8_WS_V6_SOURCE_PACKET_CREATED sha256={record(OUT)['sha256']}")
    else:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise RuntimeError("v6 source packet or bound input drift")
        print(f"Q8_WS_V6_SOURCE_PACKET_PASS sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
