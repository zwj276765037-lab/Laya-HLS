#!/usr/bin/env python3
"""Audit already-executed R003 sources/receipts/snapshots/trace; no experiment launch."""
from datetime import datetime,timezone
from decimal import Decimal
import hashlib,json
from pathlib import Path
import tarfile
RUN=Path(__file__).resolve().parent;PROJECT=RUN.parents[4];EXPERIMENT=PROJECT/'project/E002_Laya_HLS/experiment';MODULE=EXPERIMENT/'vivado/module_design/vector_and_ffn'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
receipts=[];totals={'static':Decimal(0),'rtl':Decimal(0)};archives=[];policy_samples=0;corrections=0
for at in sorted((RUN/'attempts').glob('AT*')):
 r=json.loads((at/'receipt.json').read_text());receipts.append(r);assert r['status']=='EXIT_ZERO'and r['exit_code']==0 and r['owned_after_cleanup']==[]and r['owned_group_after_cleanup_exists']is False
 totals[r['phase']]+=Decimal(str(r['child_wall_s']))
 assert sha(at/'sources.tar.gz')==r['source_archive_sha256']
 with tarfile.open(at/'sources.tar.gz')as archive:
  expected=dict(r['source_sha256']);expected['e015_d31_protocol.md']=r['protocol_sha256'];expected['authority_SM011.md']=next(iter(r['authority_sha256'].values()))
  old={'m007_tanh_ce_run.py':'57ead93dbd4279a0a7f58add0cc9c974c36b8faddebcc565c938ece8e9991452','m007_tanh_ce_tb.sv':'58f0e9c0709ee3c03ea2b63553afc098f90d0e6f463041c3dd287e1229bb8565'}
  expected.update({str((MODULE/'tb'/name).relative_to(EXPERIMENT)):digest for name,digest in old.items()})
  assert set(archive.getnames())==set(expected)
  for name,digest in expected.items():assert hashlib.sha256(archive.extractfile(name).read()).hexdigest()==digest,name
  archives.append({'attempt':at.name,'verified_archive_files':len(expected),'sha256':sha(at/'sources.tar.gz')})
 for name,digest in r['source_sha256'].items():assert sha(EXPERIMENT/name)==digest,name
 for item in r['descendant_policy_checks']:
  assert item['nice']==19 and item['ioprio']==3<<13 and set(item['affinity'])<={0,1,2,3};policy_samples+=item['samples'];corrections+=len(item['corrections'])
reports={};snapshot_audits=[]
for variant,build_at,rtl_at in [('eq','AT001_eq_build','AT002_eq_rtl'),('v2','AT003_v2_build','AT004_v2_cost'),('v3','AT005_v3_build','AT006_v3_cost')]:
 b=RUN/'attempts'/build_at/'work';w=RUN/'attempts'/rtl_at/'work';build=json.loads((b/'report.json').read_text());report=json.loads((w/'report.json').read_text());reports[variant]=report
 pre=json.loads((w/'snapshot_prerun_sha256.json').read_text());post=json.loads((w/'snapshot_postrun_sha256.json').read_text());assert pre==build['snapshot'] and all(post[k]==v for k,v in pre.items())
 snapshot_audits.append({'variant':variant,'original_files':len(pre),'original_files_unchanged':True,'runtime_added_files':{k:v for k,v in post.items()if k not in pre},'build_manifest_sha256':sha(b/'report.json'),'RTL_report_sha256':sha(w/'report.json'),'source_audit_sha256':sha(b/'per_target_source_equivalence.json'),'expected_actual_TANH8_instances':build['expected_actual_TANH8_instances']})
 p=json.loads((RUN/'attempts'/rtl_at/'receipt.json').read_text())['semantic_progress'];assert p['last_checked']==6726 and not p['unparsed_tail'] and p['event_count']>0
assert reports['eq']['measurements']==reports['v2']['measurements']==reports['v3']['measurements']
assert reports['eq']['source_sha256']==reports['v2']['source_sha256']==reports['v3']['source_sha256']
assert reports['eq']['actual_response_trace_sha256']==reports['v2']['actual_response_trace_sha256']==reports['v3']['actual_response_trace_sha256']
assert reports['eq']['actual_response_trace_lines']==reports['v2']['actual_response_trace_lines']==reports['v3']['actual_response_trace_lines']==841
v2,v3=reports['v2']['timing'],reports['v3']['timing'];categories=['xsim_launch_to_exit_s','startup_before_TB_INIT_s','TB_fixture_initialization_s','active_and_protocol_s','explicit_idle_noise_s','shutdown_after_TB_DONE_s']
comparison={key:{'v2_s':v2[key],'v3_s':v3[key],'v2_over_v3':v2[key]/v3[key],'v3_minus_v2_s':v3[key]-v2[key]}for key in categories}
save(RUN/'standalone_cost_comparison_v1.json',{'status':'OBSERVED_SINGLE_SAMPLE_LOCAL_SIMULATOR_COST','same_workload_cycles':2671,'same_all_outputs_nodes_and_protocol_counts':True,'common_measurements':reports['v2']['measurements'],'actual_response_trace_sha256':reports['v2']['actual_response_trace_sha256'],'response_trace_lines':841,'comparison':comparison,'explicit_idle_noise_cycles':448,'active_and_protocol_stage_cycles':2223,'CE_idle_cycles_full_workload':612,'CE_active_cycles_full_workload':2044,'reset_cycles':15,'category_boundary':'flushed host-monotonic stage markers; RUN includes protocol/reset/quiescent gaps outside explicit idle_noise, not pure CE1 CPU time','total_reduction_percent':100*(1-v3['xsim_launch_to_exit_s']/v2['xsim_launch_to_exit_s']),'repeats_per_variant':1,'variation_or_confidence_interval':'NOT_MEASURED','joint_or_FPGA_speedup':'NOT_RUN','LN128_cost_gate':'UNCHANGED'})
sources=receipts[-1]['source_sha256']
manifest={'schema':'e015-d31-production-manifest-v1','created_utc':datetime.now(timezone.utc).isoformat(),'source_sha256':sources,'all_archived_current_sources_unchanged':True,'source_archive_audits':archives,'snapshot_audits':snapshot_audits,'old_core_v2_sha256':sources[str((MODULE/'rtl/laya_m007_tanh_core_v2.sv').relative_to(EXPERIMENT))],'new_core_v3_sha256':sources[str((MODULE/'rtl/laya_m007_tanh_core_v3.sv').relative_to(EXPERIMENT))],'new_wrapper_v3_sha256':sources[str((MODULE/'rtl/laya_m007_tanh8_v3.sv').relative_to(EXPERIMENT))],'same_fixture_identity':json.loads((RUN/'attempts/AT002_eq_rtl/work/input_identity.json').read_text()),'old_D26_audit_unchanged':True,'no_new_gold':True,'no_parent_or_shared_RTL_edit':True}
save(RUN/'production_manifest_v1.json',manifest)
ledger={'schema':'e015-r003-d31-budget-closure-v1','status':'BOUNDED_WORK_COMPLETE_NO_ACTIVE_OR_QUEUED_TOOL','fresh_scope':'D31 only; old R002/E020 unused balances closed and not transferred','phase_wall_s':{k:str(v)for k,v in totals.items()},'phase_cap_s':{'reference':0,'static':300,'rtl':600,'OOC':0},'unused_s':{k:str(Decimal(cap)-totals[k])for k,cap in [('static',300),('rtl',600)]},'recovery_archive_reserve_s':120,'reserve_retained':totals['static']<=180 and totals['rtl']<=480,'unused_balance_transferred':False,'attempts':[{'attempt':r['attempt'],'phase':r['phase'],'status':r['status'],'child_wall_s':r['child_wall_s'],'sampled_RSS_peak_bytes':r['RSS_sampled_peak_bytes'],'receipt_sha256':sha(RUN/'attempts'/r['attempt']/'receipt.json'),'cleanup_empty':True}for r in receipts]}
save(RUN/'budget_closure_v1.json',ledger)
delivery={'schema':'e015-r003-d31-independent-delivery-v1','status':'PASS_SOURCE_AND_SAME_RUNTIME_EQUIVALENCE_WITH_LOCAL_SINGLE_SAMPLE_COST','review_state':'PENDING_A001_SCOPE_REVIEW','runtime_id':'/root/m007_host_tail_engineering','desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','old_processes':2447,'new_processes':1,'unique_NBA_targets':2447,'unchanged_leaf_instances_per_core':42,'new_FF_bits':0,'clock_gates':0,'unchanged_valid_reset_priority_and_data_CE_no_reset':True,'measurements':reports['eq']['measurements'],'secondary_node_checks':282812,'actual_cycles':2671,'same_trace_sha256':reports['eq']['actual_response_trace_sha256'],'same_trace_lines':841,'single_sample_total_speed_ratio':comparison['xsim_launch_to_exit_s']['v2_over_v3'],'single_sample_active_protocol_ratio':comparison['active_and_protocol_s']['v2_over_v3'],'owned_policy_samples':policy_samples,'owned_ioprio_corrections':corrections,'all_cleanup_empty':True,'production_manifest_sha256':sha(RUN/'production_manifest_v1.json'),'cost_comparison_sha256':sha(RUN/'standalone_cost_comparison_v1.json'),'budget_closure_sha256':sha(RUN/'budget_closure_v1.json'),'not_run':['joint_speedup','new_parent_build_with_v3','full_LN128','OOC_PnR_physical_timing_board'],'limitation':'single local cost sample per variant, total ~1.057x; no gate or general performance claim'}
save(RUN/'independent_delivery_v1.json',delivery)
print(json.dumps({'status':delivery['status'],'new_core_sha':manifest['new_core_v3_sha256'],'new_wrapper_sha':manifest['new_wrapper_v3_sha256'],'policy_samples':policy_samples,'ioprio_corrections':corrections,'budget':ledger['phase_wall_s'],'unused':ledger['unused_s'],'trace_lines':841,'single_total_ratio':delivery['single_sample_total_speed_ratio'],'snapshot_files':[x['original_files']for x in snapshot_audits],'archive_files':[x['verified_archive_files']for x in archives]}))
