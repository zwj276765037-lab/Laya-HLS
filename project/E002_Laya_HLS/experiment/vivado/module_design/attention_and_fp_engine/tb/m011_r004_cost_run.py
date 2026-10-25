#!/usr/bin/env python3
"""Known-cost Encoder one-head run; existing immutable compiled closure unchanged."""
import argparse,datetime,fcntl,json,math,re,shutil,subprocess,sys
from pathlib import Path
import m011_r004_run as b

def main():
 p=argparse.ArgumentParser();p.add_argument('attempt');p.add_argument('--build-at',required=True);p.add_argument('--head-at',required=True);p.add_argument('--prep-at',required=True);p.add_argument('--case',choices=['encoder0','encoder1'],default='encoder0');a=p.parse_args();assert re.fullmatch('AT[0-9]{3}_[A-Za-z0-9_]+',a.attempt)
 with(b.ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=b.RUN/'attempts'/a.attempt;f=at/'frozen';w=at/'work';f.mkdir(parents=True,exist_ok=True);w.mkdir(exist_ok=True);build=b.RUN/'attempts'/a.build_at;head=b.RUN/'attempts'/a.head_at;prep=b.RUN/'attempts'/a.prep_at
  assert json.loads((build/'receipt_static.json').read_text())['verdict']=='PASS';assert b.sha(Path(b.__file__))==b.sha(build/'frozen'/Path(b.__file__).name),'original build runner identity changed'
  hx=json.loads((head/'receipt_rtl.json').read_text());px=json.loads((prep/'receipt_rtl.json').read_text());assert hx['verdict']=='PASS'and px['verdict']=='PASS'and hx['build_at']==px['build_at']==a.build_at and not hx['prep_only']and px['prep_only']and px['case']==a.case
  samples=[]
  for rp in sorted((b.RUN/'attempts').glob('AT*/receipt_rtl.json')):
   x=json.loads(rp.read_text())
   if x.get('build_at')!=a.build_at or x['verdict']not in('PASS','COST_STOP')or x.get('error_or_fatal')or x.get('compiled_products_unchanged')is not True:continue
   ep=rp.parent/'work/wall_events.json'
   if not ep.exists():continue
   es=json.loads(ep.read_text())['events'];beg={e['head']:e['elapsed_seconds']for e in es if e.get('kind')=='begin'}
   for e in es:
    if e.get('kind')=='end'and all(t in e['line']for t in('score=16384','prob=16384','context=8192','qk=','sm=','av=')):
     samples.append({'attempt':rp.parent.name,'head':e['head'],'seconds':e['elapsed_seconds']-beg[e['head']]})
  assert any(x['attempt']==a.head_at for x in samples),'actual complete head event missing';pr=next(e['elapsed_seconds']for e in json.loads((prep/'work/wall_events.json').read_text())['events']if e.get('kind')=='begin');hc=max(s['seconds']for s in samples);limit=math.ceil(1.3*(pr+hc)+2);gate={'formula':'ceil(1.3*(actual same-build Encoder preparation+max all known same-build complete normal heads)+2sec process margin)','preparation_seconds':pr,'head_seconds':hc,'complete_samples':samples,'cap_seconds':limit,'head_receipt_sha256':b.sha(head/'receipt_rtl.json'),'prep_receipt_sha256':b.sha(prep/'receipt_rtl.json'),'scope':'Different Encoder complete-one-head boundary; no full16 admission','compiled_SV_TB_and_original_build_runner_unchanged':True,'new_run_control_source_sha256':b.sha(Path(__file__))};b.dump(at/'one_head_cost_gate.json',gate)
  costs=b.ledger();assert limit<=1200 and costs['rtl']+limit+240<=3000,'COST_STOP gate/reserve; no RTL launched'
  for q in(build/'frozen').iterdir():
   if q.is_file():shutil.copy2(q,f/q.name)
  shutil.copy2(Path(__file__),f/Path(__file__).name);shutil.copytree(build/'work/xsim.dir',w/'xsim.dir');shutil.copy2(build/'artifacts_after_build.json',at/'artifacts_after_build.json')
  if(build/'work/xsim.ini').exists():shutil.copy2(build/'work/xsim.ini',w/'xsim.ini')
  for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
  b.dump(at/'source_manifest.json',{'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'same immutable AT008 compiled SV/TB closure; new explicit measured-cost run control only','build_at':a.build_at,'build_manifest_sha256':b.sha(build/'source_manifest.json'),'original_build_runner_sha256':b.sha(Path(b.__file__)),'cost_runner_sha256':b.sha(Path(__file__))})
  cmd=[sys.executable,str(f/'m011_xsim_wall_driver.py'),'--out',str(w/'wall_events.json'),'--',str(b.VIV/'xsim'),'m011_r004_layer_sim','-runall','-testplusarg','DATA='+str(f),'-testplusarg','CASE='+a.case,'-testplusarg','PILOT_HEADS=1','-testplusarg','PREP_ONLY=0'];out=at/'guard_rtl';assert not out.exists();argv=[sys.executable,str(b.GUARD),'--out',str(out),'--cwd',str(w),'--rss-gib','8','--timeout-seconds',str(limit),'--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',*cmd];b.dump(at/'command_rtl.json',{'argv':argv,'lock':'m007_heavy.lock through descendants','cost_gate':gate,'recovery_reserve_seconds':240})
  before=b.artifacts(at,w,'before_rtl');assert before==json.loads((build/'artifacts_after_build.json').read_text())['immutable_compiled_products'];rc=subprocess.call(argv,cwd=w);after=b.artifacts(at,w,'after_rtl');g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:Fatal|FATAL|ERROR)\s*[:\[]',log));marker='HARDWARE_AGENT_SIM_PASS M011_LAYER_PILOT';ok=rc==0 and not fatal and before==after and marker in log
  b.dump(at/'receipt_rtl.json',{'verdict':'PASS'if ok else'COST_STOP'if g.get('trigger')else'FAIL','guard':g,'wrapper_exit':rc,'error_or_fatal':fatal,'compiled_products_unchanged':before==after,'build_at':a.build_at,'case':a.case,'prep_only':False,'pilot_heads':1,'marker':marker,'marker_found':marker in log,'log_sha256':b.sha(out/'driver.log'),'cost_gate':gate});b.ledger();print('rtl',json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
