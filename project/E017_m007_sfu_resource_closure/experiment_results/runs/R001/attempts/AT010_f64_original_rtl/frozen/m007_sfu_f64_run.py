#!/usr/bin/env python3
"""Conditional E017 exact six-file F64mul functional and bottom-up pilot."""
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
import m007_sfu_measure_run as common
ROOT,MOD,RUN,VIV,HELPER=common.ROOT,common.MOD,common.RUN,common.VIV,common.HELPER
sha,dump=common.sha,common.dump
F64='attention_exp_leaf_attention_f64_mul'
M50='attention_exp_leaf_mul_32ns_32ns_50_2_1'
M64='attention_exp_leaf_mul_32ns_32ns_64_2_1'
NAMES=[F64,M50,M64,'attention_exp_leaf_sparsemux_7_2_64_1_1',
       'attention_exp_leaf_sparsemux_7_2_12_1_1','attention_exp_leaf_sparsemux_15_6_64_1_1']
BOUNDARIES=[('mul_32ns_32ns_50_2_1_U1',M50)]+[('mul_32ns_32ns_64_2_1_U'+str(i),M64)for i in [2,3,4]]

def main():
    p=argparse.ArgumentParser();p.add_argument('stage',choices=['refbuild','reference','build','rtl','ooc'])
    p.add_argument('attempt');p.add_argument('--refbuild-at');p.add_argument('--reference-at');p.add_argument('--build-at')
    p.add_argument('--mul50-at',default='AT004_mul50_complete_io_ooc')
    p.add_argument('--mul64-at',default='AT005_mul64_complete_io_ooc');a=p.parse_args()
    assert re.fullmatch('AT[0-9]{3}_[A-Za-z0-9_]+',a.attempt)
    cat={'refbuild':'static','reference':'reference','build':'static','rtl':'rtl','ooc':'ooc'}[a.stage]
    # This path is conditional on actual small-helper measurements and checkpoints.
    children={M50:RUN/'attempts'/a.mul50_at,M64:RUN/'attempts'/a.mul64_at}
    for module,child in children.items():
        rec=json.loads((child/'receipt.json').read_text());assert rec['verdict']=='PASS'
        expected=next(x['sha256'] for x in rec['outputs'] if x['path']=='work/helper.dcp')
        assert sha(child/'work/helper.dcp')==expected
    with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
        print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
        print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
        at=RUN/'attempts'/a.attempt;assert not at.exists(),'fresh AT required'
        f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
        sources=[Path(__file__),MOD/'tb/m007_sfu_measure_run.py',MOD/'tb/m007_sfu_measure_guard.py',HELPER,
                 MOD/'tb/m007_sfu_f64_reference.cpp',MOD/'tb/m007_sfu_f64_tb.sv']
        sources += [MOD/'rtl/strict_exp_ii1_167'/(n+'.v')for n in NAMES]
        old=ROOT/'project/E007_m006_full_fpga_attention/experiment_results/runs/R001/attempts/AT005_strict_exp_pipeline_cpu_oracle/frozen_source/attention_exp_cpu.cpp'
        sources += [old]
        for src in sources:shutil.copy2(src,f/src.name)
        dump(at/'source_manifest.json',{'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'host':socket.gethostname(),'stage':a.stage,'scope':'original exact six-file F64mul, no production writes',
            'files':[{'source':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size}for s in sources]})
        marker=None
        if a.stage=='refbuild':
            cmd=['/usr/bin/g++','-O2','-std=c++17','-fno-fast-math','-frounding-math','-ffp-contract=off',
                 str(f/'m007_sfu_f64_reference.cpp'),'-o',str(w/'f64_reference')]
        elif a.stage=='reference':
            build=RUN/'attempts'/a.refbuild_at
            assert json.loads((build/'receipt.json').read_text())['verdict']=='PASS'
            shutil.copy2(build/'work/f64_reference',f/'f64_reference')
            dump(at/'input_manifest.json',{'refbuild_attempt':a.refbuild_at,'binary_sha256':sha(f/'f64_reference'),
                'independent_rule':'frozen AT005 volatile native binary64 product; finite inputs; FE_TONEAREST; same xorshift seed'})
            (w/'oracle').mkdir();cmd=[str(f/'f64_reference'),str(w/'oracle/f64_vectors.txt')];marker='SFU_REFERENCE_PASS'
        elif a.stage=='build':
            ref=RUN/'attempts'/a.reference_at;assert json.loads((ref/'receipt.json').read_text())['verdict']=='PASS'
            shutil.copytree(ref/'work/oracle',f/'oracle')
            dump(at/'input_manifest.json',{'reference_attempt':a.reference_at,'files':[{'path':str(q.relative_to(f)),'sha256':sha(q)}for q in(f/'oracle').iterdir()]})
            script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+
                ' '.join(str(f/(n+'.v'))for n in NAMES)+' '+str(f/'m007_sfu_f64_tb.sv')+'\n'+
                str(VIV/'xelab')+' work.m007_sfu_f64_tb --relax -mt 4 --O3 -s f64_sim\n')
            cmd=['/bin/bash',str(script)]
        elif a.stage=='rtl':
            build=RUN/'attempts'/a.build_at;assert json.loads((build/'receipt.json').read_text())['verdict']=='PASS'
            assert sha(Path(__file__))==sha(build/'frozen'/Path(__file__).name),'runner changed after build'
            shutil.copytree(build/'work/xsim.dir',w/'xsim.dir')
            if(build/'work/xsim.ini').exists():shutil.copy2(build/'work/xsim.ini',w/'xsim.ini')
            shutil.copytree(build/'frozen/oracle',f/'oracle')
            dump(at/'input_manifest.json',{'build_attempt':a.build_at,'build_manifest_sha256':sha(build/'source_manifest.json'),
                'compiled_files':[{'path':str(q.relative_to(w)),'sha256':sha(q)}for q in sorted((w/'xsim.dir').rglob('*'))if q.is_file()],
                'oracle_sha256':sha(f/'oracle/f64_vectors.txt')})
            cmd=[str(VIV/'xsim'),'f64_sim','-runall','-testplusarg','DATA='+str(f/'oracle')];marker='SFU_RTL_PASS'
        else:
            dcps={}
            for n,child in children.items():
                q=f/(n+'.dcp');shutil.copy2(child/'work/helper.dcp',q);dcps[n]=q
            stubs=f/'integer_stubs.v';stubs.write_text(''.join(
                '(* black_box *) module '+n+' #(parameter ID=1,NUM_STAGE=2,din0_WIDTH=32,din1_WIDTH=32,dout_WIDTH='+str(width)+')'+
                '(input clk,ce,reset,input [din0_WIDTH-1:0] din0,input [din1_WIDTH-1:0] din1,output [dout_WIDTH-1:0] dout); endmodule\n'
                for n,width in [(M50,50),(M64,64)]))
            xdc=f/'f64_complete_io.xdc';xdc.write_text('create_clock -name core -period 3.333333 [get_ports ap_clk]\n'
                'set_clock_uncertainty 0.100 [get_clocks core]\n'
                'set_input_delay -clock core 0.500 [get_ports -filter {DIRECTION == IN && NAME != ap_clk}]\n'
                'set_output_delay -clock core 0.500 [all_outputs]\n')
            tcl=w/'bottomup.tcl';ed=w/'edif';ed.mkdir()
            lines=['set_param general.maxThreads 4','set part xcu55c-fsvh2892-2L-e']
            for n,q in dcps.items():
                lines += ['open_checkpoint {'+str(q)+'}',
                    'if {[get_property PART [current_design]] != $part} {error "DCP_PART"}',
                    'if {[llength [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]] != 0} {error "CHILD_BLACKBOX"}',
                    'write_edif -force {'+str(ed/(n+'.edf'))+'}',
                    'puts "SFU_PHASE_PASS exact_child_DCP_export='+n+'"','close_design','catch {close_project}']
            lines += ['create_project -in_memory -part $part','read_verilog {'+str(stubs)+'}']
            lines += ['read_verilog {'+str(f/(n+'.v'))+'}'for n in NAMES if n not in [M50,M64]]
            lines += ['read_xdc {'+str(xdc)+'}',
                'synth_design -top '+F64+' -part $part -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off',
                'set bb [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]',
                'if {[llength $bb] != 4} {error "PARENT_BOUNDARY_COUNT [llength $bb]"}']
            for cell,n in BOUNDARIES:
                lines += ['set target [get_cells -quiet {'+cell+'}]',
                    'if {[llength $target] != 1 || [get_property REF_NAME $target] != "'+n+'" || ![get_property IS_BLACKBOX $target]} {error "PARENT_BOUNDARY '+cell+'"}',
                    'set_property KEEP_HIERARCHY true $target']
            lines += ['write_checkpoint -force parent_stub_only.dcp',
                'write_edif -force {'+str(ed/(F64+'.edf'))+'}',
                'puts "SFU_PHASE_PASS parent_export boundaries=4"','close_project']
            lines += ['read_edif {'+str(ed/(n+'.edf'))+'}'for n in [M50,M64,F64]]
            lines += ['link_design -top '+F64+' -part $part -mode out_of_context',
                'read_xdc {'+str(xdc)+'}',
                'if {[llength [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]] != 0} {error "FINAL_BLACKBOX"}',
                'set map [open final_boundary_map.txt w]']
            for cell,n in BOUNDARIES:
                lines += ['set target [get_cells -quiet {'+cell+'}]',
                    'if {[llength $target] != 1 || [get_property REF_NAME $target] != "'+n+'"} {error "LINKED_BOUNDARY '+cell+'"}',
                    'puts $map "'+cell+' '+n+' blackbox=[get_property IS_BLACKBOX $target] child_dcp_sha256='+sha(dcps[n])+'"']
            lines += ['close $map','opt_design','report_utilization -file utilization.rpt',
                'report_utilization -hierarchical -file utilization_hierarchical.rpt',
                'report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file timing_summary.rpt',
                'check_timing -verbose -file check_timing.rpt',
                'report_timing -delay_type max -max_paths 10 -file setup.rpt',
                'report_timing -delay_type min -max_paths 10 -file hold.rpt',
                'write_checkpoint -force f64_bottomup.dcp','write_verilog -mode funcsim f64_bottomup_sim.v',
                'puts "SFU_OOC_PASS F64_BOTTOMUP boundaries=4 blackboxes=0"','exit']
            tcl.write_text('\n'.join(lines)+'\n')
            dump(at/'bottomup_manifest.json',{'part':'xcu55c-fsvh2892-2L-e','clock_period_ns':3.333333,
                'input_output_delay_ns':0.5,'uncertainty_ns':0.1,'xdc_sha256':sha(xdc),'tcl_sha256':sha(tcl),
                'stub_sha256':sha(stubs),'boundaries':[{'cell':c,'module':n,'child_dcp_sha256':sha(dcps[n]),
                    'source_attempt':str(children[n].relative_to(ROOT))}for c,n in BOUNDARIES],
                'unused_parameter_equivalence':'Original helper ID/NUM_STAGE never referenced. DCP width32x32 correct; parent NUM_STAGE2 and child default0 implement identical logic.'})
            cmd=[str(VIV/'vivado'),'-mode','batch','-source',str(tcl),'-notrace'];marker='SFU_OOC_PASS F64_BOTTOMUP'
        costs=common.ledger();limit=min(120,int(common.CAPS[cat]-costs[cat]))
        assert limit>0,'budget insufficient'
        out=at/'guard';argv=[sys.executable,str(f/'m007_sfu_measure_guard.py'),'--out',str(out),'--cwd',str(w),
            '--rss-gib',str(16 if cat=='reference' else 8 if cat=='rtl' else 24),
            '--timeout-seconds',str(limit),'--semantic-stall-seconds','120','--',*cmd]
        dump(at/'command.json',{'argv':argv,'category':cat,'stage':a.stage,'lock':'m007_heavy.lock through all actual descendants','pilot_seconds':120})
        rc=subprocess.call(argv,cwd=w);g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace')
        fatal=bool(re.search(r'(?im)(?:^|\s)(?:Fatal|FATAL|ERROR)\s*[:\[]',log));ok=rc==0 and not fatal and(marker is None or marker in log)
        dump(at/'receipt.json',{'verdict':'PASS'if ok else'COST_STOP'if g.get('trigger')else'FAIL',
            'category':cat,'stage':a.stage,'guard':g,'wrapper_exit':rc,'error_or_fatal':fatal,'marker':marker,
            'marker_found':marker is None or marker in log,
            'outputs':[{'path':str(q.relative_to(at)),'sha256':sha(q),'bytes':q.stat().st_size}for q in sorted(w.rglob('*'))
                       if q.is_file()and(q.suffix in ['.dcp','.edf','.rpt','.txt']or q.name=='f64_reference')]})
        common.ledger();print((at/'receipt.json').read_text(),flush=True);return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
