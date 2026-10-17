from pathlib import Path
import json,hashlib,shutil,difflib
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003';BASE=RUNS/'graph_lifecycle_split_host_03'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rec(p):return {'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size}
m=json.loads((BASE/'input_manifest.json').read_text());r=json.loads((BASE/'receipt.json').read_text());pairs=[];refs=[];snapshots=[]
for e in m['files']:
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
for f in ['receipt.json','input_manifest.json','launcher.json','run.log','error_run.log','build.log','error_build.log','oracle.log']:
 snap(BASE/f)
old=json.loads((RUNS/'graph_lifecycle_split_host_02/input_manifest.json').read_text());a={e['relative']:e for e in old['files']};b={e['relative']:e for e in m['files']};changed=sorted(f for f in a.keys()&b.keys() if a[f]['frozen']['sha256']!=b[f]['frozen']['sha256']);added=sorted(b.keys()-a.keys())
for f in changed+added+['include/laya_graph_program_sequencer.h','include/laya_graph_action_protocol.h','include/laya_task_lifecycle_executor.h','config/graph_action_registry.json','config/production_hls_partitions.json']:
 snap(BASE/'frozen'/f)
for f in changed:
 p=OUT/'diff'/Path(f+'.diff');p.parent.mkdir(parents=True,exist_ok=True);p.write_text(''.join(difflib.unified_diff(Path(a[f]['frozen']['path']).read_text().splitlines(True),Path(b[f]['frozen']['path']).read_text().splitlines(True),fromfile='host02/'+f,tofile='host03/'+f)))
for f in ['results/reviews/SM003.md','results/overview.md','mission/current.md','results/review_queue.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','results/production_hls_partition_contract_20261012.md']:
 snap(ROOT/f)
snap(RUNS/'graph_lifecycle_split_f11_f13_verification_20261012.json')
expected={'graph_lifecycle_split_host_03/input_manifest.json':'914777b50062afa1711a8cabc9040017923a4f0f3bc6d6d69fca5129f32519e9','graph_lifecycle_split_host_03/receipt.json':'dcb798795109e8fdbd97479f5458cb3bbe95e8c312358955ee7dac0fa5d9a72b','graph_lifecycle_split_host_03/run.log':'8a385909950b98d20ce3b3b5780effa7d3ef5392d318da2e9b7c3d5322a7ea76','graph_lifecycle_split_host_03/error_run.log':'c3cf55552cf4cf4f10f0c7420ed1093e844d2d058652a01b70e0e6f6f47337d0','graph_lifecycle_split_f11_f13_verification_20261012.json':'ab446e35f693279694713c17c3785fe5ea2c5fed51fefd3fabc3829a52753c0c'}
v={'review_id':'R-SM003-GRAPH-LIFECYCLE-F11-F13-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'pairs':pairs,'references':refs,'snapshots':snapshots,'handoff_hashes':[{'path':f,'match':sha(RUNS/f)==h} for f,h in expected.items()],'summary':{'pairs':len(pairs),**{k:sum(e[k] for e in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'change_from_host02':{'common':len(a.keys()&b.keys()),'changed':changed,'added':added},'commands':[{k:v for k,v in c.items() if k!='command'} for c in r['commands']],'markers':r['markers'],'launcher':json.loads((BASE/'launcher.json').read_text()),'source_review':{'F11':'active action retains first error and cleanup state; matched undrained INVALIDATE then bound terminal cleanup resumes without producers or duplicate typed retirement; nonterminal BEGIN and injected source release failure retain tracker/lease','F12':'Status and LOCAL_REJECT+OK rejected; temporary-object completion decoder commits only after validation; NORM success checks batch255,row0 and B*ceil(S/16)','F13':'prepare_norm gates first_error; direct program begin resets request error and preserves action highwater; accepted-request bootstrap is not implemented/tested','unsupported_kinds':'16 kinds dynamically enumerated with NORM-shaped base parameters; generic pre-side-effect rejection matches static code','limits':'host fixture producer/provenance responses and unbounded software streams; no action FIFO RTL, no actual LN/hub or hardware recovery','no_heavy_tool_by_controller':True},'decision':{'F11':'closed_scoped_host','F12':'closed_scoped_host','F13':'closed_scoped_host','new_findings':[],'C009':'awaiting_implementation','overall_acceptance':False}}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':v['summary'],'mismatches':[x for x in refs if not x['match']],'handoff_hashes':v['handoff_hashes'],'change_from_host02':v['change_from_host02']},ensure_ascii=False,indent=2))
