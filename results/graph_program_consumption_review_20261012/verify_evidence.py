from pathlib import Path
import hashlib,json,shutil,difflib
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent;RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003';BASE=RUNS/'graph_program_top_host_02'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rec(p):return {'path':str(p.relative_to(ROOT)),'sha256':sha(p)}
m=json.loads((BASE/'input_manifest.json').read_text());r=json.loads((BASE/'receipt.json').read_text());pairs=[];refs=[];snaps=[]
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
 t=OUT/'snapshot'/p.relative_to(ROOT);t.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,t);snaps.append({'source':str(p.relative_to(ROOT)),**rec(t)})
old=RUNS/'graph_program_top_host_01';om=json.loads((old/'input_manifest.json').read_text());a={e['relative']:e for e in om['files']};b={e['relative']:e for e in m['files']};changed=sorted(f for f in a.keys()&b.keys() if a[f]['frozen']['sha256']!=b[f]['frozen']['sha256'])
for f in changed:
 snap(BASE/'frozen'/f);p=OUT/'diff'/Path(f+'.diff');p.parent.mkdir(parents=True,exist_ok=True);p.write_text(''.join(difflib.unified_diff(Path(a[f]['frozen']['path']).read_text().splitlines(True),Path(b[f]['frozen']['path']).read_text().splitlines(True),fromfile='01/'+f,tofile='02/'+f)))
for f in ['receipt.json','input_manifest.json','launcher.json','run.log','build.log','oracle.log']:snap(BASE/f)
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json']:snap(ROOT/f)
vp=RUNS/'graph_program_top_consumption_verification_20261012.json';snap(vp)
expected={BASE/'input_manifest.json':'a69591a76350b271da03c61fb24bc8e04cad5af224d46fb6ba1bfb10e919c03b',BASE/'receipt.json':'0fecffe69e0cf1d54aa4de5d0f50c8a20a3e06d55069d8fd2d53868de4c051e3',BASE/'run.log':'247b8ffe8e43f233f5f5cd075e6ea7637d54afa4bc8bf2cfe31edd41258d4adc',BASE/'graph_program_oracle.bin':'9da3038eb38399d5a220745b8618b95f13837d03c7701bcfedd6a54b41f48aa0',vp:'80a13b7b74a7b1d97e9da63b4b23b5ba592a0404689a1cf6fe7203f1ed65e181'}
v={'review_id':'R-SM003-GRAPH-PROGRAM-CONSUMPTION-HOST-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'pairs':pairs,'references':refs,'snapshots':snaps,'summary':{'pairs_including_contract':len(pairs),**{k:sum(e[k] for e in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'handoff_hashes':[{'path':str(p.relative_to(ROOT)),'match':sha(p)==h} for p,h in expected.items()],'changed_common_files':changed,'commands':[{k:v for k,v in c.items() if k!='command'} for c in r['commands']],'markers':r['markers'],'launcher':json.loads((BASE/'launcher.json').read_text()),'oracle_same_as_01':sha(BASE/'graph_program_oracle.bin')==sha(old/'graph_program_oracle.bin'),'source_review':{'notification_latch':'last-result-write host invocation samples bool; next WAIT uses and clears pending','adjacent_test':'TB asserts bool in final-write tick before dequeuing last result word; validates abstract input retention, not measured hardware FIFO pop','stale_test':'one pulse while receiving second LAC1 is ignored; not proof against stale level/pulse coinciding with final write or WAIT','completion_scope':'901 success,902 safe error,903 pre-action reject,904 success; all four software streams empty at end','physical_pending':'shell-generated held request-specific notification across generated HLS scheduling; real depth2/tail stalls and action/transaction consumer boundaries','no_controller_heavy_tools':True},'decision':{'verdict':'accept_scoped_host_supplement','new_findings':[],'C009':'awaiting_implementation','overall_acceptance':False}}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n');print(json.dumps({'summary':v['summary'],'hashes':v['handoff_hashes'],'changed':changed,'oracle_unchanged':v['oracle_same_as_01']},ensure_ascii=False,indent=2))
