#!/usr/bin/env python3
"""Freeze the exact, uncompiled ACT static RTL source and library closure."""
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
MODULE = ROOT.parent
BASE = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")
VIV = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado")
VERILOG = MODULE / "runs/csynth_local_v1/work/hls/syn/verilog"
REPORT = MODULE / "runs/csynth_local_v1/work/hls/syn/report"
IP = MODULE / "runs/csynth_local_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
ENDPOINT = BASE / "results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv"
FIX = ROOT / "fixtures"
OUT = ROOT / "source_binding_v1/source_packet.json"
G16 = BASE / "results/attention_rtl_repair_20261008/d2_controller_reachable/source/guard_16g.py"
G4 = BASE / "results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/guard_trace_v5/tb/guard_runtime_4g.py"

def record(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda:f.read(1<<20),b""):
            h.update(block)
    return {"path":str(path.resolve()),"bytes":path.stat().st_size,
            "mode":oct(path.stat().st_mode & 0o777),"sha256":h.hexdigest()}

def inventory(paths):
    return [record(p) for p in sorted(paths)]

def main():
    verilog = sorted(VERILOG.glob("*.v"))
    dat = sorted(VERILOG.glob("*.dat"))
    vhdl = sorted(IP.glob("*/sim/*_ip.vhd"))
    assert (len(verilog),len(dat),len(vhdl)) == (230,108,7)
    tb = [HERE/x for x in ("generate_top.py","q8_act_static_top.sv",
          "q8_act_static_control.svh","q8_static_axi_stall.sv",
          "q8_axi_monitor.sv","q8_axi_port.sv","q8_axi_lite_master.sv",
          "prepare_runtime.py","build_static.sh","run_mode.sh",
          "make_source_packet.py","materialize_act_pages.py",
          "verify_binding.py")]
    manifest = json.loads((FIX/"manifest.json").read_text())
    fixtures = [FIX/"manifest.json"] + [FIX/x["relative_path"]
                for x in manifest["generated_files_excluding_manifest"]]
    assert len(fixtures)==235
    for item in manifest["generated_files_excluding_manifest"]:
        p = FIX/item["relative_path"]
        actual = record(p)
        assert (actual["bytes"],actual["sha256"]) == (item["bytes"],item["sha256"]),p
    original = []
    for item in manifest["original_model_files"]:
        p = Path(item["path"])
        actual = record(p)
        assert (actual["bytes"],actual["sha256"]) == (item["bytes"],item["sha256"]),p
        original.append(actual)
    libs = {}
    for name,location in {
        "floating_point_v7_1_21":"ip/floating_point_v7_1_21",
        "unisim":"vhdl/unisim", "unisims_ver":"verilog/unisims_ver",
        "secureip":"verilog/secureip", "xpm":"ip/xpm", "ieee":"vhdl/ieee"
    }.items():
        directory = VIV/"data/xsim"/location
        assert directory.is_dir(),directory
        libs[name] = inventory(p for p in directory.rglob("*") if p.is_file())
    mode_specs = [("legal",0,9),("fault_load",1,3),("identity_reset",2,24)]
    runs=[]
    build=ROOT/"runs/static_build_v1"
    snapshot=build/"xsim.dir"
    packet_path=str(OUT)
    verifier=str(HERE/"verify_binding.py")
    def verify(out,*,with_snapshot=False,baseline_snapshot=False,
               prepared=None,mode=None,baseline_prepared=None,archive=None):
        argv=["python3",verifier,packet_path,str(out)]
        if with_snapshot:
            argv += ["--snapshot",str(snapshot)]
        if baseline_snapshot:
            argv += ["--expected-snapshot-report",str(build/"binding_post.json")]
        if prepared is not None:
            argv += ["--prepared",str(prepared),"--expected-mode",mode]
        if baseline_prepared is not None:
            argv += ["--expected-prepared-report",str(baseline_prepared)]
        if archive is not None:
            argv += ["--archive-runtime-artifacts",str(archive)]
        return argv
    runs.append({"stage":"static","cwd":str(build),"out":str(build/"guard"),
      "argv":["python3",str(G16),"--out",str(build/"guard"),"--cwd",str(build),
              "--rss-gib","16","--timeout-seconds","300","--",
              str(HERE/"build_static.sh"),str(build)],
      "binding_pre_argv":verify(build/"binding_pre.json"),
      "binding_post_argv":verify(build/"binding_post.json",with_snapshot=True)})
    for name,code,count in mode_specs:
        run=ROOT/f"runs/rtl_{name}_v1"
        prepared=run/"prepared"
        runs.append({"stage":f"prepare_{name}","cwd":str(run),
          "out":str(run/"prepare_guard"),
          "argv":["python3",str(G4),"--out",str(run/"prepare_guard"),
                  "--cwd",str(run),"--rss-gib","4","--timeout-seconds","120",
                  "--","python3",str(HERE/"prepare_runtime.py"),name,str(prepared)],
          "binding_pre_argv":verify(run/"prepare_binding_pre.json",
                                     with_snapshot=True,baseline_snapshot=True),
          "binding_post_argv":verify(run/"prepare_binding_post.json",
                                      with_snapshot=True,baseline_snapshot=True,
                                      prepared=prepared,mode=name)})
        runs.append({"stage":f"runtime_{name}","cwd":str(prepared),
          "out":str(run/"runtime_guard"),
          "argv":["python3",str(G16),"--out",str(run/"runtime_guard"),
                  "--cwd",str(prepared),"--rss-gib","8","--timeout-seconds","180",
                  "--",str(HERE/"run_mode.sh"),name,str(build),str(prepared)],
          "xsim_argv":[str(VIV/"bin/xsim"),"q8_act_static",
                         "-testplusarg",f"MODE={code}","-testplusarg",f"CASE_COUNT={count}",
                         "-runall","-onerror","quit","-onfinish","quit","-log","xsim.log"],
          "binding_pre_argv":verify(run/"runtime_binding_pre.json",
                                     with_snapshot=True,baseline_snapshot=True,
                                     prepared=prepared,mode=name,
                                     baseline_prepared=run/"prepare_binding_post.json"),
          "binding_post_argv":verify(run/"runtime_binding_post.json",
                                      with_snapshot=True,baseline_snapshot=True,
                                      prepared=prepared,mode=name,
                                      baseline_prepared=run/"prepare_binding_post.json",
                                      archive=run/"snapshot_runtime_artifacts")})
    release_path=BASE/"results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_dual_lite_design_preparation_release.json"
    release=json.loads(release_path.read_text())
    bound=[]
    for item in release["bound_baselines"]:
        actual=record(Path(item["path"]))
        assert (actual["bytes"],actual["sha256"]) == (item["bytes"],item["sha256"]),item["path"]
        bound.append(actual)
    assert len(bound)==manifest["frozen_baselines_rehashed"]==32
    packet={"schema":"q8_metadata_reset_v3_act_static_actual_source_packet_v1",
      "created_utc":datetime.now(timezone.utc).isoformat(),
      "state":"PREPARATION_ONLY_NO_Q8_XVLOG_XVHDL_XELAB_XSIM_EXECUTED",
      "source_gate":record(release_path),"frozen_bound_baselines":bound,
      "fixture_byte_review":record(BASE/"results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_materialized_bytes_review.json"),
      "materialization_evidence":record(ROOT/"runs/materialize_v1/materialization_evidence.json"),
      "verilog_modules":inventory(verilog),"dat_files":inventory(dat),
      "fp_sim_vhdl_wrappers":inventory(vhdl),
      "testbench_and_runner":inventory(tb),"accepted_endpoint":record(ENDPOINT),
      "fixtures":inventory(fixtures),"original_model_files":original,
      "guard_scripts":inventory([G16,G4]),
      "schedule_reports":inventory([REPORT/name for name in (
          "q8_joint_tm4tn8_csynth.rpt",
          "q8_joint_tm4tn8_Pipeline_VITIS_LOOP_583_21_VITIS_LOOP_584_22_VITIS_LOOP_587_23_csynth.rpt",
          "q8_joint_tm4tn8_Pipeline_VITIS_LOOP_602_27_csynth.rpt",
          "q8_joint_tm4tn8_Pipeline_VITIS_LOOP_634_29_csynth.rpt")]),
      "xsim_ini":record(VIV/"data/xsim/xsim.ini"),
      "xsim_lookup_manual":record(VIV/"doc/eng/man/xsim"),
      "installed_library_files":libs,
      "build_command":[str(HERE/"build_static.sh"),str(build)],
      "compile_commands":{
        "xvhdl":[str(VIV/"bin/xvhdl"),"-work","xil_defaultlib",*[str(p) for p in vhdl],"-log","xvhdl.log"],
        "xvlog_dut":[str(VIV/"bin/xvlog"),"-work","xil_defaultlib",*[str(p) for p in verilog],"-log","xvlog_dut.log"],
        "xvlog_tb":[str(VIV/"bin/xvlog"),"--sv","-work","xil_defaultlib","-i",str(HERE),
                     str(ENDPOINT),*[str(HERE/p) for p in ("q8_static_axi_stall.sv",
                       "q8_axi_monitor.sv","q8_axi_port.sv","q8_axi_lite_master.sv",
                       "q8_act_static_top.sv")],"-log","xvlog_tb.log"],
        "xelab":[str(VIV/"bin/xelab"),"xil_defaultlib.q8_act_static_top",
                 "-L","floating_point_v7_1_21","-L","unisims_ver","-L","xpm",
                 "-L","secureip","--relax","-mt","off","-s","q8_act_static",
                 "-log","xelab.log"]},
      "planned_runs_in_dependency_order":runs,
      "snapshot_lookup":"Each fresh prepared mode directory contains an absolute xsim.dir symlink to the compiled build/xsim.dir; xsim uses its documented default lookup from prepared cwd. No --xsimdir interpretation is assumed.",
      "snapshot_runtime_artifacts":"Only q8_act_static/xsim_script.tcl, xsimSettings.ini, xsimkernel.log, and xsimcrash.log may change between compiled snapshot checks. Their hashes remain in each binding report and each runtime post-check archives the four exact files before source/snapshot comparison. Every other new, missing, or changed snapshot file fails.",
      "stage_execution_contract":"Execute each stage's binding_pre_argv, then its guarded argv, then binding_post_argv even if the guarded process fails. Stop before any next stage on a guard, binding, compile, or simulation failure; preserve first-failure logs and runtime artifact archive.",
      "preflight":"One Laya heavy tool, four CPUs, nice 19, idle I/O, MemAvailable strictly >192GiB, 0.2s owned RSS samples; guard wrappers enforce policy.",
      "clock_bounds":{"per_command_watchdog":20000,"per_mode_watchdog":250000,
        "nominal_simulation_period_ns":6.666,
        "basis":"ACT fixed fixture K=256,N=2,rows=1,G=8,T=1: rejected command reads 128 descriptor beats and writes 256 observed words; LOAD also reads AUX 34, Q0 32, scale 2; largest RUN also reads activation 16 and writes 388 observed plus 2 out0 words. With one request/response per beat as a deliberately pessimistic no-redundant-transaction count, LOAD has at most 1160 adapter channel transfers, RUN 1458, rejection 1024, and the 24-command identity mode totals 25716. A one-entry adapter at its programmed 0..3 exposure delay needs at most five sampled edges from acceptance through delivery when its sink is immediately ready, giving 5800/7290/5120 and 128580 identity edge occupancies if channels were serialized. The chosen final R/B add 16 each in legal RUN. HLS ACT quantization has 8 groups with two four-block passes per group; scan and pack submodules report maxima 18 and 29 cycles per invocation, and the report submodule has 1134-cycle latency. Linear has 8 group/tile issue slots; HLS top and linear latency remain unknown, and endpoint/HLS backpressure can exceed the immediate-ready adapter calculation. Thus 20000/250000 are prior watchdogs to make failure finite, not proven latency or physical timing bounds; any timeout is a failure to investigate.",
        "hls_report":str(MODULE/"runs/csynth_local_v1/work/hls/syn/report/q8_joint_tm4tn8_csynth.rpt")},
      "immutability":"Source and prepared input hashes must match this packet before launch and after exit; compiled snapshot is exact except four named XSim runtime artifacts, which are hashed and archived per run. Each stage has a new output directory. No production/model/HLS/IP changes, no replay of successful HLS/fixture materializer."}
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(packet,sort_keys=True,indent=2)+"\n")
    print(f"Q8_SOURCE_PACKET files={sum(len(v) for v in (packet['verilog_modules'],packet['dat_files'],packet['fp_sim_vhdl_wrappers'],packet['fixtures']))} path={OUT}")

if __name__=="__main__": main()
