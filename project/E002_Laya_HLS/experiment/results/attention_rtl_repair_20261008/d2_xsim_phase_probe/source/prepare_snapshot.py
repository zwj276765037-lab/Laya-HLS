#!/usr/bin/env python3
"""Copy v3 generated RTL environment and full C TV without compiled caches."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import shutil


MODULE = Path(__file__).resolve().parent.parent
RESULTS = MODULE.parent
SIM = RESULTS / "d2_attention_slice/runs/depth_v3/csynth_work/hls/sim"
V3_LIST = RESULTS / "d2_attention_slice/runs/depth_v3/cosim_watchdog/compiled_and_vectors.sha256"
V3_VERILOG = SIM / "verilog"
VERILOG = MODULE / "rtl/verilog"
TV = MODULE / "rtl/tv"
ORIGINAL = MODULE / "source/original_selected"
SELECTED = (
    "attention_slice.autotb.v", "file_agent/file_agent_pkg.sv",
    "file_agent/file_read_agent.sv", "file_agent/mem_model.sv",
    "axivip/axi_monitor.sv", "axivip/axi_state.sv",
    "attention_slice_subsystem/attention_slice_reference_model.sv",
    "attention_slice_subsystem/attention_slice_env.sv",
    "svtb/misc_interface.sv", "svtb/sv_module_top.sv")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def ignore(_directory: str, names: list[str]) -> set[str]:
    skip = {"xsim.dir", ".Xil", "__pycache__"}
    return {name for name in names if name in skip or
            name.endswith((".log", ".jou", ".wdb", ".pb", ".backup"))}


def main() -> None:
    if VERILOG.exists() or TV.exists():
        raise RuntimeError("phase-probe snapshot already exists; never replace it in place")
    shutil.copytree(V3_VERILOG, VERILOG, ignore=ignore)
    shutil.copytree(SIM / "tv", TV)
    ORIGINAL.mkdir(parents=True, exist_ok=True)
    for relative in SELECTED:
        target = ORIGINAL / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(V3_VERILOG / relative, target)
    shutil.copyfile(V3_LIST, MODULE / "source/v3_compiled_and_vectors.sha256")
    entries = []
    for line in V3_LIST.read_text().splitlines():
        digest, original_name = line.split(maxsplit=1)
        original = Path(original_name)
        if original.is_relative_to(V3_VERILOG):
            copied = VERILOG / original.relative_to(V3_VERILOG)
        elif original.is_relative_to(SIM / "tv"):
            copied = TV / original.relative_to(SIM / "tv")
        else:
            raise RuntimeError(f"v3 artifact outside generated environment: {original}")
        if not copied.is_file() or sha(original) != digest or sha(copied) != digest:
            raise RuntimeError(f"v3 copied input mismatch: {original}")
        entries.append({"v3": str(original), "copy": str(copied.resolve()),
                        "sha256": digest, "bytes": copied.stat().st_size})
    if len(entries) != 212:
        raise RuntimeError(f"expected 212 v3 artifacts; got {len(entries)}")
    prj = (VERILOG / "attention_slice.prj").read_text().splitlines()
    sources = [line for line in prj if line.startswith(("sv ", "vhdl ", "verilog "))]
    if len(sources) != 188:
        raise RuntimeError(f"expected 188 compiled sources; got {len(sources)}")
    report = {"v3_manifest": str(V3_LIST), "v3_manifest_sha256": sha(V3_LIST),
              "compiled_sources": 188, "compiled_and_C_vector_artifacts": entries,
              "copied_tv_directory": str(TV.resolve()),
              "selected_original_files": {relative: sha(ORIGINAL / relative) for relative in SELECTED}}
    (MODULE / "source/snapshot_manifest.json").write_text(json.dumps(report, indent=2) + "\n")
    print("PHASE_PROBE_SNAPSHOT_PASS sources=188 artifacts=212")


if __name__ == "__main__":
    main()
