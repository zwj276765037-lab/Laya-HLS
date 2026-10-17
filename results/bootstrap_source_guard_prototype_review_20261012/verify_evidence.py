from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUNS = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p): return json.loads(Path(p).read_text())
snapshots, pairs, refs, attempts, history, diffs = [], [], [], {}, {}, []
def snap(p):
    p = Path(p)
    t = OUT / 'snapshot' / p.relative_to(ROOT)
    t.parent.mkdir(parents=True, exist_ok=True)
    if not t.exists(): shutil.copyfile(p, t)
    assert sha(t) == sha(p), str(p)
    snapshots.append({'path': str(t.relative_to(ROOT)), 'sha256': sha(t)})
def walk(x, origin):
    if isinstance(x, dict):
        if isinstance(x.get('path'), str) and isinstance(x.get('sha256'), str):
            p = Path(x['path']); actual = sha(p) if p.is_file() else None
            refs.append({'origin': origin, 'path': str(p), 'expected': x['sha256'], 'actual': actual, 'match': actual == x['sha256']})
        for v in x.values(): walk(v, origin)
    elif isinstance(x, list):
        for v in x: walk(v, origin)

names = ['bootstrap_source_guard_rtl_04', 'bootstrap_snapshot_rtl_04', 'generated_store_monitor_12']
for name in names:
    base = RUNS / name; m = read(base / 'input_manifest.json'); r = read(base / 'receipt.json')
    for e in m['files'] + ([m['contract']] if 'contract' in m else m.get('contracts', [])):
        a, b = e['original'], e['frozen']; current = sha(a['path'])
        pairs.append({'attempt': name, 'path': a['path'], 'declared': a['sha256'], 'current': current, 'current_match': current == a['sha256'], 'frozen_match': sha(b['path']) == b['sha256'], 'declared_pair_match': a['sha256'] == b['sha256']})
        if Path(b['path']).suffix in ('.sv', '.py', '.tcl', '.json'): snap(b['path'])
        if current != a['sha256']: snap(a['path'])
    for kind, x in [('manifest', m), ('receipt', r)]: walk(x, name + '/' + kind)
    for f in ['input_manifest.json', 'receipt.json', 'launcher.json']: snap(base / f)
    gd = base / 'guard'; plan = read(gd / 'guard_plan.json'); result = read(gd / 'guard_result.json'); policy = read(gd / 'policy_checks.json'); log = (gd / 'driver.log').read_text()
    for f in ['guard_plan.json', 'guard_result.json', 'policy_checks.json', 'launch.json', 'driver.log']: snap(gd / f)
    attempts[name] = {'status': r['status'], 'scope': r['scope'], 'guard_result': result, 'plan': plan, 'launcher': read(base / 'launcher.json'), 'policy_count': len(policy), 'policy_ok': all(x['matches'] and x['affinity'] == [0,1,2,3] and x['nice'] == 19 and x['ionice'] == 'idle' for x in policy), 'budget_ok': result['elapsed_seconds'] <= plan['maximum_seconds'] and result['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb'] and result['minimum_mem_available_kb'] >= plan['minimum_mem_available_kb'], 'receipt_guard_equal': r['guard_result'] == result, 'markers': r['marker'], 'markers_in_raw_log': all(x in log and x.startswith('FULL_CURRENT_') for x in r['marker'])}

for n in ['bootstrap_source_guard_rtl_01','bootstrap_source_guard_rtl_02','bootstrap_source_guard_rtl_03']:
    b = RUNS / n; r = read(b / 'receipt.json'); log = (b / 'guard/driver.log').read_text()
    history[n] = {'status': r['status'], 'guard': r['guard_result'], 'fatal_lines': [x for x in log.splitlines() if x.startswith('Fatal:')], 'runtime_pass_lines': [x for x in log.splitlines() if x.startswith('FULL_CURRENT_BOOTSTRAP_SOURCE_GUARD_RTL_PASS')]}
    for f in ['input_manifest.json','receipt.json','guard/driver.log']: snap(b / f)

for old, new in [('bootstrap_source_guard_rtl_01','bootstrap_source_guard_rtl_02'), ('bootstrap_source_guard_rtl_02','bootstrap_source_guard_rtl_03'), ('bootstrap_source_guard_rtl_03','bootstrap_source_guard_rtl_04'), ('bootstrap_snapshot_rtl_03','bootstrap_snapshot_rtl_04'), ('generated_store_monitor_11','generated_store_monitor_12')]:
    aa = {x['original']['path']: x for x in read(RUNS / old / 'input_manifest.json')['files']}
    bb = {x['original']['path']: x for x in read(RUNS / new / 'input_manifest.json')['files']}
    changed = []
    for f in sorted(aa.keys() & bb.keys()):
        a, b = aa[f]['frozen'], bb[f]['frozen']
        if a['sha256'] != b['sha256']:
            changed.append(f)
            t = OUT / 'diff' / (old + '__' + new) / (Path(f).name + '.diff'); t.parent.mkdir(parents=True, exist_ok=True)
            t.write_text(''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True), Path(b['path']).read_text().splitlines(True), fromfile=old+'/'+Path(f).name, tofile=new+'/'+Path(f).name)))
    diffs.append({'old':old, 'new':new, 'common_files':len(aa.keys() & bb.keys()), 'changed':changed})

rows = [
('bootstrap_source_guard_rtl_04','28438580a99e3d7ac4f3427a608ebb11c4ac3d07c6230bd4b8819e9af323582e','468186926b1f15180ad03d96aa30b064f206bbdf8b138616897caf97eadc8728','5ea8fb1da0b2fb07c8a99c9d8dac0140ec1115c24a3f4ca2257f20f4c4c72805'),
('bootstrap_snapshot_rtl_04','53585cfb065185846d4607b34752816c6f4e8fef051986a058b38a5bbc692a99','85d51f4aed96cd4a76ab752d3bf0d32c97bc74d3eaecd6639dbcc83b3f1a3068','313df3ff4c41e633a7445fe0e51d63046cb8b71d96cb6f3062b636c11bde1a41'),
('generated_store_monitor_12','2288ea7bbc2287065a2840aafa4eb985e44384340169f1e7e467a88c45ef5fb9','f509faa06b02aed3da1e0fde6d17ce99d4ac2bc6b0b7b005ae3d1b5ea2f8f94a','42429da8360c8b47f7b049591b7894228d2e96820dd99b97046325f68b2bf0cc')]
expected = {}
for n,m,r,v in rows:
    expected[RUNS/n/'input_manifest.json'] = m; expected[RUNS/n/'receipt.json'] = r; expected[RUNS/(n+'_verification_20261012.json')] = v
expected[RUNS/'bootstrap_source_guard_prototype_verification_20261012.json'] = '27e1c7078413e8827cb1ce2c3429f5a6d497f68d0a5a958a1542f541379ce35e'
expected[RUNS/'bootstrap_source_guard_prototype_catalog_delta_20261012.json'] = '05dc47df4a35a11c88792372b59600e6dcc00369d39e47c2f1887db2479cd511'
hashes = [{'path':str(p.relative_to(ROOT)), 'expected':h, 'actual':sha(p), 'match':sha(p)==h} for p,h in expected.items()]
for p in expected:
    if p.parent == RUNS: snap(p)
for f in ['results/reviews/SM003.md','results/overview.md','results/review_queue.md','mission/current.md','agent/A001/state.json','agent/A001/result.md','agent/A002/state.json','.research-agent/discussions.json']: snap(ROOT/f)
intervals = sorted((a['plan']['at'],a['guard_result']['finished_at'],n) for n,a in attempts.items())
serial = all(intervals[i][1] <= intervals[i+1][0] for i in range(len(intervals)-1))
catalog = read(RUNS/'bootstrap_source_guard_prototype_catalog_delta_20261012.json')
catalog_keys = {(x['attempt'],x['path']):x for x in catalog['expected_live_pairs']}
for x in pairs:
    c = catalog_keys.get((x['attempt'],x['path']))
    x['matches_reported_catalog_delta'] = bool(c and x['declared'] == c['frozen_sha256'] and x['current'] == c['current_sha256'])
v = {'review_id':'R-SM003-BOOTSTRAP-SOURCE-GUARD-PROTOTYPE-20261012','checked_at':datetime.now(timezone.utc).isoformat(), 'pairs':pairs,'references':refs,'snapshots':snapshots,'attempts':attempts,'history':history,'diffs':diffs,'handoff_hashes':hashes,'summary':{'pairs':len(pairs),**{k:sum(x[k] for x in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'serial_intervals':intervals,'serial_nonoverlap':serial,'no_controller_compilation_simulation_hls':True,'decision':'pending_source_review'}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':v['summary'],'hash_matches':sum(x['match'] for x in hashes),'hash_total':len(hashes),'serial':serial,'changes':diffs,'live_differences':[x for x in pairs if not x['current_match']],'guards':[(n,a['policy_count'],a['policy_ok'],a['budget_ok'],a['receipt_guard_equal'],a['markers_in_raw_log']) for n,a in attempts.items()]},ensure_ascii=False,indent=2))
