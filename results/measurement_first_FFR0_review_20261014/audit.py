"""Controller FFR0 identity/log/source audit only; no RTL or reference execution."""
from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,re,shutil,math

ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
ATT=RUN/'attempts';A52=ATT/'AT052_FFR0_four_row_01';A53=ATT/'AT053_FFR0_four_row_02'
for name in ['mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md',
             'results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md',
             'agent/A001/result.md','agent/A001/state.json','NEW_CHAT_START.md']:
    p=OUT/'prior_records'/name;p.parent.mkdir(parents=True,exist_ok=True)
    if not p.exists():shutil.copy2(ROOT/name,p)
cache={};checks=[]
def ident(path):
    p=Path(path)
    if not p.is_absolute():p=ROOT/p
    if str(p) not in cache:
        b=p.read_bytes();cache[str(p)]=dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
    return cache[str(p)]
def j(p):ident(p);return json.loads(Path(p).read_text())
manifests={}
for p in [A52,A53]:
    m=j(p/'source_manifest.json');manifests[p.name]=m
    for group in ['frozen','external']:
        for name,e in m[group].items():
            actual=ident(e['path']);assert actual==e
            checks.append(dict(attempt=p.name,group=group,name=name,identity=actual,match=True))
    assert len(m['frozen'])+len(m['external'])==14
m52=manifests[A52.name];m53=manifests[A53.name]
delta=[]
for group in ['frozen','external']:
    for name,a in m52[group].items():
        b=m53[group][name]
        if (a['bytes'],a['sha256'])!=(b['bytes'],b['sha256']):delta.append(group+'/'+name)
assert delta==['frozen/laya_ffn_residual_four_row_v1_tb.sv']
partial=[]
for p in sorted((ATT/'AT051_FFR0_four_row_01/frozen').iterdir()):
    a=ident(p);b=ident(A52/'frozen'/p.name)
    partial.append(dict(name=p.name,before=a,after=b,changed=a['sha256']!=b['sha256']))
assert len(partial)==7 and [x['name'] for x in partial if x['changed']]==['run_ffr0_v1.py']
prep=j(ATT/'AT051_FFR0_four_row_01/preparation_failure.json');assert prep['tool_started'] is False
assert not list((ATT/'AT051_FFR0_four_row_01').glob('guard_*'))

phases=[];last_end=None;policy_total=0
for p in [A52,A53]:
    phase_names=['static','slot','pilot'] if p==A52 else ['static','pilot','full']
    for phase in phase_names:
        g=p/('guard_'+phase);plan=j(g/'guard_plan.json');result=j(g/'guard_result.json');policy=j(g/'policy_checks.json')
        verdict=j(p/('result_'+phase+'.json'));preflight=j(p/('preflight_'+phase+'.json'))
        ident(g/'driver.log');log=(g/'driver.log').read_text()
        start=datetime.fromisoformat(plan['at']);end=datetime.fromisoformat(result['finished_at'])
        assert last_end is None or start>last_end
        last_end=end
        assert plan['maximum_seconds']==(1800 if phase=='static' else 3600 if phase=='full' else 120)
        assert plan['maximum_owned_rss_kb']==(24 if phase=='static' else 8)*1024**2
        assert plan['minimum_mem_available_kb']==192*1024**2 and plan['semantic_stall_seconds']==120
        assert plan['selected_cpu_ids']==[0,1,2,3]
        assert result['trigger'] is None and result['child_exit_code']==0 and verdict['verdict']=='PASS'
        assert result['elapsed_seconds']<plan['maximum_seconds'] and result['peak_owned_rss_kb']<plan['maximum_owned_rss_kb']
        assert result['minimum_mem_available_kb']>plan['minimum_mem_available_kb']
        assert policy and all(x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 and x['matches'] for x in policy)
        assert verdict['required_marker'] in log and not re.search(r'Fatal:|ERROR:',log)
        assert preflight['files_verified']==14 and preflight['manifest_sha256']==ident(p/'source_manifest.json')['sha256']
        assert datetime.fromisoformat(preflight['at'])<start
        assert plan['command'][:9]==['/usr/bin/nice','-n','19','/usr/bin/ionice','-c','3','/usr/bin/taskset','-c','0,1,2,3']
        assert preflight['command']==plan['command'][9:]
        policy_total+=len(policy)
        phases.append(dict(attempt=p.name,phase=phase,start=plan['at'],end=result['finished_at'],guard=result,policy_samples=len(policy),
            semantic_guard_limitation='FFR0_PROGRESS accepts periodic unchanged counters; compliance not certified despite no trigger'))

full=(A53/'guard_full/driver.log').read_text();slot=(A52/'guard_slot/driver.log').read_text()
markers=['FFR0_DESCRIPTOR_REJECT_PASS cases=5 zero_axi=1','FFR0_BOUNDARIES','FFR0_NUMERICAL_REJECT_PASS nan=1 finite_overflow=1 zero_new_writes=1',
         'FFR0_FOUR_ROW_PASS rows=4 words=4096 R=256+256 AW/W/B=256/256/256 protected_bytes=196608','$finish called']
assert [full.index(x) for x in markers]==sorted(full.index(x) for x in markers)
assert 'FFR0_FADD_SLOT_PASS count=52 accepted=52 returned=52 consumed=52 cycles=1335' in slot
progress=[tuple(map(int,x)) for x in re.findall(r'FFR0_PROGRESS cycle=(\d+) skip_R=(\d+) down_R=(\d+) add_done=(\d+) B=(\d+)',full)]
assert len(progress)==5 and all(all(a<b for a,b in zip(x,y)) for x,y in zip(progress,progress[1:]))
boundary=re.search(r'FFR0_BOUNDARIES pilot=0 (.*)',full).group(1)
edges={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',boundary)}
assert edges==dict(first_AR=62,first_R=67,last_W=103325,last_B=103340,first_done=103341,consume=103349,total=103350)
assert edges['last_B']-edges['last_W']==15 and edges['first_done']>edges['last_B']
cost=j(A53/'full_cost_decision.json');pg=j(A53/'guard_pilot/guard_result.json')
assert cost['admit_full'] and math.isclose(cost['estimated_full_seconds'],pg['elapsed_seconds']*40)
assert cost['estimated_full_cycles']==25903*40 and cost['estimated_full_cycles']<40000000
assert cost['estimated_full_seconds']<3600 and cost['estimated_peak_rss_kb']==2*pg['peak_owned_rss_kb']
assert datetime.fromisoformat(cost['at_utc'])<datetime.fromisoformat(j(A53/'guard_full/guard_plan.json')['at'])
assert cost['manifest_sha256']==ident(A53/'source_manifest.json')['sha256']
assert cost['negative_tests_spawned'] is False and all(x['verdict']=='REJECT' for x in cost['negative_preflight'].values())
receipt=j(A53/'receipt.json');ev=j(A53/'verification.json')
assert receipt['status']==ev['verdict']=='PASS_SCOPED_NORMAL_FOUR_ROWS'

dut=(A53/'frozen/laya_ffn_residual_four_row_v1.sv').read_text();tb=(A53/'frozen/laya_ffn_residual_four_row_v1_tb.sv').read_text()
types=ROOT/'project/E002_Laya_HLS/experiment/include/laya_types.h';typeid=ident(types);t=types.read_text()
assert 'E_NUMERICAL=6' in t and 'E_PROTOCOL=7' in t and 'E_INTERNAL=8' in t
assert "STATUS_NUMERICAL = 8'd8" in dut and "STATUS_AXI = 8'd9" in dut
assert "consume_response(8'd8)" in tb and "cycle%20000==0 && (skip_model_r || down_model_r)" in tb
guard=(A53/'frozen/ffr0_guard.py').read_text()
assert 'PROGRESS|STATIC_PASS' in guard and 'if semantic_pattern.search(line):' in guard
assert 'semantic_last = current' in guard
assert 'if (beat_index == last_beat) source_locked <= 1\'b0;' in dut
assert "dst_published <= 1'b1;" in dut[dut.index('WRITE_B:'):dut.index('RESPONSE:')]
assert 'slot_result[30:23] == 8\'hff' in dut
assert 'skip_mem[offset+j]' in tb and 'down_mem[offset+j]' in tb and 'dst_mem[offset+j] <= wdata' in tb
assert 'dst_mem[i] !== dst_gold[i] || !dst_written[i]' in tb and 'for (int i=0;i<65536;i++)' in tb
assert 'cfg_context=416\'h123456789abcdef' in tb
source_notes=dict(normal='Actual source address-backed arrays, single unchanged leaf, AXI-written destination compared bytewise with independent gold and sentinels',
    context='Separate fixed identity fields validated; cfg_context is opaque 416-bit echo 0x123456789abcdef, not a validated production Context',
    finite_errors='Local rejection/zero writes observed but status 8 mismatches E_NUMERICAL 6; local AXI 9 absent from canonical enum',
    missing_measurements=['cfg acceptance edge','per-source first/last AR/R','exact source lock release and local destination publication edges','per-add latency histogram','exclusive state-cycle accounting'],
    watchdog='Actual five progress tuples increase, but a stagnant tuple can refresh watchdog in frozen source')
messages=[]
for name in ['measurement-first-FFR0-AT053-scoped-result-20261014','measurement-first-FFR0-status-progress-answer-20261014']:
    p=ROOT/'.research-agent/communications'/(name+'.json');m=j(p)
    payload={k:m[k] for k in ['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']}
    sha=hashlib.sha256(json.dumps(payload,ensure_ascii=False,sort_keys=True).encode()).hexdigest()
    assert m['status']=='delivered' and sha==m['payload_sha256']
    assert m['from_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279' and m['to_thread_id']=='01a129af-0395-7fd0-95ac-edd54873bd5f'
    messages.append(dict(id=name,payload_sha256=sha,identity=ident(p)))
result=dict(at=datetime.now(timezone.utc).isoformat(),scope='Read-only controller audit; no DUT/reference run',manifest_checks=checks,
    manifest_references=len(checks),unique_hashed_paths=len(cache),identities=list(cache.values()),partial_AT051=partial,
    AT052_to_AT053_delta=delta,phases=phases,policy_samples_all=policy_total,
    policy_samples_reused_slot_and_AT053=sum(x['policy_samples'] for x in phases if x['attempt']==A53.name or x['phase']=='slot'),
    full_actual_progress=progress,full_boundaries=edges,cost=cost,canonical_status_source=typeid,source_review=source_notes,messages=messages,
    verdict='Accept normal four-row data/AXI/local completion and reused 52 cases; FFR0 contract incomplete: error semantics, semantic watchdog and measurement gaps',
    next_scope='Bounded FFR1 status/watchdog/measurement correction; no long-chain launch; M003/M004 open')
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['manifest_references','unique_hashed_paths','policy_samples_all','policy_samples_reused_slot_and_AT053','verdict']},ensure_ascii=False))
