#!/usr/bin/env python3
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];MODULE=Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
def rec(p):
 p=p.resolve();return {"path":str(p),"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
def main():
 p=argparse.ArgumentParser();p.add_argument("--attempt",type=Path,required=True);a=p.parse_args();attempt=a.attempt.resolve();attempt.mkdir(exist_ok=False);frozen=attempt/"frozen"
 rels=[MODULE/"rtl/laya_compute_portal_layout_v1.sv",MODULE/"rtl/laya_gate_quant_portal_decode_v1.sv",MODULE/"tb/laya_gate_quant_portal_decode_tb_v1.sv",MODULE/"tb/run_gate_quant_portal_decode.tcl"];files=[]
 for rel in rels:
  dst=frozen/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,dst);files.append({"original":rec(ROOT/rel),"frozen":rec(dst)})
 guard=ROOT/MODULE/"tb/production_guard.py";vivado=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
 cmd=[sys.executable,str(guard),"--out",str(attempt/"guard"),"--cwd",str(ROOT),"--rss-gib","8","--timeout-seconds","120","--semantic-stall-seconds","120","--",str(vivado),"-mode","batch","-notrace","-source",str(frozen/MODULE/"tb/run_gate_quant_portal_decode.tcl"),"-tclargs",str(attempt/"sim"),str(frozen)]
 manifest={"schema":"laya-gate-quant-portal-decode-input-v1","scope":"side-effect-free v2 GEGLU/QUANT identity, relative BO range, fixed-stride and GATE-path decoding before physical service admission","files":files,"runner":rec(Path(__file__)),"guard":rec(guard),"command":cmd};(attempt/"input_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
 result=subprocess.run(cmd,cwd=ROOT);state=json.loads((attempt/"guard/guard_result.json").read_text());log=(attempt/"guard/driver.log").read_text(errors="replace");passed=result.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and "FULL_CURRENT_GATE_QUANT_PORTAL_DECODE_PASS" in log and "Fatal:" not in log
 receipt={"schema":"laya-gate-quant-portal-decode-receipt-v1","status":"PASS" if passed else "FAIL","scope":manifest["scope"],"guard_result":state,"input_manifest":rec(attempt/"input_manifest.json"),"driver_log":rec(attempt/"guard/driver.log")};(attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n");print("FULL_CURRENT_GATE_QUANT_PORTAL_DECODE_RUN status="+receipt["status"]);return 0 if passed else 1
if __name__=="__main__":sys.exit(main())
