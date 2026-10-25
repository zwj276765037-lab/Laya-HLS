#!/usr/bin/env python3
"""Run one newly authorized true kind7 unknown pilot without expanding its120s cap."""
import argparse,fcntl,importlib.util,json,os,subprocess,sys,time
from pathlib import Path
here=Path(__file__).resolve().parent;spec=importlib.util.spec_from_file_location('r002',here/'fullgraph_run_r002.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
p=argparse.ArgumentParser();p.add_argument('attempt');a=p.parse_args();at=m.RUN/'attempts'/a.attempt;work=at/'work';cfg=json.loads((at/'config.json').read_text());exe=work/'obj'/('V'+cfg['top']);out=at/'guard_rtl';pre=time.monotonic()
if out.exists():raise SystemExit('preserve previous pilot; no automatic extension')
if m.budget()['rtl']+120>6600:raise SystemExit('independent R002 reserve gate')
for x in json.loads((at/'source_manifest.json').read_text())['sources_and_inputs']:
 if m.sha(Path(x['path']))!=x['sha256']:raise SystemExit('source/input changed '+x['path'])
br=json.loads((at/'receipt_build.json').read_text())
if br['verdict']!='PASS' or m.sha(exe)!=br['executable']['sha256']:raise SystemExit('actual successful fixed-runtime exe required')
if cfg['top']!='m007_fullgraph_binary_tb' or '+KIND=7' not in cfg['plusargs'] or '+LAYER=0' not in cfg['plusargs'] or any('STOP_' in z for z in cfg['plusargs']):raise SystemExit('original once-BEGIN all30 kind7 controls required')
gtest=m.RUN/'attempts/AT001_fullgraph_kind7/receipt_progress_tests.json';test=json.loads(gtest.read_text());guard=Path(cfg['guard_path'])
if test['verdict']!='PASS' or m.sha(guard)!=test['guard_identity']['sha256']:raise SystemExit('actual same-guard branch test required')
driver=here/'fullgraph_pilot_driver.py';cmd=[sys.executable,str(driver),'--events',str(work/'wall_events.jsonl'),'--receipt',str(work/'pilot_driver_receipt.json'),'--seconds','119','--guard-module',str(guard),'--',str(exe),*cfg['plusargs']]
argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','8','--timeout-seconds','120','--semantic-stall-seconds','120','--phase','rtl','--',*cmd];m.dump(at/'rtl_execution_identity.json',{'executable':m.identify(exe),'build_receipt':m.identify(at/'receipt_build.json'),'config':m.identify(at/'config.json'),'source_manifest':m.identify(at/'source_manifest.json'),'guard':m.identify(guard),'driver':m.identify(driver),'launcher':m.identify(Path(__file__)),'guard_branch_test':m.identify(gtest),'runtime_identity':cfg['runtime_identity'],'preflight_measured_seconds':time.monotonic()-pre,'not_full_run_authorization':True});m.dump(at/'command_rtl.json',{'category':'rtl','argv':argv,'budget_before_seconds':m.budget(),'cap_seconds':120,'inner_child_cap119_with_cleanup_margin':True})
env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
 with (at/'rtl_wrapper.log').open('w') as stream:rc=subprocess.call(argv,cwd=work,env=env,stdout=stream,stderr=subprocess.STDOUT)
g=json.loads((out/'guard_result.json').read_text());ip=work/'pilot_driver_receipt.json';inner=json.loads(ip.read_text()) if ip.exists() else None;ok=rc==0 and not g.get('trigger') and inner and inner['verdict']=='PASS';cost=bool(g.get('trigger')) or (inner and inner['verdict']=='COST_STOP');x={'category':'rtl','stage':'unknown_kind7_pilot','verdict':'PASS' if ok else 'COST_STOP' if cost else 'FAIL','guard':g,'guard_wrapper_exit':rc,'pilot_driver_receipt':inner,'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','two_state_limitation':True,'fullgraph_complete':bool(ok),'original_28_plus_2_once_BEGIN':True};m.dump(at/'receipt_rtl.json',x);print(json.dumps({'verdict':x['verdict'],'elapsed_seconds':g['elapsed_seconds'],'trigger':g.get('trigger'),'reason':inner['reason'] if inner else 'inner receipt unavailable'}),flush=True);raise SystemExit(0 if ok else 124 if cost else 1)
