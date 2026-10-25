#!/usr/bin/env python3
"""M007 owned strict-FP runner; one project lock covers every guarded descendant."""
import argparse,datetime as dt,fcntl,hashlib,json,os,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7]
MODULE=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E008_m007_strict_fp_shared_service/experiment_results/runs/R001'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def dump(p,obj):p.write_text(json.dumps(obj,indent=2,sort_keys=True)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl','ooc']);p.add_argument('attempt');p.add_argument('--timeout',type=int,default=120);p.add_argument('--count',type=int);args=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[a-zA-Z0-9_]+',args.attempt):p.error('stable AT name required')
 if args.timeout>600:p.error('this runner never exceeds 600 seconds')
 lock=ROOT/'.research-agent/m007_heavy.lock';lock.parent.mkdir(exist_ok=True)
 with lock.open('a+') as lf:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lf,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/args.attempt;frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True,exist_ok=True);work.mkdir(exist_ok=True)
  sources=[MODULE/'rtl/laya_fdiv_rne_v1.sv',MODULE/'tb/m007_fdiv_reference.cpp',MODULE/'tb/m007_fdiv_rne_tb.sv',MODULE/'tb/m007_fdiv_ooc.tcl',MODULE/'tb/m007_fdiv_clock.xdc',Path(__file__),GUARD,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']
  for src in sources:
   dest=frozen/src.name
   if dest.exists():
    if sha(dest)!=sha(src):raise RuntimeError('Frozen source differs; create next AT: '+str(src))
   else:shutil.copy2(src,dest)
  if not (at/'source_manifest.json').exists():
   dump(at/'source_manifest.json',{'at':dt.datetime.now(dt.timezone.utc).isoformat(),'attempt':args.attempt,'source_inputs':[{'path':str(src.relative_to(ROOT)),'frozen':src.name,'sha256':sha(src),'bytes':src.stat().st_size} for src in sources],'hostname':os.uname().nodename,'python':sys.version,'tool_root':str(VIV),'numeric_reference':'native binary32 DIVSS, FE_TONEAREST, FTZ/DAZ disabled; independent of DUT'})
  if args.stage=='reference':
   commands=[('static',24,['/usr/bin/g++','-O2','-std=c++17','-fno-fast-math','-frounding-math','-ffp-contract=off',str(frozen/'m007_fdiv_reference.cpp'),'-o',str(work/'fdiv_reference')]),('reference',16,[str(work/'fdiv_reference'),str(work/'vectors.hex')])]
  elif args.stage=='build':
   build=work/'build.sh';build.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+str(frozen/'laya_fdiv_rne_v1.sv')+' '+str(frozen/'m007_fdiv_rne_tb.sv')+'\n'+str(VIV/'xelab')+' work.m007_fdiv_rne_tb --relax -mt 4 --O3 -s strict_fdiv_sim\n');commands=[('static',24,['/bin/bash',str(build)])]
  elif args.stage=='rtl':
   count=args.count or sum(1 for _ in (work/'vectors.hex').open())
   commands=[('rtl',8,[str(VIV/'xsim'),'strict_fdiv_sim','-runall','-testplusarg','VECTORS='+str(work/'vectors.hex'),'-testplusarg','COUNT='+str(count)])]
  else:commands=[('ooc',24,[str(VIV/'vivado'),'-mode','batch','-source',str(frozen/'m007_fdiv_ooc.tcl'),'-tclargs',str(at)])]
  for category,rss,cmd in commands:
   out=at/('guard_'+category)
   if out.exists():raise RuntimeError('Preserve existing guard; create a new AT')
   guardcmd=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(work),'--rss-gib',str(rss),'--timeout-seconds',str(args.timeout),'--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd]
   dump(at/('command_'+category+'.json'),{'category':category,'argv':guardcmd,'lock':str(lock),'lock_held_through_guard_and_children':True})
   rc=subprocess.call(guardcmd,cwd=work)
   result=json.loads((out/'guard_result.json').read_text()) if (out/'guard_result.json').exists() else {'missing_guard_result':True}
   log=(out/'driver.log').read_text(errors='replace') if (out/'driver.log').exists() else ''
   fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log))
   marker={'reference':'FDIV_REFERENCE_PASS','rtl':'HARDWARE_AGENT_SIM_PASS FDIV_RNE','ooc':'FDIV_RNE_OOC_PASS'}.get(category)
   ok=rc==0 and not fatal and (not marker or marker in log)
   dump(at/('receipt_'+category+'.json'),{'stage':category,'guard':result,'guard_wrapper_exit':rc,'error_or_fatal':fatal,'required_marker':marker,'marker_found':marker in log if marker else None,'verdict':'PASS' if ok else ('COST_STOP' if result.get('trigger') else 'FAIL'),'driver_sha256':sha(out/'driver.log')})
   if category=='reference' and ok:dump(at/'fixture_identity.json',{'sha256':sha(work/'vectors.hex'),'bytes':(work/'vectors.hex').stat().st_size,'count':int(re.search(r'count=(\d+)',log).group(1)),'generator_sha256':sha(frozen/'m007_fdiv_reference.cpp'),'binary_sha256':sha(work/'fdiv_reference')})
   print(category,json.dumps(result),'PASS' if ok else 'FAIL',flush=True)
   for line in log.splitlines():
    if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line:print(line,flush=True)
   if not ok:return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
