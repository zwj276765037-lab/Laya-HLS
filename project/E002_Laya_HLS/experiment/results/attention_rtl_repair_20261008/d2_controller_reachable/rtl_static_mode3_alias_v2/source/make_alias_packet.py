#!/usr/bin/env python3
"""Seal the approved alias-only Mode3 overlay; no compiler or simulation."""

from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path


BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
REVIEW = BASE / 'results/attention_rtl_repair_20261008'
D2 = REVIEW / 'd2_controller_reachable'
V1 = D2 / 'rtl_static_mode3_v1'
ROOT = D2 / 'rtl_static_mode3_alias_v2'
TB = ROOT / 'tb'
OUT = ROOT / 'source/source_packet.json'
STATIC = ROOT / 'runs/static_build_alias_v2_a1'
RUNTIME = ROOT / 'runs/rtl_mode3_alias_v2_runtime_held'
RELEASE = REVIEW / 'reviewer_d2_i_mode3_alias_compatibility_bounded_frontend_release.json'
BASE_PACKET = V1 / 'source/source_packet.json'
ALIAS = TB / 'vector_mode3_control.svh'
DIFF = ROOT / 'source/alias_only.diff'
PREPARED = V1 / 'runs/materialize_mode3_v1/prepared'


def sha(path: Path) -> str:
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            value.update(block)
    return value.hexdigest()


def record(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(path)
    return {'path': str(path.resolve()), 'bytes': path.stat().st_size,
            'mode': oct(path.stat().st_mode & 0o777), 'sha256': sha(path)}


def assert_record(expected: dict) -> None:
    path = Path(expected['path'])
    actual = record(path)
    if (actual['bytes'], actual['sha256']) != (expected['bytes'], expected['sha256']):
        raise ValueError(f'frozen record changed: {path}')


def main() -> None:
    release = json.loads(RELEASE.read_text())
    if release['status'] != 'PRIOR_FAILURE_PRESERVED_ALIAS_ONLY_DESIGN_ACCEPTED_BOUNDED_STATIC_FRONTEND_RELEASED_RUNTIME_HELD':
        raise ValueError('reviewer release status')
    for info in release['evidence']:
        assert_record(info)
    if sha(RELEASE) != '9376ba89704e181680ffb5a7d554a122d7b18c0849909cd236c465bfb9146097':
        raise ValueError('reviewer release changed')
    if sha(BASE_PACKET) != 'fb97329debfda7e3277aeda940af28d1ef1ecd7f422d3e708c8514a7d8d133dc':
        raise ValueError('frozen V1 packet changed')
    candidate = json.loads((V1 / 'runs/clocking_alias_candidate_v1/candidate_manifest.json').read_text())
    if len(candidate['alias_names']) != 19 or \
       sha(ALIAS) != candidate['candidate_sha256'] or \
       sha(DIFF) != candidate['diff_sha256']:
        raise ValueError('exact 19-alias candidate binding')
    if sha(V1 / 'tb/vector_mode3_control.svh') != candidate['preimage_sha256']:
        raise ValueError('frozen source preimage changed')

    v1 = json.loads(BASE_PACKET.read_text())
    packet = dict(v1)
    packet['created_utc'] = datetime.now(timezone.utc).isoformat()
    packet['status'] = 'ALIAS_ONLY_STATIC_FRONTEND_RELEASED_RUNTIME_HELD_NOT_YET_EXECUTED'
    packet['overlay_schema'] = 'd2_i_mode3_alias_compatibility_overlay_v2_a1'
    packet['reviewer_release'] = record(RELEASE)
    packet['base_source_packet'] = record(BASE_PACKET)
    packet['exact_candidate'] = {
        'alias_count': 19, 'control': record(ALIAS), 'diff': record(DIFF),
        'preimage': record(V1 / 'tb/vector_mode3_control.svh'),
        'candidate_manifest': record(V1 / 'runs/clocking_alias_candidate_v1/candidate_manifest.json'),
    }
    packet['authority'] = list(v1['authority']) + [record(RELEASE)] + \
        [record(Path(info['path'])) for info in release['evidence']]
    local = sorted(p for p in TB.iterdir() if p.is_file() and
                   p.suffix in ('.py', '.sh', '.sv', '.svh'))
    local += [ROOT / 'source/design.md', ROOT / 'source/results.md', DIFF,
              ROOT / 'source/make_alias_packet.py', ROOT / 'rtl/README.md']
    packet['local_active_sources'] = [record(p) for p in local]
    packet['paths'] = dict(v1['paths'])
    packet['paths'].update({
        'module_root': str(ROOT), 'tb_root': str(TB),
        'static_build_root': str(STATIC),
        'snapshot_root': str(STATIC / 'xsim.dir'),
        'snapshot_manifest': str(STATIC / 'snapshot_manifest.json'),
        'runtime_root': str(RUNTIME),
        'prepared_root': str(PREPARED),
        'source_packet': str(OUT),
    })
    packet['compile_argv'] = dict(v1['compile_argv'])
    packet['compile_argv']['xvlog_tb'] = [
        arg.replace(str(V1 / 'tb'), str(TB))
        for arg in v1['compile_argv']['xvlog_tb']]
    packet['stage_argv_source_only'] = {
        'source_check': ['python3', str(TB / 'verify_binding.py'),
                         str(OUT), '--stage', 'source'],
        'fresh_build_preflight': ['python3', str(TB / 'verify_binding.py'),
                                  str(OUT), '--stage', 'build',
                                  '--static-build-root', str(STATIC),
                                  '--fresh-library-hashes'],
        'static_build_released_once': ['/usr/bin/bash', str(TB / 'build_static.sh'),
                                        str(STATIC)],
        'static_guard_released_once': ['python3', str(D2 / 'source/guard_16g.py'),
            '--out', str(STATIC / 'guard'), '--cwd', str(STATIC),
            '--rss-gib', '16', '--timeout-seconds', '300', '--',
            '/usr/bin/bash', str(TB / 'build_static.sh'), str(STATIC)],
        'snapshot_seal_after_success': ['python3', str(TB / 'seal_snapshot.py'),
                                         str(STATIC / 'xsim.dir'),
                                         str(STATIC / 'snapshot_manifest.json')],
        'runtime_NOT_RELEASED': ['/usr/bin/bash', str(TB / 'run_mode3.sh'),
                                 str(STATIC), str(RUNTIME), str(PREPARED),
                                 '131072', '140000'],
    }
    packet['reused_prepared_pages'] = [record(p) for p in sorted(PREPARED.iterdir())
                                       if p.is_file()]
    packet['reused_cpu_gold_evidence'] = [
        record(V1 / 'runs/cpu_gold_mode3_v1.json'),
        record(V1 / 'runs/cpu_gold_mode3_v1_evidence.json'),
        record(V1 / 'runs/materialize_mode3_v1_bytes_check_evidence.json')]
    packet['prior_static_failure'] = record(
        V1 / 'runs/mode3_ordered_attempt_evidence_v1.json')
    packet['bounded_attempt'] = {'ordinal': 1, 'maximum': 3,
                                 'rss_gib': 16, 'wall_seconds': 300,
                                 'runtime_released': False}
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + '\n')
    print('D2_MODE3_ALIAS_PACKET_PREPARED', OUT,
          'local=', len(local), 'pages=', len(packet['reused_prepared_pages']),
          'sha256=', sha(OUT))


if __name__ == '__main__':
    main()
