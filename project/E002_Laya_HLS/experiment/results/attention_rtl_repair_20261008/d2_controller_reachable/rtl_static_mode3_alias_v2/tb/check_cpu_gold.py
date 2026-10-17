#!/usr/bin/env python3
"""Independent finite FP32 candidate-mask comparison for the frozen CPU gold.

This file is source preparation. It is not executed by source-packet creation.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'tb/fixture_v2'


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def f32(value: float) -> float:
    return struct.unpack('<f', struct.pack('<f', value))[0]


def checked(name: str, report: dict) -> bytes:
    path = FIXTURE / (name + ('.bin' if name == 'request' else '.f32.bin'))
    info = report['files'][name]
    raw = path.read_bytes()
    if path.resolve() != Path(info['path']) or (len(raw), sha(raw)) != (info['bytes'], info['sha256']):
        raise ValueError(f'frozen CPU fixture identity changed: {name}')
    return raw


def cpu_expected_words(request: bytes, candidate: bytes) -> list[int]:
    descriptor = 128 + 3 * 32
    offset, length = struct.unpack_from('<II', request, descriptor + 4)
    if length != 16 or offset + length > len(request):
        raise ValueError('candidate-mask descriptor')
    mask = request[offset:offset + length]
    if set(mask) - {0, 1} or len(candidate) != 64:
        raise ValueError('candidate-mask input')
    expected = []
    for index, bit in enumerate(mask):
        value = struct.unpack_from('<f', candidate, 4 * index)[0]
        multiplier = f32(f32(1.0) - f32(float(bit)))
        bias = f32(multiplier * f32(-10000.0))
        result = f32(value + bias)
        expected.append(struct.unpack('<I', struct.pack('<f', result))[0])
    return expected


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('output', type=Path)
    args = ap.parse_args()
    report = json.loads((FIXTURE / 'fixture_report.json').read_text())
    request = checked('request', report)
    candidate = checked('candidate', report)
    gold = checked('candidate_gold', report)
    expected = cpu_expected_words(request, candidate)
    actual = list(struct.unpack('<16I', gold))
    if expected != actual:
        raise ValueError(f'CPU gold mismatch at {next(i for i in range(16) if expected[i] != actual[i])}')
    result = {'schema': 'd2_i_mode3_cpu_gold_crosscheck_v1',
              'status': 'FROZEN_CPU_GOLD_MATCHES_INDEPENDENT_FP32_RULE',
              'request_sha256': sha(request), 'candidate_sha256': sha(candidate),
              'candidate_gold_sha256': sha(gold), 'f32_bit_patterns_checked': 16,
              'signed_zero_rule': 'Exact 32-bit comparison, no tolerance'}
    args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print('D2_MODE3_CPU_GOLD_CHECK_PASS f32=16')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
