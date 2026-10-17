#!/usr/bin/env python3
"""Read-only frozen identity and guard audit for the bounded checkpoint stage."""
import datetime as dt
import hashlib
import json
from pathlib import Path
import re

RUN=Path(__file__).resolve().parent
NAMES=['executor_checkpoint_host_04','executor_bootstrap_host_04','task_lifecycle_fsm_host_04','graph_lifecycle_split_host_05']
WRAPPERS={'executor_bootstrap_host_04':'checkpoint_final_compat_v1_guard','task_lifecycle_fsm_host_04':'checkpoint_final_compat_fsm_guard','graph_lifecycle_split_host_05':'checkpoint_final_compat_sync_guard'}
def rec(p):
 p=Path(p).resolve();b=p.read_bytes();return {'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def refs(v,out):
 if isinstance(v,dict):
  if all(k in v for k in ('path','bytes','sha256')):
   actual=rec(v['path']);out.append({'declared':v,'actual':actual,'match':v==actual})
  for x in v.values():refs(x,out)
 elif isinstance(v,list):
  for x in v:refs(x,out)
def guard(directory):
 r=json.loads((directory/'guard_result.json').read_text());p=json.loads((directory/'guard_plan.json').read_text())
 policy=json.loads((directory/'policy_checks.json').read_text())
 body=(directory/'driver.log').read_text(errors='replace')
 checks={'child':r['child_exit_code']==0 and r['trigger'] is None,'limits':p['maximum_owned_rss_kb']<=25165824 and p['maximum_seconds']<=1800 and p['semantic_stall_seconds']==120 and r['elapsed_seconds']<p['maximum_seconds'] and r['peak_owned_rss_kb'] is not None and r['peak_owned_rss_kb']<p['maximum_owned_rss_kb'] and r['minimum_mem_available_kb']>201326592,'policy':bool(policy) and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy),'log':'ERROR:' not in body and 'Assertion' not in body}
 return {'directory':str(directory),'result':r,'plan':p,'policy_count':len(policy),'checks':checks,'passed':all(checks.values()),'artifacts':{n:rec(directory/n) for n in ['guard_plan.json','guard_result.json','policy_checks.json','rss_samples.csv','driver.log'] if (directory/n).is_file()}}
def verify(name):
 a=RUN/name;m=json.loads((a/'input_manifest.json').read_text());r=json.loads((a/'receipt.json').read_text())
 pairs=list(m['files'])
 for key in ['contract','bootstrap_contract']:
  if key in m:pairs.append(m[key])
 checked=[]
 for p in pairs:
  o,f=rec(p['original']['path']),rec(p['frozen']['path'])
  checked.append({'original':p['original'],'frozen':p['frozen'],'actual_current':o,'actual_frozen':f,'current_match':o==p['original'],'frozen_match':f==p['frozen'],'pair_match':p['original']['sha256']==p['frozen']['sha256']})
 references=[];refs(m,references);refs(r,references)
 dirs=sorted(p for p in a.glob('guard_*') if p.is_dir())
 if name in WRAPPERS:dirs.append(RUN/WRAPPERS[name])
 guards=[guard(p) for p in dirs]
 launcher=json.loads((a/'launcher.json').read_text())
 checks={'receipt':r['status']=='PASS','current':all(x['current_match'] for x in checked),'frozen':all(x['frozen_match'] for x in checked),'pairs':all(x['pair_match'] for x in checked),'references':all(x['match'] for x in references),'guards':bool(guards) and all(x['passed'] for x in guards),'launcher':launcher['pass']}
 result={'attempt':name,'checks':checks,'passed':all(checks.values()),'pair_count':len(checked),'pairs':checked,'reference_count':len(references),'references':references,'guards':guards,'deliverables':{n:rec(a/n) for n in ['input_manifest.json','receipt.json']}}
 return result

def main():
 out=RUN/'executor_checkpoint_verification_20261013.json'
 if out.exists():raise RuntimeError('verification already exists')
 data=[verify(n) for n in NAMES]
 stages=sorted([g for x in data for g in x['guards']],key=lambda x:x['plan']['at'])
 serial=all(dt.datetime.fromisoformat(a['result']['finished_at'])<=dt.datetime.fromisoformat(b['plan']['at']) for a,b in zip(stages,stages[1:]))
 layout=RUN/NAMES[0]/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_checkpoint_layout_v2.sv'
 text=layout.read_text()
 values={'BYTES':1024,'BEATS':16,'VERSION_VALUE':2,'MODE_VALUE':1,'VERSION':4,'BEAT_COUNT':6,'PURPOSE':8,'STATUS':10,'FLAGS':12,'SEQUENCE':16,'DETAIL':24,'BAD':32,'BASE_EPOCH':40,'BASE_ADDRESS':48,'BASE_CAPACITY':56,'IDENTITY':64,'MODEL_IDENTITY':160,'OWNER':576,'MODE':672,'TARGET':674,'TARGET_STATE':678,'HANDOFF':680,'TARGET_BASE':688,'KNOWN':744,'COMPLETE':748,'TASK_FLOOR':752,'SOURCE_EPOCH_FLOOR':756,'TARGET_EPOCH_FLOOR':760,'LPV_FLOOR':768,'SUCCESS_FLAGS':255,'ERROR_FLAGS':3,'DOMAINS':15}
 parity=all(re.search(r'\b'+k+r'\s*=\s*'+str(v)+r'\b',text) for k,v in values.items())
 result={'schema':'laya-executor-checkpoint-stage-verification-v2','at_utc':dt.datetime.now(dt.timezone.utc).isoformat(),'attempts':data,'passed':serial and parity and all(x['passed'] for x in data),'total_pairs':sum(x['pair_count'] for x in data),'total_references':sum(x['reference_count'] for x in data),'actual_policy_records':sum(x['policy_count'] for x in stages),'stage_count':len(stages),'serial_no_overlap':serial,'sv_literal_layout_parity':{'passed':parity,'layout':rec(layout),'expected_values':values,'scope':'literal constants only; SV logic not generated or simulated'},'new_v2_scope':'PASS_SCOPED_HOST with controlled snapshot/fence/remote; RTL authority and handoff pending'}
 out.write_text(json.dumps(result,indent=2)+'\n')
 print({k:result[k] for k in ['passed','total_pairs','total_references','stage_count','actual_policy_records','serial_no_overlap']})
 if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
