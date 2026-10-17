#!/usr/bin/env python3
"""Check sealed XSim bytes against frozen score/probability/AV fixtures."""
from __future__ import annotations
import argparse
import hashlib
import json
import math
from pathlib import Path
import struct

BASE=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
V5=BASE/'results/attention_rtl_repair_20261008/d2_attention_preloaded/v5'
FIX=V5/'tb/fixture_preloaded'
RAW=BASE/'results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision/qkv_final.f32.bin'

def sha(data:bytes)->str: return hashlib.sha256(data).hexdigest()
def checked(path:Path,n:int,digest:str)->bytes:
    data=path.read_bytes()
    assert len(data)==n and sha(data)==digest,(path,len(data),sha(data))
    return data

def read_hex(path:Path,n:int)->bytes:
    text=path.read_text(encoding='ascii')
    assert len(text)==2*n+1 and text.endswith('\n'),(path,len(text))
    assert all(c in '0123456789abcdef' for c in text[:-1]),path
    return bytes.fromhex(text[:-1])

def f32(value:float)->float:
    return struct.unpack('<f',struct.pack('<f',value))[0]
def from_word(bits:int)->float:
    return struct.unpack('<f',struct.pack('<I',bits))[0]
def to_word(value:float)->int:
    return struct.unpack('<I',struct.pack('<f',value))[0]
def near(actual_bits:int, expected_bits:int)->bool:
    actual=from_word(actual_bits); expected=from_word(expected_bits)
    if not(math.isfinite(actual) and math.isfinite(expected)): return False
    tolerance=f32(f32(1e-4)+f32(f32(1e-4)*f32(abs(expected))))
    return f32(abs(f32(actual-expected)))<=tolerance

def word(data:bytes,index:int)->int:
    return struct.unpack_from('<I',data,4*index)[0]

def main():
    p=argparse.ArgumentParser()
    p.add_argument('runtime_dir',type=Path)
    p.add_argument('output',type=Path)
    args=p.parse_args()
    seal=json.loads((args.runtime_dir/'runtime_seal.json').read_text())
    assert seal['schema']=='attention_v5_cold_runtime_seal_v1'
    for name,info in seal['files'].items():
        path=args.runtime_dir/name
        assert path.is_file() and sha(path.read_bytes())==info['sha256'] and path.stat().st_size==info['bytes'],name
    manifest=json.loads((FIX/'fixture_manifest.json').read_text())
    raw=checked(RAW,786432,manifest['cases']['base']['source_sha256'])
    gold={kind:checked(FIX/f'base_h0_r0_{kind}.f32.bin',256,manifest['gold']['base_h0_r0'][kind])
          for kind in ('score','probability','av')}
    seen=[read_hex(args.runtime_dir/f'observed_{i}.hex',4096) for i in range(4)]
    out=read_hex(args.runtime_dir/'att_out_2.hex',256<<10)
    replay=read_hex(args.runtime_dir/'att_out_3.hex',256<<10)
    assert replay==out and out[256:]==b'\xa5'*(len(out)-256)
    for command,obs in enumerate(seen):
        assert obs[1024:]==b'\xa5'*(4096-1024)
        assert all(word(obs,i)==0xdeadbeef for i in list(range(208,224))+list(range(238,256)))
        if command!=2: assert all(word(obs,i)==0xdeadbeef for i in range(16,208))
    run=seen[2]
    assert word(run,0)==0 and word(run,2)==13 and word(run,3)==4
    assert word(run,230)==3072 and [word(run,i) for i in (235,236,237)]==[64,64,64]
    score_exact=0; probability_near=0; av_exact=0; av_near=0
    probability=[]
    for key in range(64):
        got=word(run,16+key); expected=word(gold['score'],key)
        assert got==expected,('QK',key,got,expected)
        score_exact+=1
        actual_probability=word(run,80+key)
        expected_probability=word(gold['probability'],key)
        assert near(actual_probability,expected_probability),('softmax',key,actual_probability,expected_probability)
        probability.append(actual_probability)
        probability_near+=1
    for d in range(64):
        accumulator=f32(0.0)
        for key in range(64):
            vbits=word(raw,key*3072+2048+d)
            product=f32(from_word(probability[key])*from_word(vbits))
            accumulator=f32(accumulator+product)
        actual=word(run,144+d)
        expected=to_word(accumulator)
        assert actual==expected,('AV from actual probability',d,actual,expected)
        assert near(actual,word(gold['av'],d)),('AV frozen gold',d,actual,word(gold['av'],d))
        assert word(out,d)==actual,('ATT_OUT versus observed AV',d)
        av_exact+=1; av_near+=1
    result={'schema':'attention_v5_cold_numeric_check_v1',
            'input_seal_sha256':sha((args.runtime_dir/'runtime_seal.json').read_bytes()),
            'source_sha256':sha(raw),'frozen_gold_sha256':{k:sha(v) for k,v in gold.items()},
            'qk_exact_words':score_exact,'probability_tolerance_words':probability_near,
            'av_exact_from_actual_probability_words':av_exact,
            'av_frozen_tolerance_words':av_near,
            'att_out_equal_observed_bytes':256,
            'att_out_sentinel_bytes':len(out)-256,
            'replay_att_out_identical_bytes':len(out),
            'observed_pages_checked':4,'status':'PASS'}
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print('ATT_COLD_NUMERIC_PASS qk=64 probability=64 av_exact=64 av_gold=64')
if __name__=='__main__': main()
