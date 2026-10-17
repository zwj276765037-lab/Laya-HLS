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

aggregate_path=RUNS/'executor_handoff_shell_deliverables_20261013.json'
assert sha(aggregate_path)=='9ebfed5355d4796b4055564ffbed5c28813429ca143c3eb45cfe0c92e1c6f688'
delivered=read(aggregate_path)['files']; assert len(delivered)==13
snap(aggregate_path)
for e in delivered:
    assert sha(e['path'])==e['sha256']; snap(e['path'])
pairs=[]; references=[]; stages=[]; manifests={}
names=['executor_handoff_portal_rtl_01','executor_handoff_shell_helper_host_02','executor_handoff_shell_rtl_02','executor_handoff_portal_rtl_02','executor_checkpoint_rtl_07']
for name in names:
    base=RUNS/name; m=read(base/'input_manifest.json'); rc=read(base/'receipt.json'); manifests[name]=m
    assert rc['status']=='PASS'
    for e in entries(m):
        a,b=e['original'],e['frozen']; actual=sha(b['path']); cur=sha(a['path'])
        assert actual==b['sha256']==a['sha256']
        pairs.append(dict(attempt=name,path=a['path'],frozen_path=b['path'],expected=a['sha256'],current=cur,current_match=cur==a['sha256'],frozen_match=True,pair_match=True))
        snap(b['path'])
        if cur!=a['sha256']: snap(a['path'])
    references.extend(refs(m,name+'/manifest')); references.extend(refs(rc,name+'/receipt'))
    launch=read(base/'launcher.json'); snap(base/'launcher.json')
    assert launch['pass'] and launch['cpu_affinity']==[0,1,2,3] and launch['nice']==19 and launch['ionice']=='idle'
    assert launch['mem_available_kib']>=201326592
    modes=['oracle','build','run'] if 'helper_host' in name else (['oracle','rtl'] if 'shell_rtl' in name else [''])
    for mode in modes:
        gd=base/('guard_'+mode if mode else 'guard'); guard=read(gd/'guard_result.json'); plan=read(gd/'guard_plan.json'); started=read(gd/'launch.json')
        policy=read(gd/'policy_checks.json') if (gd/'policy_checks.json').exists() else []
        raw=(gd/'driver.log').read_text(); markers=[l for l in raw.splitlines() if l.startswith('FULL_') and '_PASS' in l]
        assert guard== (rc[mode]['guard'] if mode else rc['guard_result'])
        expected_markers=rc[mode]['markers'] if mode else rc['marker']
        assert all(x in markers for x in expected_markers)
        if mode: assert rc[mode]['runner_exit_code']==0
        assert guard['child_exit_code']==0 and guard['trigger'] is None
        max_sec,max_rss=(1800,25165824) if 'helper_host' in name else (120,8388608)
        assert plan['maximum_seconds']==max_sec and plan['maximum_owned_rss_kb']==max_rss
        assert plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==201326592
        assert guard['elapsed_seconds']<=max_sec and guard['minimum_mem_available_kb']>=201326592
        assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy)
        if guard['rss_captured']: assert guard['peak_owned_rss_kb']<=max_rss and policy
        else: assert (name,mode) in [('executor_handoff_shell_helper_host_02','run'),('executor_handoff_shell_rtl_02','oracle')] and guard['peak_owned_rss_kb'] is None and not policy
        for f in ['guard_plan.json','guard_result.json','launch.json','policy_checks.json','driver.log']:
            if (gd/f).exists(): snap(gd/f)
        stages.append(dict(attempt=name,mode=mode,start=started['at'],finish=guard['finished_at'],guard=guard,plan=plan,policy_count=len(policy),markers=markers))
    for folder in ['fixture','control_fixture']:
        if (base/folder).exists():
            for p in (base/folder).rglob('*'):
                if p.is_file() and p.stat().st_size<2000000: snap(p)
ordered=sorted(stages,key=lambda x:x['start'])
assert all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]))
assert len(stages)==8 and sum(s['policy_count'] for s in stages)==110
assert len(pairs)==211 and len(references)==718
# Classify contemporaneous live changes without treating them as frozen corruption.
delta=read(RUNS/'executor_handoff_shell_catalog_delta_20261013.json')
after={x['after']['path']:x['after']['sha256'] for x in delta['changes']}
diffs=[]
for p in pairs:
    if not p['current_match']:
        kind='catalog_registration' if after.get(p['path'])==p['current'] else ('proof_only_followup_implementation' if p['attempt']=='executor_handoff_portal_rtl_01' and Path(p['path']).name in ['laya_generated_provenance_axi_portal_v1.sv','laya_executor_handoff_portal_tb_v1.sv','run_executor_handoff_portal_rtl.py'] else 'additional_live_change')
        diffs.append({**p,'classification':kind})
# Compare historical frozen attempts; do not execute their code.
history=[]
for oldname,newname in [('executor_handoff_shell_helper_host_01','executor_handoff_shell_helper_host_02'),('executor_handoff_shell_rtl_01','executor_handoff_shell_rtl_02'),('executor_handoff_portal_rtl_01','executor_handoff_portal_rtl_02'),('executor_checkpoint_rtl_06','executor_checkpoint_rtl_07')]:
    oldm=read(RUNS/oldname/'input_manifest.json'); newm=manifests[newname]
    old={x['original']['path']:x for x in entries(oldm)}; new={x['original']['path']:x for x in entries(newm)}; changes=[]
    for p in old.keys()&new.keys():
        a,b=old[p]['frozen'],new[p]['frozen']; assert sha(a['path'])==a['sha256'] and sha(b['path'])==b['sha256']
        if a['sha256']!=b['sha256']:
            changes.append(p); snap(a['path'])
            if Path(p).suffix in ['.cpp','.h','.py','.sv','.md','.json']:
                dest=OUT/'diff'/oldname/(Path(p).name+'.diff'); dest.parent.mkdir(parents=True,exist_ok=True)
                dest.write_text(''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True),Path(b['path']).read_text().splitlines(True),fromfile=oldname+'/'+Path(p).name,tofile=newname+'/'+Path(p).name)))
    for f in ['input_manifest.json','receipt.json']: snap(RUNS/oldname/f)
    history.append(dict(old=oldname,new=newname,common=len(old.keys()&new.keys()),changes=sorted(changes),added=sorted(new.keys()-old.keys()),removed=sorted(old.keys()-new.keys()),old_status=read(RUNS/oldname/'receipt.json')['status']))
def unhex(p):
    rows=Path(p).read_text().split(); assert len(rows)==16 and all(len(x)==128 for x in rows)
    return b''.join(bytes.fromhex(x)[::-1] for x in rows)
cap1=RUNS/names[0]/'fixture/actual_handoff_checkpoint.hex'; cap2=RUNS/names[3]/'fixture/actual_handoff_checkpoint.hex'
assert sha(cap1)==sha(cap2)=='c2442fd8a8c35c39777229f95075c47958fde0c77c41dd8e52affa5b82a9ccc6'
raw=unhex(cap1); assert hashlib.sha256(raw).hexdigest()=='05fd66a4d50e3bcca0d086a3cb2503202f595ed10a6d1e287cc817a34e1a64a6'
helper=RUNS/names[1]/'fixture'; shell=RUNS/names[2]/'fixture'; portal=RUNS/names[3]/'control_fixture'
assert raw==(helper/'helper_proof_stimulus.bin').read_bytes()==unhex(shell/'proof.hex')==unhex(portal/'proof.hex')
# This batch literal already has S/H1; verify equality before the TB idempotent assignments.
gold=bytearray((RUNS/names[3]/'fixture/checkpoint_good.bin').read_bytes())
original_sh=[struct.unpack_from('<Q',gold,n)[0] for n in [16,680]]
assert original_sh == [1,1] and bytes(gold) == raw
for n in [16,680]: struct.pack_into('<Q',gold,n,1)
assert bytes(gold)==raw
control_chain=[]
for rawname,hexname in [('actual_helper_hold.bin','hold.hex'),('actual_helper_query.bin','query.hex'),('actual_helper_import_ok.bin','import_ok.hex'),('actual_helper_abort.bin','abort.hex')]:
    b=(helper/rawname).read_bytes(); assert b==unhex(shell/hexname)
    if (portal/hexname).exists(): assert b==unhex(portal/hexname)
    control_chain.append(dict(name=rawname,sha256=hashlib.sha256(b).hexdigest(),bytes=len(b),shell_match=True,portal_match=(portal/hexname).exists()))
# Independent literal control frame check, no C++/SV execution.
expected=bytearray((helper/'control_3.bin').read_bytes()); struct.pack_into('<Q',expected,680,1)
assert bytes(expected)==(helper/'actual_helper_import_ok.bin').read_bytes()
for kind,hfile in [(2,'held_gold.hex'),(4,'grant_gold.hex'),(6,'abort_closed_gold.hex')]:
    literal=bytearray((helper/f'control_{kind}.bin').read_bytes()); struct.pack_into('<Q',literal,680,1)
    assert bytes(literal)==unhex(shell/hfile)
    if (portal/hfile).exists(): assert bytes(literal)==unhex(portal/hfile)
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json','.research-agent/communications/executor-handoff-shell-milestone-20261013.json','results/executor_checkpoint_import_handshake_contract_20261013.md']:
    snap(ROOT/f)
summary=dict(pairs=len(pairs),frozen_matches=len(pairs),declared_pairs=len(pairs),current_matches=sum(p['current_match'] for p in pairs),references=len(references),reference_matches=sum(p['match'] for p in references),deliverables=len(delivered),guards=len(stages),policy_records=sum(s['policy_count'] for s in stages))
v=dict(review_id='R-SM003-EXECUTOR-HANDOFF-SHELL-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,delivered=delivered,pairs=pairs,references=references,current_differences=diffs,stages=stages,serial_no_overlap=True,history=history,byte_chain=dict(capture_hex_sha256=sha(cap1),raw_sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw),original_literal_sh=original_sh,only_literal_sh_replaced=[1,1],actual_helper_to_shell_and_portal=control_chain,literal_control_gold=True),snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],no_controller_compilation_simulation_hls=True,decision='pending_final_record')
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=summary,differences=[dict(attempt=p['attempt'],name=Path(p['path']).name,classification=p['classification']) for p in diffs],history=history),ensure_ascii=False,indent=2))
