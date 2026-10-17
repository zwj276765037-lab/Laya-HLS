"""Controller read-only audit of LNQ0 bounded failure; no DUT execution."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, shutil, re
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
ATT=RUN/'attempts'
P={i:next(ATT.glob(f'AT{i:03}_*')) for i in range(42,48)}
for name in ['mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md',
             'results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md','agent/A001/result.md',
             'agent/A001/state.json','NEW_CHAT_START.md']:
    target=OUT/'prior_records'/name;target.parent.mkdir(parents=True,exist_ok=True)
    if not target.exists():shutil.copy2(ROOT/name,target)
cache={};checks=[]
def identity(path):
    p=Path(path)
    if str(p) not in cache:
        h=hashlib.sha256();n=0
        with p.open('rb') as f:
            while b:=f.read(4*1024**2):h.update(b);n+=len(b)
        cache[str(p)]={'path':str(p),'bytes':n,'sha256':h.hexdigest()}
    return cache[str(p)]
def check(v,origin):
    actual=identity(v['path']);ok=all(v[k]==actual[k] for k in ['bytes','sha256'])
    checks.append(dict(origin=origin,expected=v,actual=actual,match=ok));assert ok,origin
def refs(v,origin):
    if isinstance(v,dict):
        if {'path','bytes','sha256'}<=v.keys():check(v,origin)
        else:
            for k,x in v.items():refs(x,origin+'/'+k)
    elif isinstance(v,list):
        for i,x in enumerate(v):refs(x,origin+'/'+str(i))
manifests={}
for i in [45,46,47]:
    m=json.loads((P[i]/'source_manifest.json').read_text());manifests[i]=m
    refs(m,f'AT{i}/manifest')
receipt=json.loads((P[47]/'receipt.json').read_text());refs(receipt,'AT047/receipt')
assert receipt['verdict']=='FAIL_AT_POST_PUBLICATION_TB_CHECK'
assert len(manifests[47]['files'])==286
assert len({x['path'] for x in manifests[47]['files']})==285

diff=[]
for p in (P[47]/'frozen_new').iterdir():
    old=P[46]/'frozen_new'/p.name
    if old.exists() and identity(old)['sha256']!=identity(p)['sha256']:diff.append(p.name)
assert sorted(diff)==['laya_lnq0_source_stage_v1.sv','run_lnq0_chain_v1.tcl']
for name in ['geglu_gate_quant_bridge_v1.sv','laya_lnq0_external_quant_admission_v1.sv',
             'laya_lnq0_w_binding_v1.sv','laya_lnq0_bound_identity_generated_v1.sv','lnq0_chain_tb_v1.sv']:
    assert identity(P[46]/'frozen_new'/name)['sha256']==identity(P[47]/'frozen_new'/name)['sha256']

raw=(P[47]/'guard_full/driver.log').read_text()
pilot=(P[47]/'guard_pilot/driver.log').read_text()
assert 'Fatal: LN publication missed real store/last B' in raw
assert 'LNQ0_CHAIN_PASS' not in raw and 'LNQ0_LN_SOURCE_PASS' not in raw
assert 'source_quant_accepted=1' not in raw
for s in ['destination_B row=3 cycles=167215','completion_complete cycles=168789',
          'MATRIX_PROGRESS cycle=168898 LN_publish=1 last_B=4']:assert s in raw
assert 'cycle=24450 LN_row=0 arithmetic_pass1_cursor=896' in pilot
assert 'LNQ0_STATIC_PASS' in (P[47]/'guard_static/driver.log').read_text()
tb=(P[47]/'frozen_new/lnq0_chain_tb_v1.sv').read_text()
source=(P[47]/'frozen_new/laya_lnq0_source_stage_v1.sv').read_text()
monitor_entry=next(x for x in manifests[47]['files'] if x['path'].endswith('/laya_generated_store_monitor_v1.sv'))
portal_entry=next(x for x in manifests[47]['files'] if x['path'].endswith('/laya_generated_provenance_axi_portal_v1.sv'))
monitor=Path(monitor_entry['path']).read_text();portal=Path(portal_entry['path']).read_text()
assert 'assign coverage_complete=scope_active && physical_status==0' in monitor
assert '(request_action==PUBLISH && !monitor_scope_active && monitor_drained)' in portal
assert tb.index('while(!ln_published)tick();')<tb.index('if(!ln_source.monitor_coverage_complete')
ordered=['if(!monitor_coverage_complete)','receive_provenance(END_EVENT,0',
         'if(monitor_observed0!=target_rows*4096','LN NORM guard changed',
         'transact("publish",PUBLISH', 'ln_published=1;']
positions=[source.index(x) for x in ordered];assert positions==sorted(positions)

guards=[]
for i,names in [(42,['guard_bound_identity']),(45,['guard_static']),
                (46,['guard_static','guard_pilot','guard_pilot_02']),
                (47,['guard_static','guard_pilot','guard_full'])]:
    for name in names:
        p=P[i]/name
        plan=json.loads((p/'guard_plan.json').read_text());result=json.loads((p/'guard_result.json').read_text())
        policy=json.loads((p/'policy_checks.json').read_text())
        assert plan['maximum_seconds']==(1800 if name=='guard_static' else 3600 if name=='guard_full' else 120)
        assert plan['maximum_owned_rss_kb']==(24 if name=='guard_static' else 8)*1024**2
        assert plan['minimum_mem_available_kb']==192*1024**2 and plan['semantic_stall_seconds']==120
        assert policy and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 for x in policy)
        guards.append(dict(attempt=i,name=name,start=plan['at'],end=result['finished_at'],result=result,policy_samples=len(policy)))
assert all(datetime.fromisoformat(a['end'])<datetime.fromisoformat(b['start']) for a,b in zip(guards,guards[1:]))
for name in ['static','pilot','full']:
    r=next(g['result'] for g in guards if g['attempt']==47 and g['name']=='guard_'+name)
    assert r==receipt['stages'][name]['guard']
assert receipt['stages']['full']['guard']['child_exit_code']==0 and receipt['stages']['full']['status']=='FAIL'
assert 'Fatal: LayerNorm producer portal fixture path' in (P[46]/'guard_pilot/driver.log').read_text()

cost=json.loads((P[47]/'full_cost_decision.json').read_text())
last=json.loads((P[47]/'guard_pilot/semantic_timeline.jsonl').read_text().splitlines()[-1])
t=last['elapsed_seconds']-last['seconds_since_progress'];rate=24450/t
forecast=(170031+206136*2.5)/rate*1.05
assert abs(t-cost['last_marker_elapsed_upper_seconds'])<1e-8
assert abs(rate-cost['conservative_observed_cycles_per_second'])<1e-8
assert abs(forecast-cost['forecast_wall_seconds'])<1e-7 and forecast<3600

directed=(P[44]/'directed_xsim.log').read_text()
dtb=P[44]/'frozen_rtl/laya_lnq0_admission_binding_tb_v1.sv'
assert 'LNQ0_ADMISSION_BINDING_PASS' in directed and 'Fatal:' not in directed
dt=dtb.read_text();assert 'source_query_granted=0' in dt and 'cache_ready=1' in dt
for name in ['laya_lnq0_external_quant_admission_v1.sv','laya_lnq0_w_binding_v1.sv','laya_lnq0_bound_identity_generated_v1.sv']:
    assert identity(P[44]/'frozen_rtl'/name)['sha256']==identity(P[47]/'frozen_new'/name)['sha256']
result=dict(scope='controller read-only bounded-failure and temporal-check audit',at=datetime.now(timezone.utc).isoformat(),
            references=checks,reference_count=len(checks),unique_paths=len(cache),all_references_match=True,
            AT047_manifest_rows=286,AT047_unique_paths=285,AT046_to_AT047_changed_new_files=diff,
            observed_LN_boundary={'last_B_cycle':167215,'completion_packet_last_cycle':168789,'publish_marker_cycle':168898},
            source_checks_before_publish=ordered,monitor_identity=monitor_entry,portal_identity=portal_entry,
            guards=guards,guard_count=len(guards),policy_samples=sum(g['policy_samples'] for g in guards),
            AT047_policy_samples=sum(g['policy_samples'] for g in guards if g['attempt']==47),
            cost_recalculation={'last_marker_seconds':t,'prefix_cycles_per_second':rate,'forecast_seconds':forecast,
                                'kind':'estimate, not a measured full-chain bound or deployment latency'},
            AT044={'log':identity(P[44]/'directed_xsim.log'),'TB':identity(dtb),
                   'scope':'adapter RTL with TB-controlled hub/bridge/cache responses; not actual combined endpoints',
                   'guard_policy':'No guard/policy artifact found in AT043/AT044 attempt roots; UNKNOWN, not inferred from AT047'},
            verdict='AT047 semantic FAIL; LN prefix evidence retained, subsequent chain NOT_REACHED',
            next_candidate='TB-only temporal witness correction; same DUT/data/profile; at most one separately contracted full')
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['reference_count','unique_paths','guard_count','policy_samples','AT047_policy_samples','verdict']},ensure_ascii=False))
