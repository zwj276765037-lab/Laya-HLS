#!/usr/bin/env python3
"""Create or read-only verify the isolated same-source OOC source packet."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

from verify_inputs import verify


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "source/source_packet.json"
MANIFEST = ROOT / "source/input_manifest.json"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
RELEASE_SHA256 = "276192bf2c1fe883ae94fbb8eb945af84be85f396fd60021415c41dc12d39a85"
PRECHECK_SHA256 = "d79b631b871ed6aa94bf04e9c7cdd35edf84735dd2ead7afb31a04e2582c639b"
V2_PREIMAGES = {
    "source_packet.json": "202471e6d0e9655dd6c7f008d6761049215c7a38a2b7b73b0e8886c4b46951c3",
    "source_check.json": "e2b6e0c27c56820a915048d77c83971ca50437340d6600b33660f22ca4f19ccf",
    "verify_project_outputs.py": "f96e1495e780e2a0045570aa1616c6e3bc45951279de6d3ffb08a0cf26fde074",
    "report_ws_banks.tcl": "f8b547c964ce23475cbc10fd549cd10d2c88c7e60be1fcfadffac84861804548",
    "make_source_packet.py": "a2b860c51f52332fa8e1acde222032a8bd209ac0fa7ddfcad61aca0c0d2da61e",
}
V3_PREIMAGES = {
    "source_packet.json": "602628bfcd2f9de2a128c8cb3d9fa2906b7c643fad2ab9d0a28314b6226591b6",
    "source_check.json": "1ad4ec3b0a8c814da3401d534d8cd075493d281c530df6d6c19193648193c41b",
    "report_ws_banks.tcl": "0c06e20683488897665ee36cf2ab8b93ce2e287ca56ce997e9d3ddd612d25050",
    "make_source_packet.py": "37876365dc502d791c78e27b751e53d1a7fa17e57be24540a00a313fac5fc685",
}


def record(path: Path) -> dict:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": h.hexdigest()}


def construct(created_utc: str) -> dict:
    manifest, rows = verify()  # Rehash every one of the 366 original inputs.
    archived = []
    for name, digest in V2_PREIMAGES.items():
        item = record(ROOT / "source/preimages/v2" / name)
        if item["sha256"] != digest:
            raise RuntimeError(f"V2 preimage identity mismatch: {name}")
        archived.append(item)
    archived_v3 = []
    for name, digest in V3_PREIMAGES.items():
        item = record(ROOT / "source/preimages/v3" / name)
        if item["sha256"] != digest:
            raise RuntimeError(f"V3 preimage identity mismatch: {name}")
        archived_v3.append(item)
    release = Path(manifest["source_preparation_release_path"])
    precheck = Path(manifest["reviewed_precheck_path"])
    if record(release)["sha256"] != RELEASE_SHA256 or manifest["source_preparation_release_sha256"] != RELEASE_SHA256:
        raise RuntimeError("source-preparation release identity mismatch")
    if record(precheck)["sha256"] != PRECHECK_SHA256 or manifest["reviewed_precheck_sha256"] != PRECHECK_SHA256:
        raise RuntimeError("accepted prerequisites identity mismatch")
    if manifest["part"] != "xcu55c-fsvh2892-2L-e" or manifest["top"] != "q8_joint_tm4tn8":
        raise RuntimeError("part/top drift")
    if manifest["ap_clk_period_ns"] != 6.667:
        raise RuntimeError("OOC clock request drift")
    scripts = [ROOT / "tb" / name for name in (
        "create_project.tcl", "verify_project.tcl", "prepare_dat.tcl",
        "synth_ooc.tcl", "report_ws_banks.tcl")]
    maintained = [ROOT / "tb/verify_inputs.py", ROOT / "tb/make_source_packet.py",
                  ROOT / "tb/verify_project_outputs.py",
                  *scripts, ROOT / "source/design.md", ROOT / "source/results.md",
                  ROOT / "rtl/README.md"]
    if set((ROOT / "tb").glob("*.tcl")) != set(scripts):
        raise RuntimeError("maintained Tcl script set drift")
    counts = manifest["counts"]
    if len(rows) != 366 or sum(counts.values()) != 366:
        raise RuntimeError("input manifest count drift")
    return {
        "schema": "q8_same_source_ooc_source_packet_v4",
        "created_utc": created_utc,
        "status": "SOURCE_ONLY_NO_VIVADO_EXECUTION_RELEASE",
        "accepted_prerequisites": record(precheck),
        "source_preparation_release": record(release),
        "original_input_manifest": record(MANIFEST),
        "original_input_count": len(rows),
        "original_input_counts": counts,
        "stage_input_count": sum(counts[k] for k in ("verilog", "data", "ip_tcl", "ip_xci", "ooc_xdc")),
        "candidate_synthesis_compile_files": counts["verilog"] + counts["ip_synth_vhdl"] + counts["shared_synth_vhdl"],
        "target_part": manifest["part"],
        "top": manifest["top"],
        "ap_clk_period_ns_requested": manifest["ap_clk_period_ns"],
        "vivado_launcher": record(VIVADO),
        "archived_v2_preimages": archived,
        "archived_v3_preimages": archived_v3,
        "v3_source_corrections": [
            "A shared synthesis VHDL absent from actual compile order is REVIEW_REQUIRED, not PASS.",
            "Ws audit inventories all bank primitive REF/type categories including FF/LUTRAM/LUT and records address[14:0]/WE/CE/EN reachability to primitive pins, nets and immediate drivers for independent review.",
        ],
        "v4_source_corrections": [
            "Use a Tcl nested-dictionary update for per-bank primitive-category counters; dict incr does not accept nested keys.",
            "Treat the BRAM/URAM-only bank absence flag as provisional; reset it before the full primitive/address-source audit so FF/LUTRAM mappings are reviewable without a false fatal.",
        ],
        "maintained_source": [record(path) for path in maintained],
        "proposed_unreleased_limits": {
            "project_ip_preparation": {"owned_rss_gib": 12, "wall_seconds": 1800},
            "top_ooc_synthesis": {"owned_rss_gib": 48, "wall_seconds": 14400},
            "selected_cpu_ids": [0, 1, 2, 3],
            "nice": 19,
            "ionice": "idle",
            "minimum_mem_available_gib_strictly_greater_than": 192,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--create", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.create:
        if OUT.exists():
            raise RuntimeError("source packet already exists")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
        print(f"Q8_OOC_SOURCE_PACKET_CREATED inputs={packet['original_input_count']} maintained={len(packet['maintained_source'])} sha256={record(OUT)['sha256']}")
    else:
        if not OUT.is_file():
            raise RuntimeError("source packet missing")
        recorded = json.loads(OUT.read_text())
        current = construct(recorded["created_utc"])
        if recorded != current:
            raise RuntimeError("source packet binding mismatch")
        print(f"Q8_OOC_SOURCE_PACKET_PASS inputs={current['original_input_count']} maintained={len(current['maintained_source'])} sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
