#!/usr/bin/env python3
"""Freeze and run ordinary-QUANT through the shared portal quant/full-A RTL."""
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
M=Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
Q=Path("vivado/module_design/activation_quantizer")
V=Path("vivado/module_design/vector_and_ffn")
R0=Path("vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv")
OLD=ROOT/"results/compute_throughput_optimization_20261010/attempts"
CANONICAL=OLD/"t2_geglu_gate_quant_bridge_rtl_04/canonical_rtl"
QUANT_IP=OLD/"quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog"
CASE_ROOT=OLD/"quant16_stream_adapter_01/fixture"

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
    files += [M/"tb/laya_gate_quant_ordinary_portal_tb_v1.sv",
              M/"tb/run_gate_quant_ordinary_portal_v1.tcl",
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
    fixture=frozen/"fixture";fixture.mkdir(parents=True)
    fixture_sources=[CASE_ROOT/"manifest.json"]
    groups=[f"case_{index:02d}" for index in range(11,19)]
    payload={name:[] for name in ("source.mem","q.mem","scale.mem")}
    for group in groups:
        for name in payload:
            src=CASE_ROOT/group/name;fixture_sources.append(src)
            payload[name].append(src.read_text())
    for name,parts in payload.items():(fixture/name).write_text("".join(parts))
    fixture_records=[rec(path) for path in fixture_sources]
    fixture_outputs=[rec(path) for path in sorted(fixture.iterdir())]
    guard=ROOT/M/"tb/production_guard.py"
    tool=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
    xsim=tool.parent/"xsim"
    scope=("One stage6 K256 ordinary F32 QUANT command, after an unpublished-source rejection, "
           "uses the same quant_task_to_dual_a_v1 instance as GATE QUANT; checks physical AXI "
           "source, portal response, full-A publication and eight independently frozen groups. "
           "No GEGLU payload, hub, generated provenance channel, LOAD, matrix or full request claim")
    manifest={"schema":"laya-gate-quant-ordinary-portal-input-v1","scope":scope,
              "files":records,"fixture_source_groups":groups,
              "fixture_sources":fixture_records,"fixture_outputs":fixture_outputs,
              "runner":rec(Path(__file__)),"guard":rec(guard),"tool":rec(tool),"commands":{}}
    receipt={"schema":"laya-gate-quant-ordinary-portal-receipt-v1","scope":scope}
    for mode,rss,seconds in [("static",24,1800),("pilot",8,120)]:
        if mode=="static":
            run_cwd=ROOT
            payload_cmd=[str(tool),"-mode","batch","-notrace","-log",str(attempt/"static.log"),
                         "-journal",str(attempt/"static.jou"),"-source",
                         str(frozen/M/"tb/run_gate_quant_ordinary_portal_v1.tcl"),"-tclargs",
                         str(attempt/"work"),str(frozen)]
        else:
            run_cwd=attempt/"work/vivado/gate_quant_ordinary_portal.sim/sim_1/behav/xsim"
            payload_cmd=[str(xsim),"laya_gate_quant_ordinary_portal_tb_v1_behav","-key",
                         "Behavioral:sim_1:Functional:laya_gate_quant_ordinary_portal_tb_v1",
                         "-tclbatch",str(frozen/M/"tb/run_gate_quant_portal_binding_nowave_v1.tcl"),
                         "-log",str(attempt/"pilot_sim.log"),"-testplusarg","FIXTURE="+str(fixture)]
        command=[sys.executable,str(guard),"--out",str(attempt/("guard_"+mode)),
                 "--cwd",str(run_cwd),"--rss-gib",str(rss),"--timeout-seconds",str(seconds),
                 "--semantic-stall-seconds","120","--",*payload_cmd]
        manifest["commands"][mode]=command
        (attempt/"input_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
        run=subprocess.run(command,cwd=ROOT)
        state=json.loads((attempt/("guard_"+mode)/"guard_result.json").read_text())
        log=attempt/("guard_"+mode)/"driver.log";body=log.read_text(errors="replace")
        marker=("FULL_CURRENT_GATE_QUANT_ORDINARY_PORTAL_STATIC_PASS" if mode=="static"
                else "FULL_CURRENT_GATE_QUANT_ORDINARY_PORTAL_PASS")
        passed=(run.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and
                marker in body and "Fatal:" not in body and "ERROR:" not in body)
        receipt[mode]={"status":"PASS" if passed else "FAIL","guard":state,
                       "marker":[line for line in body.splitlines() if marker in line],
                       "driver_log":rec(log)}
        receipt["input_manifest"]=rec(attempt/"input_manifest.json")
        receipt["native_ip"]=[rec(path) for path in (attempt/"work").rglob("*.xci")]
        (attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n")
        print("FULL_CURRENT_GATE_QUANT_ORDINARY_PORTAL_"+mode.upper()+"_"+("PASS" if passed else "FAIL"),flush=True)
        if not passed:return 1
    return 0

if __name__=="__main__":sys.exit(main())
