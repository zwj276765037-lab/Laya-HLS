#!/usr/bin/env python3
"""Static evidence audit; no DUT, simulator or oracle runner is executed."""
import datetime as dt,hashlib,json,re,struct
from pathlib import Path
import verify_executor_cancel_f18_20261013 as common
R=Path(__file__).resolve().parent
NAMES=['executor_request_close_shell_rtl_04','executor_request_close_host_06','executor_actor_host_08',
       'executor_handoff_portal_rtl_15','executor_handoff_portal_rtl_16']
OUT=R/'executor_close_f19_f20_verification_20261013.json'
def raw(p):return b''.join(bytes.fromhex(x)[::-1] for x in Path(p).read_text().split())
def main():
 if OUT.exists():raise RuntimeError('immutable audit exists')
 attempts=[common.audit(n) for n in NAMES]
 guards=sorted([g for a in attempts for g in a['guards']],key=lambda g:g['plan']['at'])
 serial=all(dt.datetime.fromisoformat(a['result']['finished_at'])<=dt.datetime.fromisoformat(b['plan']['at']) for a,b in zip(guards,guards[1:]))
 history=json.loads((R/'executor_close_f19_f20_history_20261013.json').read_text())
 allowed={d['current']['path']:d['current']['sha256'] for d in history['live_differences']}
 diffs=[d for a in attempts for d in a['pairs'] if not d['current_match']]
 refs=[d for a in attempts for d in a['references'] if not d['match']]
 checks={'all_frozen_declared_pairs':all(a['frozen_matches']==a['declared_pair_matches']==a['pair_count'] for a in attempts),
  'all_selected_receipts_PASS':all(a['status']=='PASS' for a in attempts),
  'guard_configuration_exit_time_memory':all(g['passed'] for g in guards),'serial_no_overlap':serial,
  'current_differences_disclosed':all(allowed.get(d['actual_current']['path'])==d['actual_current']['sha256'] for d in diffs) and all(allowed.get(d['actual']['path'])==d['actual']['sha256'] for d in refs)}
 h=R/NAMES[1]/'fixture';old=R/'executor_actor_host_06/fixture'
 legacy=['all_control.bin']+['control_'+str(i)+'.bin' for i in range(1,8)]
 checks['all_original_7_literals_unchanged']=all((h/n).read_bytes()==(old/n).read_bytes() for n in legacy)
 # Reconstruct eight literal controls from the independent request layout,
 # never from a shell/actor-produced terminal.
 base=bytearray((h/'v2/checkpoint_request.bin').read_bytes())
 struct.pack_into('<IHH',base,0,0x3143484c,1,16);struct.pack_into('<Q',base,32,(1<<64)-1)
 struct.pack_into('<QQ',base,776,29,101);literal=[]
 for kind in [8,9]:
  for failed in [False,True]:
   for commit in [0,1]:
    p=bytearray(base);p[8]=kind;p[792]=commit;struct.pack_into('<Q',p,680,19)
    if failed:struct.pack_into('<H',p,10,7);struct.pack_into('<I',p,24,0x0700000e)
    n=('close' if kind==8 else 'closed')+('_error' if failed else '_ok')+'_c'+str(commit)
    checks['literal_'+n]=(h/(n+'.bin')).read_bytes()==p;literal.append(common.rec(h/(n+'.bin')))
 captures=[]
 for status in ['ok','error']:
  for commit in [0,1]:
   name='closed_'+status+'_c'+str(commit);source=R/NAMES[0]/'fixture'/(name+'_capture.hex')
   b=raw(source);gold=raw(source.parent/(name+'.hex'))
   cpp=R/NAMES[1]/'frozen/external/closed_results'/(name+'_capture.hex')
   checks['actual_'+name]=len(b)==1024 and b==gold and b==(h/('shell_'+name+'.bin')).read_bytes() and source.read_bytes()==cpp.read_bytes()
   captures.append({'name':name,'RTL':common.rec(source),'CPP_frozen':common.rec(cpp),'literal':common.rec(source.parent/(name+'.hex')),'raw_sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)})
 shell=(R/NAMES[0]/'guard_rtl/driver.log').read_text();host=(R/NAMES[1]/'guard_run/driver.log').read_text()
 actor=(R/NAMES[2]/'guard_run/driver.log').read_text();normal=(R/NAMES[3]/'guard/driver.log').read_text();cancel=(R/NAMES[4]/'guard/driver.log').read_text()
 checks['shell_control_close']=all(x in shell for x in ['cases=19','close_cases=17','cycles=4901','F20_cases=22','terminal_control_independent=1','terminal_full_handshake=1','observed_IMPORT_commit=1','same_edge_CLOSE=1','owned_query_cleanup=1','terminal_same_edge_no_start=1','full_closed_consumer=1','old_cancel_close_progress=1','response_stall_stable=1'])
 checks['host_true_results_close']=all(x in host for x in ['wire_literals=8','wire_mutants=156','real_success_cases=1','real_cancel_cases=3','real_no_action_cases=2','actual_closed_rtl_capture_frames=4','F19_boundary_cases=6','managed_legacy_fact_separate=1','tagged_final_transition_retained=1','host_full_result_required=1','runtime_unchanged_close=1'])
 checks['F19_six_individual_markers']=len(re.findall(r'^F19_RESULT_BOUNDARY_PASS case=[0-5] ',host,re.M))==6
 checks['all_primary_markers_are_original_line_start']=all(re.search(r'^'+marker+r' .*$',body,re.M) for marker,body in [('FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_RTL_PASS',shell),('FULL_CURRENT_EXECUTOR_REQUEST_CLOSE_PASS',host),('FULL_CURRENT_EXECUTOR_ACTOR_PASS',actor),('FULL_CURRENT_EXECUTOR_HANDOFF_PORTAL_RTL_PASS',normal),('FULL_CURRENT_EXECUTOR_HANDOFF_PORTAL_RTL_PASS',cancel)])
 checks['actor_F17_compat']=all(x in actor for x in ['host_windows_retired=8','F17_unread_partial_validate_cases=33','F17_active_begin_producer_cases=12'])
 checks['normal_wrapper_compat']=all(x in normal for x in ['FULL_CURRENT_EXECUTOR_HANDOFF_PORTAL_RTL_PASS','real_predecessor_AW=112 W=7168 B=112','lpv_seq=180','helper_import_offline=1'])
 checks['partial_query_cancel_compat']=all(x in cancel for x in ['query_case=1','old_query_ingress=16','real_response_reads=16','bound_abort_once=1','hub_terminals=7','no_auto_reopen=1'])
 layout=(R/NAMES[0]/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_handoff_layout_v1.sv').read_text()
 checks['C_SV_8_9_static_layout']=all(re.search(r'\b'+name+r'\s*=\s*'+str(value)+r'\b',layout) for name,value in [('CONTROL_BYTES',1024),('CONTROL_BEATS',16),('CONTROL_VERSION',1),('CLOSE',8),('CLOSED',9),('SESSION_OFFSET',776),('COMMITTED_OFFSET',792)])
 warnings={NAMES[1]:host.count('contains leftover data'),NAMES[2]:actor.count('contains leftover data')}
 result={'schema':1,'at_utc':dt.datetime.now(dt.timezone.utc).isoformat(),'checks':checks,'passed':all(checks.values()),
  'attempts':attempts,'pairs':sum(a['pair_count'] for a in attempts),'frozen_matches':sum(a['frozen_matches'] for a in attempts),
  'declared_pair_matches':sum(a['declared_pair_matches'] for a in attempts),'current_matches':sum(a['current_matches'] for a in attempts),
  'references':sum(a['reference_count'] for a in attempts),'reference_matches':sum(a['reference_matches'] for a in attempts),
  'guards':len(guards),'actual_policy_records':sum(len(g['policy']) for g in guards),'serial_no_overlap':serial,
  'resource_observation_complete':all(g['owned_RSS_observed'] and g['child_policy_observed'] for g in guards),
  'resource_scope':'Only actual sampled children have RSS/policy evidence. Short oracle/run, fixture and -MM configuration do not become observed guard evidence.',
  'captures':captures,'control_literals':literal,'intentional_stream_leftover_warnings':warnings,
  'limits':['shell 8192-bit atomic consumer and terminal/work/Host/physical records controlled; no actual depth2 CLOSED stream',
    'six separate software runtime cases; no accepted-request hardware lifecycle rearm',
    'actual shell captures only offline C++ codec roundtrip; controlled CLOSED reply does not sign same hardware consumer',
    'managed-close production wrapper still default-disabled; no local no-LGP accepted error result or admission_closed(A)',
    'active LPV persistent cancellation, old half-frame/END/last-B/return cleanup still pending',
    'new bound candidate ingress and persistent allocator/highwater begin/recycle repair pending',
    'source all-entry protection/LAP1/action/F10/QUANT lease/executor HLS/production full chain pending',
    'G2338.224019s/all original caps retained; no new HLS/OOC/P&R/board/agents; no combination restart']}
 OUT.write_text(json.dumps(result,indent=2)+'\n')
 print({k:result[k] for k in ['passed','pairs','frozen_matches','current_matches','references','reference_matches','guards','actual_policy_records','resource_observation_complete']})
 if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
