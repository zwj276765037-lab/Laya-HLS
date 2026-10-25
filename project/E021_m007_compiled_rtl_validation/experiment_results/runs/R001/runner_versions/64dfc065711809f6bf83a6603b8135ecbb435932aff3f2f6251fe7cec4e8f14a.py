#!/usr/bin/env python3
"""D33: same-source Verilator cross-checks; no RTL/reference substitutions."""
import argparse, datetime as dt, fcntl, hashlib, json, os, re, shlex, subprocess, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R001'
MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
E8=ROOT/'project/E008_m007_strict_fp_shared_service/experiment_results/runs/R001/attempts'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py'
KIT=Path('/home/user/EDA-202/zhuowenjun/.local-tools/verilator-5.020')
VER=KIT/'usr/bin/verilator'
VROOT=KIT/'usr/share/verilator'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def dump(p,v):p.write_text(json.dumps(v,indent=2,sort_keys=True)+'\n')
def identify(p):return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def budget():
 totals={'static':0.0,'rtl':0.0}
 for p in RUN.glob('attempts/AT*/receipt_*.json'):
  x=json.loads(p.read_text());cat=x.get('category');g=x.get('guard',{})
  if cat in totals:totals[cat]+=g.get('elapsed_seconds',0)
 return totals
def small_config(case):
 kind={'add':'fadd','mul':'fmul','div':'fdiv'}.get(case)
 if kind:
  ref,old={'add':('AT001_native_reference_pilot','AT002_strict_add8_rtl_pilot'),'mul':('AT015_strict_mul_native_reference','AT016_strict_mul8_rtl_pilot'),'div':('AT010_direct_div_reference','AT012_direct_div32_rtl_pilot')}[case]
  fixture=E8/ref/'work/vectors.hex'; count=json.loads((E8/ref/'fixture_identity.json').read_text())['count']
  return {'case':case,'top':f'm007_{kind}_rne_tb','sources':[str(MOD/f'rtl/laya_{kind}_rne_v1.sv'),str(MOD/f'tb/m007_{kind}_rne_tb.sv')],'inputs':[str(fixture)],'plusargs':[f'+VECTORS={fixture}',f'+COUNT={count}'],'marker':f'HARDWARE_AGENT_SIM_PASS {kind.upper()}_RNE','baseline_log':str(E8/old/'guard_rtl/driver.log'),'baseline_manifest':str(E8/old/'source_manifest.json')}
 if case=='shared4':
  fixture=E8/'AT019_shared_strict4_regression/work/vectors.hex'
  return {'case':case,'top':'m007_shared_fp4_tb','sources':[str(MOD/'rtl'/n) for n in ['laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv','laya_fp_return_credit_v1.sv','laya_shared_fp256_v2.sv']]+[str(MOD/'tb/m007_shared_fp4_tb.sv')],'inputs':[str(fixture)],'plusargs':[f'+VECTORS={fixture}'],'marker':'HARDWARE_AGENT_SIM_PASS SHARED_FP4','baseline_log':str(E8/'AT019_shared_strict4_regression/guard_rtl/driver.log')}
 raise ValueError(case)
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['prepare','translate','build','rtl']);p.add_argument('attempt');p.add_argument('--case',choices=['add','mul','div','shared4']);p.add_argument('--config',type=Path);p.add_argument('--timeout',type=int,default=120);p.add_argument('--targets',nargs='*');a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt):p.error('stable AT required')
 if a.timeout>120 or a.timeout<1:p.error('unknown stage cap is 120 seconds')
 at=RUN/'attempts'/a.attempt;work=at/'work';obj=work/'obj'
 if a.stage=='prepare':
  if (at/'config.json').exists():raise RuntimeError('preserve existing attempt')
  at.mkdir(parents=True,exist_ok=True);work.mkdir(exist_ok=True)
  cfg=json.loads(a.config.read_text()) if a.config else small_config(a.case)
  cfg['output_split']=cfg.get('output_split',10000);cfg['output_split_cfuncs']=cfg.get('output_split_cfuncs',200)
  dump(at/'config.json',cfg)
  guard_path=Path(cfg.get('guard_path',str(GUARD)))
  (at/'frozen_runner.py').write_bytes(Path(__file__).read_bytes())
  paths=[Path(x) for x in cfg['sources']+cfg.get('inputs',[])]+[Path(__file__),at/'frozen_runner.py',guard_path,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',VER,VROOT/'include/verilated.mk',HERE/'cxx_record.py']
  dump(at/'source_manifest.json',{'utc':dt.datetime.now(dt.timezone.utc).isoformat(),'sources_and_inputs':[identify(x) for x in paths],'hostname':os.uname().nodename,'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','expected_model':'gpt-6.1-sol','expected_effort':'xhigh','two_state_limit':'Cannot replace XSim 4-state/X-propagation or uninitialized checks','source_copy_or_rewrite':False})
  print('PREPARED',a.attempt,flush=True);return 0
 cfg=json.loads((at/'config.json').read_text())
 for x in json.loads((at/'source_manifest.json').read_text())['sources_and_inputs']:
  if sha(Path(x['path']))!=x['sha256']:raise RuntimeError('Frozen identity changed '+x['path'])
 cat='rtl' if a.stage=='rtl' else 'static';spent=budget()
 if spent[cat]+a.timeout>1800-(300 if cat=='rtl' else 0):raise RuntimeError('D33 budget/reserve preflight')
 tag=a.stage+(('_targets_'+hashlib.sha256('\0'.join(a.targets).encode()).hexdigest()[:12]) if a.targets else '')
 out=at/('guard_'+tag)
 if out.exists():raise RuntimeError('Preserve prior guard, choose new attempt/stage targets')
 if a.stage=='translate':
  cmd=[str(VER),'--cc','--main','--exe','--timing','--assert','-O3','-Wno-fatal','--output-split',str(cfg['output_split']),'--output-split-cfuncs',str(cfg['output_split_cfuncs']),'--top-module',cfg['top'],'--Mdir',str(obj),*cfg.get('verilator_flags',[]),*cfg['sources']]
 elif a.stage=='build':
  cmd=['/usr/bin/make','-C',str(obj),'-f','V'+cfg['top']+'.mk','-j4','OPT_FAST='+cfg.get('cxx_opt_fast','-O2'),'OPT_SLOW='+cfg.get('cxx_opt_slow','-O1')]
  if cfg.get('record_cxx_units',False):cmd+=['CXX='+shlex.join([sys.executable,str(HERE/'cxx_record.py'),'--records',str(at/'cxx_units')])]
  cmd+=a.targets or []
 else:cmd=[str(obj/('V'+cfg['top'])),*cfg.get('plusargs',[])]
 guard_path=Path(cfg.get('guard_path',str(GUARD)))
 guardcmd=[sys.executable,str(guard_path),'--out',str(out),'--cwd',str(work),'--rss-gib','8' if cat=='rtl' else '24','--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120']
 if cfg.get('guard_phase_option',False):guardcmd+=['--phase',cat]
 if cat=='static':guardcmd+=['--artifact-progress-root',str(work)]
 guardcmd+=['--',*cmd]
 dump(at/('command_'+tag+'.json'),{'category':cat,'argv':guardcmd,'cwd':str(work),'environment':{'VERILATOR_ROOT':str(VROOT)},'budget_before_seconds':spent,'lock':str(ROOT/'.research-agent/m007_heavy.lock'),'held_through_all_owned_descendants':True})
 env=os.environ.copy();env['VERILATOR_ROOT']=str(VROOT)
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  rc=subprocess.call(guardcmd,cwd=work,env=env)
  g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace')
  marker=cfg['marker'] if cat=='rtl' else None
  ok=rc==0 and (not marker or marker in log) and not re.search(r'(?m)^%Error|%Error:|Assertion failed|\bAborting\b',log)
  baseline=Path(cfg.get('baseline_log',''))
  pattern=cfg.get('semantic_pattern',r'^(?:FADD_|FMUL_|FDIV_|SHARED_|FP4_|HARDWARE_AGENT_SIM_PASS)')
  sem=lambda s:[x for x in s.splitlines() if re.match(pattern,x)]
  actual=sem(log);prior=sem(baseline.read_text(errors='replace')) if baseline.is_file() else []
  def artifact_path_map(lines,path):
   if not path:return lines
   return [line.replace(' prefix='+path,' prefix=<OWNED_EXPORT>') if line.startswith('M007_ACTUAL_PUBLIC_CAPTURE ') else line for line in lines]
  export=next((x.split('=',1)[1] for x in cfg.get('plusargs',[]) if x.startswith('+EXPORT=')),None)
  norm_actual=artifact_path_map(actual,export);norm_prior=artifact_path_map(prior,cfg.get('baseline_export'))
  comparison={'actual_semantic_lines':actual,'baseline_semantic_lines':prior,'exact_equal':bool(actual) and bool(prior) and actual==prior,'semantic_pattern':pattern,'nonempty':bool(actual) and bool(prior),'qualified_equal':bool(actual) and bool(prior) and norm_actual==norm_prior,'normalized_actual_semantic_lines':norm_actual,'normalized_baseline_semantic_lines':norm_prior,'artifact_path_mapping':{'actual_export':export,'baseline_export':cfg.get('baseline_export'),'only_field':'M007_ACTUAL_PUBLIC_CAPTURE prefix; no cycle/count/data normalization'}} if cat=='rtl' else None
  result={'category':cat,'stage':tag,'verdict':'PASS' if ok else ('COST_STOP' if g.get('trigger') else 'FAIL'),'guard':g,'guard_wrapper_exit':rc,'required_marker':marker,'marker_found':marker in log if marker else None,'driver_sha256':sha(out/'driver.log'),'warnings':[x for x in log.splitlines() if x.startswith('%Warning')],'two_state_limitation':True,'baseline_comparison':comparison}
  if a.stage=='build':result['completed_objects']=[identify(x) for x in sorted(obj.glob('*.o'))];result['executable']=identify(obj/('V'+cfg['top'])) if (obj/('V'+cfg['top'])).exists() else None
  if cat=='rtl' and cfg.get('require_exact_semantics',False) and not comparison['qualified_equal']:
   ok=False;result['verdict']='FAIL';result['semantic_crosscheck_failure']=True
  dump(at/('receipt_'+tag+'.json'),result)
  print(json.dumps({'attempt':a.attempt,'stage':tag,'verdict':result['verdict'],'elapsed_seconds':g['elapsed_seconds'],'trigger':g.get('trigger'),'baseline_equal':comparison['exact_equal'] if comparison else None}),flush=True)
  for line in log.splitlines():
   if '_PASS' in line or '%Error' in line or 'Assertion failed' in line:print(line,flush=True)
 return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
