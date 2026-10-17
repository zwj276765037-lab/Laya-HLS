#!/usr/bin/env python3
"""Audit frozen evidence only. Never run a DUT or rewrite previous artifacts."""
import datetime as dt,hashlib,json,re,struct
from pathlib import Path
import verify_executor_cancel_f18_20261013 as common
R=Path(__file__).resolve().parent
NAMES=['executor_admission_owner_host_02','executor_actor_host_09','executor_managed_lpv_rtl_04',
       'generated_store_monitor_rtl_17','executor_handoff_portal_rtl_17','executor_handoff_portal_rtl_18','executor_checkpoint_rtl_09']
OUT=R/'executor_managed_lpv_verification_20261013.json'
def raw(p):return b''.join(bytes.fromhex(x)[::-1] for x in Path(p).read_text().split())
def pairs(n):
 return {x['original']['path']:x['frozen'] for x in common.walk(json.loads((R/n/'input_manifest.json').read_text()))
         if isinstance(x.get('original'),dict) and isinstance(x.get('frozen'),dict)}
def main():
 if OUT.exists():raise RuntimeError('immutable evidence audit already exists')
 attempts=[common.audit(n) for n in NAMES]
 guards=sorted([g for a in attempts for g in a['guards']],key=lambda g:g['plan']['at'])
 serial=all(dt.datetime.fromisoformat(a['result']['finished_at'])<=dt.datetime.fromisoformat(b['plan']['at']) for a,b in zip(guards,guards[1:]))
 changes=json.loads((R/'executor_managed_lpv_catalog_delta_20261013.json').read_text())['changes']
 allowed={d['after']['path']:d['after']['sha256'] for d in changes}
 differences=[d for a in attempts for d in a['pairs'] if not d['current_match']]
 references=[d for a in attempts for d in a['references'] if not d['match']]
 checks={'frozen_all':all(a['frozen_matches']==a['pair_count']==a['declared_pair_matches'] for a in attempts),
   'selected_PASS':all(a['status']=='PASS' for a in attempts),'guards':all(g['passed'] for g in guards),'serial':serial,
   'catalog_only_current_difference':all(allowed.get(d['actual_current']['path'])==d['actual_current']['sha256'] for d in differences) and
      all(allowed.get(d['actual']['path'])==d['actual']['sha256'] for d in references)}
 host=R/NAMES[0];rtl=R/NAMES[2]
 a=(host/'fixture/actual_admission_owner.bin').read_bytes();literal=(host/'fixture/admission_owner.bin').read_bytes()
 checks['full_actual_A_literal_RTL_equal']=len(a)==1024 and a==literal and a==raw(rtl/'fixture/admission.hex') and a==(rtl/'frozen/external/admission_host/fixture/actual_admission_owner.bin').read_bytes()
 checks['A_schema']=struct.unpack_from('<IHHIIQQ',a)==(0x3144414c,1,16,3,64,29,101) and struct.unpack_from('<QQQ',a,720)==(7,0x1200000000,16920576)
 logs={n:((R/n/'guard_run/driver.log') if (R/n/'guard_run').exists() else (R/n/'guard/driver.log')).read_text() for n in NAMES}
 checks['actual_host_A_marker']=all(x in logs[NAMES[0]] for x in ['FULL_CURRENT_ADMISSION_OWNER_HOST_PASS','wire_rejects=22','capture_rejects=7','actual_LYRQ_LYMP=1','before_HOLD=1','runtime_unchanged=1'])
 checks['actual_direct_capture_source']='admission_owner::encode(state->admitted_owner)' in (host/'frozen/tests/executor_actor_test.cpp').read_text()
 checks['F19_and_close_compat']=all(x in logs[NAMES[0]] for x in ['F19_boundary_cases=6','real_success_cases=1','real_cancel_cases=3','real_no_action_cases=2','runtime_unchanged_close=1','actual_closed_rtl_capture_frames=4'])
 checks['F17_actor_compat']=all(x in logs[NAMES[1]] for x in ['host_windows_retired=8','F17_unread_partial_validate_cases=33','F17_active_begin_producer_cases=12'])
 body=logs[NAMES[2]]
 checks['seven_actual_RTL_cases']=len(re.findall(r'^FULL_CURRENT_MANAGED_LPV_CASE_PASS case=[1-7] ',body,re.M))==7 and all(x in body for x in ['cases=7','cycles=1441','A_wire_rejects=22','depth2_16_8=1','unique_hub=1','route_tagged=1','persistent_revoke=1','no_reset_within_case=1','rearm_NOT_RUN=1'])
 checks['END_claim_partial_cases']=all(x in body for x in ['claim_only=1','wrong_A_route_no_pop=1','precise_cleanup=1','partial2_then_persistent_base_cancel=1','held_B=12 adapter_fence=12','typed_once=1','actual_AW_W_B=1','first_ever_LPV_already_owned_pending=1','bad_reserved_isolated=1','actual_legal_lease_NOT_RUN=1'])
 checks['default_monitor_compat']='FULL_CURRENT_GENERATED_STORE_MONITOR_PASS' in logs[NAMES[3]] and all(x in logs[NAMES[3]] for x in ['aw=18 w=1027 b=19','terminal=4','recovery=1'])
 checks['normal_query_compat']=all(x in logs[NAMES[4]] for x in ['FULL_CURRENT_EXECUTOR_HANDOFF_PORTAL_RTL_PASS','real_predecessor_AW=112 W=7168 B=112','lpv_seq=180','helper_import_offline=1'])
 checks['persistent_query_compat']=all(x in logs[NAMES[5]] for x in ['query_case=1','old_query_ingress=16','real_response_reads=16','bound_abort_once=1','hub_terminals=7','no_auto_reopen=1'])
 checks['default_checkpoint_compat']='FULL_CURRENT_EXECUTOR_CHECKPOINT_RTL_PASS' in logs[NAMES[6]]
 checks['all_marker_line_start']=all(re.search(r'^FULL_CURRENT_.*PASS',v,re.M) for v in logs.values())
 # Old immutable captures must still be present and byte-identical in this host.
 closed=[]
 for status in ['ok','error']:
  for commit in [0,1]:
   name='closed_'+status+'_c'+str(commit)
   source=R/'executor_request_close_shell_rtl_04/fixture'/(name+'_capture.hex')
   target=host/'frozen/external/closed_results'/(name+'_capture.hex')
   checks['old_'+name]=source.read_bytes()==target.read_bytes() and raw(source)==(host/'fixture'/('shell_'+name+'.bin')).read_bytes()
   closed.append({'source':common.rec(source),'host':common.rec(target),'raw_sha256':hashlib.sha256(raw(source)).hexdigest()})
 history=[]
 for before,after in [('executor_admission_owner_host_01','executor_admission_owner_host_02'),('executor_managed_lpv_rtl_01','executor_managed_lpv_rtl_02'),('executor_managed_lpv_rtl_02','executor_managed_lpv_rtl_03'),('executor_managed_lpv_rtl_03','executor_managed_lpv_rtl_04'),('executor_actor_host_08','executor_actor_host_09'),('generated_store_monitor_rtl_16','generated_store_monitor_rtl_17'),('executor_handoff_portal_rtl_15','executor_handoff_portal_rtl_17'),('executor_handoff_portal_rtl_16','executor_handoff_portal_rtl_18'),('executor_checkpoint_rtl_08','executor_checkpoint_rtl_09')]:
  b,c=pairs(before),pairs(after)
  history.append({'before':before,'after':after,'common':len(b.keys()&c.keys()),'changed':[{'original':n,'before':b[n],'after':c[n]} for n in sorted(b.keys()&c.keys()) if b[n]['sha256']!=c[n]['sha256']], 'added':[c[n] for n in sorted(c.keys()-b.keys())],'removed':[b[n] for n in sorted(b.keys()-c.keys())]})
 result={'schema':1,'at_utc':dt.datetime.now(dt.timezone.utc).isoformat(),'passed':all(checks.values()),'checks':checks,'attempts':attempts,
  'pairs':sum(a['pair_count'] for a in attempts),'frozen_matches':sum(a['frozen_matches'] for a in attempts),'declared_pair_matches':sum(a['declared_pair_matches'] for a in attempts),'current_matches':sum(a['current_matches'] for a in attempts),
  'references':sum(a['reference_count'] for a in attempts),'reference_matches':sum(a['reference_matches'] for a in attempts),
  'guards':len(guards),'actual_policy_records':sum(len(g['policy']) for g in guards),'serial_no_overlap':serial,'resource_observation_complete':all(g['owned_RSS_observed'] and g['child_policy_observed'] for g in guards),
  'actual_A':common.rec(host/'fixture/actual_admission_owner.bin'),'actual_A_raw_sha256':hashlib.sha256(a).hexdigest(),'closed_compat_captures':closed,
  'history':history,'original_attempts':{n:json.loads((R/n/'receipt.json').read_text())['status'] for n in ['executor_admission_owner_host_01','executor_managed_lpv_rtl_01','executor_managed_lpv_rtl_02','executor_managed_lpv_rtl_03']},
  'leftover_warnings':{NAMES[0]:logs[NAMES[0]].count('contains leftover data'),NAMES[1]:logs[NAMES[1]].count('contains leftover data')},
  'limits':['controlled wide A install; actual C++ admission bytes fed offline, no same hardware runtime ingress','controlled full adapter preowned record; actual adapter pending handshake not integrated','candidate lane changes and tagged reads tested; global HOLD physical route transition not integrated','seven reset-separated finite fixtures; no accepted-request rearm/no-reset session lifecycle','single STATE0 only, source AR/F9/legal QUANT lease/all13BO not tested','damaged model/reserved frames isolated; no automatic error recovery or all queue empty claim','actual END/one AW/W/B and hub terminal; no generated HLS adapter causality or software retirement','managed LPV remains disabled in production wrappers; true terminal/Host/CLOSED consumers and no-LGP/committed errors pending','G2338.224019s/all original caps unchanged; no HLS/OOC/P&R/board/new agents/combination restart']}
 OUT.write_text(json.dumps(result,indent=2)+'\n')
 print({k:result[k] for k in ['passed','pairs','frozen_matches','current_matches','references','reference_matches','guards','actual_policy_records','resource_observation_complete']})
 if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
