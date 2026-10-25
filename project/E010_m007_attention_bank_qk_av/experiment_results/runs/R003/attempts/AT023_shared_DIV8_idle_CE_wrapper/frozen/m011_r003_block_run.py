#!/usr/bin/env python3
"""Immutable guarded R003 local blocks; original AT001 fixture is read-only reused."""
import argparse,datetime,fcntl,hashlib,json,re,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];RUN=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def ledger():
 costs={k:0.0 for k in('reference','static','rtl','ooc')};receipts=[]
 for rp in sorted((RUN/'attempts').glob('AT*/receipt_*.json')):
  x=json.loads(rp.read_text());cat=rp.stem.removeprefix('receipt_');costs[cat]+=x['guard']['elapsed_seconds'];receipts.append({'path':str(rp.relative_to(ROOT)),'verdict':x['verdict'],'seconds':x['guard']['elapsed_seconds']})
 dump(RUN/'budget_ledger.json',{'caps_seconds':{'reference':900,'static':1800,'rtl':7200,'ooc':600},'actual_seconds':costs,'receipts':receipts,'independent':'No R002/E012/other balance transfer'})
 return costs

def artifacts(at,w,label):
 controls={'xsimSettings.ini','xsim_script.tcl','xsimkernel.log','xsimcrash.log'}
 entries=[];mutable=[]
 for q in sorted((w/'xsim.dir').rglob('*')):
  if q.is_file():
   x={'path':str(q.relative_to(w)),'sha256':sha(q),'bytes':q.stat().st_size}
   (mutable if q.name in controls else entries).append(x)
 result={'observed_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'immutable_compiled_products':entries,'mutable_run_control_and_logs':mutable,'classification':'xsimSettings.ini/xsim_script.tcl and kernel/crash logs are mutable control, not source/compiled identity'}
 dump(at/('artifacts_'+label+'.json'),result);return entries

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('config',choices=['coeff','rope','div8']);p.add_argument('attempt');p.add_argument('--case',choices=['encoder0','encoder1'],default='encoder0');p.add_argument('--mode',choices=['normal','stall','abort','reset'],default='normal');a=p.parse_args();assert re.fullmatch('AT[0-9]{3}_[A-Za-z0-9_]+',a.attempt)
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;f=at/'frozen';w=at/'work';f.mkdir(parents=True,exist_ok=True);w.mkdir(exist_ok=True)
  names=['laya_rope_coeff_cache_v1.sv'] if a.config!='div8' else ['laya_shared_div8_v1.sv','laya_return_vector_credit_v1.sv','laya_fdiv_rne_v1.sv']
  if a.config=='rope':names+=['laya_attention_rope_engine_v1.sv','laya_attention_qkv_bank_v2.sv','laya_shared_fp256_v2.sv','laya_fp_return_credit_v1.sv','laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv']
  ref=RUN/'attempts/AT001_original_b1_three_layer_local_reference/work/oracle'
  files=[Path(__file__),GUARD,HELPER]+[MOD/'rtl'/n for n in names]+[MOD/'tb'/('m011_layer_'+a.config+'_tb.sv'),ref/'manifest.json',RUN/'layer_identity_binding.json',RUN/'attempts/AT001_original_b1_three_layer_local_reference/frozen/identity_manifest.json']+[ref/(n+'.mem')for n in('cos_full','sin_full','cos_slide','sin_slide')]
  if a.config=='rope':files +=[ref/(a.case+'_'+n+'.mem')for n in('pre_qkv','post_qkv')]+[ref/(a.case+'_rope_p'+str(pl)+'_m'+str(m)+'.mem')for pl in range(2)for m in range(4)]
  if a.config=='div8':
   divref=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R002/attempts/AT009_shared_div8_reference'
   files=[Path(__file__),GUARD,HELPER]+[MOD/'rtl'/n for n in names]+[MOD/'tb/m011_softmax_div8_tb.sv',divref/'work/oracle/manifest.json',divref/'source_manifest.json',divref/'receipt_reference.json',divref/'frozen/full_reference.py',divref/'frozen/m011_div_fixture.py']+sorted((divref/'work/oracle').glob('*.mem'))
  for src in files:
   dst=f/src.name
   if dst.exists():assert sha(src)==sha(dst),'immutable input differs; fresh AT required'
   else:shutil.copy2(src,dst)
  ident={'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'host':socket.gethostname(),'scope':'E010/R003 '+a.config+' actual original-table local RTL','case':a.case,'files':[{'source':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size}for s in files]}
  if not(at/'source_manifest.json').exists():dump(at/'source_manifest.json',ident)
  else:assert json.loads((at/'source_manifest.json').read_text())['case']==a.case
  top='m011_softmax_div8_tb' if a.config=='div8' else 'm011_layer_'+a.config+'_tb';snapshot='m011_r003_'+a.config+'_sim';cat='static'if a.stage=='build'else'rtl';rss=24 if cat=='static'else 8
  costs=ledger();cap=1800 if cat=='static'else 7200;assert costs[cat]+120<=cap,'R003 remaining budget insufficient for120-second pilot'
  if a.stage=='build':
   script=w/'build.sh';script.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(f/s.name)for s in files if s.suffix in('.sv','.v'))+'\n'+str(VIV/'xelab')+' work.'+top+' --relax -mt 4 --O3 -s '+snapshot+'\n');cmd=['/bin/bash',str(script)];marker=None
  else:
   assert json.loads((at/'receipt_static.json').read_text())['verdict']=='PASS';cmd=[str(VIV/'xsim'),snapshot,'-runall','-testplusarg','DATA='+str(f),'-testplusarg','CASE='+a.case,'-testplusarg','MODE='+a.mode];marker='HARDWARE_AGENT_SIM_PASS M011_DIV8' if a.config=='div8' else 'HARDWARE_AGENT_SIM_PASS M011_LAYER_'+a.config.upper()
   if a.config=='div8':cmd+=['-testplusarg','COUNT='+str(json.loads((f/'manifest.json').read_text())['div_main_count'])]
  out=at/('guard_'+cat);assert not out.exists(),'preserve prior run'
  argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(w),'--rss-gib',str(rss),'--timeout-seconds','120','--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':argv,'lock':'m007_heavy.lock through descendants','resources':'CPU0-3/nice19/idle MemAvailable>192GiB','mode':a.mode,'case':a.case})
  before=artifacts(at,w,'before_rtl')if a.stage=='rtl'else None
  if before is not None:assert before==json.loads((at/'artifacts_after_build.json').read_text())['immutable_compiled_products'],'compiled product differs before RTL'
  rc=subprocess.call(argv,cwd=w)
  after=artifacts(at,w,'after_rtl'if a.stage=='rtl'else'after_build')
  artifact_ok=before is None or before==after
  g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:Fatal|FATAL|ERROR)\s*[:\[]',log));ok=artifact_ok and rc==0 and not fatal and(marker is None or marker in log)
  dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS'if ok else'COST_STOP'if g.get('trigger')else'FAIL','guard':g,'wrapper_exit':rc,'error_or_fatal':fatal,'compiled_products_unchanged':artifact_ok,'marker':marker,'marker_found':marker in log if marker else None,'log_sha256':sha(out/'driver.log')});ledger()
  print(cat,json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
