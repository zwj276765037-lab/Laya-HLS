#!/usr/bin/env python3
"""Read-only source binding and generated-output inventory for the single HLS run."""

import hashlib
import json
import os
import platform
import sys
from datetime import datetime, timezone
from pathlib import Path

RUN = Path(__file__).resolve().parent
BASE = RUN.parent.parent
PROJECT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
RELEASE = PROJECT / 'results/attention_rtl_repair_20261008/reviewer_attention_v6_metadata_reset_post_csim_single_hls_release.json'
PACKET = BASE / 'source/source_packet.json'
RELEASE_SHA = 'cf6b577e4a0251cb83c7bc48a4c128d1a22082a8fefbdd098bdcd18a55c79a90'
MIN_AVAILABLE = 201326592


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def identity(path):
    p = Path(path)
    return {'path': str(p), 'resolved_path': str(p.resolve()),
            'bytes': p.stat().st_size, 'sha256': digest(p)}


def records(value, out):
    if isinstance(value, dict):
        if {'path', 'bytes', 'sha256'} <= value.keys():
            out.append({k: value[k] for k in ('path', 'bytes', 'sha256')})
        for child in value.values():
            records(child, out)
    elif isinstance(value, list):
        for child in value:
            records(child, out)


def mem_available():
    for line in Path('/proc/meminfo').read_text().splitlines():
        if line.startswith('MemAvailable:'):
            return int(line.split()[1])
    raise RuntimeError('MemAvailable missing')


def binding(phase):
    packet = json.loads(PACKET.read_text())
    release = json.loads(RELEASE.read_text())
    expected = []
    records(packet, expected)
    checks = []
    for entry in expected:
        try:
            actual = identity(entry['path'])
            match = actual['bytes'] == entry['bytes'] and actual['sha256'] == entry['sha256']
        except OSError as error:
            actual = {'path': entry['path'], 'error': str(error)}
            match = False
        checks.append({'expected': entry, 'actual': actual, 'match': match})
    authority = [
        {'expected': {'path': str(RELEASE), 'sha256': RELEASE_SHA},
         'actual': identity(RELEASE)},
        {'expected': release['source_packet'], 'actual': identity(PACKET)},
        {'expected': release['execution_plan'], 'actual': identity(BASE / 'source/execution_plan.json')},
        {'expected': release['config'], 'actual': identity(BASE / 'config.cfg')},
        {'expected': release['vplusplus_entry'], 'actual': identity(release['vplusplus_entry']['path'])},
        {'expected': release['guard'], 'actual': identity(release['guard']['path'])},
        {'expected': release['guard_helper'], 'actual': identity(release['guard_helper']['path'])},
        {'expected': release['actual_csim_acceptance'],
         'actual': identity(release['actual_csim_acceptance']['path'])},
    ]
    for item in authority:
        item['match'] = all(item['expected'][key] == item['actual'][key]
                            for key in ('path', 'sha256') if key in item['expected']) and \
                        ('bytes' not in item['expected'] or
                         item['expected']['bytes'] == item['actual']['bytes'])
    config_sources = [line.split('=', 1)[1] for line in (BASE / 'config.cfg').read_text().splitlines()
                      if line.startswith('syn.file=')]
    source_paths = {item['path'] for item in expected}
    affinity = sorted(os.sched_getaffinity(0))
    available = mem_available()
    environment = {}
    for key, value in sorted(os.environ.items()):
        if any(s in key.upper() for s in ('TOKEN', 'KEY', 'PASS', 'SECRET', 'COOKIE',
                                          'AUTH', 'LICENSE', 'CREDENTIAL')):
            environment[key] = {'sha256': hashlib.sha256(value.encode()).hexdigest(),
                                'redacted': True}
        else:
            environment[key] = value
    result = {
        'schema': 'attention_v6_single_hls_source_binding_v1', 'phase': phase,
        'created_utc': datetime.now(timezone.utc).isoformat(),
        'cwd': str(PROJECT), 'run_root': str(RUN),
        'release': authority[0], 'authority_checks': authority,
        'nested_record_count': len(expected), 'nested_unique_path_count': len(source_paths),
        'nested_checks': checks, 'config_source_count': len(config_sources),
        'config_sources': config_sources,
        'config_sources_in_packet': all(path in source_paths for path in config_sources),
        'affinity_first_four': affinity[:4], 'mem_available_kib': available,
        'minimum_mem_available_kib_strictly_above': MIN_AVAILABLE,
        'platform': platform.platform(), 'python': sys.version,
        'environment': environment,
    }
    result['all_match'] = (len(expected) == 101 and all(c['match'] for c in checks) and
                           all(c['match'] for c in authority) and
                           len(config_sources) == 25 and result['config_sources_in_packet'] and
                           affinity[:4] == [0, 1, 2, 3] and available > MIN_AVAILABLE)
    target = RUN / f'source_binding_{phase}.json'
    target.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(f'{phase}: all_match={result["all_match"]} nested={len(expected)} '
          f'config_sources={len(config_sources)} mem_available_kib={available}')
    return 0 if result['all_match'] else 1


def inventory():
    items, directories, symlinks, other = [], [], [], []
    for path in sorted(RUN.rglob('*')):
        relative = str(path.relative_to(RUN))
        if path.name in ('archive_inventory.json', 'actual_result_evidence.json'):
            continue
        if path.is_symlink():
            symlinks.append({'relative_path': relative, 'target': str(path.readlink())})
        elif path.is_dir():
            directories.append(relative)
        elif path.is_file():
            item = identity(path)
            item['relative_path'] = relative
            items.append(item)
        else:
            other.append(relative)
    result = {'schema': 'attention_v6_single_hls_archive_inventory_v1',
              'created_utc': datetime.now(timezone.utc).isoformat(),
              'root': str(RUN), 'file_count': len(items), 'files': items,
              'directory_count': len(directories), 'directories': directories,
              'symlink_count': len(symlinks), 'symlinks': symlinks,
              'other_count': len(other), 'other': other,
              'total_file_bytes': sum(item['bytes'] for item in items)}
    (RUN / 'archive_inventory.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(f'inventory: {len(items)} files')
    return 0


if __name__ == '__main__':
    if sys.argv[1:] == ['pre']:
        raise SystemExit(binding('pre'))
    if sys.argv[1:] == ['post']:
        raise SystemExit(binding('post'))
    if sys.argv[1:] == ['inventory']:
        raise SystemExit(inventory())
    raise SystemExit('usage: identity_check.py pre|post|inventory')
