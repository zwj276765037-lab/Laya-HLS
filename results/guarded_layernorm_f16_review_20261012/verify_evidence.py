from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUNS = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
NAMES = ['bootstrap_source_guard_rtl_08', 'layernorm_guarded_source_05',
         'bootstrap_source_conflict_adapter_host_01', 'generated_store_monitor_13',
         'bootstrap_snapshot_rtl_05', 'layernorm_producer_portal_08', 'layernorm_quant_source_04']
EXPECTED = [
 ('59a2a0af383f4a1238452a901e8ea39f9d35ff5d6e53dbbf1a652fdebf1df521','e7a471647fa7c8fd4bdac964f801b63d3f46bab8e4015a48044fb7a62ea52c7f','42f3952429e4d4efcdabdd4b2bbc4269932ea3a2d3fdca29ad5dd5e965ce67bb'),
 ('61ae1ac912d98f156f69c694ee5877485d2b00d6ab0c1321d2872568a2aefccf','0eae6c2b99f4b09178ab8b68398acb29a3060eff8e2c246d9685db01543e0ac3','cae59d4a2ec92ac3b865ee125262323d18e89b4930edfa299c21b7c63e574925'),
 ('0676c25d61c08effb543902a19cf0098d4478889451c7c00b300c1186d5397b7','3dd2b07c7dd26c5764f03e6ad4da61aba4e272d566d2f4947e8981c0ec6f0973','027f080577d900572b9310cef1240b505dc7a1ffa46402f4751306f2493b4549'),
 ('b7387393bb4766eeacc2a6320354d167a8e22f465ab49ea6c1f88206852ddef5','48276c1724ee42d763dd358314b7bf7b237c0fe94fd3819ff3569a5b62076858','10bfb99a0d20cbdcb2fa16141fe584888b15faee54969e5b0a0c721581e2b16b'),
 ('43454bb69e9a15fa864dfa6d479e6eb5737cdb36da12f715d3b1ad1ca3611bbb','3a85e9f755dc9d3f0656400fbd0a52419433160479c6403f0063e5b72289b299','cb4a10a9f138cc20f7b2785ab620fb5f81710d9636bea77e5648828adf7bd88c'),
 ('39b025bace00392f24c3f7d7ebc888f9f24396d55967a885af1dcc54f6242aa0','0da16f46e4649bd18217075485b99eace65a48dd3d46bd8420415af48dc9c0cb','882fdd2e9532098e8a0652b2feecedebb716ed38b3cb6dd0085113edb969d525'),
 ('f2e1f76435af9fc2e4f2f82a08ec94d3cc8193d92deed37fe90fee801779d5ba','4115bbef5e4b974fce48acc33ce7b1996c7d6fa73e5b75c40a79a896be508e7b','1db95956939b7656efb77ee19259e1352f85b261219b938cdafd8039a3ed6c57')]
def sha(p):
    h=hashlib.sha256()
    with Path(p).open('rb') as f:
        for b in iter(lambda:f.read(1048576),b''): h.update(b)
    return h.hexdigest()
def read(p): return json.loads(Path(p).read_text())
snapshots, pairs, refs, stages, handoff, diffs, history = {}, [], [], [], [], [], {}
def snap(p):
    p=Path(p); t=OUT/'snapshot'/p.relative_to(ROOT)
    t.parent.mkdir(parents=True,exist_ok=True)
    if not t.exists(): shutil.copyfile(p,t)
    assert sha(t)==sha(p), str(p)
    snapshots[str(t.relative_to(ROOT))]=sha(t)
def walk(x, origin):
    if isinstance(x,dict):
        if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
            p=Path(x['path']); actual=sha(p) if p.is_file() else None
            refs.append(dict(origin=origin,path=str(p),expected=x['sha256'],actual=actual,match=actual==x['sha256']))
        for v in x.values(): walk(v,origin)
    elif isinstance(x,list):
        for v in x: walk(v,origin)
def pair_entries(m): return m['files']+([m['contract']] if 'contract' in m else m.get('contracts',[]))
def verify_handoff(p,h):
    actual=sha(p);handoff.append(dict(path=str(p.relative_to(ROOT)),expected=h,actual=actual,match=actual==h));snap(p)
for n,hs in zip(NAMES,EXPECTED):
    base=RUNS/n; m=read(base/'input_manifest.json'); r=read(base/'receipt.json')
    for p,h in zip([base/'input_manifest.json',base/'receipt.json',RUNS/(n+'_verification_20261012.json')],hs):verify_handoff(p,h)
    for e in pair_entries(m):
        a,b=e['original'],e['frozen']; c,f=sha(a['path']),sha(b['path'])
        pairs.append(dict(attempt=n,path=a['path'],frozen_path=b['path'],declared=a['sha256'],current=c,frozen_actual=f,current_match=c==a['sha256'],frozen_match=f==b['sha256'],declared_pair_match=a['sha256']==b['sha256']))
        if '/external/' not in b['path'] and Path(b['path']).suffix in ('.sv','.py','.cpp','.h','.tcl','.json','.md'):snap(b['path'])
        if c!=a['sha256']: snap(a['path'])
    for origin,x in [('manifest',m),('receipt',r)]:walk(x,n+'/'+origin)
    launcher=read(base/'launcher.json');snap(base/'launcher.json')
    assert launcher['pass'] and launcher['cpu_affinity']==[0,1,2,3] and launcher['nice']==19 and launcher['ionice']=='idle' and launcher['mem_available_kib']>=201326592
    stage_receipts=[('guard',r)] if 'guard_result' in r else [(k,v) for k,v in r.items() if isinstance(v,dict) and 'guard' in v]
    for label,s in stage_receipts:
        gd=base/('guard' if label=='guard' else 'guard_'+label)
        g=read(gd/'guard_result.json'); plan=read(gd/'guard_plan.json'); launch=read(gd/'launch.json')
        policy=read(gd/'policy_checks.json') if (gd/'policy_checks.json').exists() else []
        log=(gd/'driver.log').read_text(); markers=[x for x in log.splitlines() if x.startswith('FULL_') and '_PASS' in x and not x.endswith('_SCRIPT_PASS')]
        for f in ['guard_result.json','guard_plan.json','launch.json','driver.log','policy_checks.json']:
            if (gd/f).exists():snap(gd/f)
        assert g==s.get('guard',s.get('guard_result')) and g['child_exit_code']==0 and g['trigger'] is None
        assert s.get('runner_exit_code',0)==0 and markers==s['marker']
        assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy)
        assert g['elapsed_seconds']<=plan['maximum_seconds'] and plan['selected_cpu_ids']==[0,1,2,3] and plan['semantic_stall_seconds']==120
        assert plan['minimum_mem_available_kb']==201326592
        sampled=g['peak_owned_rss_kb'] is not None
        if sampled: assert g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and g['minimum_mem_available_kb']>=plan['minimum_mem_available_kb']
        else: assert n=='bootstrap_source_conflict_adapter_host_01' and label=='run' and not policy and not g['rss_captured']
        stages.append(dict(attempt=n,stage=label,start=launch['at'],finish=g['finished_at'],guard=g,plan=plan,policy_count=len(policy),policy_ok=True,sampled=sampled,markers=markers))
for name,h in [('guarded_layernorm_f16_verification_20261012.json','9241d9a72259d59507651bf4697b62a1c6fd2b1688b99aa3e8afdaebea146c65'),('guarded_layernorm_f16_catalog_delta_20261012.json','052bd3d0823982ba8a5f6be6e7d59c4dc2b199600996abe30b52d0efd4cf8ed6')]:verify_handoff(RUNS/name,h)
ordered=sorted(stages,key=lambda x:x['start'])
serial=all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]))
assert serial and len(stages)==17 and sum(s['policy_count'] for s in stages)==179

for old,new in [('bootstrap_source_guard_rtl_07','bootstrap_source_guard_rtl_08')]+[(f'layernorm_guarded_source_{i:02}',f'layernorm_guarded_source_{i+1:02}') for i in range(1,5)]:
    aa={e['original']['path']:e for e in pair_entries(read(RUNS/old/'input_manifest.json'))};bb={e['original']['path']:e for e in pair_entries(read(RUNS/new/'input_manifest.json'))};changes=[]
    for f in sorted(aa.keys()&bb.keys()):
        x,y=aa[f]['frozen'],bb[f]['frozen']
        if x['sha256']!=y['sha256']:
            changes.append(f); t=OUT/'diff'/(old+'__'+new)/(Path(f).name+'.diff');t.parent.mkdir(parents=True,exist_ok=True)
            t.write_text(''.join(difflib.unified_diff(Path(x['path']).read_text().splitlines(True),Path(y['path']).read_text().splitlines(True),fromfile=old+'/'+Path(f).name,tofile=new+'/'+Path(f).name)))
    diffs.append(dict(old=old,new=new,common_pairs=len(aa.keys()&bb.keys()),changes=changes))
for n in ['bootstrap_source_guard_rtl_05','bootstrap_source_guard_rtl_06']+[f'layernorm_guarded_source_{i:02}' for i in range(1,5)]:
    base=RUNS/n;r=read(base/'receipt.json'); logs=[]
    for gd in sorted(base.glob('guard*')):
        if not gd.is_dir():continue
        log=(gd/'driver.log').read_text()
        logs.append(dict(stage=gd.name,guard=read(gd/'guard_result.json'),fatals=[x for x in log.splitlines() if 'Fatal:' in x],markers=[x for x in log.splitlines() if x.startswith('FULL_')]))
        for f in ['driver.log','guard_result.json']:snap(gd/f)
    history[n]=dict(status=r.get('status'),stages=logs)
    for f in ['input_manifest.json','receipt.json']:snap(base/f)

lnm=read(RUNS/'layernorm_guarded_source_05/input_manifest.json');lnr=read(RUNS/'layernorm_guarded_source_05/receipt.json')
dat=[dict(source=x['source'],staged=x['staged'],match=sha(x['source']['path'])==sha(x['staged']['path'])==x['source']['sha256']==x['staged']['sha256']) for x in lnr['runtime_dat_staging']]
assert len(dat)==7 and all(x['match'] for x in dat)
captures={Path(x['path']).name:x for x in lnr['actual_protocol_captures']}
host=read(RUNS/'bootstrap_source_conflict_adapter_host_01/input_manifest.json');host_captures=[]
for e in pair_entries(host):
    if Path(e['original']['path']).name in captures:
        x=captures[Path(e['original']['path']).name]
        host_captures.append(dict(name=Path(x['path']).name,match=sha(e['frozen']['path'])==sha(x['path'])==x['sha256']))
assert len(captures)==36 and len(host_captures)==8 and all(x['match'] for x in host_captures)
generated=[e for e in pair_entries(lnm) if '/external/layernorm_producer_rtl/' in e['frozen']['path']]
assert sum(Path(e['frozen']['path']).suffix=='.v' for e in generated)==71
assert sum(Path(e['frozen']['path']).suffix=='.dat' for e in generated)==7
assert all('layernorm_producer_hls_01' in e['original']['path'] for e in generated)
delta=read(RUNS/'guarded_layernorm_f16_catalog_delta_20261012.json')
known={(e['attempt'],e['original']['path']):e for e in delta['live_differences']}
current_differences=[]
for x in pairs:
    if not x['current_match']:
        k=known.get((x['attempt'],x['path']))
        current_differences.append({**x,'matches_handoff_catalog_delta':bool(k and k['current']['sha256']==x['current'])})
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/state.json','agent/A001/result.md','agent/A002/state.json','.research-agent/discussions.json']:snap(ROOT/f)
v=dict(review_id='R-SM003-GUARDED-LAYERNORM-F16-20261012',checked_at=datetime.now(timezone.utc).isoformat(),pairs=pairs,references=refs,stages=stages,selected_stages_serial=serial,handoff_hashes=handoff,diffs=diffs,history=history,dat_staging=dat,actual_host_capture_pairs=host_captures,actual_capture_files=len(captures),generated_rtl=dict(verilog=71,dat=7,original_hls='layernorm_producer_hls_01'),numeric_inputs=lnm['numeric_inputs'],full_workloads=dict(guarded_ln=lnm['full'],quant=read(RUNS/'layernorm_quant_source_04/receipt.json')['full']),current_differences=current_differences,snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],summary=dict(pairs=len(pairs),**{k:sum(x[k] for x in pairs) for k in ['current_match','frozen_match','declared_pair_match']},references=len(refs),reference_matches=sum(x['match'] for x in refs),handoff_matches=sum(x['match'] for x in handoff),stages=len(stages),policy_count=sum(x['policy_count'] for x in stages)),decision='pending_source_review',no_controller_compilation_simulation_hls=True)
assert all(x['frozen_match'] and x['declared_pair_match'] for x in pairs) and all(x['match'] for x in handoff)
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=v['summary'],serial=serial,current_differences=[dict(attempt=x['attempt'],path=x['path'],catalog_only=x['matches_handoff_catalog_delta']) for x in current_differences],diffs=diffs,history={n:{'status':h['status'],'fatal':[x for s in h['stages'] for x in s['fatals']]} for n,h in history.items()}),ensure_ascii=False,indent=2))
