from pathlib import Path
import hashlib,json,shutil
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003';BASE=RUNS/'graph_program_top_host_01'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rec(p):return {'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size}
m=json.loads((BASE/'input_manifest.json').read_text());r=json.loads((BASE/'receipt.json').read_text());pairs=[];refs=[];snapshots=[]
for e in m['files']+[m['contract']]:
 a,b=e['original'],e['frozen'];pairs.append({'path':a['path'],'current_match':sha(Path(a['path']))==a['sha256'],'frozen_match':sha(Path(b['path']))==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']})
def walk(x,origin):
 if isinstance(x,dict):
  if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
   p=Path(x['path']);refs.append({'origin':origin,'path':str(p),'expected_sha256':x['sha256'],'match':p.is_file() and sha(p)==x['sha256']})
  for y in x.values():walk(y,origin)
 elif isinstance(x,list):
  for y in x:walk(y,origin)
for n,x in [('manifest',m),('receipt',r)]:walk(x,n)
def snap(p):
 t=OUT/'snapshot'/p.relative_to(ROOT);t.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,t);snapshots.append({'source':str(p.relative_to(ROOT)),**rec(t)})
for f in ['receipt.json','input_manifest.json','launcher.json','run.log','build.log','oracle.log']:snap(BASE/f)
for f in ['hls/control/graph_program_hls.cpp','hls/control/graph_program_protocol.cpp','hls/control/graph_program_sequencer.cpp','hls/control/graph_action_protocol.cpp','include/laya_graph_program_hls.h','include/laya_graph_program_protocol.h','include/laya_graph_program_sequencer.h','tests/graph_program_top_test.cpp','tests/graph_program_protocol_oracle.py','config/graph_program_sources.cmake','config/production_hls_partitions.json','config/full_module_registry.json','vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_graph_program_layout_v1.sv','vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_program_top_host.py']:
 snap(BASE/'frozen'/f)
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','results/production_hls_partition_contract_20261012.md']:snap(ROOT/f)
vp=RUNS/'graph_program_top_host_verification_20261012.json'
if not vp.exists():
 candidates=[p for p in RUNS.glob('*graph*program*verif*.json') if sha(p)=='4c8148463f8387f469b9ee2b76276add9ab43a0796794ed8f8c553dab5932b97'];assert len(candidates)==1;vp=candidates[0]
snap(vp)
expected={BASE/'input_manifest.json':'03cf285f7b024350a8224dac6ed51413f78ba31e2424881ea402fa875e7c281b',BASE/'receipt.json':'a3f6ce5f2dc5b42b7eaf617ea691e3e77d42b416a5b6ea3c8802c718c3e324c0',BASE/'run.log':'5c446e99d59ed77dc82b413136ac99ccfc94006a46933c554d90403db2e3ba5d',BASE/'graph_program_oracle.bin':'9da3038eb38399d5a220745b8618b95f13837d03c7701bcfedd6a54b41f48aa0',vp:'4c8148463f8387f469b9ee2b76276add9ab43a0796794ed8f8c553dab5932b97'}
old=RUNS/'graph_lifecycle_split_host_03/frozen';stable=['hls/control/graph_program_sequencer.cpp','hls/control/graph_action_protocol.cpp'];stability=[{'path':f,'same_as_host03':sha(old/f)==sha(BASE/'frozen'/f)} for f in stable]
v={'review_id':'R-SM003-GRAPH-PROGRAM-TOP-HOST-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'pairs':pairs,'references':refs,'snapshots':snapshots,'handoff_hashes':[{'path':str(p.relative_to(ROOT)),'match':sha(p)==h} for p,h in expected.items()],'summary':{'pairs_including_contract':len(pairs),'source_files':len(m['files']),**{k:sum(e[k] for e in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'commands':[{k:v for k,v in c.items() if k!='command'} for c in r['commands']],'markers':r['markers'],'launcher':json.loads((BASE/'launcher.json').read_text()),'existing_fix_identity':stability,'source_review':{'top':'callable C++ HLS entry with ap_ctrl_none annotations; no generated RTL evidence','scope':'one NORM_LAYER1_ATTN entry; runtime B1/S64 only','request901':'success LAC1 returns successful LGR1, slot/pc committed','request902':'blocked before request901 abstract result_consumed; safe error returns no slot update','request903':'bad magic -> zero ordinal/unbound local reject; blocks next command until abstract result_consumed','request904':'ordinal3 action emitted, test ends before its completion/result/drain','oracle':'512-byte encoder mapping oracle; patterned LGP1 source.slot3/version differing from epoch is intentionally not a semantically valid command','result_notification':'sampled only in WAIT_RESULT_CONSUMED; production shell must provide a held/lossless transaction-specific notification across HLS scheduling, verify late/early/stale timing','unverified':'real FIFO depth2 consumer, executor/shell request-model-source authority, nonterminal/bad LAC1 recovery, cancellation and full PC graph','no_controller_heavy_tools':True},'decision':{'verdict':'accept_scoped_host','new_findings':[],'C009':'awaiting_implementation','overall_acceptance':False}}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n');print(json.dumps({'summary':v['summary'],'mismatches':[x for x in refs if not x['match']],'handoff_hashes':v['handoff_hashes'],'existing_fix_identity':stability},ensure_ascii=False,indent=2))
