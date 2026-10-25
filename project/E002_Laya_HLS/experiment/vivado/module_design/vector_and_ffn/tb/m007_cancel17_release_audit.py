from pathlib import Path
import argparse,json,hashlib,tarfile,re
from decimal import Decimal
ROOT=Path(__file__).resolve().parents[7];R=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002';G=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load(at):
 p=R/'attempts'/at/'work/report.json';m=json.loads(p.read_text());assert m['status']=='PASS';return m,p
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir()
records=[];cost={k:Decimal(0)for k in ['reference','static','rtl','ooc']};policies=0
for rp in sorted((R/'attempts').glob('AT*/receipt.json')):
 if rp.parent==a.output.parent:continue
 r=json.loads(rp.read_text());assert r['status']not in('RUNNING','WAITING_LOCK');assert not r['owned_after_cleanup']and not r['owned_group_after_cleanup_exists'];assert sha(rp.parent/'sources.tar.gz')==r['source_archive_sha256']
 with tarfile.open(rp.parent/'sources.tar.gz')as z:
  data=z.extractfile('project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_guard_v1.py').read();assert hashlib.sha256(data).hexdigest()==r['guard_self_sha256_at_startup']==r['guard_self_sha256_at_lock']
  assert hashlib.sha256(z.extractfile('e018_protocol.md').read()).hexdigest()==r['protocol_sha256']
 assert r['MemAvailable_bytes']>192<<30 and r.get('minimum_MemAvailable_bytes',r['MemAvailable_bytes'])>192<<30
 for q in r.get('descendant_policy_checks',[]):assert q['nice']==19 and q['affinity']and set(q['affinity'])<={0,1,2,3}and q['ioprio']==3<<13;policies+=1
 cost[r['phase']]+=Decimal(str(r['child_wall_s']));records.append({'attempt':r['attempt'],'status':r['status'],'phase':r['phase'],'child_wall_s':str(r['child_wall_s']),'receipt_sha256':sha(rp)})
 pp=rp.parent/'work/report.json'
 if pp.exists():
  m=json.loads(pp.read_text())
  if m['status']=='PASS':
   assert r['status']=='EXIT_ZERO'
   if 'xsim_log_sha256'in m:assert sha(pp.parent/'xsim.log')==m['xsim_log_sha256']
   if 'semantic_progress_sha256'in m:assert sha(pp.parent/'semantic_progress.jsonl')==m['semantic_progress_sha256'] and r['semantic_progress']['event_count']>0
for n in ['AT005_cancel_mode0','AT006_cancel_mode1','AT007_cancel_mode2','AT008_cancel_mode3','AT009_cancel_mode4','AT010_cancel_mode5','AT011_cancel_mode6','AT015_exact_edge_mode1','AT016_exact_edge_mode2','AT019_exact_edge_mode5','AT003_normal_held3','AT017_normal_medium_pilot','AT023_real_terminal_priority','AT024_corrected_tb_normal_held3']:load(n)
normal,np=load('AT018_full_original_normal');priority,pp=load('AT023_real_terminal_priority');state,sp=load('AT012_exact_cancel_state_audit')
terminal_attempt=R/'attempts/AT020_full_terminal_cancel_priority';assert json.loads((terminal_attempt/'receipt.json').read_text())['status']=='FAIL'
partial=json.loads((R/'AT020_partial_evidence.json').read_text());assert partial['last_actual_checked_event']['checked']==335872 and partial['last_actual_checked_event']['node_checks']==3358720
assert priority['metrics']['cancel_terminal_same']==priority['metrics']['done_records']==1
old=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R001/attempts/AT024_current_full_normal_handoff/work/report.json';baseline=json.loads(old.read_text());assert normal['metrics']==baseline['metrics'] and normal['metrics']['full_done_cycles']==42171
nl=(np.parent/'xsim.log').read_text();assert 'CANCEL17_NORMAL_QUALIFIER mode=0 full_terminal_cancel=0'in nl
assert 'CONTROL_G_TO_A_PASS actual_done_consumed=1 resources_retired=1 coverage_reload=2'in nl
for at in ['AT002_normal_build','AT004_cancel_build','AT014_cancel_exact_edge_build','AT021_corrected_normal_tb_build','AT022_real_terminal_priority_build']:
 b=R/'attempts'/at/'work';m=json.loads((b/'report.json').read_text())
 for path,digest in m['source_sha256'].items():
  if at=='AT002_normal_build'and Path(path).name=='m007_cancel17_normal_tb.sv':
   frozen=b/'frozen'/path;assert sha(frozen)==digest
   original=frozen.read_text();corrected=original.replace('slot_fp_debt||protocol_fault||needs_discard)$fatal(1,"FINAL_REAL_DEBT")','slot_fp_debt||protocol_fault||(needs_discard&&mode!=2))$fatal(1,"FINAL_REAL_DEBT")',1)
   assert (ROOT/path).read_text()==corrected
  else:assert sha(ROOT/path)==digest,path
 for path,digest in m['snapshot'].items():assert sha(b/path)==digest,path
# The old raw R001 archives and all numeric/shared sources retain their identity.
old_build=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R001/attempts/AT015_actual_joint_admission_build/work/report.json'
for path,digest in json.loads(old_build.read_text())['source_sha256'].items():
 if '/rtl/'in path and Path(path).name not in('laya_m007_g_engine_v1.sv','laya_m007_control_workspace_joint_v1.sv'):assert sha(ROOT/path)==digest,path
assert state['new_FF_bits']==3 and state['current_joint_ceiling_bytes']==4037 and state['R001_all34_receipt_identities_unchanged']
engine=(G/'rtl/laya_m007_g_engine_v1.sv').read_text();assert 'math_clear=cmd_fire||discard_fire;'in engine and '!cancel_fill_held&&!producer_cancel_fire&&'in engine
assert 'cancel_read_held<=g_rd_valid&&!g_rd_ready;'in engine and 'cancel_fill_held<=g_wr_valid&&!g_wr_ready;'in engine
assert 'done_status<=protocol_fault?32\'d8:(first_error?32\'d6:32\'d0);needs_discard<=done_cancelled||protocol_fault||first_error;'in engine
for filename in ['m007_cancel17_tb.sv','m007_cancel17_edges_tb.sv','m007_cancel17_normal_tb.sv']:assert not re.search(r'\bforce\s+', (G/'tb'/filename).read_text())
fixture=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work';fi=json.loads((fixture/'report.json').read_text());assert sha(fixture/'geglu_vectors.hex')==fi['vectors_sha256'] and sha(fixture/'report.json')==normal['fixture_report_sha256']
for at in ['AT018_full_original_normal','AT020_full_terminal_cancel_priority']:
 rr=json.loads((R/'attempts'/at/'receipt.json').read_text());gate=rr['validated_measured_cost_plan'];assert gate['conservative_wall_bound_s']<=300 and rr['limit_s']<=300
 plan=json.loads(Path(gate['plan_path']).read_text());assert plan['remaining_before_s']>=plan['conservative_wall_bound_s']+120 and plan['previous_R002_rtl_wall_s']+plan['requested_timeout_s']<=480
assert cost['reference']==cost['ooc']==0 and cost['static']<=300 and cost['rtl']<=480
r={'schema':'m007-cancel17-release-audit-v1','status':'PASS','audited_prior_terminal_receipts':len(records),'archives':len(records),'policy_observations':policies,'records':records,'prior_guarded_child_cost_s_exact':{k:str(v)for k,v in cost.items()},'state_audit_sha256':sha(sp),'normal_report_sha256':sha(np),'real_peer_terminal_priority_report_sha256':sha(pp),'retained_full_terminal_failure_receipt_sha256':sha(terminal_attempt/'receipt.json'),'baseline_R001_normal_sha256':sha(old),'normal_metrics_exactly_equal_R001':True,'full_normal_cycles':42171,'full_terminal_cancel_cycles':None,'full_terminal_cancel_verdict':'FAIL_PRE_FIX_TB_FINAL_REAL_DEBT; corrected full lifecycle NOT_RUN_COST_GATE','corrected_TB_change':'Only allow expected needs_discard in mode2; modes0/1 assertions unchanged' ,'terminal_cancel_is_normal_success':False,'terminal_cancel_qualification_basis':'Only real-peer terminal same-edge short case has validated cancelled DONE/discard/recovery; full-success terminal cancellation lifecycle remains open','current_engine_sha256':sha(G/'rtl/laya_m007_g_engine_v1.sv'),'current_joint_sha256':sha(ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/laya_m007_control_workspace_joint_v1.sv'),'math_pairs_pool_numeric_sources':'UNCHANGED_FROM_R001','scope':'Producer cancel and bounded/full G functional RTL only; no parent FFN, numerical global-rank, physical fit/timing or missing-return recovery claim'}
(a.output/'report.json').write_text(json.dumps(r,indent=2)+'\n');print('CANCEL17_RELEASE_AUDIT_PASS receipts='+str(len(records))+' new_bits3 joint_ceiling4037 normal42171 real_peer_terminal_priority1 full_terminal_cancel_OPEN')
