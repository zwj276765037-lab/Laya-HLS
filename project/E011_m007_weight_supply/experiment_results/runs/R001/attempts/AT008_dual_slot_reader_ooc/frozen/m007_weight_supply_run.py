#!/usr/bin/env python3
"""E011 runner: one lock, frozen inputs, existing process guard, independent log verdict."""
import argparse,datetime as dt,fcntl,hashlib,json,os,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E011_m007_weight_supply/experiment_results/runs/R001'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl','ooc']);p.add_argument('attempt');p.add_argument('--fixture',type=Path);p.add_argument('--build',type=Path);p.add_argument('--timeout',type=int,default=120);a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt):p.error('ATnnn_name required')
 category={'reference':'reference','build':'static','rtl':'rtl','ooc':'ooc'}[a.stage];caps={'reference':600,'static':1800,'rtl':1800,'ooc':600}
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  used={x:0.0 for x in caps}
  for rp in (RUN/'attempts').glob('*/receipt.json'):
   r=json.loads(rp.read_text());used[r['category']]+=r.get('wall_s',0)
  if a.timeout>min(1200 if category=='rtl' else 600,caps[category]-used[category]):raise RuntimeError('budget exceeded')
  at=RUN/'attempts'/a.attempt
  if at.exists():raise RuntimeError('preserve previous attempt')
  frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True);work.mkdir()
  sources=[Path(__file__),GUARD,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',ROOT/'project/E002_Laya_HLS/experiment/tools/m007_weight_pack.py',ROOT/'source/m007_matrix_supply_map_20261021.json']+list((MOD/'rtl').glob('laya_m007_w*.sv'))+list((MOD/'tb').glob('m007_weight*.sv'))+list((MOD/'tb').glob('m007_weight*.tcl'))
  for src in sources:shutil.copy2(src,frozen/src.name)
  dump(at/'source_manifest.json',{'time':dt.datetime.now(dt.timezone.utc).isoformat(),'hostname':os.uname().nodename,'requested_model':'gpt-6.1-sol','requested_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','sources':[{'path':str(x),'frozen':x.name,'sha256':sha(x),'bytes':x.stat().st_size} for x in sources]})
  if a.stage=='reference':cmd=[sys.executable,str(frozen/'m007_weight_pack.py'),'--map',str(frozen/'m007_matrix_supply_map_20261021.json'),'--out',str(work/'fixtures')];marker='M007_WEIGHT_PACK_PASS'
  elif a.stage=='build':
   script=work/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(x) for x in frozen.glob('*.sv'))+'\n'+str(VIV/'xelab')+' work.m007_weight_supply_tb --relax -mt 4 --O3 -s m007_weight_supply_sim\n');cmd=['/bin/bash',str(script)];marker=None
  elif a.stage=='rtl':
   if not a.fixture or not a.build:p.error('--fixture and --build required')
   fixture=a.fixture.resolve();build=a.build.resolve()
   for hdl in frozen.glob('*.sv'):
    if sha(hdl)!=sha(build/'frozen'/hdl.name):raise RuntimeError('current HDL does not match compiled closure: '+hdl.name)
   shutil.copytree(build/'work/xsim.dir',work/'xsim.dir')
   for f in (build/'work').glob('*.so'):shutil.copy2(f,work/f.name)
   dump(at/'fixture_identity.json',{'build':str(build),'build_source_manifest_sha256':sha(build/'source_manifest.json'),'snapshot_files':[{'path':str(x.relative_to(work)),'sha256':sha(x),'bytes':x.stat().st_size} for x in (work/'xsim.dir').rglob('*') if x.is_file()],'fixture':str(fixture),'files':[{'path':str(x),'sha256':sha(x)} for x in fixture.rglob('*') if x.is_file()]})
   cmd=[str(VIV/'xsim'),'m007_weight_supply_sim','-runall','-testplusarg','FIXTURE='+str(fixture)];marker='HARDWARE_AGENT_SIM_PASS M007_WEIGHT_SUPPLY'
  else:cmd=[str(VIV/'vivado'),'-mode','batch','-source',str(frozen/'m007_weight_supply_ooc.tcl'),'-tclargs',str(at)];marker='M007_WEIGHT_SUPPLY_OOC_PASS'
  guardcmd=[sys.executable,str(GUARD),'--out',str(at/'guard'),'--cwd',str(work),'--rss-gib',str({'reference':16,'static':24,'rtl':8,'ooc':24}[category]),'--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd]
  dump(at/'command.json',{'argv':guardcmd,'lock_held_through_children':True,'used_before_s':used,'stage':category})
  rc=subprocess.call(guardcmd,cwd=work);result=json.loads((at/'guard/guard_result.json').read_text()) if (at/'guard/guard_result.json').exists() else {}
  log=(at/'guard/driver.log').read_text(errors='replace') if (at/'guard/driver.log').exists() else ''
  fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));ok=rc==0 and not fatal and (not marker or marker in log)
  wall=result.get('elapsed_seconds',result.get('wall_seconds',result.get('wall_s',0)))
  dump(at/'receipt.json',{'category':category,'guard':result,'wall_s':wall,'guard_exit':rc,'error_or_fatal':fatal,'required_marker':marker,'marker_found':marker in log if marker else None,'verdict':'PASS' if ok else ('COST_STOP' if result.get('trigger') else 'FAIL'),'driver_sha256':sha(at/'guard/driver.log')})
  used[category]+=wall
  dump(RUN/'budget_ledger.json',{'limits_s':caps,'used_s':used,'remaining_s':{k:caps[k]-used[k] for k in caps},'latest_receipt':str(at/'receipt.json')})
  for line in log.splitlines():
   if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line:print(line,flush=True)
  print(json.dumps(result),flush=True);return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
