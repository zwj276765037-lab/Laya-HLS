#!/usr/bin/env python3
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];MODULE=Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
def rec(p):
 p=p.resolve();return {"path":str(p),"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
def main():
 p=argparse.ArgumentParser();p.add_argument("--attempt",type=Path,required=True);a=p.parse_args();attempt=a.attempt.resolve();attempt.mkdir(exist_ok=False);frozen=attempt/"frozen"
 rels=[MODULE/"rtl/laya_wi_axi_reader_v1.sv",MODULE/"tb/laya_wi_axi_reader_tb_v1.sv",MODULE/"tb/run_wi_axi_reader.tcl"];files=[]
 for rel in rels:
  dst=frozen/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,dst);files.append({"original":rec(ROOT/rel),"frozen":rec(dst)})
 guard=ROOT/MODULE/"tb/production_guard.py";vivado=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
 cmd=[sys.executable,str(guard),"--out",str(attempt/"guard"),"--cwd",str(ROOT),"--rss-gib","8","--timeout-seconds","120","--semantic-stall-seconds","120","--",str(vivado),"-mode","batch","-notrace","-source",str(frozen/MODULE/"tb/run_wi_axi_reader.tcl"),"-tclargs",str(attempt/"sim"),str(frozen)]
 manifest={"schema":"laya-wi-axi-reader-input-v1","scope":"physical AXI512 WI rows, 4KiB/256-beat burst splitting, scalar binding, response error and late-RLAST drain, latched ADDR/DATA cancellation, and no-new-AR stop","files":files,"runner":rec(Path(__file__)),"guard":rec(guard),"command":cmd};(attempt/"input_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
 result=subprocess.run(cmd,cwd=ROOT);state=json.loads((attempt/"guard/guard_result.json").read_text());log=(attempt/"guard/driver.log").read_text(errors="replace");passed=result.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and "FULL_CURRENT_WI_AXI_READER_PASS" in log and "Fatal:" not in log
 receipt={"schema":"laya-wi-axi-reader-receipt-v1","status":"PASS" if passed else "FAIL","scope":manifest["scope"],"guard_result":state,"input_manifest":rec(attempt/"input_manifest.json"),"driver_log":rec(attempt/"guard/driver.log")};(attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n");print("FULL_CURRENT_WI_AXI_READER_RUN status="+receipt["status"]);return 0 if passed else 1
if __name__=="__main__":sys.exit(main())
