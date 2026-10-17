#!/usr/bin/env python3
"""Freeze and run the bounded AXI-Lite start-gate simulation."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")

def rec(path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--attempt", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve(); attempt.mkdir(exist_ok=False)
    frozen = attempt / "frozen"
    rels = [MODULE / "rtl/laya_control_start_gate_v1.sv",
            MODULE / "tb/laya_control_start_gate_tb_v1.sv",
            MODULE / "tb/run_control_start_gate.tcl"]
    files=[]
    for rel in rels:
        dst=frozen/rel; dst.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(ROOT/rel,dst); files.append({"original":rec(ROOT/rel),"frozen":rec(dst)})
    vivado=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
    guard=ROOT/MODULE/"tb/production_guard.py"
    command=[sys.executable,str(guard),"--out",str(attempt/"guard"),"--cwd",str(ROOT),
      "--rss-gib","8","--timeout-seconds","120","--semantic-stall-seconds","120","--",
      str(vivado),"-mode","batch","-notrace","-source",str(frozen/MODULE/"tb/run_control_start_gate.tcl"),
      "-tclargs",str(attempt/"sim")]
    manifest={"schema":"laya-control-start-gate-input-v1","files":files,
      "runner":rec(Path(__file__)),"guard":rec(guard),"command":command,
      "scope":"AXI-Lite AW/W separation, ap_start admission, SLVERR rejection, B/R backpressure"}
    (attempt/"input_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
    result=subprocess.run(command,cwd=ROOT)
    state=json.loads((attempt/"guard/guard_result.json").read_text())
    log=(attempt/"guard/driver.log").read_text(errors="replace")
    passed=result.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and \
      "FULL_CURRENT_CONTROL_START_GATE_PASS" in log and "FATAL:" not in log
    receipt={"schema":"laya-control-start-gate-receipt-v1","status":"PASS" if passed else "FAIL",
      "scope":manifest["scope"],"guard_result":state,
      "input_manifest":rec(attempt/"input_manifest.json"),"driver_log":rec(attempt/"guard/driver.log")}
    (attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n")
    print("FULL_CURRENT_CONTROL_START_GATE_RUN status="+receipt["status"])
    return 0 if passed else 1

if __name__=="__main__": sys.exit(main())
