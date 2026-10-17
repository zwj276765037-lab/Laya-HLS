#!/usr/bin/env python3
"""Audit immutable output after a live-source postcheck refusal; never run HLS."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import xml.etree.ElementTree as ET


def identity(path):
    path = Path(path)
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            size += len(block)
            digest.update(block)
    return {'path': str(path.resolve()), 'bytes': size, 'sha256': digest.hexdigest()}


def verify(record):
    actual = identity(record['path'])
    if any(actual[k] != record[k] for k in ('bytes', 'sha256')):
        raise RuntimeError('immutable identity mismatch: ' + record['path'])
    return actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    if args.output.exists():
        raise RuntimeError('audit output exists; historical audits are immutable')
    receipt = json.loads((attempt / 'receipt.json').read_text())
    manifest = json.loads((attempt / 'input_manifest.json').read_text())
    result = {'schema': 'laya-managed-generation-immutable-audit-v1',
              'original_receipt': identity(attempt / 'receipt.json'),
              'original_receipt_status': receipt['status'],
              'hls_rerun': False, 'receipt_rewritten': False,
              'RTL_runtime': 'NOT_RUN', 'production_chain': 'NOT_RUN',
              'live_differences': [], 'frozen_pairs_checked': 0,
              'immutable_references_checked': 0}
    verify(receipt['input_manifest'])
    hls = receipt['operations']['hls']
    guard = hls['guard']
    if (hls['status'] != 'PASS' or guard['child_exit_code'] != 0 or
            guard['trigger'] is not None or hls['runner_exit_code'] != 0):
        raise RuntimeError('real HLS guard did not complete successfully')
    result['real_hls_guard'] = guard
    result['real_hls_operation_status'] = hls['status']
    expected_suffixes = {'include/laya_full_runtime.h', 'include/laya_task_reservation.h'}
    differences = set()
    for row in manifest['files']:
        frozen = verify(row['frozen'])
        if any(row['original'][k] != frozen[k] for k in ('bytes', 'sha256')):
            raise RuntimeError('original snapshot/frozen pair mismatch')
        result['frozen_pairs_checked'] += 1
        current = identity(row['original']['path'])
        if any(current[k] != frozen[k] for k in ('bytes', 'sha256')):
            path = Path(current['path'])
            suffix = '/'.join(path.parts[-2:])
            if suffix not in expected_suffixes:
                raise RuntimeError('unexpected live difference: ' + str(path))
            differences.add(suffix)
            result['live_differences'].append({'declared_original': row['original'],
                                              'current_original': current})
    if differences != expected_suffixes:
        raise RuntimeError('postcheck drift does not match the two known cold-init edits')

    # Every recorded immutable artifact, guard file, reused host input and
    # actual external/tool dependency must still match. A live source path is
    # never accepted as an immutable reference to a generated input.
    def walk(value, key=None):
        if isinstance(value, dict):
            if all(k in value for k in ('path', 'bytes', 'sha256')):
                if key not in ('original', 'current_original'):
                    verify(value)
                    result['immutable_references_checked'] += 1
            for name, item in value.items():
                walk(item, name)
        elif isinstance(value, list):
            for item in value:
                walk(item, key)
    walk(receipt)
    walk(manifest)
    for record in manifest['tools'] + manifest['actual_external_dependency_closure']:
        verify(record)
    driver = next(row for row in manifest['files']
                  if row['original']['path'].endswith('/run_controller_transaction_adapter_managed_hls.py'))
    verify(driver['original'])
    spec = importlib.util.spec_from_file_location('managed_generation_driver', driver['original']['path'])
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    candidates = sorted((attempt / 'work').glob('**/syn/verilog/' + module.TOP + '.v'))
    if len(candidates) != 1:
        raise RuntimeError('a unique actual generated top is required')
    result['actual_top'] = identity(candidates[0])
    result['port_evidence'] = module.port_evidence(candidates[0])
    if result['port_evidence']['status'] != 'PASS':
        raise RuntimeError('actual generated top ports do not match the contract')
    xmls = sorted((attempt / 'work').glob('**/syn/report/' + module.TOP + '_csynth.xml'))
    result['HLS_estimate'] = None
    if len(xmls) == 1:
        tree = ET.parse(xmls[0])
        resources = tree.find('.//AreaEstimates/Resources')
        result['HLS_estimate'] = {'source': identity(xmls[0]),
                                  'resources': {v.tag: v.text for v in resources}}
    result['status'] = 'PASS_SCOPED_IMMUTABLE_GENERATION_AUDIT'
    result['scope'] = ('Actual frozen managed adapter HLS generation and exact ports only. '
        'Original receipt FAIL from its post-run live-source identity check remains unchanged. '
        'All frozen inputs, tools, external dependencies and recorded artifacts match. '
        'No RTL behavior, initial external presentation/backpressure, real executor pending, '
        'hub retirement, complete NORM, joint area, implemented timing or board result.')
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(result['status'], 'frozen_pairs=' + str(result['frozen_pairs_checked']),
          'immutable_refs=' + str(result['immutable_references_checked']),
          'live_differences=' + str(len(result['live_differences'])))


if __name__ == '__main__':
    main()
