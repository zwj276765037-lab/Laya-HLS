#!/usr/bin/env python3
import argparse,hashlib,json,tarfile
from decimal import Decimal
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];RUN=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R003'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):return json.loads(p.read_text())
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
pre=load(RUN/'attempts/AT001_corrected_source_cost_preflight/work/report.json');assert pre['status']=='PASS'
full=RUN/'attempts/AT003_corrected_full_terminal_cancel';r=load(full/'receipt.json');m=load(full/'work/report.json');i=load(full/'work/input_identity.json');log=(full/'work/xsim.log').read_text()
assert r['status']=='EXIT_ZERO' and m['status']=='PASS' and m['mode']==i['mode']==2 and m['groups']==82 and m['complete_S128'] and m['main_input_count']==335872
v=m['metrics'];assert v['checked']==335872 and v['node_checks']==3358720 and v['writes']==v['write_acks']==20992 and v['read_vectors']==41984 and v['releases']==82 and v['all_accepted_debt_zero']==1 and v['prefix']==0
assert v['first_actual_consume']==185 and v['max_read_gap']==v['max_output_gap']==1
for marker in ['CONTROL_A_TO_G_PASS coverage_unique=7 real_qkv_writes=9 cancel_held=17','CONTROL_G_TO_A_PASS actual_done_consumed=1 resources_retired=1 coverage_reload=2','CANCEL17_NORMAL_QUALIFIER mode=2 full_terminal_cancel=1','HARDWARE_AGENT_SIM_PASS G_ENGINE groups=82']:
 assert log.count(marker)==1,'missing/duplicate marker '+marker
assert not any(x.startswith(('Fatal:','ERROR:')) for x in log.splitlines())
assert r['semantic_progress']['last_checked']==335872 and r['semantic_progress']['last_node_checks']==3358720 and r['semantic_progress']['event_count']==328
assert r['semantic_progress']['raw_sha256']==m['semantic_progress_sha256']==sha(full/'work/semantic_progress.jsonl')
assert r['owned_after_cleanup']==[] and r['owned_group_after_cleanup_exists'] is False and r['child_wall_s']<=200
build=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002/attempts/AT021_corrected_normal_tb_build/work';bm=load(build/'report.json');assert sha(build/'report.json')==m['build_manifest_sha256']==pre['build_manifest_sha256']
for name,digest in bm['source_sha256'].items():assert sha(ROOT/name)==sha(build/'frozen'/name)==digest
for name,digest in bm['snapshot'].items():assert sha(build/name)==digest
for name,digest in pre['R002_receipt_sha256'].items():assert sha(ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002/attempts'/name/'receipt.json')==digest
for name,digest in pre['R001_receipt_sha256'].items():assert sha(ROOT/name)==digest
records=[];cost={k:Decimal(0)for k in ['reference','static','rtl','ooc']}
for rp in sorted((RUN/'attempts').glob('AT*/receipt.json')):
 if rp.parent==a.output.parent:continue
 q=load(rp);assert q['status'] in ['EXIT_ZERO','COST_GATE_STOP']
 if q['attempt']=='AT002_corrected_full_terminal_cancel':assert q['child_wall_s']==0 and 'pid' not in q and q['status']=='COST_GATE_STOP'
 else:
  assert q['owned_after_cleanup']==[] and q['owned_group_after_cleanup_exists'] is False
  assert sha(rp.parent/'sources.tar.gz')==q['source_archive_sha256']
  with tarfile.open(rp.parent/'sources.tar.gz')as ar:
   for name,digest in q['source_sha256'].items():assert hashlib.sha256(ar.extractfile(name).read()).hexdigest()==digest
 cost[q['phase']]+=Decimal(str(q['child_wall_s']));records.append({'attempt':q['attempt'],'status':q['status'],'phase':q['phase'],'child_wall_s':str(q['child_wall_s']),'receipt_sha256':sha(rp)})
tb=(ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_normal_tb.sv').read_text();eng=(ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_m007_g_engine_v1.sv').read_text()
for text in ['repeat(17)begin @(negedge clk);if(!done_valid','CANCEL_NEEDS_EXPLICIT_DISCARD','POST_DONE_NOT_IDLE','RETURN_A_COVERAGE_RELOAD','CANCEL_MUST_WIN_NORMAL_TERMINAL_EDGE','FULL_TERMINAL_CANCEL_NOT_OBSERVED']:
 assert text in tb
assert eng.count('done_valid<=1;')==1 and 'active<=0;done_valid<=1;' in eng and '!producer_cancel_fire&&' in eng
report={'schema':'m007-cancel-end19-release-audit-v1','status':'PASS','full_report_sha256':sha(full/'work/report.json'),'full_receipt_sha256':sha(full/'receipt.json'),'full_metrics':v,'full_guarded_child_wall_s':r['child_wall_s'],'qualified_cancelled_DONE':True,'full_terminal_cancel_at_actual_normal_candidate':True,'DONE_held17_and_identity_checked':True,'explicit_discard_after_DONE_consumption':True,'actual_G_to_A_resource_retirement_and_coverage_reload':True,'DONE_uniqueness_basis':'One real command; sole engine publication assignment requires active and clears active. TB requires no DONE at legal terminal-cancel edge, stable cancelled DONE for17 cycles, one DONE consumption, then explicit discard/engine idle/resource release and inactive-G assertions during A reload. No separate runtime publication counter is claimed.','unchanged_R002_receipts':len(pre['R002_receipt_sha256']),'unchanged_R001_receipts':len(pre['R001_receipt_sha256']),'build_and_snapshot_immutable':True,'prior_receipts':records,'prior_cost_s_exact':{k:str(x)for k,x in cost.items()},'control_cost_unchanged':{'new_FF_bits_this_R003':0,'total_cancel_FF_bits':3,'joint_exact_B':'4036.375','joint_ceiling_B':4037},'scope':'Corrected full successful-terminal producer-cancel functional lifecycle only; prior R002 failure preserved; no FFN/Encoder/30layer/physical claim'}
save(a.output/'report.json',report);print(json.dumps({k:report[k] for k in ['status','full_metrics','full_guarded_child_wall_s','unchanged_R002_receipts','unchanged_R001_receipts']}))
