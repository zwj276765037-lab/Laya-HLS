#!/usr/bin/env python3
"""Future-gated independent byte audit of the 206 cold mapped pages."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
TASK = BASE / 'results/attention_rtl_repair_20261008'
MODULE = TASK / 'd2_type_producer_binary_v1'
SOURCE_GATE = TASK / 'reviewer_d2_type_producer_actual_hls_cold_finite_rtl_source_preparation_release.json'
GATE_SHA = '0bb6b0c872858a406a279a4d3f7366d4d916fb2435ce1ce153ee6df0eea11c87'
QTYPE1 = MODULE / 'runs/qtype1_materialization_v1/qtype1_fixture_report.json'
QTYPE1_SHA = '0c1d4a06617aff6b896ceeb9a8dd1d08eaa8ddf2b177c2f3ba84bf5826a07f9e'
PAGE = 4096


def checksum(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_bound(item: dict) -> bytes:
    data = Path(item['path']).read_bytes()
    if len(data) != item['bytes'] or checksum(data) != item['sha256']:
        raise ValueError(f'bound source changed: {item["path"]}')
    return data


def decode(path: Path) -> bytes:
    encoded = path.read_bytes()
    if len(encoded) % 3 or not encoded.endswith(b'\n'):
        raise ValueError(f'invalid memh length: {path}')
    if any(encoded[i + 2] != 10 for i in range(0, len(encoded), 3)):
        raise ValueError(f'invalid memh line ending: {path}')
    if any(byte not in b'0123456789abcdef' for i, byte in enumerate(encoded)
           if i % 3 != 2):
        raise ValueError(f'noncanonical memh digit: {path}')
    return bytes(int(encoded[i:i + 2], 16) for i in range(0, len(encoded), 3))


def first_difference(actual: bytes, expected: bytes) -> int | None:
    if len(actual) != len(expected):
        return min(len(actual), len(expected))
    return next((i for i, (a, b) in enumerate(zip(actual, expected)) if a != b), None)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('case', choices=('qtype2', 'qtype1'))
    parser.add_argument('prepared', type=Path)
    parser.add_argument('fresh_report', type=Path)
    args = parser.parse_args()
    if args.fresh_report.exists():
        raise FileExistsError(args.fresh_report)
    gate_raw = SOURCE_GATE.read_bytes()
    if checksum(gate_raw) != GATE_SHA:
        raise ValueError('source release changed')
    gate = json.loads(gate_raw)
    base = json.loads(read_bound(gate['frozen_base_packet']))
    fixture = json.loads(read_bound(base['frozen_fixture_report']))
    model = json.loads(read_bound(base['model_manifest']))
    mapping = json.loads(read_bound(gate['source_static_mapping']))
    qtype1_raw = QTYPE1.read_bytes()
    if checksum(qtype1_raw) != QTYPE1_SHA:
        raise ValueError('qtype1 report changed')
    qtype1 = json.loads(qtype1_raw)
    hidden = read_bound(base['hidden_ingress'])
    embedding = read_bound(base['embedding_bo'])
    aux_info = model['bo']['aux']
    aux = read_bound({'path': str(Path(base['embedding_bo']['path']).parent / aux_info['file']),
                      'bytes': aux_info['size'], 'sha256': aux_info['sha256']})
    if args.case == 'qtype2':
        request = read_bound(fixture['files']['request'])
        selected = read_bound(fixture['files']['type_rows'])[2 * PAGE:3 * PAGE]
        gold = read_bound(fixture['files']['type_gold'])
        qtype = 2
    else:
        request = read_bound(qtype1['files']['request'])
        selected = read_bound(qtype1['files']['row_reference'])
        gold = read_bound(qtype1['files']['gold'])
        qtype = 1
    if len(request) != 832 or len(selected) != PAGE or len(gold) != 64 * PAGE:
        raise ValueError('reference extent changed')
    if int.from_bytes(request[768:772], 'little') != qtype:
        raise ValueError('request type changed')
    io = request + b'\x00' * (8 * PAGE - len(request))
    observed = b'\xef\xbe\xad\xde' * 32 + b'\xa5' * (PAGE - 128)
    expected_files = {f'init_{p["name"]}.memh' for p in mapping['top_ports']}
    if {p.name for p in args.prepared.glob('*.memh')} != expected_files:
        raise ValueError('page file set changed')
    materialized_path = args.prepared / 'materialization.json'
    materialized = json.loads(materialized_path.read_text())
    if materialized['schema'] != 'd2_type_producer_cold_sparse_page_materialization_v1' or \
            materialized['case'] != args.case or materialized['mapped_page_count'] != 206:
        raise ValueError('materialization identity changed')
    expected_sources = {'hidden_sha256': checksum(hidden),
                        'embedding_sha256': checksum(embedding),
                        'aux_sha256': checksum(aux),
                        'request_sha256': checksum(request),
                        'selected_type_row_sha256': checksum(selected),
                        'gold_sha256': checksum(gold)}
    if materialized['source_identities'] != expected_sources:
        raise ValueError('materialized source identities changed')
    checked_pages = []
    all_addresses = set()
    for port in mapping['top_ports']:
        name = port['name']
        actual = decode(args.prepared / f'init_{name}.memh')
        offsets = [start + i * PAGE for start, count in port['mapped_page_runs']
                   for i in range(count)]
        if len(actual) != PAGE * len(offsets):
            raise ValueError(f'wrong serialized page count: {name}')
        for slot, offset in enumerate(offsets):
            page = actual[slot * PAGE:(slot + 1) * PAGE]
            valid = min(PAGE, port['capacity_bytes'] - offset)
            if valid <= 0:
                raise ValueError(f'page outside BO: {name} {slot}')
            if name == 'hidden_input':
                expected = hidden[offset:offset + valid]
            elif name == 'embedding':
                expected = embedding[offset:offset + valid]
            elif name == 'io':
                expected = io[offset:offset + valid]
            elif name == 'aux':
                expected = aux[offset:offset + valid]
            elif name == 'observed':
                expected = observed[offset:offset + valid]
            else:
                expected = b'\xa5' * valid
            expected += b'\xa5' * (PAGE - valid)
            diff = first_difference(page, expected)
            if diff is not None:
                raise ValueError(f'first page mismatch {name} slot={slot} byte={diff}')
            address = int(port['base_hex'], 16) + offset
            if address in all_addresses:
                raise ValueError(f'physical alias: {name} slot={slot}')
            all_addresses.add(address)
            checked_pages.append({'port': name, 'slot': slot, 'bo_offset': offset,
                                  'physical_base': address, 'valid_bo_bytes': valid,
                                  'raw_sha256': checksum(page)})
        info = materialized['generated'][name]
        encoded = (args.prepared / f'init_{name}.memh').read_bytes()
        if (info['raw_bytes'], info['raw_sha256'], info['encoded_bytes'],
                info['encoded_sha256']) != (len(actual), checksum(actual),
                                            len(encoded), checksum(encoded)):
            raise ValueError(f'encoded identity changed: {name}')
    if len(checked_pages) != 206 or checked_pages != materialized['pages']:
        raise ValueError('materialized page table changed')
    report = {'schema': 'd2_type_producer_cold_independent_page_audit_v1',
              'status': 'PASS_NO_EDA', 'case': args.case,
              'materialization_sha256': checksum(materialized_path.read_bytes()),
              'source_release_sha256': GATE_SHA,
              'mapped_page_count': len(checked_pages),
              'mapped_bytes': len(checked_pages) * PAGE,
              'source_identities': expected_sources,
              'pages': checked_pages}
    args.fresh_report.write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(f'TYPE_COLD_PAGES_VERIFIED case={args.case} pages={len(checked_pages)}')


if __name__ == '__main__':
    main()
