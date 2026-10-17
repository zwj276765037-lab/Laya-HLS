from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, shutil, difflib, re

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
NAMES=['executor_checkpoint_host_04','executor_bootstrap_host_04','task_lifecycle_fsm_host_04','graph_lifecycle_split_host_05']
HASHES=[('decf0fd4555c85eb1a264ed49987bf5a3c44b761d0fc8f3fc0cac0e327e75830','b717c77dee32c4f949a9848d770751375df730a8706ceeb3b694f212d0da255a'),('2a325fdb895aff9c86333ec3999b2188adde0098e4a818efbc36568761a4dac6','58892d5ef571cf6fff5ca8f262b3b1668695fa2b8714c51a7d1a2fb8cedfe599'),('5ed211a19c3a61dbaeb71ed3a5a309a70ecf8aad4a116a0c2752aa3e5a0a055c','54c50a2dfff066ba099ba052d21135f2127ce3dfd259981283c82032d7fbe150'),('d2167adc6d85bbd5df1731270ce42ce8a917e5fc52353aff926310b5330b5ee6','c2ca353ca975b73cdced3ecc6abf99da0629d20fc8151b51b8ecdbe125bd3ae5')]
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p): return json.loads(Path(p).read_text())
def entries(x):
    if isinstance(x,dict):
        if 'original' in x and 'frozen' in x: yield x
        else:
            for v in x.values():yield from entries(v)
    elif isinstance(x,list):
        for v in x:yield from entries(v)
snapshots={};pairs=[];refs=[];hashes=[];stages=[];commands=[];diffs=[];history={}
def snap(p):
    p=Path(p);t=OUT/'snapshot'/p.relative_to(ROOT);t.parent.mkdir(parents=True,exist_ok=True)
    if not t.exists():shutil.copyfile(p,t)
    assert sha(t)==sha(p),str(p)
    snapshots[str(t.relative_to(ROOT))]=sha(t)
def walk(x,origin):
    if isinstance(x,dict):
        if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
            p=Path(x['path']);actual=sha(p) if p.is_file() else None
            refs.append(dict(origin=origin,path=str(p),expected=x['sha256'],actual=actual,match=actual==x['sha256']))
        for v in x.values():walk(v,origin)
    elif isinstance(x,list):
        for v in x:walk(v,origin)
def handoff(p,h):
    hashes.append(dict(path=str(p.relative_to(ROOT)),expected=h,actual=sha(p),match=sha(p)==h));snap(p)
for n,hs in zip(NAMES,HASHES):
    a=RUNS/n;m=read(a/'input_manifest.json');r=read(a/'receipt.json')
    for file,h in zip(['input_manifest.json','receipt.json'],hs):handoff(a/file,h)
    assert r['status']=='PASS'
    for e in entries(m):
        x,y=e['original'],e['frozen'];c,f=sha(x['path']),sha(y['path'])
        pairs.append(dict(attempt=n,path=x['path'],frozen_path=y['path'],declared=x['sha256'],current=c,frozen=f,current_match=c==x['sha256'],frozen_match=f==y['sha256'],pair_match=x['sha256']==y['sha256']))
        if Path(y['path']).suffix in ['.cpp','.h','.sv','.py','.cmake','.json','.md']:snap(y['path'])
        if c!=x['sha256']:snap(x['path'])
    walk(m,n+'/manifest');walk(r,n+'/receipt')
    launcher=read(a/'launcher.json');snap(a/'launcher.json')
    assert launcher['pass'] and launcher['cpu_affinity']==[0,1,2,3] and launcher['nice']==19 and launcher['ionice']=='idle' and launcher['mem_available_kib']>=201326592
    if n==NAMES[0]:
        for k in ['oracle','build','run']:
            s=r[k];log=Path(s['driver_log']['path']).read_text();markers=[l for l in log.splitlines() if l.startswith('FULL_CURRENT_') and '_PASS' in l]
            if k=='oracle':markers=[l for l in markers if l.startswith('FULL_CURRENT_EXECUTOR_CHECKPOINT_FIXTURE_PASS')]
            assert s['runner_exit_code']==0 and s['status']=='PASS' and markers==s['markers']
            commands.append(dict(attempt=n,stage=k,markers=markers,guard=s['guard']))
    else:
        raw=[]
        for s in r['commands']:
            assert s['exit_code']==0 and not s['timeout'];p=Path(s['log']['path']);snap(p)
            raw += [l for l in p.read_text().splitlines() if l.startswith('FULL_CURRENT_') and '_PASS' in l]
            commands.append(dict(attempt=n,command=s['command'],elapsed_seconds=s['elapsed_seconds'],exit_code=0,log=s['log']))
        assert all(raw.count(marker)==1 for marker in r['markers'])
handoff(RUNS/'executor_checkpoint_verification_20261013.json','2043f78b95c5bdbf71505fe90b86655b970f9d19fe71dad9ecac4538e2ae6e8e')
handoff(RUNS/'executor_checkpoint_catalog_delta_20261013.json','e367d2e3b10a3610d195e0f94bc40e2a085d2f35dfa9648912278c5ae05c2ac2')
aggregate=read(RUNS/'executor_checkpoint_verification_20261013.json')
guard_dirs=[(NAMES[0],RUNS/NAMES[0]/('guard_'+k)) for k in ['oracle','build','run']]+list(zip(NAMES[1:],[RUNS/('checkpoint_final_compat_'+k+'_guard') for k in ['v1','fsm','sync']]))
for n,gd in guard_dirs:
    plan=read(gd/'guard_plan.json');result=read(gd/'guard_result.json');launch=read(gd/'launch.json');policy=read(gd/'policy_checks.json')
    for f in ['guard_plan.json','guard_result.json','launch.json','policy_checks.json','driver.log']:snap(gd/f)
    expected=next(g for a in aggregate['attempts'] if a['attempt']==n for g in a['guards'] if g['directory']==str(gd))
    assert result==expected['result'] and plan==expected['plan']
    assert all(sha(a['path'])==a['sha256'] for a in expected['artifacts'].values())
    assert result['child_exit_code']==0 and result['trigger'] is None and result['rss_captured']
    assert result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb']==25165824 and result['elapsed_seconds']<=plan['maximum_seconds']==1800
    assert result['minimum_mem_available_kb']>=plan['minimum_mem_available_kb']==201326592 and plan['semantic_stall_seconds']==120
    assert policy and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy)
    assert len(policy)==expected['policy_count']
    assert str(RUNS/n) in ' '.join(plan['command'])
    stages.append(dict(attempt=n,directory=str(gd),start=launch['at'],finish=result['finished_at'],result=result,plan=plan,policy_count=len(policy),sampled=True,guard_artifacts=expected['artifacts']))
ordered=sorted(stages,key=lambda s:s['start']);serial=all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]));assert serial
assert len(stages)==6 and sum(x['policy_count'] for x in stages)==109
delta=read(RUNS/'executor_checkpoint_catalog_delta_20261013.json');known={(x['attempt'],x['original']['path']):x['current']['sha256'] for x in delta['live_differences']}
current_differences=[{**x,'matches_catalog_delta':known.get((x['attempt'],x['path']))==x['current']} for x in pairs if not x['current_match']]
for i in range(1,4):
    old=f'executor_checkpoint_host_{i:02}';new=f'executor_checkpoint_host_{i+1:02}'
    aa={e['original']['path']:e for e in entries(read(RUNS/old/'input_manifest.json'))};bb={e['original']['path']:e for e in entries(read(RUNS/new/'input_manifest.json'))};changed=[]
    for f in sorted(aa.keys()&bb.keys()):
        x,y=aa[f]['frozen'],bb[f]['frozen']
        if x['sha256']!=y['sha256']:
            changed.append(f);p=OUT/'diff'/(old+'__'+new)/(Path(f).name+'.diff');p.parent.mkdir(parents=True,exist_ok=True)
            p.write_text(''.join(difflib.unified_diff(Path(x['path']).read_text().splitlines(True),Path(y['path']).read_text().splitlines(True),fromfile=old+'/'+Path(f).name,tofile=new+'/'+Path(f).name)))
    diffs.append(dict(old=old,new=new,common_pairs=len(aa.keys()&bb.keys()),changed=changed))
    r=read(RUNS/old/'receipt.json');history[old]=dict(status=r['status'],stages=[])
    for k in ['oracle','build','run']:
        s=r.get(k)
        if not s:continue
        log=Path(s['driver_log']['path']);snap(log)
        history[old]['stages'].append(dict(stage=k,guard=s['guard'],markers=s['markers'],assertions=[l for l in log.read_text().splitlines() if 'Assertion' in l]))
    for f in ['input_manifest.json','receipt.json']:snap(RUNS/old/f)
frozen=RUNS/NAMES[0]/'frozen'
layout=frozen/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_checkpoint_layout_v2.sv'
sv=layout.read_text();values=aggregate['sv_literal_layout_parity']['expected_values'];layout_checks={k:bool(re.search(r'\b'+re.escape(k)+r'\s*=\s*'+str(v)+r'\b',sv)) for k,v in values.items()}
assert all(layout_checks.values())
fixture=RUNS/NAMES[0]/'fixture';req=(fixture/'checkpoint_request.bin').read_bytes();rsp=(fixture/'checkpoint_response.bin').read_bytes();assert len(req)==len(rsp)==1024
for name,data in [('checkpoint_request',req),('checkpoint_response',rsp)]:assert (fixture/(name+'.hex')).read_text()==''.join(data[i:i+64][::-1].hex()+'\n' for i in range(0,1024,64))
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/state.json','agent/A001/result.md','agent/A002/state.json','.research-agent/discussions.json']:snap(ROOT/f)
summary=dict(pairs=len(pairs),current_matches=sum(x['current_match'] for x in pairs),frozen_matches=sum(x['frozen_match'] for x in pairs),pair_matches=sum(x['pair_match'] for x in pairs),references=len(refs),reference_matches=sum(x['match'] for x in refs),handoff_matches=sum(x['match'] for x in hashes),guards=len(stages),policy_count=sum(x['policy_count'] for x in stages))
assert len(pairs)==256 and len(refs)==574 and all(x['frozen_match'] and x['pair_match'] for x in pairs) and all(x['match'] for x in hashes)
v=dict(review_id='R-SM003-EXECUTOR-CHECKPOINT-HOST-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,pairs=pairs,references=refs,handoff_hashes=hashes,stages=stages,serial_no_overlap=serial,commands=commands,current_differences=current_differences,history=history,diffs=diffs,sv_literal_only_checks=layout_checks,fixture_byte_hex_consistency=True,snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],decision='pending_source_review',no_controller_compilation_simulation_hls=True)
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=summary,current_differences=[dict(attempt=x['attempt'],path=x['path'],catalog=x['matches_catalog_delta']) for x in current_differences],diffs=diffs,history={n:dict(status=h['status'],assertions=[x for s in h['stages'] for x in s['assertions']]) for n,h in history.items()}),ensure_ascii=False,indent=2))
