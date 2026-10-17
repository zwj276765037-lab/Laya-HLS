#!/usr/bin/env python3
"""Check sealed finite-mode XSim bytes against frozen score/probability/AV fixtures."""
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
TASK=BASE/'results/attention_rtl_repair_20261008'
OLD=TASK/'d2_attention_slice/tb/fixture_b1_s64_decision'
FINITE=TASK/'reviewer_attention_v5_head15_changed_finite_source_preparation_release.json'

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
    p.add_argument('mode',choices=('base_h15_r63','changed_h0_r0'))
    p.add_argument('runtime_dir',type=Path)
    p.add_argument('output',type=Path)
    args=p.parse_args()
    seal=json.loads((args.runtime_dir/'runtime_seal.json').read_text())
    assert seal['schema']=='attention_v5_finite_runtime_seal_v1'
    assert seal['mode']==args.mode
    for name,info in seal['files'].items():
        path=args.runtime_dir/name
        assert path.is_file() and sha(path.read_bytes())==info['sha256'] and path.stat().st_size==info['bytes'],name
    finite_bytes=FINITE.read_bytes()
    assert sha(finite_bytes)=='7044e85372af05ba3660ac0bde6a094f7385229c11ff86ae090f8a3168ef2203'
    mode=next(x for x in json.loads(finite_bytes)['prepared_modes'] if x['mode']==args.mode)
    manifest_bytes=(FIX/'fixture_manifest.json').read_bytes()
    assert sha(manifest_bytes)=='1f7f163924457d024d141b66994a7ce453467969f9ddca781caebd4bc5dcb43c'
    manifest=json.loads(manifest_bytes)
    raw_path=OLD/'qkv_final.f32.bin' if mode['source_case']=='base' else FIX/'qkv_changed.f32.bin'
    raw=checked(raw_path,786432,manifest['cases'][mode['source_case']]['source_sha256'])
    assert manifest['cases']['base']['source_sha256']!=manifest['cases']['changed']['source_sha256']
    assert all(manifest['gold']['base_h0_r0'][kind]!=manifest['gold'][mode['gold_case']][kind]
               for kind in ('score','probability','av'))
    gold={kind:checked(FIX/f'{mode["gold_case"]}_{kind}.f32.bin',256,manifest['gold'][mode['gold_case']][kind])
          for kind in ('score','probability','av')}
    seen=[read_hex(args.runtime_dir/f'observed_{i}.hex',4096) for i in range(4)]
    outs=[read_hex(args.runtime_dir/f'att_out_{i}.hex',256<<10) for i in range(4)]
    output_start=mode['ATT_OUT_write_read_offset_bytes'][0]
    assert output_start in (0,(256<<10)-256)
    assert mode['ATT_OUT_write_read_offset_bytes'][1]==output_start+256
    assert outs[0]==outs[1]==b'\xa5'*(256<<10)
    out=outs[2]
    assert outs[3]==out
    assert out[:output_start]==b'\xa5'*output_start
    assert out[output_start+256:]==b'\xa5'*(len(out)-output_start-256)
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
            vbits=word(raw,key*3072+2048+mode['head']*64+d)
            product=f32(from_word(probability[key])*from_word(vbits))
            accumulator=f32(accumulator+product)
        actual=word(run,144+d)
        expected=to_word(accumulator)
        assert actual==expected,('AV from actual probability',d,actual,expected)
        assert near(actual,word(gold['av'],d)),('AV frozen gold',d,actual,word(gold['av'],d))
        assert word(out[output_start:output_start+256],d)==actual,('ATT_OUT versus observed AV',d)
        av_exact+=1; av_near+=1
    result={'schema':'attention_v5_finite_numeric_check_v1','mode':args.mode,
            'selected_port':mode['selected_port'],'head':mode['head'],'query':mode['query'],
            'input_seal_sha256':sha((args.runtime_dir/'runtime_seal.json').read_bytes()),
            'source_sha256':sha(raw),'source_differs_from_base':mode['source_case']=='changed',
            'frozen_gold_sha256':{k:sha(v) for k,v in gold.items()},
            'qk_exact_words':score_exact,'probability_tolerance_words':probability_near,
            'av_exact_from_actual_probability_words':av_exact,
            'av_frozen_tolerance_words':av_near,
            'att_out_equal_observed_bytes':256,
            'att_out_selected_offset':output_start,'att_out_sentinel_bytes':len(out)-256,
            'replay_att_out_identical_bytes':len(out),
            'observed_pages_checked':4,'status':'PASS'}
    assert not args.output.exists(),args.output
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(f'ATT_FINITE_NUMERIC_PASS mode={args.mode} qk=64 probability=64 av_exact=64 av_gold=64')
if __name__=='__main__': main()
