#!/usr/bin/env python3
import argparse,datetime as dt,fcntl,hashlib,json,os,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R001'
GUARD=MOD/'tm1tn8_gs32_512/tb/production_guard.py';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl','ooc']);p.add_argument('attempt');p.add_argument('--test',choices=['leaf','dot','a','matrix'],default='leaf');p.add_argument('--fixture',type=Path);p.add_argument('--build',type=Path);p.add_argument('--timeout',type=int,default=120);a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt):p.error('ATnnn_name required')
 caps={'reference':900,'static':1800,'rtl':2400,'ooc':900}
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  used={k:0.0 for k in caps}
  for rp in (RUN/'attempts').glob('*/receipt_*.json'):
   r=json.loads(rp.read_text());used[r['category']]+=r['wall_s']
  at=RUN/'attempts'/a.attempt
  if at.exists():raise RuntimeError('preserve old attempts')
  frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True);work.mkdir()
  sources=[Path(__file__),GUARD,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',MOD/'tb/m007_matrix_reference.cpp']+list((MOD/'rtl').glob('laya_m007_*.sv'))+list((MOD/'tb').glob('m007_matrix*.sv'))+list((MOD/'tb').glob('m007_matrix*.tcl'))+[MOD/'tm1tn8_gs32_512/rtl'/x for x in ['tm1tn8_integer_tree_packed.sv','tm1tn8_signed_pack_pair.sv']]
  for src in sources:shutil.copy2(src,frozen/src.name)
  dump(at/'source_manifest.json',{'time':dt.datetime.now(dt.timezone.utc).isoformat(),'hostname':os.uname().nodename,'requested_model':'gpt-6.1-sol','requested_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','sources':[{'path':str(x),'frozen':x.name,'sha256':sha(x),'bytes':x.stat().st_size} for x in sources]})
  if a.stage=='reference':
   (work/'fixture').mkdir();commands=[('static',24,['/usr/bin/g++','-O2','-std=c++17','-fno-fast-math','-frounding-math','-ffp-contract=off',str(frozen/'m007_matrix_reference.cpp'),'-o',str(work/'reference')],None),('reference',16,[str(work/'reference'),str(work/'fixture')],'M007_MATRIX_REFERENCE_PASS')]
  elif a.stage=='build':
   script=work/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(x) for x in frozen.glob('*.sv'))+'\n'+str(VIV/'xelab')+' work.m007_matrix_'+a.test+'_tb --relax -mt 4 --O3 -s m007_matrix_'+a.test+'_sim\n');commands=[('static',24,['/bin/bash',str(script)],None)]
  elif a.stage=='rtl':
   if not a.fixture or not a.build:p.error('fixture/build required')
   fixture=a.fixture.resolve();build=a.build.resolve()
   for hdl in frozen.glob('*.sv'):
    if not (build/'frozen'/hdl.name).exists() or sha(hdl)!=sha(build/'frozen'/hdl.name):raise RuntimeError('compiled closure mismatch '+hdl.name)
   shutil.copytree(build/'work/xsim.dir',work/'xsim.dir')
   dump(at/'fixture_identity.json',{'build':str(build),'build_source_manifest_sha256':sha(build/'source_manifest.json'),'fixture':str(fixture),'files':[{'path':str(x),'sha256':sha(x),'bytes':x.stat().st_size} for x in fixture.rglob('*') if x.is_file()],'snapshot_files':[{'path':str(x.relative_to(work)),'sha256':sha(x),'bytes':x.stat().st_size} for x in (work/'xsim.dir').rglob('*') if x.is_file()]})
   commands=[('rtl',8,[str(VIV/'xsim'),'m007_matrix_'+a.test+'_sim','-runall','-testplusarg','FIXTURE='+str(fixture)],'HARDWARE_AGENT_SIM_PASS M007_MATRIX_'+a.test.upper())]
  else:commands=[('ooc',24,[str(VIV/'vivado'),'-mode','batch','-source',str(frozen/'m007_matrix_leaf_ooc.tcl'),'-tclargs',str(at)],'M007_MATRIX_OOC_PASS')]
  for category,rss,cmd,marker in commands:
   if a.timeout>min(1200 if category=='rtl' else 600,caps[category]-used[category]):raise RuntimeError('budget exceeded')
   gcmd=[sys.executable,str(GUARD),'--out',str(at/('guard_'+category)),'--cwd',str(work),'--rss-gib',str(rss),'--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd]
   dump(at/('command_'+category+'.json'),{'argv':gcmd,'lock_held_through_children':True,'used_before_s':used.copy()});rc=subprocess.call(gcmd,cwd=work)
   result=json.loads((at/('guard_'+category)/'guard_result.json').read_text());log=(at/('guard_'+category)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));ok=rc==0 and not fatal and (not marker or marker in log);wall=result['elapsed_seconds'];used[category]+=wall
   dump(at/('receipt_'+category+'.json'),{'category':category,'guard':result,'wall_s':wall,'guard_exit':rc,'error_or_fatal':fatal,'required_marker':marker,'marker_found':marker in log if marker else None,'verdict':'PASS' if ok else ('COST_STOP' if result.get('trigger') else 'FAIL'),'driver_sha256':sha(at/('guard_'+category)/'driver.log')})
   dump(RUN/'budget_ledger.json',{'limits_s':caps,'used_s':used,'remaining_s':{k:caps[k]-used[k] for k in caps}})
   for line in log.splitlines():
    if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line:print(line,flush=True)
   print(json.dumps(result),flush=True)
   if not ok:return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
