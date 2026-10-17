#!/usr/bin/env python3
"""Bind finite source, original V5 hardware, guards and installed library closure."""
from __future__ import annotations
from datetime import datetime,timezone
import hashlib,json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent
V5=ROOT.parent
BASE=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
TASK=BASE/'results/attention_rtl_repair_20261008'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado')
VERILOG=V5/'runs/local_csynth_v1/work/hls/syn/verilog'
REPORT=V5/'runs/local_csynth_v1/work/hls/syn/report'
IP=V5/'runs/local_csynth_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip'
GATE=TASK/'reviewer_attention_v5_head15_changed_finite_source_preparation_release.json'
COLD_GATE=TASK/'reviewer_attention_v5_cold_static_source_preparation_release.json'
COLD_ACCEPT=TASK/'reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json'
ENDPOINT=TASK/'d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv'
G16=TASK/'d2_controller_reachable/source/guard_16g.py'
G4=TASK/'d2_axi_allocation_diagnostic/guard_trace_v5/tb/guard_runtime_4g.py'
OUT=ROOT/'source/source_packet.json'

def sha(path:Path)->str:
    digest=hashlib.sha256()
    with path.open('rb') as source:
        for block in iter(lambda:source.read(1<<20),b''): digest.update(block)
    return digest.hexdigest()

def record(path:Path)->dict:
    assert path.is_file(),path
    return {'path':str(path.resolve()),'bytes':path.stat().st_size,
            'mode':oct(path.stat().st_mode & 0o777),'sha256':sha(path)}

def inventory(paths): return [record(path) for path in sorted(set(paths))]

def main():
    assert not OUT.exists(),OUT
    assert sha(GATE)=='7044e85372af05ba3660ac0bde6a094f7385229c11ff86ae090f8a3168ef2203'
    assert sha(COLD_GATE)=='b73b9095ca3e3c80c512ff404c4c6c8883afd31626e85c38b7e012016cca61eb'
    assert sha(COLD_ACCEPT)=='5166ae99b1d2378e1229de7a5758707813b25b581a19f4852221a983e4cffc97'
    assert sha(ENDPOINT)=='b33c29a0ce934f19f61b1313ca82f24ef3df60bede1b949610054f4caa7b909d'
    release=json.loads(GATE.read_text())
    for item in release['source_records']:
        source=Path(item['path'])
        assert source.stat().st_size==item['bytes'] and sha(source)==item['sha256'],source
    verilog=sorted(VERILOG.glob('*.v'))
    data=sorted(VERILOG.glob('*.dat'))
    wrappers=sorted(IP.glob('*/sim/*_ip.vhd'))
    assert (len(verilog),len(data),len(wrappers))==(216,35,6)
    sources=[path for path in HERE.iterdir() if path.is_file() and path.suffix in
             ('.py','.sh','.sv','.svh','.c','.so')]
    sources += [ROOT/'source/design.md',ROOT/'source/results.md',
                ROOT/'source/cold_v2_to_finite_control.diff',ROOT/'rtl/README.md']
    sources += [path for path in (ROOT/'source/history/cold_v2_preimage').iterdir() if path.is_file()]
    fixture=V5/'tb/fixture_preloaded'
    fixture_manifest_path=fixture/'fixture_manifest.json'
    assert sha(fixture_manifest_path)=='1f7f163924457d024d141b66994a7ce453467969f9ddca781caebd4bc5dcb43c'
    fixture_manifest=json.loads(fixture_manifest_path.read_text())
    base_source=fixture_manifest['cases']['base']['source_sha256']
    changed_source=fixture_manifest['cases']['changed']['source_sha256']
    assert base_source!=changed_source
    base_gold=fixture_manifest['gold']['base_h0_r0']
    changed_gold=fixture_manifest['gold']['changed_h0_r0']
    assert all(base_gold[kind]!=changed_gold[kind] for kind in ('score','probability','av'))
    old=TASK/'d2_attention_slice/tb/fixture_b1_s64_decision'
    package=BASE/'build/model-attention-rtl-repair-20261008'
    frozen=[V5/'config.cfg',V5/'source/attention_preloaded_slice.cpp',
            V5/'source/attention_preloaded_abi.h',
            V5/'runs/local_csynth_v1/synthesis_evidence.json',
            V5/'runs/source_config_binding_v1/source_config_binding_packet.json',
            V5/'rtl_static_cold_v2/source/source_packet.json',
            old/'request.bin',old/'qkv_final.f32.bin',
            package/'aux.bin',package/'manifest.json']
    frozen += [path for path in fixture.iterdir() if path.is_file()]
    libs={}
    for name,relative in {
        'floating_point_v7_1_21':'ip/floating_point_v7_1_21',
        'unisim':'vhdl/unisim','unisims_ver':'verilog/unisims_ver',
        'secureip':'verilog/secureip','xpm':'ip/xpm','ieee':'vhdl/ieee'
    }.items():
        directory=VIV/'data/xsim'/relative
        assert directory.is_dir(),directory
        libs[name]=inventory(path for path in directory.rglob('*') if path.is_file())
    reports=[REPORT/name for name in ('attention_preloaded_slice_csynth.rpt',
        'p_anonymous_namespace_read_qkv_csynth.rpt',
        'p_anonymous_namespace_read_qkv_f32_csynth.rpt',
        'qk_row_csynth.rpt','softmax_row_csynth.rpt','av_row_csynth.rpt')]
    modes={}
    verify=str(HERE/'verify_binding.py')
    packet_path=str(OUT)
    for mode in release['prepared_modes']:
        name=mode['mode']
        materialize=ROOT/f'runs/materialize_{name}_v1'
        prepared=materialize/'prepared'
        build=ROOT/f'runs/static_build_{name}_v1'
        runtime=ROOT/f'runs/rtl_{name}_v1'
        snapshot=build/'xsim.dir'
        def bind(output,prepared_pages=False,compiled=False,prepared_prior=None,snapshot_prior=None,run=False):
            argv=['python3',verify,packet_path,name,str(output)]
            if prepared_pages: argv+=['--prepared',str(prepared)]
            if compiled: argv+=['--snapshot',str(snapshot)]
            if prepared_prior: argv+=['--expected-prepared-report',str(prepared_prior)]
            if snapshot_prior: argv+=['--expected-snapshot-report',str(snapshot_prior)]
            if run: argv+=['--runtime',str(runtime)]
            return argv
        materialize_post=materialize/'binding_post.json'
        build_post=build/'binding_post.json'
        runtime_pre=runtime/'binding_pre.json'
        modes[name]={
            **mode,
            'stage_state':'SOURCE_PREPARED_ONLY_NO_MATERIALIZATION_OR_EDA_RELEASE',
            'materialize_dir':str(materialize),'prepared_dir':str(prepared),
            'build_dir':str(build),'runtime_dir':str(runtime),
            'materialize':{
                'cwd':str(materialize),
                'binding_pre_argv':bind(materialize/'binding_pre.json'),
                'guard_argv':['python3',str(G16),'--out',str(materialize/'guard'),
                    '--cwd',str(materialize),'--rss-gib','8','--timeout-seconds','300','--',
                    'python3',str(HERE/'materialize_cold_pages.py'),name,str(prepared)],
                'independent_check_argv':['python3',str(HERE/'check_prepared_pages.py'),
                    name,str(prepared),str(materialize/'independent_page_check.json')],
                'binding_post_argv':bind(materialize_post,prepared_pages=True),
                'archive_argv':['python3',str(HERE/'archive_attempt.py'),name,'materialize',
                    str(materialize),str(materialize/'attempt_archive')]},
            'static':{
                'cwd':str(build),
                'binding_pre_argv':bind(build/'binding_pre.json',prepared_pages=True,
                                        prepared_prior=materialize_post),
                'guard_argv':['python3',str(G16),'--out',str(build/'guard'),
                    '--cwd',str(build),'--rss-gib','16','--timeout-seconds','300','--',
                    str(HERE/'build_static.sh'),name,str(build)],
                'binding_post_argv':bind(build_post,prepared_pages=True,compiled=True,
                    prepared_prior=materialize_post),
                'archive_argv':['python3',str(HERE/'archive_attempt.py'),name,'static',
                    str(build),str(build/'attempt_archive')]},
            'runtime':{
                'cwd':str(runtime),
                'binding_pre_argv':bind(runtime_pre,prepared_pages=True,compiled=True,
                    prepared_prior=build_post,snapshot_prior=build_post),
                'guard_argv':['python3',str(G16),'--out',str(runtime/'guard'),
                    '--cwd',str(runtime),'--rss-gib','8','--timeout-seconds','3600','--',
                    str(HERE/'run_mode.sh'),name,str(runtime),str(build),str(prepared)],
                'binding_post_argv':bind(runtime/'binding_post.json',prepared_pages=True,
                    compiled=True,prepared_prior=runtime_pre,snapshot_prior=build_post,run=True),
                'archive_argv':['python3',str(HERE/'archive_attempt.py'),name,'runtime',
                    str(runtime),str(runtime/'attempt_archive'),'--build',str(build)]}}
    packet={
      'schema':'attention_v5_finite_static_source_packet_v1',
      'created_utc':datetime.now(timezone.utc).isoformat(),
      'state':'SOURCE_PREPARED_ONLY_NO_FINITE_MATERIALIZATION_CPU_OR_EDA_EXECUTED',
      'source_gate':record(GATE),'cold_gate':record(COLD_GATE),
      'cold_v2_numeric_acceptance':record(COLD_ACCEPT),'accepted_endpoint':record(ENDPOINT),
      'verilog_modules':inventory(verilog),'dat_files':inventory(data),
      'fp_sim_vhdl_wrappers':inventory(wrappers),
      'testbench_and_runner':inventory(sources),'frozen_inputs':inventory(frozen),
      'guard_scripts':inventory([G16,G4]),'schedule_reports':inventory(reports),
      'installed_library_files':libs,'xsim_ini':record(VIV/'data/xsim/xsim.ini'),
      'xsim_lookup_manual':record(VIV/'doc/eng/man/xsim'),
      'modes':modes,
      'changed_mode_divergence':{
          'base_source_sha256':base_source,'changed_source_sha256':changed_source,
          'base_h0_r0_gold_sha256':base_gold,'changed_h0_r0_gold_sha256':changed_gold,
          'all_three_gold_kinds_distinct':True},
      'dependency_order':'Review derived head15 pages and actual source, then separately release head15 static and first runtime. Changed execution depends on head15 actual results and its own bounded gate. No automatic sweep.',
      'snapshot_lookup':'Fresh runtime directory links xsim.dir absolutely to same-mode compiled snapshot; XSim default lookup uses current directory.',
      'snapshot_runtime_artifacts':'Only the four named att_finite_<mode>_static/xsim_script.tcl, xsimSettings.ini, xsimkernel.log and xsimcrash.log may change between pre/post snapshot checks. Archive actual files and report missing on first failure.',
      'stage_execution_contract':'For each separately released stage: create a fresh directory, run binding precheck, one guarded command, then binding postcheck and attempt archive even on guard/command failure. Stop on first failure. A failed materializer may have no prepared files, so preserve guard/archive without claiming postcheck pass.',
      'policy':'One Laya heavy tool, four CPUs, nice19, idle I/O, <=0.2 s owned RSS samples and MemAvailable >192 GiB. 8 GiB/300 s materialize, 16 GiB/300 s static and 8 GiB/3600 s runtime are proposals for stage review, not this source gate release.',
      'prior_cycle_watchdogs':{'run':2000000,'other_each':200000,'total':2700000,
          'status':'prior bounded stop proposal; not measured head15/changed latency'},
      'scope':'Fresh-process cold B1/S64 Decision head15/query63 or changed-source head0/query0; no persistent-cache invalidation or full-graph claim.'}
    OUT.write_text(json.dumps(packet,indent=2,sort_keys=True)+'\n')
    print('ATT_FINITE_SOURCE_PACKET',OUT,'source_files',len(sources),
          'libraries',sum(len(group) for group in libs.values()),'modes',len(modes))

if __name__=='__main__': main()
