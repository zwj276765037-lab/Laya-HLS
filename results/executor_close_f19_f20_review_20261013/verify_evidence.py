from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib, struct, re

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUNS = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
cache = {}
data_cache = {}
def sha(p):
    p = Path(p)
    if str(p) not in cache:
        data_cache[str(p)] = p.read_bytes() if p.is_file() else None
        cache[str(p)] = hashlib.sha256(data_cache[str(p)]).hexdigest() if data_cache[str(p)] is not None else None
    return cache[str(p)]
def read(p): return json.loads(Path(p).read_text())
snapshots = {}
def snap(p):
    p = Path(p); t = OUT / 'snapshot' / p.relative_to(ROOT)
    h=sha(p)
    if t.exists() and hashlib.sha256(t.read_bytes()).hexdigest()!=h: t=OUT/'additional_observations'/h/p.relative_to(ROOT)
    t.parent.mkdir(parents=True, exist_ok=True)
    if not t.exists(): t.write_bytes(data_cache[str(p)])
    assert h == sha(t)
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

index=RUNS/'executor_close_f19_f20_deliverables_20261013.json'
assert sha(index)=='c28d0ebbe9ae0867c1422167e6ce04ca7190d7743b8bfdfecab4c369fc02fc69'
delivered=read(index)['files'];assert len(delivered)==28;snap(index)
for x in delivered:assert sha(x['path'])==x['sha256'];snap(x['path'])
engineering=read(RUNS/'executor_close_f19_f20_verification_20261013.json')
history_input=read(RUNS/'executor_close_f19_f20_history_20261013.json')
delta=read(RUNS/'executor_close_f19_f20_catalog_delta_20261013.json')
assert engineering['passed'] and not engineering['resource_observation_complete']
catalog={x['after']['path']:x['after']['sha256'] for x in delta['changes']}
names=['executor_request_close_shell_rtl_04','executor_request_close_host_06','executor_actor_host_08','executor_handoff_portal_rtl_15','executor_handoff_portal_rtl_16']
pairs=[];references=[];stages=[];warnings={};manifests={}
for name in names:
    base=RUNS/name;m=read(base/'input_manifest.json');rc=read(base/'receipt.json');manifests[name]=m
    assert rc['status']=='PASS'
    for e in entries(m):
        a,b=e['original'],e['frozen'];assert sha(b['path'])==a['sha256']==b['sha256']
        pairs.append(dict(attempt=name,path=a['path'],frozen_path=b['path'],expected=a['sha256'],current=sha(a['path']),current_match=sha(a['path'])==a['sha256'],frozen_match=True,pair_match=True));snap(b['path'])
        if sha(a['path'])!=a['sha256']:snap(a['path'])
    references.extend(refs(m,name+'/manifest'));references.extend(refs(rc,name+'/receipt'))
    launcher=read(base/'launcher.json');snap(base/'launcher.json')
    assert launcher['pass'] and launcher['cpu_affinity']==[0,1,2,3] and launcher['nice']==19 and launcher['ionice']=='idle' and launcher['mem_available_kib']>=201326592
    for gd in sorted(base.glob('guard*')):
        if not gd.is_dir():continue
        guard=read(gd/'guard_result.json');plan=read(gd/'guard_plan.json');launch=read(gd/'launch.json')
        policy=read(gd/'policy_checks.json') if (gd/'policy_checks.json').exists() else []
        raw=(gd/'driver.log').read_text();markers=[l for l in raw.splitlines() if l.startswith('FULL_') and '_PASS' in l]
        mode=gd.name.removeprefix('guard_');max_sec,max_rss=(120,8388608) if '_rtl_' in name else (1800,25165824)
        if gd.name=='guard':assert guard==rc['guard_result'] and all(x in markers for x in rc['marker'])
        else:assert guard==rc[mode]['guard'] and rc[mode]['runner_exit_code']==0 and all(x in markers for x in rc[mode]['markers'])
        assert guard['child_exit_code']==0 and guard['trigger'] is None
        assert plan['maximum_seconds']==max_sec and plan['maximum_owned_rss_kb']==max_rss and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==201326592
        assert guard['elapsed_seconds']<=max_sec and guard['minimum_mem_available_kb']>=201326592
        assert all(p['matches'] and p['affinity']==[0,1,2,3] and p['nice']==19 and p['ionice']=='idle' for p in policy)
        if guard['rss_captured']:assert guard['peak_owned_rss_kb']<=max_rss and policy
        else:assert (name,mode)==('executor_request_close_shell_rtl_04','oracle') and guard['peak_owned_rss_kb'] is None and not policy and guard['rss_capture_count']==0
        for f in ['guard_plan.json','guard_result.json','launch.json','policy_checks.json','driver.log']:
            if (gd/f).exists():snap(gd/f)
        stages.append(dict(attempt=name,mode=mode,start=launch['at'],finish=guard['finished_at'],guard=guard,plan=plan,policy_count=len(policy),markers=markers))
        warnings[name+'/'+mode]=raw.count('contains leftover data')
    for folder in ['fixture','control_fixture','host_fixture']:
        if (base/folder).exists():
            for p in (base/folder).rglob('*'):
                if p.is_file() and p.stat().st_size<2000000:snap(p)
ordered=sorted(stages,key=lambda x:x['start']);assert all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]))
assert len(stages)==10 and sum(x['policy_count'] for x in stages)==118
assert len(pairs)==295 and len(references)==880
changes=[{**x,'matches_catalog':catalog.get(x['path'])==x['current']} for x in pairs if not x['current_match']]
assert sum(x['matches_catalog'] for x in changes)==8
additional_live=[x for x in changes if not x['matches_catalog']]
# Live implementation is owned by the running engineer; preserve exact observed
# hashes and never infer a new PASS from ongoing edits. Frozen checks stay strict.
history=[]
for record in history_input['comparison']:
    oldname,newname=record['before'],record['after']
    old={x['original']['path']:x for x in entries(read(RUNS/oldname/'input_manifest.json'))}
    new={x['original']['path']:x for x in entries(read(RUNS/newname/'input_manifest.json'))}
    changed=[]
    for path in old.keys()&new.keys():
        a,b=old[path]['frozen'],new[path]['frozen'];assert sha(a['path'])==a['sha256'] and sha(b['path'])==b['sha256']
        if a['sha256']!=b['sha256']:
            changed.append(path);snap(a['path']);snap(b['path'])
            if Path(path).suffix in ['.cpp','.h','.sv','.py','.tcl','.json','.md']:
                q=OUT/'diff'/(oldname+'__'+newname)/(Path(path).name+'.diff');q.parent.mkdir(parents=True,exist_ok=True)
                q.write_text(''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True),Path(b['path']).read_text().splitlines(True),fromfile=oldname+'/'+Path(path).name,tofile=newname+'/'+Path(path).name)))
    assert len(old.keys()&new.keys())==record['common_pairs'] and set(changed)=={x['original'] for x in record['changed']}
    assert {new[x]['frozen']['path'] for x in new.keys()-old.keys()}=={x['path'] for x in record['added']}
    assert {old[x]['frozen']['path'] for x in old.keys()-new.keys()}=={x['path'] for x in record['removed']}
    for x in record['added']+record['removed']:assert sha(x['path'])==x['sha256'];snap(x['path'])
    for n in [oldname,newname]:
        for f in ['input_manifest.json','receipt.json']:snap(RUNS/n/f)
    history.append(dict(before=oldname,after=newname,common=record['common_pairs'],changed=sorted(changed),added=sorted(new.keys()-old.keys()),removed=sorted(old.keys()-new.keys())))
failures=[]
for n in ['executor_request_close_host_01','executor_request_close_host_02','executor_request_close_shell_rtl_01']:
    b=RUNS/n;assert read(b/'receipt.json')['status']=='FAIL'
    g=b/('guard_rtl' if '_rtl_' in n else 'guard_build');raw=(g/'driver.log').read_text()
    if '_host_' in n:assert 'error:' in raw and not (b/'guard_run').exists()
    else:assert 'exception' in raw.lower() and not re.search(r'^FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_RTL_PASS',raw,re.M)
    for f in ['driver.log','guard_result.json']:snap(g/f)
    failures.append(dict(attempt=n,status='FAIL',raw_log_sha256=sha(g/'driver.log'),run_started='_rtl_' in n))
# No DUT or oracle execution: reconstruct fixed literal controls from bytes.
fixture=RUNS/names[1]/'fixture';oldfixture=RUNS/'executor_actor_host_06/fixture'
for n in ['all_control.bin']+[f'control_{i}.bin' for i in range(1,8)]:assert (fixture/n).read_bytes()==(oldfixture/n).read_bytes();snap(oldfixture/n)
base=bytearray((fixture/'v2/checkpoint_request.bin').read_bytes());struct.pack_into('<IHH',base,0,0x3143484c,1,16)
struct.pack_into('<Q',base,32,(1<<64)-1);struct.pack_into('<QQ',base,776,29,101)
literals=[]
for kind in [8,9]:
    for failed in [False,True]:
        for commit in [0,1]:
            p=bytearray(base);p[8]=kind;p[792]=commit;struct.pack_into('<Q',p,680,19)
            if failed:struct.pack_into('<H',p,10,7);struct.pack_into('<I',p,24,0x0700000e)
            name=('close' if kind==8 else 'closed')+('_error' if failed else '_ok')+'_c'+str(commit)
            assert bytes(p)==(fixture/(name+'.bin')).read_bytes();literals.append(bytes(p))
assert b''.join(literals)==(fixture/'all_close_control.bin').read_bytes()
captures=[]
for failed in [False,True]:
    for commit in [0,1]:
        name='closed_'+('error' if failed else 'ok')+'_c'+str(commit)
        cap=RUNS/names[0]/'fixture'/(name+'_capture.hex');lines=cap.read_text().split()
        assert len(lines)==16 and all(len(x)==128 for x in lines)
        raw=b''.join(bytes.fromhex(x)[::-1] for x in lines)
        gold=bytearray(base);gold[8]=9;gold[792]=commit;struct.pack_into('<Q',gold,680,1)
        if failed:struct.pack_into('<H',gold,10,7);struct.pack_into('<I',gold,24,0x0700000e)
        assert raw==bytes(gold)==(fixture/('shell_'+name+'.bin')).read_bytes()
        assert cap.read_bytes()==(RUNS/names[0]/'fixture'/(name+'.hex')).read_bytes()
        external=RUNS/names[1]/'frozen/external/closed_results'/(name+'_capture.hex')
        assert cap.read_bytes()==external.read_bytes()
        captures.append(dict(name=name,hex_sha256=sha(cap),raw_sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw),independent_literal_H1=True,frozen_host_capture_equal=True))
sv=(RUNS/names[0]/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_handoff_layout_v1.sv').read_text()
for k,n in dict(CONTROL_BYTES=1024,CONTROL_BEATS=16,CONTROL_VERSION=1,CLOSE=8,CLOSED=9,SESSION_OFFSET=776,COMMITTED_OFFSET=792).items():assert re.search(r'\b'+k+r'\s*=\s*'+str(n)+r'\b',sv)
assert warnings['executor_request_close_host_06/run']==5 and warnings['executor_actor_host_08/run']==45
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json','.research-agent/communications/executor-close-f19-f20-milestone-20261013.json','results/executor_close_rearm_contract_20261013.md','results/executor_managed_query_reply_20261013.md']:snap(ROOT/f)
# Repair boundary markers read directly from the actual guard logs.
host_log=(RUNS/names[1]/'guard_run/driver.log').read_text()
f19=re.findall(r'^F19_RESULT_BOUNDARY_PASS case=(\d+) final_write_legacy_ignored=1 tagged_fact=1 close_once=1 tail2_tail1_read_wait=1 runtime_unchanged=1$',host_log,re.M)
assert f19==[str(i) for i in range(6)]
assert re.search(r'^FULL_CURRENT_EXECUTOR_REQUEST_CLOSE_PASS .*F19_boundary_cases=6 .*actual_closed_rtl_capture_frames=4 ',host_log,re.M)
shell_log=(RUNS/names[0]/'guard_rtl/driver.log').read_text()
assert re.search(r'^FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_RTL_PASS cases=19 cycles=4901 close_cases=17 F20_cases=22 ',shell_log,re.M)
assert "'cycle_cap':6000" in (RUNS/names[0]/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_handoff_shell_rtl.py').read_text()
old_index=RUNS/'executor_request_close_deliverables_20261013.json'
assert sha(old_index)=='e35b01a3dc7f759b30ef345095dd3f307b368313f877683cace78fd561cef1cc'
snap(old_index)
previous=history_input['previous_immutable_deliverables'];assert len(previous)==20
old_files={x['path']:x['sha256'] for x in read(old_index)['files']}
for item in previous:
    d=item['declared'];assert sha(d['path'])==d['sha256']==old_files[d['path']]
    assert item['match'] and item['actual']['sha256']==d['sha256'];snap(d['path'])
for f in ['results/executor_request_close_reply_20261013.md','results/executor_request_close_review_20261013/source_review.md','results/executor_managed_lpv_owner_contract_20261013.md','results/executor_managed_lpv_owner_reply_20261013.md'] :snap(ROOT/f)
summary=dict(pairs=len(pairs),frozen_matches=len(pairs),declared_pairs=len(pairs),current_matches=sum(x['current_match'] for x in pairs),references=len(references),reference_matches=sum(x['match'] for x in references),deliverables=len(delivered),guards=len(stages),policy_records=118,catalog_differences=8,additional_current_pair_differences=len(additional_live),engineering_delivery_current_claim=dict(current_matches=287,reference_matches=872,scope="historical engineering report; subsequent actor implementation drift observed"),unobserved_child_stages=[dict(attempt=x['attempt'],mode=x['mode'],elapsed=x['guard']['elapsed_seconds']) for x in stages if not x['guard']['rss_captured']])
v=dict(review_id='R-SM003-EXECUTOR-CLOSE-F19-F20-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,delivered=delivered,pairs=pairs,references=references,current_differences=changes,stages=stages,serial_no_overlap=True,history=history,failed_history=failures,captures=captures,legacy7_literal_unchanged=True,eight_close_literals_independently_reconstructed=True,resource_observation_complete=False,warnings=warnings,snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],repair_markers=dict(F19_cases=6,F20_cases=22,shell_cycles=4901,cycle_cap=6000),previous_immutable_deliverables=previous,decision='pending_scoped_review',no_controller_compilation_simulation_hls=True)
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=summary,captures=captures,warnings=warnings),ensure_ascii=False,indent=2))
