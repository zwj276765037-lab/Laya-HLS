from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re

R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
A=B/'AT014_LQ0_measurement_02';H=B/'AT015_LQ1_LN_hls_01';T=B/'AT016_LQ1_RTL_01'
def get(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
verified={}
def check(x,actual=None):
    p=actual or Path(x['path'])
    if not p.is_absolute():p=R/p
    assert p.is_file() and sha(p)==x['sha256'],str(p)
    if 'bytes' in x:assert p.stat().st_size==x['bytes'],str(p)
    verified[str(p)]={'bytes':p.stat().st_size,'sha256':sha(p)}
    return p
def refs(x):
    if isinstance(x,dict):
        if {'path','sha256'}<=x.keys():check(x)
        else:
            for k,v in x.items():
                if k not in ['previous_engine','historical_tb']:refs(v)
    elif isinstance(x,list):
        for v in x:refs(v)
am,ar=get(A/'input_manifest.json'),get(A/'receipt.json')
tm,tr=get(T/'input_manifest.json'),get(T/'receipt.json')
prior=get(R/'results/measurement_first_LQ0_review_20261013/verification.json')
for p in [A/'input_manifest.json',H/'input_manifest.json',H/'work/reports/hls_compile.rpt']:
    check({'path':str(p),**prior['verified_references'][str(p)]})
assert tr['measurement_status']=='PASS_SCOPED'
refs(tm);refs(tr)
oldroot=Path(tm['historical_source_manifest']['path']).parent
for x in tm['previous_engine']:check(x,oldroot/'frozen/external/layernorm_producer_rtl'/Path(x['path']).name)
tbrel='vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_layernorm_quant_source_shell_tb_v1.sv'
check(tm['historical_tb'],oldroot/'frozen'/tbrel)
amap={str(Path(x['path']).relative_to(A/'frozen')):x for x in am['frozen_files']}
tmap={str(Path(x['path']).relative_to(T/'frozen')):x for x in tm['frozen_files']}
assert len(amap)==153 and len(tmap)==158
outside=[k for k in set(amap)|set(tmap) if not k.startswith('external/layernorm_producer_rtl/')]
assert all(k in amap and k in tmap and amap[k]['sha256']==tmap[k]['sha256'] for k in outside)
assert sha(A/'frozen'/tbrel)==sha(T/'frozen'/tbrel)
gmap={Path(x['path']).name:x for x in tm['candidate_engine']}
installed={Path(x['path']).name:x for x in tm['installed_engine']}
assert len(gmap)==len(installed)==88 and set(gmap)==set(installed)
assert all(gmap[k]['sha256']==installed[k]['sha256'] for k in gmap)
assert set(gmap)=={p.name for p in (H/'work/hls/syn/verilog').iterdir() if p.suffix in ['.v','.dat','.tcl']}
assert tm['selected_header']['sha256']==tm['candidate_engine_header']['sha256']
for key in ['fixture_files','pilot_fixture_files']:
    a={Path(x['path']).name:(x['sha256'],x['bytes']) for x in am[key]}
    t={Path(x['path']).name:(x['sha256'],x['bytes']) for x in tm[key]}
    assert a==t and len(t)==17
ipold={Path(x['path']).name:x['sha256'] for x in ar['native_ip']}
ipnew={Path(x['path']).name:x['sha256'] for x in tr['native_ip']}
assert len(ipold)==7 and len(ipnew)==9 and all(ipnew[k]==v for k,v in ipold.items())
for x in tr['native_ip']:
    if Path(x['path']).name not in ipold:
        native=Path(x['path']).read_text()
        assert re.search(r'"C_Latency"\s*:\s*\[\s*\{\s*"value"\s*:\s*"0"',native)
        assert re.search(r'"Has_ACLKEN"\s*:\s*\[\s*\{\s*"value"\s*:\s*"false"',native)
assert len(tr['runtime_dat_staging'])==7
assert all(x['source']['sha256']==x['staged']['sha256'] for x in tr['runtime_dat_staging'])
def metrics(p):
    log=p.read_text();assert not re.search(r'^(?:ERROR|Error|FATAL|Fatal):',log,re.M)
    result={}
    for line in log.splitlines():
        if line.startswith(('LQ0_','FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS')):
            result[line.split()[0]]={k:[int(z) for z in v.split(',')] if ',' in v else int(v) for k,v in re.findall(r'(\w+)=([\d,-]+)',line)}
    return result
base,cur=metrics(A/'full_sim.log'),metrics(T/'full_sim.log')
for n,m in [('LQ0',base),('LQ1',cur)]:
    e=m['LQ0_EVENT'];assert sum(e['phase'+str(i)] for i in range(6))==e['cycles']
    p=m['FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS']
    assert [p[k] for k in ['rows','D','gold_elements','source_AR','source_R','destination_AW','destination_W','destination_B','store_bytes','quant_AR','quant_R','fullA_groups']]==[16,1024,16384,16,1024,16,1024,16,65536,16,1024,128]
    assert e['cycles']==m['LQ0_LIFECYCLE']['zero_debt']==p['cycles']
def spans(m):
    e,ax,l=m['LQ0_EVENT'],m['LQ0_AXI'],m['LQ0_LIFECYCLE']
    return {'TB':e['cycles'],'LN_run':ax['math_done'][1]-ax['math_start'][0],'Q_accept_to_consume':e['q_consume']-e['q_accept'],'fullA':l['fulla_last_check']-l['fulla_acquire']}
s0,s1=spans(base),spans(cur)
assert list(s0.values())==[659334,649380,3267,512]
assert list(s1.values())==[528307,518354,3266,512]
comparison={k:{'LQ0':s0[k],'LQ1':s1[k],'delta':s1[k]-s0[k],'reduction_percent':100*(s0[k]-s1[k])/s0[k]} for k in s0}
guards=[];policy=[]
for phase in ['static','pilot','full']:
    p=T/('guard_'+phase);g=get(p/'guard_result.json');launch=get(p/'launch.json');plan=get(p/'guard_plan.json');pol=get(p/'policy_checks.json')
    assert tr[phase]['guard']==g and tr[phase]['status']=='PASS'
    assert g['child_exit_code']==0 and g['trigger'] is None
    assert g['elapsed_seconds']<plan['maximum_seconds'] and g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb']
    assert plan['semantic_stall_seconds']==120 and g['minimum_mem_available_kb']>201326592
    assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
    guards.append({'phase':phase,'start':launch['at'],'end':g['finished_at'],**g,'policy_count':len(pol)});policy.extend(pol)
assert all(datetime.fromisoformat(x['end'])<=datetime.fromisoformat(y['start']) for x,y in zip(guards,guards[1:]))
gen=H/'work/hls/syn/verilog';prefix='laya_layernorm_producer_engine_'
timing=[]
for fname,lat in [('fsub_32ns_32ns_32_1_full_dsp_1',0),('fmul_32ns_32ns_32_1_max_dsp_1',0),('faddfsub_32ns_32ns_32_4_full_dsp_1',2),('fmul_32ns_32ns_32_3_max_dsp_1',1)]:
    p=gen/(prefix+fname+'_ip.tcl');s=p.read_text()
    assert re.search(r'CONFIG.c_latency\s+'+str(lat)+r'\b',s)
    if lat==0:
        assert 'CONFIG.has_aclken false' in s
        wrapper=(gen/(prefix+fname+'.v')).read_text()
        assert not re.search(r'input\s+(?:wire\s+)?(?:clk|ce|reset)\b',wrapper)
    timing.append({'path':str(p),'sha256':sha(p),'native_core_c_latency':lat})
sched=H/'work/hls/.autopilot/db/layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7.verbose.sched.rpt'
flow=H/'work/hls/.autopilot/db/autopilot.flow.log'
assert '<State 3>: 53.626ns' in sched.read_text()
assert 'Target II = 1, Final II = 2, Depth = 3' in flow.read_text()
assert 'combination delay: 51.165 ns' in flow.read_text()
details={'schedule':{'path':str(sched),'sha256':sha(sched)},'flow':{'path':str(flow),'sha256':sha(flow)},'native_core_configs':timing,'II':2,'schedule_delay_ns':53.626,'effective_budget_ns':4.867,'slack_report_ns':-48.76,'II2_unique_cause':'UNKNOWN'}
out={'schema':'controller-LQ1-readonly-review-v1','at':datetime.now(timezone.utc).isoformat(),'dut_tools_run':False,'status':'PASS_SCOPED_NUMERICAL_AND_CYCLES_TIMING_NOT_ACCEPTED','frozen_files':158,'generated_files':88,'non_engine_files_identical_to_LQ0':len(outside),'observation_TB_identical':True,'full_fixture_files':17,'pilot_fixture_files':17,'native_IP_unchanged':7,'native_IP_added':2,'staged_DAT_pairs':7,'source_scope_inherited_from':'results/measurement_first_LQ0_review_20261013/verification.json','metrics':{'LQ0':base,'LQ1':cur},'comparison':comparison,'guards':guards,'serial':True,'policy_records':len(policy),'timing':details,'unique_references':len(verified),'verified_references':verified}
(D/'verification.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k not in ['verified_references','metrics','timing']},ensure_ascii=False,indent=2))
