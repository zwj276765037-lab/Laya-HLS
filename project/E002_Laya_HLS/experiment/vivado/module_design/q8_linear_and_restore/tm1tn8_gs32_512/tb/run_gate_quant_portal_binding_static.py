#!/usr/bin/env python3
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
M=Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
Q=Path("vivado/module_design/activation_quantizer");V=Path("vivado/module_design/vector_and_ffn")
R0=Path("vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv")
OLD=ROOT/"results/compute_throughput_optimization_20261010/attempts"
CANONICAL=OLD/"t2_geglu_gate_quant_bridge_rtl_04/canonical_rtl"
QUANT_IP=OLD/"quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog"
def rec(p):
 p=p.resolve();return {"path":str(p),"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
def main():
 p=argparse.ArgumentParser();p.add_argument("--attempt",type=Path,required=True);a=p.parse_args();attempt=a.attempt.resolve();attempt.mkdir(exist_ok=False);frozen=attempt/"frozen"
 files=[R0]
 files += [M/"rtl"/(n+".sv") for n in "laya_compute_portal_layout_v1 laya_gate_quant_portal_decode_v1 laya_wi_axi_reader_v1 laya_gate_quant_portal_binding_v1".split()]
 files += [Q/"rtl"/(n+".sv") for n in "quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2".split()]
 files += [V/"rtl"/(n+".sv") for n in "tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter".split()]
 files += [M/"tb/run_gate_quant_portal_binding_static.tcl"]
 records=[]
 for rel in files:
  dst=frozen/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,dst);records.append({"original":rec(ROOT/rel),"frozen":rec(dst)})
 for src in sorted(CANONICAL.glob("*.v")):
  dst=frozen/"external/canonical_rtl"/src.name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst);records.append({"original":rec(src),"frozen":rec(dst)})
 for name in ["laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl","laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl"]:
  src=QUANT_IP/name;dst=frozen/"external/quant_ip"/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst);records.append({"original":rec(src),"frozen":rec(dst)})
 guard=ROOT/M/"tb/production_guard.py";vivado=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
 cmd=[sys.executable,str(guard),"--out",str(attempt/"guard"),"--cwd",str(ROOT),"--rss-gib","24","--timeout-seconds","1800","--semantic-stall-seconds","120","--",str(vivado),"-mode","batch","-notrace","-log",str(attempt/"vivado.log"),"-journal",str(attempt/"vivado.jou"),"-source",str(frozen/M/"tb/run_gate_quant_portal_binding_static.tcl"),"-tclargs",str(attempt/"work"),str(frozen)]
 manifest={"schema":"laya-gate-quant-portal-binding-static-input-v1","scope":"RTL elaboration of one physical WI reader plus one shared split GEGLU/GATE-QUANT/dual-A instance behind v2 portal admission; no runtime payload, ordinary QUANT, hub, matrix, full request, or resource claim","files":records,"runner":rec(Path(__file__)),"guard":rec(guard),"command":cmd};(attempt/"input_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
 result=subprocess.run(cmd,cwd=ROOT);state=json.loads((attempt/"guard/guard_result.json").read_text());log=(attempt/"guard/driver.log").read_text(errors="replace");passed=result.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and "FULL_CURRENT_GATE_QUANT_PORTAL_BINDING_STATIC_PASS" in log and "ERROR:" not in log
 receipt={"schema":"laya-gate-quant-portal-binding-static-receipt-v1","status":"PASS" if passed else "FAIL","scope":manifest["scope"],"guard_result":state,"input_manifest":rec(attempt/"input_manifest.json"),"driver_log":rec(attempt/"guard/driver.log")};(attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n");print("FULL_CURRENT_GATE_QUANT_PORTAL_BINDING_STATIC_RUN status="+receipt["status"]);return 0 if passed else 1
if __name__=="__main__":sys.exit(main())
