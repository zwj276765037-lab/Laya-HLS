#!/usr/bin/env python3
"""Guarded real v4 package scan and offline memory upload/readback exercise."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import time

from t3_offline_session import Candidate, MemoryEndpoint, PROFILE, State, StaticModelSession
from t3_static_model import digest_bytes


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    package = args.package.resolve()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((package / 'manifest.json').read_bytes())
    build_path = package / manifest['tag_preimages']['build']['file']
    candidate = Candidate(tags=manifest['tags'], kernel_sha256=sha(build_path))
    session = StaticModelSession(package, candidate, device='offline-memory-device-0',
                                 context='offline-memory-context-0',
                                 endpoint=MemoryEndpoint())
    start = time.perf_counter()
    first = session.prepare(out / 'validated_model.json')
    matrix = session.record['matrices'][0]
    key = tuple(matrix['WeightKey'])
    request = {'profile': PROFILE, 'candidate': candidate,
               'record_sha256': session.record_sha256,
               'allocations': {}, 'weight_key': key,
               'K': matrix['K'], 'N': matrix['N'],
               'cache_epoch': session.cache_epoch}
    assert not session.authorize_load(generation=session.generation, **request)
    session.upload()
    assert not session.authorize_load(generation=session.generation, **request)
    session.verify_readback()
    assert not session.authorize_load(generation=session.generation, **request)
    first_active = session.activate()
    first_cost = session.cost_seconds.copy()
    request['allocations'] = session.allocations.copy()
    assert session.authorize_load(generation=session.generation, **request)
    assert not session.authorize_load(generation=session.generation - 1, **request)
    assert not session.authorize_load(generation=session.generation,
                                      **{**request, 'allocations': {'w_scale': 'old-handle'}})
    warm = session.warm_reuse()
    assert warm['scale_scan_count'] == 1 and session.state == State.ACTIVE
    (out / 'active_session.json').write_text(json.dumps(first_active, indent=2, sort_keys=True) + '\n')
    old_generation = session.generation
    old_allocations = session.allocations.copy()
    session.reset()
    assert not session.authorize_load(generation=old_generation, **request)
    second = session.prepare(out / 'validated_model_after_reset.json')
    session.upload()
    session.verify_readback()
    second_active = session.activate()
    second_cost = session.cost_seconds.copy()
    request['record_sha256'] = session.record_sha256
    request['allocations'] = session.allocations.copy()
    assert session.generation > old_generation
    assert session.allocations != old_allocations
    assert session.scale_scan_count == 2
    assert session.authorize_load(generation=session.generation, **request)
    (out / 'active_session_after_reset.json').write_text(
        json.dumps(second_active, indent=2, sort_keys=True) + '\n')
    report = {'schema': 'laya-t3-offline-session-report-v1', 'status': 'PASS',
              'scope': 'v4 package CPU scan and offline memory endpoint only',
              'production_kernel_integration': 'NOT_RUN',
              'xrt_pcie_hbm_readback': 'NOT_MEASURED',
              'package': str(package), 'manifest_sha256': sha(package / 'manifest.json'),
              'candidate_fixture_build_preimage_sha256': sha(build_path),
              'first': first, 'second': second,
              'first_session_sha256': sha(out / 'active_session.json'),
              'second_session_sha256': sha(out / 'active_session_after_reset.json'),
              'first_record_sha256': sha(out / 'validated_model.json'),
              'second_record_sha256': sha(out / 'validated_model_after_reset.json'),
              'scan_count': session.scale_scan_count,
              'warm_reuse': warm,
              'cost_seconds': {'first': first_cost, 'after_reset': second_cost},
              'total_seconds': time.perf_counter() - start}
    raw = (json.dumps(report, indent=2, sort_keys=True) + '\n').encode()
    (out / 'report.json').write_bytes(raw)
    print(json.dumps({'status': 'PASS', 'report_sha256': digest_bytes(raw),
                      'scan_count': session.scale_scan_count,
                      'total_seconds': report['total_seconds']}))


if __name__ == '__main__':
    main()
