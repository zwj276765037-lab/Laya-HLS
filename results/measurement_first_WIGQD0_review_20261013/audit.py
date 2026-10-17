from pathlib import Path
import hashlib
import json
import re
import shutil
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUN = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001'
NAMES = ['AT029_WIGQD0_chain_01', 'AT030_WIGQD0_chain_02', 'AT031_WIGQD0_chain_03']
CURRENT = ['mission/current.md', 'results/overview.md', 'results/hardware_metrics.md',
           'results/hardware_progress.md', 'results/review_queue.md', 'results/reviews/SM005.md',
           'project/missions/SM005.md', 'agent/A001/result.md', 'NEW_CHAT_START.md']
for name in CURRENT + ['agent/A001/state.json']:
    dest = OUT / 'prior_records' / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    if not dest.exists():
        shutil.copy2(ROOT / name, dest)

cache = {}
checks = []
attempts = {}
guards = []
def identity(path):
    p = Path(path)
    if str(p) not in cache:
        b = p.read_bytes()
        cache[str(p)] = {'path': str(p), 'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}
    return cache[str(p)]

def verify_refs(value, origin):
    if isinstance(value, dict):
        if {'path', 'bytes', 'sha256'} <= value.keys():
            p = Path(value['path'])
            actual = identity(p)
            checks.append({'origin': origin, 'expected': value, 'actual': actual,
                           'match': all(value[k] == actual[k] for k in ['bytes', 'sha256']),
                           'live': str(ROOT / 'project/E002_Laya_HLS/experiment') in str(p)})
        else:
            for k, v in value.items():
                verify_refs(v, origin + '/' + k)
    elif isinstance(value, list):
        for i, v in enumerate(value):
            verify_refs(v, origin + '/' + str(i))

maps = {}
for name in NAMES:
    p = RUN / 'attempts' / name
    manifest = json.loads((p / 'input_manifest.json').read_text())
    receipt = json.loads((p / 'receipt.json').read_text())
    verify_refs(manifest, name + '/manifest')
    verify_refs(receipt, name + '/receipt')
    mapping = {str(Path(x['frozen']['path']).relative_to(p)): x['frozen']['sha256']
               for x in manifest['files']}
    maps[name] = mapping
    attempts[name] = {'file_rows': len(manifest['files']), 'distinct_frozen_paths': len(mapping),
                      'status': receipt['status'], 'phases': {k: v['status'] for k, v in receipt['phases'].items()},
                      'manifest': identity(p / 'input_manifest.json'), 'receipt': identity(p / 'receipt.json')}
    for phase, info in receipt['phases'].items():
        g = p / ('guard_' + phase)
        launch = json.loads((g / 'launch.json').read_text())
        plan = json.loads((g / 'guard_plan.json').read_text())
        result = json.loads((g / 'guard_result.json').read_text())
        policy = json.loads((g / 'policy_checks.json').read_text())
        ok = all(s['matches'] and s['affinity'] == [0,1,2,3] and s['nice'] == 19
                 and s['ionice'] == 'idle' and s['ionice_exit'] == 0 for s in policy)
        limits_ok = (plan['selected_cpu_ids'] == [0,1,2,3]
                     and plan['semantic_stall_seconds'] == 120
                     and plan['minimum_mem_available_kb'] == 192*1024*1024
                     and plan['maximum_seconds'] == {'static':1800,'pilot':120,'full':3600}[phase]
                     and plan['maximum_owned_rss_kb'] == (24 if phase == 'static' else 8)*1024*1024)
        guards.append({'attempt': name, 'phase': phase, 'started_at': launch['at'],
                       'finished_at': result['finished_at'], 'result': result, 'receipt_match': result == info['guard'],
                       'policy_count': len(policy), 'policies_match': ok, 'limits_match': limits_ok,
                       'files': [identity(g / n) for n in ['launch.json','guard_plan.json','guard_result.json','policy_checks.json']]})

guards.sort(key=lambda x: x['started_at'])
overlaps = [(a['attempt'], a['phase'], b['attempt'], b['phase']) for a,b in zip(guards,guards[1:])
            if datetime.fromisoformat(a['finished_at']) > datetime.fromisoformat(b['started_at'])]
diffs = {a+'__'+b: [k for k in maps[a] if maps[a][k] != maps[b].get(k)]
         for a,b in zip(NAMES,NAMES[1:])}

p = RUN / 'attempts' / NAMES[-1]
tb = p / 'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv'
lines = tb.read_text().splitlines()
marker_lines = [{'line': i, 'text': s.strip()} for i,s in enumerate(lines,1) if 'MATRIX_PROGRESS' in s]
gap_start = next(x['line'] for x in marker_lines if 'GQD0_cfg_accepted' in x['text'])
gap_end = next(x['line'] for x in marker_lines if 'GQD0_A_ready' in x['text'])
raw = (p / 'raw_full.log').read_text()
last_marker = [l for l in raw.splitlines() if 'MATRIX_PROGRESS' in l][-1]
boundaries = re.search(r'DOWN_MEASURE_BOUNDARIES.*', raw).group()
states = re.search(r'DOWN_MEASURE_STATES.*', raw).group()
state_sum = sum(map(int, re.findall(r'\bs\d+=(\d+)', states)))
evidence = [identity(tb), identity(p / 'raw_full.log')]
for n in ['WIGQD0_bounded_stop_20261013.md', 'WIGQD0_connection_map_20261013.md',
          'WIGQD0_identity_audit_20261013.json', 'WIGQD0_observation_addendum_20261013.md']:
    evidence.append(identity(RUN / 'reports' / n))
result = {'scope': 'controller read-only immutable evidence audit; no DUT tools executed',
          'recorded_at': datetime.now(timezone.utc).isoformat(), 'attempts': attempts,
          'reference_count': len(checks), 'unique_reference_paths': len({c['actual']['path'] for c in checks}),
          'frozen_manifest_rows': sum(x['file_rows'] for x in attempts.values()),
          'immutable_mismatches': [c for c in checks if not c['match'] and not c['live']],
          'live_mismatches': [c for c in checks if not c['match'] and c['live']],
          'comparisons': diffs, 'guard_count': len(guards),
          'policy_count': sum(x['policy_count'] for x in guards), 'overlaps': overlaps,
          'guards': guards, 'references': checks, 'evidence': evidence,
          'observability': {'tb': identity(tb), 'all_semantic_marker_lines': marker_lines,
                            'G_gap_start_line': gap_start, 'G_gap_end_line': gap_end,
                            'last_raw_marker': last_marker,
                            'no_cycle_or_root_cause_inference': True},
          'Wi_boundaries_raw': boundaries, 'Wi_state_sum': state_sum,
          'verdict': 'COST_STOP retained; only reached Wi numeric, actual output-memory readback and completion accepted; entire chain unverified'}
(OUT / 'verification.json').write_text(json.dumps(result, ensure_ascii=False, indent=2)+'\n')
assert not result['immutable_mismatches'] and not overlaps
assert all(g['receipt_match'] and g['policies_match'] and g['limits_match'] for g in guards)
assert state_sum == 46911 and 'WIGQD_WI_COMPLETE cycle=101335' in raw
assert 'WIGQD0_FULL_PASS' not in raw
print(json.dumps({k:result[k] for k in ['reference_count','unique_reference_paths','frozen_manifest_rows','guard_count','policy_count','comparisons','Wi_state_sum']},ensure_ascii=False))
print('live_mismatches', [(x['origin'],x['expected']['path']) for x in result['live_mismatches']])
print('observation', result['observability'])
