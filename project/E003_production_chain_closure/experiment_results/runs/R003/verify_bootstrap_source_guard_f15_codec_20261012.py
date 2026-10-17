#!/usr/bin/env python3
"""Read-only identity, receipt and raw policy check for this bounded milestone."""
import datetime as dt
import hashlib
import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
NAMES = ['bootstrap_source_guard_rtl_08']
cache = {}
def record(path):
    path = Path(path).resolve()
    if path not in cache:
        data = path.read_bytes()
        cache[path] = {'path': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
    return cache[path]
def references(value, results):
    if isinstance(value, dict):
        if 'path' in value and 'sha256' in value and 'bytes' in value:
            actual = record(value['path'])
            results.append({'declared': value, 'actual': actual,
                            'match': actual['sha256'] == value['sha256'] and actual['bytes'] == value['bytes']})
        for item in value.values(): references(item, results)
    elif isinstance(value, list):
        for item in value: references(item, results)

def verify(name):
    attempt = RUN / name
    manifest = json.loads((attempt / 'input_manifest.json').read_text())
    receipt = json.loads((attempt / 'receipt.json').read_text())
    pairs = list(manifest['files'])
    for key in ['contract', 'bootstrap_contract']:
        if key in manifest: pairs.append(manifest[key])
    pairs += manifest.get('contracts', [])
    checked = []
    for pair in pairs:
        current = record(pair['original']['path']); frozen = record(pair['frozen']['path'])
        checked.append({'original': pair['original'], 'frozen': pair['frozen'],
            'current': current, 'actual_frozen': frozen,
            'current_match': current['sha256'] == pair['original']['sha256'],
            'frozen_match': frozen['sha256'] == pair['frozen']['sha256'],
            'declared_pair_match': pair['original']['sha256'] == pair['frozen']['sha256']})
    refs = []
    references(manifest, refs); references(receipt, refs)
    launcher = json.loads((attempt / 'launcher.json').read_text())
    checks = {'current': all(p['current_match'] for p in checked),
        'frozen': all(p['frozen_match'] for p in checked),
        'declared_pairs': all(p['declared_pair_match'] for p in checked),
        'references': all(r['match'] for r in refs),
        'launcher': launcher['pass'] and launcher['cpu_affinity'] == [0, 1, 2, 3]
            and launcher['nice'] == 19 and launcher['ionice'].startswith('idle')
            and launcher['mem_available_kib'] > 201326592,
        'receipt_pass': receipt['status'] == 'PASS'}
    metrics = {}
    if 'commands' in receipt:
        commands = receipt['commands']
        checks['commands'] = all(c['exit_code'] == 0 and not c['timeout'] for c in commands)
        checks['marker'] = len(receipt['markers']) == 1 and receipt['markers'][0] in (attempt / 'run.log').read_text()
        metrics['commands_seconds'] = [c['elapsed_seconds'] for c in commands]
        metrics['host_guard_scope'] = '1800s/24GiB RLIMIT_AS only; no owned-RSS/120s semantic sampling'
    else:
        guard = json.loads((attempt / 'guard/guard_result.json').read_text())
        plan = json.loads((attempt / 'guard/guard_plan.json').read_text())
        policy = json.loads((attempt / 'guard/policy_checks.json').read_text())
        checks['guard'] = guard['child_exit_code'] == 0 and guard['trigger'] is None
        checks['limits'] = guard['elapsed_seconds'] < plan['maximum_seconds'] <= 120 and \
            guard['peak_owned_rss_kb'] < plan['maximum_owned_rss_kb'] <= 8 * 1024 * 1024 and \
            guard['minimum_mem_available_kb'] > 201326592 and plan['semantic_stall_seconds'] == 120
        checks['policy'] = len(policy) > 0 and all(p['matches'] and p['affinity'] == [0, 1, 2, 3]
            and p['nice'] == 19 and p['ionice'] == 'idle' for p in policy)
        checks['marker'] = len(receipt['marker']) == 1 and receipt['marker'][0] in (attempt / 'guard/driver.log').read_text()
        metrics['guard_result'] = guard
        metrics['policy_count'] = len(policy)
        metrics['marker'] = receipt['marker']
    result = {'schema': 'laya-executor-bootstrap-attempt-verification-v1',
        'verified_at_utc': dt.datetime.now(dt.timezone.utc).isoformat(), 'attempt': str(attempt),
        'checks': checks, 'passed': all(checks.values()),
        'pair_count': len(checked), 'reference_count': len(refs), 'pairs': checked,
        'references': refs, 'metrics': metrics,
        'deliverables': {n: record(attempt / n) for n in ['input_manifest.json', 'receipt.json']}}
    out = RUN / (name + '_verification_20261012.json')
    if out.exists(): raise RuntimeError('refuse to overwrite verification ' + str(out))
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(name, result['passed'], len(checked), len(refs), metrics)
    return result, record(out)

if __name__ == '__main__':
    results = [verify(name) for name in NAMES]
    aggregate = {'schema': 'laya-executor-bootstrap-milestone-verification-v1',
        'scope': 'F15 terminal action pop and delayed physical release block persistent producer, old completion tail and R debt retained; source-conflict cleanup prototype, no generated executor or producer',
        'verifier': record(__file__), 'attempts': [r for _, r in results],
        'all_pre_catalog_identity_and_checks_match': all(v['passed'] for v, _ in results),
        'pairs': sum(v['pair_count'] for v, _ in results),
        'references': sum(v['reference_count'] for v, _ in results)}
    out = RUN / 'bootstrap_source_guard_f15_codec_verification_20261012.json'
    if out.exists(): raise RuntimeError('refuse to overwrite aggregate')
    out.write_text(json.dumps(aggregate, indent=2) + '\n')
    if not aggregate['all_pre_catalog_identity_and_checks_match']: raise SystemExit(1)
