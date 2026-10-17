#!/usr/bin/env python3
"""Create only the reviewed fourteen mode3 pages after a separate gate."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
REVIEW = BASE / 'results/attention_rtl_repair_20261008'
D2 = REVIEW / 'd2_controller_reachable'
GATE = REVIEW / 'reviewer_d2_i_vector_mode3_static_source_preparation_release.json'
FIXTURE = D2 / 'tb/fixture_v2'
MODEL = BASE / 'build/model-attention-rtl-repair-20261008'
PAGE = 4096
PORTS = ('src0_input', 'src1_input', 'io', 'aux', 'state0', 'state1', 'observed')
PAGES = {'src0_input': 1, 'src1_input': 1, 'io': 8, 'aux': 1,
         'state0': 1, 'state1': 1, 'observed': 1}
RAW_IN_PAGE = 16918976 - 16916480
MASKED_IN_PAGE = 16918592 - 16916480


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def load_frozen(name: str, report: dict) -> bytes:
    entry = report['files'][name]
    path = FIXTURE / (name + ('.f32.bin' if name != 'request' else '.bin'))
    if Path(entry['path']) != path:
        raise ValueError(f'fixture path mismatch: {name}')
    raw = path.read_bytes()
    if (len(raw), sha(raw)) != (entry['bytes'], entry['sha256']):
        raise ValueError(f'fixture bytes changed: {name}')
    return raw


def write_memh(path: Path, raw: bytes) -> dict:
    with path.open('x', encoding='ascii') as out:
        for byte in raw:
            out.write(f'{byte:02x}\n')
    return {'path': str(path.resolve()), 'payload_bytes': len(raw),
            'payload_sha256': sha(raw), 'memh_bytes': path.stat().st_size,
            'memh_sha256': sha(path.read_bytes())}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('fresh_output', type=Path)
    args = parser.parse_args()
    if args.fresh_output.exists():
        raise FileExistsError(args.fresh_output)
    gate_bytes = GATE.read_bytes()
    if sha(gate_bytes) != '853ff64b50b2fb1d879453e6aff8759222d5c949e94916cc0b26c8ac72882466':
        raise ValueError('mode3 preparation release changed')
    gate = json.loads(gate_bytes)
    report_path = FIXTURE / 'fixture_report.json'
    report_bytes = report_path.read_bytes()
    if sha(report_bytes) != gate['immutable_source_refs']['fixture_report']['sha256']:
        raise ValueError('frozen fixture report changed')
    report = json.loads(report_bytes)
    request = bytearray(load_frozen('request', report))
    candidate = load_frozen('candidate', report)
    gold = load_frozen('candidate_gold', report)
    if (len(request), len(candidate), len(gold),
        int.from_bytes(request[24:32], 'little'),
        int.from_bytes(request[32:40], 'little')) != (832, 64, 64, 301, 1):
        raise ValueError('frozen mode3 source shape')
    request[24:32] = (305).to_bytes(8, 'little')
    manifest = json.loads((MODEL / 'manifest.json').read_text())
    if sha((MODEL / 'manifest.json').read_bytes()) != report['package_manifest_sha256']:
        raise ValueError('model manifest changed')
    aux_entry = manifest['bo']['aux']
    aux_path = MODEL / aux_entry['file']
    aux = aux_path.read_bytes()
    if (len(aux), sha(aux)) != (aux_entry['size'], aux_entry['sha256']):
        raise ValueError('model aux BO changed')
    if sum(PAGES.values()) != gate['static_pages']['total'] or sum(PAGES.values()) != 14:
        raise ValueError('physical page contract')

    initial = {name: bytearray(b'\xa5' * (PAGES[name] * PAGE)) for name in PORTS}
    initial['src0_input'][:64] = candidate
    initial['io'][:] = b'\x00' * (8 * PAGE)
    initial['io'][:832] = request
    initial['aux'][:128] = aux[:128]
    final_state1 = bytearray(initial['state1'])
    final_state1[RAW_IN_PAGE:RAW_IN_PAGE+64] = candidate
    final_state1[MASKED_IN_PAGE:MASKED_IN_PAGE+64] = gold
    words = [0xffffffff] * 32
    for key, value in gate['exact_observed_words'].items():
        if key == '19_through31':
            assert value == '0xffffffff'
            continue
        words[int(key)] = value
    expected_observed = bytearray(initial['observed'])
    expected_observed[:128] = struct.pack('<32I', *words)
    if (len(set(words[19:])) != 1 or words[14:16] != [305, 1] or
        final_state1[RAW_IN_PAGE:RAW_IN_PAGE+64] != candidate or
        final_state1[MASKED_IN_PAGE:MASKED_IN_PAGE+64] != gold):
        raise ValueError('mode3 expected image contract')

    args.fresh_output.mkdir(parents=True)
    products = {}
    for name, raw in initial.items():
        products[f'init_{name}'] = write_memh(args.fresh_output / f'init_{name}.memh', raw)
    products['expected_state1'] = write_memh(args.fresh_output / 'expected_state1.memh', final_state1)
    products['expected_observed'] = write_memh(args.fresh_output / 'expected_observed.memh', expected_observed)
    report_out = {
        'schema': 'd2_i_vector_mode3_first_static_fixture_v1',
        'status': 'HOST_MATERIALIZED_NOT_CPU_OR_EDA_VALIDATED',
        'release_sha256': sha(gate_bytes),
        'frozen_fixture_report_sha256': sha(report_bytes),
        'source_request_sha256': report['files']['request']['sha256'],
        'patched_request_sha256': sha(request),
        'request_id_byte_offset': 24, 'request_id': 305,
        'source_candidate_sha256': sha(candidate), 'source_gold_sha256': sha(gold),
        'aux_header_sha256': sha(aux[:128]),
        'mapped_pages': PAGES, 'mapped_page_total': sum(PAGES.values()),
        'state1_raw_page_offset': RAW_IN_PAGE,
        'state1_masked_page_offset': MASKED_IN_PAGE,
        'products': products,
    }
    (args.fresh_output / 'fixture_report.json').write_text(
        json.dumps(report_out, indent=2, sort_keys=True) + '\n')
    print(f'D2_MODE3_FIXTURE_MATERIALIZED pages={sum(PAGES.values())} request_id=305')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
