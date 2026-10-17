#!/usr/bin/env python3
"""Freeze v2 diagnostic checkpoint and run actual C++ caller/adapter tests."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import run_executor_bootstrap_host as host

ROOT=host.ROOT
PROJECT=host.PROJECT
MODEL=host.MODEL
M=Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--attempt',type=Path,required=True)
    args=ap.parse_args()
    attempt=args.attempt.resolve(); attempt.mkdir(parents=True,exist_ok=False)
    launcher=host.launcher_state()
    (attempt/'launcher.json').write_text(json.dumps(launcher,indent=2)+'\n')
    if not launcher['pass']: raise RuntimeError('launcher rejected')
    config=Path('config/executor_checkpoint_sources.cmake')
    production=host.cmake_sources(ROOT/config)
    forbidden={'task_lifecycle_executor.cpp','full_forward_controller.cpp',
        'controller_transaction_dispatch.cpp','controller_transaction_hls.cpp',
        'controller_transaction_adapter.cpp','compute_portal_codec.cpp',
        'generated_provenance_codec.cpp','producer_engine_codec.cpp'}
    required={'executor_checkpoint.cpp','executor_checkpoint_protocol.cpp',
        'executor_bootstrap.cpp','bootstrap_snapshot_protocol.cpp',
        'task_lifecycle_fsm.cpp','task_lifecycle_port.cpp'}
    names={p.name for p in production}
    if names & forbidden or not required.issubset(names): raise RuntimeError('source closure rejected')
    integration=[Path(s) for s in [
        'hls/control/graph_program_sequencer.cpp','hls/control/graph_program_protocol.cpp',
        'hls/platform/controller_transaction_adapter.cpp','hls/platform/compute_portal_codec.cpp',
        'hls/platform/generated_provenance_codec.cpp','hls/platform/producer_engine_codec.cpp']]
    sources=production+integration
    test=Path('tests/executor_checkpoint_test.cpp')
    flags=['-std=c++17','-O1','-Wall','-Wextra','-Werror','-Wno-unknown-pragmas',
        '-Wno-unused-parameter','-Wno-aggressive-loop-optimizations','-fno-fast-math',
        '-fno-associative-math','-ffp-contract=off','-DLAYA_PARTITIONED_PRODUCTION_CALLER',
        '-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER','-pthread']
    vitis=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include')
    includes=['-I'+str(ROOT/'include'),'-I'+str(ROOT/'hls'),
        '-I'+str(ROOT/'hls/platform'),'-I'+str(ROOT/MODEL),'-isystem',str(vitis)]
    closure=set()
    for unit in sources+[test]:
        deps=subprocess.check_output(['g++',*flags,*includes,'-MM',str(ROOT/unit)],
            cwd=ROOT,text=True,timeout=1800,preexec_fn=host.limited)
        for name in deps.replace('\\\n',' ').split(':',1)[1].split():
            p=Path(name).resolve()
            if ROOT in p.parents: closure.add(p)
    fixed=[config,Path('config/full_module_registry.json'),
        Path('config/production_hls_partitions.json'),Path('config/graph_action_registry.json'),
        MODEL/'manifest.json',MODEL/'aux.bin',Path('tests/executor_checkpoint_fixture.py'),
        Path('tests/executor_bootstrap_fixture.py'),M/'rtl/laya_executor_checkpoint_layout_v2.sv',
        M/'rtl/laya_bootstrap_snapshot_layout_v1.sv',M/'rtl/laya_graph_action_layout_v1.sv',
        M/'tb/production_guard.py',Path('tools/hls_guard_helpers.py'),
        Path(__file__).resolve().relative_to(ROOT),M/'tb/run_executor_bootstrap_host.py']
    closure.update((ROOT/p).resolve() for p in fixed)
    frozen=attempt/'frozen'; records=[]
    def copy(src,rel):
        dst=frozen/rel; dst.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(src,dst)
        records.append({'relative':str(rel),'original':host.rec(src),'frozen':host.rec(dst)})
    for src in sorted(closure): copy(src,src.relative_to(ROOT))
    for name in ['production_hls_partition_contract_20261012.md',
        'executor_bootstrap_source_contract_20261012.md','executor_checkpoint_high_water_contract_20261012.md']:
        copy(PROJECT/'results'/name,Path('external/contracts')/name)
    compiler=Path(shutil.which('g++'))
    build=[str(compiler),*flags,'-I'+str(frozen/'include'),'-I'+str(frozen/'hls'),
        '-I'+str(frozen/'hls/platform'),'-I'+str(frozen/MODEL),'-isystem',str(vitis),
        str(frozen/test),*[str(frozen/s) for s in sources],'-o',str(attempt/'test')]
    fixture=[sys.executable,str(frozen/'tests/executor_checkpoint_fixture.py'),
        '--model-header',str(frozen/MODEL/'laya_model_layout_generated.h'),
        '--model-aux',str(frozen/MODEL/'aux.bin'),'--output',str(attempt/'fixture')]
    commands={'oracle':fixture,'build':build,'run':[str(attempt/'test'),str(attempt/'fixture')]}
    scope=('1024B/16beat LBS2/LBR2 independent full-byte oracle; atomic host checkpoint '
        'import without retirement/publication; dynamic task and LPV/Ref floors; actual '
        'program helper, lifecycle port/FSM and C++ transaction adapter four-window '
        'retirement, controlled snapshot/fences and remote responses. No RTL snapshot '
        'authority, real handoff, executor HLS, LN arithmetic or full graph acceptance.')
    mp=attempt/'input_manifest.json'
    mp.write_text(json.dumps({'schema':'laya-executor-checkpoint-host-input-v2','scope':scope,
        'files':records,'production_sources':[str(p) for p in production],
        'host_integration_sources':[str(p) for p in integration],'forbidden_present':[],
        'planned_commands':commands,'launcher':host.rec(attempt/'launcher.json'),
        'compiler':host.rec(compiler),'external_headers':[host.rec(vitis/'ap_int.h'),host.rec(vitis/'hls_stream.h')],
        'dependency_extraction_limit':'1800s timeout /24GiB RLIMIT_AS; no owned-RSS sampling'},
        indent=2)+'\n')
    receipt={'schema':'laya-executor-checkpoint-host-receipt-v2','scope':scope,
        'status':'RUNNING','input_manifest':host.rec(mp)}
    for mode,command in commands.items():
        guarded=[sys.executable,str(frozen/M/'tb/production_guard.py'),
            '--out',str(attempt/('guard_'+mode)),'--cwd',str(frozen),
            '--rss-gib','24','--timeout-seconds','1800','--semantic-stall-seconds','120',
            '--',*command]
        proc=subprocess.run(guarded)
        state=json.loads((attempt/('guard_'+mode)/'guard_result.json').read_text())
        log=attempt/('guard_'+mode)/'driver.log'; body=log.read_text()
        marker='FULL_CURRENT_EXECUTOR_CHECKPOINT_'+('HOST_PASS' if mode=='run' else 'FIXTURE_PASS')
        passed=proc.returncode==0 and state['child_exit_code']==0 and state['trigger'] is None
        if mode!='build': passed=passed and body.count(marker)==1
        receipt[mode]={'status':'PASS' if passed else 'FAIL','started':True,'guard':state,
            'runner_exit_code':proc.returncode,'driver_log':host.rec(log),
            'markers':[s for s in body.splitlines() if marker in s]}
        receipt['status']='PASS' if mode=='run' and passed else 'RUNNING' if passed else 'FAIL'
        receipt['fixture_files']=[host.rec(p) for p in sorted((attempt/'fixture').rglob('*')) if p.is_file()]
        (attempt/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
        print('FULL_CURRENT_EXECUTOR_CHECKPOINT_'+mode.upper()+'_'+('PASS' if passed else 'FAIL'),flush=True)
        if not passed: return 1
    receipt['executable']=host.rec(attempt/'test')
    (attempt/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    return 0

if __name__=='__main__': raise SystemExit(main())
