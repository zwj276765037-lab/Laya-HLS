#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
import re
import struct


def put(buf, offset, fmt, value):
    struct.pack_into('<' + fmt, buf, offset, value)


def ref(epoch, buffer_id, bank=0, region=0):
    return struct.pack('<IBBBB', epoch, buffer_id, bank, region, 0)


def identity(l13m, request_id):
    result = bytearray(84)
    put(result, 0, 'Q', request_id)
    put(result, 8, 'Q', 73)
    put(result, 16, 'H', 1)
    put(result, 18, 'H', 64)
    result[20:84] = l13m[:64]
    return result


def context(task_id):
    result = bytearray(12)
    put(result, 0, 'I', task_id)
    result[4:8] = bytes((0x10, 2, 0, 0))
    result[8] = 0
    put(result, 9, 'H', 0)
    result[11] = 16
    return result


def descriptor(epoch, buffer_id=1, bank=0):
    result = bytearray(128)
    result[:8] = ref(epoch, buffer_id, bank)
    result[16:20] = bytes((2, 0, 255, 0))
    put(result, 20, 'H', 0)
    put(result, 22, 'H', 64)
    put(result, 24, 'H', 1024 if buffer_id == 1 else 64)
    result[26] = 1 if buffer_id == 1 else 2
    result[27] = 0 if buffer_id == 1 else 1
    result[28] = 6 if buffer_id == 1 else 8 + bank
    if buffer_id == 1:
        put(result, 32, 'Q', 17 * 1024 * 1024)
        put(result, 40, 'Q', 0)
        put(result, 48, 'Q', 4096)
        put(result, 56, 'Q', 4 * 1024 * 1024)
        put(result, 64, 'Q', 64 * 4096)
    else:
        row_stride = 64 * 4
        batch_stride = 8 * 1024 * 64 * 4
        head_stride = 1024 * 64 * 4
        plane_stride = 2 * 8 * 1024 * 64 * 4
        extent = 2 * plane_stride + 7 * head_stride + 63 * row_stride + 64 * 4
        put(result, 32, 'Q', 12 * 1024 * 1024)
        put(result, 40, 'Q', 0)
        put(result, 48, 'Q', row_stride)
        put(result, 56, 'Q', batch_stride)
        put(result, 64, 'Q', extent)
        put(result, 72, 'Q', head_stride)
        put(result, 80, 'Q', plane_stride)
    return result


def geometry():
    result = bytearray(64)
    put(result, 0, 'Q', 0)
    put(result, 8, 'I', 4096)
    put(result, 12, 'H', 16)
    put(result, 14, 'H', 1)
    put(result, 16, 'Q', 4096)
    put(result, 32, 'Q', 16 * 4096)
    result[40:43] = bytes((0, 255, 0))
    return result


def request(l13m, action, seq, request_id, descs, task_id=0, origin=0,
            reported_status=0, issued=0):
    result = bytearray(1024)
    put(result, 0, 'I', 0x3156504c)
    put(result, 4, 'H', 1)
    put(result, 6, 'H', action)
    put(result, 8, 'Q', seq)
    put(result, 16, 'I', task_id)
    put(result, 24, 'H', 16)
    put(result, 26, 'H', 8)
    put(result, 32, 'Q', origin)
    put(result, 40, 'H', reported_status)
    result[64:148] = identity(l13m, request_id)
    result[160:576] = l13m
    result[576] = len(descs)
    for index, desc in enumerate(descs):
        result[608 + 128 * index:736 + 128 * index] = desc
    if action in (2, 3):
        result[148:160] = context(task_id)
        result[578] = 1
        put(result, 580, 'I', 16 * 1024)
        for index in range(len(descs)):
            result[864 + 64 * index:928 + 64 * index] = geometry()
    if action == 3:
        put(result, 584, 'Q', issued)
        if reported_status == 0:
            result[42] = 1
            put(result, 44, 'I', 16 * 1024)
        else:
            put(result, 48, 'I', 0x07100007)
            put(result, 56, 'Q', 19)
    return result


def write_hex(path, packet):
    lines = []
    for offset in range(0, len(packet), 64):
        lines.append(packet[offset:offset + 64][::-1].hex())
    path.write_text('\n'.join(lines) + '\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    text = args.package.read_text()
    match = re.search(r'L13M_CANONICAL=3328\'h([0-9a-fA-F]+)', text)
    if not match:
        raise RuntimeError('L13M canonical constant is absent')
    l13m = int(match.group(1), 16).to_bytes(416, 'little')
    out = args.out
    out.mkdir(parents=True, exist_ok=False)
    ordinary1 = descriptor(1)
    ordinary2 = descriptor(2)
    ordinary3 = descriptor(3)
    qkv = (descriptor(1, 5, 0), descriptor(1, 5, 1))
    packets = {
        'claim1': request(l13m, 1, 1, 901, (ordinary1,)),
        'begin1': request(l13m, 2, 2, 901, (ordinary1,), 1, 2),
        'bad_end1': request(l13m, 3, 3, 901, (ordinary1,), 1, 1, 0, 65536),
        'end1': request(l13m, 3, 4, 901, (ordinary1,), 1, 2, 0, 65536),
        'duplicate_end1': request(l13m, 3, 5, 901, (ordinary1,), 1, 2, 0, 65536),
        'publish_incomplete': request(l13m, 4, 6, 901, (ordinary1,)),
        'publish1': request(l13m, 4, 7, 901, (ordinary1,)),
        'release1': request(l13m, 5, 8, 901, (ordinary1,)),
        'claim2': request(l13m, 1, 9, 902, (ordinary2,)),
        'begin2': request(l13m, 2, 10, 902, (ordinary2,), 1, 10),
        'failed_end2': request(l13m, 3, 11, 902, (ordinary2,), 1, 10, 6, 4096),
        'invalidate2': request(l13m, 6, 12, 902, (ordinary2,)),
        'qkv_claim': request(l13m, 1, 13, 902, qkv),
        'qkv_invalidate': request(l13m, 6, 14, 902, qkv),
        'claim3': request(l13m, 1, 16, 902, (ordinary3,)),
    }
    packets['replay'] = bytearray(packets['qkv_invalidate'])
    packets['bad_model'] = request(l13m, 1, 15, 902, (ordinary3,))
    packets['bad_model'][160] ^= 1
    packets['bad_header'] = request(l13m, 1, (1 << 64) - 1, 902,
                                    (ordinary3,))
    packets['bad_header'][0] ^= 1
    sequence = 17
    for index in range(33):
        request_id = 1000 + index
        owner = descriptor(4 + index)
        packets[f'loop_claim_{index}'] = request(
            l13m, 1, sequence, request_id, (owner,))
        packets[f'loop_begin_{index}'] = request(
            l13m, 2, sequence + 1, request_id, (owner,), 1, sequence + 1)
        packets[f'loop_end_{index}'] = request(
            l13m, 3, sequence + 2, request_id, (owner,), 1,
            sequence + 1, 0, 65536)
        packets[f'loop_invalidate_{index}'] = request(
            l13m, 6, sequence + 3, request_id, (owner,))
        sequence += 4
    packets['stale_claim'] = request(
        l13m, 1, sequence, 1000, (descriptor(37),))
    for name, packet in packets.items():
        write_hex(out / (name + '.hex'), packet)
    (out / 'fixture.json').write_text(json.dumps({
        'schema': 'laya-generated-provenance-portal-fixture-v1',
        'packets': list(packets),
        'scope': 'controlled ledger transactions; no AXI monitor input derivation'
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
