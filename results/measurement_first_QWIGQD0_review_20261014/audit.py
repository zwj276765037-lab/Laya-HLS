from pathlib import Path
import hashlib, json, re, shutil, difflib, ast
from datetime import datetime, timezone

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
names=['AT033_QWIGQD0_chain_01','AT034_QWIGQD0_chain_02']
for n in ['mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md',
          'results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md',
          'agent/A001/result.md','agent/A001/state.json','NEW_CHAT_START.md']:
    p=OUT/'prior_records'/n;p.parent.mkdir(parents=True,exist_ok=True)
    if not p.exists():shutil.copy2(ROOT/n,p)
cache={};checks=[];attempts={};guards=[];maps={}
def ident(p):
    p=Path(p)
    if str(p) not in cache:
        b=p.read_bytes();cache[str(p)]={'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
    return cache[str(p)]
def refs(v,origin):
    if isinstance(v,dict):
        if {'path','bytes','sha256'}<=v.keys():
            a=ident(v['path']);checks.append({'origin':origin,'expected':v,'actual':a,
              'match':v['bytes']==a['bytes'] and v['sha256']==a['sha256'],
              'live':str(ROOT/'project/E002_Laya_HLS/experiment') in a['path'] and '/results/' not in a['path']})
        else:
            for k,x in v.items():refs(x,origin+'/'+k)
    elif isinstance(v,list):
        for i,x in enumerate(v):refs(x,origin+'/'+str(i))
for name in names:
    p=RUN/'attempts'/name;m=json.loads((p/'input_manifest.json').read_text());r=json.loads((p/'receipt.json').read_text())
    refs(m,name+'/manifest');refs(r,name+'/receipt')
    maps[name]={str(Path(x['frozen']['path']).relative_to(p)):x['frozen']['sha256'] for x in m['files']}
    attempts[name]={'manifest_rows':len(m['files']),'distinct_frozen_paths':len(maps[name]),'status':r['status'],
                    'manifest':ident(p/'input_manifest.json'),'receipt':ident(p/'receipt.json')}
    for phase,info in r['phases'].items():
        g=p/('guard_'+phase);plan=json.loads((g/'guard_plan.json').read_text());result=json.loads((g/'guard_result.json').read_text())
        launch=json.loads((g/'launch.json').read_text());policy=json.loads((g/'policy_checks.json').read_text())
        assert result==info['guard']
        assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 for x in policy)
        assert plan['maximum_seconds']=={'static':1800,'pilot':120,'full':3600}[phase]
        assert plan['maximum_owned_rss_kb']==(24 if phase=='static' else 8)*1024*1024
        assert plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==192*1024*1024
        guards.append({'attempt':name,'phase':phase,'start':launch['at'],'end':result['finished_at'],'result':result,'policy_count':len(policy),
                       'files':[ident(g/x) for x in ['launch.json','guard_plan.json','guard_result.json','policy_checks.json']]})
guards.sort(key=lambda g:g['start'])
assert all(datetime.fromisoformat(a['end'])<=datetime.fromisoformat(b['start']) for a,b in zip(guards,guards[1:]))
diff=[k for k in maps[names[0]] if maps[names[0]][k]!=maps[names[1]].get(k)]
assert sorted(diff)==['frozen/tools/run_qwigqd0_chain.py','frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv']
new=RUN/'attempts'/names[1];old=RUN/'attempts'/names[0];base=RUN/'attempts/AT032_WIGQD1_observation_01'
bn='frozen/vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv'
tn='frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv'
bridge=(new/bn).read_text();tb=(new/tn).read_text();raw=(new/'raw_full.log').read_text()
assert bridge==(old/bn).read_text()
(OUT/'bridge_diff.txt').write_text(''.join(difflib.unified_diff((base/bn).read_text().splitlines(True),bridge.splitlines(True),fromfile='AT032',tofile='AT034')))
(OUT/'repair_TB_diff.txt').write_text(''.join(difflib.unified_diff((old/tn).read_text().splitlines(True),tb.splitlines(True),fromfile='AT033',tofile='AT034')))
assert raw.count('QWIGQD0_CHAIN_PASS')==1 and 'Fatal:' not in raw
assert 'Fatal: GQD0 bridge completion/physical debt' in (old/'raw_full.log').read_text()
markers=[x for x in raw.splitlines() if x.startswith(('DOWN_MEASURE_BOUNDARIES','DOWN_MEASURE_STATES','QWIGQD0_CHAIN_PASS','QWIGQD0_G_COUNTERS','WIGQD_BOUNDARIES','WIGQD_WI_COMPLETE'))]
state_sums=[sum(map(int,re.findall(r'\bs\d+=(\d+)',x))) for x in markers if x.startswith('DOWN_MEASURE_STATES')]
assert state_sums==[46910,16186]
guard=(new/'frozen/tools/production_guard.py').read_text()
node=next(x for x in ast.walk(ast.parse(guard)) if isinstance(x,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='semantic_pattern' for t in x.targets))
pattern=re.compile(ast.literal_eval(node.value.args[0]),re.I)
diags=[x for x in raw.splitlines() if x.startswith('WIGQD_DIAG')]
assert all(not pattern.search(x) for x in diags)
up=ROOT/'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts'
f=up/'t2_widown_av_fixtures_01/work/fixtures';cap=up/'t2_widown_av_capture_run_01/work/capture/t2_enc0_ln_ffn_source.f32.bin'
src=f/'wi_rows4_source_f32.bin';q=f/'wi_rows4_a8_q.bin';scale=f/'wi_rows4_a8_scale.bin'
assert cap.read_bytes()[:16384]==src.read_bytes()
assert ident(cap)['sha256']=='6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863'
assert b''.join(int(x,16).to_bytes(32,'little') for x in (new/'work/fixtures/wi_a/q.mem').read_text().split())==q.read_bytes()
assert b''.join(int(x,16).to_bytes(2,'little') for x in (new/'work/fixtures/wi_a/scale.mem').read_text().split())==scale.read_bytes()
source_hex=next(x for x in json.loads((new/'input_manifest.json').read_text())['files'] if x['role']=='LN_FFN_source_bytes')
assert bytes(int(x,16) for x in Path(source_hex['frozen']['path']).read_text().split())==src.read_bytes()
truth=[]
for g in [False,True]:
    for e in [False,True]:
        truth.append({'G_valid':g,'ext_valid':e,'idle_G_ready':not e,'idle_ext_ready':not g,
                      'accept_G':g and not e,'accept_ext':e and not g})
result={'scope':'controller read-only audit; no DUT tools','at':datetime.now(timezone.utc).isoformat(),
        'attempts':attempts,'references':checks,'reference_count':len(checks),'unique_reference_paths':len({x['actual']['path'] for x in checks}),
        'immutable_mismatches':[x for x in checks if not x['match'] and not x['live']],
        'live_mismatches':[x for x in checks if not x['match'] and x['live']],
        'changed_paths':diff,'guard_count':len(guards),'policy_count':sum(x['policy_count'] for x in guards),'guards':guards,
        'AT034_guard_count':3,'AT034_policy_count':sum(x['policy_count'] for x in guards if x['attempt']==names[1]),
        'raw_markers':markers,'state_sums':state_sums,'diagnostics_match_guard':False,
        'timing':{'whole_TB':206133,'Q_accept_to_A_publish':1101-23,'Wi_cfg_to_consume':102153-55236,
                  'G_cfg_to_final_consume':206132-102158,'Down_cfg_to_first_done':206125-189939,'Down_cfg_to_consume':206132-189939},
        'DDR':{'total':393216,'source_read_only':16384,'outputs':142336,'sentinel':234496},
        'source_identities':[ident(x) for x in [cap,src,q,scale,Path(source_hex['frozen']['path'])]],
        'new_static_findings':{'idle_truth_table_assuming_other_ready_and_no_debt':truth,
          'both_valid_no_accept':'Both valids held high inhibit both ready outputs; no registered state changes can select a request in idle.',
          'observed_dynamic_deadlock':False,'AT034_source_P_Q_opcodes':['0x60','0x61'],
          'task_schema_LN_FFN_QUANT':['0x12','0x20'],'scope':'normal numeric/key-bound sample only; not production producer identity'},
        'evidence':[ident(x) for x in [new/bn,new/tn,new/'raw_full.log',new/'verification.json',new/'source_identity_check.json',
          ROOT/'project/E002_Laya_HLS/experiment/include/laya_tasks.h',RUN/'reports/QWIGQD0_integration_result_20261014.md',RUN/'reports/QWIGQD0_connection_map_20261014.md']]}
assert not result['immutable_mismatches']
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['reference_count','unique_reference_paths','changed_paths','guard_count','policy_count','AT034_policy_count','state_sums','timing']},ensure_ascii=False))
print('live drift',[(x['origin'],x['actual']['path']) for x in result['live_mismatches']])
