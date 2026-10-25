#!/usr/bin/env python3
"""R003 immutable original layer tests and actual same-build cost gate."""
import argparse,datetime,fcntl,hashlib,json,re,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];RUN=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def ledger():
 costs={k:0.0 for k in('reference','static','rtl','ooc')};receipts=[]
 for rp in sorted((RUN/'attempts').glob('AT*/receipt_*.json')):
  x=json.loads(rp.read_text());cat=rp.stem.removeprefix('receipt_');costs[cat]+=x['guard']['elapsed_seconds'];receipts.append({'path':str(rp.relative_to(ROOT)),'verdict':x['verdict'],'seconds':x['guard']['elapsed_seconds']})
 dump(RUN/'budget_ledger.json',{'caps_seconds':{'reference':900,'static':1800,'rtl':7200,'ooc':600},'actual_seconds':costs,'receipts':receipts,'independent':'No balance transfer'})
 return costs

def artifacts(at,w,label):
 mutable_names={'xsimSettings.ini','xsim_script.tcl','xsimkernel.log','xsimcrash.log'};fixed=[];mutable=[]
 for p in sorted((w/'xsim.dir').rglob('*')):
  if p.is_file():(mutable if p.name in mutable_names else fixed).append({'path':str(p.relative_to(w)),'bytes':p.stat().st_size,'sha256':sha(p)})
 dump(at/('artifacts_'+label+'.json'),{'observed_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'immutable_compiled_products':fixed,'mutable_run_control_and_logs':mutable});return fixed

def cost_gate(a):
 prep=[];perhead=[];evidence=[]
 for name,n in((a.one_head_at,1),(a.two_head_at,2)):
  assert name,'full16head needs actual one/two-head pilots';p=RUN/'attempts'/name;x=json.loads((p/'receipt_rtl.json').read_text());assert x['verdict']=='PASS'and x.get('build_at')==a.build_at and x.get('pilot_heads')==n,'pilot scope/build mismatch'
  events=json.loads((p/'work/wall_events.json').read_text())['events'];beg={e['head']:e['elapsed_seconds']for e in events if e.get('kind')=='begin'};end={e['head']:e['elapsed_seconds']for e in events if e.get('kind')=='end'};assert len(end)==n;prep.append(beg[0]);perhead +=[end[h]-beg[h]for h in range(n)];evidence.append({'attempt':name,'receipt_sha256':sha(p/'receipt_rtl.json'),'wall_events_sha256':sha(p/'work/wall_events.json')})
 estimate=1.2*(max(prep)+16*max(perhead));assert estimate<=1800,'COST_STOP full16head actual same-build gate exceeds1800s'
 return {'actual_preparation_rope_seconds':max(prep),'actual_conservative_head_seconds':max(perhead),'formula':'1.2*(actual prep/RoPE+16*conservative actual head)','predicted_guarded_seconds':estimate,'evidence':evidence}

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('config',choices=['order','layer']);p.add_argument('attempt');p.add_argument('--build-at');p.add_argument('--case',choices=['encoder0','encoder1','decision0'],default='encoder0');p.add_argument('--pilot-heads',type=int,choices=[0,1,2],default=1);p.add_argument('--one-head-at');p.add_argument('--two-head-at');a=p.parse_args();assert re.fullmatch('AT[0-9]{3}_[A-Za-z0-9_]+',a.attempt)
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;f=at/'frozen';w=at/'work';f.mkdir(parents=True,exist_ok=True);w.mkdir(exist_ok=True)
  top='m011_layer_order_tb'if a.config=='order'else'm011_layer_integration_tb';snapshot='m011_'+a.config+'_sim'
  if a.stage=='build':
   names=['laya_attention_check_order_v1.sv']
   if a.config=='layer':names+=['laya_attention_layer_v1.sv','laya_attention_head_engine_v1.sv','laya_attention_resources_v1.sv','laya_attention_qk_av_engine_v1.sv','laya_attention_softmax_engine_v1.sv','laya_attention_rope_engine_v1.sv','laya_attention_qkv_bank_v2.sv','laya_rope_coeff_cache_v1.sv','laya_attention_storage_v1.sv','laya_ln_exp_storage_v1.sv','laya_shared_fp256_v2.sv','laya_fp_return_credit_v1.sv','laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv','laya_sfu_exp8_v1.sv','laya_return_vector_credit_v1.sv','laya_shared_div8_v1.sv','laya_fdiv_rne_v1.sv']
   files=[Path(__file__),MOD/'tb/m011_xsim_wall_driver.py',GUARD,HELPER]+[MOD/'rtl'/n for n in names]+[MOD/'tb'/(top+'.sv')]
   if a.config=='layer':
    ref=RUN/'attempts/AT001_original_b1_three_layer_local_reference/work/oracle';files+=sorted((MOD/'rtl/strict_exp_ii1_167').glob('*'))+sorted(ref.glob('*.mem'))+[ref/'manifest.json']
   for src in files:
    dst=f/src.name
    if dst.exists():assert sha(src)==sha(dst),'fresh AT required'
    else:shutil.copy2(src,dst)
   manifest={'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'host':socket.gethostname(),'scope':'E010/R003 '+a.config+' build','files':[{'source':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size}for s in files]};dump(at/'source_manifest.json',manifest)
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   script=w/'build.sh';script.write_text('#!/usr/bin/env bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(f/s.name)for s in files if s.suffix in('.sv','.v'))+'\n'+str(VIV/'xelab')+' work.'+top+' --relax -mt 4 --O3 -s '+snapshot+'\n');cmd=['/bin/bash',str(script)];cat='static';rss=24;limit=120;marker=None;gate=None
  else:
   build=RUN/'attempts'/a.build_at if a.build_at else at
   assert json.loads((build/'receipt_static.json').read_text())['verdict']=='PASS'
   assert sha(Path(__file__))==sha(build/'frozen'/Path(__file__).name),'runner differs from compiled closure'
   if build!=at:
    for q in(build/'frozen').iterdir():
     if q.is_file():shutil.copy2(q,f/q.name)
    shutil.copytree(build/'work/xsim.dir',w/'xsim.dir');
    if(build/'work/xsim.ini').exists():shutil.copy2(build/'work/xsim.ini',w/'xsim.ini')
    shutil.copy2(build/'artifacts_after_build.json',at/'artifacts_after_build.json')
    dump(at/'source_manifest.json',{'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'actual same-compiled original layer RTL','build_at':a.build_at,'build_source_manifest_sha256':sha(build/'source_manifest.json'),'frozen_files':[{'name':q.name,'sha256':sha(q),'bytes':q.stat().st_size}for q in sorted(f.iterdir())if q.is_file()]})
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   xsim=[str(VIV/'xsim'),snapshot,'-runall','-testplusarg','DATA='+str(f),'-testplusarg','CASE='+a.case,'-testplusarg','PILOT_HEADS='+str(a.pilot_heads)]
   cmd=[sys.executable,str(f/'m011_xsim_wall_driver.py'),'--out',str(w/'wall_events.json'),'--',*xsim];cat='rtl';rss=8;limit=120 if a.config=='order'or a.pilot_heads==1 else 1200;gate=None
   marker='HARDWARE_AGENT_SIM_PASS M011_LAYER_ORDER'if a.config=='order'else'HARDWARE_AGENT_SIM_PASS M011_LAYER_PILOT'if a.pilot_heads else'HARDWARE_AGENT_SIM_PASS M011_LAYER_INTEGRATION'
   if a.config=='layer'and a.pilot_heads==0:gate=cost_gate(a);limit=1800;dump(at/'full16_cost_gate.json',gate)
  costs=ledger();cap=1800 if cat=='static'else 7200;assert costs[cat]+limit<=cap,'R003 remaining budget insufficient for guard limit'
  out=at/('guard_'+cat);assert not out.exists(),'preserve prior run';argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(w),'--rss-gib',str(rss),'--timeout-seconds',str(limit),'--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':argv,'lock':'m007_heavy.lock through descendants','case':a.case,'pilot_heads':a.pilot_heads,'build_at':a.build_at,'cost_gate':gate})
  before=artifacts(at,w,'before_rtl')if cat=='rtl'else None
  if before is not None:assert before==json.loads((at/'artifacts_after_build.json').read_text())['immutable_compiled_products'],'compiled product identity changed'
  rc=subprocess.call(argv,cwd=w);after=artifacts(at,w,'after_rtl'if cat=='rtl'else'after_build');artifact_ok=before is None or before==after;g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:Fatal|FATAL|ERROR)\s*[:\[]',log));ok=artifact_ok and rc==0 and not fatal and(marker is None or marker in log)
  dump(at/('receipt_'+cat+'.json'),{'verdict':'PASS'if ok else'COST_STOP'if g.get('trigger')else'FAIL','guard':g,'wrapper_exit':rc,'error_or_fatal':fatal,'compiled_products_unchanged':artifact_ok,'build_at':a.build_at,'case':a.case,'pilot_heads':a.pilot_heads,'marker':marker,'marker_found':marker in log if marker else None,'log_sha256':sha(out/'driver.log')});ledger();print(cat,json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'PASS'in line or'Fatal:'in line or'ERROR:'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
