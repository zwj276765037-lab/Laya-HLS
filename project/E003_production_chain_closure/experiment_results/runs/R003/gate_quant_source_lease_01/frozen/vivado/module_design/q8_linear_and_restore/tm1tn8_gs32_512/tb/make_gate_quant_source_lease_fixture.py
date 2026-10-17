#!/usr/bin/env python3
import argparse
import importlib.util
import json
from pathlib import Path
import re
import struct


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def put(buf, offset, fmt, value):
    struct.pack_into('<' + fmt, buf, offset, value)


def context(task_id, op, row0):
    result = bytearray(12)
    put(result, 0, 'I', task_id)
    result[4:8] = bytes((op, 2, 0, 0))
    result[8] = 0
    put(result, 9, 'H', row0)
    result[11] = 16
    return result


def owner_descriptor(base):
    result = bytearray(base.descriptor(100, rows=64))
    put(result, 24, 'H', 256)
    put(result, 32, 'Q', 17 * 1024 * 1024)
    put(result, 40, 'Q', 0x1000)
    put(result, 48, 'Q', 1024)
    put(result, 56, 'Q', 1024 * 1024)
    put(result, 64, 'Q', 64 * 1024)
    return result


def set_window(packet, task_id, row0):
    packet[148:160] = context(task_id, 0x10, row0)
    put(packet, 864, 'Q', 0x1000 + row0 * 1024)
    put(packet, 872, 'I', 1024)
    put(packet, 876, 'H', 16)
    put(packet, 878, 'H', 1)
    put(packet, 880, 'Q', 1024)
    put(packet, 888, 'Q', 0)
    put(packet, 896, 'Q', 16 * 1024)
    packet[904:907] = bytes((0, 255, 0))
    return packet


def query(base, l13m, generation):
    producer = context(2001, 0x10, 0)
    quant = context(3001, 0x20, 0)
    linear = context(4001, 0x33, 0)
    result = bytearray(1024)
    put(result, 0, 'I', 0x3150434c)
    put(result, 4, 'H', 2)
    put(result, 6, 'H', 2)
    put(result, 8, 'Q', generation)
    put(result, 16, 'I', 3001)
    put(result, 24, 'H', 16)
    put(result, 26, 'H', 8)
    result[64:148] = base.identity(l13m, 2000)
    result[148:160] = quant
    result[160:168] = base.ref(100, 1)
    result[168:176] = base.ref(1, 0x22)
    result[176:184] = base.ref(1, 0x23)
    result[184:192] = base.ref(1, 0x24)
    result[192:200] = result[168:176]
    result[200:616] = l13m
    put(result, 616, 'H', 256)
    put(result, 618, 'H', 2)
    result[620] = 16
    put(result, 624, 'I', 1)
    put(result, 628, 'I', 1)
    put(result, 632, 'H', 0xff0c)
    result[637] = 6
    put(result, 688, 'Q', 1024)
    put(result, 696, 'Q', 1024 * 1024)
    put(result, 904, 'Q', 0x1000)
    put(result, 912, 'Q', 64 * 1024)
    put(result, 920, 'Q', 1024)
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
    base = load_module('provenance_fixture_base', args.base_generator)
    match = re.search(r"L13M_CANONICAL=3328'h([0-9a-fA-F]+)",
                      args.package.read_text())
    if not match:
        raise RuntimeError('L13M canonical constant is absent')
    l13m = int(match.group(1), 16).to_bytes(416, 'little')
    owner = owner_descriptor(base)
    packets = {'source_claim': base.request(l13m, 1, 300, 2000, (owner,))}
    sequence = 301
    for window in range(4):
        task = 2001 + window
        begin = base.request(l13m, 2, sequence, 2000, (owner,), task, sequence)
        end = base.request(l13m, 3, sequence + 1, 2000, (owner,), task,
                           sequence, 0, 16 * 1024)
        packets[f'source_begin_{window}'] = set_window(begin, task, window * 16)
        packets[f'source_end_{window}'] = set_window(end, task, window * 16)
        sequence += 2
    packets['source_publish'] = base.request(l13m, 4, sequence, 2000, (owner,))
    packets['source_release'] = base.request(l13m, 5, sequence + 1, 2000, (owner,))
    packets['query_unpublished'] = query(base, l13m, 500)
    packets['query_window0'] = query(base, l13m, 501)
    args.out.mkdir(parents=True, exist_ok=False)
    for name, packet in packets.items():
        base.write_hex(args.out / (name + '.hex'), packet)
    (args.out / 'fixture.json').write_text(json.dumps({
        'schema': 'laya-gate-quant-source-lease-fixture-v1',
        'identity': {'request_id': 2000, 'session_generation': 73,
                     'B': 1, 'S': 64},
        'source': {'role': 6, 'ref_epoch': 100, 'rows': 64,
                   'window_rows': 16, 'K': 256, 'region_offset': 4096,
                   'region_span': 65536},
        'query_generation': 501,
        'packets': list(packets),
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
