"""Controller read-only ATN0 evidence audit; writes only this audit directory."""
from pathlib import Path
import json, hashlib, difflib, re
from datetime import datetime

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
OLD = '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline'
LOCAL = str(ROOT / 'project/E002_Laya_HLS/experiment')
refs = {}

def read(p):
    return json.loads(Path(p).read_text())

def rec(p):
    p = Path(p)
    data = p.read_bytes()
    return dict(path=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def check(ref, mapped=False):
    p = str(ref['path'])
    if p.startswith(OLD):
        assert mapped, p
        p = LOCAL + p[len(OLD):]
    r = rec(p)
    assert r['bytes'] == ref['bytes'] and r['sha256'] == ref['sha256'], p
    refs[p] = r
    return Path(p)

def walk(obj):
    if isinstance(obj, dict):
        if all(k in obj for k in ('path','bytes','sha256')):
            check(obj)
        else:
            for v in obj.values(): walk(v)
    elif isinstance(obj,list):
        for v in obj: walk(v)

manifests = {}
counts = {}
guards = []
policy_count = 0
for number in (19,20):
    attempt = next(BASE.glob(f'AT{number:03d}_ATN0_*'))
    receipt = read(attempt/'receipt.json'); refs[str(attempt/'receipt.json')] = rec(attempt/'receipt.json')
    walk(receipt)
    manifest = read(check(receipt['source_manifest']))
    historical = read(check(manifest['historical_v10_manifest']))
    assert len(manifest['sources']) == len(historical['sources']) == 93
    history = {s['frozen']['path']:s['frozen'] for s in historical['sources']}
    differences=[]
    for item in manifest['sources']:
        source=check(item['source']); frozen=check(item['frozen'])
        assert item['historical_frozen'] == history[item['historical_frozen']['path']]
        assert (item['source']['bytes'],item['source']['sha256']) == (item['historical_frozen']['bytes'],item['historical_frozen']['sha256'])
        if item['source']['sha256'] != item['frozen']['sha256']:
            differences.append(frozen.name)
            diff='\n'.join(difflib.unified_diff(source.read_text().splitlines(),frozen.read_text().splitlines(),fromfile=str(source),tofile=str(frozen)))+'\n'
            (OUT/f'AT{number:03d}_{frozen.name}.diff').write_text(diff)
    assert set(differences)=={'attention_tile_tb.sv','attention_tile_run.py'}
    fixture=read(check(manifest['fixture_manifest']))
    for ref in fixture['products'].values(): check(ref,mapped=True)
    for ref in fixture['producer_planes'].values(): check(ref,mapped=True)
    for key,ref in manifest['trace'].items():
        check(ref)
        assert (ref['sha256'],ref['bytes']) == (historical['trace'][key]['sha256'],historical['trace'][key]['bytes'])
    snapshots={}
    for stage,entry in receipt['stages'].items():
        guard=attempt/f'guard_{stage}'
        plan=read(guard/'guard_plan.json'); launch=read(guard/'launch.json'); result=read(guard/'guard_result.json')
        assert result==entry['guard']
        policy=read(guard/'policy_checks.json')
        for p in policy:
            assert p['matches'] and p['nice']==19 and p['affinity']==[0,1,2,3] and p['ionice']=='idle'
        policy_count+=len(policy)
        assert plan['semantic_stall_seconds']==120 and plan['selected_cpu_ids']==[0,1,2,3]
        assert plan['minimum_mem_available_kb']==201326592
        assert plan['maximum_owned_rss_kb']==(25165824 if stage.startswith('static') else 8388608)
        assert plan['maximum_seconds']==(1800 if stage.startswith('static') else 120 if stage.startswith('pilot') else 3600)
        assert result['minimum_mem_available_kb']>plan['minimum_mem_available_kb']
        guards.append(dict(attempt=attempt.name,stage=stage,start=launch['at'],finish=result['finished_at'],policies=len(policy),result=result))
        for f in ('guard_plan.json','launch.json','policy_checks.json','guard_result.json'):
            p=guard/f;refs[str(p)]=rec(p)
        if 'input_manifest' in entry:
            inp=read(check(entry['input_manifest'])); walk(inp)
            snapshots[stage]=len(inp['compiled_snapshot'])
            assert 'PROTOCOL=0' in inp['command']
            for rel,ref in inp['compiled_snapshot'].items():
                original=attempt/'build/vivado/attention_tile.sim/sim_1/behav/xsim'/rel
                assert rec(original)['sha256']==ref['sha256']
            build=attempt/'build/vivado/attention_tile.sim/sim_1/behav/xsim'
            for p in [*build.glob('*.dat'),*build.glob('*.ini')]:
                run=attempt/stage/p.name
                assert rec(p)['sha256']==rec(run)['sha256']
                refs[str(run)]=rec(run)
    manifests[number]=manifest
    counts[str(number)]={'frozen_sources':93,'mapped_sources':93,'changed':differences,'fixture_products':len(fixture['products']),'producer_planes':len(fixture['producer_planes']),'trace_files':len(manifest['trace']),'snapshots':snapshots,'status':receipt['status']}

guards.sort(key=lambda x:x['start'])
assert all(datetime.fromisoformat(a['finish'])<datetime.fromisoformat(b['start']) for a,b in zip(guards,guards[1:]))
a19=next(BASE.glob('AT019_ATN0_*')); a20=next(BASE.glob('AT020_ATN0_*'))
assert read(a19/'receipt.json')['status']=='FAIL_OBSERVER_ASSERT'
assert 'Fatal:' in (a19/'pilot_01/simulate.log').read_text()
assert not (a19/'full_01').exists()
changed_19_20=[]
for a,b in zip(manifests[19]['sources'],manifests[20]['sources']):
    if a['frozen']['sha256']!=b['frozen']['sha256']:
        changed_19_20.append(Path(b['frozen']['path']).name)
        (OUT/'AT019_AT020_observer.diff').write_text('\n'.join(difflib.unified_diff(Path(a['frozen']['path']).read_text().splitlines(),Path(b['frozen']['path']).read_text().splitlines()))+'\n')
assert changed_19_20==['attention_tile_tb.sv']

numeric={}
for stage in ('pilot_01','full_01'):
    measure=read(a20/stage/'measurement.json');log=(a20/stage/'simulate.log').read_text()
    assert not re.search(r'(^|\n)(Fatal:|ERROR:)',log)
    def lines(marker):
        return [{k:int(v) for k,v in re.findall(r'(\w+)=(-?\d+)',line)} for line in log.splitlines() if line.startswith(marker+' ')]
    mapping={'terminal':'ATTENTION_SERVICE_TILE_RTL_PASS','ledger':'ATTENTION_SERVICE_TILE_LEDGER_PASS','softmax_mutually_exclusive_enabled':'ATTENTION_SERVICE_TILE_SM_MEASURE','softmax_operation_counts':'ATTENTION_SERVICE_TILE_SM_OP_COUNTS','commands':'ATTENTION_SERVICE_TILE_CMD_MEASURE','workers':'ATTENTION_SERVICE_TILE_EXP_MEASURE'}
    for k,m in mapping.items():
        got=lines(m); expected=measure[k]
        assert got==(expected if isinstance(expected,list) else [expected]),(stage,k)
    sm=measure['softmax_mutually_exclusive_enabled']; workers=measure['workers']; terminal=measure['terminal']
    assert sum(sm[k] for k in ('MAX','EXP','TREE','DIV','launch_report'))==sm['enabled_to_done']
    assert all(sum(w[k] for k in ('input_wait','core_busy','commit_wait','idle'))==sm['EXP'] for w in workers)
    assert all(w['launch']==w['done']==w['commit'] for w in workers)
    assert sum(w['launch'] for w in workers)==terminal['exp']==terminal['rows']*128
    for c in measure['commands']:
        assert c['wall_to_done']==c['enabled_to_done'] and c['wall_to_consume']==c['enabled_to_consume']
        assert c['wall_to_consume']-c['wall_to_done']==c['calls']*3
    total_busy=sum(w['core_busy'] for w in workers)
    assert (total_busy+3)//4==measure['four_worker_aggregate_core_bound_enabled']
    assert sm['EXP']-(total_busy+3)//4==measure['optimistic_noncore_gap_enabled']
    assert sm['A_tree_issue']==sm['A_tree_retire']==terminal['rows']*11
    assert sm['D_issue']==terminal['rows']*32 and sm['D_return_lanes']==terminal['rows']*128
    assert measure['ledger']['accepted']==measure['ledger']['retired'] and measure['ledger']['cancelled']==0
    hist=lines('ATTENTION_SERVICE_TILE_EXP_PROFILE')
    for w in workers:
        wh=[x for x in hist if x['worker']==w['worker']]
        assert sum(x['count'] for x in wh)==w['launch']
        assert sum(x['count']*x['launch_done_enabled_gap'] for x in wh)==w['core_busy']
    numeric[stage]={'terminal':terminal,'softmax':sm,'workers':workers,'commands':measure['commands'],'worker_slot_totals':{k:sum(w[k] for w in workers) for k in ('input_wait','core_busy','commit_wait','idle')},'conditional_lower_bound':measure['four_worker_aggregate_core_bound_enabled'],'optimistic_gap':measure['optimistic_noncore_gap_enabled']}

result=dict(schema='controller-atn0-scoped-audit-v1',status='PASS_SCOPED_READ_ONLY_AUDIT',attempts=counts,at019_to_at020_changes=changed_19_20,observer_note='AT020 removed fixed ASUB/TREE/D request-count assumptions from the new observer; retained original numerical checks and issue/retirement balance; actual TREE/D totals independently matched workload.',guards_serial=True,guard_count=len(guards),actual_policy_count=policy_count,guards=guards,numeric=numeric,unique_verified_reference_count=len(refs),references=list(refs.values()),scope='No DUT execution or protocol/physical acceptance; historical old-root paths mapped to local E002 only.')
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ('references','numeric','guards')},ensure_ascii=False,indent=2))
