#!/usr/bin/env python3
"""Budgeted isolated observer verification; never modifies an old capture/build."""
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

ROOT=Path(__file__).resolve().parents[3]
MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R006'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
CAPS={'reference':0,'static':900,'rtl':7200,'ooc':0}

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def dump(p,value):p.write_text(json.dumps(value,indent=2)+'\n')
def costs():
    result={k:Decimal(0)for k in CAPS}
    for p in(RUN/'attempts').glob('*/receipt_*.json'):
        d=read(p);result[d['category']]+=Decimal(str(d['wall_s']))
    return result

def main():
    parser=argparse.ArgumentParser();parser.add_argument('stage',choices=['build','rtl']);parser.add_argument('attempt');parser.add_argument('--build',type=Path);args=parser.parse_args()
    assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',args.attempt)
    with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
        try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError:
            print('PROJECT_TOOL_WINDOW_BUSY_NO_ATTEMPT_CREATED',flush=True);return 75
        category='static'if args.stage=='build'else'rtl';used=costs();timeout=120
        assert Decimal(CAPS[category])-used[category]>=timeout+(500 if category=='rtl'else 0)
        at=RUN/'attempts'/args.attempt;assert not at.exists(),'preserve prior attempt'
        frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True);work.mkdir()
        shutil.copy2(Path(__file__),at/'actual_orchestrator.py')
        files=[MOD/'tb'/name for name in ['m007_public_f32_capture_tb_v2.sv','m007_public_f32_capture_directed_tb.sv','m007_public_f32_capture_directed_check.py','m007_f32_capture_manifest_v2.py','m007_parent_guard_v2.py']]
        files+=[ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']
        if args.stage=='build':
            for p in files:shutil.copy2(p,frozen/p.name)
            dump(at/'source_manifest.json',{'scope':'isolated synthetic capture observer only','host':socket.gethostname(),'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','files':[{'source':str(p.relative_to(ROOT)),'frozen':p.name,'sha256':sha(frozen/p.name)}for p in files],'model_or_gold_data_used':False})
            script=work/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join([str(VIV/'xvlog'),'--sv',str(frozen/'m007_public_f32_capture_tb_v2.sv'),str(frozen/'m007_public_f32_capture_directed_tb.sv')])+'\n'+shlex.join([str(VIV/'xelab'),'work.m007_public_f32_capture_directed_tb','--relax','-debug','typical','-mt','4','--O3','-s','m007_capture_directed_sim'])+'\necho M007_CAPTURE_DIRECTED_BUILD_PASS\n')
            command=['/bin/bash',str(script)];marker='M007_CAPTURE_DIRECTED_BUILD_PASS'
        else:
            assert args.build;build=args.build.resolve();assert read(build/'receipt_static.json')['verdict']=='PASS'
            for row in read(build/'source_manifest.json')['files']:assert sha(build/'frozen'/row['frozen'])==row['sha256']
            for p in(build/'frozen').iterdir():shutil.copy2(p,frozen/p.name)
            shutil.copytree(build/'work/xsim.dir',work/'xsim.dir')
            dump(at/'source_manifest.json',{'scope':'same isolated capture observer snapshot, seven synthetic cases','build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'files':[{'frozen':p.name,'sha256':sha(p)}for p in sorted(frozen.iterdir())],'snapshot_initial_identity':[{'path':str(p.relative_to(work)),'sha256':sha(p)}for p in sorted((work/'xsim.dir').rglob('*'))if p.is_file()],'model_or_gold_data_used':False})
            lines=['#!/bin/bash','set -euo pipefail']
            for case in range(7):
                lines.append(shlex.join([str(VIV/'xsim'),'m007_capture_directed_sim','-runall','-log',str(work/f'case{case}.xsim.log'),'-testplusarg',f'CASE={case}','-testplusarg',f'EXPORT={work}/case{case}']))
            lines.append(shlex.join([sys.executable,str(frozen/'m007_public_f32_capture_directed_check.py'),'--work',str(work),'--verifier',str(frozen/'m007_f32_capture_manifest_v2.py')]))
            script=work/'run.sh';script.write_text('\n'.join(lines)+'\n');command=['/bin/bash',str(script)];marker='HARDWARE_AGENT_SIM_PASS M007_CAPTURE_DIRECTED_INDEPENDENT'
        guardcmd=[sys.executable,str(frozen/'m007_parent_guard_v2.py'),'--out',str(at/('guard_'+category)),'--cwd',str(work),'--rss-gib',str(24 if category=='static'else 8),'--timeout-seconds',str(timeout),'--semantic-stall-seconds','120','--phase',category]
        if category=='static':guardcmd+=['--artifact-progress-root',str(work)]
        guardcmd+=['--',*command]
        dump(at/('command_'+category+'.json'),{'argv':guardcmd,'single_project_lock_held_through_descendants':True,'used_before_s_exact':{k:str(v)for k,v in used.items()},'scope':'synthetic capture observer only','full_encoder_authorized_by_this_command':False})
        rc=subprocess.call(guardcmd,cwd=work);guard=read(at/('guard_'+category)/'guard_result.json');log=(at/('guard_'+category)/'driver.log').read_text(errors='replace')
        fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL_ERROR|FATAL|Fatal|ERROR)\s*[:\[]',log));passed=rc==0 and not fatal and marker in log
        dump(at/('receipt_'+category+'.json'),{'category':category,'wall_s':guard['elapsed_seconds'],'guard':guard,'guard_exit':rc,'required_marker':marker,'marker_found':marker in log,'error_or_fatal':fatal,'verdict':'PASS'if passed else'COST_STOP'if guard['trigger']else'FAIL','scope':'synthetic observer serialization/completeness; no production parent or data-chain acceptance'})
        used=costs();dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s_exact':{k:str(v)for k,v in used.items()},'remaining_s_exact':{k:str(Decimal(CAPS[k])-used[k])for k in used},'reserve_rtl_s':500,'old_balances_transferred':False})
        print(json.dumps({'attempt':args.attempt,'category':category,'verdict':'PASS'if passed else'FAIL','guard':guard}),flush=True)
        return 0 if passed else 1

if __name__=='__main__':raise SystemExit(main())
