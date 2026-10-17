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

index = RUNS / 'executor_managed_query_deliverables_20261013.json'
assert sha(index) == '2dde48c8e037f000b804e2c0a0a437038a981e6947ee87f34f19fbf884796eec'
delivered = read(index)['artifacts']; assert len(delivered) == 30; snap(index)
for x in delivered:
    assert sha(x['path']) == x['sha256']; snap(x['path'])
engineering = read(RUNS / 'executor_managed_query_verification_20261013.json')
history_input = read(RUNS / 'executor_managed_query_history_20261013.json')
delta = read(RUNS / 'executor_managed_query_catalog_delta_20261013.json')
assert engineering['passed'] and not engineering['resource_observation_complete']
catalog = {x['after']['path']: x['after']['sha256'] for x in delta['changes']}
known_live = {x['current']['path']: x['current']['sha256'] for x in history_input['live_differences']}
names = [f'executor_handoff_portal_rtl_{i:02}' for i in range(6,11)] + [
    'executor_handoff_shell_rtl_05','executor_checkpoint_rtl_08',
    'bootstrap_source_guard_rtl_10','generated_store_monitor_rtl_16',
    'executor_managed_query_decode_host_02']
pairs=[]; references=[]; stages=[]; manifests={}; warnings={}
for name in names:
    base=RUNS/name; m=read(base/'input_manifest.json'); rc=read(base/'receipt.json')
    manifests[name]=m; assert rc['status']=='PASS'
    for e in entries(m):
        a,b=e['original'],e['frozen']; assert sha(b['path'])==a['sha256']==b['sha256']
        pairs.append(dict(attempt=name,path=a['path'],frozen_path=b['path'],expected=a['sha256'],current=sha(a['path']),current_match=sha(a['path'])==a['sha256'],frozen_match=True,pair_match=True))
        snap(b['path'])
        if sha(a['path'])!=a['sha256']: snap(a['path'])
    references.extend(refs(m,name+'/manifest')); references.extend(refs(rc,name+'/receipt'))
    launcher=read(base/'launcher.json'); snap(base/'launcher.json')
    assert launcher['pass'] and launcher['cpu_affinity']==[0,1,2,3] and launcher['nice']==19 and launcher['ionice']=='idle' and launcher['mem_available_kib']>=201326592
    for gd in sorted(base.glob('guard*')):
        if not gd.is_dir(): continue
        guard=read(gd/'guard_result.json'); plan=read(gd/'guard_plan.json'); launch=read(gd/'launch.json')
        policy=read(gd/'policy_checks.json') if (gd/'policy_checks.json').exists() else []
        raw=(gd/'driver.log').read_text(); markers=[l for l in raw.splitlines() if l.startswith('FULL_') and '_PASS' in l]
        mode=gd.name.removeprefix('guard_'); max_sec,max_rss=(1800,25165824) if name.endswith('host_02') else (120,8388608)
        if gd.name=='guard': assert guard==rc['guard_result'] and all(x in markers for x in rc['marker'])
        else: assert guard==rc[mode]['guard'] and rc[mode]['runner_exit_code']==0 and all(x in markers for x in rc[mode]['markers'])
        assert guard['child_exit_code']==0 and guard['trigger'] is None
        assert plan['maximum_seconds']==max_sec and plan['maximum_owned_rss_kb']==max_rss and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==201326592
        assert guard['elapsed_seconds']<=max_sec and guard['minimum_mem_available_kb']>=201326592
        assert all(p['matches'] and p['affinity']==[0,1,2,3] and p['nice']==19 and p['ionice']=='idle' for p in policy)
        if guard['rss_captured']: assert guard['peak_owned_rss_kb']<=max_rss and policy
        else: assert (name,mode) in [('executor_handoff_shell_rtl_05','oracle'),('executor_managed_query_decode_host_02','run')] and guard['peak_owned_rss_kb'] is None and not policy and guard['rss_capture_count']==0
        for f in ['guard_plan.json','guard_result.json','launch.json','policy_checks.json','driver.log']:
            if (gd/f).exists(): snap(gd/f)
        stages.append(dict(attempt=name,mode=mode,start=launch['at'],finish=guard['finished_at'],guard=guard,plan=plan,policy_count=len(policy),markers=markers))
        warnings[name+'/'+mode]=raw.count('contains leftover data')
    for folder in ['fixture','control_fixture','host_fixture']:
        if (base/folder).exists():
            for p in (base/folder).rglob('*'):
                if p.is_file() and p.stat().st_size<2000000: snap(p)
ordered=sorted(stages,key=lambda x:x['start'])
assert all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]))
assert len(stages)==12 and sum(s['policy_count'] for s in stages)==194
assert len(pairs)==401 and len(references)==1402
changes=[]
for x in pairs:
    if x['current_match']: continue
    kind='catalog' if catalog.get(x['path'])==x['current'] else ('disclosed_TB_runner' if known_live.get(x['path'])==x['current'] else 'later_live_change')
    changes.append({**x,'classification':kind})
assert len(changes)==23 and sum(x['classification']=='catalog' for x in changes)==17 and sum(x['classification']=='disclosed_TB_runner' for x in changes)==6
assert sum(x['match'] for x in references)==1379
history=[]
for record in history_input['comparisons']:
    oldname,newname=record['old'],record['new']
    old={x['original']['path']:x for x in entries(read(RUNS/oldname/'input_manifest.json'))}
    new={x['original']['path']:x for x in entries(read(RUNS/newname/'input_manifest.json'))}
    changed=[]
    for path in old.keys() & new.keys():
        a,b=old[path]['frozen'],new[path]['frozen']; assert sha(a['path'])==a['sha256'] and sha(b['path'])==b['sha256']
        if a['sha256']!=b['sha256']:
            changed.append(path);snap(a['path']);snap(b['path'])
            if Path(path).suffix in ['.cpp','.h','.sv','.py','.tcl','.json','.md']:
                q=OUT/'diff'/(oldname+'__'+newname)/(Path(path).name+'.diff');q.parent.mkdir(parents=True,exist_ok=True)
                q.write_text(''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True),Path(b['path']).read_text().splitlines(True),fromfile=oldname+'/'+Path(path).name,tofile=newname+'/'+Path(path).name)))
    assert len(old.keys() & new.keys())==record['common_pairs'] and set(changed)=={x['original_path'] for x in record['changed']}
    for n in [oldname,newname]:
        for f in ['input_manifest.json','receipt.json']: snap(RUNS/n/f)
    history.append(dict(before=oldname,after=newname,common=record['common_pairs'],changed=sorted(changed),added=sorted(new.keys()-old.keys()),removed=sorted(old.keys()-new.keys())))
failed=RUNS/'executor_managed_query_decode_host_01'
assert read(failed/'receipt.json')['status']=='FAIL'
failed_log=(failed/'guard_build/driver.log').read_text(); assert 'explicit' in failed_log and 'error:' in failed_log
assert not (failed/'guard_run').exists()
for f in ['guard_build/driver.log','guard_build/guard_result.json']:snap(failed/f)

# Independently inspect literal capture bytes; do not execute DUT/fixture generators.
captures=[]
host=RUNS/'executor_managed_query_decode_host_02/frozen'
for i,n in enumerate(names[:3]):
    b=RUNS/n; cap=b/'fixture/actual_handoff_checkpoint.hex'
    rows=cap.read_text().split(); assert len(rows)==16 and all(len(x)==128 for x in rows)
    raw=b''.join(bytes.fromhex(x)[::-1] for x in rows)
    gold=b/'control_fixture'/('revoked_proof_gold.hex' if i<2 else 'proof.hex')
    assert cap.read_bytes()==gold.read_bytes()
    external=host/'external/rtl'/str(i)
    for f in ['input_manifest.json','receipt.json','fixture/actual_handoff_checkpoint.hex','control_fixture/query.hex','control_fixture/proof.hex','control_fixture/revoked_proof_gold.hex','host_fixture/request.bin','host_fixture/aux_header.bin']:
        assert (b/f).read_bytes()==(external/f).read_bytes();snap(external/f)
    expected='b6dc2a9345af331329b627f676bd4b49fe3d6ee634413899a99af2aaca375b66' if i<2 else '05fd66a4d50e3bcca0d086a3cb2503202f595ed10a6d1e287cc817a34e1a64a6'
    assert hashlib.sha256(raw).hexdigest()==expected
    (OUT/(n+'_capture.bin')).write_bytes(raw)
    captures.append(dict(attempt=n,hex_sha256=sha(cap),raw_sha256=expected,bytes=1024,literal_direct_equal=True,frozen_host_inputs_direct_equal=True))
core={}
for fname,expected in engineering['core_identities'].items():
    observed=[]
    for n in names[:5]:
        e=[x for x in entries(manifests[n]) if Path(x['original']['path']).name==fname]; assert len(e)==1
        observed.append(sha(e[0]['frozen']['path']))
    assert len(set(observed))==1 and sorted(set(observed))==expected
    core[fname]=observed[0]
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json','.research-agent/communications/executor-managed-query-milestone-20261013.json','results/executor_close_rearm_contract_20261013.md','results/executor_cancel_f18_reply_20261013.md']:
    snap(ROOT/f)
for f in ['experiment_source/summary.md','experiment_results/summary.md','experiment_status/summary.md']:snap(ROOT/'project/E003_production_chain_closure'/f)
summary=dict(pairs=len(pairs),frozen_matches=len(pairs),declared_pairs=len(pairs),current_matches=sum(x['current_match'] for x in pairs),references=len(references),reference_matches=sum(x['match'] for x in references),deliverables=len(delivered),guards=len(stages),policy_records=194,catalog_differences=17,TB_runner_differences=6,unobserved_child_stages=[dict(attempt=x['attempt'],mode=x['mode'],elapsed=x['guard']['elapsed_seconds']) for x in stages if not x['guard']['rss_captured']])
v=dict(review_id='R-SM003-EXECUTOR-MANAGED-QUERY-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,delivered=delivered,pairs=pairs,references=references,current_differences=changes,stages=stages,serial_no_overlap=True,history=history,captures=captures,core_identities=core,resource_observation_complete=False,warnings=warnings,snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],decision='pending_scoped_review',no_controller_compilation_simulation_hls=True,pre_registration_count_scope='395/401 inferred from unchanged catalog identity, not independently sampled historical state')
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=summary,warnings=warnings,history=[dict(before=x['before'],after=x['after'],common=x['common'],changed=[Path(p).name for p in x['changed']]) for x in history]),ensure_ascii=False,indent=2))
