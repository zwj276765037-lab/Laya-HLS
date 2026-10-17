#!/usr/bin/env python3
"""Independent byte check of all ten finite-mode serialized page files."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import struct

BASE=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
TASK=BASE/'results/attention_rtl_repair_20261008'
FIX=TASK/'d2_attention_preloaded/v5/tb/fixture_preloaded'
OLD=TASK/'d2_attention_slice/tb/fixture_b1_s64_decision'
PKG=BASE/'build/model-attention-rtl-repair-20261008'
GATE=TASK/'reviewer_attention_v5_cold_static_source_preparation_release.json'
FINITE=TASK/'reviewer_attention_v5_head15_changed_finite_source_preparation_release.json'
PAGE=4096

def sha(data:bytes)->str: return hashlib.sha256(data).hexdigest()

def checked(path:Path,size:int,digest:str)->bytes:
    data=path.read_bytes()
    assert len(data)==size and sha(data)==digest,(path,len(data),sha(data))
    return data

def mem(prepared:Path,name:str)->bytes:
    source=(prepared/f'{name}.memh').read_bytes()
    assert len(source)%3==0 and source.endswith(b'\n'),name
    assert all(source[i]==10 for i in range(2,len(source),3)),name
    assert all(c in b'0123456789abcdef' for i,c in enumerate(source) if i%3!=2),name
    return bytes(int(source[i:i+2],16) for i in range(0,len(source),3))

def main()->None:
    parser=argparse.ArgumentParser()
    parser.add_argument('mode',choices=('base_h15_r63','changed_h0_r0'))
    parser.add_argument('prepared',type=Path)
    parser.add_argument('output',type=Path)
    args=parser.parse_args()
    assert not args.output.exists(),args.output
    finite_bytes=FINITE.read_bytes()
    assert sha(finite_bytes)=='7044e85372af05ba3660ac0bde6a094f7385229c11ff86ae090f8a3168ef2203'
    mode=next(x for x in json.loads(finite_bytes)['prepared_modes'] if x['mode']==args.mode)
    gate_bytes=GATE.read_bytes()
    assert sha(gate_bytes)=='b73b9095ca3e3c80c512ff404c4c6c8883afd31626e85c38b7e012016cca61eb'
    gate=json.loads(gate_bytes)
    manifest_bytes=(FIX/'fixture_manifest.json').read_bytes()
    assert sha(manifest_bytes)=='1f7f163924457d024d141b66994a7ce453467969f9ddca781caebd4bc5dcb43c'
    manifest=json.loads(manifest_bytes)
    source_path=OLD/'qkv_final.f32.bin' if mode['source_case']=='base' else FIX/'qkv_changed.f32.bin'
    raw=checked(source_path,786432,manifest['cases'][mode['source_case']]['source_sha256'])
    request=checked(OLD/'request.bin',832,manifest['source_request_sha256'])
    aux=(PKG/'aux.bin').read_bytes()
    assert len(aux)==1671872 and sha((PKG/'manifest.json').read_bytes())==manifest['package_manifest_sha256']
    begin=bytearray(checked(FIX/'base_h0_r0_begin.u32le.bin',640,manifest['first_descriptor_pages']['begin_sha256']))
    run=bytearray(checked(FIX/'base_h0_r0_run_ticket1_epoch1.u32le.bin',640,manifest['first_descriptor_pages']['run_sha256']))
    for descriptor in (begin,run):
        struct.pack_into('<II',descriptor,176,mode['head'],mode['query'])
    io=bytearray(32768)
    io[:832]=request
    io[24:32]=(301).to_bytes(8,'little')
    io[32:40]=(1).to_bytes(8,'little')
    assert io[88:104].hex()==manifest['build_tag']
    expected={
        'init_descriptor':bytes(begin)+b'\xa5'*(PAGE-640),
        'descriptor_run':bytes(run)+b'\xa5'*(PAGE-640),
        'init_io':bytes(io),
        'init_aux':aux[:128]+b'\xa5'*(PAGE-128),
        'init_qkv0':b'\xa5'*(96*PAGE),
        'init_qkv1':b'\xa5'*(96*PAGE),
        'init_att_out':b'\xa5'*(64*PAGE),
        'init_observed':b'\xef\xbe\xad\xde'*256+b'\xa5'*(PAGE-1024),
    }
    ports=gate['interfaces']['ports']
    assert sum(p['page_capacity'] for p in ports)==gate['interfaces']['page_count']==267
    assert len({int(page,0) for port in ports for page in port['physical_page_bases']})==267
    for shard in (0,1):
        port=next(p for p in ports if p['name']==f'qkv{shard}')
        assert port['page_capacity']==96 and len(port['logical_page_offsets'])==96
        payload=bytearray()
        for address in port['logical_page_offsets']:
            start=int(address,0)
            for byte_offset in range(start,start+PAGE):
                index=byte_offset>>2
                plane=index>>20
                batch=(index>>19)&1
                local_head=(index>>16)&7
                row=(index>>6)&1023
                dimension=index&63
                value=0xa5
                if plane<3 and batch==0 and row<64:
                    head=2*local_head+shard
                    source=4*(row*3072+plane*1024+head*64+dimension)+(byte_offset&3)
                    value=raw[source]
                payload.append(value)
        expected[f'run_qkv{shard}']=bytes(payload)
    assert {p.name for p in args.prepared.glob('*.memh')}=={f'{name}.memh' for name in expected}
    record=json.loads((args.prepared/'materialization.json').read_text())
    assert record['mode']==args.mode and record['source']['sha256']==sha(raw)
    assert record['descriptor_derived_hashes']=={'begin':sha(begin),'run':sha(run)}
    assert record['gate_sha256']==sha(gate_bytes) and record['finite_release_sha256']==sha(finite_bytes)
    assert len(record['host_shards'])==2 and all(x['inverse_checked_bytes']==12<<20 for x in record['host_shards'])
    case=manifest['cases'][mode['source_case']]
    for shard,item in enumerate(record['host_shards']):
        assert item['host_sha256']==case['bank_host_sha256'][shard]
        assert item['prefix_sha256']==case['bank_prefix_sha256'][shard]
        assert item['prefix_bytes']==10_240_064 and item['materialized_page_bytes']==96*PAGE
    assert record['mapped_pages']==[
        {'port':port['name'],'count':port['page_capacity'],
         'logical_offsets':port['logical_page_offsets'],
         'physical_bases':port['physical_page_bases']} for port in ports]
    checked_files=[]
    for name,payload in sorted(expected.items()):
        got=mem(args.prepared,name)
        assert got==payload,(name,next((i for i,(a,b) in enumerate(zip(got,payload)) if a!=b),None),len(got),len(payload))
        assert record['generated'][f'{name}.memh']['source_sha256']==sha(payload)
        checked_files.append({'name':name,'bytes':len(got),'sha256':sha(got)})
    assert len(checked_files)==10 and sum(x['bytes'] for x in checked_files)==460*PAGE
    result={'schema':'attention_v5_finite_independent_page_serialization_check_v1',
            'status':'PASS_NO_EDA','mode':args.mode,'source_sha256':sha(raw),
            'finite_release_sha256':sha(finite_bytes),
            'materialization_sha256':sha((args.prepared/'materialization.json').read_bytes()),
            'mapped_page_count':267,'initial_mapped_page_bytes':267*PAGE,
            'prepared_total_bytes':sum(x['bytes'] for x in checked_files),
            'qkv_run_checked_bytes':2*96*PAGE,'files':checked_files}
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(f'ATT_FINITE_INDEPENDENT_PAGES_PASS mode={args.mode} files=10 qkv_bytes={2*96*PAGE}')

if __name__=='__main__': main()
