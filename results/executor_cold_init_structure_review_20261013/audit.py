from pathlib import Path
from datetime import datetime, timezone
import hashlib, json

R = Path(__file__).resolve().parents[2]
D = Path(__file__).resolve().parent
B = R / 'project/E003_production_chain_closure/experiment_results/runs/R003'
def get(p): return json.loads(p.read_text())
def sha(p):
    with p.open('rb') as f: return hashlib.file_digest(f, 'sha256').hexdigest()
def valid(x):
    p = Path(x['path'])
    return p.is_file() and p.stat().st_size == x['bytes'] and sha(p) == x['sha256']
def refs(x, key=''):
    if isinstance(x, dict):
        if {'path', 'bytes', 'sha256'} <= x.keys(): yield key, x
        else:
            for k, v in x.items(): yield from refs(v, key + '/' + k)
    elif isinstance(x, list):
        for i, v in enumerate(x): yield from refs(v, key + '/' + str(i))

eng = get(B / 'executor_fourth_stop_stream_verification_20261013.json')
checks, snaps, intervals = {}, [], []
for name in ['executor_hls_04', 'executor_stream_host_03']:
    p = B / name
    m, r = get(p / 'input_manifest.json'), get(p / 'receipt.json')
    assert r['status'] == eng['attempts'][name]['status']
    live, original_refs, count = [], [], 0
    for f in m['files']:
        assert valid(f['frozen'])
        assert all(f['frozen'][k] == f['original'][k] for k in ['sha256', 'bytes'])
        if not valid(f['original']): live.append(f.get('relative', f['original']['path']))
    for obj in [m, r]:
        for key, x in refs(obj):
            if key.endswith('/original') or key.endswith('_original'):
                if not valid(x): original_refs.append(key)
            else:
                assert valid(x), (name, key, x)
                count += 1
    guards = []
    for gp in sorted(p.glob('guard_*/guard_result.json')):
        g = get(gp)
        plan = get(gp.parent / 'guard_plan.json')
        polpath = gp.parent / 'policy_checks.json'
        policies = get(polpath) if polpath.exists() else []
        if name == 'executor_hls_04':
            assert g['child_exit_code'] == -9 and g['trigger'] == 'semantic_stall'
        else:
            assert g['child_exit_code'] == 0 and g['trigger'] is None
        assert plan['semantic_stall_seconds'] == 120
        assert plan['maximum_seconds'] <= 1800 and plan['maximum_owned_rss_kb'] <= 24 * 1024 * 1024
        assert g['minimum_mem_available_kb'] > 192 * 1024 * 1024
        assert all(x['matches'] and x['affinity'] == [0, 1, 2, 3] and x['nice'] == 19 and x['ionice'] == 'idle' for x in policies)
        launch = gp.parent / 'launch.json'
        intervals.append({'attempt': name, 'guard': gp.parent.name, 'start': get(launch)['at'], 'end': g['finished_at']})
        guards.append({'guard': gp.parent.name, 'result': g, 'plan': plan, 'policy_count': len(policies)})
        snaps.extend([gp, gp.parent / 'guard_plan.json', launch])
        if polpath.exists(): snaps.append(polpath)
    checks[name] = {'status': r['status'], 'frozen_pairs': len(m['files']), 'immutable_references': count, 'live_drift': live, 'historical_original_reference_drift': original_refs, 'guards': guards}
    snaps.extend([p / 'receipt.json', p / 'input_manifest.json'])

r = get(B / 'executor_hls_04/receipt.json')
assert not r['generated_candidates'] and r['port_evidence'] is None
bc = B / 'executor_hls_04/work/hls/.autopilot/db/a.g.ld.5.gdce.bc'
assert bc.stat().st_size == 1212028 and sha(bc) == '19c12c3b6108d7cb8e626a423e2fad528ee9db3a3610fd1f29b9e7c951a52aa5'
checks['executor_hls_04']['gdce_identity'] = {'bytes': bc.stat().st_size, 'sha256': sha(bc)}
checks['executor_hls_04']['IR_analysis_scope'] = 'A006 report preserved; controller hashes BC but does not rerun decoder/pass/callgraph'
for mode in ['const', 'in_place']:
    log = B / f'executor_stream_host_03/guard_run_{mode}/driver.log'
    body = log.read_text()
    markers = [line for line in body.splitlines() if 'PASS' in line or '5859' in line]
    assert markers and any('PASS' in x for x in markers), (mode, body)
    assert 'Assertion' not in body and 'Fatal:' not in body
    checks['executor_stream_host_03'][mode + '_actual_markers'] = markers
    snaps.append(log)
intervals.sort(key=lambda x: x['start'])
assert all(a['end'] <= b['start'] for a, b in zip(intervals, intervals[1:]))
for rel in [
    'results/production_hls_partition_contract_20261012.md',
    'results/executor_minimum_hardware_chain_reply_20261013.md',
    'agent/A006/result.md',
    '.research-agent/communication.json',
    '.research-agent/communications/executor-fourth-stop-stream-progress-20261013.json',
    'project/E003_production_chain_closure/experiment_results/runs/R003/executor_fourth_stop_stream_verification_20261013.json',
    'project/E002_Laya_HLS/experiment/hls/control/executor_hls.cpp',
    'project/E002_Laya_HLS/experiment/include/laya_executor_actor.h',
    'project/E002_Laya_HLS/experiment/include/laya_full_runtime.h',
    'project/E002_Laya_HLS/experiment/include/laya_task_reservation.h',
    'project/E002_Laya_HLS/experiment/include/laya_types.h',
]: snaps.append(R / rel)
snaps.extend([B / 'executor_hls_04/guard_hls/driver.log', B / 'executor_hls_04/work/hls/syn/report/csynth_design_size.rpt'])
snaps.extend((B / 'executor_stream_host_03/frozen/tests').glob('*executor*stream*'))
items = []
for p in dict.fromkeys(snaps):
    if not p.is_file(): continue
    q = D / 'snapshot' / p.relative_to(R)
    q.parent.mkdir(parents=True, exist_ok=True)
    q.write_bytes(p.read_bytes())
    items.append({'source': str(p.relative_to(R)), 'snapshot': str(q.relative_to(R)), 'sha256': sha(q), 'bytes': q.stat().st_size})
out = {'review': 'R-SM003-EXECUTOR-COLD-INIT-STRUCTURE-20261013', 'at': datetime.now(timezone.utc).isoformat(), 'attempts': checks, 'selected_serial_intervals': intervals, 'snapshots': items, 'no_DUT_or_LLVM_tools_run': True, 'limitations': ['No new executor RTL or C/D numeric/cycle baseline', 'Stream dual process is not object-by-object cross-process equivalence', 'Cold-init/storage restructuring is an authorized untested hypothesis, not a proven stall cause']}
vp = D / 'verification.json'
assert not vp.exists()
vp.write_text(json.dumps(out, ensure_ascii=False, indent=2) + '\n')
gs = [g for x in checks.values() for g in x['guards']]
print(json.dumps({'frozen_pairs': sum(x['frozen_pairs'] for x in checks.values()), 'immutable_references': sum(x['immutable_references'] for x in checks.values()), 'live_drift': {k:v['live_drift'] for k,v in checks.items()}, 'guards': len(gs), 'policy_count': sum(g['policy_count'] for g in gs), 'snapshots': len(items), 'verification_sha256': sha(vp)}, ensure_ascii=False))
