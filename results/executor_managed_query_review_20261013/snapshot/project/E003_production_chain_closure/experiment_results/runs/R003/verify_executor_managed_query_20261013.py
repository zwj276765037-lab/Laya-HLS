#!/usr/bin/env python3
"""Stage evidence audit; every pair/contract and all guard samples counted."""
import datetime as dt,hashlib,json
from pathlib import Path
import verify_executor_cancel_f18_20261013 as common
RUN=Path(__file__).resolve().parent
NAMES=['executor_handoff_portal_rtl_06','executor_handoff_portal_rtl_07',
 'executor_handoff_portal_rtl_08','executor_handoff_portal_rtl_09','executor_handoff_portal_rtl_10',
 'executor_handoff_shell_rtl_05','executor_checkpoint_rtl_08','bootstrap_source_guard_rtl_10',
 'generated_store_monitor_rtl_16','executor_managed_query_decode_host_02']
OUT=RUN/'executor_managed_query_verification_20261013.json'
def raw(path):return b''.join(bytes.fromhex(x)[::-1] for x in Path(path).read_text().split())
def main():
 if OUT.exists():raise RuntimeError('immutable audit exists')
 data=[common.audit(n) for n in NAMES]
 gs=sorted([g for d in data for g in d['guards']],key=lambda g:g['plan']['at'])
 serial=all(dt.datetime.fromisoformat(a['result']['finished_at'])<=dt.datetime.fromisoformat(b['plan']['at']) for a,b in zip(gs,gs[1:]))
 history=json.loads((RUN/'executor_managed_query_history_20261013.json').read_text())
 allowed={d['current']['path']:d['current']['sha256'] for d in history['live_differences']}
 drift=[d for a in data for d in a['pairs'] if not d['current_match']]
 refs=[d for a in data for d in a['references'] if not d['match']]
 disclosed=all(allowed.get(d['actual_current']['path'])==d['actual_current']['sha256'] for d in drift) and all(allowed.get(d['actual']['path'])==d['actual']['sha256'] for d in refs)
 checks={'all_frozen_pairs':all(d['pair_count']==d['frozen_matches']==d['declared_pair_matches'] for d in data),
  'all_receipts':all(d['status']=='PASS' for d in data),'guard_configuration_exit_time_memory':all(g['passed'] for g in gs),
  'serial':serial,'live_differences_disclosed':disclosed}
 captures=[]
 for name,case in zip(NAMES[:3],[1,2,3]):
  p=RUN/name;receipt=json.loads((p/'receipt.json').read_text());body=(p/'guard/driver.log').read_text()
  actual=raw(p/'fixture/actual_handoff_checkpoint.hex')
  expected=raw(p/'control_fixture'/('revoked_proof_gold.hex' if case<3 else 'proof.hex'))
  checks[name+'_oracle']=len(actual)==1024 and actual==expected
  checks[name+'_markers']=all(v in body for v in ['query_case='+str(case),'old_query_ingress=16','real_response_reads=16','bound_abort_once=1','no_auto_reopen=1','hub_terminals=7','lpv_seq=179'])
  captures.append({'case':case,'file':common.rec(p/'fixture/actual_handoff_checkpoint.hex'),
   'literal':common.rec(p/'control_fixture'/('revoked_proof_gold.hex' if case<3 else 'proof.hex')),
   'raw_sha256':hashlib.sha256(actual).hexdigest(),'literal_equal':actual==expected})
 normal=(RUN/NAMES[4]/'guard/driver.log').read_text();shell=(RUN/NAMES[5]/'guard_rtl/driver.log').read_text()
 mismatch=(RUN/NAMES[3]/'guard/driver.log').read_text();host=(RUN/NAMES[9]/'guard_run/driver.log').read_text()
 checks['normal_wrapper']=all(x in normal for x in ['real_predecessor_AW=112 W=7168 B=112','lpv_seq=180','lastread_no_authority=1','helper_import_offline=1'])
 checks['full_wrong_binding_isolated']=all(x in mismatch for x in ['actual_ingress=16','accepted_queries=0','trusted_returns=0','full_binding_isolation=1'])
 checks['F18_compat']=all(x in shell for x in ['cases=19','F18_drain_abort_same_edge=1','F18_accepted_query_persistent_abort=1','response_stall_stable=1'])
 checks['real_cpp_capture']=all(x in host for x in ['actual_frames=3','negative_roundtrip=2','stable_success_revoked=1','atomic_no_import=3','wire_rejects=54'])
 # This code identity is common across all five selected actual wrapper runs.
 core=['laya_executor_checkpoint_transport_v2.sv','laya_executor_handoff_shell_v1.sv',
  'laya_generated_provenance_hub_v1.sv','laya_generated_provenance_axi_portal_v1.sv',
  'laya_executor_handoff_portal_shell_v1.sv']
 identities={name:sorted({d['original']['sha256'] for a in data[:5] for d in a['pairs'] if Path(d['original']['path']).name==name}) for name in core}
 checks['common_wrapper_DUT_identity']=all(len(v)==1 for v in identities.values())
 result={'schema':1,'at_utc':dt.datetime.now(dt.timezone.utc).isoformat(),'checks':checks,'passed':all(checks.values()),
  'attempts':data,'pairs':sum(a['pair_count'] for a in data),'frozen_matches':sum(a['frozen_matches'] for a in data),
  'declared_pair_matches':sum(a['declared_pair_matches'] for a in data),'current_matches':sum(a['current_matches'] for a in data),
  'references':sum(a['reference_count'] for a in data),'reference_matches':sum(a['reference_matches'] for a in data),
  'guards':len(gs),'actual_policy_records':sum(len(g['policy']) for g in gs),'serial_no_overlap':serial,
  'resource_observation_complete':all(g['owned_RSS_observed'] and g['child_policy_observed'] for g in gs),
  'resource_observation_scope':'Actual sampled children only; fixture generators and -MM retain launcher/timeout/RLIMIT bounds only; short host run has no inferred RSS/policy sample.',
  'captures':captures,'core_identities':identities,'limits':['controlled wide shell current/admission/predecessor-done facts',
  'actual helper remains offline; captures do not authorize canceled hardware',
  'query-only cancel runs begin with LPV drained; active LPV cancel/half-frame reset semantics not covered',
  'CLOSE/CLOSED/new-request handshake not implemented in this identity',
  'no source AR/F9/LAP1 hardware/QUANT lease/full13BO or executor HLS acceptance',
  'G2338.224019s and all original caps unchanged; no combination restart/OOC/P&R/board/agent']}
 OUT.write_text(json.dumps(result,indent=2)+'\n')
 print({k:result[k] for k in ['passed','pairs','frozen_matches','current_matches','references','reference_matches','guards','actual_policy_records','resource_observation_complete']})
 if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
