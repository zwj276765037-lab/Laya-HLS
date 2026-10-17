from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,shutil,difflib
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text())
pairs=[];refs=[];snapshots=[];attempts={};diffs=[]
def snap(p):
 t=OUT/'snapshot'/p.relative_to(ROOT);t.parent.mkdir(parents=True,exist_ok=True)
 if not t.exists():shutil.copyfile(p,t)
 assert sha(t)==sha(p)
 snapshots.append({'path':str(t.relative_to(ROOT)),'sha256':sha(t)})
def walk(x,origin):
 if isinstance(x,dict):
  if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
   p=Path(x['path']);refs.append({'origin':origin,'path':str(p),'expected':x['sha256'],'actual':sha(p) if p.is_file() else None,'match':p.is_file() and sha(p)==x['sha256']})
  for v in x.values():walk(v,origin)
 elif isinstance(x,list):
  for v in x:walk(v,origin)
names=['bootstrap_snapshot_rtl_03','generated_source_lease_05','generated_store_monitor_11']
for name in names:
 base=RUNS/name;m=read(base/'input_manifest.json');r=read(base/'receipt.json')
 for e in m['files']+([m['contract']] if 'contract' in m else m.get('contracts',[])):
  a,b=e['original'],e['frozen']
  pairs.append({'attempt':name,'path':a['path'],'current_match':sha(a['path'])==a['sha256'],'frozen_match':sha(b['path'])==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']})
  if any(key in Path(b['path']).name for key in ['hub_v1.sv','tb_v1.sv','run_bootstrap_snapshot.py']):snap(Path(b['path']))
 for kind,x in [('manifest',m),('receipt',r)]:walk(x,name+'/'+kind)
 for f in ['input_manifest.json','receipt.json','launcher.json']:snap(base/f)
 gd=base/'guard';plan=read(gd/'guard_plan.json');result=read(gd/'guard_result.json');policy=read(gd/'policy_checks.json');log=(gd/'driver.log').read_text()
 for f in ['guard_plan.json','guard_result.json','policy_checks.json','launch.json','driver.log']:snap(gd/f)
 attempts[name]={'status':r['status'],'scope':r['scope'],'guard_result':result,'plan':plan,'launcher':read(base/'launcher.json'),'policy_count':len(policy),'policy_ok':all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy),'budget_ok':result['elapsed_seconds']<=plan['maximum_seconds'] and result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and result['minimum_mem_available_kb']>=plan['minimum_mem_available_kb'],'receipt_guard_equal':r['guard_result']==result,'markers':r['marker'],'markers_in_raw_log':all(x in log for x in r['marker'])}
old=read(RUNS/'bootstrap_snapshot_rtl_02/input_manifest.json');new=read(RUNS/'bootstrap_snapshot_rtl_03/input_manifest.json')
a={e['original']['path']:e for e in old['files']};b={e['original']['path']:e for e in new['files']};changed=[]
for f in sorted(a.keys()&b.keys()):
 if a[f]['frozen']['sha256']!=b[f]['frozen']['sha256']:
  changed.append(f);pa,pb=Path(a[f]['frozen']['path']),Path(b[f]['frozen']['path']);t=OUT/'diff'/(Path(f).name+'.diff');t.parent.mkdir(exist_ok=True)
  t.write_text(''.join(difflib.unified_diff(pa.read_text().splitlines(True),pb.read_text().splitlines(True),fromfile='02/'+Path(f).name,tofile='03/'+Path(f).name)));diffs.append(str(t.relative_to(ROOT)))
expected={}
rows=[
('bootstrap_snapshot_rtl_03','cb57f763fa948a1f98a3986e803195a71a2f6f03cc0fc1d2a688e2562d85bc39','1dc73fe5d10b491e7b0f7ebc72d462684adc6c98a2c74e05ffdb8b52d97e50d5','955a3bd19286c342dbeb7097190e7926dbdf2d454b8194cd8f25946d05995b51'),
('generated_source_lease_05','fc5775316a066891f38b323a456a3c8495d44c4a6a12fc09ac92677bd9aa8efd','882ebcd3b68326a24ceff1b010e5dc2dbb777581ac67663e0dac7a0401934ea6','c07b9c272dc55d7a277222572fad2067d8d9a9a60600f59090383991cbbe4bce'),
('generated_store_monitor_11','44a9969c27d4020fa2b8df3c2d7093ef0cc3aabfc94b4f4c4a396ed73129148b','3d739adef062b243307fed8301f971cbb9c8f2914b3fb4d0f305a09a2e35dcb8','bea3305f04ed0380dbe64ce4925847ed7aba7cc594125353dc6c7a4f63863273')]
for n,m,r,v in rows:
 expected[RUNS/n/'input_manifest.json']=m;expected[RUNS/n/'receipt.json']=r;expected[RUNS/(n+'_verification_20261012.json')]=v
expected[RUNS/'bootstrap_snapshot_f14_verification_20261012.json']='23bbb8c5e8e189c933d995b84a158c6ed71264b0bf0494e4f9d823552e681539'
hashes=[{'path':str(p.relative_to(ROOT)),'expected':h,'actual':sha(p),'match':sha(p)==h} for p,h in expected.items()]
for p in expected:
 if p.parent==RUNS:snap(p)
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/state.json','agent/A001/result.md','agent/A002/state.json','.research-agent/discussions.json']:snap(ROOT/f)
intervals=[(a['plan']['at'],a['guard_result']['finished_at'],n) for n,a in attempts.items()]
intervals.sort();serial=all(intervals[i][1]<=intervals[i+1][0] for i in range(len(intervals)-1))
v={'review_id':'R-SM003-BOOTSTRAP-SNAPSHOT-F14-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'pairs':pairs,'references':refs,'snapshots':snapshots,'attempts':attempts,'diffs':diffs,'changed_common_02_03':changed,'handoff_hashes':hashes,'summary':{'pairs':len(pairs),**{k:sum(x[k] for x in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'serial_intervals':intervals,'serial_nonoverlap':serial,'source_review':{'arbitration':'unaccepted snapshot valid removed from LPV request_ready; accepted held snapshot response still gates LPV; snapshot ready requires no LPV request or old scope/pending response','idle':'both valid; CLAIM first, held response12 cycles; query progresses only after LPV response consumed; counts check single accept','end':'fourth window snapshot held continuously; END waits with final B12cycles, progresses on physical retirement; held END response12 cycles before query; original 4 typed/9 events at END','invalidate_cancel':'held snapshot response blocks INVALIDATE12cycles; consumer releases then exactly one INVALIDATE; matching old LPV response preserved through cancel and12 cycles; pending query resumes with bound E_BUFFER','source_query':'invalid all-zero QUANT competitor only with snapshot enabled, no lease granted; legal lease retained by default-disabled compatibility fixture','fairness':'finite workload progress only; continuous higher-priority LPV may starve snapshot','protection':'snapshot is point-in-time fact; no source lifetime guard, executor top/action RTL, full production graph or physical recovery conclusion','source_lease_compatibility':'release_drained supplied by controlled TB, not generated consumer read-debt proof'},'decision':{'F14':'closed_scoped_rtl_arbitration','snapshot':'accept_scoped_rtl_snapshot_arbitration','compatibility':'accept_lease_and_monitor_existing_fixture_scope','new_blocking_findings':[],'C009':'awaiting_implementation','overall_acceptance':False},'no_controller_compilation_simulation_hls':True}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':v['summary'],'hash_matches':sum(x['match'] for x in hashes),'hash_total':len(hashes),'serial':serial,'changes':changed,'guards':[(n,a['policy_count'],a['policy_ok'],a['budget_ok'],a['receipt_guard_equal'],a['markers_in_raw_log']) for n,a in attempts.items()]},ensure_ascii=False,indent=2))

