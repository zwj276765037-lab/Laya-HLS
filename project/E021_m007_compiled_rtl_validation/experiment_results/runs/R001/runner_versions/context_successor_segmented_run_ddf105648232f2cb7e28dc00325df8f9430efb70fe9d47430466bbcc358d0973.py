#!/usr/bin/env python3
"""D33: replay-test the segment watchdog, then run one authorized original Encoder process."""
import argparse, fcntl, importlib.util, json, os, re, subprocess, sys
from pathlib import Path
here=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('d33_segment_launch',here/'run.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
p=argparse.ArgumentParser();p.add_argument('stage',choices=['validate','rtl','all']);a=p.parse_args()
at=m.RUN/'attempts/AT034_context_credit_v3';work=at/'work'
cfg=json.loads((at/'config.json').read_text());contract_path=Path(cfg['segmented_contract'])
contract=json.loads(contract_path.read_text());guard=Path(cfg['guard_path']);driver=here/'segmented_encoder_driver.py'
exe=work/'obj'/('V'+cfg['top']);env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')

def execute(stage):
    cat='static' if stage=='validate' else 'rtl'
    out=at/('guard_'+stage)
    if out.exists():raise SystemExit('preserve prior segment attempt stage')
    spent=m.budget()
    if stage=='validate':
        if spent['static']+20>1800:raise SystemExit('D33 static cap')
        cmd=[sys.executable,str(driver),'replay','--contract',str(contract_path),'--receipt',str(work/'driver_replay_validation.json'),'--streams',str(m.RUN/'attempts/AT029_single_context_head1/work/wall_events.jsonl'),str(m.RUN/'attempts/AT027_full_encoder_pilot/work/wall_events.jsonl')]
        cap=20
    else:
        if json.loads((at/'receipt_validate.json').read_text())['verdict']!='PASS':raise SystemExit('actual watchdog replay PASS required')
        remaining=1800-spent['rtl']
        if remaining<1100 or remaining-contract['overall_seconds']<300:raise SystemExit('D33 launch balance/reserve cap')
        br=Path(cfg['successful_build_receipt']);build=json.loads(br.read_text())
        if build['verdict']!='PASS' or build['executable']['sha256']!=m.sha(exe):raise SystemExit('proven model1/context1 executable required')
        if any(x not in cfg['plusargs'] for x in ['+KIND=5','+PACKED=0','+STOP_QKV_BLOCKS=0','+STOP_AFTER_HEAD=0','+STOP_FFN_BLOCKS=0','+STOP_DOWN_BLOCKS=0']):raise SystemExit('original complete-checker controls required')
        cmd=[sys.executable,str(driver),'run','--contract',str(contract_path),'--events',str(work/'wall_events.jsonl'),'--segments',str(work/'segment_retirements.jsonl'),'--receipt',str(work/'segment_driver_receipt.json'),'--command',str(exe),*cfg['plusargs']]
        cap=contract['overall_seconds']
        m.dump(at/'rtl_execution_identity.json',{'executable':m.identify(exe),'actual_successful_build_receipt':m.identify(br),'config':m.identify(at/'config.json'),'source_manifest':m.identify(at/'source_manifest.json'),'runtime_manifest':m.identify(at/'runtime_build_manifest.json'),'driver':m.identify(driver),'launcher':m.identify(Path(__file__)),'contract':m.identify(contract_path),'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','compiler_optimization':'actual g++ fast O2 / slow O1 / runtime Os; Verilator O3 is translation optimization; successor source: 11 changed TUs compiled, 733 proven generated objects reused','not_30_layer_validation':True})
    argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','24' if cat=='static' else '8','--timeout-seconds',str(cap),'--semantic-stall-seconds','120','--phase',cat]
    if cat=='static':argv+=['--artifact-progress-root',str(work)]
    argv+=['--',*cmd]
    m.dump(at/('command_'+stage+'.json'),{'category':cat,'argv':argv,'budget_before_seconds':spent,'contract':m.identify(contract_path),'driver':m.identify(driver),'launcher':m.identify(Path(__file__)),'same_heavy_lock_held_through_descendants':True,'environment':{'VERILATOR_ROOT':str(m.VROOT),'PYTHONPATH_project_prefix':str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')}})
    with (at/(stage+'_wrapper.log')).open('w') as stream:rc=subprocess.call(argv,cwd=work,env=env,stdout=stream,stderr=subprocess.STDOUT)
    if not (out/'guard_result.json').exists():raise SystemExit('guard receipt absent; preserve wrapper evidence')
    g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace')
    result={'category':cat,'stage':stage,'guard':g,'guard_wrapper_exit':rc,'driver_sha256':m.sha(out/'driver.log')}
    if stage=='validate':
        v=work/'driver_replay_validation.json';ok=rc==0 and v.exists() and json.loads(v.read_text())['verdict']=='PASS'
        result.update(verdict='PASS' if ok else 'COST_STOP' if g.get('trigger') else 'FAIL',watchdog_replay_validation=m.identify(v) if v.exists() else None)
    else:
        inner_path=work/'segment_driver_receipt.json';inner=json.loads(inner_path.read_text()) if inner_path.exists() else None
        sem=lambda s:[x for x in s.splitlines() if re.match(r'^(?:M007_|HARDWARE_AGENT_SIM_PASS)',x)]
        actual=sem(log);prior=sem(Path(cfg['baseline_log']).read_text(errors='replace'));export=next(x.split('=',1)[1] for x in cfg['plusargs'] if x.startswith('+EXPORT='))
        norm=lambda lines,path:[s.replace(' prefix='+path,' prefix=<OWNED_EXPORT>') if s.startswith('M007_ACTUAL_PUBLIC_CAPTURE ') else s for s in lines]
        na=norm(actual,export);nb=norm(prior,cfg['baseline_export']);qualified=bool(nb) and na[:len(nb)]==nb
        fatal=bool(re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b',log));terminal=actual.count(contract['exact_terminal'])==1;complete_count=sum(s.startswith('M007_FULLMODEL_ENCODER0_COMPLETE_PASS ') for s in actual)
        ok=rc==0 and not g.get('trigger') and inner is not None and inner['verdict']=='PASS' and terminal and complete_count==1 and not fatal and qualified
        cost=bool(g.get('trigger')) or (inner is not None and inner['verdict']=='COST_STOP')
        result.update(verdict='PASS' if ok else 'COST_STOP' if cost else 'FAIL',required_marker=contract['exact_terminal'],exact_marker_found=terminal,original_complete_pass_count=complete_count,error_or_fatal=fatal,segment_driver_receipt=inner,wall_events=m.identify(work/'wall_events.jsonl') if (work/'wall_events.jsonl').exists() else None,baseline_comparison={'baseline_prefix_only':True,'actual_line_count':len(actual),'baseline_line_count':len(prior),'qualified_equal':qualified,'normalized_actual_semantic_lines':na,'normalized_baseline_semantic_lines':nb,'only_normalized_field':'registered M007_ACTUAL_PUBLIC_CAPTURE EXPORT prefix'},two_state_limitation=True,not_30_layer_validation=True)
    m.dump(at/('receipt_'+stage+'.json'),result)
    print(json.dumps({'stage':stage,'verdict':result['verdict'],'elapsed_seconds':g['elapsed_seconds'],'trigger':g.get('trigger'),'segment_reason':result.get('segment_driver_receipt',{}).get('reason') if result.get('segment_driver_receipt') else None}),flush=True)
    return result['verdict']=='PASS'

with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
    print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
    for manifest_path in [at/'source_manifest.json',at/'runtime_build_manifest.json']:
        for x in json.loads(manifest_path.read_text())['sources_and_inputs']:
            if m.sha(Path(x['path']))!=x['sha256']:raise SystemExit('frozen identity changed '+x['path'])
    if a.stage in ['validate','all'] and not execute('validate'):raise SystemExit(1)
    if a.stage in ['rtl','all'] and not execute('rtl'):raise SystemExit(1)
