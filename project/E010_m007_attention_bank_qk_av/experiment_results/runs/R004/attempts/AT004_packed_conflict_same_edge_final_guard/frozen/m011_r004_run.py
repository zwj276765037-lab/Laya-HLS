#!/usr/bin/env python3
"""Immutable E010/R004 bounded actual pure-layer regressions."""
import argparse,datetime,fcntl,hashlib,json,re,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];RUN=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R004';OLD=RUN.parent/'R003';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
CAPS={'reference':120,'static':1200,'rtl':3000,'ooc':0}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def ledger():
 costs={k:0.0 for k in CAPS};receipts=[]
 for p in sorted((RUN/'attempts').glob('AT*/receipt_*.json')):
  x=json.loads(p.read_text());costs[p.stem.removeprefix('receipt_')]+=x['guard']['elapsed_seconds'];receipts.append({'path':str(p.relative_to(ROOT)),'verdict':x['verdict'],'seconds':x['guard']['elapsed_seconds']})
 dump(RUN/'budget_ledger.json',{'caps_seconds':CAPS,'actual_seconds':costs,'receipts':receipts,'independent':'No transfers; unknown120s; ordinaryRTL1200s;static600s;longrun recovery reserve240s'});return costs
def artifacts(at,w,label):
 fixed=[];mutable=[]
 for p in sorted((w/'xsim.dir').rglob('*')):
  if p.is_file():(mutable if p.name in {'xsimSettings.ini','xsim_script.tcl','xsimkernel.log','xsimcrash.log'}else fixed).append({'path':str(p.relative_to(w)),'sha256':sha(p),'bytes':p.stat().st_size})
 dump(at/('artifacts_'+label+'.json'),{'observed_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'immutable_compiled_products':fixed,'mutable_run_control_and_logs':mutable});return fixed

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('config',choices=['check','cancel','layer']);p.add_argument('attempt');p.add_argument('--build-at');p.add_argument('--case',choices=['encoder0','encoder1','decision0'],default='decision0');p.add_argument('--prep-only',action='store_true');a=p.parse_args();assert re.fullmatch('AT[0-9]{3}_[A-Za-z0-9_]+',a.attempt)
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;f=at/'frozen';w=at/'work';f.mkdir(parents=True,exist_ok=True);w.mkdir(exist_ok=True);top='m011_r004_'+a.config+'_tb';snap='m011_r004_'+a.config+'_sim';cat='static'if a.stage=='build'else'rtl';limit=120;marker=None
  if a.stage=='build':
   names=['laya_attention_check_order_v1.sv']
   if a.config!='check':names+=['laya_attention_layer_v1.sv','laya_attention_layer_engine_v1.sv','laya_attention_head_engine_v1.sv','laya_attention_resources_v1.sv','laya_attention_qk_av_engine_v1.sv','laya_attention_softmax_engine_v1.sv','laya_attention_rope_engine_v1.sv','laya_attention_qkv_bank_v2.sv','laya_rope_coeff_cache_v1.sv','laya_attention_storage_v1.sv','laya_ln_exp_storage_v1.sv','laya_shared_fp256_v2.sv','laya_fp_return_credit_v1.sv','laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv','laya_sfu_exp8_v1.sv','laya_return_vector_credit_v1.sv','laya_shared_div8_v1.sv','laya_fdiv_rne_v1.sv']
   files=[Path(__file__),MOD/'tb/m011_xsim_wall_driver.py',GUARD,HELPER]+[MOD/'rtl'/n for n in names]+[MOD/'tb'/(top+'.sv')]
   if a.config!='check':files+=sorted((MOD/'rtl/strict_exp_ii1_167').glob('*'))
   if a.config=='layer':
    ref=OLD/'attempts/AT001_original_b1_three_layer_local_reference/work/oracle';files+=sorted(ref.glob('*.mem'))+sorted(ref.glob('*.bin'))+[ref/'manifest.json']
   for src in files:
    dst=f/src.name
    if dst.exists():assert sha(src)==sha(dst),'fresh AT required'
    else:shutil.copy2(src,dst)
   dump(at/'source_manifest.json',{'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'host':socket.gethostname(),'scope':'E010/R004 '+a.config+' actual build','files':[{'source':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size}for s in files]})
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   script=w/'build.sh';script.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(f/s.name)for s in files if s.suffix in('.sv','.v'))+'\n'+str(VIV/'xelab')+' work.'+top+' --relax -mt 4 --O3 -s '+snap+'\n');cmd=['/bin/bash',str(script)]
  else:
   build=RUN/'attempts'/a.build_at if a.build_at else at;assert json.loads((build/'receipt_static.json').read_text())['verdict']=='PASS';assert sha(Path(__file__))==sha(build/'frozen'/Path(__file__).name),'runner closure changed'
   if build!=at:
    for q in(build/'frozen').iterdir():
     if q.is_file():shutil.copy2(q,f/q.name)
    shutil.copytree(build/'work/xsim.dir',w/'xsim.dir');shutil.copy2(build/'artifacts_after_build.json',at/'artifacts_after_build.json')
    if(build/'work/xsim.ini').exists():shutil.copy2(build/'work/xsim.ini',w/'xsim.ini')
    dump(at/'source_manifest.json',{'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'actual same-compiled pure layer RTL','build_at':a.build_at,'build_manifest_sha256':sha(build/'source_manifest.json')})
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   cmd=[sys.executable,str(f/'m011_xsim_wall_driver.py'),'--out',str(w/'wall_events.json'),'--',str(VIV/'xsim'),snap,'-runall','-testplusarg','DATA='+str(f),'-testplusarg','CASE='+a.case,'-testplusarg','PILOT_HEADS=1','-testplusarg','PREP_ONLY='+str(int(a.prep_only))]
   marker='HARDWARE_AGENT_SIM_PASS M011_R004_'+a.config.upper()if a.config!='layer'else'HARDWARE_AGENT_SIM_PASS M011_LAYER_PREP_PILOT'if a.prep_only else'HARDWARE_AGENT_SIM_PASS M011_LAYER_PILOT'
  costs=ledger();assert costs[cat]+limit<=CAPS[cat],'R004 budget insufficient'
  out=at/('guard_'+cat);assert not out.exists(),'preserve old attempt';argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(w),'--rss-gib','24'if cat=='static'else'8','--timeout-seconds',str(limit),'--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':argv,'lock':'m007_heavy.lock through descendants','resources':'CPU0-3/nice19/idle/MemAvailable>192GiB','case':a.case,'prep_only':a.prep_only,'build_at':a.build_at})
  before=artifacts(at,w,'before_rtl')if cat=='rtl'else None
  if before is not None:assert before==json.loads((at/'artifacts_after_build.json').read_text())['immutable_compiled_products'],'compiled product changed'
  rc=subprocess.call(argv,cwd=w);after=artifacts(at,w,'after_rtl'if cat=='rtl'else'after_build');g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:Fatal|FATAL|ERROR)\s*[:\[]',log));unchanged=before is None or before==after;ok=unchanged and rc==0 and not fatal and(marker is None or marker in log)
  dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS'if ok else'COST_STOP'if g.get('trigger')else'FAIL','guard':g,'wrapper_exit':rc,'error_or_fatal':fatal,'compiled_products_unchanged':unchanged,'build_at':a.build_at,'case':a.case,'prep_only':a.prep_only,'marker':marker,'marker_found':marker in log if marker else None,'log_sha256':sha(out/'driver.log')});ledger();print(cat,json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
