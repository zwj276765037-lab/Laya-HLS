from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUNS = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
BASE = RUNS / 'bootstrap_source_guard_rtl_07'
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p): return json.loads(Path(p).read_text())
snapshots, pairs, refs, diffs, history = [], [], [], [], {}
def snap(p):
    p=Path(p);t=OUT/'snapshot'/p.relative_to(ROOT);t.parent.mkdir(parents=True,exist_ok=True)
    if not t.exists(): shutil.copyfile(p,t)
    assert sha(t)==sha(p),str(p)
    snapshots.append({'path':str(t.relative_to(ROOT)),'sha256':sha(t)})
def walk(x, origin):
    if isinstance(x,dict):
        if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
            p=Path(x['path']);actual=sha(p) if p.is_file() else None
            refs.append({'origin':origin,'path':str(p),'expected':x['sha256'],'actual':actual,'match':actual==x['sha256']})
        for v in x.values():walk(v,origin)
    elif isinstance(x,list):
        for v in x:walk(v,origin)

m=read(BASE/'input_manifest.json');r=read(BASE/'receipt.json')
for e in m['files']+[m['contract']]:
    a,b=e['original'],e['frozen'];c=sha(a['path']);f=sha(b['path'])
    pairs.append({'path':a['path'],'declared':a['sha256'],'current':c,'frozen_actual':f,'current_match':c==a['sha256'],'frozen_match':f==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']})
    if Path(b['path']).suffix in ['.sv','.py','.json','.tcl','.md']:snap(b['path'])
    if c!=a['sha256']:snap(a['path'])
for origin,x in [('manifest',m),('receipt',r)]:walk(x,origin)
for f in ['input_manifest.json','receipt.json','launcher.json','guard/guard_plan.json','guard/guard_result.json','guard/policy_checks.json','guard/launch.json','guard/driver.log']:snap(BASE/f)
gd=BASE/'guard';plan=read(gd/'guard_plan.json');result=read(gd/'guard_result.json');policy=read(gd/'policy_checks.json');log=(gd/'driver.log').read_text()
runtime_markers=[x for x in log.splitlines() if x.startswith('FULL_CURRENT_BOOTSTRAP_SOURCE_GUARD_RTL_PASS ')]
assert len(runtime_markers)==1 and runtime_markers==r['marker']
guard={'result':result,'plan':plan,'launcher':read(BASE/'launcher.json'),'policy_count':len(policy),'policy_ok':all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy),'budget_ok':result['elapsed_seconds']<=plan['maximum_seconds'] and result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and result['minimum_mem_available_kb']>=plan['minimum_mem_available_kb'],'receipt_guard_equal':r['guard_result']==result,'markers':runtime_markers,'no_raw_fatal':not any(x.startswith(('Fatal:','ERROR:')) for x in log.splitlines())}
for old,new in [('bootstrap_source_guard_rtl_04','bootstrap_source_guard_rtl_06'),('bootstrap_source_guard_rtl_05','bootstrap_source_guard_rtl_06'),('bootstrap_source_guard_rtl_06','bootstrap_source_guard_rtl_07')]:
    a=read(RUNS/old/'input_manifest.json');b=read(RUNS/new/'input_manifest.json')
    aa={x['original']['path']:x for x in a['files']+[a['contract']]};bb={x['original']['path']:x for x in b['files']+[b['contract']]};changes=[]
    for f in sorted(aa.keys()&bb.keys()):
        x,y=aa[f]['frozen'],bb[f]['frozen']
        if x['sha256']!=y['sha256']:
            changes.append(f);t=OUT/'diff'/(old+'__'+new)/(Path(f).name+'.diff');t.parent.mkdir(parents=True,exist_ok=True)
            t.write_text(''.join(difflib.unified_diff(Path(x['path']).read_text().splitlines(True),Path(y['path']).read_text().splitlines(True),fromfile=old+'/'+Path(f).name,tofile=new+'/'+Path(f).name)))
    diffs.append({'old':old,'new':new,'common_pairs':len(aa.keys()&bb.keys()),'changes':changes})
for n in ['bootstrap_source_guard_rtl_05','bootstrap_source_guard_rtl_06']:
    base=RUNS/n;rr=read(base/'receipt.json');raw=(base/'guard/driver.log').read_text()
    history[n]={'status':rr['status'],'guard':rr['guard_result'],'fatal_lines':[x for x in raw.splitlines() if x.startswith('Fatal:')],'pass_markers':[x for x in raw.splitlines() if x.startswith('FULL_CURRENT_BOOTSTRAP_SOURCE_GUARD_RTL_PASS ')]}
    for f in ['input_manifest.json','receipt.json','guard/driver.log']:snap(base/f)
expected={BASE/'input_manifest.json':'71e726d74118f6a6df4d54790832731e6eb01ad7b77a9631d33e0d6048585c0f',BASE/'receipt.json':'d5235b62f479fb57d7531af640ea809b0e699cb53b797ec63ef754960955c2dd',RUNS/'bootstrap_source_guard_rtl_07_verification_20261012.json':'ef4647865cf3272e8016342739de8ee81033144499ce322fda3dd2b512266b62',RUNS/'bootstrap_source_guard_f15_verification_20261012.json':'d86d90fe2b44e82ab21f076c2495d3352743a1513bbd40cbaaea8e76f2562e1a'}
hashes=[{'path':str(p.relative_to(ROOT)),'expected':h,'actual':sha(p),'match':sha(p)==h} for p,h in expected.items()]
for p in expected:
    if p.parent==RUNS:snap(p)
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/state.json','agent/A001/result.md','agent/A002/state.json','.research-agent/discussions.json']:snap(ROOT/f)
v={'review_id':'R-SM003-BOOTSTRAP-SOURCE-GUARD-F15-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'pairs':pairs,'references':refs,'snapshots':snapshots,'guard':guard,'history':history,'diffs':diffs,'handoff_hashes':hashes,'summary':{'pairs':len(pairs),**{k:sum(x[k] for x in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'decision':'pending_source_review','no_controller_compilation_simulation_hls':True}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':v['summary'],'hashes':sum(x['match'] for x in hashes),'hash_total':len(hashes),'guard':guard,'diffs':diffs,'current_differences':[x for x in pairs if not x['current_match']],'history':history},ensure_ascii=False,indent=2))
