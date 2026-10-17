"""Controller read-only identity/log audit. Never imports a DUT or old updater."""
from pathlib import Path
import datetime as dt, hashlib, json, re, shutil, difflib, struct
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
BASE=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
names=['AT055_FFN0_single_runtime_01','AT056_FFN0_single_runtime_02','AT057_FFN0_single_runtime_03']
cache={}; checks=[]; manifests={}; guards=[];differences=[]
def ident(p):
 p=Path(p).resolve()
 if str(p) not in cache:
  h=hashlib.sha256()
  with p.open('rb') as f:
   for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
  cache[str(p)]={'path':str(p),'bytes':p.stat().st_size,'sha256':h.hexdigest()}
 return cache[str(p)]
def read(p):
 ident(p);return json.loads(Path(p).read_text())
for name in names:
 p=BASE/name;m=read(p/'source_manifest.json');manifests[name]=m['files']
 for row in m['files']:
  a=ident(row['path']);assert a['bytes']==row['bytes'] and a['sha256']==row['sha256'],row
  checks.append({'attempt':name,'role':row['role'],**a,'match':True})
 for phase in ['static','short','pilot','full']:
  g=p/f'guard_{phase}'
  if not g.exists():continue
  plan=read(g/'guard_plan.json');res=read(g/'guard_result.json');pol=read(g/'policy_checks.json');log=(g/'driver.log').read_text();ident(g/'driver.log')
  assert plan['selected_cpu_ids']==[0,1,2,3] and plan['semantic_stall_seconds']==120
  assert plan['minimum_mem_available_kb']==192*1024*1024
  assert plan['maximum_owned_rss_kb']<=(24 if phase=='static' else 8)*1024*1024
  assert plan['maximum_seconds']<=(1800 if phase=='static' else 3600)
  for x in pol:
   assert x['matches'] and x['nice']==19 and x['affinity']==[0,1,2,3] and x['ionice']=='idle' and x['ionice_exit']==0,x
  for filename in ['launch.json','guard_trigger.json','semantic_timeline.jsonl','memory_timeline.csv']:
   if (g/filename).exists():ident(g/filename)
  guards.append({'attempt':name,'phase':phase,'start':plan['at'],'finish':res['finished_at'],'result':res,'policy_samples':len(pol),'fatal':bool(re.search(r'^Fatal:',log,re.M)),'error':bool(re.search(r'^ERROR',log,re.M))})
for a,b in zip(names,names[1:]):
 def local(m,n):
  d={}
  for x in m:
   p=Path(x['path'])
   if str(BASE/n)+'/' in str(p):d[str(p.relative_to(BASE/n))]=x
  return d
 left,right=local(manifests[a],a),local(manifests[b],b)
 keys=sorted(left.keys()|right.keys());change=[]
 for k in keys:
  x,y=left.get(k),right.get(k)
  if x is None or y is None or x['sha256']!=y['sha256']:
   change.append({'path':k,'before':x,'after':y})
   if x and y and Path(k).suffix in ['.sv','.py','.tcl']:
    diff=''.join(difflib.unified_diff(Path(x['path']).read_text().splitlines(True),Path(y['path']).read_text().splitlines(True),fromfile=a+'/'+k,tofile=b+'/'+k))
    q=OUT/'diffs'/f'{a[:5]}_{b[:5]}'/k;q.parent.mkdir(parents=True,exist_ok=True);q.with_suffix(q.suffix+'.diff').write_text(diff)
 differences.append({'before':a,'after':b,'changed_local_files':change})
for x,y in zip(sorted(guards,key=lambda g:g['start']),sorted(guards,key=lambda g:g['start'])[1:]):assert x['finish']<=y['start'],(x,y)
p=BASE/names[-1];log=(p/'guard_full/driver.log').read_text()
progress=[int(x) for x in re.findall(r'^FFN0_PROGRESS work=(\d+)$',log,re.M)]
assert len(progress)==36 and all(b>a for a,b in zip(progress,progress[1:])) and progress[-1]==840
w=[tuple(map(int,m)) for m in re.findall(r'^MATRIX_PROGRESS cycle=(\d+) stage=0 W_q0_R=(\d+) W_q1_R=(\d+) W_scale_R=(\d+)$',log,re.M)]
assert len(w)==52 and w[-1]==(204365,26624,26622,5248)
assert all(all(bb>=aa for aa,bb in zip(a,b)) and b[1]>a[1] for a,b in zip(w,w[1:]))
assert log.count('FFN0_SIM_START')==1 and 'LNQ0_LN_SOURCE_PASS rows=4' in log
assert not re.search(r'^(?:Fatal:|ERROR|FFN0_CHAIN_PASS)',log,re.M)
assert guards[-1]['result']['child_exit_code']==-9 and guards[-1]['result']['trigger']=='semantic_stall'
trigger=read(p/'guard_full/guard_trigger.json')
cost=read(p/'full_cost_decision.json');pre=read(p/'preflight_full.json');launch=read(p/'guard_full/launch.json')
assert cost['at']<pre['checked_at']<launch['at']
assert abs(cost['wall_projection_seconds_with_5pct_margin']-cost['workload_allowance_cycles']/cost['selected_conservative_rate_cycles_per_s']*1.05)<1e-8
assert cost['workload_allowance_cycles']==375074+103289+21637
assert cost['rss_projection_kib']==cost['pilot']['peak_owned_rss_kib']*2
# Frozen ROM/fixture audit was a launch condition; verify current identities independently.
for n in ['receipt.json','verification.json','guard_host_test.json','preflight_pilot.json','result_short.json','result_pilot.json','result_full.json']:
 read(p/n)
mid='measurement-first-FFN0-AT057-bounded-guard-stop-handoff-20261014'; msg=read(ROOT/'.research-agent/communications'/f'{mid}.json')
keys=['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']
assert hashlib.sha256(json.dumps({k:msg[k] for k in keys},ensure_ascii=False,sort_keys=True).encode()).hexdigest()==msg['payload_sha256']
assert msg['status']=='delivered' and msg['from_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279' and msg['to_thread_id']=='01a129af-0395-7fd0-95ac-edd54873bd5f'
assert (ROOT/msg['message_file']).read_text()==msg['text'];ident(ROOT/msg['message_file'])
for n in ['project/E005_full_request_performance/experiment_source/summary.md','project/E005_full_request_performance/experiment_results/summary.md','project/E005_full_request_performance/experiment_status/summary.md','agent/A002/state.json']:
 ident(ROOT/n)
prior=['goal/goal.md','mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md','results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md','agent/A001/result.md','agent/A001/state.json','NEW_CHAT_START.md']
for n in prior:
 q=OUT/'prior_records'/n
 if not q.exists():q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
result={'at':dt.datetime.now(dt.timezone.utc).isoformat(),'scope':'Controller read-only hashes, frozen diff, raw logs and JSON; no DUT/reference/tool replay','verdict':'COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER; no full-chain PASS or DUT deadlock conclusion','manifest_references':len(checks),'at057_references':len(manifests[names[-1]]),'at057_unique_paths':len({x['path'] for x in manifests[names[-1]]}),'manifest_checks':checks,'evidence_paths':len(cache),'evidence':list(cache.values()),'guards':guards,'guard_count':len(guards),'policy_samples':sum(x['policy_samples'] for x in guards),'at057_policy_samples':sum(x['policy_samples'] for x in guards if x['attempt']==names[-1]),'guards_serial':True,'diffs':differences,'full_log':{'accepted_progress_records':len(progress),'last_progress':progress[-1],'w_progress_records':len(w),'first_w':w[0],'last_w':w[-1],'trigger':trigger,'no_chain_pass':True},'cost':{'formula_recomputed':True,'decision_before_preflight_before_launch':True,'workload_is_sum_based_planning_not_measurement':True},'host_test_scope':'Frozen code tests parser transitions only, no logical time sequence or full SV observer-to-parser mapping; no host RSS/policy samples','missing_short_tests':['failed Down done','old/Wi completion','done_valid held without consume','missing one retirement prerequisite','old TMP bank1/epoch2 descriptor','wrong final destination'], 'old_evidence_unchanged':True}
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['manifest_references','at057_references','at057_unique_paths','evidence_paths','guard_count','policy_samples','at057_policy_samples','verdict']},ensure_ascii=False))
