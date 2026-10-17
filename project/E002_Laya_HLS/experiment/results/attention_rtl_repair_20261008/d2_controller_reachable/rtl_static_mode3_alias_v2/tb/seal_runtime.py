#!/usr/bin/env python3
"""Archive raw XSim evidence, including a failed run, without changing its exit code."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil

MUTABLE = (
    'vector_mode3_static/xsim_script.tcl',
    'vector_mode3_static/xsimSettings.ini',
    'vector_mode3_static/xsimkernel.log',
    'vector_mode3_static/xsimcrash.log',
)
RAW = ('xsim.log', 'state1_raw.hex', 'observed_raw.hex')


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            h.update(block)
    return h.hexdigest()


def info(path: Path) -> dict:
    return {'bytes': path.stat().st_size, 'sha256': sha(path)}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('packet', type=Path)
    ap.add_argument('static_build_root', type=Path)
    ap.add_argument('runtime_root', type=Path)
    ap.add_argument('xsim_exit_code', type=int)
    args = ap.parse_args()
    packet = json.loads(args.packet.read_text())
    paths = packet['paths']
    if packet['schema'] != 'd2_i_vector_mode3_exact_source_packet_v1' or \
       str(args.packet.resolve()) != paths['source_packet'] or \
       str(args.static_build_root.resolve()) != paths['static_build_root'] or \
       str(args.runtime_root.resolve()) != paths['runtime_root']:
        raise ValueError('runtime seal path binding')
    snapshot = Path(paths['snapshot_root'])
    baseline_path = Path(paths['snapshot_manifest'])
    baseline = json.loads(baseline_path.read_text())
    if baseline['schema'] != 'd2_i_mode3_compiled_snapshot_manifest_v1' or \
       baseline['snapshot_root'] != str(snapshot.resolve()):
        raise ValueError('static snapshot baseline binding')
    runtime = args.runtime_root
    archive = runtime / 'snapshot_runtime_artifacts'
    archive.mkdir(parents=False, exist_ok=False)
    archived = {}
    for relative in MUTABLE:
        source = snapshot / relative
        if source.is_file():
            target = archive / Path(relative).name
            shutil.copy2(source, target)
            archived[relative] = {'present': True, 'source': info(source),
                                  'archive_path': str(target), 'archive': info(target)}
            if archived[relative]['source'] != archived[relative]['archive']:
                raise ValueError(f'archive copy changed: {relative}')
        else:
            archived[relative] = {'present': False}
    baseline_files = baseline['files']
    mutable_missing = [name for name in MUTABLE if not archived[name]['present']]
    current_files = {str(path.relative_to(snapshot)): path for path in snapshot.rglob('*') if path.is_file()}
    nonmutable_changed = []
    for relative in sorted((set(baseline_files) | set(current_files)) - set(MUTABLE)):
        path = current_files.get(relative)
        if path is None or relative not in baseline_files or info(path) != baseline_files[relative]:
            nonmutable_changed.append(relative)
    raw = {}
    for name in RAW:
        path = runtime / name
        raw[name] = {'present': path.is_file(), **(info(path) if path.is_file() else {})}
    report = {
        'schema': 'd2_i_mode3_runtime_seal_v1',
        'status': ('SNAPSHOT_OTHER_FILES_CHANGED' if nonmutable_changed else
                   'SNAPSHOT_MUTABLE_MISSING' if args.xsim_exit_code == 0 and mutable_missing else
                   'SNAPSHOT_OTHER_FILES_UNCHANGED'),
        'xsim_exit_code': args.xsim_exit_code,
        'static_snapshot_manifest': str(baseline_path),
        'static_snapshot_manifest_sha256': sha(baseline_path),
        'mutable_artifacts': archived,
        'mutable_missing': mutable_missing,
        'unexpected_snapshot_changes': nonmutable_changed,
        'raw_runtime_files': raw,
    }
    output = runtime / 'runtime_seal.json'
    with output.open('x') as stream:
        json.dump(report, stream, indent=2, sort_keys=True)
        stream.write('\n')
    print('D2_MODE3_RUNTIME_SEALED xsim_exit=', args.xsim_exit_code,
          'mutable_present=', sum(item['present'] for item in archived.values()),
          'nonmutable_changed=', len(nonmutable_changed))
    return 0 if not nonmutable_changed and (args.xsim_exit_code != 0 or not mutable_missing) else 1


if __name__ == '__main__':
    raise SystemExit(main())
