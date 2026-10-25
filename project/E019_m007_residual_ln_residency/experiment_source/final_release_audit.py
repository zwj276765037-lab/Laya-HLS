from pathlib import Path
import argparse,json,hashlib,re,tarfile
from decimal import Decimal
ROOT=Path(__file__).resolve().parents[3];RUN=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R001';SRC=RUN.parents[2]/'experiment_source'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):return json.loads(p.read_text())
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
reports={n:load(RUN/'attempts'/n/'work/report.json')for n in ['AT001_original_residual_fixture','AT004_bank_public_protocol','AT006_residual16row_prefix','AT007_full_cost_gate','AT008_full_original_residual','AT009_final_write_held17','AT010_nonfinite_first_error_drain','AT012_bank_and_real_FP_debt_edges']}
assert all(x['status']=='PASS'for x in reports.values())
full=reports['AT008_full_original_residual']['metrics'];held=reports['AT009_final_write_held17']['metrics'];err=reports['AT010_nonfinite_first_error_drain']['metrics']
assert full['issued']==full['retired']==full['commits']==4096 and full['checked']==131072 and full['scan_checked']==131104 and full['first_commit']==12 and full['done_cycles']==4110 and full['status']==0 and full['lease_count']==full['release_count']==1
assert held['done_cycles']==full['done_cycles']+held['external_write_held']==4127 and held['external_write_held']==held['done_held']==17 and held['checked']==131072 and held['scan_checked']==131104
assert err['status']==6 and err['issued']==err['retired']<4096 and err['lease_count']==err['release_count']==1
log=(RUN/'attempts/AT012_bank_and_real_FP_debt_edges/work/xsim.log').read_text();assert log.count('RESIDENT21_EDGES_PASS different_address_1R1W=1 Q64_half_collision=1 held_scratch_release_barrier=1 real_FP_debt_held17=17 early_start_reject=1')==1
builds=['AT003_resident_component_build','AT011_bank_debt_edges_build'];selected={}
for name in builds:
 b=RUN/'attempts'/name/'work';m=load(b/'report.json');assert m['status']=='BUILD_COMPLETE'
 for n,d in m['source_sha256'].items():assert sha(ROOT/n)==sha(b/'frozen'/n)==d;selected[n]=d
 for n,d in m['snapshot'].items():assert sha(b/n)==d
for name in ['AT006_residual16row_prefix','AT008_full_original_residual','AT009_final_write_held17']:
 rr=load(RUN/'attempts'/name/'receipt.json');m=reports[name];assert rr['semantic_progress']['last_checked']==m['metrics']['checked'] and rr['semantic_progress']['raw_sha256']==m['semantic_progress_sha256']==sha(RUN/'attempts'/name/'work/semantic_progress.jsonl')
census=load(SRC/'state_census.json');assert census['new_control_bits']==62 and sum(x['bits']for x in census['control'])==62
for name,d in census['source_sha256'].items():assert selected[name]==sha(ROOT/name)==d
expected={'laya_m007_hidden32_v1.sv':{'rd_rsp_valid','rd_rsp_addr','words','rd_rsp_data'},'laya_m007_qscratch32_v1.sv':{'owner_active'},'laya_m007_resident_vector32_v1.sv':{'state','issued_vectors','retired_vectors','first_error','protocol_error','error_addr','error_lane'}}
for name,want in expected.items():
 s=(ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl'/name).read_text();lhs=set(re.findall(r'\b(\w+)(?:\[[^\]]+\])?\s*<=',s));assert lhs==want,(name,lhs,want)
 assert not re.search(r'\b(?:laya_shared_fp256_v2|laya_fadd_rne_v1|laya_fmul_rne_v1)\s+(?:#|\w+\s*\()',s),'private FP in provider/bank'
record=[];cost={k:Decimal(0)for k in ['reference','static','rtl','ooc']}
for p in sorted((RUN/'attempts').glob('AT*/receipt.json')):
 if p.parent==a.output.parent:continue
 d=load(p);assert d['status']in ['EXIT_ZERO','FAIL','INFRASTRUCTURE_FAILURE'];assert d['owned_after_cleanup']==[] and d['owned_group_after_cleanup_exists'] is False
 assert d['guard_self_sha256_at_startup']==d['guard_self_sha256_at_lock'] and sha(p.parent/'sources.tar.gz')==d['source_archive_sha256']
 with tarfile.open(p.parent/'sources.tar.gz')as ar:
  for n,v in d['source_sha256'].items():assert hashlib.sha256(ar.extractfile(n).read()).hexdigest()==v
  assert hashlib.sha256(ar.extractfile(d['guard_entrypoint'].split(str(ROOT)+'/')[1]).read()).hexdigest()==d['guard_self_sha256_at_startup']
 if d['attempt']=='AT002_resident_component_build':assert d['status']=='FAIL'
 elif d['attempt']=='AT005_residual16row_prefix':assert d['status']=='INFRASTRUCTURE_FAILURE' and "'ioprio': 0"in d['error']
 else:
  assert d['status']=='EXIT_ZERO'
  for row in d['descendant_policy_checks']:assert row['ioprio']==24576 and row['nice']==19 and set(row['affinity'])<={0,1,2,3}
 cost[d['phase']]+=Decimal(str(d['child_wall_s']));record.append({'attempt':d['attempt'],'phase':d['phase'],'status':d['status'],'child_wall_s_exact':str(d['child_wall_s']),'receipt_sha256':sha(p)})
report={'schema':'m007-resident21-release-audit-v1','status':'PASS','prior_terminal_receipts':len(record),'source_and_snapshot_immutable':True,'selected_source_sha256':selected,'normal_full_metrics':full,'final_write_held_metrics':held,'nonfinite_metrics':err,'control_census':census,'prior_cost_s_exact':{k:str(v)for k,v in cost.items()},'records':record,'limits':'Declared new components only, no final combined parent fit; parent layer/matrix/quant handoff NOT_RUN; no LN/Encoder30/physical claim','actual_resource_scope':'one hidden32 and sole nativeQKV; one real default256-lane shared FP; public original H/WO loads, actualADD/writes and finalH rescan; no force or fabricated debt'}
(a.output/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'status':'PASS','prior_terminal_receipts':len(record),'new_control_bits':62,'first_commit':full['first_commit'],'full_DONE_cycles':full['done_cycles'],'held_DONE_cycles':held['done_cycles']}))
