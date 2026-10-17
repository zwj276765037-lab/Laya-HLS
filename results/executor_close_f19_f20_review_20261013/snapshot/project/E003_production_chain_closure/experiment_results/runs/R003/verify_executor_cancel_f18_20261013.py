#!/usr/bin/env python3
"""Read-only stage audit; count every manifest pair, including contracts."""
import datetime as dt
import hashlib
import json
from pathlib import Path
import re
RUN=Path(__file__).resolve().parent
NAMES=['executor_handoff_shell_rtl_04','executor_handoff_portal_rtl_04',
       'executor_cancel_drain_host_02','executor_actor_host_06','graph_program_top_host_04']
OUT=RUN/'executor_cancel_f18_verification_02_20261013.json'
def rec(p):
 p=Path(p).resolve();b=p.read_bytes();return {'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def walk(v):
 if isinstance(v,dict):
  yield v
  for x in v.values():yield from walk(x)
 elif isinstance(v,list):
  for x in v:yield from walk(x)
def match(d):
 a=rec(d['path']);return a,a['sha256']==d['sha256'] and (d.get('bytes',a['bytes'])==a['bytes'])
def audit(name):
 p=RUN/name;m=json.loads((p/'input_manifest.json').read_text());r=json.loads((p/'receipt.json').read_text())
 pairs=[]
 for x in walk(m):
  if isinstance(x.get('original'),dict) and isinstance(x.get('frozen'),dict):
   o,f=x['original'],x['frozen']
   if 'path' in o and 'sha256' in o and 'path' in f and 'sha256' in f:
    ao,cm=match(o);af,fm=match(f)
    pairs.append({'original':o,'frozen':f,'actual_current':ao,'current_match':cm,
      'actual_frozen':af,'frozen_match':fm,'declared_pair_match':o['sha256']==f['sha256'] and o['bytes']==f['bytes']})
 refs=[]
 for d in list(walk(m))+list(walk(r)):
  if 'path' in d and 'sha256' in d:
   a,ok=match(d);refs.append({'declared':d,'actual':a,'match':ok})
 directories=sorted(x for x in p.glob('guard*') if (x/'guard_result.json').is_file())
 if name=='graph_program_top_host_04':directories.append(RUN/'guard_graph_program_top_host_04')
 guards=[]
 for directory in directories:
  g=json.loads((directory/'guard_result.json').read_text());plan=json.loads((directory/'guard_plan.json').read_text())
  policies=json.loads((directory/'policy_checks.json').read_text()) if (directory/'policy_checks.json').is_file() else []
  unsampled=not g['rss_captured']
  short=unsampled and g['elapsed_seconds']<plan['sample_seconds']
  cap=8388608 if 'rtl' in name else 25165824
  checks={'exit':g['child_exit_code']==0 and g['trigger'] is None,
   'caps':plan['maximum_owned_rss_kb']<=cap and plan['maximum_seconds']<=(120 if 'rtl' in name else 1800) and plan['semantic_stall_seconds']==120,
   'time_mem':g['elapsed_seconds']<plan['maximum_seconds'] and g['minimum_mem_available_kb']>201326592 and (unsampled or (g['peak_owned_rss_kb'] is not None and g['peak_owned_rss_kb']<plan['maximum_owned_rss_kb'])),
   'policy':(unsampled and not policies) or bool(policies) and all(d['matches'] and d['affinity']==[0,1,2,3] and d['nice']==19 and d['ionice']=='idle' for d in policies)}
  guards.append({'directory':str(directory),'result':g,'plan':plan,'policy':policies,'checks':checks,
   'passed':all(checks.values()),'sampling':('configuration only; no owned-child RSS/policy sample recorded; elapsed below sample period' if short else 'configuration only; no owned-child RSS/policy sample recorded despite wrapper elapsed above sample period') if unsampled else 'actual owned-tree samples',
   'owned_RSS_observed':not unsampled, 'child_policy_observed':bool(policies),
   'artifacts':{n:rec(directory/n) for n in ['guard_plan.json','guard_result.json','policy_checks.json','driver.log','rss_samples.csv'] if (directory/n).is_file()}})
 return {'name':name,'manifest':rec(p/'input_manifest.json'),'receipt':rec(p/'receipt.json'),
   'status':r['status'],'pairs':pairs,'pair_count':len(pairs),'frozen_matches':sum(d['frozen_match'] for d in pairs),
   'declared_pair_matches':sum(d['declared_pair_match'] for d in pairs),'current_matches':sum(d['current_match'] for d in pairs),
   'references':refs,'reference_count':len(refs),'reference_matches':sum(d['match'] for d in refs),'guards':guards}
def main():
 if OUT.exists():raise RuntimeError('immutable stage audit already exists')
 data=[audit(n) for n in NAMES]
 gs=sorted([g for a in data for g in a['guards']],key=lambda x:x['plan']['at'])
 serial=all(dt.datetime.fromisoformat(a['result']['finished_at'])<=dt.datetime.fromisoformat(b['plan']['at']) for a,b in zip(gs,gs[1:]))
 mismatches=[d for a in data for d in a['pairs'] if not d['current_match']]
 delta=json.loads((RUN/'executor_cancel_f18_catalog_delta_20261013.json').read_text())
 expected={d['after']['path']:d['after']['sha256'] for d in delta['changes']}
 disclosed=all(expected.get(d['actual_current']['path'])==d['actual_current']['sha256'] for d in mismatches)
 ref_diffs=[d for a in data for d in a['references'] if not d['match']]
 disclosed=disclosed and all(expected.get(d['actual']['path'])==d['actual']['sha256'] for d in ref_diffs)
 shell=(RUN/NAMES[0]/'guard_rtl/driver.log').read_text()
 portal=(RUN/NAMES[1]/'guard/driver.log').read_text()
 cancel=(RUN/NAMES[2]/'guard_run/driver.log').read_text()
 actor=(RUN/NAMES[3]/'guard_run/driver.log').read_text()
 checks={'frozen_pairs':all(a['frozen_matches']==a['pair_count']==a['declared_pair_matches'] for a in data),
   'receipt':all(a['status']=='PASS' for a in data),'guards':all(g['passed'] for g in gs),'serial':serial,
   'live_differences_disclosed':disclosed,'F18_marker':all(x in shell for x in ['cases=19','F18_drain_abort_same_edge=1','F18_accepted_query_persistent_abort=1','response_stall_stable=1']),
   'cancel_marker':all(x in cancel for x in ['actual_program_successful_cancel_cases=3','bad_frame_cases=8','bad_key_cases=4','real_program_no_action_cases=2','runtime_byte_unchanged=1','host_result_consumed_retained_no_CLOSE_no_rearm=1']),
   'actor_compat':all(x in actor for x in ['host_windows_retired=8','F17_unread_partial_validate_cases=33','F17_active_begin_producer_cases=12']),
   'portal_marker':'FULL_CURRENT_EXECUTOR_HANDOFF_PORTAL_RTL_PASS' in portal}
 # Full capture unchanged; no mutation of the existing literal is permitted.
 capture=RUN/NAMES[1]/'fixture/actual_handoff_checkpoint.hex'
 raw=b''.join(bytes.fromhex(s.strip())[::-1] for s in capture.read_text().splitlines())
 literal=RUN/NAMES[1]/'fixture/checkpoint_good.bin'
 checks['capture_direct_literal']=raw==literal.read_bytes() and len(raw)==1024
 host=RUN/NAMES[2]/'fixture'
 layout=RUN/NAMES[2]/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_program_pending_layout_v1.sv'
 expected_layout={'BYTES':1024,'BEATS':16,'VERSION':1,'SESSION_OFFSET':16,'REQUEST_OFFSET':24,'SEQUENCE_OFFSET':32,'HANDOFF_OFFSET':40,'COMMAND_OFFSET':256,'ACTION_OFFSET':512}
 checks['static_C_SV_layout']=all(re.search(r'\b'+k+r'\s*=\s*'+str(v)+r'\b',layout.read_text()) for k,v in expected_layout.items())
 result={'schema':'laya-executor-cancel-f18-stage-verification-v1','at_utc':dt.datetime.now(dt.timezone.utc).isoformat(),
   'checks':checks,'passed':all(checks.values()),'attempts':data,
   'pair_count':sum(a['pair_count'] for a in data),'frozen_matches':sum(a['frozen_matches'] for a in data),
   'declared_pair_matches':sum(a['declared_pair_matches'] for a in data),'current_matches':sum(a['current_matches'] for a in data),
   'references':sum(a['reference_count'] for a in data),'reference_matches':sum(a['reference_matches'] for a in data),
   'resource_observation_complete':all(g['owned_RSS_observed'] and g['child_policy_observed'] for g in gs),
   'resource_observation_scope':'Configured owned-tree guards/exit/time/MemAvailable checked; actual RSS/policy signed only for sampled children. Unobserved child maxima/policy remain unknown.',
   'stage_count':len(gs),'actual_policy_records':sum(len(g['policy']) for g in gs),'serial_no_overlap':serial,
   'capture':rec(capture),'direct_literal':rec(literal),'raw_capture_sha256':hashlib.sha256(raw).hexdigest(),
   'LAP1_and_error_literals':{n:rec(host/n) for n in ['pending.bin','cancel_completion.bin','cancel_result.bin']},
   'LAP1_SV_layout_scope':'static constants only, no SV execution of LAP1 or generated bound program top',
   'limits':['unsampled guard children have no observed owned-RSS/policy claim, including actor_06 run elapsed1.224335s with one RSS sample and zero child capture', 'software streams unbounded; delays do not sign real depth2','controlled HELD/GRANT/K forwarding and fences','no bound CLOSE or accepted-request hardware rearm','revoked consumed result stays closed','production wrapper/source protection and legal post-handoff Q lease pending','no executor HLS/new OOC/P&R/board; G2338.224019s unchanged']}
 OUT.write_text(json.dumps(result,indent=2)+'\n')
 print({k:result[k] for k in ['passed','pair_count','frozen_matches','current_matches','references','reference_matches','stage_count','actual_policy_records','serial_no_overlap']})
 if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
