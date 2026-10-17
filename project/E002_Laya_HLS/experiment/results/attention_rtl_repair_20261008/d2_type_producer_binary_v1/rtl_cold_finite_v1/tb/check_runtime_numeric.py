#!/usr/bin/env python3
"""Future-gated exact check of all 206 dumped Type physical pages.

The input is seven XSim hex dumps of only mapped pages. This checker never
calls a model or calculates a new numerical gold value; it compares frozen
native ingress, independent Type-row and full 65,536-word output references.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct


BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
TASK = BASE / 'results/attention_rtl_repair_20261008'
MODULE = TASK / 'd2_type_producer_binary_v1'
GATE = TASK / 'reviewer_d2_type_producer_actual_hls_cold_finite_rtl_source_preparation_release.json'
GATE_SHA = '0bb6b0c872858a406a279a4d3f7366d4d916fb2435ce1ce153ee6df0eea11c87'
QTYPE1 = MODULE / 'runs/qtype1_materialization_v1/qtype1_fixture_report.json'
QTYPE1_SHA = '0c1d4a06617aff6b896ceeb9a8dd1d08eaa8ddf2b177c2f3ba84bf5826a07f9e'
PAGE = 4096
PORTS = ('hidden_input', 'embedding', 'io', 'aux', 'state0', 'state1', 'observed')


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def bound(info: dict) -> bytes:
    path = Path(info['path'])
    raw = path.read_bytes()
    if (len(raw), sha(raw)) != (info['bytes'], info['sha256']):
        raise ValueError(f'frozen source changed: {path}')
    return raw


def raw_dump(path: Path, size: int) -> bytes:
    text = path.read_text(encoding='ascii')
    if len(text) != size * 2 + 1 or not text.endswith('\n') or \
            any(ch not in '0123456789abcdef' for ch in text[:-1]):
        raise ValueError(f'noncanonical or incomplete dump: {path}')
    return bytes.fromhex(text[:-1])


def compare(name: str, actual: bytes, expected: bytes) -> dict:
    if len(actual) != len(expected):
        raise ValueError(f'{name} extent actual={len(actual)} expected={len(expected)}')
    first = next((i for i, (a, b) in enumerate(zip(actual, expected)) if a != b), None)
    if first is not None:
        raise ValueError(f'{name} first byte mismatch offset={first} '
                         f'actual={actual[first]:02x} expected={expected[first]:02x}')
    return {'name': name, 'bytes': len(actual), 'sha256': sha(actual), 'exact': True}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('case', choices=('qtype2', 'qtype1'))
    parser.add_argument('runtime_dir', type=Path)
    parser.add_argument('fresh_report', type=Path)
    args = parser.parse_args()
    if args.fresh_report.exists():
        raise FileExistsError(args.fresh_report)
    gate_raw = GATE.read_bytes()
    if sha(gate_raw) != GATE_SHA:
        raise ValueError('source release changed')
    gate = json.loads(gate_raw)
    base = json.loads(bound(gate['frozen_base_packet']))
    fixture = json.loads(bound(base['frozen_fixture_report']))
    mapping = json.loads(bound(gate['source_static_mapping']))
    manifest = json.loads(bound(base['model_manifest']))
    q1_raw = QTYPE1.read_bytes()
    if sha(q1_raw) != QTYPE1_SHA:
        raise ValueError('accepted qtype1 report changed')
    q1 = json.loads(q1_raw)
    hidden = bound(base['hidden_ingress'])
    embedding = bound(base['embedding_bo'])
    aux_info = manifest['bo']['aux']
    aux = bound({'path': str(Path(base['embedding_bo']['path']).parent / aux_info['file']),
                 'bytes': aux_info['size'], 'sha256': aux_info['sha256']})
    if args.case == 'qtype2':
        request = bound(fixture['files']['request'])
        row = bound(fixture['files']['type_rows'])[2 * PAGE:3 * PAGE]
        gold = bound(fixture['files']['type_gold'])
        qtype = 2
    else:
        request = bound(q1['files']['request'])
        row = bound(q1['files']['row_reference'])
        gold = bound(q1['files']['gold'])
        qtype = 1
    if len(hidden) != 64 * PAGE or len(row) != PAGE or len(gold) != 64 * PAGE or \
            len(request) != 832 or int.from_bytes(request[768:772], 'little') != qtype:
        raise ValueError('frozen Type reference geometry changed')
    if tuple(p['name'] for p in mapping['top_ports']) != PORTS or \
            mapping['mapped_page_total'] != 206:
        raise ValueError('mapped Type page geometry changed')
    actual = {}
    checked = []
    for port in mapping['top_ports']:
        name = port['name']
        count = sum(run[1] for run in port['mapped_page_runs'])
        actual[name] = raw_dump(args.runtime_dir / f'dump_{name}.hex', count * PAGE)
    checked.append(compare('hidden_input_64_pages', actual['hidden_input'], hidden))
    checked.append(compare('embedding_selected_tail_page', actual['embedding'],
                           embedding[54_800_384:54_803_648] + b'\xa5' * (PAGE - 3264)))
    checked.append(compare('io_8_pages_request_and_zero_tail', actual['io'],
                           request + b'\x00' * (8 * PAGE - len(request))))
    checked.append(compare('aux_first_page', actual['aux'], aux[:PAGE]))
    case = next(x for x in mapping['qtype_cases'] if x['qtype'] == qtype)
    if case['type_f32_row_byte_offset'] not in (16_912_384, 16_916_480):
        raise ValueError('selected TYPE_ROWS offset changed')
    state0_expected = bytearray(b'\xa5' * (67 * PAGE))
    state0_expected[:64 * PAGE] = hidden
    selected_slot = 64 + (case['type_f32_row_byte_offset'] - 16_908_288) // PAGE
    state0_expected[selected_slot * PAGE:(selected_slot + 1) * PAGE] = row
    checked.append(compare('state0_ingress_selected_row_and_two_sentinels',
                           actual['state0'], state0_expected))
    checked.append(compare('state1_all_65536_f32_words', actual['state1'], gold))
    observed_words = [0, 0, 5, 5, 5, 3, 1, 1, 1, 0, 0, 1, 4, qtype,
                      int.from_bytes(request[24:28], 'little'),
                      int.from_bytes(request[32:36], 'little'),
                      0, 2, 1, 0xffffffff, 0xffffffff, 0, 0, 0, 0, 0, 0, 0, 0,
                      1, 0, 1]
    if len(observed_words) != 32:
        raise ValueError('observed contract word count')
    observed_expected = struct.pack('<32I', *observed_words) + b'\xa5' * (PAGE - 128)
    checked.append(compare('observed_32_words_and_outside_BO_tail',
                           actual['observed'], observed_expected))
    result = {'schema': 'd2_type_producer_cold_full_sparse_runtime_numeric_check_v1',
              'status': 'PASS_EXACT_206_MAPPED_PAGES_NO_FULL_BO_DUMP_CLAIM',
              'case': args.case, 'source_release_sha256': GATE_SHA,
              'mapped_pages_checked': 206,
              'mapped_bytes_checked': sum(len(x) for x in actual.values()),
              'independent_frozen_row_sha256': sha(row),
              'independent_frozen_output_sha256': sha(gold),
              'selected_state0_slot': selected_slot,
              'checks': checked,
              'coverage': 'All modeled physical pages, with forbidden-access assertions in the TB; '
                          'unmapped BO gaps are not dumped.'}
    if result['mapped_bytes_checked'] != 206 * PAGE:
        raise ValueError('mapped byte coverage changed')
    args.fresh_report.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(f'TYPE_COLD_NUMERIC_PASS case={args.case} pages=206 words=65536')


if __name__ == '__main__':
    main()
