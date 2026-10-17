#!/usr/bin/env python3
"""Seal R0 source and the unchanged seven-wrapper/library lineage."""

from __future__ import annotations

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


def record(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def require_record(item: dict) -> None:
    actual = record(Path(item["path"]))
    if any(actual[key] != item[key] for key in ("bytes", "sha256")):
        raise RuntimeError(f"bound input drift: {item['path']}")


def main() -> None:
    if OUT.exists():
        raise RuntimeError(f"source packet already exists: {OUT}")
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
        "schema": "q8_r0_finite_domain_source_packet_v1",
        "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "status": "SOURCE_ONLY_NO_R0_REFERENCE_OR_ADAPTER_EXECUTION",
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
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(f"R0_SOURCE_PACKET_CREATED wrappers=7 inputs=28 maintained={len(maintained)} "
          f"sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
