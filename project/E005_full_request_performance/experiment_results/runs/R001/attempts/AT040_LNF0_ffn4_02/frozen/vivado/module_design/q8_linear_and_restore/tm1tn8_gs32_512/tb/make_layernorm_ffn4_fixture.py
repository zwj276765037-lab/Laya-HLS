#!/usr/bin/env python3
"""Build one real LayerNorm producer/portal transaction fixture."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct


def put(buf, offset, fmt, value):
    struct.pack_into('<' + fmt, buf, offset, value)


def record(path):
    data = path.read_bytes()
    return {'path': str(path.resolve()), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def ref(epoch, buffer_id, bank=0, region=0):
    return struct.pack('<IBBBB', epoch, buffer_id, bank, region, 0)


def identity(l13m, request_id=3):
    result = bytearray(84)
    put(result, 0, 'Q', request_id)
    put(result, 8, 'Q', 1)
    put(result, 16, 'H', 1)
    put(result, 18, 'H', 128)
    result[20:84] = l13m[:64]
    return result


def context(task_id, op, row0=0, rows=4):
    result = bytearray(12)
    put(result, 0, 'I', task_id)
    result[4:8] = bytes((op, 2, 0, 0))
    result[8] = 0
    put(result, 9, 'H', row0)
    result[11] = rows
    return result


def descriptor(rows):
    result = bytearray(128)
    result[0:8] = ref(9, 2)
    result[16:20] = bytes((2, 0, 255, 0))
    put(result, 20, 'H', 0)
    put(result, 22, 'H', rows)
    put(result, 24, 'H', 1024)
    result[26:29] = bytes((1, 0, 6))
    put(result, 32, 'Q', 16920576)
    put(result, 40, 'Q', 8 * 1024 * 1024)
    put(result, 48, 'Q', 4096)
    put(result, 56, 'Q', 4 * 1024 * 1024)
    put(result, 64, 'Q', rows * 4096)
    return result


def geometry(rows):
    result = bytearray(64)
    put(result, 0, 'Q', 8 * 1024 * 1024)
    put(result, 8, 'I', 4096)
    put(result, 12, 'H', rows)
    put(result, 14, 'H', 1)
    put(result, 16, 'Q', 0 if rows == 1 else 4096)
    put(result, 32, 'Q', rows * 4096)
    result[40:43] = bytes((0, 255, 0))
    return result


def provenance(l13m, action, seq, task_id=0, origin=0, rows=4):
    packet = bytearray(1024)
    put(packet, 0, 'I', 0x3156504c)
    put(packet, 4, 'H', 1)
    put(packet, 6, 'H', action)
    put(packet, 8, 'Q', seq)
    put(packet, 16, 'I', task_id)
    put(packet, 24, 'H', 16)
    put(packet, 26, 'H', 8)
    put(packet, 32, 'Q', origin)
    packet[64:148] = identity(l13m)
    packet[160:576] = l13m
    packet[576] = 1
    packet[608:736] = descriptor(rows)
    if action in (2, 3):
        packet[148:160] = context(task_id, 0x12, rows=rows)
        packet[578] = 1
        put(packet, 580, 'I', rows * 1024)
        packet[864:928] = geometry(rows)
    if action == 3:
        packet[42] = 1
        put(packet, 44, 'I', rows * 1024)
        put(packet, 584, 'Q', rows * 4096)
    return packet


def producer_request(l13m, rows):
    packet = bytearray(1024)
    put(packet, 0, 'I', 0x3145504c)
    put(packet, 4, 'H', 1)
    put(packet, 6, 'H', 16)
    put(packet, 8, 'H', 1)
    put(packet, 12, 'H', 8)
    put(packet, 16, 'Q', 41)
    put(packet, 24, 'Q', 301)
    packet[64:148] = identity(l13m)
    packet[148:160] = context(11, 0x12, rows=rows)
    packet[160:576] = l13m
    packet[576:584] = ref(3, 1)
    packet[584:592] = ref(9, 2)
    put(packet, 592, 'H', 1024)
    packet[594:599] = bytes((0, 0, 0, 6, 6))
    put(packet, 600, 'I', 0x3727c5ac)
    put(packet, 604, 'I', 4096)
    put(packet, 608, 'Q', 0)
    put(packet, 616, 'Q', 8 * 1024 * 1024)
    put(packet, 624, 'Q', 4096)
    put(packet, 632, 'Q', 4096)
    put(packet, 640, 'Q', 16920576)
    put(packet, 648, 'Q', 16920576)
    put(packet, 656, 'I', rows * 1024)
    packet[660] = 1
    return packet


def source_query(l13m, rows):
    packet = bytearray(1024)
    put(packet, 0, 'I', 0x3150434c)
    put(packet, 4, 'H', 2)
    put(packet, 6, 'H', 2)
    put(packet, 8, 'Q', 900)
    put(packet, 16, 'I', 12)
    put(packet, 24, 'H', 16)
    put(packet, 26, 'H', 8)
    packet[64:148] = identity(l13m)
    packet[148:160] = context(12, 0x20, rows=rows)
    packet[160:168] = ref(9, 2)
    packet[168:176] = ref(1, 0x22)
    packet[176:184] = ref(1, 0x23)
    packet[184:192] = ref(1, 0x24)
    packet[192:200] = ref(1, 0x22)
    packet[200:616] = l13m
    put(packet, 616, 'H', 1024)
    put(packet, 618, 'H', 2)
    packet[620] = rows
    put(packet, 624, 'I', 1)
    put(packet, 628, 'I', 1)
    put(packet, 632, 'H', 0xff0c)
    packet[637] = 6
    put(packet, 688, 'Q', 4096)
    put(packet, 696, 'Q', 4 * 1024 * 1024)
    put(packet, 904, 'Q', 8 * 1024 * 1024)
    put(packet, 912, 'Q', rows * 4096)
    put(packet, 920, 'Q', 4096)
    packet[928:940] = context(11, 0x12, rows=rows)
    packet[940:952] = context(12, 0x20, rows=rows)
    packet[952:964] = context(13, 0x30, rows=rows)
    packet[964:972] = ref(2, 10, 0, 4)
    return packet


def write_hex(path, packet):
    lines = [packet[offset:offset + 64][::-1].hex()
             for offset in range(0, len(packet), 64)]
    path.write_text('\n'.join(lines) + '\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--gold', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--q-mem', type=Path, required=True)
    parser.add_argument('--scale-mem', type=Path, required=True)
    parser.add_argument('--rows', type=int, choices=(1, 4), default=4)
    args = parser.parse_args()
    match = re.search(r"L13M_CANONICAL=3328'h([0-9a-fA-F]+)",
                      args.package.read_text())
    if not match:
        raise RuntimeError('L13M canonical constant is absent')
    l13m = int(match.group(1), 16).to_bytes(416, 'little')
    if args.source.stat().st_size != 4 * 1024 * 4 or hashlib.sha256(args.source.read_bytes()).hexdigest() != '5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9':
        raise RuntimeError('independent residual rows4 identity mismatch')
    if args.gold.stat().st_size != 4 * 1024 * 4 or hashlib.sha256(args.gold.read_bytes()).hexdigest() != '658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883':
        raise RuntimeError('independent LN_FFN rows4 identity mismatch')
    q = b''.join(bytes.fromhex(line.strip())[::-1] for line in args.q_mem.read_text().splitlines())
    scale = b''.join(bytes.fromhex(line.strip())[::-1] for line in args.scale_mem.read_text().splitlines())
    if len(q) != 4096 or hashlib.sha256(q).hexdigest() != '839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34':
        raise RuntimeError('independent Q bytes mismatch')
    if len(scale) != 256 or hashlib.sha256(scale).hexdigest() != '4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f':
        raise RuntimeError('independent scale bytes mismatch')
    args.out.mkdir(parents=True, exist_ok=False)
    packets = {
        'claim': provenance(l13m, 1, 300, rows=args.rows),
        'begin': provenance(l13m, 2, 301, 11, 301, rows=args.rows),
        'end': provenance(l13m, 3, 302, 11, 301, rows=args.rows),
        'publish': provenance(l13m, 4, 303, rows=args.rows),
        'release': provenance(l13m, 5, 304, rows=args.rows),
        'producer_request': producer_request(l13m, args.rows),
        'source_query': source_query(l13m, args.rows),
    }
    for name, packet in packets.items():
        write_hex(args.out / (name + '.hex'), packet)
    (args.out / 'source_rows4.f32.bin').write_bytes(args.source.read_bytes())
    (args.out / 'gold_rows4.f32.bin').write_bytes(args.gold.read_bytes())
    for name, path in (('source.mem', args.source), ('gold.mem', args.gold)):
        words = struct.unpack('<4096I', path.read_bytes())
        (args.out / name).write_text(''.join(f'{word:08x}\n' for word in words))
    (args.out / 'q.mem').write_text(''.join(f'{byte:02x}\n' for byte in q))
    (args.out / 'scale.mem').write_text(''.join(f'{word:04x}\n' for word in struct.unpack('<128H', scale)))
    (args.out / 'fixture.json').write_text(json.dumps({
        'schema': 'laya-layernorm-ffn-four-row-fixture-v1',
        'identity': {'request_id': 3, 'generation': 1, 'B': 1, 'S': 128},
        'producer': {'request_seq': 41, 'begin_origin_seq': 301,
                     'task_id': 11, 'op': 'LN_FFN', 'stage': 2,
                     'layer': 0, 'row0': 0, 'rows': args.rows, 'D': 1024},
        'owner': {'ref': 'NORM/bank0/epoch9', 'role': 6,
                  'base_offset': 8 * 1024 * 1024,
                  'extent_bytes': args.rows * 4096,
                  'capacity': 16920576,
                  'scope': f'one honest rows{args.rows} owner in B1/S128'},
        'packets': list(packets),
        'source': record(args.out / 'source_rows4.f32.bin'),
        'gold': record(args.out / 'gold_rows4.f32.bin'),
        'q': record(args.out / 'q.mem'),
        'scale': record(args.out / 'scale.mem'),
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
