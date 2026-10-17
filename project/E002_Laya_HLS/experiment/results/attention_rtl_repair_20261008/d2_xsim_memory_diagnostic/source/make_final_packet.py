#!/usr/bin/env python3
"""Bind the frozen diagnostic inputs, tool commands, snapshot and observed results."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


MODULE = Path(__file__).resolve().parent.parent
RUNS = MODULE / "runs"
SOURCE = MODULE / "source"
TB = MODULE / "tb"
RTL = MODULE / "rtl"


def artifact(path: Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def job(name: str) -> dict:
    directory = RUNS / "guards" / name
    files = {p.name: artifact(p) for p in directory.iterdir() if p.is_file()}
    return {"name": name, "files": files,
            "guard": json.loads((directory / "guard_result.json").read_text()),
            "actual_wrapped_command": json.loads((directory / "guard_plan.json").read_text())["command"]}


def main() -> None:
    diagnostic = json.loads((RUNS / "diagnostic_results.json").read_text())
    if len(diagnostic["results"]) != 12 or any(
            r["guard"]["trigger"] is not None or r["guard"]["child_exit_code"] != 0
            for r in diagnostic["results"]):
        raise RuntimeError("diagnostic ladder not complete and clean")
    jobs = [job(name) for name in
            ("gcc", "xvlog", "xvlog_uvm", "xelab", "xelab_lib")]
    jobs += [job(f"{mode}_{depth}") for depth in (1024, 4096, 16384, 65536)
             for mode in ("q", "m", "f")]
    snapshot_dir = RUNS / "build/xsim.dir/diag_mem"
    files = [SOURCE / "design.md", SOURCE / "results.md",
             SOURCE / "prepare_diagnostic.py", SOURCE / "instrumentation.diff",
             SOURCE / "source_manifest.json", SOURCE / "guard_job.py",
             SOURCE / "hls_guard_helpers.py", SOURCE / "run_ladder.py",
             SOURCE / "analyze_results.py", SOURCE / "make_final_packet.py",
             RUNS / "diagnostic_results.json", RUNS / "analysis.json",
             TB / "diag_tb.sv", TB / "diag_rss.c", TB / "libdiag_rss.so",
             RUNS / "build/diag_rss.so"]
    files += sorted(RTL.glob("*.sv"))
    files += sorted((SOURCE / "original").glob("*.sv"))
    files += sorted((TB / "data").glob("*"))
    files += sorted(p for p in snapshot_dir.rglob("*") if p.is_file())
    files += [RUNS / "build/xvlog.log", RUNS / "build/xelab.log"]
    packet = {
        "purpose": "Independent 1-64 KiB generated XSim file-agent/memory-model diagnostic, no Attention DUT",
        "result": "Q/M/F all 12 fresh-process jobs passed byte-for-byte; no guard trigger",
        "tool": "Vivado Simulator v2025.2",
        "compilation_sources": [str((RTL / "file_agent_pkg.sv").resolve()),
                                str((TB / "diag_tb.sv").resolve()),
                                str((TB / "diag_rss.c").resolve())],
        "package_includes": [str((RTL / n).resolve()) for n in
                             ("file_read_agent.sv", "file_write_agent.sv", "mem_model.sv")],
        "stage_observation": "DPI C reads /proc/self/status in the XSim kernel process at each stage; /proc task-tree guard samples every 0.1 s. Stage calls and reader assertions are shown in instrumentation.diff.",
        "previous_compile_corrections": {
            "xvlog": "Initial compile omitted -L uvm; final xvlog_uvm passed.",
            "xelab": "Initial elaboration sought diag_rss.so in build cwd; final xelab_lib used a copied identical library and -mt off."},
        "jobs": jobs,
        "artifacts": {str(p.resolve()): artifact(p) for p in files},
        "limitation": "Results apply only to single-transaction fixture-prefix depths 1, 4, 16, 64 KiB. No full DUT re-run or full-scale memory bound is authorized or inferred."}
    output = RUNS / "final_packet.json"
    output.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(f"{output}: {artifact(output)['sha256']}")


if __name__ == "__main__":
    main()
