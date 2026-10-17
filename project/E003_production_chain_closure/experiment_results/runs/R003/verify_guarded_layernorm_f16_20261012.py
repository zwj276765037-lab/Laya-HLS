#!/usr/bin/env python3
"""Read-only current/frozen, raw guard/policy and staged ROM verification."""
import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

RUN = Path(__file__).resolve().parent

def rec(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return {'path': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def references(value, output):
    if isinstance(value, dict):
        if all(k in value for k in ('path', 'bytes', 'sha256')):
            actual = rec(value['path'])
            output.append({'declared': value, 'actual': actual, 'match': actual == value})
        for item in value.values(): references(item, output)
    elif isinstance(value, list):
        for item in value: references(item, output)

def verify(name):
    attempt = RUN/name
    manifest = json.loads((attempt/'input_manifest.json').read_text())
    receipt = json.loads((attempt/'receipt.json').read_text())
    pairs = list(manifest['files']) + manifest.get('contracts', [])
    for key in ('contract', 'bootstrap_contract'):
        if key in manifest: pairs.append(manifest[key])
    checked = []
    for p in pairs:
        original, frozen = rec(p['original']['path']), rec(p['frozen']['path'])
        checked.append({'original': p['original'], 'frozen': p['frozen'],
            'actual_current': original, 'actual_frozen': frozen,
            'current_match': original == p['original'], 'frozen_match': frozen == p['frozen'],
            'declared_pair_match': p['original']['sha256'] == p['frozen']['sha256']})
    refs = []; references(manifest, refs); references(receipt, refs)
    launcher = json.loads((attempt/'launcher.json').read_text())
    guards = []
    for directory in sorted(attempt.glob('guard*')):
        if not directory.is_dir(): continue
        result = json.loads((directory/'guard_result.json').read_text())
        plan = json.loads((directory/'guard_plan.json').read_text())
        policy_path = directory/'policy_checks.json'
        policy = json.loads(policy_path.read_text()) if policy_path.exists() else []
        body = (directory/'driver.log').read_text(errors='replace')
        markers = [s for s in body.splitlines() if s.startswith('FULL_CURRENT_') and '_PASS' in s]
        allowed_rss = 24*1024*1024 if directory.name in ('guard_static', 'guard_build', 'guard_run') else 8*1024*1024
        allowed_seconds = 1800 if allowed_rss == 24*1024*1024 else 120
        short_host = directory.name == 'guard_run' and result['elapsed_seconds'] < plan['sample_seconds'] and not result['rss_captured'] and not policy
        rss = result['peak_owned_rss_kb']
        checks = {
            'child': result['child_exit_code'] == 0 and result['trigger'] is None,
            'limits': result['elapsed_seconds'] < plan['maximum_seconds'] <= allowed_seconds and
                plan['maximum_owned_rss_kb'] <= allowed_rss and
                ((rss is not None and rss < plan['maximum_owned_rss_kb']) or short_host) and
                result['minimum_mem_available_kb'] > 201326592 and plan['semantic_stall_seconds'] == 120,
            'policy_or_short_host_disclosure': short_host or (bool(policy) and all(p['matches'] and p['affinity'] == [0,1,2,3] and
                p['nice'] == 19 and p['ionice'] == 'idle' for p in policy)),
            'log': 'Fatal:' not in body and 'ERROR:' not in body,
            'marker': bool(markers) or directory.name == 'guard_build',
        }
        guards.append({'directory': directory.name, 'result': result, 'plan': plan,
            'policy_count': len(policy), 'markers': markers, 'checks': checks,
            'sampling_limitation': 'short host run finished before first owned-RSS/child-policy capture; launcher and wrapper policy only' if short_host else None,
            'passed': all(checks.values())})
    staged = receipt.get('runtime_dat_staging', [])
    dat_pass = all(p['source']['sha256'] == p['staged']['sha256'] and
        rec(p['source']['path']) == p['source'] and rec(p['staged']['path']) == p['staged'] for p in staged)
    stage_states = [v['status'] for k,v in receipt.items() if k in ('static','pilot','build','run')]
    checks = {'current': all(p['current_match'] for p in checked),
        'frozen': all(p['frozen_match'] for p in checked),
        'declared_pairs': all(p['declared_pair_match'] for p in checked),
        'references': all(p['match'] for p in refs),
        'launcher': launcher['pass'] and launcher['cpu_affinity'] == [0,1,2,3] and
            launcher['nice'] == 19 and launcher['ionice'].startswith('idle') and
            launcher['mem_available_kib'] > 201326592,
        'guards': bool(guards) and all(g['passed'] for g in guards),
        'receipt': receipt.get('status', 'PASS' if stage_states and all(s == 'PASS' for s in stage_states) else 'FAIL') == 'PASS',
        'staged_DAT': dat_pass}
    result = {'schema': 'laya-guarded-layernorm-f16-verification-v1',
        'at_utc': dt.datetime.now(dt.timezone.utc).isoformat(), 'attempt': str(attempt),
        'checks': checks, 'passed': all(checks.values()), 'pair_count': len(checked),
        'reference_count': len(refs), 'pairs': checked, 'references': refs,
        'guards': guards, 'staged_DAT_count': len(staged),
        'actual_capture_count': len(receipt.get('actual_protocol_captures', [])),
        'deliverables': {n: rec(attempt/n) for n in ('input_manifest.json', 'receipt.json')}}
    out = RUN/(name+'_verification_20261012.json')
    if out.exists(): raise RuntimeError('verification exists; do not overwrite '+str(out))
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(name, result['passed'], len(checked), len(refs), [(g['directory'],g['result']['elapsed_seconds'],g['policy_count']) for g in guards])
    if not result['passed']: raise SystemExit(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('attempts', nargs='+'); args = parser.parse_args()
    for name in args.attempts: verify(name)
