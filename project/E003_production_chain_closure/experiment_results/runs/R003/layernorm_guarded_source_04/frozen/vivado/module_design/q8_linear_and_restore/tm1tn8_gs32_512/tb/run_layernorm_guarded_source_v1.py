#!/usr/bin/env python3
"""Freeze actual generated LN and the finite source guard, then static/pilot."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import runpy
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[5]
PROJECT=ROOT.parents[2]
M=Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL=Path('build/model-current-production-v2-20261011')
ENGINE=PROJECT/'project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_producer_hls_01'

def rec(p):
    p=Path(p).resolve();b=p.read_bytes()
    return {'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}

def launcher():
    available=next(int(s.split()[1]) for s in Path('/proc/meminfo').read_text().splitlines() if s.startswith('MemAvailable:'))
    r={'pid':os.getpid(),'cpu_affinity':sorted(os.sched_getaffinity(0)),
       'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':subprocess.run(['ionice','-p',str(os.getpid())],check=True,text=True,capture_output=True).stdout.strip(),
       'mem_available_kib':available,'required_mem_available_kib':192*1024*1024}
    r['pass']=r['cpu_affinity']==[0,1,2,3] and r['nice']==19 and r['ionice'].startswith('idle') and available>r['required_mem_available_kib']
    return r

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--attempt',type=Path,required=True);a=ap.parse_args()
    attempt=a.attempt.resolve();attempt.mkdir(exist_ok=False)
    state=launcher();(attempt/'launcher.json').write_text(json.dumps(state,indent=2)+'\n')
    if not state['pass']:raise RuntimeError('launcher policy rejected')
    frozen=attempt/'frozen';records=[]
    def copy(src,relative):
        src=Path(src);dst=frozen/relative;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
        pair={'original':rec(src),'frozen':rec(dst)};records.append(pair);return dst
    names=['laya_model_identity_13bo_generated_v1','laya_compute_portal_layout_v1',
        'laya_generated_provenance_layout_v1','laya_private_fifo2_v1',
        'laya_generated_provenance_v1','laya_generated_provenance_hub_v1',
        'laya_generated_provenance_portal_v1','laya_generated_store_monitor_v1',
        'laya_generated_provenance_axi_portal_v1','laya_bootstrap_source_guard_v1',
        'laya_layernorm_producer_portal_shell_v1']
    files=[M/'rtl'/f'{n}.sv' for n in names]+[
        M/'tb/laya_layernorm_guarded_source_tb_v1.sv',M/'tb/run_layernorm_guarded_source_v1.tcl',
        M/'tb/run_layernorm_producer_portal_nowave_v1.tcl',M/'tb/production_guard.py',
        Path('tools/hls_guard_helpers.py'),Path('tools/generate_laya_model_identity_sv.py'),
        Path('tests/executor_bootstrap_fixture.py'),Path('tests/bootstrap_snapshot_rtl_fixture.py'),
        Path('tests/layernorm_guarded_source_fixture.py'),MODEL/'laya_model_layout_generated.h',MODEL/'aux.bin',
        Path('config/full_module_registry.json'),Path('config/production_hls_partitions.json'),
        Path(__file__).resolve().relative_to(ROOT)]
    for rel in files:copy(ROOT/rel,rel)
    generation=json.loads((ENGINE/'input_manifest.json').read_text())
    model=next(i for i in generation['files'] if i['relative']==str(MODEL/'laya_model_layout_generated.h'))
    original_header=Path(model['frozen']['path'])
    if rec(original_header)['sha256']!=model['frozen']['sha256'] or original_header.read_bytes()!=(frozen/MODEL/'laya_model_layout_generated.h').read_bytes():raise RuntimeError('engine/header identity differs')
    helper=runpy.run_path(str(frozen/'tools/generate_laya_model_identity_sv.py'))
    if helper['generate'](frozen/MODEL/'laya_model_layout_generated.h')!=(frozen/M/'rtl/laya_model_identity_13bo_generated_v1.sv').read_text():raise RuntimeError('canonical model differs')
    engine_files=sorted(p for p in (ENGINE/'work/hls/syn/verilog').iterdir() if p.is_file() and p.suffix in {'.v','.dat','.tcl'})
    if not any(p.name=='laya_layernorm_producer_engine.v' for p in engine_files):raise RuntimeError('real generated top absent')
    for p in engine_files:copy(p,Path('external/layernorm_producer_rtl')/p.name)
    for n in ['input_manifest.json','receipt.json','work/reports/hls_compile.rpt']:
        copy(ENGINE/n,Path('external/layernorm_producer_generation')/n)
    inputs=[]
    for n in ['source_rows16.f32.bin','gold_rows16.f32.bin']:
        dst=copy(ENGINE/'fixture'/n,Path('external/numeric_fixture')/n);inputs.append(rec(dst))
    contracts=[]
    for n in ['production_hls_partition_contract_20261012.md','executor_bootstrap_source_contract_20261012.md','generated_provenance_channel_contract_20261012.md']:
        dst=copy(PROJECT/'results'/n,Path('external/contracts')/n);contracts.append({'original':rec(PROJECT/'results'/n),'frozen':rec(dst)})
    host=attempt/'host_fixture';fixture=attempt/'fixture'
    commands_fixture=[
        [sys.executable,str(frozen/'tests/executor_bootstrap_fixture.py'),'--model-header',str(frozen/MODEL/'laya_model_layout_generated.h'),'--model-aux',str(frozen/MODEL/'aux.bin'),'--output',str(host)],
        [sys.executable,str(frozen/'tests/layernorm_guarded_source_fixture.py'),'--host-fixture',str(host),'--prelude-generator',str(frozen/'tests/bootstrap_snapshot_rtl_fixture.py'),'--source',str(frozen/'external/numeric_fixture/source_rows16.f32.bin'),'--gold',str(frozen/'external/numeric_fixture/gold_rows16.f32.bin'),'--out',str(fixture)]]
    for command in commands_fixture:subprocess.run(command,check=True,cwd=ROOT,timeout=120)
    tool=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard=frozen/M/'tb/production_guard.py'
    runtime=attempt/'work/vivado/layernorm_guarded_source.sim/sim_1/behav/xsim'
    static=[sys.executable,str(guard),'--out',str(attempt/'guard_static'),'--cwd',str(ROOT),'--rss-gib','24','--timeout-seconds','1800','--semantic-stall-seconds','120','--',str(tool),'-mode','batch','-notrace','-log',str(attempt/'static.log'),'-journal',str(attempt/'static.jou'),'-source',str(frozen/M/'tb/run_layernorm_guarded_source_v1.tcl'),'-tclargs',str(attempt/'work'),str(frozen),str(fixture)]
    pilot=[sys.executable,str(guard),'--out',str(attempt/'guard_pilot'),'--cwd',str(runtime),'--rss-gib','8','--timeout-seconds','120','--semantic-stall-seconds','120','--',str(tool.parent/'xsim'),'laya_layernorm_guarded_source_tb_v1_behav','-key','Behavioral:sim_1:Functional:laya_layernorm_guarded_source_tb_v1','-tclbatch',str(frozen/M/'tb/run_layernorm_producer_portal_nowave_v1.tcl'),'-log',str(attempt/'pilot.log'),'-testplusarg','FIXTURE='+str(fixture)]
    scope='finite actual generated one-row LN behind F9 full request/completion validation and unique guarded source AR VALID/READY; controlled full B1/S64 checkpoint initialized by normal four-window LPV/real monitored W/B publication; source mutable requests rejected without blocking old END; same actual LPC1 depth2 consumer holds producer/fence through last 2/1 beats; 1024 independent F32 gold words; actual completion builds END, short full-owner window honestly rejected and task5 retired once; controlled LAC1 safe-error depth2 consumer releases source after physical cleanup. Single STATE0 base and two selected monitored write peers only; no real executor/program, all 13BO writes/base lifecycle, full tensor LN, active cancellation recovery, QUANT or whole request success.'
    manifest={'schema':'laya-layernorm-guarded-source-input-v1','scope':scope,'files':records,'contracts':[],
        'fixture_commands':commands_fixture,'fixture_files':[rec(p) for p in sorted(fixture.iterdir())],
        'host_fixture_files':[rec(p) for p in sorted(host.iterdir())],'launcher':rec(attempt/'launcher.json'),
        'tool':rec(tool),'commands':{'static':static,'pilot':pilot},'profiles':{'static':{'maximum_seconds':1800,'maximum_rss_gib':24,'semantic_stall_seconds':120},'pilot':{'maximum_seconds':120,'maximum_rss_gib':8,'maximum_cycles':100000,'semantic_stall_seconds':120}},
        'full':{'status':'NOT_PLANNED_FIXED_PILOT','started':False},'numeric_inputs':inputs,
        'generated_verilog_count':sum(p.suffix=='.v' for p in engine_files),'generated_dat_count':sum(p.suffix=='.dat' for p in engine_files)}
    mp=attempt/'input_manifest.json';mp.write_text(json.dumps(manifest,indent=2)+'\n')
    receipt={'schema':'laya-layernorm-guarded-source-receipt-v1','scope':scope,'input_manifest':rec(mp),'status':'RUNNING'}
    for mode,command,marker in [('static',static,'FULL_CURRENT_LAYERNORM_GUARDED_SOURCE_STATIC_PASS'),('pilot',pilot,'FULL_CURRENT_LAYERNORM_GUARDED_SOURCE_PASS')]:
        if mode=='pilot':
            staged=[]
            for p in sorted((frozen/'external/layernorm_producer_rtl').glob('*.dat')):
                dst=runtime/p.name;shutil.copyfile(p,dst)
                if rec(p)['sha256']!=rec(dst)['sha256']:raise RuntimeError('DAT staging differs')
                staged.append({'source':rec(p),'staged':rec(dst)})
            receipt['runtime_dat_staging']=staged
        result=subprocess.run(command,cwd=ROOT)
        state=json.loads((attempt/('guard_'+mode)/'guard_result.json').read_text())
        log=attempt/('guard_'+mode)/'driver.log';body=log.read_text(errors='replace')
        passed=result.returncode==0 and state['child_exit_code']==0 and state['trigger'] is None and marker in body and 'Fatal:' not in body and 'ERROR:' not in body
        receipt[mode]={'status':'PASS' if passed else 'FAIL','started':True,'runner_exit_code':result.returncode,'guard':state,'marker':[s for s in body.splitlines() if marker in s],'driver_log':rec(log)}
        receipt['native_ip']=[rec(p) for p in sorted((attempt/'work').rglob('*.xci'))]
        if mode=='pilot':receipt['actual_protocol_captures']=[rec(p) for p in sorted(fixture.glob('actual_*.hex'))]
        receipt['status']='PASS' if mode=='pilot' and passed else 'RUNNING' if passed else 'FAIL'
        (attempt/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
        print('FULL_CURRENT_LAYERNORM_GUARDED_SOURCE_'+mode.upper()+'_'+('PASS' if passed else 'FAIL'),flush=True)
        if not passed:return 1
    return 0

if __name__=='__main__':raise SystemExit(main())
