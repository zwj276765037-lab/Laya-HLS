#!/usr/bin/env python3
"""Prepare the independently budgeted exact fullgraph closure and strict progress guard."""
import importlib.util,json,subprocess,sys,time
from pathlib import Path
h=Path(__file__).resolve().parent;root=h.parents[4];run=root/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002';run.mkdir(exist_ok=False);at=run/'attempts/AT001_fullgraph_kind7';at.mkdir(parents=True)
# Preserve all R001 helpers; the new runner and guard have distinct identities.
text=(h/'run.py').read_text().replace("runs/R001'","runs/R002'")
text=text.replace("if spent[cat]+a.timeout>1800-(300 if cat=='rtl' else 0):raise RuntimeError('D33 budget/reserve preflight')","if spent[cat]+a.timeout>({'static':1200,'rtl':6600}[cat]):raise RuntimeError('D34 independent budget/reserve preflight')")
assert "runs/R002'" in text and "D34 independent" in text
runner=h/'fullgraph_run_r002.py';runner.write_text(text)
spec=importlib.util.spec_from_file_location('r002',runner);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);assert m.ROOT==root and m.RUN==run
original=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007/attempts/AT042_encoder_1d_compatibility_build/frozen/m007_parent_guard_v2.py';text=original.read_text();start=text.index('    if phase == "rtl":',text.index('def semantic_progress_advances'));end=text.index('    """Classify',start)
branch='''    if phase == "rtl":
        state = dict(split_highwater or {})
        match = PARENT_PROGRESS.fullmatch(line)
        stream = "checked"
        if match:
            count, cycle = int(match.group(1)), int(match.group(3))
        else:
            match = RETIRED_PROGRESS.fullmatch(line)
            stream = "retired"
            if not match:
                return False, split_highwater
            count, cycle = map(int, match.groups())
        previous = state.get(stream, (0, 0))
        latest_cycle = max((value[1] for value in state.values()), default=0)
        if count <= previous[0] or cycle < latest_cycle or cycle < previous[1]:
            return False, split_highwater
        if stream == "retired" and cycle <= previous[1]:
            return False, split_highwater
        state[stream] = (count, cycle)
        return True, state
'''
text=text[:start]+branch+text[end:];anchor='def semantic_progress_advances';idx=text.index(anchor);text=text[:idx]+'RETIRED_PROGRESS = re.compile(r"^M007_RTL_RETIRE_PROGRESS retired=(\\d+) cycle=(\\d+)$")\n\n'+text[idx:]
text=text.replace('semantic_pattern = PARENT_PROGRESS','semantic_pattern = re.compile(r"^(?:M007_PARENT_CHECKED|M007_RTL_RETIRE_PROGRESS) ")')
text=text.replace('strict checked-word highwater; no artifact or generic logs','separate strict independent checked-word and actual result/ACK retirement highwaters; retirement is not gold count; no artifact/generic heartbeat')
text=text.replace('"checked_highwater": split_highwater if args.phase == "rtl" else None,','"checked_highwater": (split_highwater or {}).get("checked") if args.phase == "rtl" else None,\n                "retired_highwater": (split_highwater or {}).get("retired") if args.phase == "rtl" else None,')
text=text.replace('"checked_highwater": split_highwater})','"progress_stream_highwaters": split_highwater})')
guard=h/'fullgraph_guard_v1.py';guard.write_text(text)
# Record exact future controls and all current source/data input identities.
base=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';manifest=base/'prepared/fullgraph_retire_progress_v3/source_manifest.json';f=json.loads(manifest.read_text());binding=json.loads((m.ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R001/fullgraph_successor_source_binding_plan.json').read_text());args=dict(binding['plusargs']);args['EXPORT']=str(at/'work/actual_fullgraph');inputs=[z['path'] for z in binding['actual_input_files']+binding['actual_BO_files_rehashed_now']]+[binding['package_manifest']['path'],str(manifest),str(base/'fullgraph_retire_progress_delivery.json'),str(base/'fullgraph_original_input_binding.json'),str(h/'runtime_fixed_batch_v1/verilated_timing.cpp'),str(h/'runtime_fixed_batch_v1/manifest.json')]
cfg={'case':'original_once_BEGIN_kind7_fullgraph120peer_unknown_pilot','top':f['top'],'sources':[str(root/z['path']) for z in f['compile_sources']],'inputs':list(dict.fromkeys(inputs)),'plusargs':['+'+k+'='+v for k,v in args.items()],'marker':'HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=7 layers=30 matrix=120 outputs=544 actual_tail_commit=1','output_split':5000,'output_split_cfuncs':100,'verilator_flags':['--compiler','gcc','--unroll-count','128','--converge-limit','512'],'record_cxx_units':True,'guard_path':str(guard),'guard_phase_option':True,'runtime_identity':'5.020+local fixed-batch-v1+converge512; model1/context1','semantic_pattern':r'^(?:M007_|HARDWARE_AGENT_SIM_PASS)','require_exact_semantics':False}
m.dump(at/'proposed_config.json',cfg);m.dump(run/'budget_authorization.json',{'task':'D-M007-SM012-FULLGRAPH-COMPILED-34','task_source':str(root/'mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md'),'reference':0,'static':1200,'rtl':7200,'rtl_reserve':600,'unknown_stage_seconds':120,'first_build_total_plan_seconds_if_scale_gate':500,'maximum_single_rtl_seconds':3600,'R001_balance_transferred':False,'prior_preparation_known_seconds':binding['source_binding_prep_measured_seconds'],'other_prior_unmeasured_preparation_seconds':'UNKNOWN'})
# Unit tests exercise exact parser classifications; these are guard tests, not RTL proof.
test=run/'guard_progress_tests.py';test.write_text('''import importlib.util,json,sys
from pathlib import Path
spec=importlib.util.spec_from_file_location('guard',sys.argv[1]);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
state=None;cases=[]
def check(line,expected):
 global state
 prior=state;ok,state=g.semantic_progress_advances(line,state,'rtl');assert ok==expected,(line,ok,expected);assert expected or state==prior;cases.append({'line':line,'expected_advance':expected})
check('M007_PARENT_CHECKED checked=4096 phase=PUBLIC_H cycle=100',True)
check('M007_RTL_RETIRE_PROGRESS retired=128 cycle=200',True)
check('M007_RTL_RETIRE_PROGRESS retired=128 cycle=201',False)
check('M007_RTL_RETIRE_PROGRESS retired=127 cycle=202',False)
check('M007_RTL_RETIRE_PROGRESS retired=256 cycle=200',False)
check('M007_RTL_RETIRE_PROGRESS retired=256 cycle=199',False)
check('M007_RTL_RETIRE_PROGRESS retired=256 cycle=201',True)
check('M007_PARENT_CHECKED checked=4096 phase=LAYER_H cycle=999',False)
check('M007_PARENT_CHECKED checked=8192 phase=LAYER_H cycle=202',True)
check('M007_RTL_RETIRE_PROGRESS retired=384 cycle=201',False)
check('M007_RTL_RETIRE_PROGRESS retired=384 cycle=203',True)
for line in ['cycle=999 state=7','M007_FULLGRAPH_LAYER_END global=0 checkpoint=0 cycle=999','M007_RTL_RETIRE_PROGRESS retired=512 cycle=204 extra=1','M007_RTL_RETIRE_PROGRESS retired=512 cycle=204heartbeat','prefix M007_RTL_RETIRE_PROGRESS retired=512 cycle=204','M007_PARENT_CHECKED checked=99999 phase=FAKE cycle=100','artifact files=99','M007_RTL_RETIRE_PROGRESS retired=0 cycle=999']:
 check(line,False)
assert state['checked']==(8192,202) and state['retired']==(384,203)
Path(sys.argv[2]).write_text(json.dumps({'verdict':'PASS','cases':cases,'separate_checked_highwater':state['checked'],'separate_retired_highwater':state['retired'],'retired_never_added_to_gold':True},indent=2)+'\\n')
print('FULLGRAPH_GUARD_BRANCH_PASS',len(cases))
''')
work=at/'work';work.mkdir();rom=f['ROM_initialization_files'][0];(work/Path(rom['path']).name).symlink_to(root/rom['path'])
subprocess.run([sys.executable,str(runner),'prepare',at.name,'--config',str(at/'proposed_config.json')],check=True)
# Test under the same guard and heavy lock, then translate under its own≤120 guard.
import fcntl,os
out=at/'guard_progress_tests';cmd=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','24','--timeout-seconds','20','--semantic-stall-seconds','120','--phase','static','--artifact-progress-root',str(work),'--',sys.executable,str(test),str(guard),str(work/'guard_progress_test_result.json')];env=os.environ.copy();env['PYTHONPATH']=str(root/'project/E002_Laya_HLS/experiment/tools')
with (root/'.research-agent/m007_heavy.lock').open('a+') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 with (at/'progress_test_wrapper.log').open('w') as stream:rc=subprocess.call(cmd,cwd=work,env=env,stdout=stream,stderr=subprocess.STDOUT)
g=json.loads((out/'guard_result.json').read_text());ok=rc==0 and json.loads((work/'guard_progress_test_result.json').read_text())['verdict']=='PASS';m.dump(at/'receipt_progress_tests.json',{'category':'static','verdict':'PASS' if ok else 'FAIL','guard':g,'guard_wrapper_exit':rc,'guard_identity':m.identify(guard),'test_identity':m.identify(test)});assert ok
print('GUARD_TEST_PASS',g['elapsed_seconds'],flush=True)
subprocess.run([sys.executable,str(runner),'translate',at.name,'--timeout','120'],check=True)
