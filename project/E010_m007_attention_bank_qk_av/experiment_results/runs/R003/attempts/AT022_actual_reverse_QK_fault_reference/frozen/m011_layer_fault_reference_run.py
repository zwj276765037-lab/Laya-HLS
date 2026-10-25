#!/usr/bin/env python3
import datetime,fcntl,hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];RUN=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003';GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
 print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
 at=RUN/'attempts/AT022_actual_reverse_QK_fault_reference';f=at/'frozen';w=at/'work';f.mkdir(parents=True,exist_ok=False);w.mkdir();orig=RUN/'attempts/AT001_original_b1_three_layer_local_reference';files=[Path(__file__),GUARD,HELPER,MOD/'tb/m011_layer_fault_fixture.py',orig/'frozen/full_reference.py']+[orig/'work/oracle'/n for n in('decision0_pre_qkv.bin','mask.mem','manifest.json')]
 for p in files:shutil.copy2(p,f/p.name)
 dump(at/'source_manifest.json',{'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'actual finite perturbation of original B1 Decision0; original independent logical-order exception only','files':[{'source':str(p.relative_to(ROOT)),'frozen':p.name,'sha256':sha(p),'bytes':p.stat().st_size}for p in files]})
 import m011_layer_integration_run as common
 costs=common.ledger();assert costs['reference']+120<=900
 out=at/'guard_reference';cmd=[sys.executable,str(GUARD),'--out',str(out),'--cwd',str(w),'--rss-gib','16','--timeout-seconds','120','--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',sys.executable,str(f/'m011_layer_fault_fixture.py'),'--input',str(f),'--out',str(w/'oracle')];dump(at/'command_reference.json',{'argv':cmd,'project_lock':'m007_heavy.lock through all descendants'});rc=subprocess.call(cmd);g=json.loads((out/'guard_result.json').read_text());log=(out/'driver.log').read_text();ok=rc==0 and'M011_LAYER_FAULT_REFERENCE_PASS'in log
 dump(at/'receipt_reference.json',{'verdict':'PASS'if ok else'COST_STOP'if g.get('trigger')else'FAIL','guard':g,'wrapper_exit':rc,'marker_found':'M011_LAYER_FAULT_REFERENCE_PASS'in log,'log_sha256':sha(out/'driver.log')});common.ledger();print(json.dumps(g),'PASS'if ok else'FAIL',flush=True)
 for line in log.splitlines():
  if'PASS'in line or'Traceback'in line or'Error'in line:print(line,flush=True)
 raise SystemExit(0 if ok else 1)
