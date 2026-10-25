#!/usr/bin/env python3
import argparse,datetime,fcntl,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R002'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference','build','rtl']);p.add_argument('config',choices=['latency','credit','exp_lane']);p.add_argument('attempt');p.add_argument('--reference-at',default='AT005_real_softmax_reference');a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt):p.error('fresh AT required')
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;f=at/'frozen';w=at/'work';f.mkdir(parents=True,exist_ok=True);w.mkdir(exist_ok=True)
  files=[Path(__file__),GUARD,HELPER]
  if a.stage=='reference':
   fixture=ROOT/'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture'
   files += [MOD/'tb/m011_softmax_fixture.py',ROOT/'project/E002_Laya_HLS/experiment/tests/full_reference.py',fixture/'manifest.json',fixture/'mask.mem']+[fixture/(n+'.bin')for n in('q','k','v','score','maximum','prob','out')]
  elif a.config=='exp_lane':
   files += sorted((MOD/'rtl/strict_exp_ii1_167').glob('*'))+[MOD/'tb/m011_softmax_exp_lane_tb.sv']
   ref=RUN/'attempts'/a.reference_at/'work/oracle'
   files += [ref/n for n in('manifest.json','exp_x.mem','exp_gold.mem','exp_status.mem')]
  else:files += [MOD/'rtl'/n for n in('laya_shared_fp256_v2.sv','laya_fp_return_credit_v1.sv','laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv')]+[MOD/'tb'/('m011_softmax_'+a.config+'_tb.sv')]
  for src in files:
   dst=f/src.name
   if dst.exists()and sha(src)!=sha(dst):raise RuntimeError('immutable input differs; new AT')
   if not dst.exists():shutil.copy2(src,dst)
  if not(at/'source_manifest.json').exists():dump(at/'source_manifest.json',{'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'E010/R002 '+a.config+'; independent budget, no R001 transfer','files':[{'source':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size}for s in files]})
  top='m011_softmax_'+a.config+'_tb';snapshot='m011_'+a.config+'_sim'
  if a.stage=='reference':
   cat='reference';rss=16;cmd=[sys.executable,str(f/'m011_softmax_fixture.py'),'--input',str(f),'--reference',str(f/'full_reference.py'),'--out',str(w/'oracle')];marker='M011_SOFTMAX_REFERENCE_PASS'
  elif a.stage=='build':
   for data in f.glob('*.dat'):shutil.copy2(data,w/data.name)
   cat='static';rss=24;script=w/'build.sh';script.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(f/s.name)for s in files if s.suffix in('.sv','.v'))+'\n'+str(VIV/'xelab')+' work.'+top+' --relax -mt 4 --O3 -s '+snapshot+'\n');cmd=['/bin/bash',str(script)];marker=None
  else:
   cat='rtl';rss=8;cmd=[str(VIV/'xsim'),snapshot,'-runall'];marker='HARDWARE_AGENT_SIM_PASS M011_'+('SUM_LATENCY'if a.config=='latency'else'CREDIT'if a.config=='credit'else'EXP_LANE')
   if a.config=='exp_lane':cmd+=['-testplusarg','DATA='+str(f),'-testplusarg','COUNT='+str(json.loads((f/'manifest.json').read_text())['exp_count'])]
  out=at/('guard_'+cat)
  if out.exists():raise RuntimeError('preserve prior guard')
  argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(w),'--rss-gib',str(rss),'--timeout-seconds','120','--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':argv,'lock':'m007_heavy.lock','CPU':'0-3/nice19/idle','R002_independent_cap_seconds':{'reference':900,'static':1800,'rtl':3600,'hls_ooc':1800}})
  rc=subprocess.call(argv,cwd=w);g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:Fatal|FATAL|ERROR)\s*[:\[]',log));ok=rc==0 and not fatal and(marker is None or marker in log)
  dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS'if ok else('COST_STOP'if g.get('trigger')else'FAIL'),'guard':g,'wrapper_exit':rc,'error_or_fatal':fatal,'marker':marker,'marker_found':marker in log if marker else None,'log_sha256':sha(out/'driver.log')})
  print(cat,json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
