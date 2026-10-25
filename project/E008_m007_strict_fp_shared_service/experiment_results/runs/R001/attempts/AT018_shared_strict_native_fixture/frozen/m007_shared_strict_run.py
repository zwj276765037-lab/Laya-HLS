#!/usr/bin/env python3
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MODULE=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E008_m007_strict_fp_shared_service/experiment_results/runs/R001'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,o):p.write_text(json.dumps(o,indent=2,sort_keys=True)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl']);p.add_argument('config',choices=['4','256','compat']);p.add_argument('attempt');a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[a-zA-Z0-9_]+',a.attempt):p.error('stable fresh AT required')
 tb,top,marker={'4':('m007_shared_fp4_tb.sv','m007_shared_fp4_tb','HARDWARE_AGENT_SIM_PASS SHARED_FP4'),'256':('m007_shared_fp256_tb.sv','m007_shared_fp256_tb','HARDWARE_AGENT_SIM_PASS SHARED_FP256'),'compat':('laya_shared_fp256_local_tb.sv','laya_shared_fp256_local_tb','SHARED_FP_LOCAL_PASS')}[a.config]
 lock=ROOT/'.research-agent/m007_heavy.lock'
 with lock.open('a+') as lf:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lf,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True,exist_ok=True);work.mkdir(exist_ok=True)
  srcs=[MODULE/'rtl'/n for n in ['laya_fmul_rne_v1.sv','laya_fadd_rne_v1.sv','laya_fp_return_credit_v1.sv','laya_shared_fp256_v2.sv','laya_shared_fp256_v1.sv']]+[MODULE/'tb'/tb,MODULE/'tb/m007_shared_strict_fixture.py',Path(__file__),GUARD,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']
  for s in srcs:
   d=frozen/s.name
   if d.exists() and sha(d)!=sha(s):raise RuntimeError('Frozen input changed; use next AT')
   if not d.exists():shutil.copy2(s,d)
  dump(at/'source_manifest.json',{'attempt':a.attempt,'config':a.config,'at':dt.datetime.now(dt.timezone.utc).isoformat(),'sources':[{'path':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size}for s in srcs],'mul':'laya_fmul_rne_v1, latency8, exact finite binary32; no vendor floating IP in this closure'})
  if a.stage=='reference':
   mul=RUN/'attempts/AT015_strict_mul_native_reference/work/vectors.hex';add=RUN/'attempts/AT001_native_reference_pilot/work/vectors.hex'
   dump(at/'reference_inputs.json',{'mul':str(mul.relative_to(ROOT)),'mul_sha256':sha(mul),'add':str(add.relative_to(ROOT)),'add_sha256':sha(add)})
   cmd=[sys.executable,str(frozen/'m007_shared_strict_fixture.py'),str(mul),str(add),str(work/'vectors.hex')];cat='reference';rss=16;marker='SHARED_STRICT_FIXTURE_PASS'
  elif a.stage=='build':
   b=work/'build.sh';b.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(frozen/n)for n in ['laya_fmul_rne_v1.sv','laya_fadd_rne_v1.sv','laya_fp_return_credit_v1.sv','laya_shared_fp256_v2.sv','laya_shared_fp256_v1.sv',tb])+'\n'+str(VIV/'xelab')+' work.'+top+' --relax -mt 4 --O3 -s shared_strict_sim\n');cmd=['/bin/bash',str(b)];cat='static';rss=24;marker=None
  else:cmd=[str(VIV/'xsim'),'shared_strict_sim','-runall','-testplusarg','VECTORS='+str(work/'vectors.hex')];cat='rtl';rss=8
  out=at/('guard_'+cat)
  if out.exists():raise RuntimeError('Preserve existing guard')
  argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(work),'--rss-gib',str(rss),'--timeout-seconds','120','--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd]
  dump(at/('command_'+cat+'.json'),{'argv':argv,'lock':str(lock),'category':cat,'config':a.config})
  rc=subprocess.call(argv,cwd=work);g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace')
  fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));ok=rc==0 and not fatal and (marker is None or marker in log)
  dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS'if ok else('COST_STOP'if g.get('trigger')else'FAIL'),'guard':g,'guard_wrapper_exit':rc,'error_or_fatal':fatal,'required_marker':marker,'marker_found':marker in log if marker else None,'driver_sha256':sha(out/'driver.log')})
  print(cat,json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if '_PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
