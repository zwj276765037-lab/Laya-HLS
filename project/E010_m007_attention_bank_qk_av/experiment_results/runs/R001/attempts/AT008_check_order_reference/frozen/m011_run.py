#!/usr/bin/env python3
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MODULE=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R001'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py'
HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
FIXTURE=ROOT/'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture'
REFERENCE=ROOT/'project/E002_Laya_HLS/experiment/tests/full_reference.py'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,o):p.write_text(json.dumps(o,indent=2,sort_keys=True)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl']);p.add_argument('config',choices=['storage','core']);p.add_argument('attempt');p.add_argument('--reference-at',default='AT002_independent_intermediates');p.add_argument('--build-at');p.add_argument('--error-at',default='AT008_check_order_reference');p.add_argument('--mode',choices=['qk','av','sliding','stall','abort','reset','error'],default='qk');p.add_argument('--timeout',type=float,default=120);a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[a-zA-Z0-9_]+',a.attempt):p.error('fresh stable AT required')
 if not 0<a.timeout<=1200:p.error('invalid bounded timeout')
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+')as lf:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lf,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True,exist_ok=True);work.mkdir(exist_ok=True)
  files=[Path(__file__),GUARD,HELPER]
  if a.stage=='reference':
   if a.mode=='error':files += [MODULE/'tb/m011_error_fixture.py',REFERENCE]
   else:files += [MODULE/'tb/m011_fixture.py',REFERENCE,FIXTURE/'manifest.json',FIXTURE/'mask.mem']+[FIXTURE/(n+'.bin')for n in('q','k','v','prob','score','maximum','out')]
  else:
   names=['laya_attention_storage_v1.sv']if a.config=='storage'else['laya_attention_storage_v1.sv','laya_attention_qkv_bank_v1.sv','laya_attention_qk_av_v1.sv','laya_shared_fp256_v2.sv','laya_fp_return_credit_v1.sv','laya_fmul_rne_v1.sv','laya_fadd_rne_v1.sv']
   files += [MODULE/'rtl'/n for n in names]+[MODULE/'tb'/('m011_'+a.config+'_tb.sv')]
   if a.config=='core':
    files+=sorted((RUN/'attempts'/a.reference_at/'work/oracle').glob('*'))
    files+=sorted((RUN/'attempts'/a.error_at/'work/oracle').glob('*'))
  for s in files:
   d=frozen/s.name
   if d.exists()and sha(s)!=sha(d):raise RuntimeError('frozen input differs; next AT required: '+s.name)
   if not d.exists():shutil.copy2(s,d)
  if not(at/'source_manifest.json').exists():dump(at/'source_manifest.json',{'attempt':a.attempt,'at':dt.datetime.now(dt.timezone.utc).isoformat(),'files':[{'source':str(s.relative_to(ROOT)),'sha256':sha(s),'bytes':s.stat().st_size,'frozen':s.name}for s in files],'experiment':'E010; separate budget, no E008 transfer'})
  if a.stage=='reference':
   cat='reference';rss=16
   if a.mode=='error':cmd=[sys.executable,str(frozen/'m011_error_fixture.py'),'--out',str(work/'oracle')];marker='M011_ERROR_REFERENCE_PASS'
   else:cmd=[sys.executable,str(frozen/'m011_fixture.py'),'--input',str(frozen),'--reference',str(frozen/'full_reference.py'),'--out',str(work/'oracle')];marker='M011_REFERENCE_PASS'
  elif a.stage=='build':
   top='m011_'+a.config+'_tb';b=work/'build.sh';b.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(frozen/s.name)for s in files if s.suffix=='.sv')+'\n'+str(VIV/'xelab')+' work.'+top+' --relax -mt 4 --O3 -s '+top+'_sim\n');cat='static';rss=24;cmd=['/bin/bash',str(b)];marker=None
  else:
   if a.build_at:
    prior=RUN/'attempts'/a.build_at
    for src in files:
     if src.suffix=='.sv'and sha(src)!=sha(prior/'frozen'/src.name):raise RuntimeError('reused compiled SV mismatch '+src.name)
    shutil.copytree(prior/'work/xsim.dir',work/'xsim.dir')
    dump(at/'build_reuse.json',{'from':a.build_at,'static_receipt_sha256':sha(prior/'receipt_static.json'),'compiled_sv_match':True,'new_compile_cost':0})
   cat='rtl';rss=8;cmd=[str(VIV/'xsim'),'m011_'+a.config+'_tb_sim','-runall']
   if a.config=='core':cmd+=['-testplusarg','MODE='+a.mode,'-testplusarg','DATA='+str(frozen)]
   marker='HARDWARE_AGENT_SIM_PASS M011_'+a.config.upper()
  out=at/('guard_'+cat)
  if out.exists():raise RuntimeError('preserve old guard')
  argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(work),'--rss-gib',str(rss),'--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':argv,'category':cat,'project_exclusive_lock':'m007_heavy.lock','mode':a.mode})
  rc=subprocess.call(argv,cwd=work);g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');error=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));ok=rc==0 and not error and(marker is None or marker in log)
  dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS'if ok else('COST_STOP'if g.get('trigger')else'FAIL'),'guard':g,'wrapper_exit':rc,'error_or_fatal':error,'required_marker':marker,'marker_found':marker in log if marker else None,'log_sha256':sha(out/'driver.log')})
  print(cat,json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'_PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
