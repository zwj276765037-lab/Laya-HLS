"""Bounded terminal audit; inherit normal review, audit protocol and next input identity."""
from pathlib import Path
import json, hashlib, re, difflib
from datetime import datetime

ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
BASE=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
A1=BASE/'attempts/AT021_ATN1_attention_prefetch_01'
AP=BASE/'attempts/AT022_ATN1_prefetch_protocol_01'
PRE=ROOT/'results/measurement_first_ATN1_progress_review_20261013/verification.json'
refs={};drifts=[]
def read(p):return json.loads(p.read_text())
def rec(p):
    p=Path(p);b=p.read_bytes();r=dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest());refs[str(p)]=r;return r
def check(r):
    v=rec(r['path']);assert (v['sha256'],v['bytes'])==(r['sha256'],r['bytes']),r['path'];return Path(r['path'])
def walk(o):
    if isinstance(o,dict):
        if all(k in o for k in ('path','bytes','sha256')):check(o)
        else:
            for v in o.values():walk(v)
    elif isinstance(o,list):
        for v in o:walk(v)

prior=read(PRE);rec(PRE)
for r in prior['references']:
    now=rec(r['path'])
    if (now['sha256'],now['bytes'])!=(r['sha256'],r['bytes']):
        assert r['path'].endswith('/tb/attention_tile_receipt.py')
        drifts.append(dict(historical=r,current=now,scope='Live postprocessing collector, outside 93 frozen DUT inputs; original AT021 log/numeric/measurement identities remain unchanged.'))
assert len(drifts)==1
for a in (A1,AP):
    rec(a/'receipt.json');receipt=read(a/'receipt.json');assert receipt['status']=='PASS_SCOPED';walk(receipt)
    sm=read(a/'source_manifest.json')
    for s in sm['sources']:check(s['frozen'])
    assert len(sm['sources'])==93
    assert rec(a/'frozen_source/attention_tile_service_v1.sv')['sha256']=='11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16'

protocol=read(AP/'protocol_01/numeric_result.json');walk(protocol)
inp=read(AP/'protocol_01/input_manifest.json');walk(inp)
assert 'PROTOCOL=1' in inp['command'] and 'ROWS=16' in inp['command']
for rel,r in inp['compiled_snapshot'].items():
    assert rec(AP/'build/vivado/attention_tile.sim/sim_1/behav/xsim'/rel)['sha256']==r['sha256']
log=(AP/'protocol_01/simulate.log').read_text()
assert not re.search(r'(^|\n)(Fatal:|ERROR:)',log)
def lines(marker):
    return [{k:int(v) for k,v in re.findall(r'(\w+)=(-?\d+)',l)} for l in log.splitlines() if l.startswith(marker+' ')]
assert lines('ATTENTION_SERVICE_TILE_RTL_PASS')==[protocol['terminal']]
assert lines('ATTENTION_SERVICE_TILE_LEDGER_PASS')==[protocol['call_ledger']]
assert protocol['call_ledger']==dict(accepted=210966,retired=210960,cancelled=6)
assert lines('ATTENTION_SERVICE_TILE_FIRST_ERROR_CASE_PASS')==protocol['first_error_cases']
history=ROOT/'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/tile16_03/numeric_result.json'
rec(history);h=read(history)
assert protocol['first_error_cases']==h['first_error_cases']
assert set(x['kind'] for x in lines('ATTENTION_SERVICE_TILE_CE_PASS'))==set(range(4))
assert set(x['kind'] for x in lines('ATTENTION_SERVICE_TILE_RESET_PASS'))==set(range(6))
assert lines('ATTENTION_SERVICE_TILE_PREFETCH_CE_PASS')==[dict(kind=4,pending=1,ready=0),dict(kind=5,pending=0,ready=4)]
assert lines('ATTENTION_SERVICE_TILE_PREFETCH_RESET_PASS')==[dict(kind=4),dict(kind=5)]
assert 'ATTENTION_SERVICE_TILE_FIRST_ERROR_PASS cases=6 pending_Q_CE_reset=1' in log
assert 'ATTENTION_SERVICE_TILE_PROTOCOL_PASS resets=6 wrong_epoch_row=1 prefetch_pending_ready=1' in log
tb=(AP/'frozen_source/attention_tile_tb.sv').read_text()
assert 'repeat(8)begin @(negedge ap_clk);#1;if(read_tile_state()!==saved||exp_native_advance)' in tb
svh=(AP/'frozen_source/attention_tile_state.svh').read_text()
fields=re.findall(r'dut\.staged_\w+(?:\[\d+\])?',svh)
expected=['dut.staged_count','dut.staged_cursor','dut.staged_pending']+[f'dut.staged_{k}[{i}]' for i in range(4) for k in ['x','key']]
assert sorted(fields)==sorted(expected)
(OUT/'AT021_AT022_protocol.diff').write_text('\n'.join(difflib.unified_diff((A1/'frozen_source/attention_tile_tb.sv').read_text().splitlines(),tb.splitlines()))+'\n')
g=AP/'guard_protocol_01';plan=read(g/'guard_plan.json');gr=read(g/'guard_result.json');launch=read(g/'launch.json');policy=read(g/'policy_checks.json')
for f in ('guard_plan.json','guard_result.json','launch.json','policy_checks.json'):rec(g/f)
assert gr==protocol['guard'] and gr['child_exit_code']==0 and gr['trigger'] is None
assert plan['maximum_owned_rss_kb']==8388608 and plan['maximum_seconds']==3600 and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==201326592
assert all(p['matches'] and p['nice']==19 and p['affinity']==[0,1,2,3] and p['ionice']=='idle' for p in policy)
assert datetime.fromisoformat(prior['guards'][-1]['finish'])<datetime.fromisoformat(launch['at'])

oldroot='/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline'
local=ROOT/'project/E002_Laya_HLS/experiment'
bridge=local/'results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04'
fm=read(bridge/'work/fixture/manifest.json');rec(bridge/'work/fixture/manifest.json');rec(bridge/'receipt.json')
kb=BASE/'attempts/AT002_KB1_Down_rowpack/evidence/measurement'
km=read(kb/'input_manifest.json');rec(kb/'input_manifest.json')
identity={}
for name in ('q.mem','scale.mem'):
    x=next(r for r in fm['outputs'] if Path(r['path']).name==name)
    y=next(s['frozen'] for s in km['fixture_files'] if s['frozen']['path'].endswith('/a/'+name))
    mapped={**x,'path':str(local)+x['path'][len(oldroot):]};check(mapped);check(y)
    assert (x['bytes'],x['sha256'])==(y['bytes'],y['sha256'])
    identity[name]=dict(bridge=mapped,kb1=y,meaning='Independent expected data only; not same-runtime producer evidence.')
for r in fm['inputs'][:5]:
    check({**r,'path':str(local)+r['path'][len(oldroot):]})
out=dict(schema='controller-atn1-close-audit-v1',status='PASS_SCOPED_TERMINAL_REVIEW',inherited_normal_review=rec(PRE),normal_comparison=prior['comparison'],protocol_terminal=protocol['terminal'],protocol_ledger=protocol['call_ledger'],first_error_matches_original=True,prefetch_CE=lines('ATTENTION_SERVICE_TILE_PREFETCH_CE_PASS'),prefetch_reset=lines('ATTENTION_SERVICE_TILE_PREFETCH_RESET_PASS'),captured_new_fields=fields,protocol_snapshot_files=len(inp['compiled_snapshot']),guards_serial=True,total_guard_count=prior['guard_count']+1,total_policy_count=prior['actual_policy_count']+len(policy),protocol_guard=gr,historical_live_reference_drifts=drifts,next_GQD0_expected_input_identity=identity,unique_current_reference_count=len(refs),references=list(refs.values()),limits='Normal drain is bounded source-invariant reasoning plus numerical/CE/reset evidence, not per-slot formal proof. No physical/full-request acceptance or tool run by controller.')
(OUT/'verification.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k not in ('references','historical_live_reference_drifts','next_GQD0_expected_input_identity')},ensure_ascii=False,indent=2))
