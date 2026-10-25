#!/usr/bin/env python3
"""E016/R006 independent budget and frozen four-owner parent source runner."""
import argparse
from decimal import Decimal
import fcntl
import hashlib
import json
from pathlib import Path
import re
import shlex
import shutil
import socket
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[7]
MOD=Path(__file__).resolve().parents[1]
SRC=ROOT/'project/E016_m007_single_resource_parent/experiment_source'
RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R006'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
CAPS={'reference':0,'static':900,'rtl':7200,'ooc':0}
RESERVE=500
sys.path.insert(0,str(MOD/'tb'))
from m007_ffn_parent_run import selected_sources as old_sources
sys.path.insert(0,str(MOD.parent/'attention_and_fp_engine/tb'))
from m007_joint23_run import selected_sources as bundle_sources


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def dump(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n')
def costs():
    result={k:Decimal(0)for k in CAPS}
    for q in(RUN/'attempts').glob('*/receipt_*.json'):
        d=read(q);result[d['category']]+=Decimal(str(d['wall_s']))
    return result


def readiness(checkpoint):
    # The resource owner's actual compiled/normal-retired checkpoint is the
    # dependency evidence. No additional approval/admission record is created.
    d=read(checkpoint)
    assert d['ready_for_parent_static_integration']is True and d['cleanup_empty']is True
    for key in ['LN_verified_manifest','build_report','pilot_receipt','pilot_report']:
        assert sha(ROOT/d[key])==d[key+'_sha256']
    b=read(ROOT/d['build_report']);n=read(ROOT/d['pilot_report']);r=read(ROOT/d['pilot_receipt'])
    assert b['status']=='BUILD_COMPLETE' and n['status']=='PASS' and r['status']=='EXIT_ZERO'
    assert n['build_manifest_sha256']==d['build_report_sha256']
    assert d['actual_metrics']['residual_vectors']==4096 and d['actual_metrics']['ln_vectors']>=512
    for name,expected in d['source_sha256'].items():assert sha(ROOT/name)==expected,'Production bundle changed '+name
    return {'checkpoint':str(checkpoint),'checkpoint_sha256':sha(checkpoint),
            'build_report':d['build_report'],'build_report_sha256':d['build_report_sha256'],
            'normal_report':d['pilot_report'],'normal_report_sha256':d['pilot_report_sha256'],
            'production_sources':d['source_sha256']}


def sources(top):
    d=old_sources(top)
    for q in bundle_sources():
        if q.suffix in ['.sv','.v','.dat']and '/tb/'not in str(q):
            d[q.name]=(q,q,'A007 frozen verified four-owner bundle source')
    for q in [MOD/'tb/m007_public_f32_capture_tb_v2.sv',MOD/'tb/m007_f32_capture_manifest_v2.py',SRC/'audit_encoder0_parent_r006.py',SRC/'make_encoder0_complete_tb_r006.py',SRC/'encoder0_complete_tb_body_r006.svpart',Path(__file__),MOD/'tb/m007_parent_guard_v2.py',MOD/'tb/m007_encoder0_wall_driver_v2.py',SRC/'compose_encoder0_parent_r006.py',SRC/'encoder0_parent_additions_r006.svpart',SRC/'prepare_encoder0_wrapper_adapter_r006.py',SRC/'prepare_encoder0_fixture_r006.py',SRC/'make_encoder0_public_tb_r006.py',SRC/'protocol_encoder0_r006.md']:
        d[q.name]=(q,q,'R006 owned source/protocol/guard')
    return d


def fixture_identity():
    p=RUN/'data/original_encoder0_fixture/manifest.json';m=read(p)
    rows=[{'path':str(p.relative_to(ROOT)),'sha256':sha(p)}]
    for row in m['files']:
        for key,expected in [('original_source',row['original_sha256']),('serialized_path',row['serialized_sha256'])]:
            q=ROOT/row[key];assert sha(q)==expected;rows.append({'path':str(q.relative_to(ROOT)),'sha256':expected,'role':row['role']})
    att=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle'
    for name in ['cos_full.mem','sin_full.mem']:
        q=att/name;rows.append({'path':str(q.relative_to(ROOT)),'sha256':sha(q),'role':'original coefficient input'})
    return rows,att


def main():
    p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','audit','rtl']);p.add_argument('attempt');p.add_argument('--build',type=Path);p.add_argument('--bundle-checkpoint',type=Path,default=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R002/production_bundle_checkpoint_v1.json');p.add_argument('--mode',type=int,choices=[0,1,2,3],default=0);p.add_argument('--kind',type=int,choices=[3,4],default=4);p.add_argument('--packed',type=int,choices=[0,1],default=1);p.add_argument('--qkv-blocks',type=int,choices=[0,3],default=0);p.add_argument('--head',type=int,choices=[0,1,2],default=0);p.add_argument('--ffn-blocks',type=int,choices=[0,3,16],default=0);p.add_argument('--top',choices=['m007_encoder0_public_tb','m007_encoder0_complete_tb'],default='m007_encoder0_public_tb');a=p.parse_args()
    assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
    with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
        print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
        if a.stage=='build':
            admitted=readiness(a.bundle_checkpoint.resolve())
        else:
            assert a.build;admitted=read(a.build.resolve()/'source_manifest.json')['bundle_evidence']
        used=costs();cat='rtl'if a.stage=='rtl'else'static';timeout=120
        assert Decimal(timeout)<=Decimal(CAPS[cat])-used[cat]
        assert cat!='rtl'or Decimal(CAPS['rtl'])-used['rtl']>=timeout+RESERVE
        at=RUN/'attempts'/a.attempt;assert not at.exists(),'preserve old attempt'
        f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir();shutil.copy2(Path(__file__),at/'actual_orchestrator.py')
        fixtures,attention=fixture_identity();
        fullpaths={}
        if a.top=='m007_encoder0_complete_tb':
            fullpaths={'MATRIX':ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture','INPUT':ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture','CONTEXT':ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R004/attempts/AT005_original_context_wo_fixture/work/fixture','FFN':ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005/fixtures/reference','WI':ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005/fixtures/wi','DOWN':ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005/fixtures/down','G':ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005/fixtures/geglu_vectors.hex','RESIDUAL':ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R001/attempts/AT001_original_residual_fixture/work'}
            relevant=[*list((fullpaths['MATRIX']/'qkv_0_weight').glob('*')),*list((fullpaths['CONTEXT']/'wo_0_weight').glob('*')),fullpaths['INPUT']/'qkv_0_weight/input.hex',fullpaths['RESIDUAL']/'GOLD.hex']+[attention/n for n in ['mask.mem','encoder0_pre_qkv.mem','encoder0_post_qkv.mem','encoder0_score.mem','encoder0_maximum.mem','encoder0_prob.mem','encoder0_context.mem']]
            oldfix=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005/fixtures'
            for entry in read(oldfix/'manifest.json')['files']:
                q=oldfix/entry['frozen'];assert sha(q)==entry['sha256'];relevant.append(q)
            for q in sorted(set(relevant)):
                if q.is_file():fixtures.append({'path':str(q.relative_to(ROOT)),'sha256':sha(q),'role':'original independent math checker or original external W input; no intermediate DUT producer'})
        dump(at/'fixture_manifest.json',{'files':fixtures,'no_reference_arithmetic':True})
        if a.stage=='build':
            selected=sources(a.top)
            for name,(origin,current,why)in selected.items():shutil.copy2(origin,f/name)
            dump(at/'source_manifest.json',{'top':a.top,'host':socket.gethostname(),'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','desired_model':'gpt-6.1-sol','desired_effort':'xhigh','parent_v2_sha256':sha(f/'laya_m007_single_parent_v2.sv'),'bundle_evidence':admitted,'fixture_manifest_sha256':sha(at/'fixture_manifest.json'),'files':[{'frozen':name,'source':str(current),'origin':str(origin),'why':why,'sha256':sha(f/name),'bytes':(f/name).stat().st_size}for name,(origin,current,why)in selected.items()]})
            for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
            hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nforeach scope [get_scopes -r /*] {puts $h $scope}\nclose $h\nquit\n')
            script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join([str(VIV/'xvlog'),'--sv',*[str(q)for q in sorted(f.iterdir(),key=lambda q:(q.name!='laya_m007_tanh_fast_leaves_v1.sv',q.name))if q.suffix in ['.sv','.v']]])+'\n'+shlex.join([str(VIV/'xelab'),'work.'+a.top,'--relax','-debug','typical','-mt','4','--O3','-s','m007_encoder0_parent_sim'])+'\n'+shlex.join([str(VIV/'xsim'),'m007_encoder0_parent_sim','-tclbatch',str(hier)])+'\necho M007_ENCODER0_BUILD_PASS\n')
            cmd=['/bin/bash',str(script)];marker='M007_ENCODER0_BUILD_PASS'
        elif a.stage=='audit':
            assert a.build;b=a.build.resolve()
            for q in [MOD/'tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',SRC/'audit_encoder0_parent_r006.py',SRC/'protocol_encoder0_r006.md']:shutil.copy2(q,f/q.name)
            dump(at/'source_manifest.json',{'stage':'actual compiled parent declaration/hierarchy audit','compiled_build':str(b),'compiled_build_manifest_sha256':sha(b/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)}for q in sorted(f.iterdir())if q.is_file()]})
            cmd=[sys.executable,str(f/'audit_encoder0_parent_r006.py'),'--build',str(b),'--out',str(w)];marker='M007_ENCODER0_CENSUS_PASS'
        else:
            assert a.build;b=a.build.resolve();assert read(b/'receipt_static.json')['verdict']=='PASS'and read(b/'source_manifest.json')['top']==a.top
            for row in read(b/'source_manifest.json')['files']:assert sha(b/'frozen'/row['frozen'])==row['sha256']
            for q in(b/'frozen').iterdir():
                if q.is_file():shutil.copy2(q,f/q.name)
            # Runtime guards are separately versioned; replacing a Python
            # observer does not recompile or relabel the frozen SV snapshot.
            runtime_tools=[MOD/'tb/m007_parent_guard_v2.py',MOD/'tb/m007_encoder0_wall_driver_v2.py']
            for tool in runtime_tools:shutil.copy2(tool,f/tool.name)
            dump(at/'runtime_tool_identity.json',{'compiled_build_manifest_sha256':sha(b/'source_manifest.json'),'tools':[{'name':tool.name,'current_sha256':sha(tool),'compiled_archive_sha256':sha(b/'frozen'/tool.name)}for tool in runtime_tools]})
            shutil.copytree(b/'work/xsim.dir',w/'xsim.dir')
            for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
            dump(at/'source_manifest.json',{'build':str(b),'build_manifest_sha256':sha(b/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)}for q in sorted(f.iterdir())if q.is_file()]})
            dump(at/'fixture_identity.json',{'build':str(b),'build_manifest_sha256':sha(b/'source_manifest.json'),'fixture_manifest_sha256':sha(at/'fixture_manifest.json'),'snapshot_files':[{'path':str(q.relative_to(w)),'sha256':sha(q)}for q in sorted((w/'xsim.dir').rglob('*'))if q.is_file()]})
            cmd=[sys.executable,str(f/'m007_encoder0_wall_driver_v2.py'),'--out',str(w/'encoder0_wall_events.json'),'--',str(VIV/'xsim'),'m007_encoder0_parent_sim','-runall','-testplusarg','FIXTURE='+str(RUN/'data/original_encoder0_fixture'),'-testplusarg','ATTENTION='+str(attention),'-testplusarg','MODE='+str(a.mode)];marker='HARDWARE_AGENT_SIM_PASS M007_ENCODER0_PUBLIC_H_PREFIX'
            if a.top=='m007_encoder0_complete_tb':
                assert a.head==0 and ((a.kind==4 and a.qkv_blocks==3 and a.ffn_blocks==0)or(a.kind==3 and a.ffn_blocks==3 and a.qkv_blocks==0)),'Only unknown120s math prefixes enabled until same-build measured gates are prepared'
                cmd=[sys.executable,str(f/'m007_encoder0_wall_driver_v2.py'),'--out',str(w/'encoder0_wall_events.json'),'--',str(VIV/'xsim'),'m007_encoder0_parent_sim','-runall','-testplusarg','ORIGINAL='+str(RUN/'data/original_encoder0_fixture'),'-testplusarg','ATTENTION='+str(attention),'-testplusarg','KIND='+str(a.kind),'-testplusarg','PACKED='+str(a.packed),'-testplusarg','STOP_QKV_BLOCKS='+str(a.qkv_blocks),'-testplusarg','STOP_AFTER_HEAD='+str(a.head),'-testplusarg','STOP_FFN_BLOCKS='+str(a.ffn_blocks)]
                for key,value in fullpaths.items():cmd+=['-testplusarg',key+'='+str(value)]
                marker='HARDWARE_AGENT_SIM_PASS M007_ENCODER0_QKV_PREFIX'if a.kind==4 else'HARDWARE_AGENT_SIM_PASS M007_ENCODER0_FFN_PREFIX'
        guardcmd=[sys.executable,str(f/'m007_parent_guard_v2.py'),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static'else 8),'--timeout-seconds',str(timeout),'--semantic-stall-seconds','120','--phase',cat]+(['--artifact-progress-root',str(w)]if cat=='static'else[])+['--',*cmd]
        dump(at/('command_'+cat+'.json'),{'argv':guardcmd,'actual_orchestrator_sha256':sha(at/'actual_orchestrator.py'),'single_project_lock_held':True,'used_before_s_exact':{k:str(v)for k,v in used.items()},'requested_timeout_s':timeout,'no_old_balance_transfer':True,'full_Encoder_authorized_by_this_command':False})
        rc=subprocess.call(guardcmd,cwd=w)
        g=read(at/('guard_'+cat)/'guard_result.json');log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL_ERROR|FATAL|Fatal|ERROR)\s*[:\[]',log));passed=rc==0 and not fatal and marker in log
        dump(at/('receipt_'+cat+'.json'),{'category':cat,'mode':a.mode if cat=='rtl'else None,'top':a.top,'kind':a.kind,'packed':a.packed,'stop_qkv_blocks':a.qkv_blocks,'stop_after_head':a.head,'stop_ffn_blocks':a.ffn_blocks,'wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'required_marker':marker,'marker_found':marker in log,'error_or_fatal':fatal,'verdict':'PASS'if passed else'COST_STOP'if g['trigger']else'FAIL','scope':('public H/input/error recovery prefix only'if a.top=='m007_encoder0_public_tb'else'actual original complete-checker math prefix only')if cat=='rtl'else'actual source/control hierarchy audit'if a.stage=='audit'else'complete production v2 parent elaboration'})
        used=costs();dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s_exact':{k:str(v)for k,v in used.items()},'remaining_s_exact':{k:str(Decimal(CAPS[k])-used[k])for k in used},'reserve_rtl_s':RESERVE,'old_balances_transferred':False})
        for line in log.splitlines():
            if '_PASS'in line or 'Fatal:'in line or 'ERROR:'in line:print(line,flush=True)
        print(json.dumps(g),flush=True)
        return 0 if passed else 1


if __name__=='__main__':raise SystemExit(main())
