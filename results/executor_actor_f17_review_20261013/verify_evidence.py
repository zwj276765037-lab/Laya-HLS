from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib, struct, re

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUNS = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
cache = {}
def sha(p):
    p = Path(p)
    if str(p) not in cache:
        cache[str(p)] = hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
    return cache[str(p)]
def read(p): return json.loads(Path(p).read_text())
snapshots = {}
def snap(p):
    p = Path(p); t = OUT / 'snapshot' / p.relative_to(ROOT)
    t.parent.mkdir(parents=True, exist_ok=True)
    if not t.exists(): shutil.copyfile(p, t)
    assert sha(p) == sha(t)
    snapshots[str(t.relative_to(ROOT))] = sha(t)
def entries(x):
    if isinstance(x, dict):
        if 'original' in x and 'frozen' in x: yield x
        else:
            for v in x.values(): yield from entries(v)
    elif isinstance(x, list):
        for v in x: yield from entries(v)
def refs(x, origin):
    if isinstance(x, dict):
        if isinstance(x.get('path'), str) and isinstance(x.get('sha256'), str):
            actual = sha(x['path'])
            yield dict(origin=origin, path=x['path'], expected=x['sha256'], actual=actual, match=actual == x['sha256'])
        for v in x.values(): yield from refs(v, origin)
    elif isinstance(x, list):
        for v in x: yield from refs(v, origin)


agg_path=RUNS/'executor_actor_f17_verification_20261013.json'
delta_path=RUNS/'executor_actor_f17_catalog_delta_20261013.json'
assert sha(agg_path)=='5263b47965eaf9e8e52698af1d8d1da459466630adc78a0d7898026ac96f727b'
agg=read(agg_path);delta=read(delta_path)
delivered_path=RUNS/'executor_actor_f17_deliverables_20261013.json'
delivered=read(delivered_path)['files'];snap(delivered_path)
for p in delivered:assert sha(p['path'])==p['sha256'];snap(p['path'])
base=RUNS/'executor_actor_host_04';m=read(base/'input_manifest.json');receipt=read(base/'receipt.json')
assert receipt['status']=='PASS'
pairs=[]
for e in entries(m):
 a,b=e['original'],e['frozen'];current,frozen=sha(a['path']),sha(b['path'])
 assert frozen==b['sha256']==a['sha256']
 pairs.append(dict(path=a['path'],frozen_path=b['path'],expected=a['sha256'],current=current,frozen=frozen,current_match=current==a['sha256'],frozen_match=True,pair_match=True))
 if Path(b['path']).suffix in ['.h','.cpp','.py','.sv','.json','.cmake','.md']:snap(b['path'])
 if current!=a['sha256']:snap(a['path'])
references=list(refs(m,'manifest'))+list(refs(receipt,'receipt'))
assert len(pairs)==83 and len(references)==195
expected_catalog={e['after']['path']:e['after']['sha256'] for e in delta['changes']}
differences=[dict(p,matches_catalog_delta=expected_catalog.get(p['path'])==p['current']) for p in pairs if not p['current_match']]
assert len(differences)==2 and all(p['matches_catalog_delta'] for p in differences)
assert sum(p['match'] for p in references)==193
launcher=read(base/'launcher.json');snap(base/'launcher.json')
assert launcher['pass'] and launcher['cpu_affinity']==[0,1,2,3] and launcher['nice']==19 and launcher['ionice']=='idle' and launcher['mem_available_kib']>=201326592
stages=[]
for mode in ['oracle','build','run']:
 gd=base/('guard_'+mode);g=read(gd/'guard_result.json');plan=read(gd/'guard_plan.json');launch=read(gd/'launch.json');policy=read(gd/'policy_checks.json');raw=(gd/'driver.log').read_text()
 assert receipt[mode]['runner_exit_code']==0 and g==receipt[mode]['guard'] and g['child_exit_code']==0 and g['trigger'] is None
 assert plan['maximum_seconds']==1800 and plan['maximum_owned_rss_kb']==25165824 and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==201326592
 assert g['elapsed_seconds']<1800 and g['rss_captured'] and g['peak_owned_rss_kb']<25165824 and g['minimum_mem_available_kb']>=201326592 and policy
 assert all(p['matches'] and p['affinity']==[0,1,2,3] and p['nice']==19 and p['ionice']=='idle' for p in policy)
 markers=[l for l in raw.splitlines() if l.startswith('FULL_') and '_PASS' in l]
 assert all(l in markers for l in receipt[mode]['markers'])
 if mode!='oracle':assert markers==receipt[mode]['markers']
 for f in ['guard_result.json','guard_plan.json','launch.json','policy_checks.json','driver.log']:snap(gd/f)
 stages.append(dict(mode=mode,start=launch['at'],finish=g['finished_at'],guard=g,plan=plan,policy_count=len(policy),markers=markers))
assert sum(s['policy_count'] for s in stages)==28
assert all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(stages,stages[1:]))
# Compare complete frozen closures and preserve the real compile failure.
diffs=[]
new={e['original']['path']:e for e in entries(m)}
for name in ['executor_actor_host_02','executor_actor_host_03']:
 old={e['original']['path']:e for e in entries(read(RUNS/name/'input_manifest.json'))};changed=[]
 for path in sorted(old.keys()&new.keys()):
  a,b=old[path]['frozen'],new[path]['frozen'];assert sha(a['path'])==a['sha256'] and sha(b['path'])==b['sha256']
  if a['sha256']!=b['sha256']:
   changed.append(path);p=OUT/'diff'/name/(Path(path).name+'.diff');p.parent.mkdir(parents=True,exist_ok=True)
   p.write_text(''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True),Path(b['path']).read_text().splitlines(True),fromfile=name+'/'+Path(path).name,tofile='actor_04/'+Path(path).name)))
 for f in ['input_manifest.json','receipt.json']:snap(RUNS/name/f)
 diffs.append(dict(old=name,new='executor_actor_host_04',common_pairs=len(old.keys()&new.keys()),changes=changed))
assert len(diffs[0]['changes'])==6 and len(diffs[1]['changes'])==1 and diffs[1]['changes'][0].endswith('/tests/executor_actor_test.cpp')
old03=read(RUNS/'executor_actor_host_03/receipt.json');assert old03['status']=='FAIL' and old03['build']['guard']['child_exit_code']!=0
for f in ['guard_build/driver.log','guard_build/guard_result.json']:snap(RUNS/'executor_actor_host_03'/f)
assert 'inconsistent deduction' in (RUNS/'executor_actor_host_03/guard_build/driver.log').read_text()
for p in receipt['fixture_files']:
 assert sha(p['path'])==p['sha256'];snap(p['path'])
 relative=Path(p['path']).relative_to(base);assert sha(RUNS/'executor_actor_host_02'/relative)==p['sha256']
raw=(base/'guard_run/driver.log').read_text();warnings=[l for l in raw.splitlines() if 'contains leftover data' in l]
assert len(warnings)==45 and 'maximum depth reached by any hls::stream() instance in the design is 24' in raw
src=(base/'frozen/hls/control/executor_actor.cpp').read_text();tb=(base/'frozen/tests/executor_actor_test.cpp').read_text()
assert 'const auto& b = s.admitted_base;' in src and 's.admitted_base = in.fence.base;' in src
assert 'for(unsigned stage=0;stage<5;++stage)for(unsigned which=0;which<(stage<3?11u:6u);++which)' in tb
assert 'if(stage==1)for(unsigned i=0;i<3;++i)h.call();' in tb and 'if(stage==2)for(unsigned i=0;i<8;++i)h.call();' in tb
# Check the frozen build did not compile out assert-based cases.
assert all('NDEBUG' not in arg for arg in m['planned_commands']['build'])
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json','results/executor_handoff_actor_host_reply_20261013.md','results/executor_checkpoint_import_handshake_contract_20261013.md','.research-agent/communications/executor-actor-f17-milestone-20261013.json']:snap(ROOT/f)
summary=dict(frozen_pairs=83,declared_pairs=83,current=81,references=195,references_matching=193,deliverables=len(delivered),guards=3,policy_records=28,prestart_cases=33,active_cases=12)
v=dict(review_id='R-SM003-EXECUTOR-ACTOR-F17-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,pairs=pairs,references=references,current_differences=differences,delivered=delivered,stages=stages,serial_no_overlap=True,diffs=diffs,history=dict(actor_02='PASS preserved',actor_03='FAIL compile auto type deduction preserved',actor_04='PASS'),fixture_files_unchanged_from_actor_02=True,run_warnings=dict(count=45,kind='leftover hls::stream data',scope='each negative case intentionally leaves eight unread action beats; no claim streams empty or hardware recovery',maximum_host_stream_depth=24),snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],decision='pending_source_review',no_controller_compilation_simulation_hls=True)
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=summary,differences=[p['path'] for p in differences],diffs=diffs),ensure_ascii=False,indent=2))
