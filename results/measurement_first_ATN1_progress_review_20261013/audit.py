"""Read settled AT021 normal evidence and AT022 frozen identity; no tool runs."""
from pathlib import Path
import json, hashlib, re
from datetime import datetime

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
BASE=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
A0=BASE/'AT020_ATN0_attention_measurement_02'
A1=BASE/'AT021_ATN1_attention_prefetch_01'
AP=BASE/'AT022_ATN1_prefetch_protocol_01'
refs={}
def read(p):return json.loads(p.read_text())
def record(p):
    data=p.read_bytes()
    r=dict(path=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
    refs[str(p)]=r
    return r
def check(r):
    p=Path(r['path']);v=record(p)
    assert (v['bytes'],v['sha256'])==(r['bytes'],r['sha256']),str(p)
    return p
def walk(o):
    if isinstance(o,dict):
        if all(k in o for k in ('path','bytes','sha256')):check(o)
        else:
            for v in o.values():walk(v)
    elif isinstance(o,list):
        for v in o:walk(v)

m0=read(A0/'source_manifest.json');record(A0/'source_manifest.json')
manifests={};source_changes={}
for a in (A1,AP):
    record(a/'source_manifest.json');m=read(a/'source_manifest.json');manifests[a.name]=m
    assert len(m['sources'])==93
    for s in m['sources']:check(s['frozen'])
    check(m['candidate_state_manifest'])
    assert m['fixture_manifest']==m0['fixture_manifest']
    for name,r in m['trace'].items():
        check(r);assert (r['sha256'],r['bytes'])==(m0['trace'][name]['sha256'],m0['trace'][name]['bytes'])
    source_changes[a.name]=[Path(y['frozen']['path']).name for x,y in zip(m0['sources'],m['sources']) if x['frozen']['sha256']!=y['frozen']['sha256']]
    dut=record(a/'frozen_source/attention_tile_service_v1.sv')
    assert dut['sha256']=='11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16'
    assert m['candidate_dut']['sha256']==dut['sha256']
assert source_changes[A1.name]==['attention_tile_service_v1.sv','attention_tile_state.svh','attention_tile_run.py','attention_tile_state.py']
assert source_changes[AP.name]==['attention_tile_tb.sv',*source_changes[A1.name]]
between=[Path(y['frozen']['path']).name for x,y in zip(manifests[A1.name]['sources'],manifests[AP.name]['sources']) if x['frozen']['sha256']!=y['frozen']['sha256']]
assert between==['attention_tile_tb.sv','attention_tile_run.py']

measurement=read(A1/'full_01/measurement.json');numeric=read(A1/'full_01/numeric_result.json')
walk(measurement);walk(numeric)
for p in (A1/'full_01/measurement.json',A1/'full_01/numeric_result.json'):record(p)
inp=read(A1/'full_01/input_manifest.json');walk(inp)
assert 'ROWS=128' in inp['command'] and 'PROTOCOL=0' in inp['command']
for rel,r in inp['compiled_snapshot'].items():
    build=A1/'build/vivado/attention_tile.sim/sim_1/behav/xsim'/rel
    assert record(build)['sha256']==r['sha256']
log=(A1/'full_01/simulate.log').read_text()
assert not re.search(r'(^|\n)(Fatal:|ERROR:)',log)
def lines(marker):
    return [{k:int(v) for k,v in re.findall(r'(\w+)=(-?\d+)',l)} for l in log.splitlines() if l.startswith(marker+' ')]
for k,marker in [('terminal','ATTENTION_SERVICE_TILE_RTL_PASS'),('ledger','ATTENTION_SERVICE_TILE_LEDGER_PASS'),('commands','ATTENTION_SERVICE_TILE_CMD_MEASURE'),('workers','ATTENTION_SERVICE_TILE_EXP_MEASURE'),('softmax_mutually_exclusive_enabled','ATTENTION_SERVICE_TILE_SM_MEASURE')]:
    v=measurement[k];assert lines(marker)==(v if isinstance(v,list) else [v]),k
assert numeric['terminal']==measurement['terminal']
assert numeric['call_ledger']==measurement['ledger']
assert numeric['protocol_enabled']==0
baseline=read(A0/'full_01/measurement.json');record(A0/'full_01/measurement.json')
for k in ('M','A','D','exp','products','trees','av_steps','load','qk','av','rows'):
    assert baseline['terminal'][k]==measurement['terminal'][k]
assert baseline['ledger']==measurement['ledger']
sm=measurement['softmax_mutually_exclusive_enabled']
assert sum(sm[k] for k in ('MAX','EXP','TREE','DIV','launch_report'))==265084
assert all(sum(w[k] for k in ('input_wait','core_busy','commit_wait','idle'))==248436 for w in measurement['workers'])
workers={key:{k:sum(w[k] for w in v['workers']) for k in ('launch','done','commit','input_wait','core_busy','commit_wait','idle')} for key,v in [('ATN0',baseline),('ATN1',measurement)]}
assert workers['ATN0']['core_busy']==workers['ATN1']['core_busy']==898680
assert workers['ATN1']['launch']==workers['ATN1']['done']==workers['ATN1']['commit']==16384
comparison={}
for name,old,new in [('SM_first_done',287173,265084),('SM_consume',287197,265108),('normal_compute_first_done_sum',604317,582228),('full_TB',1608896,1586807),('EXP_interval',270525,248436)]:
    comparison[name]=dict(baseline=old,candidate=new,reduction=old-new,reduction_percent=(old-new)/old*100)
    assert old-new==22089

guards=[];policies=0
for a,stages in [(A1,('static_01','pilot_01','full_01')),(AP,('static_01',))]:
    for stage in stages:
        g=a/f'guard_{stage}'
        for f in ('guard_plan.json','guard_result.json','launch.json','policy_checks.json'):record(g/f)
        plan=read(g/'guard_plan.json');r=read(g/'guard_result.json');ps=read(g/'policy_checks.json');launch=read(g/'launch.json')
        assert r['child_exit_code']==0 and r['trigger'] is None
        assert plan['semantic_stall_seconds']==120 and plan['selected_cpu_ids']==[0,1,2,3]
        assert plan['maximum_owned_rss_kb']==(25165824 if stage.startswith('static') else 8388608)
        assert plan['maximum_seconds']==(1800 if stage.startswith('static') else 120 if stage.startswith('pilot') else 3600)
        assert r['minimum_mem_available_kb']>201326592
        assert all(p['matches'] and p['nice']==19 and p['affinity']==[0,1,2,3] and p['ionice']=='idle' for p in ps)
        policies+=len(ps);guards.append(dict(attempt=a.name,stage=stage,start=launch['at'],finish=r['finished_at'],result=r,policy_count=len(ps)))
guards.sort(key=lambda x:x['start'])
assert all(datetime.fromisoformat(x['finish'])<datetime.fromisoformat(y['start']) for x,y in zip(guards,guards[1:]))
protocol_plan=read(AP/'guard_protocol_01/guard_plan.json');record(AP/'guard_protocol_01/guard_plan.json')
assert protocol_plan['command'][-2:]==['--protocol','1']
result=dict(schema='controller-atn1-progress-audit-v1',status='PASS_SCOPED_NORMAL_PROGRESS_ONLY',comparison=comparison,worker_slot_totals=workers,source_counts={'AT021':93,'AT022':93},source_changes=source_changes,AT021_AT022_diff=between,candidate_dut_sha256='11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16',snapshot_files=len(inp['compiled_snapshot']),guard_count=len(guards),actual_policy_count=policies,guards_serial=True,guards=guards,protocol='RUNNING per latest handoff; no terminal reviewed here',scope='Normal head progress only; no candidate adoption, physical or full request acceptance; no DUT run by controller.',unique_reference_count=len(refs),references=list(refs.values()))
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ('references','guards')},ensure_ascii=False,indent=2))
