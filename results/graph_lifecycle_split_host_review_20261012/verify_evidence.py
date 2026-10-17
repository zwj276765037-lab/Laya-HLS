from pathlib import Path
import json,hashlib,shutil
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rec(p):return {'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size}
refs=[];attempts={};snaps=[]
def walk(x,origin):
 if isinstance(x,dict):
  if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
   p=Path(x['path']);refs.append({'origin':origin,'path':str(p),'expected_sha256':x['sha256'],'match':p.is_file() and sha(p)==x['sha256']})
  for y in x.values():walk(y,origin)
 elif isinstance(x,list):
  for y in x:walk(y,origin)
def snap(p):
 target=OUT/'snapshot'/p.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
 snaps.append({'source':str(p.relative_to(ROOT)),**rec(target)})
for name in ['graph_lifecycle_split_host_02','source_provenance_06']:
 base=RUNS/name;m=json.loads((base/'input_manifest.json').read_text());r=json.loads((base/'receipt.json').read_text());pairs=[]
 for e in m['files']:
  a,b=e['original'],e['frozen'];pairs.append({'path':a['path'],'current_match':sha(Path(a['path']))==a['sha256'],'frozen_match':sha(Path(b['path']))==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']})
 attempts[name]={'pairs':pairs,'summary':{'count':len(pairs),**{k:sum(e[k] for e in pairs) for k in ['current_match','frozen_match','declared_pair_match']}},'receipt':rec(base/'receipt.json'),'manifest':rec(base/'input_manifest.json'),'status':r['status'],'commands':r.get('commands'), 'scope':r.get('scope')}
 for f in ['input_manifest.json','receipt.json','run.log','launcher.json','build.log','oracle.log']:
  p=base/f
  if p.exists():snap(p)
 for f,x in [('manifest',m),('receipt',r)]:walk(x,name+'/'+f)
base=RUNS/'graph_lifecycle_split_host_02'/'frozen'
for rel in ['hls/control/task_lifecycle_executor.cpp','hls/control/graph_program_sequencer.cpp','hls/control/graph_action_protocol.cpp','include/laya_graph_action_protocol.h','include/laya_graph_program_sequencer.h','include/laya_task_lifecycle_executor.h','hls/platform/generated_provenance_codec.cpp','hls/common/laya_full_owner.cpp','tests/graph_lifecycle_split_test.cpp','tests/graph_action_protocol_oracle.py','config/graph_action_registry.json','config/production_hls_partitions.json','config/graph_program_sources.cmake','config/task_lifecycle_executor_sources.cmake','vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_lifecycle_split_host.py']:
 snap(base/rel)
for rel in ['results/reviews/SM003.md','results/overview.md','mission/current.md','results/review_queue.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','results/production_hls_partition_contract_20261012.md']:
 snap(ROOT/rel)
snap(RUNS/'graph_lifecycle_split_host_verification_20261012.json')
expected={'graph_lifecycle_split_host_02/receipt.json':'d3a4ca31e56691975c3e60d50a9aef8e9fdbb794c7ab2b70bcd0a0a7afeeb73e','graph_lifecycle_split_host_02/input_manifest.json':'b580be22f4d29ca6aac48a3f3d0a9102a8be49a6154c593e4a3498d559f8830b','graph_lifecycle_split_host_02/run.log':'7ee5f1e797b9a099bf3528e1db87cedbd537e25117c01dac8dafc81261b8349a','graph_lifecycle_split_host_02/graph_action_oracle.bin':'6ccf07108e931dc5074b4195d84a1d175d32eb3477a813d9e6cd214a8cd914c0','graph_lifecycle_split_host_verification_20261012.json':'f6ccf3e3270e82f20eb893ea4b010f00c193e2e62713be9698c0fa3100f589a9','source_provenance_06/receipt.json':'64061933359de321e6ce7f7e94b2469e19bb5ba93490b3f3fbb128f44ffaf63f2','source_provenance_06/input_manifest.json':'a3ed779be3fd3df916e2dd3f3894a3cce0a265ffa202e256e171892c6b77f11b','source_provenance_06/run.log':'5cd396763b1b94dc75f5ca230215b1e6232dcb7e4764e5cbe638f12c94232cd8'}
v={'review_id':'R-SM003-GRAPH-LIFECYCLE-SPLIT-HOST-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'attempts':attempts,'references':refs,'snapshots':snaps,'handoff_hashes':[{'path':p,'match':sha(RUNS/p)==h} for p,h in expected.items()],'launcher':json.loads((RUNS/'graph_lifecycle_split_host_02/launcher.json').read_text()),'source_review':{'no_controller_compile_simulation_hls':True,'dynamic_unsupported_kinds':['LINEAR'],'static_unsupported_kind_count':16,'norm_runtime':'B1/S64 four rows16 windows with fixture producer and provenance responses','program_implemented':'begin/seed_slot/prepare_norm/accept_completion helpers; full graph PC and accepted-request bootstrap not executed','executor_implemented':'synchronous NORM execute/execute_task loops using FullRuntime; no generated top or explicit stepped persistent executor state tested','runner_limits':'launcher preflight plus per-command 1800s and 24GiB RLIMIT_AS; no child owned RSS sampling/120s progress guard in this host runner','source_provenance_runner_limits':'per-command120s and24GiB RLIMIT_AS only; no launcher policy claim'},'summary':{'pairs':sum(len(a['pairs']) for a in attempts.values()),'current_matches':sum(a['summary']['current_match'] for a in attempts.values()),'frozen_matches':sum(a['summary']['frozen_match'] for a in attempts.values()),'declared_pair_matches':sum(a['summary']['declared_pair_match'] for a in attempts.values()),'references':len(refs),'reference_matches':sum(x['match'] for x in refs)}}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':v['summary'],'mismatches':[r for r in refs if not r['match']],'handoff_hashes':v['handoff_hashes']},ensure_ascii=False,indent=2))
