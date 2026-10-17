#!/usr/bin/env python3
"""Run Q, M, F in fresh guarded XSim processes, stopping on first failure."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


MODULE = Path(__file__).resolve().parent.parent
BUILD = MODULE / "runs/build"
GUARDS = MODULE / "runs/guards"
XSIM = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim")
DEPTHS = (1024, 4096, 16384, 65536)
MODES = ("Q", "M", "F")
STAGE = re.compile(r"DIAG_STAGE epoch_ms=(\d+) pid=(\d+) label=(\S+) elements=(-?\d+) aux=(-?\d+) rss_kb=(-?\d+) hwm_kb=(-?\d+)")
TRAILER = int("5a5aa5a50f0ff0f0", 16)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checked_result(depth: int, mode: str) -> dict:
    out = GUARDS / f"{mode.lower()}_{depth}"
    result = json.loads((out / "guard_result.json").read_text())
    log = (out / "driver.log").read_text(errors="replace")
    expected = f"DIAG_PASS mode={mode} depth={depth} bytes={depth}"
    if (result["child_exit_code"] != 0 or result["trigger"] is not None or
            log.count(expected) != 1 or re.search(r"(^|\n)(FATAL:|ERROR:|UVM_FATAL)", log)):
        raise RuntimeError(f"{mode}/{depth} guard or diagnostic failure; see {out}")
    stages = [dict(epoch_ms=int(m[1]), pid=int(m[2]), label=m[3],
                   elements=int(m[4]), aux=int(m[5]), rss_kb=int(m[6]), hwm_kb=int(m[7]))
              for m in STAGE.finditer(log)]
    if not stages or any(stage["rss_kb"] < 0 or stage["hwm_kb"] < 0 for stage in stages):
        raise RuntimeError(f"missing in-process RSS stages: {mode}/{depth}")
    if mode in ("Q", "F"):
        expected_stages = ("reader_header", "reader_queue_power2", "reader_before_2d_copy",
                           "reader_after_2d_copy", "reader_after_trailer")
        if not all(any(s["label"] == label for s in stages) for label in expected_stages):
            raise RuntimeError(f"missing reader stages: {mode}/{depth}")
        first = {s["label"]: s for s in stages if s["label"] in expected_stages}
        if (first["reader_header"]["elements"] != depth or first["reader_header"]["aux"] != 8 or
                first["reader_queue_power2"]["elements"] != depth or
                first["reader_queue_power2"]["aux"] != depth + 8 or
                first["reader_before_2d_copy"]["elements"] != depth or
                first["reader_before_2d_copy"]["aux"] != 0 or
                first["reader_after_2d_copy"]["elements"] != depth or
                first["reader_after_2d_copy"]["aux"] != 1 or
                first["reader_after_trailer"]["elements"] != TRAILER or
                first["reader_after_trailer"]["aux"] != depth + 16):
            raise RuntimeError(f"reader frame/queue/count stage mismatch: {mode}/{depth}")
    if mode == "M" and not all(any(s["label"] == label and s["elements"] == depth for s in stages)
                                for label in ("mem_after_mem_alloc", "mem_after_iswr_alloc",
                                              "M_after_writes", "readback_verified")):
        raise RuntimeError(f"missing direct-memory stages: {mode}/{depth}")
    if mode == "F" and not all(any(s["label"] == label for s in stages)
                                for label in ("mem_after_mem_alloc", "mem_after_iswr_alloc",
                                              "pages_after_copy", "offset_bound", "readback_verified")):
        raise RuntimeError(f"missing full-chain stages: {mode}/{depth}")
    if mode == "F":
        first = {s["label"]: s for s in stages}
        if (first["mem_after_mem_alloc"]["elements"] != depth or
                first["mem_after_iswr_alloc"]["elements"] != depth or
                first["pages_after_copy"]["elements"] != depth or
                first["pages_after_copy"]["aux"] != 1 or
                first["offset_bound"]["elements"] != 0 or
                first["offset_bound"]["aux"] != 1 or
                first["readback_verified"]["elements"] != depth):
            raise RuntimeError(f"full-memory depth/copy/offset stage mismatch: {mode}/{depth}")
    return {"depth": depth, "mode": mode, "guard": result, "stages": stages,
            "driver_log_sha256": sha(out / "driver.log"),
            "guard_plan_sha256": sha(out / "guard_plan.json")}


def main() -> None:
    manifest = json.loads((MODULE / "source/source_manifest.json").read_text())
    for filename, metadata in manifest["artifacts"].items():
        if sha(Path(filename)) != metadata["sha256"]:
            raise RuntimeError(f"frozen source changed: {filename}")
    for depth in DEPTHS:
        for mode in MODES:
            out = GUARDS / f"{mode.lower()}_{depth}"
            if (out / "guard_result.json").exists():
                checked_result(depth, mode)
                print(f"verified existing {mode}/{depth}", flush=True)
                continue
            command = [sys.executable, str(MODULE / "source/guard_job.py"),
                       "--out", str(out), "--cwd", str(BUILD),
                       "--rss-gib", "2", "--timeout-seconds", "120", "--",
                       str(XSIM), "diag_mem", "--runall", "--onerror", "quit", "--onfinish", "quit",
                       "--testplusarg", f"MODE={mode}", "--testplusarg", f"DEPTH={depth}",
                       "--testplusarg", f"TV=../../tb/data/tv_{depth}.dat",
                       "--testplusarg", f"RAW=../../tb/data/raw_{depth}.dat",
                       "--testplusarg", "OFFSET=../../tb/data/offset_r.dat"]
            out.mkdir(parents=True, exist_ok=True)
            completed = subprocess.run(command, check=False)
            if completed.returncode != 0:
                raise RuntimeError(f"guard failed for {mode}/{depth}: {completed.returncode}; see {out}")
            checked_result(depth, mode)
            print(f"passed {mode}/{depth}", flush=True)
    outputs = [checked_result(depth, mode) for depth in DEPTHS for mode in MODES]
    provenance = {"xsim": str(XSIM), "xsim_sha256": sha(XSIM),
                  "snapshot": "diag_mem", "artifact_hashes": {str(p): sha(p) for p in
                  [MODULE / "tb/diag_tb.sv", MODULE / "tb/diag_rss.c", MODULE / "tb/libdiag_rss.so",
                   MODULE / "runs/build/diag_rss.so", MODULE / "source/guard_job.py",
                   MODULE / "source/hls_guard_helpers.py", MODULE / "source/run_ladder.py"]},
                  "results": outputs}
    (MODULE / "runs/diagnostic_results.json").write_text(json.dumps(provenance, indent=2, sort_keys=True) + "\n")
    print("all Q/M/F depth jobs passed", flush=True)


if __name__ == "__main__":
    main()
