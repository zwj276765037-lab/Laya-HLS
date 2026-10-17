from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib, re, struct
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
AGG=RUNS/'executor_checkpoint_rtl_current_verification_20261013.json'
DELTA=RUNS/'executor_checkpoint_rtl_catalog_final_delta_20261013.json'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text())
assert sha(AGG)=='d7d67a7947deecfc6f7c5e4af74118ac9874793959a06e0bfaa37c0797041f3c'
assert sha(DELTA)=='f8312a6160f12a525bcc4a145133b8865a6c0012da24899f17cff4f5f90dd390'
agg=read(AGG);delta=read(DELTA)
snapshots={};pairs=[];refs=[];stages=[];deliverables=[];history={};diffs=[]
def snap(p):
 p=Path(p);t=OUT/'snapshot'/p.relative_to(ROOT);t.parent.mkdir(parents=True,exist_ok=True)
 if not t.exists():shutil.copyfile(p,t)
 assert sha(t)==sha(p),str(p)
 snapshots[str(t.relative_to(ROOT))]=sha(t)
def entries(x):
 if isinstance(x,dict):
  if 'original' in x and 'frozen' in x:yield x
  else:
   for v in x.values():yield from entries(v)
 elif isinstance(x,list):
  for v in x:yield from entries(v)
def walk(x,origin):
 if isinstance(x,dict):
  if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
   p=Path(x['path']);h=sha(p) if p.is_file() else None
   refs.append(dict(origin=origin,path=str(p),expected=x['sha256'],actual=h,match=h==x['sha256']))
  for v in x.values():walk(v,origin)
 elif isinstance(x,list):
  for v in x:walk(v,origin)
for p in [AGG,DELTA]:snap(p)
for a in agg['attempts']:
 n=a['attempt'];base=RUNS/n;m=read(base/'input_manifest.json');r=read(base/'receipt.json')
 assert r['status']=='PASS'
 for x in a['deliverables'].values():
  assert sha(x['path'])==x['sha256'];deliverables.append(x);snap(x['path'])
 for e in entries(m):
  x,y=e['original'],e['frozen'];c,f=sha(x['path']),sha(y['path'])
  pairs.append(dict(attempt=n,path=x['path'],frozen_path=y['path'],expected=x['sha256'],current=c,frozen=f,current_match=c==x['sha256'],frozen_match=f==y['sha256'],pair_match=x['sha256']==y['sha256']))
  if Path(y['path']).suffix in ['.sv','.py','.cpp','.h','.cmake','.json','.md','.tcl']:snap(y['path'])
  if c!=x['sha256']:snap(x['path'])
 walk(m,n+'/manifest');walk(r,n+'/receipt')
 launcher=read(base/'launcher.json');snap(base/'launcher.json')
 assert launcher['pass'] and launcher['cpu_affinity']==[0,1,2,3] and launcher['nice']==19 and launcher['ionice']=='idle' and launcher['mem_available_kib']>=201326592
 ss=[('guard',r)] if 'guard_result' in r else [(k,s) for k,s in r.items() if isinstance(s,dict) and 'guard' in s]
 for label,s in ss:
  gd=base/('guard' if label=='guard' else 'guard_'+label);g=read(gd/'guard_result.json');plan=read(gd/'guard_plan.json');launch=read(gd/'launch.json')
  policy=read(gd/'policy_checks.json') if (gd/'policy_checks.json').exists() else []
  raw=(gd/'driver.log').read_text();markers=[l for l in raw.splitlines() if l.startswith('FULL_') and '_PASS' in l and not l.endswith('_SCRIPT_PASS')]
  assert markers==s.get('marker',s.get('markers')) and g==s.get('guard_result',s.get('guard')) and s.get('runner_exit_code',0)==0
  assert g['child_exit_code']==0 and g['trigger'] is None
  assert plan['maximum_seconds']==(120 if label=='guard' else 1800) and plan['maximum_owned_rss_kb']==(8388608 if label=='guard' else 25165824)
  assert g['elapsed_seconds']<=plan['maximum_seconds'] and plan['minimum_mem_available_kb']==201326592 and plan['semantic_stall_seconds']==120
  assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy)
  if g['rss_captured']:assert g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and g['minimum_mem_available_kb']>=201326592 and policy
  else:assert n=='executor_checkpoint_rtl_decode_02' and label=='run' and not policy and g['peak_owned_rss_kb'] is None
  ga=next(x for x in a['guards'] if x['directory']==str(gd));assert ga['result']==g and ga['plan']==plan and ga['policy_count']==len(policy)
  for x in ga['artifacts'].values():assert sha(x['path'])==x['sha256']
  for f in ['guard_plan.json','guard_result.json','launch.json','driver.log','policy_checks.json']:
   if (gd/f).exists():snap(gd/f)
  stages.append(dict(attempt=n,stage=label,start=launch['at'],finish=g['finished_at'],guard=g,plan=plan,policy_count=len(policy),markers=markers))
ordered=sorted(stages,key=lambda x:x['start']);serial=all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]));assert serial and len(stages)==7 and sum(s['policy_count'] for s in stages)==114
expected_current={x['after']['path']:x['after']['sha256'] for x in delta['changes']}
differences=[{**x,'matches_catalog_delta':expected_current.get(x['path'])==x['current']} for x in pairs if not x['current_match']]
for i in range(2,6):
 old=f'executor_checkpoint_rtl_{i:02}';new=f'executor_checkpoint_rtl_{i+1:02}'
 aa={e['original']['path']:e for e in entries(read(RUNS/old/'input_manifest.json'))};bb={e['original']['path']:e for e in entries(read(RUNS/new/'input_manifest.json'))};changes=[]
 for f in sorted(aa.keys()&bb.keys()):
  x,y=aa[f]['frozen'],bb[f]['frozen']
  if x['sha256']!=y['sha256']:
   changes.append(f);p=OUT/'diff'/(old+'__'+new)/(Path(f).name+'.diff');p.parent.mkdir(parents=True,exist_ok=True)
   p.write_text(''.join(difflib.unified_diff(Path(x['path']).read_text().splitlines(True),Path(y['path']).read_text().splitlines(True),fromfile=old+'/'+Path(f).name,tofile=new+'/'+Path(f).name)))
 diffs.append(dict(old=old,new=new,common_pairs=len(aa.keys()&bb.keys()),changes=changes))
 r=read(RUNS/old/'receipt.json');raw=(RUNS/old/'guard/driver.log').read_text()
 history[old]=dict(status=r['status'],guard=r['guard_result'],errors=[l for l in raw.splitlines() if l.startswith(('Fatal:','ERROR:'))])
 for f in ['input_manifest.json','receipt.json','guard/driver.log','guard/guard_result.json']:snap(RUNS/old/f)
first=RUNS/'executor_checkpoint_rtl_01';history[first.name]=read(first/'entry_failure.json');snap(first/'entry_failure.json');assert not (first/'receipt.json').exists() and not (first/'input_manifest.json').exists()
fixture=RUNS/'executor_checkpoint_rtl_06/fixture';capture=fixture/'actual_checkpoint.hex'
def hexbytes(p):
 lines=Path(p).read_text().split();assert len(lines)==16 and all(len(l)==128 for l in lines)
 return b''.join(bytes.fromhex(l)[::-1] for l in lines)
actual=hexbytes(capture);gold=bytearray((fixture/'checkpoint_good.bin').read_bytes());struct.pack_into('<Q',gold,16,4);struct.pack_into('<Q',gold,680,4);assert actual==gold
hostm=read(RUNS/'executor_checkpoint_rtl_decode_02/input_manifest.json');capture_refs=[e for e in entries(hostm) if e['original']['path']==str(capture)];assert len(capture_refs)==1 and sha(capture_refs[0]['frozen']['path'])==sha(capture)
raw=(RUNS/'executor_checkpoint_rtl_06/guard/driver.log').read_text();times=re.findall(r'\$finish called at time\s*:\s*(\d+)\s*ns',raw);assert times==['797850']
tb=RUNS/'executor_checkpoint_rtl_06/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_executor_checkpoint_tb_v2.sv';assert 'always #5 clk=~clk;' in tb.read_text() and 'cycles>100000' in tb.read_text()
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/state.json','agent/A001/result.md','agent/A002/state.json','.research-agent/discussions.json']:snap(ROOT/f)
summary=dict(pairs=len(pairs),current_matches=sum(x['current_match'] for x in pairs),frozen_matches=sum(x['frozen_match'] for x in pairs),pair_matches=sum(x['pair_match'] for x in pairs),references=len(refs),reference_matches=sum(x['match'] for x in refs),delivered_aggregate_hashes=2,aggregate_bound_deliverables=len(deliverables),stages=len(stages),policy_count=sum(x['policy_count'] for x in stages))
assert len(pairs)==183 and len(refs)==621 and all(x['frozen_match'] and x['pair_match'] for x in pairs)
v=dict(review_id='R-SM003-EXECUTOR-CHECKPOINT-RTL-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,pairs=pairs,references=refs,deliverables=deliverables,stages=stages,serial_no_overlap=serial,current_differences=differences,history=history,diffs=diffs,count_correction=dict(engineering_total=181,independent_total=183,reason='generated_source_lease_06 has 11 files plus 2 frozen contracts; engineering pairs omitted contracts although recursive references included them',original_aggregate_preserved=True),actual_capture_oracle=dict(capture=str(capture),capture_sha256=sha(capture),literal_gold_sha256=sha(fixture/'checkpoint_good.bin'),query_sequence=4,handoff_epoch=4,full_1024_bytes_equal=True,host_frozen_capture_equal=True),simulation_cycles=dict(derived=79785,finish_ns=797850,period_ns=10,cap=100000,marker_prints_cycles=False,performance_claim=False),snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],decision='pending_source_review',no_controller_compilation_simulation_hls=True)
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=summary,current_differences=[dict(attempt=x['attempt'],path=x['path'],catalog=x['matches_catalog_delta']) for x in differences],diffs=diffs,history=history),ensure_ascii=False,indent=2))
