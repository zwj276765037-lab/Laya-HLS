#!/usr/bin/env python3
"""R003 guarded immutable attempts; independent budget, no prior balance transfer."""
import argparse,datetime,fcntl,hashlib,json,re,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];E=ROOT/'project/E010_m007_attention_bank_qk_av';RUN=E/'experiment_results/runs/R003'
GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['reference']);p.add_argument('attempt');a=p.parse_args();assert re.fullmatch('AT[0-9]{3}_[A-Za-z0-9_]+',a.attempt)
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  at=RUN/'attempts'/a.attempt;f=at/'frozen';w=at/'work';f.mkdir(parents=True,exist_ok=True);w.mkdir(exist_ok=True)
  base=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official';eroot=ROOT/'project/E002_Laya_HLS/experiment';reuse=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT001_full_local_model_fixtures/work/fixture/qkv_0_weight'
  mp=eroot/'build/model-q8-session-v2-actual-r2-20261010/manifest.json';assert sha(mp)=='46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c'
  files=[Path(__file__),GUARD,HELPER,MOD/'tb/m011_layer_fixture.py',eroot/'tests/full_reference.py',mp,base/'oracle/full_forward_oracle_report.json',eroot/'build/cpu-embedding-requests-v4-20261010/B1_from_b0_S128.request.bin',eroot/'build/cpu-embedding-requests-v4-20261010/identity_manifest.json',reuse/'fixture.json',reuse/'expected_f32.bin']+[base/'oracle/B1_from_b0_S128'/(n+'.f32.bin')for n in('embedding_norm','encoder_00_out','type_add')]
  for src in files:
   dst=f/src.name
   if dst.exists():assert sha(src)==sha(dst),'immutable input differs; fresh AT required'
   else:shutil.copy2(src,dst)
  model=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf');assert model.stat().st_size==455179648
  manifest={'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'host':socket.gethostname(),'scope':'M007/SM011 HEAD16-06 E010/R003 original local B1 reference only','desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','files':[{'source':str(s.relative_to(ROOT)),'frozen':s.name,'sha256':sha(s),'bytes':s.stat().st_size}for s in files],'external_model':{'path':str(model),'bytes':model.stat().st_size,'full_sha_inherited':'6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18','actual_read_tensor_hashes_verified_and_payload_saved_by_generator':True},'independent_caps_seconds':{'reference':900,'static':1800,'rtl':7200,'ooc':600},'per_process_first_pilot_seconds':120}
  if not(at/'source_manifest.json').exists():dump(at/'source_manifest.json',manifest)
  out=at/'guard_reference';assert not out.exists(),'preserve prior run'
  cmd=[sys.executable,str(f/'m011_layer_fixture.py'),'--input',str(f),'--model',str(model),'--out',str(w/'oracle')]
  argv=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(w),'--rss-gib','16','--timeout-seconds','120','--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',*cmd];dump(at/'command_reference.json',{'argv':argv,'lock':'m007_heavy.lock through all descendants','resources':'CPU0-3/nice19/idle MemAvailable>192GiB RSS<=16GiB','R003_budget':'independent; no R002/E012 transfer'})
  (RUN/'run.md').write_text('# E010 R003 actual launch\n\nExecution state: running\nVerdict: unassessed\n\nAuthority: SM011 HEAD16-06; current actual original local-reference pilot '+a.attempt+'.\nExact command, source/input identities and guard: attempts/'+a.attempt+'/command_reference.json and source_manifest.json.\nNo RTL/16head/RoPE implementation PASS is inferred from this launch.\n')
  rc=subprocess.call(argv,cwd=w);g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text(errors='replace');marker='M011_LAYER_REFERENCE_PASS';ok=rc==0 and marker in log
  dump(at/'receipt_reference.json',{'verdict':'PASS'if ok else'COST_STOP'if g.get('trigger')else'FAIL','wrapper_exit':rc,'guard':g,'marker':marker,'marker_found':marker in log,'log_sha256':sha(out/'driver.log')})
  costs={k:0.0 for k in('reference','static','rtl','ooc')};receipts=[]
  for rp in sorted((RUN/'attempts').glob('AT*/receipt_*.json')):
   x=json.loads(rp.read_text());cat=rp.stem.removeprefix('receipt_');costs[cat]+=x['guard']['elapsed_seconds'];receipts.append({'path':str(rp.relative_to(ROOT)),'verdict':x['verdict'],'seconds':x['guard']['elapsed_seconds']})
  dump(RUN/'budget_ledger.json',{'caps_seconds':manifest['independent_caps_seconds'],'actual_seconds':costs,'receipts':receipts,'independent':'No R002/E012/other balance transfer'})
  print('reference',json.dumps(g),'PASS'if ok else'FAIL',flush=True)
  for line in log.splitlines():
   if'PASS'in line or'Error'in line or'Traceback'in line:print(line,flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
