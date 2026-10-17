#!/usr/bin/env python3
"""Future-gated, cold-only Type inputs on exactly 206 sparse physical pages.

This program only serializes already accepted bytes. It does not calculate a
Type row, binary output, or DUT result. Each qtype needs its own fresh output
directory and, later, its own fresh elaborated XSim process.
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
SOURCE_GATE = TASK / 'reviewer_d2_type_producer_actual_hls_cold_finite_rtl_source_preparation_release.json'
GATE_SHA = '0bb6b0c872858a406a279a4d3f7366d4d916fb2435ce1ce153ee6df0eea11c87'
BASE_PACKET = MODULE / 'source/source_packet.json'
MAPPING = MODULE / 'tb/static_mapping.json'
FIXTURE = TASK / 'd2_controller_reachable/tb/fixture_v2/fixture_report.json'
QTYPE1 = MODULE / 'runs/qtype1_materialization_v1/qtype1_fixture_report.json'
QTYPE1_SHA = '0c1d4a06617aff6b896ceeb9a8dd1d08eaa8ddf2b177c2f3ba84bf5826a07f9e'
PAGE = 4096
NAMES = ('hidden_input', 'embedding', 'io', 'aux', 'state0', 'state1', 'observed')


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def bound(entry: dict) -> bytes:
    path = Path(entry['path'])
    raw = path.read_bytes()
    if (len(raw), sha(raw)) != (entry['bytes'], entry['sha256']):
        raise ValueError(f'frozen source changed: {path}')
    return raw


def load_identity() -> tuple[dict, dict, dict, dict, dict, dict]:
    gate_raw = SOURCE_GATE.read_bytes()
    if sha(gate_raw) != GATE_SHA:
        raise ValueError('Type source release identity changed')
    gate = json.loads(gate_raw)
    packet = json.loads(bound(gate['frozen_base_packet']))
    fixture = json.loads(bound(packet['frozen_fixture_report']))
    model = json.loads(bound(packet['model_manifest']))
    mapping = json.loads(bound(gate['source_static_mapping']))
    qtype1_raw = QTYPE1.read_bytes()
    if sha(qtype1_raw) != QTYPE1_SHA:
        raise ValueError('accepted qtype1 fixture report changed')
    qtype1 = json.loads(qtype1_raw)
    if qtype1['status'] != 'INDEPENDENT_ORACLE_NOT_DUT_RESULT':
        raise ValueError('qtype1 oracle provenance changed')
    return gate, packet, fixture, model, mapping, qtype1


def write_memh(path: Path, raw: bytes) -> dict:
    with path.open('x', encoding='ascii') as out:
        for byte in raw:
            out.write(f'{byte:02x}\n')
    encoded = path.read_bytes()
    return {'path': str(path), 'raw_bytes': len(raw), 'raw_sha256': sha(raw),
            'encoded_bytes': len(encoded), 'encoded_sha256': sha(encoded)}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('case', choices=('qtype2', 'qtype1'))
    parser.add_argument('fresh_output', type=Path)
    args = parser.parse_args()
    if args.fresh_output.exists():
        raise FileExistsError(args.fresh_output)
    gate, packet, fixture, model, mapping, qtype1 = load_identity()
    if mapping['mapped_page_total'] != 206 or mapping['page_bytes'] != PAGE:
        raise ValueError('accepted sparse geometry changed')
    ports = mapping['top_ports']
    if tuple(p['name'] for p in ports) != NAMES:
        raise ValueError('seven port identities changed')
    hidden = bound(packet['hidden_ingress'])
    embedding = bound(packet['embedding_bo'])
    package = Path(packet['embedding_bo']['path']).parent
    aux_info = model['bo']['aux']
    aux = bound({'path': str(package / aux_info['file']), 'bytes': aux_info['size'],
                 'sha256': aux_info['sha256']})
    if len(hidden) != 64 * 1024 * 4 or len(aux) < PAGE:
        raise ValueError('hidden or aux source extent changed')
    if args.case == 'qtype2':
        request = bound(fixture['files']['request'])
        selected = bound(fixture['files']['type_rows'])[8192:12288]
        gold = bound(fixture['files']['type_gold'])
        type_id = 2
    else:
        request = bound(qtype1['files']['request'])
        selected = bound(qtype1['files']['row_reference'])
        gold = bound(qtype1['files']['gold'])
        type_id = 1
    if len(request) != 832 or len(selected) != PAGE or len(gold) != 64 * PAGE:
        raise ValueError('cold reference extent changed')
    if struct.unpack_from('<HHI', request, 20)[:2] != (1, 64) or \
            struct.unpack_from('<I', request, 768)[0] != type_id:
        raise ValueError('request B1/S64 or qtype changed')
    if struct.unpack_from('<Q', request, 24)[0] == 0 or \
            struct.unpack_from('<Q', request, 32)[0] == 0:
        raise ValueError('cold request identity absent')
    io = bytearray(8 * PAGE)
    io[:len(request)] = request
    # These are conceptual host BO prefill extents. Only mapped pages are
    # emitted into the simulator; the 16 MiB unmapped gaps are not modeled.
    state0 = b'\xa5' * 16_920_576
    state1 = b'\xa5' * 16_919_104
    observed = (struct.pack('<I', 0xdeadbeef) * 32) + b'\xa5' * (PAGE - 128)
    page_offsets = {}
    physical = set()
    for port in ports:
        offsets = []
        base = int(port['base_hex'], 16)
        capacity = port['capacity_bytes']
        for first, count in port['mapped_page_runs']:
            if first % PAGE:
                raise ValueError('unaligned mapped run')
            for i in range(count):
                offset = first + i * PAGE
                if not (0 <= offset < capacity):
                    raise ValueError(f'page begins outside BO: {port["name"]}')
                address = base + offset
                if address in physical:
                    raise ValueError('physical page alias')
                physical.add(address)
                offsets.append(offset)
        page_offsets[port['name']] = offsets
    if len(physical) != 206 or len(page_offsets['state0']) != 67:
        raise ValueError('page count changed')
    images = {
        'hidden_input': hidden,
        'embedding': embedding,
        'io': bytes(io),
        'aux': aux,
        'state0': state0,
        'state1': state1,
        'observed': observed,
    }
    args.fresh_output.mkdir(parents=True)
    generated = {}
    page_rows = []
    for port in ports:
        name = port['name']
        pieces = []
        for slot, offset in enumerate(page_offsets[name]):
            valid = min(PAGE, port['capacity_bytes'] - offset)
            payload = images[name][offset:offset + valid] + b'\xa5' * (PAGE - valid)
            if len(payload) != PAGE:
                raise ValueError(f'page source short: {name} slot {slot}')
            pieces.append(payload)
            page_rows.append({'port': name, 'slot': slot, 'bo_offset': offset,
                              'physical_base': int(port['base_hex'], 16) + offset,
                              'valid_bo_bytes': valid, 'raw_sha256': sha(payload)})
        generated[name] = write_memh(args.fresh_output / f'init_{name}.memh', b''.join(pieces))
    report = {
        'schema': 'd2_type_producer_cold_sparse_page_materialization_v1',
        'status': 'HOST_SOURCE_ONLY_NO_EDA', 'case': args.case,
        'source_release_sha256': GATE_SHA,
        'base_packet_sha256': gate['frozen_base_packet']['sha256'],
        'mapping_sha256': gate['source_static_mapping']['sha256'],
        'qtype1_fixture_report_sha256': QTYPE1_SHA,
        'source_identities': {
            'hidden_sha256': sha(hidden), 'embedding_sha256': sha(embedding),
            'aux_sha256': sha(aux), 'request_sha256': sha(request),
            'selected_type_row_sha256': sha(selected), 'gold_sha256': sha(gold),
        },
        'type_id': type_id, 'request_id': struct.unpack_from('<Q', request, 24)[0],
        'generation': struct.unpack_from('<Q', request, 32)[0],
        'mapped_page_count': len(page_rows), 'pages': page_rows,
        'generated': generated,
        'coverage': 'Only 206 mapped physical pages; no full BO dump claim.',
    }
    (args.fresh_output / 'materialization.json').write_text(
        json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(f'TYPE_COLD_MATERIALIZED case={args.case} pages={len(page_rows)}')


if __name__ == '__main__':
    main()
