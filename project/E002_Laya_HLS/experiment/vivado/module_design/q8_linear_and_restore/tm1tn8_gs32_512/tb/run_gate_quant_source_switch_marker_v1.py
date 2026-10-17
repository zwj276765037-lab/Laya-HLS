#!/usr/bin/env python3
"""Run no-reset GATE-to-stage5 MARKER QUANT with a real B2 checkpoint."""
import argparse,hashlib,json,shutil,struct,subprocess,sys
from pathlib import Path

import numpy as np

ROOT=Path(__file__).resolve().parents[5]
M=Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
Q=Path("vivado/module_design/activation_quantizer")
V=Path("vivado/module_design/vector_and_ffn")
R0=Path("vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv")
OLD=ROOT/"results/compute_throughput_optimization_20261010/attempts"
CANONICAL=OLD/"t2_geglu_gate_quant_bridge_rtl_04/canonical_rtl"
QUANT_IP=OLD/"quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog"
FIXTURE=OLD/"t2_geglu_gate_quant_bridge_rtl_04/work/fixture"
ACTUAL=ROOT/"results/engineering_p2/full_cpu_final_20261007/dut/dut/B2_S128/marker_norm.f32.bin"
ORACLE=ROOT/"results/engineering_p2/full_cpu_final_20261007/oracle/B2_S128/marker_norm.f32.bin"
NREF=ROOT/"tests/numeric_reference.py"
EXPECTED_MARKER_SHA="969cf212034ccf7a5d6bb785e59ccbfce84cbd2fa9233591f506176076f7c10a"
sys.path.insert(0,str(ROOT/"tests"))
import numeric_reference

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
    files += [M/"tb/laya_gate_quant_source_switch_marker_tb_v1.sv",
              M/"tb/run_gate_quant_source_switch_marker_v1.tcl",
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
    marker_input=frozen/"external/marker_input";marker_input.mkdir(parents=True)
    for src,name in ((ACTUAL,"actual.bin"),(ORACLE,"oracle.bin"),(NREF,"numeric_reference.py")):
        target=marker_input/name;shutil.copyfile(src,target)
        records.append({"original":rec(src),"frozen":rec(target)})
    actual=(marker_input/"actual.bin").read_bytes()
    oracle=(marker_input/"oracle.bin").read_bytes()
    if (actual!=oracle or len(actual)!=2*16*1024*4 or
        hashlib.sha256(actual).hexdigest()!=EXPECTED_MARKER_SHA):
        raise RuntimeError("B2 marker_norm DUT/oracle identity or shape mismatch")
    fixture_records=[];frozen_fixture=frozen/"fixture";frozen_fixture.mkdir(parents=True)
    derived_names={"source.mem","q.mem","scale.mem"}
    for src in sorted(FIXTURE.iterdir()):
        if src.is_file() and src.name not in derived_names:
            target=frozen_fixture/src.name;shutil.copyfile(src,target)
            fixture_records.append({"original":rec(src),"frozen":rec(target)})
    # Select all 16 real MARKER rows from batch 1.  The independent oracle
    # checkpoint is bit-identical to the production DUT checkpoint; q/scale
    # are recomputed here with the independent P1 numeric reference.
    raw=actual[16*1024*4:]
    rows=np.frombuffer(raw,dtype="<f4").reshape(16,1024)
    encoded,_=numeric_reference.quantize(rows)
    q=b"".join(encoded[g*34+2:g*34+34] for g in range(16*32))
    scale=b"".join(encoded[g*34:g*34+2] for g in range(16*32))
    (frozen_fixture/"source.mem").write_text("".join(
        f"{v:08x}\n" for (v,) in struct.iter_unpack("<I",raw)))
    (frozen_fixture/"q.mem").write_text("".join(f"{v:02x}\n" for v in q))
    (frozen_fixture/"scale.mem").write_text("".join(
        f"{v:04x}\n" for (v,) in struct.iter_unpack("<H",scale)))
    marker_manifest={
        "schema":"laya-gate-quant-source-switch-marker-fixture-v1",
        "shape":{"B":2,"S":128,"batch":1,"rows":16,"K":1024},
        "actual":rec(marker_input/"actual.bin"),
        "oracle":rec(marker_input/"oracle.bin"),
        "numeric_reference":rec(marker_input/"numeric_reference.py"),
        "actual_oracle_bitwise_equal":True,
        "source_sha256":hashlib.sha256(raw).hexdigest(),
        "q_sha256":hashlib.sha256(q).hexdigest(),
        "scale_sha256":hashlib.sha256(scale).hexdigest(),
    }
    (frozen_fixture/"ordinary_marker_manifest.json").write_text(
        json.dumps(marker_manifest,indent=2)+"\n")
    fixture_outputs=[rec(path) for path in sorted(frozen_fixture.iterdir())]
    guard=ROOT/M/"tb/production_guard.py"
    tool=Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
    xsim=tool.parent/"xsim"
    scope=("One actual v2 GEGLU/GATE row followed without reset by one stage5 physical-role7 "
           "HEAD_WORK/ref10 region0 K1024 rows16 ordinary QUANT for the real B2/S128 batch1 "
           "MARKER checkpoint on the shared quant/full-A instance while the partial GATE owner "
           "remains resident; verifies state1-region addressing, physical WI/GATE, held responses, "
           "source lease, bit-identical DUT/oracle source, independent Q8 gold and all 128 full-A "
           "row-block/group views. No complete GATE tensor, GATE Q, persistent hub publication, "
           "LOAD, matrix, full request, performance or resource claim")
    manifest={"schema":"laya-gate-quant-source-switch-marker-input-v1","scope":scope,
              "files":records,"fixture_files":fixture_records,
              "fixture_outputs":fixture_outputs,
              "ordinary_fixture":"real B2/S128 marker_norm batch1","runner":rec(Path(__file__)),
              "guard":rec(guard),"tool":rec(tool),"commands":{}}
    receipt={"schema":"laya-gate-quant-source-switch-marker-receipt-v1","scope":scope}
    for mode,rss,seconds in [("static",24,1800),("pilot",8,120)]:
        if mode=="static":
            run_cwd=ROOT
            payload=[str(tool),"-mode","batch","-notrace","-log",str(attempt/"static.log"),
                     "-journal",str(attempt/"static.jou"),"-source",
                     str(frozen/M/"tb/run_gate_quant_source_switch_marker_v1.tcl"),"-tclargs",
                     str(attempt/"work"),str(frozen),mode,str(frozen_fixture)]
        else:
            run_cwd=attempt/"work/vivado/gate_quant_source_switch_marker.sim/sim_1/behav/xsim"
            payload=[str(xsim),"laya_gate_quant_source_switch_marker_tb_v1_behav","-key",
                     "Behavioral:sim_1:Functional:laya_gate_quant_source_switch_marker_tb_v1",
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
        marker=("FULL_CURRENT_GATE_QUANT_SOURCE_SWITCH_MARKER_RUNTIME_STATIC_PASS" if mode=="static"
                else "FULL_CURRENT_GATE_QUANT_SOURCE_SWITCH_MARKER_PASS")
        body=log.read_text(errors="replace")
        passed=(run.returncode==0 and state["child_exit_code"]==0 and state["trigger"] is None and
                marker in body and "Fatal:" not in body and "ERROR:" not in body)
        receipt[mode]={"status":"PASS" if passed else "FAIL","guard":state,
                       "marker":[line for line in body.splitlines() if marker in line],
                       "driver_log":rec(log)}
        receipt["input_manifest"]=rec(attempt/"input_manifest.json")
        receipt["native_ip"]=[rec(path) for path in (attempt/"work").rglob("*.xci")]
        (attempt/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n")
        print("FULL_CURRENT_GATE_QUANT_SOURCE_SWITCH_MARKER_"+mode.upper()+"_"+("PASS" if passed else "FAIL"),flush=True)
        if not passed:return 1
    return 0

if __name__=="__main__":sys.exit(main())
