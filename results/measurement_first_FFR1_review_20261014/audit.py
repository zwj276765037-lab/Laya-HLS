"""Read-only AT054 file/log/controller audit; no reference, RTL or synthesis."""
from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,re,shutil,difflib,math

ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
A=RUN/'attempts/AT054_FFR1_status_measurement_01'
A53=RUN/'attempts/AT053_FFR0_four_row_02';A52=RUN/'attempts/AT052_FFR0_four_row_01'
for n in ['mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md',
          'results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md','agent/A001/result.md',
          'agent/A001/state.json','NEW_CHAT_START.md']:
    p=OUT/'prior_records'/n;p.parent.mkdir(parents=True,exist_ok=True)
    if not p.exists():shutil.copy2(ROOT/n,p)
cache={};refs=[]
def ident(p):
    p=Path(p)
    if not p.is_absolute():p=ROOT/p
    if str(p) not in cache:
        b=p.read_bytes();cache[str(p)]=dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
    return cache[str(p)]
def j(p):ident(p);return json.loads(Path(p).read_text())
ms={}
for p in [A,A53,A52]:
    m=j(p/'source_manifest.json');ms[p.name]=m
    for group in ['frozen','external']:
        for name,e in m[group].items():
            assert ident(e['path'])==e
            refs.append(dict(attempt=p.name,group=group,name=name,identity=e,match=True))
m=ms[A.name]
assert len(m['frozen'])+len(m['external'])==16
for p in [A53,A52]:
    for group,names in [('frozen',['laya_ffn_fadd_slot_v1.sv','laya_ffn_fadd_slot_v1_tb.sv']),('external',['add','leaf','skip','down','gold'])]:
        for name in names:assert m[group][name]['sha256']==ms[p.name][group][name]['sha256']
old=(A53/'frozen/laya_ffn_residual_four_row_v1.sv').read_text()
new=(A/'frozen/laya_ffn_residual_four_row_v1.sv').read_text()
expected=old.replace("  localparam logic [7:0] STATUS_NUMERICAL = 8'd8;\n  localparam logic [7:0] STATUS_AXI = 8'd9;",
    "  // Local 8-bit transport of the production Status enum (laya_types.h).\n  localparam logic [7:0] STATUS_NUMERICAL = 8'd6;\n  localparam logic [7:0] STATUS_INTERNAL = 8'd8;").replace('rsp_status <= STATUS_AXI;','rsp_status <= STATUS_INTERNAL;')
assert expected==new and old.count('rsp_status <= STATUS_AXI;')==3
ident(A/'dut_diff.txt')
types=Path(m['external']['status_header']['path']).read_text()
assert 'E_NUMERICAL=6' in types and 'E_PROTOCOL=7' in types and 'E_INTERNAL=8' in types

keys=('cfg','sar','sr','dar','dr','aa','ar','ac','aw','w','b','rsp')
pattern=re.compile('^FFR1_PROGRESS '+' '.join(k+r'=(\d+)' for k in keys)+'$')
def advance(previous,line):
    match=pattern.fullmatch(line.strip())
    if not match:return previous,False,False
    cur=tuple(map(int,match.groups()))
    if previous is None:return cur,any(cur),False
    if any(x<y for x,y in zip(cur,previous)):return previous,False,True
    return cur,any(x>y for x,y in zip(cur,previous)),False
host=j(A/'guard_host_test.json');host_cases=[]
for c in host['cases']:
    prev=None;last=0;first=None;reg_seen=False
    for sample in c['samples']:
        prev,ok,reg=advance(prev,sample['line']);reg_seen|=reg
        if ok:last=sample['logical_second']
        stall=sample['logical_second']-last>=120
        if stall and first is None:first=sample['logical_second']
        assert (ok,reg,stall)==(sample['advanced'],sample['regression'],sample['stall'])
    assert first==c['observed_stall_at']==c['expected_stall_at'] and reg_seen==c['regression_seen']
    assert c['spawned'] is False and c['verdict']=='PASS'
    host_cases.append(dict(name=c['name'],stall_at=first,regression_seen=reg_seen))
assert len(host_cases)==4 and host['verdict']=='PASS' and host['spawned'] is False

phases=[];previous_end=None;total_policy=0
for phase in ['host','static','error','pilot','full']:
    g=A/('guard_'+phase);plan=j(g/'guard_plan.json');r=j(g/'guard_result.json');v=j(A/('result_'+phase+'.json'))
    if (g/'policy_checks.json').exists():policy=j(g/'policy_checks.json')
    else:
        assert phase=='host'
        policy=[]
    ident(g/'driver.log');log=(g/'driver.log').read_text()
    start=datetime.fromisoformat(plan['at']);end=datetime.fromisoformat(r['finished_at'])
    assert previous_end is None or start>previous_end
    previous_end=end
    assert plan['maximum_seconds']==(1800 if phase=='static' else 3600 if phase=='full' else 120)
    assert plan['maximum_owned_rss_kb']==(24 if phase=='static' else 8)*1024**2
    assert plan['minimum_mem_available_kb']==192*1024**2 and plan['semantic_stall_seconds']==120 and plan['selected_cpu_ids']==[0,1,2,3]
    assert plan['command'][:9]==['/usr/bin/nice','-n','19','/usr/bin/ionice','-c','3','/usr/bin/taskset','-c','0,1,2,3']
    assert r['child_exit_code']==0 and r['trigger'] is None and v['verdict']=='PASS'
    assert r['elapsed_seconds']<plan['maximum_seconds'] and r['minimum_mem_available_kb']>plan['minimum_mem_available_kb']
    assert all(x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 and x['matches'] for x in policy)
    if phase=='host':
        assert len(policy)==0 and r['peak_owned_rss_kb'] is None and not r['rss_captured']
        assert 'FFR1_GUARD_HOST_PASS cases=4 spawned=0' in log
    else:
        assert r['rss_captured'] and r['peak_owned_rss_kb']<plan['maximum_owned_rss_kb']
        pf=j(A/('preflight_'+phase+'.json'))
        assert pf['files_verified']==16 and pf['manifest_sha256']==ident(A/'source_manifest.json')['sha256']
        assert pf['command']==plan['command'][9:] and datetime.fromisoformat(pf['at'])<start
    assert not re.search(r'Fatal:|ERROR:',log)
    parsed=[];prev=None
    for line in log.splitlines():
        if pattern.fullmatch(line):
            prev,ok,reg=advance(prev,line);assert ok and not reg;parsed.append(prev)
    if phase in ['error','pilot','full']:
        assert log.splitlines().count('FFR1_SIM_START')==1 and r['simulation_started']
        assert r['semantic_progress_accepts']==len(parsed) and r['semantic_progress_rejects']==0
        assert parsed[-1]==tuple(r['semantic_final_counters'])
    total_policy+=len(policy)
    phases.append(dict(phase=phase,start=plan['at'],end=r['finished_at'],guard=r,policy_samples=len(policy),progress_records=len(parsed)))
assert total_policy==104

full=(A/'guard_full/driver.log').read_text()
required=['FFR0_DESCRIPTOR_REJECT_PASS cases=5 zero_axi=1','FFR1_NUMERICAL_REJECT_PASS status=6 nan=1 finite_overflow=1 zero_new_writes=1',
 'FFR1_AXI_REJECT_PASS kind=0 status=8 skip_AR/R=1/1 down_AR/R=0/0 AW/W/B=0/0/0 published=0',
 'FFR1_AXI_REJECT_PASS kind=1 status=8 skip_AR/R=1/1 down_AR/R=1/1 AW/W/B=0/0/0 published=0',
 'FFR1_AXI_REJECT_PASS kind=2 status=8 skip_AR/R=1/1 down_AR/R=1/1 AW/W/B=1/1/1 published=0',
 'FFR1_FOUR_ROW_PASS rows=4 words=4096 R=256+256 AW/W/B=256/256/256 protected_bytes=196608']
assert all(x in full for x in required)
hist={int(a):int(b) for a,b in re.findall(r'^FFR1_ADD_LATENCY latency=(\d+) count=(\d+)$',full,re.M)}
assert hist=={22:4096} and sum(k*v for k,v in hist.items())==90112
states={int(a):int(b) for a,b in re.findall(r'^FFR1_PHASE state=(\d+) cycles=(\d+)$',full,re.M)}
assert states==dict(enumerate([1,305,1042,288,1484,4096,94208,283,281,1292,9]))
assert sum(states.values())==103349-61+1==103289
edge_line=re.search(r'^FFR1_EDGES .+$',full,re.M).group(0)
assert edge_line=='FFR1_EDGES sample=posedge_preNBA cfg=61 skip_AR=62/102927 skip_R=67/102930 down_AR=68/102931 down_R=72/102938 lock=62/102939 last_read=102938 AW=457/103324 W=458/103325 B=464/103340 publish=103341 response=103341/103349'
assert '$finish called at time : 1038820 ns' in full
cost=j(A/'full_cost_decision.json');pilot=j(A/'guard_pilot/guard_result.json')
assert math.isclose(cost['conservative_full_wall_estimate_seconds'],8*pilot['elapsed_seconds'])
assert cost['conservative_full_cycle_estimate']>2*4*25842 and cost['conservative_full_cycle_estimate']<40000000
assert cost['decision']=='ADMIT_ONE_COLD_FULL' and cost['full_started_at_decision'] is False
cost_mtime=datetime.fromtimestamp((A/'full_cost_decision.json').stat().st_mtime,timezone.utc)
assert cost_mtime<datetime.fromisoformat(j(A/'guard_full/guard_plan.json')['at'])
receipt=j(A/'receipt.json');ev=j(A/'verification.json');assert receipt['status']=='PASS_SCOPED_LOCAL_FOUR_ROWS'

tb=(A/'frozen/laya_ffn_residual_four_row_ffr1_tb.sv').read_text()
for s in ['latency=cycle-add_accept_cycle','add_latency_hist[latency]++','phase_cycles[int\'(dut.state)]++',
          'skip_mem[offset+j]','down_mem[offset+j]','dst_mem[offset+j] <= wdata','dst_mem[i] !== dst_gold[i] || !dst_written[i]',
          'consume_response(E_NUMERICAL)','consume_response(E_INTERNAL)','FFR1_B_ERROR_WRITE_FACT','FFR1_AX_ERROR_LATE_ACTIVITY']:
    assert s in tb,s
guard=(A/'frozen/ffr1_guard.py').read_text()
assert 'elif simulation_started:' in guard and 'elif COMPILE_RE.search(line):' in guard and 'semantic_counter_regression' in guard
assert 'if line.strip() == "FFR1_SIM_START":' in guard
# Current runtime emits the startup marker once.  Repeated SIM_START remains
# outside this evidence; require one-shot handling if this guard is adapted.
context_limit='Fixed scalar identity subset plus opaque 416-bit echo; external sources/local lock, not production hub/Context proof'
logic_bits=dict(producer_data=1536,producer_control_including_context_counters=594,slot_data=96,slot_control=2,total=2228,
    meaning='Declared sequential register widths from current RTL excluding unchanged arithmetic leaf; not synthesis/physical utilization')
messages=[]
for name in ['measurement-first-FFR1-AT054-scoped-result-20261014']:
    p=ROOT/'.research-agent/communications'/(name+'.json');msg=j(p)
    payload={k:msg[k] for k in ['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']}
    sha=hashlib.sha256(json.dumps(payload,ensure_ascii=False,sort_keys=True).encode()).hexdigest()
    assert msg['status']=='delivered' and sha==msg['payload_sha256']
    messages.append(dict(identity=ident(p),payload_sha256=sha))
result=dict(at=datetime.now(timezone.utc).isoformat(),scope='Controller read-only audit; no RTL/reference run',
 manifest_references=len(refs),current_manifest_references=16,manifest_checks=refs,unique_hashed_paths=len(cache),identities=list(cache.values()),
 exact_DUT_delta='Only numerical 8->6 and three AXI 9->E_INTERNAL8 sites, plus constant/comment rename',
 host_cases_recomputed=host_cases,phases=phases,tool_policy_samples=total_policy,host_actual_policy_and_peak_RSS='UNKNOWN; 0 samples/null peak',
 normal_histogram=hist,normal_exclusive_cycles=states,inclusive_cfg_consume_cycles=sum(states.values()),edge_line=edge_line,
 end_time_ns=1038820,end_time_derived_cycles=103882,cost=cost,cost_file_mtime_utc=cost_mtime.isoformat(),
 cost_chronology_basis='Existing file mtime precedes recorded full guard launch; no at timestamp inside cost JSON',
 declared_wrapper_register_bits=logic_bits,context_limit=context_limit,messages=messages,
 guard_scope='One actual SIM_START, real monotonic handshake counters and four host sequences accepted; repeat SIM_START can currently renew and is not covered',
 verdict='PASS_SCOPED_LOCAL_FOUR_ROWS for AT054 fixed runtime/profile; M003/M004 open')
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['manifest_references','current_manifest_references','unique_hashed_paths','tool_policy_samples','inclusive_cfg_consume_cycles','verdict']},ensure_ascii=False))
