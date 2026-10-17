from pathlib import Path
import ast
import hashlib
import json
import re
import shutil
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUN = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001'
NEW = RUN / 'attempts/AT032_WIGQD1_observation_01'
OLD = RUN / 'attempts/AT031_WIGQD0_chain_03'
for name in ['mission/current.md','results/overview.md','results/hardware_metrics.md',
             'results/hardware_progress.md','results/review_queue.md','results/reviews/SM005.md',
             'project/missions/SM005.md','agent/A001/result.md','agent/A001/state.json','NEW_CHAT_START.md']:
    p = OUT / 'prior_records' / name
    p.parent.mkdir(parents=True, exist_ok=True)
    if not p.exists():
        shutil.copy2(ROOT / name, p)

cache = {}
checks = []
def ident(p):
    p = Path(p)
    if str(p) not in cache:
        b = p.read_bytes()
        cache[str(p)] = {'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
    return cache[str(p)]

def refs(v, origin):
    if isinstance(v,dict):
        if {'path','bytes','sha256'} <= v.keys():
            a=ident(v['path'])
            checks.append({'origin':origin,'expected':v,'actual':a,'match':v['bytes']==a['bytes'] and v['sha256']==a['sha256']})
        else:
            for k,x in v.items(): refs(x,origin+'/'+k)
    elif isinstance(v,list):
        for i,x in enumerate(v): refs(x,origin+'/'+str(i))

m=json.loads((NEW/'input_manifest.json').read_text())
o=json.loads((OLD/'input_manifest.json').read_text())
receipt=json.loads((NEW/'receipt.json').read_text())
regex_check=json.loads((NEW/'diagnostic_regex_check.json').read_text())
for n,v in [('manifest',m),('receipt',receipt),('diagnostic_regex_check',regex_check)]: refs(v,n)
changed=[i for i,x in enumerate(o['files']) if x['frozen']['sha256']!=m['files'][i]['frozen']['sha256']]
assert changed==[57] and len(m['files'])==103 and m['files'][-1]['role']=='WIGQD1_runner'
tb_rel='frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv'
oldtb=(OLD/tb_rel).read_text(); newtb=(NEW/tb_rel).read_text()
begin=newtb.index('  // WIGQD1: passive, bounded observation')
end=newtb.index('  logic g_aw_seen=0',begin)
assert newtb[:begin]+newtb[end:]==oldtb
(OUT/'observer_splice.sv.txt').write_text(newtb[begin:end])
guard=(NEW/'frozen/tools/production_guard.py').read_text()
node=next(n for n in ast.walk(ast.parse(guard)) if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='semantic_pattern' for t in n.targets))
pattern=re.compile(ast.literal_eval(node.value.args[0]),re.IGNORECASE)
raw=(NEW/'raw_full.log').read_text()
diags=[x for x in raw.splitlines() if x.startswith('WIGQD_DIAG')]
assert diags and all(not pattern.search(x) for x in diags+regex_check['diagnostic_templates']+regex_check['representative_diagnostics'])
assert all(pattern.search(x) for x in regex_check['progress_templates'])
progress={}
for x in raw.splitlines():
    match=re.match(r'MATRIX_PROGRESS cycle=(\d+) stage=1 kind=(\w+) n=(\d+)',x)
    if match:
        cycle,kind,count=match.groups()
        progress.setdefault(kind,[]).append({'cycle':int(cycle),'n':int(count)})
assert all(all(b['n']>a['n'] for a,b in zip(xs,xs[1:])) for xs in progress.values())
assert progress['a_publish']==[{'cycle':162045,'n':1}]
assert [x['cycle'] for x in progress['wi_row']]==[106944,121440,135936,150435]
assert raw.count('WIGQD0_CHAIN_PASS')==1 and raw.count('WIGQD_WI_COMPLETE')==1
assert not re.search(r'\b(?:ERROR|FATAL)\b',raw)
boundaries=[x for x in raw.splitlines() if x.startswith(('WIGQD_BOUNDARIES','DOWN_MEASURE_BOUNDARIES','DOWN_MEASURE_STATES','WIGQD0_CHAIN_PASS','TM4_MATRIX_RESIDENT_FULL_PASS'))]
state_sums=[sum(map(int,re.findall(r'\bs\d+=(\d+)',x))) for x in boundaries if x.startswith('DOWN_MEASURE_STATES')]
assert state_sums==[46911,16184]
guards=[]
for phase,phase_data in receipt['phases'].items():
    p=NEW/('guard_'+phase)
    launch=json.loads((p/'launch.json').read_text());result=json.loads((p/'guard_result.json').read_text())
    plan=json.loads((p/'guard_plan.json').read_text());policy=json.loads((p/'policy_checks.json').read_text())
    assert result==phase_data['guard'] and result['child_exit_code']==0 and result['trigger'] is None
    assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 for x in policy)
    assert plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==192*1024*1024
    assert plan['maximum_seconds']=={'static':1800,'pilot':120,'full':3600}[phase]
    assert plan['maximum_owned_rss_kb']==(24 if phase=='static' else 8)*1024*1024
    guards.append({'phase':phase,'start':launch['at'],'end':result['finished_at'],'result':result,'policy_count':len(policy),
                   'files':[ident(p/n) for n in ['launch.json','guard_result.json','guard_plan.json','policy_checks.json']]})
guards.sort(key=lambda x:x['start'])
assert all(datetime.fromisoformat(a['end'])<=datetime.fromisoformat(b['start']) for a,b in zip(guards,guards[1:]))

up=ROOT/'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts'
f=up/'t2_widown_av_fixtures_01/work/fixtures'
cap=up/'t2_widown_av_capture_run_01/work/capture/t2_enc0_ln_ffn_source.f32.bin'
source=f/'wi_rows4_source_f32.bin';q=f/'wi_rows4_a8_q.bin';scale=f/'wi_rows4_a8_scale.bin'
qa=NEW/'work/fixtures/wi_a/q.mem';sa=NEW/'work/fixtures/wi_a/scale.mem'
assert cap.read_bytes()[:16384]==source.read_bytes()
assert b''.join(int(x,16).to_bytes(32,'little') for x in qa.read_text().split())==q.read_bytes()
assert b''.join(int(x,16).to_bytes(2,'little') for x in sa.read_text().split())==scale.read_bytes()
result={'scope':'read-only controller review; no DUT tools','at':datetime.now(timezone.utc).isoformat(),
        'manifest_rows':len(m['files']),'unique_frozen_paths':len({x['frozen']['path'] for x in m['files']}),
        'reference_count':len(checks),'unique_reference_paths':len({x['actual']['path'] for x in checks}),
        'mismatches':[x for x in checks if not x['match']],'references':checks,'AT031_changed_rows':changed,
        'observer_splice_only':True,'actual_diagnostic_lines':len(diags),'diagnostics_match_guard':False,
        'progress_kinds':len(progress),'progress':progress,'raw_boundaries':boundaries,'Wi_Down_state_sums':state_sums,
        'guard_count':len(guards),'policy_count':sum(x['policy_count'] for x in guards),'guards':guards,
        'DDR':{'total_bytes':327680,'Wi':83968,'GATE':41984,'Down':16384,'guard_bytes':185344,
               'evidence':'unchanged final readback loop lines1724-1742 before observed CHAIN_PASS'},
        'timing':{'whole_TB':205314,'G_cfg_to_TB_end':205314-101339,'G_cfg_to_Down_consume':205313-101339,
                  'G_cfg_to_new_A_publish':162045-101339,'Down_cfg_to_first_done':205306-189122,
                  'Down_cfg_to_consume':205313-189122},
        'next_input_identity':{'full_source_first4_match':True,'AT032_q_scale_decoded_match':True,
                               'files':[ident(x) for x in [cap,source,q,scale,qa,sa]]},
        'evidence':[ident(x) for x in [NEW/'receipt.json',NEW/'verification.json',NEW/'raw_full.log',NEW/tb_rel,
                                     RUN/'reports/WIGQD1_observation_result_20261013.md',RUN/'reports/WIGQD1_upstream_LN_identity_addendum_20261013.md']]}
assert not result['mismatches']
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['manifest_rows','unique_frozen_paths','reference_count','unique_reference_paths','actual_diagnostic_lines','progress_kinds','guard_count','policy_count','timing']},ensure_ascii=False))
