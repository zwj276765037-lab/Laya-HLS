#!/usr/bin/env python3
"""Reconstruct frozen external images, verify full shards, emit only mapped pages.

This is a host producer/checker; it never initializes an internal DUT RAM.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import struct

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
V5 = BASE/'results/attention_rtl_repair_20261008/d2_attention_preloaded/v5'
FIX = V5/'tb/fixture_preloaded'
OLD = BASE/'results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision'
PKG = BASE/'build/model-attention-rtl-repair-20261008'
GATE = BASE/'results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_source_preparation_release.json'
PAGE = 4096
HOST = 12 << 20
PREFIX = 10_240_064
SOURCE = 786_432

def sha(data: bytes | bytearray) -> str:
    return hashlib.sha256(data).hexdigest()

def checked(path: Path, length: int, digest: str) -> bytes:
    data = path.read_bytes()
    assert len(data) == length and sha(data) == digest, (path, len(data), sha(data))
    return data

def write_memh(path: Path, payload: bytes | bytearray) -> None:
    with path.open('w', encoding='ascii') as f:
        for value in payload:
            f.write(f'{value:02x}\n')

def write_full_image(raw: bytes) -> tuple[bytearray, bytearray]:
    banks = (bytearray(b'\xa5' * HOST), bytearray(b'\xa5' * HOST))
    for row in range(64):
        for plane in range(3):
            for head in range(16):
                src = 4 * (row * 3072 + plane * 1024 + head * 64)
                shard = head & 1
                local_head = head >> 1
                dst = 4 * (((((plane * 2) * 8 + local_head) * 1024 + row) * 64))
                banks[shard][dst:dst+256] = raw[src:src+256]
    return banks

def inverse_check(bank: bytes | bytearray, raw: bytes, shard: int) -> int:
    assert len(bank) == HOST
    for position, got in enumerate(bank):
        word = position >> 2
        plane = word >> 20
        batch = (word >> 19) & 1
        local_head = (word >> 16) & 7
        row = (word >> 6) & 1023
        d = word & 63
        expect = 0xa5
        if plane < 3 and batch == 0 and row < 64:
            head = 2 * local_head + shard
            source = 4 * (row * 3072 + plane * 1024 + head * 64 + d) + (position & 3)
            expect = raw[source]
        if got != expect:
            raise AssertionError(f'inverse shard={shard} byte={position} actual={got:02x} expected={expect:02x}')
    return len(bank)

def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument('output', type=Path)
    args = p.parse_args()
    assert not args.output.exists(), 'fresh output directory required'
    gate_bytes = GATE.read_bytes()
    assert sha(gate_bytes) == 'b73b9095ca3e3c80c512ff404c4c6c8883afd31626e85c38b7e012016cca61eb'
    gate = json.loads(gate_bytes)
    manifest_bytes = (FIX/'fixture_manifest.json').read_bytes()
    manifest = json.loads(manifest_bytes)
    case = manifest['cases']['base']
    raw = checked(OLD/'qkv_final.f32.bin', SOURCE, case['source_sha256'])
    request = checked(OLD/'request.bin', 832, manifest['source_request_sha256'])
    aux = (PKG/'aux.bin').read_bytes()
    assert len(aux) == 1_671_872
    assert sha((PKG/'manifest.json').read_bytes()) == manifest['package_manifest_sha256']
    assert request[88:104].hex() == manifest['build_tag']
    banks = write_full_image(raw)
    verified = [inverse_check(bank, raw, shard) for shard, bank in enumerate(banks)]
    for shard, bank in enumerate(banks):
        assert sha(bank) == case['bank_host_sha256'][shard]
        assert sha(bank[:PREFIX]) == case['bank_prefix_sha256'][shard]
    begin = checked(FIX/'base_h0_r0_begin.u32le.bin', 640, manifest['first_descriptor_pages']['begin_sha256'])
    run = checked(FIX/'base_h0_r0_run_ticket1_epoch1.u32le.bin', 640, manifest['first_descriptor_pages']['run_sha256'])
    bw = struct.unpack('<160I', begin)
    rw = struct.unpack('<160I', run)
    assert bw[0:8] == (0x50514b56,1,0,0x10040,301,0,1,0)
    assert rw[2] == 1 and rw[8:10] == (1,0) and rw[12:14] == (1,1)
    assert all(x == 0xffff_ffff for x in rw[64:160])
    io = bytearray(32768)
    io[:832] = request
    io[24:32] = (301).to_bytes(8,'little')
    io[32:40] = (1).to_bytes(8,'little')
    assert io[88:104].hex() == manifest['build_tag']
    ports = gate['interfaces']['ports']
    assert [(x['name'],x['page_capacity']) for x in ports] == [
        ('descriptor',1),('io',8),('aux',1),('qkv0',96),('qkv1',96),('att_out',64),('observed',1)]
    assert sum(x['page_capacity'] for x in ports) == gate['interfaces']['page_count'] == 267
    offsets = {}
    for port in ports:
        ofs = [int(x,0) for x in port['logical_page_offsets']]
        physical = [int(x,0) for x in port['physical_page_bases']]
        base = int(port['physical_pointer_base'],0)
        assert len(ofs) == len(physical) == len(set(physical)) == port['page_capacity']
        assert all(a % PAGE == 0 and b == base+a for a,b in zip(ofs,physical))
        offsets[port['name']] = ofs
    assert len({x for port in ports for x in port['physical_page_bases']}) == 267
    initial = {
        'descriptor': begin + b'\xa5'*(PAGE-640),
        'io': bytes(io),
        'aux': aux[:128] + b'\xa5'*(PAGE-128),
        'qkv0': b'\xa5'*(96*PAGE),
        'qkv1': b'\xa5'*(96*PAGE),
        'att_out': b'\xa5'*(64*PAGE),
        'observed': (b'\xef\xbe\xad\xde'*256) + b'\xa5'*(PAGE-1024),
    }
    run_qkv = {}
    for shard in (0,1):
        name = f'qkv{shard}'
        run_qkv[name] = b''.join(banks[shard][ofs:ofs+PAGE] for ofs in offsets[name])
        assert len(run_qkv[name]) == 96*PAGE
    args.output.mkdir(parents=True)
    payloads = {f'init_{name}.memh': data for name,data in initial.items()}
    payloads.update({f'run_{name}.memh':data for name,data in run_qkv.items()})
    payloads['descriptor_run.memh'] = run + b'\xa5'*(PAGE-640)
    for name,data in payloads.items():
        write_memh(args.output/name,data)
    info = {
        'schema':'attention_v5_cold_page_materialization_v1',
        'status':'HOST_SOURCE_AND_FULL_IMAGE_CHECK_ONLY_NO_EDA',
        'source':{'path':str(OLD/'qkv_final.f32.bin'),'bytes':len(raw),'sha256':sha(raw)},
        'request':{'path':str(OLD/'request.bin'),'bytes':len(request),'sha256':sha(request)},
        'aux':{'path':str(PKG/'aux.bin'),'bytes':len(aux),'sha256':sha(aux)},
        'gate_sha256':sha(gate_bytes),'fixture_manifest_sha256':sha(manifest_bytes),
        'host_shards':[{'bytes':HOST,'inverse_checked_bytes':verified[i],
            'host_sha256':sha(banks[i]),'prefix_bytes':PREFIX,
            'prefix_sha256':sha(banks[i][:PREFIX]),'materialized_page_bytes':len(run_qkv[f'qkv{i}'])}
            for i in (0,1)],
        'mapped_pages':[{'port':p['name'],'count':p['page_capacity'],
            'logical_offsets':p['logical_page_offsets'],'physical_bases':p['physical_page_bases']}
            for p in ports],
        'generated':{name:{'source_bytes':len(data),'source_sha256':sha(data),
            'memh_bytes':(args.output/name).stat().st_size,'memh_sha256':sha((args.output/name).read_bytes())}
            for name,data in payloads.items()},
        'scope':'Only listed 4KiB pages are materialized; unmapped host-image bytes were independently reconstructed and hashed, never claimed as simulator scanned.'
    }
    (args.output/'materialization.json').write_text(json.dumps(info,indent=2,sort_keys=True)+'\n')
    print(f'ATT_COLD_MATERIALIZED pages=267 host_checked={sum(verified)} qkv_mapped={2*96*PAGE}')

if __name__ == '__main__':
    main()
