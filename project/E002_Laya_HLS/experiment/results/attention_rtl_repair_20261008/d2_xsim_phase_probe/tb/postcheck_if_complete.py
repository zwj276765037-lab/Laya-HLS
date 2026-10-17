#!/usr/bin/env python3
"""Run the unchanged generated C postcheck only after an original RTL finish."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess


MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[2]
WRAP = MODULE / "rtl/wrapc_pc"
TV_OUT = MODULE / "rtl/tv/rtldatafile"
PACKAGE = ROOT / "build/model-attention-rtl-repair-20261008"
FIXTURE = ROOT / "results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision"
ORIGINAL = ROOT / "results/attention_rtl_repair_20261008/d2_attention_slice/runs/depth_v3/csynth_work/hls/sim/wrapc_pc/cosim.pc.exe"


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--xsim-log", type=Path, required=True)
    parser.add_argument("--guard-result", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    result = json.loads(args.guard_result.read_text())
    log = args.xsim_log.read_text(errors="replace")
    if result["child_exit_code"] != 0 or result["trigger"] is not None:
        raise RuntimeError("XSim did not finish without a guard trigger")
    if "D2_PHASE_PROBE_WINDOW_END" in log:
        raise RuntimeError("diagnostic window ended before original transaction")
    if ("label=kernel_done_edge" not in log or
            "label=tb_done_edge" not in log or
            "label=finish_cnt_change value0=1" not in log):
        raise RuntimeError("kernel done and original transaction completion not observed")
    paths = [TV_OUT / f"rtl.attention_slice.autotvout_{port}.dat"
             for port in ("io", "qkv0", "qkv1", "att_out", "observed")]
    if any(not path.is_file() or path.stat().st_size == 0 for path in paths):
        raise RuntimeError("generated output TV is incomplete")
    if sha(WRAP / "cosim.pc.exe") != sha(ORIGINAL):
        raise RuntimeError("generated C postcheck executable changed")
    command = [str(WRAP / "cosim.pc.exe"), str(PACKAGE), str(FIXTURE)]
    plan = {"argv": command, "cwd": str(WRAP),
            "original_postcheck_sha256": sha(ORIGINAL),
            "copied_postcheck_sha256": sha(WRAP / "cosim.pc.exe"),
            "xsim_log_sha256": sha(args.xsim_log),
            "xsim_guard_sha256": sha(args.guard_result),
            "new_output_tv": {str(path): sha(path) for path in paths}}
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "postcheck_plan.json").write_text(json.dumps(plan, indent=2) + "\n")
    with (args.out / "postcheck.log").open("wb") as stream:
        completed = subprocess.run(command, cwd=WRAP, stdout=stream,
                                   stderr=subprocess.STDOUT, check=False)
    (args.out / "postcheck_result.json").write_text(
        json.dumps({"exit_code": completed.returncode, "plan": plan},
                   indent=2) + "\n")
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main())
