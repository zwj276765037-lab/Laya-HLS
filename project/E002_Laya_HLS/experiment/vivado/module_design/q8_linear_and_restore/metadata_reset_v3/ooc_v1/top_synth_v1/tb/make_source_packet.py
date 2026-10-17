#!/usr/bin/env python3
"""Seal the isolated top-synthesis source candidate without running EDA."""

from __future__ import annotations

import argparse
import datetime as dt
import difflib
import json
from pathlib import Path

from project_identity import (ACCEPTANCE, ACCEPTANCE_SHA256, OOC, SOURCE,
                              XPR, accepted_evidence, check_source, record)


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "source/source_packet.json"
SOURCE_PREFLIGHT = ROOT / "source/a2_source_preflight.json"
ORIGINAL_GUARD = OOC / "source/guard_12g_v1/guard_runtime_12g.py"
ORIGINAL_HELPER = OOC / "source/guard_12g_v1/hls_guard_helpers.py"
NEW_GUARD = ROOT / "source/guard_48g_v1/guard_runtime_48g.py"
NEW_HELPER = ROOT / "source/guard_48g_v1/hls_guard_helpers.py"
ORIGINAL_SYNTH = OOC / "tb/synth_ooc.tcl"
OVERLAY_SYNTH = ROOT / "tb/synth_ooc_top_v1.tcl"
XCI_CHECKER = OOC / "source/candidates/project_local_ip_import_v2/verify_imported_xci.py"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")


def canonical_diff(before: Path, after: Path) -> str:
    return "".join(difflib.unified_diff(
        before.read_text().splitlines(True), after.read_text().splitlines(True),
        fromfile=str(before.relative_to(ROOT) if before.is_relative_to(ROOT)
                     else before.relative_to(OOC)),
        tofile=str(after.relative_to(ROOT))))


def construct(created_utc: str) -> dict:
    acceptance, evidence = accepted_evidence()
    source_binding, source_rows = check_source()
    if len(source_rows) != 438 or record(ACCEPTANCE)["sha256"] != ACCEPTANCE_SHA256:
        raise RuntimeError("accepted a2 source identity changed")
    preflight = json.loads(SOURCE_PREFLIGHT.read_text())
    if (preflight["status"] != "SOURCE_PREFLIGHT_PASS" or
            preflight["source_file_count"] != 438 or
            preflight["source_binding"] != source_binding or
            preflight["source_files"] != source_rows):
        raise RuntimeError("read-only a2 source preflight changed")
    before = ORIGINAL_GUARD.read_text()
    if before.count("choices=(4, 12)") != 1 or \
            NEW_GUARD.read_text() != before.replace("choices=(4, 12)",
                                                     "choices=(4, 12, 48)"):
        raise RuntimeError("48 GiB guard differs by more than its exact choice")
    if ORIGINAL_HELPER.read_bytes() != NEW_HELPER.read_bytes():
        raise RuntimeError("owned-process guard helper changed")
    guard_diff = ROOT / "source/guard_48g_v1/guard.diff"
    synth_diff = ROOT / "source/synth_overlay.diff"
    if guard_diff.read_text() != canonical_diff(ORIGINAL_GUARD, NEW_GUARD):
        raise RuntimeError("guard canonical diff changed")
    if synth_diff.read_text() != canonical_diff(ORIGINAL_SYNTH, OVERLAY_SYNTH):
        raise RuntimeError("synthesis overlay canonical diff changed")
    if record(XCI_CHECKER)["sha256"] != \
            "771fb3a9e1965ce1c51aa40eb326263cfad4527a34941a39638e0e410e4f6817":
        raise RuntimeError("strict v2 imported-XCI checker changed")
    maintained = [ROOT / name for name in (
        "source/design.md", "source/results.md", "source/a2_source_preflight.json",
        "source/synth_overlay.diff", "source/guard_48g_v1/guard_runtime_48g.py",
        "source/guard_48g_v1/hls_guard_helpers.py",
        "source/guard_48g_v1/guard.diff", "rtl/README.md", "tb/README.md",
        "tb/project_identity.py", "tb/verify_clone.py", "tb/clone_project.py",
        "tb/verify_actual_compile.py", "tb/synth_ooc_top_v1.tcl",
        "tb/make_source_packet.py",
    )]
    return {
        "schema": "q8_top_ooc_isolated_clone_source_packet_v1",
        "created_utc": created_utc,
        "status": "SOURCE_ONLY_REVIEW_REQUIRED_NO_CLONE_OR_EDA_EXECUTION",
        "authority": record(ACCEPTANCE),
        "accepted_a2_final_evidence": record(Path(acceptance["evidence"]["path"])),
        "accepted_a2_xpr": record(SOURCE / XPR),
        "accepted_ooc_source_packet": record(OOC / "source/source_packet.json"),
        "accepted_ooc_input_manifest": record(OOC / "source/input_manifest.json"),
        "original_synth_tcl": record(ORIGINAL_SYNTH),
        "original_12g_guard": record(ORIGINAL_GUARD),
        "original_guard_helper": record(ORIGINAL_HELPER),
        "strict_v2_imported_xci_checker": record(XCI_CHECKER),
        "vivado_launcher": record(VIVADO),
        "maintained_source": [record(path) for path in maintained],
        "source_tree_file_count": 438,
        "accepted_compile_count": 243,
        "accepted_compiled_breakdown": acceptance["independent_checks"]["compiled_breakdown"],
        "accepted_generated_fp_products": evidence["product_identity"]["generated_ip_products"],
        "accepted_shared_synthesis_libraries": evidence["product_identity"]["shared_library_candidates"],
        "future_clone_root": str(OOC / "runs/top_synth_v1"),
        "future_control_root": str(OOC / "runs/top_synth_v1_control"),
        "future_report_root": str(OOC / "runs/top_synth_v1_reports"),
        "proposed_single_top_synthesis_limit": {
            "owned_rss_gib": 48, "wall_seconds_including_reports": 14400,
            "cpu_ids": [0, 1, 2, 3], "nice": 19, "ionice": "idle",
            "owned_rss_sample_seconds": 0.2,
            "mem_available_must_exceed_gib": 192,
            "execution_release": False},
        "top_synthesis": "NOT_RUN",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise RuntimeError("top OOC source packet drift")
        print(f"Q8_TOP_OOC_SOURCE_PACKET_PASS sha256={record(OUT)['sha256']}")
    else:
        if OUT.exists():
            raise RuntimeError(f"source packet already exists: {OUT}")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
        print(f"Q8_TOP_OOC_SOURCE_PACKET_CREATED sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
