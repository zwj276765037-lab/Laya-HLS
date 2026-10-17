#!/usr/bin/env python3
"""Freeze and run the bounded original-control-plane integration test."""
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
MODULE=Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
ORIGINAL=ROOT/"results/encoder_decision_validation_20261009/attempts/full_hls_01/work/hls/syn/verilog"
def rec(path):
  path=path.resolve();return {"path":str(path),"bytes":path.stat().st_size,"sha256":hashlib.sha256(path.read_bytes()).hexdigest()}
def main():
  p=argparse.ArgumentParser();p.add_argument("--attempt",type=Path,required=True);a=p.parse_args()
  attempt=a.attempt.resolve();attempt.mkdir(exist_ok=False);frozen=attempt/"frozen"
  rels=[MODULE/"rtl"/name for name in ["laya_13bo_abi_v1.sv","laya_model_identity_13bo_generated_v1.sv",
    "laya_13bo_base_mirror_v1.sv","laya_13bo_model_binding_v1.sv","laya_13bo_request_gate_v1.sv",
    "laya_control_start_gate_v1.sv","laya_13bo_control_plane_v1.sv"]]+[
    MODULE/"tb/laya_13bo_control_plane_tb_v1.sv",MODULE/"tb/run_13bo_control_plane.tcl"]
  files=[]
  for rel in rels:
    dst=frozen/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,dst);files.append({"original":rec(ROOT/rel),"frozen":rec(dst)})
  originals=[ORIGINAL/"laya_typed_q8_forward_control_s_axi.v",ORIGINAL/"laya_typed_q8_forward_control_r_s_axi.v"]
  guard=ROOT/MODULE/"tb/production_guard.py";vivado=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
  command=[sys.executable,str(guard),"--out",str(attempt/"guard"),"--cwd",str(ROOT),"--rss-gib","8",
    "--timeout-seconds","120","--semantic-stall-seconds","120","--",str(vivado),"-mode","batch","-notrace",
    "-source",str(frozen/MODULE/"tb/run_13bo_control_plane.tcl"),"-tclargs",str(attempt/"sim"),str(frozen),*map(str,originals)]
  manifest={"schema":"laya-13bo-control-plane-input-v1","scope":"actual original two AXI-Lite banks, pointer mirror, persistent L13M model-base binding, admitted/rejected start and drained cold rebind","files":files,"original_generated_controls":[rec(x) for x in originals],"runner":rec(Path(__file__)),"guard":rec(guard),"command":command}
  (attempt/"input_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
  result=subprocess.run(command,cwd=ROOT);state=json.loads((attempt/"guard/guard_result.json").read_text());log=(attempt/"guard/driver.log").read_text(errors="replace")
  passed=result.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and "FULL_CURRENT_13BO_CONTROL_PLANE_PASS" in log and "Fatal:" not in log
  receipt={"schema":"laya-13bo-control-plane-receipt-v1","status":"PASS" if passed else "FAIL","scope":manifest["scope"],"guard_result":state,"input_manifest":rec(attempt/"input_manifest.json"),"driver_log":rec(attempt/"guard/driver.log")}
  (attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n");print("FULL_CURRENT_13BO_CONTROL_PLANE_RUN status="+receipt["status"]);return 0 if passed else 1
if __name__=="__main__":sys.exit(main())
