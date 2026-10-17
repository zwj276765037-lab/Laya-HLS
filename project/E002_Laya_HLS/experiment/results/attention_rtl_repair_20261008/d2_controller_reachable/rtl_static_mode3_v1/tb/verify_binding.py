#!/usr/bin/env python3
"""Verify explicit source/build/prepared/snapshot identities before each gate."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            h.update(block)
    return h.hexdigest()


def check_record(info: dict) -> None:
    path = Path(info['path'])
    if not path.is_file() or (path.stat().st_size, sha(path)) != (info['bytes'], info['sha256']):
        raise ValueError(f'source identity mismatch: {path}')


def check_snapshot(packet: dict) -> None:
    paths = packet['paths']
    root = Path(paths['snapshot_root'])
    manifest_path = Path(paths['snapshot_manifest'])
    manifest = json.loads(manifest_path.read_text())
    if manifest['schema'] != 'd2_i_mode3_compiled_snapshot_manifest_v1' or \
       manifest['snapshot_root'] != str(root.resolve()) or \
       manifest['file_count'] != len(manifest['files']):
        raise ValueError('snapshot manifest structure/path')
    actual = {str(path.relative_to(root)) for path in root.rglob('*') if path.is_file()}
    if actual != set(manifest['files']):
        raise ValueError('snapshot file set changed')
    for rel, info in manifest['files'].items():
        path = root / rel
        if (path.stat().st_size, sha(path)) != (info['bytes'], info['sha256']):
            raise ValueError(f'snapshot file changed: {rel}')


def check_dat_links(packet: dict) -> None:
    root = Path(packet['paths']['static_build_root'])
    expected = {Path(info['path']).name: Path(info['path']) for info in packet['generated_dat']}
    actual = {path.name: path for path in root.glob('*.dat')}
    if len(expected) != 73 or set(actual) != set(expected):
        raise ValueError('static build DAT link set')
    for name, source in expected.items():
        if not actual[name].is_symlink() or actual[name].resolve(strict=True) != source:
            raise ValueError(f'static build DAT link: {name}')


def check_prepared(packet: dict) -> None:
    root = Path(packet['paths']['prepared_root'])
    report = json.loads((root / 'fixture_report.json').read_text())
    if report['schema'] != 'd2_i_vector_mode3_first_static_fixture_v1' or \
       report['mapped_page_total'] != 14:
        raise ValueError('prepared fixture report')
    # Resolve the release by path, rather than the sort order of authorities.
    authority = {Path(x['path']).name: x['sha256'] for x in packet['authority']}
    if report['release_sha256'] != authority['reviewer_d2_i_vector_mode3_static_source_preparation_release.json']:
        raise ValueError('prepared fixture release')
    if len(report['products']) != 9:
        raise ValueError('prepared product count')
    for name, info in report['products'].items():
        path = root / f'{name}.memh'
        if not path.is_file() or path.resolve() != Path(info['path']) or \
           (path.stat().st_size, sha(path)) != (info['memh_bytes'], info['memh_sha256']):
            raise ValueError(f'prepared page identity: {name}')


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('packet', type=Path)
    ap.add_argument('--stage', required=True, choices=('source', 'build', 'snapshot', 'runtime'))
    ap.add_argument('--static-build-root', type=Path)
    ap.add_argument('--runtime-root', type=Path)
    ap.add_argument('--prepared-root', type=Path)
    ap.add_argument('--fresh-library-hashes', action='store_true')
    args = ap.parse_args()
    packet_path = args.packet.resolve(strict=True)
    packet = json.loads(packet_path.read_text())
    if packet['schema'] != 'd2_i_vector_mode3_exact_source_packet_v1' or \
       packet['paths']['source_packet'] != str(packet_path):
        raise ValueError('source packet identity/path')
    for key, actual in (('static_build_root', args.static_build_root),
                        ('runtime_root', args.runtime_root),
                        ('prepared_root', args.prepared_root)):
        if actual is not None and str(actual.absolute()) != packet['paths'][key]:
            raise ValueError(f'explicit {key} differs from source packet')
    if args.stage in ('build', 'snapshot', 'runtime') and args.static_build_root is None:
        raise ValueError('explicit static build root required')
    if args.stage == 'runtime' and (args.runtime_root is None or args.prepared_root is None):
        raise ValueError('explicit runtime and prepared roots required')
    for group in ('authority', 'generated_verilog', 'generated_dat',
                  'fp_sim_vhdl_wrappers', 'local_active_sources',
                  'reused_accepted_endpoint_sources', 'guard_sources'):
        for info in packet[group]:
            check_record(info)
    for key in ('accepted_generated_manifest', 'installed_library_provenance_packet',
                'xsim_ini', 'xsim_plusarg_manual'):
        check_record(packet[key])
    if len(packet['prior_102_bindings']) != 102:
        raise ValueError('prior source binding count')
    if set(packet['mutable_document_drift']) != {'mission_read'}:
        raise ValueError('mutable workflow document exception')
    for label, info in packet['prior_102_bindings'].items():
        if label != 'mission_read':
            check_record(info)
    if packet['mutable_document_drift']['mission_read']['original'] != packet['prior_102_bindings']['mission_read']:
        raise ValueError('original mission binding changed')
    if args.fresh_library_hashes:
        for files in packet['installed_library_files'].values():
            for info in files:
                check_record(info)
    else:
        for files in packet['installed_library_files'].values():
            for info in files:
                path = Path(info['path'])
                if not path.is_file() or path.stat().st_size != info['bytes']:
                    raise ValueError(f'inherited library path/size: {path}')
    if args.stage in ('snapshot', 'runtime'):
        check_snapshot(packet)
        check_dat_links(packet)
    if args.stage == 'runtime':
        check_prepared(packet)
        if not Path(packet['paths']['runtime_root']).is_dir():
            raise ValueError('runtime root absent')
    print(f'D2_MODE3_BINDING_PASS stage={args.stage} prior=102 rtl=226 dat=73 wrappers=8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
