"""Read-only controller audit of AT049; never executes DUT or earlier audit scripts."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re, shutil

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
P=RUN/'attempts/AT049_LNQ2_runtime_01'
OLD=RUN/'attempts/AT048_LNQ1_observation_01'
for name in ['mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md',
             'results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md','agent/A001/result.md',
             'agent/A001/state.json','NEW_CHAT_START.md']:
    target=OUT/'prior_records'/name;target.parent.mkdir(parents=True,exist_ok=True)
    if not target.exists():shutil.copy2(ROOT/name,target)

cache={};checks=[]
def ident(p):
    p=Path(p)
    if not p.is_absolute():p=ROOT/p
    if str(p) not in cache:
        h=hashlib.sha256();n=0
        with p.open('rb') as f:
            while b:=f.read(4*1024**2):h.update(b);n+=len(b)
        cache[str(p)]=dict(path=str(p),bytes=n,sha256=h.hexdigest())
    return cache[str(p)]
def refs(obj,origin):
    if isinstance(obj,dict):
        if {'path','sha256'}<=obj.keys():
            actual=ident(obj['path']);fields=['sha256']+(['bytes'] if 'bytes' in obj else [])
            ok=all(obj[k]==actual[k] for k in fields)
            checks.append(dict(origin=origin,expected=obj,actual=actual,match=ok));assert ok,origin
        else:
            for k,v in obj.items():refs(v,origin+'/'+k)
    elif isinstance(obj,list):
        for i,v in enumerate(obj):refs(v,origin+'/'+str(i))
def j(p):return json.loads(Path(p).read_text())
def dt(s):return datetime.fromisoformat(s)
m=j(P/'source_manifest.json');om=j(OLD/'source_manifest.json');receipt=j(P/'receipt.json')
for name,obj in [('manifest',m),('receipt',receipt),('postrun',j(P/'postrun_verification.json'))]:refs(obj,'AT049/'+name)
assert len(m['files'])==289 and len({x['path'] for x in m['files']})==288
nonlocal_new=[x for x in m['files'] if x['role']!='new_frozen']
assert nonlocal_new==[x for x in om['files'] if x['role']!='new_frozen'] and len(nonlocal_new)==279
olds={Path(x['path']).name:x for x in om['files'] if x['role']=='new_frozen'}
news={Path(x['path']).name:x for x in m['files'] if x['role']=='new_frozen'}
changed=[];unchanged=[]
for name,entry in news.items():
    if name in olds:
        refs(olds[name],'AT048/new_frozen/'+name)
        if olds[name]['sha256']==entry['sha256']:unchanged.append(name)
        else:changed.append(name)
    else:changed.append(name)
assert set(changed)=={'run_lnq0_chain_v1.tcl','stage_ln_roms_v1.tcl','verify_lnq2_runtime_v1.py','lnq2_prefix_observe_v1.tcl'}
assert {'lnq0_chain_tb_v1.sv','laya_lnq0_source_stage_v1.sv','geglu_gate_quant_bridge_v1.sv'}<=set(unchanged)

guards=[]
for stage,seconds,gib in [('static',1800,24),('prefix',120,8),('full',3600,8)]:
    folder=P/('guard_'+stage)
    plan,result,policy=[j(folder/n) for n in ['guard_plan.json','guard_result.json','policy_checks.json']]
    assert plan['maximum_seconds']==seconds and plan['maximum_owned_rss_kb']==gib*1024**2
    assert plan['minimum_mem_available_kb']==192*1024**2 and plan['semantic_stall_seconds']==120
    assert plan['selected_cpu_ids']==[0,1,2,3]
    assert result==receipt['stages'][stage]['guard_result']
    assert result['child_exit_code']==0 and result['trigger'] is None
    assert result['minimum_mem_available_kb']>plan['minimum_mem_available_kb']
    assert result['elapsed_seconds']<seconds and result['peak_owned_rss_kb']<gib*1024**2
    assert policy and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 for x in policy)
    guards.append(dict(stage=stage,plan=plan,result=result,policy_samples=len(policy),evidence=[ident(folder/n) for n in ['guard_plan.json','guard_result.json','policy_checks.json']]))
assert sum(g['policy_samples'] for g in guards)==39
assert all(dt(a['result']['finished_at'])<dt(b['plan']['at']) for a,b in zip(guards,guards[1:]))

preflights={}
for stage in ['prefix','full']:
    pre=j(P/f'preflight_{stage}.json');refs(pre,'preflight_'+stage)
    guard=next(g for g in guards if g['stage']==stage)
    assert pre['status']=='ACCEPT' and pre['spawned'] and pre['child_exit_code']==0
    assert pre['cwd']==guard['plan']['cwd'] and Path(pre['xsimdir'])==Path(pre['cwd'])/'xsim.dir'
    assert dt(pre['checked_at'])<dt(guard['plan']['at'])
    assert len(pre['roms'])==7 and len(pre['fixtures'])==61 and len(pre['plusargs'])==10
    assert pre['plusargs']['FIXTURE']==pre['plusargs']['LN_FIXTURE']
    for rom in pre['roms']:
        assert rom['source']['sha256']==rom['target']['sha256']
        assert rom['source']['bytes']==rom['target']['bytes']
        assert Path(rom['target']['path']).parent==Path(pre['cwd'])
    assert sum(r['target']['bytes'] for r in pre['roms'])==338
    launch=j(P/f'launch_{stage}.json')['command'];child=launch[launch.index('--')+1:]
    assert child==guard['plan']['command'][guard['plan']['command'].index(child[0]):]
    assert child[1]=='lnq0_chain_tb_v1_behav'
    assert ('-runall' in child)==(stage=='full')
    preflights[stage]=pre
assert preflights['prefix']['plusargs']==preflights['full']['plusargs']
assert preflights['prefix']['cwd']==preflights['full']['cwd']
negative=j(P/'host_checks/result.json')
assert negative['spawn_calls']==0
for case in negative['cases']:
    raw_case=j(P/'host_checks'/f"{case['case']}.json")
    assert raw_case['status']==case['status'] and raw_case['spawned']==case['spawned']==False
    assert case['status']==('ACCEPT' if case['case']=='valid' else 'REJECT')
    assert case['exit_code']==(0 if case['case']=='valid' else 2)
    ident(P/'host_checks'/f"{case['case']}.json")

static=(P/'guard_static/driver.log').read_text();prefix=(P/'guard_prefix/driver.log').read_text();full=(P/'guard_full/driver.log').read_text()
assert 'LNQ0_ROM_STAGE_PASS count=7' in static and 'LNQ0_STATIC_PASS' in static
assert 'LNQ2_PREFIX_AR_R_PASS time=70 us source_AR=1 source_R=64' in prefix
for s in [prefix,full]:assert 'cannot be opened for reading' not in s and not re.search(r'^(?:Fatal:|ERROR:)',s,re.M)
for marker in ['LNQ0_CHAIN_PASS','TM4_MATRIX_RESIDENT_FULL_PASS','LNQ0_LN_SOURCE_PASS','$finish called']:
    assert full.count(marker)==1,marker
assert 'TM4_MATRIX_RESIDENT_PILOT_PASS' not in full
for key,lines in receipt['semantic_markers'].items():
    assert lines==[s for s in full.splitlines() if s.startswith(key)]
assert 'cycle=168820 scope=1 coverage=1 drained=1 status=0 bytes=16384 source=4/256 destination=4/256/4' in full
assert 'end_sample=168820 end_ack=168843 publish_ack=168898 live_scope=0 live_coverage=0 live_drained=1 destination_B=4 owner=1/1 end_status=0 publish_status=0' in full

cost=j(P/'full_cost_decision.json')
assert dt(cost['at'])<dt(guards[-1]['plan']['at'])
rate=7000/guards[1]['result']['elapsed_seconds']
forecast=(170031+206136*2.5)/rate*1.05
assert abs(rate-cost['conservative_observed_cycles_per_second'])<1e-8
assert abs(forecast-cost['forecast_wall_seconds'])<1e-7 and forecast<3600

tb=(P/'frozen_new/lnq0_chain_tb_v1.sv').read_text()
source=(P/'frozen_new/laya_lnq0_source_stage_v1.sv').read_text()
bridge=(P/'frozen_new/geglu_gate_quant_bridge_v1.sv').read_text()
for module in ['tm4tn8_matrix_resident_v2','geglu_gate_quant_bridge_v1','t4_dual_w_cache_v1','laya_lnq0_source_stage_v1']:
    assert len(re.findall(r'^\s*'+module+r'\s+(?:#|\w)',tb,re.M))==1,module
assert len(re.findall(r'^\s*quant_task_to_dual_a_v1\s+#',bridge,re.M))==1
assert tb.count('rst_n=0;')==1 and tb.count('rst_n=1;')==1
required=['source quant gold group','resident PS independent gold','resident final output gold',
          'GQD0 GATE gold','GQD0 quant gold','Q read before actual LN store',
          'LN Q grant/bridge acceptance edge mismatch','source quant response/debt consume',
          'wrong W binding not rejected','source quant held response','Wi to G switch with physical or cache debt',
          'LNQ0 final source/lease debt not closed']
for s in required:assert s in tb,s
assert "g_m_axi_rdata=ln_shared_read_data" in tb and 'destination_mem[int\'((shared_read_addr-DESTINATION_FIRST)>>2)+lane]' in source
assert tb.index('begin : final_ddr_readback')<tb.index('$display("LNQ0_CHAIN_PASS')
for s in ['393216','i>=4096 && i<4096+83968','i>=131072 && i<131072+41984','i>=262144 && i<262144+16384',
          "ddr_written[i]!==expected_written","!expected_written && ddr[i]!==8'ha5"]:assert s in tb,s
assert 393216-(83968+41984+16384)==250880
assert 65536-16384==49152

boundary=[]
for line in full.splitlines():
    if line.startswith('DOWN_MEASURE_BOUNDARIES'):
        values={k:int(v) for k,v in re.findall(r'(\w+)=(-?\d+)',line)}
        boundary.append(values)
assert len(boundary)==2
assert [(b['cfg_accept'],b['last_B'],b['first_done_valid'],b['actual_done_consume'],b['finish']) for b in boundary]==[(224172,271074,271082,271089,271090),(358881,375058,375066,375073,375074)]
assert receipt['verdict']=='PASS_SCOPED_NORMAL_FOUR_ROWS' and receipt['cold_tb_cycles']==375074
result=dict(at=datetime.now(timezone.utc).isoformat(),scope='Read-only controller audit, no DUT execution',
 references=checks,reference_count=len(checks),unique_hashed_paths=len(cache),all_references_match=True,
 manifest_rows=289,manifest_unique_paths=288,unchanged_nonlocal_references=279,changed_or_added=changed,
 unchanged_local=unchanged,guards=guards,guard_count=3,policy_samples=39,serial=True,
 preflights={s:dict(status=p['status'],roms=len(p['roms']),fixtures=len(p['fixtures']),plusargs=len(p['plusargs']),cwd=p['cwd']) for s,p in preflights.items()},
 host_checks=negative,cost_recomputed_seconds=forecast,cost_state_note='full_started=false belongs to pre-run admission; raw guard/log proves the one full ran',
 markers=receipt['semantic_markers'],matrix_boundaries=boundary,
 witness_cycles=dict(coverage=168820,END_response=168843,PUBLISH_response=168898,post_publish_sample=168899),
 storage=dict(downstream_scanned=393216,output_gold_bytes=142336,untouched_sentinel_bytes=250880,LN_local_window=65536,LN_gold_bytes=16384),
 timing=dict(cold_tb_cycles=375074,source_Q_accept_to_A_publish=169979-168901,Wi_cfg_to_consume=271089-224172,Down_cfg_to_consume=375073-358881,G_cfg_to_final_consume=375073-271094),
 caveats=['Only normal four-row diagnostic profile, external independent residual input',
          'One LN/Q/resident data path in frozen simulation hierarchy; no joint physical resource conclusion',
          'total_quant_groups=328 is second task only; source task separately128; whole sample456 groups',
          'A_fill_accept fields identify rejected probes, not legal Q/G acceptance; use explicit markers',
          'G A_publish331802 differs from post-consumption A_ready331815; held_B28225 is not standalone Down delay',
          'No entire STATE0/13BO sweep or independent readonly residual source DDR final scan',
          'No all-model, ordinary multiwindow Q/L, recovery, physical timing or board evidence'],
 verdict='PASS_SCOPED_NORMAL_FOUR_ROWS; M003/M004 remain open')
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['reference_count','unique_hashed_paths','manifest_rows','guard_count','policy_samples','verdict']},ensure_ascii=False))
