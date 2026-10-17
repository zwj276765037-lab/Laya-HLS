#!/usr/bin/env python3
"""Bind exact uncompiled Attention V5 static source, pages and library closure."""
from __future__ import annotations
from datetime import datetime,timezone
import hashlib,json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent
V5=ROOT.parent
V1=V5/'rtl_static_cold_v1'
BASE=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado')
VERILOG=V5/'runs/local_csynth_v1/work/hls/syn/verilog'
REPORT=V5/'runs/local_csynth_v1/work/hls/syn/report'
IP=V5/'runs/local_csynth_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip'
GATE=BASE/'results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_write_transaction_diagnostic_source_preparation_release.json'
V1_GATE=BASE/'results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_source_preparation_release.json'
ENDPOINT=BASE/'results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv'
G16=BASE/'results/attention_rtl_repair_20261008/d2_controller_reachable/source/guard_16g.py'
G4=BASE/'results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/guard_trace_v5/tb/guard_runtime_4g.py'
PREP=V1/'runs/materialize_base_h0_r0_v2/prepared'
OUT=ROOT/'source/source_packet.json'

def sha(path:Path)->str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1<<20),b''): h.update(block)
    return h.hexdigest()

def record(path:Path)->dict:
    assert path.is_file(),path
    return {'path':str(path.resolve()),'bytes':path.stat().st_size,
            'mode':oct(path.stat().st_mode & 0o777),'sha256':sha(path)}

def inventory(paths): return [record(p) for p in sorted(paths)]
def relative_record(path): return {'relative_path':path.name,'bytes':path.stat().st_size,'sha256':sha(path)}

def main():
    assert sha(GATE)=='0dba513c05be99806e238350ab56d6781497ff2a1dbe551e1abcd21757841906'
    assert sha(ENDPOINT)=='b33c29a0ce934f19f61b1313ca82f24ef3df60bede1b949610054f4caa7b909d'
    verilog=sorted(VERILOG.glob('*.v')); data=sorted(VERILOG.glob('*.dat'))
    wrappers=sorted(IP.glob('*/sim/*_ip.vhd'))
    assert (len(verilog),len(data),len(wrappers))==(216,35,6)
    sources=sorted(p for p in HERE.iterdir() if p.is_file() and p.suffix in ('.py','.sh','.sv','.svh','.c','.so'))
    sources += [ROOT/'source/design.md',ROOT/'source/results.md',
                ROOT/'source/v1_to_v2_source.diff',ROOT/'rtl/README.md']
    source_fixture=BASE/'results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision'
    package=BASE/'build/model-attention-rtl-repair-20261008'
    frozen=[V1_GATE,V1/'source/source_packet.json',
        V1/'runs/rtl_base_h0_r0_v1/failure_evidence_manifest.json',
        V5/'config.cfg',V5/'source/attention_preloaded_slice.cpp',
        V5/'source/attention_preloaded_abi.h',
        V5/'runs/local_csynth_v1/synthesis_evidence.json',
        V5/'runs/source_config_binding_v1/source_config_binding_packet.json',
        source_fixture/'request.bin',source_fixture/'qkv_final.f32.bin',
        package/'aux.bin',package/'manifest.json']
    frozen += sorted((V5/'tb/fixture_preloaded').glob('*'))
    frozen += sorted((V1/'runs/materialize_base_h0_r0_v1/guard').glob('*'))
    frozen += sorted((V1/'runs/materialize_base_h0_r0_v2/guard').glob('*'))
    mat=json.loads((PREP/'materialization.json').read_text())
    assert mat['status']=='HOST_SOURCE_AND_FULL_IMAGE_CHECK_ONLY_NO_EDA'
    assert len(mat['generated'])==10 and sum(p['count'] for p in mat['mapped_pages'])==267
    pages=[]
    for name,expected in sorted(mat['generated'].items()):
        path=PREP/name; actual=relative_record(path)
        assert actual['bytes']==expected['memh_bytes'] and actual['sha256']==expected['memh_sha256']
        pages.append(actual)
    libs={}
    for name,relative in {
        'floating_point_v7_1_21':'ip/floating_point_v7_1_21',
        'unisim':'vhdl/unisim','unisims_ver':'verilog/unisims_ver',
        'secureip':'verilog/secureip','xpm':'ip/xpm','ieee':'vhdl/ieee'
    }.items():
        directory=VIV/'data/xsim'/relative
        assert directory.is_dir(),directory
        libs[name]=inventory(p for p in directory.rglob('*') if p.is_file())
    reports=[REPORT/n for n in ('attention_preloaded_slice_csynth.rpt',
        'p_anonymous_namespace_read_qkv_csynth.rpt',
        'p_anonymous_namespace_read_qkv_f32_csynth.rpt',
        'qk_row_csynth.rpt','softmax_row_csynth.rpt','av_row_csynth.rpt')]
    build=ROOT/'runs/static_build_v1'
    runtime=ROOT/'runs/rtl_base_h0_r0_v1'
    packet_path=str(OUT); verify=str(HERE/'verify_binding.py')
    compile_commands={
        'xvhdl':[str(VIV/'bin/xvhdl'),'-work','xil_defaultlib',*[str(p) for p in wrappers],'-log','xvhdl.log'],
        'xvlog_dut':[str(VIV/'bin/xvlog'),'-work','xil_defaultlib',*[str(p) for p in verilog],'-log','xvlog_dut.log'],
        'xvlog_tb':[str(VIV/'bin/xvlog'),'--sv','-work','xil_defaultlib','-i',str(HERE),
            str(ENDPOINT),*[str(HERE/name) for name in ('att_static_axi_stall.sv',
                'att_axi_monitor.sv','att_axi_port.sv','att_axi_lite_master.sv','att_cold_top.sv')],
            '-log','xvlog_tb.log'],
        'xelab':[str(VIV/'bin/xelab'),'xil_defaultlib.att_cold_top',
            '-L','floating_point_v7_1_21','-L','unisims_ver','-L','xpm','-L','secureip',
            '--sv_lib','phase_rss','--sv_root',str(HERE),
            '--relax','-mt','off','-s','att_cold_static','-log','xelab.log']}
    def bind(out,prepared=True,snapshot=False,baseline=None,prebaseline=None,runtime_dir=False,archive=None):
        argv=['python3',verify,packet_path,str(out)]
        if prepared: argv+=['--prepared',str(PREP)]
        if snapshot: argv+=['--snapshot',str(build/'xsim.dir')]
        if baseline: argv+=['--expected-snapshot-report',str(baseline)]
        if prebaseline: argv+=['--expected-prepared-report',str(prebaseline)]
        if runtime_dir: argv+=['--runtime',str(runtime)]
        if archive: argv+=['--archive-runtime-artifacts',str(archive)]
        return argv
    build_post=build/'binding_post.json'
    runtime_pre=runtime/'binding_pre.json'
    planned=[
       {'stage':'static_compiler_NOT_RELEASED','cwd':str(build),
        'guard_argv':['python3',str(G16),'--out',str(build/'guard'),'--cwd',str(build),
            '--rss-gib','16','--timeout-seconds','300','--',str(HERE/'build_static.sh'),str(build)],
        'binding_pre_argv':bind(build/'binding_pre.json'),
        'binding_post_argv':bind(build_post,snapshot=True)},
       {'stage':'base_h0_r0_runtime_NOT_RELEASED','cwd':str(runtime),
        'guard_argv':['python3',str(G16),'--out',str(runtime/'guard'),'--cwd',str(runtime),
            '--rss-gib','8','--timeout-seconds','3600','--',str(HERE/'run_mode.sh'),
            str(runtime),str(build),str(PREP)],
        'xsim_argv':[str(VIV/'bin/xsim'),'att_cold_static','-runall',
            '-onerror','quit','-onfinish','quit','-log','xsim.log'],
        'binding_pre_argv':bind(runtime_pre,snapshot=True,baseline=build_post,
                                prebaseline=build_post),
        'binding_post_argv':bind(runtime/'binding_post.json',snapshot=True,
            baseline=build_post,prebaseline=runtime_pre,runtime_dir=True,
            archive=runtime/'snapshot_runtime_artifacts')}
    ]
    packet={
      'schema':'attention_v5_cold_static_source_packet_v2',
      'created_utc':datetime.now(timezone.utc).isoformat(),
      'state':'SOURCE_PREPARED_ONLY_NO_ATTENTION_XVHDL_XVLOG_XELAB_XSIM_EXECUTED',
      'source_gate':record(GATE),'accepted_endpoint':record(ENDPOINT),
      'verilog_modules':inventory(verilog),'dat_files':inventory(data),
      'fp_sim_vhdl_wrappers':inventory(wrappers),
      'testbench_and_runner':inventory(sources),'frozen_inputs':inventory(frozen),
      'guard_scripts':inventory([G16,G4]),'schedule_reports':inventory(reports),
      'materialization_record':relative_record(PREP/'materialization.json'),
      'independent_page_serialization_check':record(V1/'runs/materialize_base_h0_r0_v2/independent_page_check.json'),
      'independent_prepared_bytes_review':record(BASE/'results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v1_prepared_bytes_review.json'),
      'prepared_pages':pages,'installed_library_files':libs,
      'xsim_ini':record(VIV/'data/xsim/xsim.ini'),
      'xsim_lookup_manual':record(VIV/'doc/eng/man/xsim'),
      'compile_commands':compile_commands,
      'materializer_guard_actual':record(V1/'runs/materialize_base_h0_r0_v2/guard/guard_result.json'),
      'materializer_first_failure_actual':record(V1/'runs/materialize_base_h0_r0_v1/guard/driver.log'),
      'materializer_v1_source_limit':'The original v1 materializer script was not frozen before its failed run; no post-run script copy is claimed to be that preimage.',
      'planned_runs_in_dependency_order':planned,
      'snapshot_lookup':'A fresh runtime directory links xsim.dir absolutely to the compiled snapshot; XSim uses its documented default lookup from current directory.',
      'snapshot_runtime_artifacts':'Only att_cold_static/xsim_script.tcl, xsimSettings.ini, xsimkernel.log and xsimcrash.log may change between compiled-snapshot checks. Verify and archive the four exact files after runtime; all other additions, deletions or byte changes fail.',
      'stage_execution_contract':'After a separate compiler/runtime release, run each binding precheck, then guarded command, then binding postcheck even on command failure; stop on first failure and retain guard/log/archive. No Attention EDA is released by this packet.',
      'policy':'One Laya heavy tool, four CPUs, nice19, idle I/O, owned RSS samples <=0.2s, MemAvailable strictly >192GiB. Build 16GiB/300s and runtime 8GiB/3600s are source proposals for reviewer, not execution authorization.',
      'prior_cycle_watchdogs':{'run':2000000,'other_each':200000,'total':2700000,
          'basis':'8256*27=222912 QKV read component +44736 QK +2294 softmax +45056 AV =314998; 2*8256*5=82560 serialized AR/R adapter allowance; 100000 other-interface allowance. RUN finite control includes 16 reserved/24 digest/4 build-tag/48 metadata checks, 48*64 mask-row visits, at most 48 cover calls and 6144 check/mark row visits, 48 publish all_rows calls *64 bit tests=3072 and 128 covered-row marks, <=3072 report popcount shifts, two owner snapshots, 64 score +64 probability +64 AV observation writes, 64 ATT_OUT reads, 32 cleanup owner visits and 30 status resets. BEGIN parses a 128B header, 4*16 tag bytes, 5 directories, 64 token and 16 marker entries; two QKV claims scan <=32 owners each and clear 6144 plane plus 4096 rope bitmap words and 2*2*64 owner-row words. Remaining watchdog capacity covers these loops plus generated FSM/control and arbitration; it is not a proven latency bound. Every 100000 cycles prints state/phase hint, seven-port counts and actual XSim RSS.'},
      'scope':'Cold B1/S64 Decision stage4/layer0 head0/query0 only; four calls on one DUT, physical host verified before RUN, no internal preload/reset, no subsequent modes yet.'}
    packet['att_out_instance_override']={
      'generated_top':str(VERILOG/'attention_preloaded_slice.v'),
      'origin':'original_v5_generated_top_adapter_instance; no_testbench_or_v2_parameter_override',
      'parameter':'CH0_NUM_WRITE_OUTSTANDING', 'value':1,
      'also_NUM_WRITE_OUTSTANDING':1,'source_line':12002,
      'final_b':'RUN B response index 256 at physical ATT_OUT base+252; 256 AW/W/B, 1024 bus bytes and 256 useful bytes'}
    packet['run_external_transaction_contract']={
      'qkv0':'8256 AR/R, 33024 read bus bytes, exact Q [0,256), K [0x400000,0x404000), V [0x800000,0x804000)',
      'qkv1':'zero AR/R/AW/W/B',
      'att_out':'64 AR/R, 256 read bus bytes; 256 AW/W/B, 1024 write bus bytes and 256 useful bytes, first 256 B only; AWLEN=0, AWSIZE=2, WSTRB=1<<(i%4), AWADDR=base+4*floor(i/4)'}
    OUT.write_text(json.dumps(packet,indent=2,sort_keys=True)+'\n')
    print('ATT_COLD_SOURCE_PACKET',OUT,'source_files',len(sources),'prepared_pages',len(pages),
          'libraries',sum(len(x) for x in libs.values()))
if __name__=='__main__': main()
