#!/usr/bin/env python3
"""Seal R0 source and the unchanged seven-wrapper/library lineage."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT.parent / "rtl_fp_boundary_v1"
FP_PACKET = BASE / "source/source_packet.json"
FP_SNAPSHOT = BASE / "runs/static_build_v1/source_snapshot_pre_runtime.json"
FP_ACCEPTANCE = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/"
                     "Laya-baseline/results/attention_rtl_repair_20261008/"
                     "reviewer_q8_actual_fp_boundary_119_characterization_acceptance.json")
SCORER_PACKET = ROOT.parent / "rtl_full_dimensions_v1/source_binding_v6/source_packet.json"
OUT = ROOT / "source/source_packet.json"
ARCHIVE = ROOT / "source/preimages/v1"
ARCHIVE_MANIFEST = ARCHIVE / "archive_manifest.json"
V1_PACKET = ARCHIVE / "source/source_packet.json"
V1_CHECK = ARCHIVE / "source/source_check.json"
ASTRA_DESIGN = ROOT / "source/preimages/astra_original_design.md"
ASTRA_PREFIX_CHECK = ROOT / "source/preimages/astra_design_prefix_check.json"
ASTRA_DESIGN_SHA256 = "321080d93185336aba66048af759cd982be143fe524f669f3de0c06c7729077b"


def record(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def require_record(item: dict) -> None:
    actual = record(Path(item["path"]))
    if any(actual[key] != item[key] for key in ("bytes", "sha256")):
        raise RuntimeError(f"bound input drift: {item['path']}")


def preimages() -> dict:
    archive = json.loads(ARCHIVE_MANIFEST.read_text())
    if (archive["schema"] != "q8_r0_source_v1_preimage_archive_v1" or
            archive["status"] != "BYTE_IDENTICAL_PREIMAGES_BEFORE_ASTRA_CORRECTIONS" or
            len(archive["files"]) != 18 or
            archive["source_packet_sha256"] !=
            "7efb0de9fb60a0a2a7436a571bba3570ed9f9acbd927ef35ff54db6fef591668"):
        raise RuntimeError("v1 preimage archive structure drift")
    relative_paths = set()
    for item in archive["files"]:
        relative = Path(item["relative_path"])
        if (relative.is_absolute() or ".." in relative.parts or
                item["archive_path"] != str(ARCHIVE / relative) or
                item["original_path"] != str(ROOT / relative) or
                str(relative) in relative_paths):
            raise RuntimeError("v1 archive path drift")
        relative_paths.add(str(relative))
        require_record({"path": item["archive_path"],
                        "bytes": item["bytes"], "sha256": item["sha256"]})
    if (record(V1_PACKET)["sha256"] != archive["source_packet_sha256"] or
            json.loads(V1_PACKET.read_text())["schema"] !=
            "q8_r0_finite_domain_source_packet_v1" or
            {"source/source_packet.json", "source/source_check.json"} - relative_paths):
        raise RuntimeError("preserved v1 packet/check drift")
    design = ASTRA_DESIGN.read_bytes()
    prefix = json.loads(ASTRA_PREFIX_CHECK.read_text())
    if (len(design) != 13914 or hashlib.sha256(design).hexdigest() !=
            ASTRA_DESIGN_SHA256 or
            not (ROOT / "source/design.md").read_bytes().startswith(design) or
            prefix["schema"] != "q8_r0_astra_design_prefix_preimage_v1" or
            prefix["preimage_path"] != str(ASTRA_DESIGN) or
            prefix["bytes"] != len(design) or
            prefix["sha256"] != ASTRA_DESIGN_SHA256 or
            prefix["current_prefix_exact"] is not True):
        raise RuntimeError("Astra design prefix drift")
    return {"preimage_archive_manifest": record(ARCHIVE_MANIFEST),
            "preserved_v1_source_packet": record(V1_PACKET),
            "preserved_v1_source_check": record(V1_CHECK),
            "astra_original_design_prefix": record(ASTRA_DESIGN),
            "astra_design_prefix_check": record(ASTRA_PREFIX_CHECK),
            "preimage_archive_file_count": len(archive["files"])}


def construct(created_utc: str) -> dict:
    fp = json.loads(FP_PACKET.read_text())
    scorer = json.loads(SCORER_PACKET.read_text())
    if (fp["schema"] != "q8_actual_fp_boundary_source_packet_v1" or
            len(fp["source_inputs"]) != 28 or fp["bound_wrapper_count"] != 7 or
            len(fp["installed_fp_library_files"]) != 3 or
            len(fp["tool_launchers"]) != 4):
        raise RuntimeError("accepted FP packet structure drift")
    if record(SCORER_PACKET) != fp["inherited_accepted_scorer_packet"]:
        raise RuntimeError("accepted Scorer lineage drift")
    for item in (fp["source_inputs"] + fp["installed_fp_library_files"] +
                 fp["tool_launchers"] + scorer["immutable_files"]):
        require_record(item)
    if not FP_SNAPSHOT.is_file() or not FP_ACCEPTANCE.is_file():
        raise RuntimeError("accepted FP snapshot or acceptance evidence missing")
    preserved = preimages()
    maintained = [ROOT / name for name in (
        "source/design.md", "source/results.md", "rtl/README.md",
        "rtl/r0_fp_bits_pkg.sv", "tb/README.md", "tb/vector_manifest.json",
        "tb/original_r0_reference.py", "tb/generate_vectors.py",
        "tb/verify_generated_vectors.py", "tb/r0_adapter_probe_top.sv",
        "tb/audit_raw.py", "tb/make_source_packet.py",
        "tb/verify_source_binding.py", "tb/run_vectors.sh",
        "tb/build_static.sh", "tb/run_adapter.sh",
    )]
    packet = {
        "schema": "q8_r0_finite_domain_source_packet_v2",
        "created_utc": created_utc,
        "status": "SOURCE_ONLY_NO_R0_REFERENCE_OR_ADAPTER_EXECUTION",
        **preserved,
        "inherited_actual_fp_packet": record(FP_PACKET),
        "inherited_accepted_scorer_packet": record(SCORER_PACKET),
        "accepted_fp_119_evidence": record(FP_ACCEPTANCE),
        "accepted_fp_pre_runtime_snapshot_report": record(FP_SNAPSHOT),
        "source_inputs": fp["source_inputs"],
        "installed_fp_library_files": fp["installed_fp_library_files"],
        "tool_launchers": fp["tool_launchers"],
        "maintained_source": [record(path) for path in maintained],
        "bound_wrapper_count": 7,
        "bound_input_count": 28,
        "xsim_link_libraries": fp["xsim_link_libraries"],
        "snapshot_runtime_mutable_allowlist": [
            "r0_adapter_probe/xsim_script.tcl",
            "r0_adapter_probe/xsimSettings.ini",
            "r0_adapter_probe/xsimkernel.log",
            "r0_adapter_probe/xsimcrash.log",
        ],
    }
    return packet


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise RuntimeError("R0 v2 source packet drift")
        print(f"R0_SOURCE_PACKET_V2_PASS sha256={record(OUT)['sha256']}")
        return
    if (not OUT.is_file() or record(OUT) != record(V1_PACKET) | {"path": str(OUT)}):
        raise RuntimeError("current packet is not the preserved exact v1 preimage")
    packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
    temporary = OUT.with_name("source_packet_v2.tmp")
    if temporary.exists():
        raise RuntimeError(f"fresh temporary packet path required: {temporary}")
    temporary.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    temporary.replace(OUT)
    print(f"R0_SOURCE_PACKET_V2_CREATED wrappers=7 inputs=28 "
          f"maintained={len(packet['maintained_source'])} "
          f"sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
