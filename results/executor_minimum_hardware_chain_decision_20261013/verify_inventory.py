from pathlib import Path
import json,hashlib
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003';OUT=Path(__file__).resolve().parent

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text())
def entries(x):
 if isinstance(x,dict):
  if isinstance(x.get('original'),dict) and isinstance(x.get('frozen'),dict):yield x
  else:
   for v in x.values():yield from entries(v)
 elif isinstance(x,list):
  for v in x:yield from entries(v)
snapshots={}
def snap(p):
 p=Path(p);p=p if p.is_absolute() else ROOT/p
 q=OUT/'snapshot'/p.relative_to(ROOT);q.parent.mkdir(parents=True,exist_ok=True)
 data=p.read_bytes();q.write_bytes(data);snapshots[str(q.relative_to(ROOT))]=sha(q)
x=read(RUNS/'executor_minimum_hardware_chain_inventory_20261013.json');modules=[]
for module in x['generated_modules']:
 n=module['attempt'];m=read(RUNS/n/'input_manifest.json');files=m['files'];pairs=list(entries(m))
 assert len(files)==module['pair_count']
 differences=[];additional=[]
 for p in pairs:
  a,b=p['original'],p['frozen'];assert sha(b['path'])==a['sha256']==b['sha256'];snap(b['path'])
  h=sha(a['path'])
  if h!=a['sha256']:
   record=dict(path=a['path'],expected_sha256=a['sha256'],actual_sha256=h)
   (differences if p in files else additional).append(record)
 top=module['generated_top'];assert sha(top['path'])==top['sha256'];snap(top['path'])
 for p in module['records']:assert sha(p['path'])==p['sha256'];snap(p['path'])
 rc=read(RUNS/n/'receipt.json');assert rc['status']==module['receipt_status']
 modules.append(dict(attempt=n,file_pairs=len(files),all_pairs=len(pairs),frozen_matches=len(pairs),top_sha256=sha(top['path']),receipt_status=rc['status'],current_file_differences=differences,additional_contract_differences=additional,reported_file_differences_match={y['path']:y['actual_sha256'] for y in differences}=={y['path']:y['actual_sha256'] for y in module['current_differences']},generation_seconds=module['elapsed_seconds']))
for f in ['goal/goal.md','mission/M003_当前身份生产链接入与回归.md','mission/M004_完整Laya加速器搭建与性能优化.md','project/E003_production_chain_closure/experiment_source/protocol.md','results/production_hls_partition_contract_20261012.md','results/executor_checkpoint_import_handshake_contract_20261013.md','results/executor_close_rearm_contract_20261013.md','results/executor_managed_lpv_owner_contract_20261013.md','results/executor_minimum_hardware_chain_priority_20261013.md','.research-agent/communications/executor-minimum-hardware-chain-answer-20261013.json','.research-agent/communication.json','results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json','project/E002_Laya_HLS/experiment/hls/control/graph_program_hls.cpp','project/E002_Laya_HLS/experiment/hls/control/executor_actor.cpp','project/E002_Laya_HLS/experiment/config/executor_actor_sources.cmake']:
 snap(ROOT/f)
for f in ['executor_minimum_hardware_chain_plan_20261013.md','executor_minimum_hardware_chain_inventory_20261013.json','layernorm_quant_source_04/receipt.json','layernorm_quant_source_03/receipt.json']:snap(RUNS/f)
a=read(RUNS/'layernorm_quant_source_04/receipt.json');b=read(RUNS/'layernorm_quant_source_03/receipt.json')
print('LN_Q_04_full',a['full']);print('LN_Q_03_full_status',b.get('full',{}).get('status'))
v=dict(decision_id='D-M003-FIRST-HARDWARE-BASELINE-01',checked_at=datetime.now(timezone.utc).isoformat(),modules=modules,total_file_pairs=sum(m['file_pairs'] for m in modules),total_frozen_pairs=sum(m['all_pairs'] for m in modules),snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],decision_status='pending_plan_acceptance',no_new_DUT_HLS_RTL_OOC=True,estimate_scope='engineering effort estimates; no deadline or success bound',budget_scope='G2338.224019s is G cumulative OOC remainder only; not HLS/RTL shared budget',evidence_scope_clarification='LN-Q source_04 full NOT_PLANNED_COMPATIBILITY_PILOT_ONLY; rows16 fullA references must explicitly identify source_03 frozen evidence')
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'file_pairs':v['total_file_pairs'],'all_frozen_pairs':v['total_frozen_pairs'],'modules':[{k:m[k] for k in ['attempt','file_pairs','all_pairs','top_sha256','receipt_status','reported_file_differences_match']} for m in modules]},ensure_ascii=False,indent=2))
