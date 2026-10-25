#!/usr/bin/env python3
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MODULE=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R001'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,o):p.write_text(json.dumps(o,indent=2,sort_keys=True)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('config',choices=['storage']);p.add_argument('attempt');a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[a-zA-Z0-9_]+',a.attempt):p.error('fresh stable AT required')
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+')as lf:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lf,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True,exist_ok=True);work.mkdir(exist_ok=True)
  files=[MODULE/'rtl/laya_attention_storage_v1.sv',MODULE/'tb/m011_storage_tb.sv',Path(__file__),GUARD,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']
  for s in files:
   d=frozen/s.name
   if d.exists()and sha(s)!=sha(d):raise RuntimeError('frozen input differs; next AT required')
   if not d.exists():shutil.copy2(s,d)
  if not(at/'source_manifest.json').exists():dump(at/'source_manifest.json',{'attempt':a.attempt,'at':dt.datetime.now(dt.timezone.utc).isoformat(),'files':[{'source':str(s.relative_to(ROOT)),'sha256':sha(s),'bytes':s.stat().st_size,'frozen':s.name}for s in files],'experiment':'E010; separate budget, no E008 transfer'})
  if a.stage=='build':
   b=work/'build.sh';b.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+str(frozen/'laya_attention_storage_v1.sv')+' '+str(frozen/'m011_storage_tb.sv')+'\n'+str(VIV/'xelab')+' work.m011_storage_tb --relax -mt 4 --O3 -s m011_storage_sim\n');cat='static';rss=24;cmd=['/bin/bash',str(b)];marker=None
  else:cat='rtl';rss=8;cmd=[str(VIV/'xsim'),'m011_storage_sim','-runall'];marker='HARDWARE_AGENT_SIM_PASS M011_STORAGE'
  out=at/('guard_'+cat)
  if out.exists():raise RuntimeError('preserve old guard')
  argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(work),'--rss-gib',str(rss),'--timeout-seconds','120','--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':argv,'category':cat,'project_exclusive_lock':'m007_heavy.lock'})
  rc=subprocess.call(argv,cwd=work);g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');error=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));ok=rc==0 and not error and(marker is None or marker in log)
  dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS'if ok else('COST_STOP'if g.get('trigger')else'FAIL'),'guard':g,'wrapper_exit':rc,'error_or_fatal':error,'required_marker':marker,'marker_found':marker in log if marker else None,'log_sha256':sha(out/'driver.log')})
  print(cat,json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'_PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
