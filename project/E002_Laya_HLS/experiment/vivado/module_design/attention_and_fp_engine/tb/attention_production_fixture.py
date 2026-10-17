#!/usr/bin/env python3
"""Independent complete enc0/head0 attention oracle, checkpoint replay input."""
import ctypes
import hashlib
import json
from pathlib import Path
import struct
import sys
import numpy as np

P=Path(__file__).resolve().parents[4]
R=P/'results/compute_throughput_optimization_20261010'
sys.path.insert(0,str(P/'tests'))
import full_reference as reference

def identity(path):
    b=path.read_bytes()
    return dict(path=str(path.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def write(out,name,values):
    a=np.asarray(values,dtype='<f4').reshape(-1).view('<u4')
    (out/(name+'.bin')).write_bytes(a.tobytes())
    (out/(name+'.mem')).write_text(''.join(f'{int(x):08x}\n' for x in a))
def main():
    out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False)
    prior=R/'attempts/t2_av_feedback_gold_01/work/gold/manifest.json'
    source=json.loads(prior.read_text())
    for record in [source['capture_source_manifest'],source['request']['request'],source['reference'],
                   *source['producer_planes'].values()]:
        assert identity(Path(record['path']))==record
    qkv={n:np.frombuffer(Path(rec['path']).read_bytes(),dtype='<f4').reshape(128,64)
         for n,rec in source['producer_planes'].items()}
    request=Path(source['request']['request']['path']).read_bytes()
    offset=source['request']['mask_offset'];mask=np.frombuffer(request[offset:offset+128],dtype=np.uint8)
    for n,p in qkv.items():write(out,n,p)
    (out/'mask.mem').write_text(''.join(f'{int(x):08x}\n' for x in mask))
    ident=int((R/'attempts/t2_av_feedback_gold_01/work/gold/numeric_identity.mem').read_text(),16)
    (out/'identity_words.mem').write_text(''.join(f'{(ident>>(32*i))&0xffffffff:08x}\n' for i in range(21)))
    result={n:[] for n in ['score','maximum','shift','exp','sum','prob','out']}
    # Every basic F32 multiplication/addition/division has independent operands
    # and result. Hardware helper ports are checked passively against this file.
    handles={op:[(out/f'{op}_{n}.mem').open('w') for n in ('a','b','gold')] for op in ('mul','add','div')}
    counts=dict(mul=0,add=0,div=0)
    def record(op,a,b,c):
        a,b,c=np.broadcast_arrays(np.asarray(a,dtype='<f4'),np.asarray(b,dtype='<f4'),np.asarray(c,dtype='<f4'))
        for f,array in zip(handles[op],(a,b,c)):
            f.write(''.join(f'{int(x):08x}\n' for x in np.asarray(array,dtype='<f4').reshape(-1).view('<u4')))
        counts[op]+=a.size
    for row in range(128):
        score=[]
        for key in range(128):
            a=qkv['q'][row];b=qkv['k'][key];tree=np.multiply(a,b,dtype=np.float32);record('mul',a,b,tree)
            while len(tree)>1:
                a=tree[::2];b=tree[1::2];tree=np.add(a,b,dtype=np.float32);record('add',a,b,tree)
            scaled=reference.mul(tree[0],np.float32(.125));record('mul',tree[0],np.float32(.125),scaled)
            minus=reference.sub(np.float32(mask[key]),np.float32(1));record('add',np.float32(mask[key]),np.float32(-1),minus)
            pad=reference.mul(minus,np.float32(10000));record('mul',minus,np.float32(10000),pad)
            value=reference.add(scaled,pad);record('add',scaled,pad,value);score.append(value)
        score=np.asarray(score,dtype='<f4')
        assert np.array_equal(score.view('<u4'),reference.qk_row(qkv['q'][row],qkv['k'],mask,128,row,False).view('<u4'))
        maximum=score[0]
        for x in score[1:]:
            if x>maximum:maximum=x
        shift=np.subtract(score,maximum,dtype=np.float32);record('add',score,-maximum,shift)
        ex=np.fromiter((reference.libm_exp(x) for x in shift),dtype='<f4',count=128)
        tree=ex
        while len(tree)>1:
            a=tree[::2];b=tree[1::2];tree=np.add(a,b,dtype=np.float32);record('add',a,b,tree)
        total=tree[0];prob=np.divide(ex,total,dtype=np.float32);record('div',ex,total,prob)
        assert np.array_equal(prob.view('<u4'),reference.softmax_row(score,128).view('<u4'))
        acc=np.zeros(64,dtype='<f4')
        for key in range(128):
            product=np.multiply(prob[key],qkv['v'][key],dtype=np.float32);record('mul',prob[key],qkv['v'][key],product)
            old=acc;acc=np.add(old,product,dtype=np.float32);record('add',old,product,acc)
        assert np.array_equal(acc.view('<u4'),reference.av_row(prob,qkv['v'],128).view('<u4'))
        for name,value in [('score',score),('maximum',maximum),('shift',shift),('exp',ex),('sum',total),('prob',prob),('out',acc)]:result[name].append(value)
    for files in handles.values():
        for f in files:f.close()
    for name,value in result.items():write(out,name,value)
    # Directed exp underflow/zero/normal limits, all independently libm generated.
    directed=[0,0x80000000,0x80000001,0x807fffff,0x80800000,0xbf800000,0xc2b00000,
              0xc2ce8ecf,0xc2cff1b3,0xc2cff1b4,0xc2cff1b5,0xc61c4000]
    x=np.asarray(directed,dtype='<u4').view('<f4');gold=np.array([reference.libm_exp(v) for v in x],dtype='<f4')
    write(out,'exp_directed_x',x);write(out,'exp_directed_gold',gold)
    lm=Path('/lib/x86_64-linux-gnu/libm.so.6').resolve()
    info=dict(schema='laya-attention-production-fixture-v1',scope='enc0/head0/request3/generation1 B1S128 Q/K/V after RoPE checkpoint replay',
              rows=128,keys=128,D=64,mask_ones=int(mask.sum()),basic_operation_counts=counts,
              source_manifest=identity(prior),producer_planes=source['producer_planes'],request=source['request'],
              independent_reference=identity(P/'tests/full_reference.py'),libm=identity(lm),generator=identity(Path(__file__)),
              products={p.name:identity(p) for p in out.iterdir() if p.is_file()},
              DUT_inputs='Q,K,V,mask,full identity only; scores/probabilities/intermediates are independent gold only')
    (out/'manifest.json').write_text(json.dumps(info,indent=2,sort_keys=True)+'\n')
    print('ATTENTION_FIXTURE_PASS rows128 keys128 D64 op_counts='+str(counts),flush=True)
if __name__=='__main__':main()
