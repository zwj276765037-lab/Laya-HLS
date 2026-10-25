#!/usr/bin/env python3
import argparse,datetime as dt,fcntl,hashlib,json,os,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MODULE=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E008_m007_strict_fp_shared_service/experiment_results/runs/R001'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,obj):p.write_text(json.dumps(obj,indent=2,sort_keys=True)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl']);p.add_argument('attempt');args=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[a-zA-Z0-9_]+',args.attempt):p.error('invalid AT')
 lock=ROOT/'.research-agent/m007_heavy.lock'
 with lock.open('a+') as lf:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lf,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/args.attempt;frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True,exist_ok=True);work.mkdir(exist_ok=True)
  legacy=next((ROOT/'project/E007_m006_full_fpga_attention/experiment_results/runs/R001/attempts').glob('AT009*'))
  mul=next(legacy.glob('**/tm1tn8_fmul_ip.vhd'))
  sources=[MODULE/'rtl/laya_fadd_rne_v1.sv',MODULE/'rtl/laya_fp_return_credit_v1.sv',MODULE/'rtl/laya_shared_fp256_v2.sv',MODULE/'rtl/laya_shared_fp256_v1.sv',MODULE/'tb/laya_shared_fp256_local_tb.sv',MODULE/'tb/m007_shared_fp_reference.cpp',Path(__file__),mul,GUARD,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']
  for src in sources:
   dst=frozen/src.name
   if dst.exists() and sha(dst)!=sha(src):raise RuntimeError('Frozen input differs; use next AT')
   if not dst.exists():shutil.copy2(src,dst)
  dump(at/'source_manifest.json',{'attempt':args.attempt,'at':dt.datetime.now(dt.timezone.utc).isoformat(),'sources':[{'path':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size} for s in sources],'multiplier_legal_scope':'native randomized finite normal inputs, no underflow/overflow; subnormal strictness UNKNOWN'})
  if args.stage=='reference':
   source=RUN/'attempts/AT001_native_reference_pilot/work/vectors.hex'
   dump(at/'add_fixture_reference.json',{'path':str(source.relative_to(ROOT)),'sha256':sha(source)})
   commands=[('static',24,['/usr/bin/g++','-O2','-std=c++17','-fno-fast-math','-frounding-math','-ffp-contract=off',str(frozen/'m007_shared_fp_reference.cpp'),'-o',str(work/'shared_reference')]),('reference',16,[str(work/'shared_reference'),str(source),str(work/'vectors.hex')])]
  elif args.stage=='build':
   b=work/'build.sh';b.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvhdl')+' '+str(frozen/'tm1tn8_fmul_ip.vhd')+'\n'+str(VIV/'xvlog')+' --sv '+ ' '.join(str(frozen/n) for n in ['laya_fadd_rne_v1.sv','laya_fp_return_credit_v1.sv','laya_shared_fp256_v2.sv','laya_shared_fp256_v1.sv','laya_shared_fp256_local_tb.sv'])+'\n'+str(VIV/'xelab')+' work.laya_shared_fp256_local_tb -L work -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s shared_compat_sim\n');commands=[('static',24,['/bin/bash',str(b)])]
  else:commands=[('rtl',8,[str(VIV/'xsim'),'shared_compat_sim','-runall','-testplusarg','VECTORS='+str(work/'vectors.hex')])]
  for cat,rss,cmd in commands:
   out=at/('guard_'+cat)
   if out.exists():raise RuntimeError('guard exists: preserve attempt')
   argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(work),'--rss-gib',str(rss),'--timeout-seconds','120','--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd]
   dump(at/('command_'+cat+'.json'),{'argv':argv,'lock':str(lock),'category':cat})
   rc=subprocess.call(argv,cwd=work)
   result=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace')
   error=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));marker={'reference':'SHARED_FP_REFERENCE_PASS','rtl':'SHARED_FP_LOCAL_PASS'}.get(cat)
   ok=rc==0 and not error and (marker is None or marker in log)
   dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS' if ok else ('COST_STOP' if result.get('trigger') else 'FAIL'),'guard':result,'guard_wrapper_exit':rc,'error_or_fatal':error,'required_marker':marker,'marker_found':marker in log if marker else None,'driver_sha256':sha(out/'driver.log')})
   if cat=='reference' and ok:dump(at/'fixture_identity.json',{'sha256':sha(work/'vectors.hex'),'count':16384,'bytes':(work/'vectors.hex').stat().st_size,'binary_sha256':sha(work/'shared_reference')})
   print(cat,json.dumps(result),'PASS' if ok else 'FAIL',flush=True)
   for line in log.splitlines():
    if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line:print(line,flush=True)
   if not ok:return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
