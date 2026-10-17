"""Read-only review of frozen FFN1 inputs and existing results; no simulator."""
from pathlib import Path
import datetime as dt
import difflib
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
A = BASE / 'AT058_FFN1_progress_replay_01'
B = BASE / 'AT059_FFN1_progress_replay_02'
P = BASE / 'AT057_FFN0_single_runtime_03'
seen = {}

def identity(path):
    p = Path(path).resolve()
    if str(p) not in seen:
        h = hashlib.sha256()
        with p.open('rb') as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b''):
                h.update(block)
        seen[str(p)] = {'path': str(p), 'bytes': p.stat().st_size, 'sha256': h.hexdigest()}
    return seen[str(p)]

def read(path):
    identity(path)
    return json.loads(Path(path).read_text())

def save(name, value):
    (OUT / name).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n')

records = ['mission/current.md', 'goal/goal.md', 'results/overview.md',
           'results/hardware_metrics.md', 'results/hardware_progress.md',
           'results/review_queue.md', 'results/reviews/SM005.md',
           'project/missions/SM005.md', 'agent/A001/result.md',
           'agent/A001/state.json', 'NEW_CHAT_START.md']
before = []
for rel in records:
    before.append(identity(ROOT / rel))
    dest = OUT / 'prior_records' / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    if not dest.exists():
        shutil.copyfile(ROOT / rel, dest)
save('records_before.json', before)

manifests = []
for attempt in [A, B]:
    m = read(attempt / 'source_manifest.json')['files']
    failures = [e for e in m if any(identity(e['path'])[k] != e[k] for k in ['bytes','sha256'])]
    assert not failures, failures
    manifests.append({'attempt': attempt.name, 'references': len(m),
                      'unique_paths': len({e['path'] for e in m}), 'mismatches': failures})

diffs = []
for folder in ['frozen_new', 'frozen_ffn']:
    for p in sorted((A / folder).glob('*')):
        if not p.is_file():
            continue
        q = B / folder / p.name
        same = identity(p)['sha256'] == identity(q)['sha256']
        if not same:
            (OUT / 'diffs').mkdir(exist_ok=True)
            dest = OUT / 'diffs' / (p.name + '.diff')
            dest.write_text(''.join(difflib.unified_diff(p.read_text().splitlines(True), q.read_text().splitlines(True), fromfile=str(p), tofile=str(q))))
        diffs.append({'file': folder + '/' + p.name, 'equal': same})
assert {x['file'] for x in diffs if not x['equal']} == {'frozen_new/run_ffn1_v1.py','frozen_new/ffn1_progress_observer_micro_tb_v1.sv'}
functional = []
for folder, names in [('frozen_ffn', [p.name for p in (B/'frozen_ffn').glob('*.sv')]),
                      ('frozen_new', ['laya_ffn0_source_stage_v1.sv','geglu_gate_quant_bridge_v1.sv',
                       'laya_lnq0_external_quant_admission_v1.sv','laya_lnq0_bound_identity_generated_v1.sv','laya_lnq0_w_binding_v1.sv'])]:
    for name in names:
        eq = identity(P/folder/name)['sha256'] == identity(B/folder/name)['sha256']
        functional.append({'file': folder+'/'+name, 'matches_AT057':eq})
assert all(x['matches_AT057'] for x in functional)
for name in ['ffn0_chain_tb_v1.sv']:
    old=P/'frozen_new'/name;new=B/'frozen_new'/name
    identity(old);identity(new)
    (OUT/'diffs'/('AT057_to_AT059_'+name+'.diff')).write_text(''.join(difflib.unified_diff(old.read_text().splitlines(True),new.read_text().splitlines(True),fromfile=str(old),tofile=str(new))))

guards = []
for attempt, phases in [(A,['static','micro','negative','wrapper']),(B,['micro','pilot'])]:
    for phase in phases:
        directory = attempt / ('guard_'+phase)
        result=read(directory/'guard_result.json');plan=read(directory/'guard_plan.json')
        policy=read(directory/'policy_checks.json');identity(directory/'driver.log')
        ok=all(p['affinity']==[0,1,2,3] and p['nice']==19 and p['ionice']=='idle' and p['ionice_exit']==0 and p['matches'] for p in policy)
        assert ok
        lines=(directory/'driver.log').read_text(errors='replace').splitlines()
        markers=[l for l in lines if re.match(r'^(FFN\w*_(?:.*PASS|.*FAIL)|Fatal:|ERROR:|\$finish)',l)]
        guards.append({'attempt':attempt.name,'phase':phase,'result':result,'plan_at':plan['at'],
                       'plan_command':plan['command'],'cwd':plan['cwd'],'policy_samples':len(policy),'policy_match':ok,'markers':markers})
ordered=sorted(guards,key=lambda x:x['plan_at'])
assert all(a['result']['finished_at']<=b['plan_at'] for a,b in zip(ordered,ordered[1:]))

host=read(B/'guard_host_test.json')
micro=(B/'guard_micro/driver.log').read_text()
line=next(l for l in micro.splitlines() if l.startswith('FFN1_PROGRESS '))
fields=dict((k,int(v)) for k,v in (s.split('=') for s in line.split()[1:]))
assert len(fields)==36 and fields['work']==38 and sum(v for k,v in fields.items() if k!='work')==38
assert all(v==(2 if k in ['w0r','w1r','wsr'] else 1) for k,v in fields.items() if k!='work')
assert host['case_count']==12 and host['verdict']=='PASS'
assert any(e['line']==line for c in host['cases'] for e in c['events'])
oldlog=P/'guard_full/driver.log';identity(oldlog)
w=[tuple(map(int,m.groups())) for m in re.finditer(r'^MATRIX_PROGRESS cycle=(\d+) stage=0 W_q0_R=(\d+) W_q1_R=(\d+) W_scale_R=(\d+)$',oldlog.read_text(),re.M)]
records=host['old_w_readonly_replay']['observed_samples']
assert w==[(x['original_cycle'],x['q0_R'],x['q1_R'],x['scale_R']) for x in records] and len(w)==52

runtime=[]
for attempt, phase, filename in [(A,'work_static','runtime_preflight.json'),(B,None,'poststop_readonly_preflight.json')]:
    record=read(attempt/phase/filename if phase else attempt/filename)
    assert record['status']=='ACCEPT'
    m=read(attempt/'source_manifest.json')['files']
    roms=[e for e in m if e['role']=='LN_frozen' and e['path'].endswith('ROM_AUTO_1R.dat')]
    assert len(roms)==7
    for e in roms:
        actual=identity(Path(record['cwd'])/Path(e['path']).name)
        assert actual['bytes']==e['bytes'] and actual['sha256']==e['sha256']
    assert record['fixtures']==63 and len(record['roots'])==11 and record['roots']['FIXTURE']==record['roots']['LN_FIXTURE']
    runtime.append({'record':filename,'cwd':record['cwd'],'roms_rechecked':7,'fixture_refs':63,'roots':11,'checked_at':record['checked_at']})
for attempt in [A,B]:
    for name,verdict in [('intact','ACCEPT'),('missing_rom','REJECT'),('corrupt_rom','REJECT')]:
        d=read(attempt/('preflight_'+name+'.json'))
        assert d['status']==verdict and d['spawned'] is False
candidate=read(B/'direct_xsim_candidate_readonly.json')
actual=identity(candidate['snapshot'])
assert actual['bytes']==candidate['snapshot_bytes'] and actual['sha256']==candidate['snapshot_sha256']
assert identity(candidate['prefix_tcl'])['sha256']==candidate['prefix_tcl_sha256']
decision=read(B/'full_cost_decision.json')
assert decision['admit'] is False and decision['full_started'] is False
assert not (B/'work_pilot/runtime_preflight.json').exists()
assert not (B/'launch_full.json').exists() and not (B/'guard_full').exists()
pilot=(B/'guard_pilot/driver.log').read_text()
assert 'LNQ0_ROM_STAGE_PASS count=7' in pilot
assert all(s not in pilot for s in ['FFN0_SIM_START','FFN1_PROGRESS work=','FFN0_PREFIX_PILOT_PASS','FFN0_CHAIN_PASS'])
assert runtime[1]['checked_at']>guards[-1]['result']['finished_at']
save('verification.json', {'at':dt.datetime.now(dt.timezone.utc).isoformat(),
 'verdict':'COST_NOT_ADMITTED_INVALID_PREFIX_LAUNCH','manifests':manifests,
 'local_diff':diffs,'AT057_functional_local_comparison':functional,'guards':ordered,
 'serial':True,'total_policy_samples':sum(x['policy_samples'] for x in guards),
 'host_case_count':12,'host_scope':'same parser plus modeled logical-time loop; no owned-process runtime simulation',
 'micro_fields':fields,'old_W_samples_matched':52,'runtime':runtime,
 'snapshot_candidate_identity':actual,'candidate_executed':False,
 'pilot_runtime_preflight_absent':True,'full_started':False,
 'evidence_identities':list(seen.values())})
print(json.dumps({'manifests':manifests,'policies':sum(x['policy_samples'] for x in guards),
                  'evidence_paths':len(seen),'guards':len(guards),'serial':True,
                  'changed_local_files':[x['file'] for x in diffs if not x['equal']]},ensure_ascii=False))
