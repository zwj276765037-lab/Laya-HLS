#!/usr/bin/env python3
import argparse
import importlib.util
import json
from pathlib import Path
import re
import struct


def load_base(path):
    spec = importlib.util.spec_from_file_location('provenance_fixture_base', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def put(buf, offset, fmt, value):
    struct.pack_into('<' + fmt, buf, offset, value)


def typed_context(task_id, op, row0):
    result = bytearray(12)
    put(result, 0, 'I', task_id)
    result[4:8] = bytes((op, 2, 0, 0))
    result[8] = 0
    put(result, 9, 'H', row0)
    result[11] = 16
    return result


def set_window(packet, task_id, row0):
    packet[148:160] = typed_context(task_id, 0x10, row0)
    put(packet, 864, 'Q', row0 * 4096)
    put(packet, 872, 'I', 4096)
    put(packet, 876, 'H', 16)
    put(packet, 878, 'H', 1)
    put(packet, 880, 'Q', 4096)
    put(packet, 888, 'Q', 0)
    put(packet, 896, 'Q', 16 * 4096)
    packet[904:907] = bytes((0, 255, 0))
    return packet


def compute_query(base, l13m, generation, window, producer_task,
                  request_id=2000):
    row0 = window * 16
    producer = typed_context(producer_task, 0x10, row0)
    quant = typed_context(3001 + window, 0x20, row0)
    linear = typed_context(4001 + window, 0x33, row0)
    result = bytearray(1024)
    put(result, 0, 'I', 0x3150434c)
    put(result, 4, 'H', 2)
    put(result, 6, 'H', 2)
    put(result, 8, 'Q', generation)
    put(result, 16, 'I', 3001 + window)
    put(result, 24, 'H', 16)
    put(result, 26, 'H', 8)
    result[64:148] = base.identity(l13m, request_id)
    result[148:160] = quant
    source_ref = base.ref(100, 1)
    a_ref = base.ref(1, 0x22)
    w_ref = base.ref(1, 0x23)
    ps_ref = base.ref(1, 0x24)
    result[160:168] = source_ref
    result[168:176] = a_ref
    result[176:184] = w_ref
    result[184:192] = ps_ref
    result[192:200] = a_ref
    result[200:616] = l13m
    put(result, 616, 'H', 1024)
    put(result, 618, 'H', 2)
    result[620] = 16
    result[622] = 0
    result[623] = 0
    put(result, 624, 'I', 1)
    put(result, 628, 'I', 1)
    put(result, 632, 'H', 0xff0c)
    result[637] = 6
    put(result, 688, 'Q', 4096)
    put(result, 696, 'Q', 4 * 1024 * 1024)
    put(result, 904, 'Q', 0)
    put(result, 912, 'Q', 64 * 4096)
    put(result, 920, 'Q', 4096)
    result[928:940] = producer
    result[940:952] = quant
    result[952:964] = linear
    result[964:972] = base.ref(2, 10, 0, 4)
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--base-generator', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    base = load_base(args.base_generator)
    match = re.search(r"L13M_CANONICAL=3328'h([0-9a-fA-F]+)",
                      args.package.read_text())
    if not match:
        raise RuntimeError('L13M canonical constant is absent')
    l13m = int(match.group(1), 16).to_bytes(416, 'little')
    owner = base.descriptor(100, rows=64)
    packets = {
        'source_claim': base.request(l13m, 1, 200, 2000, (owner,)),
    }
    sequence = 201
    producer_tasks = []
    for window in range(4):
        producer_task = 2001 + window
        producer_tasks.append(producer_task)
        begin = base.request(l13m, 2, sequence, 2000, (owner,),
                             producer_task, sequence)
        end = base.request(l13m, 3, sequence + 1, 2000, (owner,),
                           producer_task, sequence, 0, 16 * 4096)
        packets[f'source_begin_{window}'] = set_window(begin, producer_task,
                                                       window * 16)
        packets[f'source_end_{window}'] = set_window(end, producer_task,
                                                     window * 16)
        sequence += 2
        if window == 2:
            packets['source_publish_early'] = base.request(
                l13m, 4, sequence, 2000, (owner,))
            sequence += 1
    packets['source_publish'] = base.request(l13m, 4, sequence, 2000,
                                              (owner,))
    packets['source_owner_release_busy'] = base.request(
        l13m, 5, sequence + 1, 2000, (owner,))
    packets['source_owner_release'] = base.request(
        l13m, 5, sequence + 2, 2000, (owner,))
    queries = {
        f'query_{window}': compute_query(base, l13m, 500 + window,
                                         window, producer_tasks[window])
        for window in range(4)
    }
    queries['query_window0_new'] = compute_query(base, l13m, 600, 0,
                                                  producer_tasks[0])
    args.out.mkdir(parents=True, exist_ok=False)
    for name, packet in {**packets, **queries}.items():
        base.write_hex(args.out / (name + '.hex'), packet)
    (args.out / 'fixture.json').write_text(json.dumps({
        'schema': 'laya-generated-source-lease-fixture-v1',
        'identity': {'request_id': 2000, 'session_generation': 73,
                     'B': 1, 'S': 64},
        'owner': {'role': 6, 'layout': 'TOKEN', 'dtype': 'F32',
                  'rows': 64, 'width': 1024, 'windows': 4,
                  'ref_epoch': 100},
        'producer_tasks': producer_tasks,
        'query_generations': [500, 501, 502, 503, 600],
        'packets': list(packets),
        'queries': list(queries),
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
