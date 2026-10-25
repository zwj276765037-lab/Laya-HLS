#!/usr/bin/env python3
"""E017 independent-budget immutable integer helper measurement runner."""
import argparse
import datetime
import fcntl
import hashlib
import json
import re
import shutil
import socket
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[7]
MOD=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E017_m007_sfu_resource_closure/experiment_results/runs/R001'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
CAPS={'reference':120,'static':600,'rtl':600,'ooc':900}
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x): p.write_text(json.dumps(x,indent=2)+'\n')
def ledger():
    costs={k:0.0 for k in CAPS}; receipts=[]
    for p in sorted((RUN/'attempts').glob('AT*/receipt.json')):
        x=json.loads(p.read_text());cat=x['category']
        costs[cat]+=x['guard']['elapsed_seconds']
        receipts.append({'path':str(p.relative_to(ROOT)),'verdict':x['verdict'],
                         'category':cat,'seconds':x['guard']['elapsed_seconds']})
    dump(RUN/'budget_ledger.json',{'caps_seconds':CAPS,'actual_seconds':costs,
         'receipts':receipts,'policy':'independent E017; unknown pilot120s; lock through all descendants; no old transfers'})
    return costs

def main():
    p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl','ooc50','ooc64'])
    p.add_argument('attempt');p.add_argument('--reference-at');p.add_argument('--build-at');a=p.parse_args()
    assert re.fullmatch('AT[0-9]{3}_[A-Za-z0-9_]+',a.attempt)
    cat={'reference':'reference','build':'static','rtl':'rtl','ooc50':'ooc','ooc64':'ooc'}[a.stage]
    with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
        print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
        print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
        at=RUN/'attempts'/a.attempt;assert not at.exists(),'fresh AT required'
        f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
        sources=[Path(__file__),MOD/'tb/m007_sfu_measure_guard.py',HELPER]
        sources += [MOD/'rtl/strict_exp_ii1_167'/('attention_exp_leaf_mul_32ns_32ns_'+str(n)+'_2_1.v') for n in [50,64]]
        sources += [MOD/'tb/m007_sfu_integer_reference.py',MOD/'tb/m007_sfu_integer_tb.sv']
        for src in sources: shutil.copy2(src,f/src.name)
        dump(at/'source_manifest.json',{'recorded_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
             'host':socket.gethostname(),'stage':a.stage,'files':[{'source':str(s.relative_to(ROOT)),
             'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size} for s in sources]})
        marker=None
        if a.stage=='reference':
            cmd=[sys.executable,str(f/'m007_sfu_integer_reference.py'),'--out',str(w/'oracle')]
            marker='SFU_REFERENCE_PASS'
        elif a.stage=='build':
            ref=RUN/'attempts'/a.reference_at
            assert json.loads((ref/'receipt.json').read_text())['verdict']=='PASS'
            shutil.copytree(ref/'work/oracle',f/'oracle')
            dump(at/'input_manifest.json',{'reference_attempt':a.reference_at,
                 'files':[{'path':str(q.relative_to(f)),'sha256':sha(q)} for q in sorted((f/'oracle').iterdir())]})
            script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+str(VIV/'xvlog')+
                ' --sv '+' '.join(str(f/q.name) for q in sources if q.suffix in ['.v','.sv'])+'\n'+
                str(VIV/'xelab')+' work.m007_sfu_integer_tb --relax -mt 4 --O3 -s integer_sim\n')
            cmd=['/bin/bash',str(script)]
        elif a.stage=='rtl':
            build=RUN/'attempts'/a.build_at
            assert json.loads((build/'receipt.json').read_text())['verdict']=='PASS'
            assert sha(Path(__file__))==sha(build/'frozen'/Path(__file__).name),'build runner identity changed'
            shutil.copytree(build/'work/xsim.dir',w/'xsim.dir')
            if (build/'work/xsim.ini').exists():shutil.copy2(build/'work/xsim.ini',w/'xsim.ini')
            shutil.copytree(build/'frozen/oracle',f/'oracle')
            dump(at/'input_manifest.json',{'build_attempt':a.build_at,'build_manifest_sha256':sha(build/'source_manifest.json'),
                'compiled_files':[{'path':str(q.relative_to(w)),'sha256':sha(q)} for q in sorted((w/'xsim.dir').rglob('*')) if q.is_file()],
                'oracle_files':[{'path':str(q.relative_to(f)),'sha256':sha(q)} for q in sorted((f/'oracle').iterdir())]})
            cmd=[str(VIV/'xsim'),'integer_sim','-runall','-testplusarg','DATA='+str(f/'oracle')]
            marker='SFU_RTL_PASS'
        else:
            width=int(a.stage[3:]);top='attention_exp_leaf_mul_32ns_32ns_'+str(width)+'_2_1'
            xdc=w/'helper.xdc';xdc.write_text('create_clock -name core -period 3.333333 [get_ports clk]\n'
                'set_clock_uncertainty 0.100 [get_clocks core]\n'
                'set_input_delay -clock core 0.500 [get_ports -filter {DIRECTION == IN && NAME != clk}]\n'
                'set_output_delay -clock core 0.500 [all_outputs]\n')
            tcl=w/'run.tcl';tcl.write_text('set_param general.maxThreads 4\nread_verilog {'+str(f/(top+'.v'))+'}\n'
                'read_xdc {'+str(xdc)+'}\n'
                'synth_design -top '+top+' -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none '
                '-generic din0_WIDTH=32 -generic din1_WIDTH=32 -generic dout_WIDTH='+str(width)+'\n'
                'opt_design\nreport_utilization -file utilization.rpt\n'
                'report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file timing_summary.rpt\n'
                'check_timing -verbose -file check_timing.rpt\n'
                'report_timing -delay_type max -max_paths 10 -file setup.rpt\n'
                'report_timing -delay_type min -max_paths 10 -file hold.rpt\n'
                'set bb [get_cells -hier -filter {IS_BLACKBOX == 1}]\n'
                'set s [open status.txt w]\nputs $s "blackboxes=[llength $bb]"\n'
                'puts $s "input_bits=[llength [get_ports -filter {DIRECTION == IN}]]"\n'
                'puts $s "output_bits=[llength [all_outputs]]"\n'
                'close $s\nif {[llength $bb] != 0} {error "blackboxes present"}\n'
                'write_checkpoint -force helper.dcp\nwrite_edif -force helper.edf\nputs "SFU_OOC_PASS width='+str(width)+'"\nexit\n')
            dump(at/'constraints_manifest.json',{'part':'xcu55c-fsvh2892-2L-e','tool':'Vivado2025.2',
                'top':top,'generics':{'din0_WIDTH':32,'din1_WIDTH':32,'dout_WIDTH':width},
                'xdc_sha256':sha(xdc),'tcl_sha256':sha(tcl),'clock_period_ns':3.333333,
                'input_delay_ns':0.5,'output_delay_ns':0.5,'clock_uncertainty_ns':0.1})
            cmd=[str(VIV/'vivado'),'-mode','batch','-source',str(tcl),'-notrace'];marker='SFU_OOC_PASS'
        costs=ledger();limit=120;assert costs[cat]+limit<=CAPS[cat],'budget insufficient'
        out=at/'guard';argv=[sys.executable,str(f/'m007_sfu_measure_guard.py'),'--out',str(out),'--cwd',str(w),
            '--rss-gib',str(16 if cat=='reference' else 8 if cat=='rtl' else 24),
            '--timeout-seconds',str(limit),'--semantic-stall-seconds','120','--',*cmd]
        dump(at/'command.json',{'argv':argv,'lock':'m007_heavy.lock through all actual descendants',
             'stage':a.stage,'category':cat,'scope':'E017/R001 integer helpers exact32x32'})
        rc=subprocess.call(argv,cwd=w);g=json.loads((out/'guard_result.json').read_text())
        log=(out/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:Fatal|FATAL|ERROR)\s*[:\[]',log))
        ok=rc==0 and not fatal and (marker is None or marker in log)
        outputs=[q for q in w.rglob('*') if q.is_file() and q.suffix in ['.dcp','.edf','.rpt','.txt','.json']]
        dump(at/'receipt.json',{'verdict':'PASS' if ok else 'COST_STOP' if g.get('trigger') else 'FAIL',
            'category':cat,'stage':a.stage,'guard':g,'wrapper_exit':rc,'error_or_fatal':fatal,
            'marker':marker,'marker_found':marker is None or marker in log,
            'outputs':[{'path':str(q.relative_to(at)),'sha256':sha(q),'bytes':q.stat().st_size} for q in sorted(outputs)]})
        ledger();print((at/'receipt.json').read_text(),flush=True)
        return 0 if ok else 1
if __name__=='__main__': raise SystemExit(main())
