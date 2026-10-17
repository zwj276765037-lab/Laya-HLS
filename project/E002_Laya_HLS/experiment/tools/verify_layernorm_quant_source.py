#!/usr/bin/env python3
"""Read-only identity and scope checks for a frozen LayerNorm to QUANT and F9 attempt."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import runpy


def record(path):
    path = path.resolve()
    data = path.read_bytes()
    return {'path': str(path), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def refs(value, location=''):
    if isinstance(value, dict):
        if 'path' in value and 'sha256' in value:
            yield location, value
        for key, child in value.items():
            yield from refs(child, location + '/' + key)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from refs(child, location + '/' + str(index))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    manifest = json.loads((attempt / 'input_manifest.json').read_text())
    receipt = json.loads((attempt / 'receipt.json').read_text())
    checks = []
    for name, value in [('manifest', manifest), ('receipt', receipt)]:
        for location, expected in refs(value, name):
            actual = record(Path(expected['path']))
            checks.append({'location': location, 'expected': expected,
                           'actual': actual,
                           'matches': actual['sha256'] == expected['sha256'] and
                           actual['bytes'] == expected['bytes']})
    pairs = []
    for item in manifest['files']:
        original = record(Path(item['original']['path']))
        frozen = record(Path(item['frozen']['path']))
        pairs.append({'label': item['label'],
                      'current_matches': original['sha256'] == item['original']['sha256'],
                      'frozen_matches': frozen['sha256'] == item['frozen']['sha256'],
                      'pair_matches': original['sha256'] == frozen['sha256']})
    stages = {}
    for mode, maximum_seconds, maximum_gib, rows in [
            ('static', 1800, 24, None), ('pilot', 120, 8, 1),
            ('full', 3600, 8, 16)] + [(f'reject_{i}',120,8,None) for i in range(1,7)]:
        result = receipt[mode]
        guard = result['guard']
        plan = json.loads((attempt / ('guard_' + mode) / 'guard_plan.json').read_text())
        policy = json.loads((attempt / ('guard_' + mode) / 'policy_checks.json').read_text())
        body = Path(result['driver_log']['path']).read_text()
        okay = (result['status'] == 'PASS' and guard['child_exit_code'] == 0 and
                guard['trigger'] is None and guard['elapsed_seconds'] <= maximum_seconds and
                guard['peak_owned_rss_kb'] <= maximum_gib * 1024 * 1024 and
                guard['minimum_mem_available_kb'] > 192 * 1024 * 1024 and
                plan['maximum_seconds'] == maximum_seconds and
                plan['maximum_owned_rss_kb'] == maximum_gib * 1024 * 1024 and
                plan['selected_cpu_ids'] == [0, 1, 2, 3] and
                policy and all(item['matches'] for item in policy) and
                'Fatal:' not in body and 'ERROR:' not in body and result['marker'])
        if rows is not None:
            ar = re.findall(r'PORTAL_PROGRESS source_AR row=(\d+) cycles=(\d+)', body)
            b = re.findall(r'PORTAL_PROGRESS destination_B row=(\d+) cycles=(\d+)', body)
            okay = okay and [int(item[0]) for item in ar] == list(range(rows))
            okay = okay and [int(item[0]) for item in b] == list(range(rows))
            marker = result['marker'][0]
            for expected in [f'rows={rows}', f'source_AR={rows}',
                             f'source_R={rows * 64}', f'destination_AW={rows}',
                             f'destination_W={rows * 64}', f'destination_B={rows}',
                             f'store_bytes={rows * 4096}', 'completion_beats=8',
                             f'gold_elements={rows * 1024}', 'begin_gated=1',
                             'END_from_real_completion=1']:
                okay = okay and expected in marker
            if mode == 'full':
                okay = okay and 'source_query_granted=1' in marker
                okay = okay and 'source_lease_released=1' in marker
                okay = okay and all(x in marker for x in ['quant_AR=16','quant_R=1024','fullA_groups=128'])
            stages[mode] = {'matches': bool(okay), 'guard': guard,
                            'plan': record(attempt / ('guard_' + mode) / 'guard_plan.json'),
                            'policy': record(attempt / ('guard_' + mode) / 'policy_checks.json'),
                            'marker': result['marker'], 'source_AR': ar, 'destination_B': b}
        else:
            if mode.startswith('reject_'):
                case=int(mode.split('_')[1])
                marker=result['marker'][0] if result['marker'] else ''
                okay=okay and f'case={case}' in marker and 'scope_retained=1' in marker
                if case<=4:
                    okay=okay and all(x in marker for x in ['source_AR=0','destination_AW=0','destination_W=0','published=0'])
                else:
                    okay=okay and 'caller_completion=0' in marker and 'tracker_retained=1' in marker
            stages[mode] = {'matches': bool(okay), 'guard': guard,
                            'plan': record(attempt / ('guard_' + mode) / 'guard_plan.json'),
                            'policy': record(attempt / ('guard_' + mode) / 'policy_checks.json')}
    cost = manifest['cost_decision']
    cycles = int(re.search(r'cycles=(\d+)', receipt['pilot']['marker'][0]).group(1))
    rate = cycles / receipt['pilot']['guard']['elapsed_seconds']
    reference = cycles * 16 + 262144
    projected = math.ceil(reference * 1.5 / rate)
    cost_ok = (cost['status'] == 'RUN_FULL' and cost == receipt['cost_decision'] and
               cost['pilot_cycles'] == cycles and cost['reference_full_cycles'] == reference and
               cost['projected_full_seconds'] == projected and projected <= 3600)
    identity = manifest['model_identity']
    generator = runpy.run_path(identity['generator']['path'])
    header = Path(identity['selected_header']['path'])
    identity_ok = (header.read_bytes() == Path(identity['engine_header']['path']).read_bytes() and
                   generator['generate'](header) == Path(identity['canonical_package']['path']).read_text())
    success = (all(item['matches'] for item in checks) and
               all(all(item[k] for k in ('current_matches', 'frozen_matches', 'pair_matches'))
                   for item in pairs) and all(item['matches'] for item in stages.values()) and
               cost_ok and identity_ok)
    output = {'schema': 'laya-layernorm-quant-source-verification-v1',
              'attempt': str(attempt), 'verifier': record(Path(__file__)),
              'manifest': record(attempt / 'input_manifest.json'),
              'receipt': record(attempt / 'receipt.json'), 'scope': receipt['scope'],
              'file_references': checks, 'file_reference_count': len(checks),
              'file_reference_matches': sum(item['matches'] for item in checks),
              'pairs': pairs, 'pair_count': len(pairs), 'stages': stages,
              'model_identity_matches': identity_ok,
              'current_pilot_cost_matches': cost_ok, 'cost_decision': cost,
              'status': 'PASS_SCOPED_IDENTITY_AND_RUNTIME' if success else 'FAIL'}
    args.output.write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps({k: output[k] for k in ['status', 'file_reference_count',
                                           'file_reference_matches', 'pair_count',
                                           'model_identity_matches', 'current_pilot_cost_matches']}))
    return 0 if success else 1


if __name__ == '__main__':
    raise SystemExit(main())
