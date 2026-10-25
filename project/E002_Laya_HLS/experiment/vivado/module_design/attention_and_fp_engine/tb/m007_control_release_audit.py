"""E018 release evidence: immutable source/run/fixture/budget boundaries."""
import argparse,json,hashlib,tarfile
from pathlib import Path
from decimal import Decimal
ROOT=Path(__file__).resolve().parents[7];RUN=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R001'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir()
records=[];cost={x:Decimal(0)for x in ['reference','static','rtl','ooc']};archives=0;policy=0;passed_reports=0;retained_policy_failures=[]
for rp in sorted((RUN/'attempts').glob('AT*/receipt.json')):
 if rp.parent==a.output.parent:continue
 r=json.loads(rp.read_text());assert r['status']not in('RUNNING','WAITING_LOCK'),rp
 assert r['owned_after_cleanup']==[] and not r['owned_group_after_cleanup_exists'],rp
 assert sha(rp.parent/'sources.tar.gz')==r['source_archive_sha256'],rp
 with tarfile.open(rp.parent/'sources.tar.gz')as z:
  name='project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_control_arena_guard_v1.py'
  assert hashlib.sha256(z.extractfile(name).read()).hexdigest()==r['guard_self_sha256_at_startup']==r['guard_self_sha256_at_lock'];archives+=1
 cost[r['phase']]+=Decimal(str(r['child_wall_s']));policy+=len(r.get('descendant_policy_checks',[]))
 assert r['MemAvailable_bytes']>192<<30
 if 'minimum_MemAvailable_bytes'in r:assert r['minimum_MemAvailable_bytes']>192<<30
 for q in r.get('descendant_policy_checks',[]):
  ok=q['nice']==19 and q['affinity'] and set(q['affinity'])<={0,1,2,3}and q['ioprio']==3<<13
  if not ok:
   assert r['attempt']=='AT008_actual_layer_cancel_g3'and r['status']=='INFRASTRUCTURE_FAILURE'and 'owned descendant policy mismatch'in r['error']
   retained_policy_failures.append({'attempt':r['attempt'],'actual_policy_observation':q,'retained_error':r['error']})
 report=rp.parent/'work/report.json'
 if report.exists():
  m=json.loads(report.read_text())
  if m['status']=='PASS':
   assert r['status']=='EXIT_ZERO';passed_reports+=1
   if 'xsim_log_sha256'in m:assert sha(rp.parent/'work/xsim.log')==m['xsim_log_sha256']
   if 'semantic_progress_sha256'in m:
    assert sha(rp.parent/'work/semantic_progress.jsonl')==m['semantic_progress_sha256'];assert r['semantic_progress']['event_count']>0
 records.append({'attempt':r['attempt'],'phase':r['phase'],'status':r['status'],'child_wall_s':str(r['child_wall_s']),'receipt_sha256':sha(rp)})
def load(n):
 pp=next((RUN/'attempts').glob(n+'*/work/report.json'));m=json.loads(pp.read_text());assert m['status']=='PASS';return m,pp
normal,np=load('AT024_');baseline_path=next((ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts').glob('AT146*/work/report.json'));baseline=json.loads(baseline_path.read_text())
assert normal['metrics']==baseline['metrics']
assert normal['metrics']['checked']==335872 and normal['metrics']['node_checks']==3358720 and normal['metrics']['full_done_cycles']==42171
assert max(x['service_cycles']for x in normal['block_timings'])==697
s=(np.parent/'xsim.log').read_text();assert 'CONTROL_A_TO_G_PASS coverage_unique=7 real_qkv_writes=9 cancel_held=17'in s and 'CONTROL_G_TO_A_PASS actual_done_consumed=1 resources_retired=1 coverage_reload=2'in s
build_path=RUN/'attempts/AT015_actual_joint_admission_build/work/report.json';build=json.loads(build_path.read_text());assert normal['build_manifest_sha256']==sha(build_path)
for name,digest in build['source_sha256'].items():assert sha(ROOT/name)==digest,name
for name,digest in build['snapshot'].items():assert sha(build_path.parent/name)==digest,name
source,sp=load('AT032_');assert source['joint_bytes']==4036 and source['remaining_to4096_bytes']==60 and source['g_engine_private_FF_algorithm']=='BYTE_IDENTICAL'
hierarchy,hp=load('AT027_');assert hierarchy['workspace_objects']==1 and hierarchy['private_control_local_branches']==0 and hierarchy['consumer_q_views']==2
for name in ['AT014_','AT016_','AT018_','AT019_','AT020_','AT021_','AT022_','AT023_','AT029_','AT031_']:load(name)
fixture=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work';fi=json.loads((fixture/'report.json').read_text());assert fi['count']==335872 and sha(fixture/'geglu_vectors.hex')==fi['vectors_sha256'];assert sha(fixture/'report.json')==normal['fixture_report_sha256']
# New standalone external regressions keep all old assertion messages.
G=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb'
import re
for old,new in [('m007_g_ring_tag_tb.sv','m007_control_arena_ring_tb.sv'),('m007_g_tag_fault_tb.sv','m007_control_arena_tag_fault_tb.sv'),('m007_g_peer_engine_tb.sv','m007_control_arena_peer_tb.sv'),('m007_g_engine_tb.sv','m007_control_arena_engine_tb.sv')]:
 messages=re.findall(r'\$fatal\([^,]+,"([^"]+)"',(G/old).read_text());current=(G/new).read_text()
 for message in messages:assert '"'+message+'"'in current,(old,message)
assert cost['reference']==cost['ooc']==0 and cost['static']<=600 and cost['rtl']<=1680
r={'schema':'m007-control-arena-release-audit-v1','status':'PASS','audited_terminal_attempts':len(records),'source_archives':archives,'actual_descendant_policy_observations':policy,'retained_failed_policy_observations':retained_policy_failures,'passed_reports':passed_reports,'exact_prior_terminal_cost_s':{k:str(v)for k,v in cost.items()},'records':records,'current_build_manifest_sha256':sha(build_path),'source_audit_sha256':sha(sp),'actual_hierarchy_sha256':sha(hp),'normal_report_sha256':sha(np),'baseline_normal_report_sha256':sha(baseline_path),'normal_metrics_exactly_equal_baseline':True,'fixture_report_sha256':sha(fixture/'report.json'),'fixture_vectors_sha256':fi['vectors_sha256'],'budget_scope':'E018 independent; this audit own guard receipt is added by final ledger after exit','limitations':['Source declaration account and XSim functional hierarchy only; no synthesis/physical fit/timing','Layer PREP/cancel only; no actual full16head normal release to G','No full FFN/Encoder/30layer parent integration','Current full numerical-error rank cases were not rerun; unchanged arithmetic/error logic evidence remains baseline-specific']}
(a.output/'report.json').write_text(json.dumps(r,indent=2)+'\n');print('CONTROL_ARENA_RELEASE_AUDIT_PASS attempts='+str(len(records))+' archives='+str(archives)+' joint_bytes4036 full_normal335872 cycles42171 actual_shadow0')
