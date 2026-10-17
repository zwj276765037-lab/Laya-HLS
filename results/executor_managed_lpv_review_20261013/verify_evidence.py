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
    if not p.is_absolute():p=ROOT/p
    if str(p) not in cache:
        data_cache[str(p)] = p.read_bytes() if p.is_file() else None
        cache[str(p)] = hashlib.sha256(data_cache[str(p)]).hexdigest() if data_cache[str(p)] is not None else None
    return cache[str(p)]
def read(p): return json.loads(Path(p).read_text())
snapshots = {}
def snap(p):
    p = Path(p)
    if not p.is_absolute():p=ROOT/p
    t = OUT / 'snapshot' / p.relative_to(ROOT)
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

index=RUNS/'executor_managed_lpv_deliverables_20261013.json'
assert sha(index)=='7eed4fde079f496427a787dc048a0e6d6914fd60012961d521f8fce640474f5f'
delivered=read(index)['files'];
for item in delivered:item['path']=str((ROOT/item['path']).resolve())
assert len(delivered)==33;snap(index)
for x in delivered:assert sha(x['path'])==x['sha256'];snap(x['path'])
engineering=read(RUNS/'executor_managed_lpv_verification_20261013.json')
history_input=engineering
delta=read(RUNS/'executor_managed_lpv_catalog_delta_20261013.json')
assert engineering['passed'] and not engineering['resource_observation_complete']
catalog={x['after']['path']:x['after']['sha256'] for x in delta['changes']}
names=['executor_admission_owner_host_02','executor_actor_host_09','executor_managed_lpv_rtl_04','generated_store_monitor_rtl_17','executor_handoff_portal_rtl_17','executor_handoff_portal_rtl_18','executor_checkpoint_rtl_09']
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
        elif mode in rc:assert guard==rc[mode]['guard'] and rc[mode]['runner_exit_code']==0 and all(x in markers for x in rc[mode]['markers'])
        assert guard['child_exit_code']==0 and guard['trigger'] is None
        assert plan['maximum_seconds']==max_sec and plan['maximum_owned_rss_kb']==max_rss and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==201326592
        assert guard['elapsed_seconds']<=max_sec and guard['minimum_mem_available_kb']>=201326592
        assert all(p['matches'] and p['affinity']==[0,1,2,3] and p['nice']==19 and p['ionice']=='idle' for p in policy)
        if guard['rss_captured']:assert guard['peak_owned_rss_kb']<=max_rss and policy
        else:assert (name,mode)==('executor_managed_lpv_rtl_04','oracle') and guard['peak_owned_rss_kb'] is None and not policy and guard['rss_capture_count']==0
        for f in ['guard_plan.json','guard_result.json','launch.json','policy_checks.json','driver.log']:
            if (gd/f).exists():snap(gd/f)
        stages.append(dict(attempt=name,mode=mode,start=launch['at'],finish=guard['finished_at'],guard=guard,plan=plan,policy_count=len(policy),markers=markers))
        warnings[name+'/'+mode]=raw.count('contains leftover data')
    for folder in ['fixture','control_fixture','host_fixture']:
        if (base/folder).exists():
            for p in (base/folder).rglob('*'):
                if p.is_file() and p.stat().st_size<2000000:snap(p)
ordered=sorted(stages,key=lambda x:x['start']);assert all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]))
assert len(stages)==12 and sum(x['policy_count'] for x in stages)==152
assert len(pairs)==355 and len(references)==1128
changes=[{**x,'matches_catalog':catalog.get(x['path'])==x['current']} for x in pairs if not x['current_match']]
assert sum(x['matches_catalog'] for x in changes)==12
additional_live=[x for x in changes if not x['matches_catalog']]
# Live implementation is owned by the running engineer; preserve exact observed
# hashes and never infer a new PASS from ongoing edits. Frozen checks stay strict.
history=[]
for record in engineering['history']:
    oldname,newname=record['before'],record['after']
    old={x['original']['path']:x for x in entries(read(RUNS/oldname/'input_manifest.json'))}
    new={x['original']['path']:x for x in entries(read(RUNS/newname/'input_manifest.json'))}
    changed=[]
    for path in old.keys()&new.keys():
        a,b=old[path]['frozen'],new[path]['frozen']
        assert sha(a['path'])==a['sha256'] and sha(b['path'])==b['sha256']
        if a['sha256']!=b['sha256']:
            changed.append(path);snap(a['path']);snap(b['path'])
            if Path(path).suffix in ['.cpp','.h','.sv','.py','.tcl','.json','.md']:
                q=OUT/'diff'/(oldname+'__'+newname)/(Path(path).name+'.diff')
                q.parent.mkdir(parents=True,exist_ok=True)
                q.write_text(''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True),Path(b['path']).read_text().splitlines(True),fromfile=oldname+'/'+Path(path).name,tofile=newname+'/'+Path(path).name)))
    assert len(old.keys()&new.keys())==record['common']
    assert set(changed)=={x['original'] for x in record['changed']}
    assert {new[x]['frozen']['path'] for x in new.keys()-old.keys()}=={x['path'] for x in record['added']}
    assert {old[x]['frozen']['path'] for x in old.keys()-new.keys()}=={x['path'] for x in record['removed']}
    for x in record['added']+record['removed']:assert sha(x['path'])==x['sha256'];snap(x['path'])
    for n in [oldname,newname]:
        for f in ['input_manifest.json','receipt.json']:snap(RUNS/n/f)
    history.append(dict(before=oldname,after=newname,common=record['common'],changed=sorted(changed),added=sorted(new.keys()-old.keys()),removed=sorted(old.keys()-new.keys())))

def hexraw(path,beats):
    words=Path(path).read_text().split()
    assert len(words)==beats and all(len(w)==128 for w in words)
    return b''.join(bytes.fromhex(w)[::-1] for w in words)

host=RUNS/names[0];rtl=RUNS/names[2]
actual=(host/'fixture/actual_admission_owner.bin').read_bytes()
request=(host/'fixture/v2/checkpoint_request.bin').read_bytes()
# Independent reconstruction from the frozen preexisting request/model bytes;
# no DUT, fixture generator or simulation is executed by this reviewer.
literal=bytearray(1024)
struct.pack_into('<IHHIIQQ',literal,0,0x3144414c,1,16,3,64,29,101)
literal[64:148]=request[64:148]
literal[160:576]=request[160:576]
struct.pack_into('<QQQ',literal,720,7,0x1200000000,16920576)
assert bytes(literal)==actual==(host/'fixture/admission_owner.bin').read_bytes()
assert actual==hexraw(rtl/'fixture/admission.hex',16)
assert actual==(rtl/'frozen/external/admission_host/fixture/actual_admission_owner.bin').read_bytes()
assert hashlib.sha256(actual).hexdigest()=='40df536794b2377bb4955c106ce1a3eef8ded0a4b5c92d57c7f4eac218c56d0f'
hostlog=(host/'guard_run/driver.log').read_text()
assert re.search(r'^FULL_CURRENT_ADMISSION_OWNER_HOST_PASS bytes=1024 wire_rejects=22 capture_rejects=7 actual_LYRQ_LYMP=1 before_HOLD=1 runtime_unchanged=1 ',hostlog,re.M)
assert re.findall(r'^F19_RESULT_BOUNDARY_PASS case=(\d+) ',hostlog,re.M)==list(map(str,range(6)))
assert re.search(r'^FULL_CURRENT_EXECUTOR_REQUEST_CLOSE_PASS .*F19_boundary_cases=6 .*actual_closed_rtl_capture_frames=4 ',hostlog,re.M)
rtllog=(rtl/'guard/driver.log').read_text()
assert re.findall(r'^FULL_CURRENT_MANAGED_LPV_CASE_PASS case=([1-7]) ',rtllog,re.M)==list(map(str,range(1,8)))
assert re.search(r'^FULL_CURRENT_MANAGED_LPV_PASS cases=7 .*cycles=1441$',rtllog,re.M)
assert 'cycles>12000' in (rtl/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_managed_lpv_tb_v1.sv').read_text()
captures=[]
previous=read(ROOT/'results/executor_close_f19_f20_review_20261013/verification.json')
for item in previous['captures']:
    name=item['name'];source=RUNS/'executor_request_close_shell_rtl_04/fixture'/(name+'_capture.hex')
    raw=hexraw(source,16)
    assert hashlib.sha256(raw).hexdigest()==item['raw_sha256']
    assert source.read_bytes()==(host/'frozen/external/closed_results'/(name+'_capture.hex')).read_bytes()
    assert raw==(host/'fixture'/('shell_'+name+'.bin')).read_bytes()
    captures.append(item);snap(source)
assert warnings[names[0]+'/run']==5 and warnings[names[1]+'/run']==45
failures=[]
for n in ['executor_managed_lpv_rtl_01','executor_managed_lpv_rtl_02']:
    b=RUNS/n;assert read(b/'receipt.json')['status']=='FAIL'
    raw=(b/'guard/driver.log').read_text()
    assert not re.search(r'^FULL_CURRENT_MANAGED_LPV_PASS',raw,re.M)
    for f in ['driver.log','guard_result.json']:snap(b/'guard'/f)
    failures.append(dict(attempt=n,status='FAIL',log_sha256=sha(b/'guard/driver.log')))
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json','.research-agent/communication.json','.research-agent/communications/executor-managed-lpv-milestone-20261013.json','results/executor_managed_lpv_owner_contract_20261013.md','results/executor_close_f19_f20_reply_20261013.md','results/executor_minimum_hardware_chain_priority_20261013.md','.research-agent/communications/executor-minimum-hardware-chain-priority-20261013.json']:
    snap(ROOT/f)
summary=dict(pairs=len(pairs),frozen_matches=len(pairs),declared_pairs=len(pairs),current_matches=sum(x['current_match'] for x in pairs),references=len(references),reference_matches=sum(x['match'] for x in references),deliverables=len(delivered),guards=len(stages),policy_records=sum(x['policy_count'] for x in stages),catalog_differences=12,additional_current_pair_differences=len(additional_live),unobserved_child_stages=[dict(attempt=x['attempt'],mode=x['mode'],elapsed=x['guard']['elapsed_seconds']) for x in stages if not x['guard']['rss_captured']])
v=dict(review_id='R-SM003-EXECUTOR-MANAGED-LPV-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,delivered=delivered,pairs=pairs,references=references,current_differences=changes,stages=stages,serial_no_overlap=True,history=history,failed_history=failures,captures=captures,actual_A_sha256=hashlib.sha256(actual).hexdigest(),actual_A_literal_RTL_equal=True,resource_observation_complete=False,warnings=warnings,snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],decision='pending_scoped_review',no_controller_compilation_simulation_hls=True)
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(summary,ensure_ascii=False,indent=2))
