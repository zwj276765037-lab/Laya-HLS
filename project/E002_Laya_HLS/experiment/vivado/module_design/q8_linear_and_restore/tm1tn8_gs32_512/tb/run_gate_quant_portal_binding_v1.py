#!/usr/bin/env python3
"""Freeze and run the bounded real one-row GEGLU portal pilot."""
import argparse,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
M=Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
Q=Path("vivado/module_design/activation_quantizer")
V=Path("vivado/module_design/vector_and_ffn")
R0=Path("vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv")
OLD=ROOT/"results/compute_throughput_optimization_20261010/attempts"
CANONICAL=OLD/"t2_geglu_gate_quant_bridge_rtl_04/canonical_rtl"
QUANT_IP=OLD/"quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog"
FIXTURE=OLD/"t2_geglu_gate_quant_bridge_rtl_04/work/fixture"

def rec(path):
    path=path.resolve()
    return {"path":str(path),"bytes":path.stat().st_size,
            "sha256":hashlib.sha256(path.read_bytes()).hexdigest()}

def main():
    parser=argparse.ArgumentParser();parser.add_argument("--attempt",type=Path,required=True)
    args=parser.parse_args();attempt=args.attempt.resolve();attempt.mkdir(exist_ok=False)
    frozen=attempt/"frozen"
    files=[R0]
    files += [M/"rtl"/(name+".sv") for name in
              "laya_compute_portal_layout_v1 laya_gate_quant_portal_decode_v1 laya_wi_axi_reader_v1 laya_gate_quant_portal_binding_v1".split()]
    files += [Q/"rtl"/(name+".sv") for name in
              "quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2".split()]
    files += [V/"rtl"/(name+".sv") for name in
              "tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter".split()]
    files += [M/"tb/laya_gate_quant_portal_binding_tb_v1.sv",
              M/"tb/run_gate_quant_portal_binding_v1.tcl",
              M/"tb/run_gate_quant_portal_binding_nowave_v1.tcl"]
    records=[]
    for rel in files:
        target=frozen/rel;target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(ROOT/rel,target);records.append({"original":rec(ROOT/rel),"frozen":rec(target)})
    for src in sorted(CANONICAL.glob("*.v")):
        target=frozen/"external/canonical_rtl"/src.name;target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(src,target);records.append({"original":rec(src),"frozen":rec(target)})
    for name in ["laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl",
                 "laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl"]:
        src=QUANT_IP/name;target=frozen/"external/quant_ip"/name;target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(src,target);records.append({"original":rec(src),"frozen":rec(target)})
    fixture_records=[];frozen_fixture=frozen/"fixture";frozen_fixture.mkdir(parents=True)
    for src in sorted(FIXTURE.iterdir()):
        if src.is_file():
            target=frozen_fixture/src.name;shutil.copyfile(src,target)
            fixture_records.append({"original":rec(src),"frozen":rec(target)})
    guard=ROOT/M/"tb/production_guard.py"
    tool=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
    xsim=tool.parent/"xsim"
    scope=("One actual v2 GEGLU portal command drives the physical WI AXI512 reader, canonical "
           "GEGLU and GATE AXI writer for one row; verifies gold payload, independent AW/W/B, "
           "held final B response gating and no QUANT before a Q command. No Q payload, ordinary "
           "QUANT, tensor publication, hub, LOAD, matrix, full request, performance or resource claim")
    manifest={"schema":"laya-gate-quant-portal-binding-pilot-input-v1","scope":scope,
              "files":records,"fixture_files":fixture_records,"runner":rec(Path(__file__)),
              "guard":rec(guard),"tool":rec(tool),"commands":{}}
    receipt={"schema":"laya-gate-quant-portal-binding-pilot-receipt-v1","scope":scope}
    for mode,rss,seconds in [("static",24,1800),("pilot",8,120)]:
        if mode=="static":
            run_cwd=ROOT
            payload=[str(tool),"-mode","batch","-notrace","-log",str(attempt/"static.log"),
                     "-journal",str(attempt/"static.jou"),"-source",
                     str(frozen/M/"tb/run_gate_quant_portal_binding_v1.tcl"),"-tclargs",
                     str(attempt/"work"),str(frozen),mode,str(frozen_fixture)]
        else:
            run_cwd=attempt/"work/vivado/gate_quant_portal_binding.sim/sim_1/behav/xsim"
            payload=[str(xsim),"laya_gate_quant_portal_binding_tb_v1_behav","-key",
                     "Behavioral:sim_1:Functional:laya_gate_quant_portal_binding_tb_v1",
                     "-tclbatch",str(frozen/M/"tb/run_gate_quant_portal_binding_nowave_v1.tcl"),
                     "-log",str(attempt/"pilot_sim.log"),"-testplusarg",
                     "FIXTURE="+str(frozen_fixture)]
        command=[sys.executable,str(guard),"--out",str(attempt/("guard_"+mode)),
                 "--cwd",str(run_cwd),"--rss-gib",str(rss),"--timeout-seconds",str(seconds),
                 "--semantic-stall-seconds","120","--",*payload]
        manifest["commands"][mode]=command
        (attempt/"input_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
        run=subprocess.run(command,cwd=ROOT)
        state=json.loads((attempt/("guard_"+mode)/"guard_result.json").read_text())
        log=attempt/("guard_"+mode)/"driver.log"
        marker=("FULL_CURRENT_GATE_QUANT_PORTAL_BINDING_RUNTIME_STATIC_PASS" if mode=="static"
                else "FULL_CURRENT_GATE_QUANT_PORTAL_BINDING_PILOT_PASS")
        body=log.read_text(errors="replace")
        passed=(run.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and
                marker in body and "Fatal:" not in body and "ERROR:" not in body)
        receipt[mode]={"status":"PASS" if passed else "FAIL","guard":state,
                       "marker":[line for line in body.splitlines() if marker in line],
                       "driver_log":rec(log)}
        receipt["input_manifest"]=rec(attempt/"input_manifest.json")
        receipt["native_ip"]=[rec(path) for path in (attempt/"work").rglob("*.xci")]
        (attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n")
        print("FULL_CURRENT_GATE_QUANT_PORTAL_BINDING_"+mode.upper()+"_"+("PASS" if passed else "FAIL"),flush=True)
        if not passed:return 1
    return 0

if __name__=="__main__":sys.exit(main())
