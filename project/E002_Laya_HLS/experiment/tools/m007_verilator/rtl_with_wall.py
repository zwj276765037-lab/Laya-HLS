#!/usr/bin/env python3
"""D33 strict RTL execution with complete semantic comparison and real wall events."""
import argparse,fcntl,hashlib,importlib.util,json,os,re,subprocess,sys
from pathlib import Path
here=Path(__file__).resolve().parent;spec=importlib.util.spec_from_file_location('d33_config',here/'run.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
p=argparse.ArgumentParser();p.add_argument('attempt');p.add_argument('--timeout',type=int,default=120);a=p.parse_args()
if not re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt) or not 1<=a.timeout<=120:p.error('stable AT and unknown RTL cap<=120 required')
at=m.RUN/'attempts'/a.attempt;cfg=json.loads((at/'config.json').read_text());work=at/'work';out=at/'guard_rtl'
if out.exists() or (at/'receipt_rtl.json').exists():raise SystemExit('preserve prior execution')
for x in json.loads((at/'source_manifest.json').read_text())['sources_and_inputs']:
 if m.sha(Path(x['path']))!=x['sha256']:raise SystemExit('frozen identity changed '+x['path'])
runtime_manifest=at/'runtime_build_manifest.json';runtime_identity=None
if runtime_manifest.exists():
 runtime_data=json.loads(runtime_manifest.read_text());runtime_identity=runtime_data['runtime_identity']
 for x in runtime_data['sources_and_inputs']:
  if m.sha(Path(x['path']))!=x['sha256']:raise SystemExit('runtime build identity changed '+x['path'])
spent=m.budget()
if spent['rtl']+a.timeout>1500:raise SystemExit('D33 RTL reserve/budget preflight')
exe=work/'obj'/('V'+cfg['top']);wall=here/'wall_events.py';guard=Path(cfg.get('guard_path',str(m.GUARD)));events=work/'wall_events.jsonl';cmd=[sys.executable,str(wall),'--events',str(events),'--',str(exe),*cfg['plusargs']];argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','8','--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120']
build_receipt=Path(cfg.get('successful_build_receipt',str(at/'receipt_build.json')))
if build_receipt.exists():
 br=json.loads(build_receipt.read_text())
 if br['verdict']!='PASS' or br['executable']['sha256']!=m.sha(exe):raise SystemExit('actual successful executable identity required')
if cfg.get('guard_phase_option',False):argv+=['--phase','rtl']
argv+=['--',*cmd];m.dump(at/'command_rtl.json',{'category':'rtl','argv':argv,'budget_before_seconds':spent,'environment':{'VERILATOR_ROOT':str(m.VROOT),'PYTHONPATH_project_prefix':str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')},'lock':str(m.ROOT/'.research-agent/m007_heavy.lock'),'wall_clock_basis':'monotonic real receipt of original RTL stdout; original lines forwarded unchanged; JSONL append avoids rewriting event history'})
m.dump(at/'rtl_execution_identity.json',{'runtime_helpers':[m.identify(Path(__file__)),m.identify(wall),m.identify(here/'run.py'),m.identify(guard)],'config':m.identify(at/'config.json'),'source_manifest':m.identify(at/'source_manifest.json'),'executable':m.identify(exe),'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','two_state_not_four_state':True})
if runtime_identity:m.dump(at/'runtime_execution_identity.json',{'runtime_identity':runtime_identity,'runtime_build_manifest':m.identify(runtime_manifest),'actual_executable':m.identify(exe),'successful_build_receipt':m.identify(build_receipt)})
env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')+(os.pathsep+env['PYTHONPATH'] if env.get('PYTHONPATH') else '')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
 with (at/'rtl_guard_wrapper.log').open('w') as wrapper:rc=subprocess.call(argv,cwd=work,env=env,stdout=wrapper,stderr=subprocess.STDOUT)
 if not (out/'guard_result.json').exists():raise SystemExit('guard result absent; preserve wrapper log')
 g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');pattern=cfg.get('semantic_pattern',r'^(?:M007_|HARDWARE_AGENT_SIM_PASS)');sem=lambda s:[line for line in s.splitlines() if re.match(pattern,line)];actual=sem(log);base=Path(cfg['baseline_log']);prior=sem(base.read_text(errors='replace'));export=next((x.split('=',1)[1] for x in cfg['plusargs'] if x.startswith('+EXPORT=')),None)
 def normalize(lines,path):return [line.replace(' prefix='+path,' prefix=<OWNED_EXPORT>') if path and line.startswith('M007_ACTUAL_PUBLIC_CAPTURE ') else line for line in lines]
 na=normalize(actual,export);nb=normalize(prior,cfg.get('baseline_export'));prefix=cfg.get('baseline_prefix_only',False);qualified=bool(na) and bool(nb) and (na[:len(nb)]==nb if prefix else na==nb);marker=cfg['marker'];fatal=bool(re.search(r'%Error|Assertion failed|\bAborting\b',log));ok=rc==0 and marker in log and not fatal and (not cfg.get('require_exact_semantics',True) or qualified)
 comparison={'baseline_prefix_only':prefix,'actual_line_count':len(actual),'baseline_line_count':len(prior),'nonempty':bool(actual) and bool(prior),'exact_equal':actual==prior and bool(actual) and bool(prior),'qualified_equal':qualified,'actual_semantic_lines':actual,'baseline_semantic_lines':prior,'normalized_actual_semantic_lines':na,'normalized_baseline_semantic_lines':nb,'uncompared_actual_suffix_lines':len(actual)-len(prior) if prefix else 0,'artifact_path_mapping':{'actual_export':export,'baseline_export':cfg.get('baseline_export'),'only_field':'M007_ACTUAL_PUBLIC_CAPTURE prefix; no data/cycle/count normalization'}}
 result={'category':'rtl','stage':'rtl','verdict':'PASS' if ok else ('COST_STOP' if g.get('trigger') else 'FAIL'),'guard':g,'guard_wrapper_exit':rc,'required_marker':marker,'marker_found':marker in log,'error_or_fatal':fatal,'driver_sha256':m.sha(out/'driver.log'),'baseline_comparison':comparison,'wall_events':m.identify(events) if events.exists() else None,'two_state_limitation':True};m.dump(at/'receipt_rtl.json',result);print(json.dumps({'attempt':a.attempt,'verdict':result['verdict'],'elapsed_seconds':g['elapsed_seconds'],'marker_found':result['marker_found'],'qualified_prefix_equal':qualified,'actual_event_count':len(actual),'baseline_event_count':len(prior),'trigger':g.get('trigger')}),flush=True)
 for line in log.splitlines():
  if '_PASS' in line or '%Error' in line or 'Assertion failed' in line:print(line,flush=True)
raise SystemExit(0 if ok else 1)
