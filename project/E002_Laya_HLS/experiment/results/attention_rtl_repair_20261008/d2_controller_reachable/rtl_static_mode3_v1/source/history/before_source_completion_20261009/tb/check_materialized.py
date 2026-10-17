#!/usr/bin/env python3
"""Independently inspect every byte of a later mode3 page materialization."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
REVIEW = BASE / 'results/attention_rtl_repair_20261008'
GATE = REVIEW / 'reviewer_d2_i_vector_mode3_static_source_preparation_release.json'
FIX = REVIEW / 'd2_controller_reachable/tb/fixture_v2'
MODEL = BASE / 'build/model-attention-rtl-repair-20261008'
PAGE = 4096


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def memh(path: Path, length: int) -> bytes:
    lines = path.read_text(encoding='ascii').splitlines()
    if len(lines) != length or any(re.fullmatch(r'[0-9a-f]{2}', x) is None for x in lines):
        raise ValueError(f'memh shape: {path}')
    return bytes.fromhex(''.join(lines))


def assert_bytes(name: str, got: bytes, expected: bytes) -> None:
    if got != expected:
        index = next(i for i, (a, b) in enumerate(zip(got, expected)) if a != b)
        raise ValueError(f'{name} first mismatch at {index}: {got[index]:02x}!={expected[index]:02x}')


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('fixture', type=Path)
    args = ap.parse_args()
    root = args.fixture.resolve()
    release = json.loads(GATE.read_text())
    report_path = root / 'fixture_report.json'
    report = json.loads(report_path.read_text())
    if (report['schema'] != 'd2_i_vector_mode3_first_static_fixture_v1' or
        report['mapped_page_total'] != 14 or
        report['release_sha256'] != sha(GATE.read_bytes())):
        raise ValueError('materialization contract')
    frozen = json.loads((FIX / 'fixture_report.json').read_text())
    for name in ('request', 'candidate', 'candidate_gold'):
        entry = frozen['files'][name]
        raw = Path(entry['path']).read_bytes()
        if (len(raw), sha(raw)) != (entry['bytes'], entry['sha256']):
            raise ValueError(f'frozen source changed: {name}')
    request = bytearray((FIX / 'request.bin').read_bytes())
    candidate = (FIX / 'candidate.f32.bin').read_bytes()
    gold = (FIX / 'candidate_gold.f32.bin').read_bytes()
    if int.from_bytes(request[24:32], 'little') != 301:
        raise ValueError('source request identity')
    request[24:32] = (305).to_bytes(8, 'little')
    manifest = json.loads((MODEL / 'manifest.json').read_text())
    aux_info = manifest['bo']['aux']
    aux = (MODEL / aux_info['file']).read_bytes()
    if (len(aux), sha(aux)) != (aux_info['size'], aux_info['sha256']):
        raise ValueError('aux BO identity')
    products = report['products']
    if set(products) != {'init_src0_input','init_src1_input','init_io','init_aux',
                         'init_state0','init_state1','init_observed',
                         'expected_state1','expected_observed'}:
        raise ValueError('materialized file set')
    payloads = {}
    for name, info in products.items():
        path = root / f'{name}.memh'
        if path.is_symlink() or path.resolve() != Path(info['path']):
            raise ValueError(f'materialized path changed: {name}')
        raw = memh(path, info['payload_bytes'])
        if (path.stat().st_size, sha(path.read_bytes()), sha(raw)) != (
            info['memh_bytes'], info['memh_sha256'], info['payload_sha256']):
            raise ValueError(f'materialized hash changed: {name}')
        payloads[name] = raw
    blank = b'\xa5' * PAGE
    assert_bytes('src0', payloads['init_src0_input'], candidate + b'\xa5' * (PAGE-64))
    for name in ('src1_input','state0','state1','observed'):
        assert_bytes(name, payloads[f'init_{name}'], blank)
    assert_bytes('io', payloads['init_io'], bytes(request) + b'\x00' * (8*PAGE-832))
    assert_bytes('aux', payloads['init_aux'], aux[:128] + b'\xa5' * (PAGE-128))
    raw_offset = release['static_pages']['state1']['raw_write_read_offset_range'][0] - \
                 release['static_pages']['state1']['physical_page_offset']
    masked_offset = release['static_pages']['state1']['masked_write_offset_range'][0] - \
                    release['static_pages']['state1']['physical_page_offset']
    actual_state = payloads['expected_state1']
    for i, byte in enumerate(actual_state):
        expect = (candidate[i-raw_offset] if raw_offset <= i < raw_offset+64 else
                  gold[i-masked_offset] if masked_offset <= i < masked_offset+64 else 0xa5)
        if byte != expect:
            raise ValueError(f'expected state1 page mismatch at {i}')
    obs = payloads['expected_observed']
    for i in range(32):
        key = str(i)
        expect = (0xffffffff if i >= 19 else release['exact_observed_words'][key])
        if int.from_bytes(obs[4*i:4*i+4], 'little') != expect:
            raise ValueError(f'expected observed word mismatch at {i}')
    assert_bytes('observed tail', obs[128:], b'\xa5' * (PAGE-128))
    print('D2_MODE3_MATERIALIZATION_CHECK_PASS pages=14 full_bytes=57344')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
