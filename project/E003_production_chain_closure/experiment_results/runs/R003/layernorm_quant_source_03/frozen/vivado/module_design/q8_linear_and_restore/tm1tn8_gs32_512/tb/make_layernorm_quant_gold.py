#!/usr/bin/env python3
"""Independent binary32 group quantization oracle of the frozen LN gold."""
import argparse
import hashlib
import json
from pathlib import Path
import numpy as np


def rec(p):
    b=p.read_bytes()
    return {'path':str(p.resolve()),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}


def main():
    a=argparse.ArgumentParser()
    a.add_argument('--gold',type=Path,required=True)
    a.add_argument('--out',type=Path,required=True)
    args=a.parse_args()
    x=np.fromfile(args.gold,dtype='<f4')
    if x.size!=16384 or not np.all(np.isfinite(x)):
        raise ValueError('expected finite independent rows16/D1024 LN gold')
    g=x.reshape(512,32)
    maximum=np.max(np.abs(g),axis=1).astype(np.float32)
    d=np.divide(maximum,np.float32(127),dtype=np.float32)
    reciprocal=np.zeros_like(d)
    np.divide(np.float32(1),d,out=reciprocal,where=d!=0)
    product=np.multiply(g,reciprocal[:,None],dtype=np.float32)
    # roundf acts on the already rounded binary32 product, ties away from zero.
    rounded=np.copysign(np.floor(np.abs(product.astype(np.float64))+0.5),product)
    if not np.all(np.isfinite(rounded)) or np.any(np.abs(rounded)>127):
        raise ValueError('nonfinite or out-of-range quantization')
    q=rounded.astype(np.int8).view(np.uint8).ravel()
    scales=d.astype('<f2').view('<u2')
    if np.any((scales&0x7c00)==0x7c00):raise ValueError('nonfinite half scale')
    # Independent tie check for the chosen roundf rule.
    ties=np.array([-1.5,-0.5,0.5,1.5],dtype=np.float32)
    assert np.array_equal(np.copysign(np.floor(np.abs(ties.astype(np.float64))+0.5),ties),[-2,-1,1,2])
    args.out.mkdir(parents=True,exist_ok=True)
    (args.out/'q.mem').write_text(''.join(f'{int(v):02x}\n' for v in q))
    (args.out/'scale.mem').write_text(''.join(f'{int(v):04x}\n' for v in scales))
    (args.out/'q.i8.bin').write_bytes(q.tobytes())
    (args.out/'scale.f16.bin').write_bytes(scales.tobytes())
    info={'schema':'laya-independent-ln-quant-gold-v1','numpy':np.__version__,
          'input':rec(args.gold),'gold_elements':16384,'groups':512,'group_size':32,
          'rule':'F32 amax/127, F32 reciprocal, F32 multiply, roundf ties away; FP16 scale RNE',
          'unique_source_words':int(np.unique(x.view(np.uint32)).size),
          'outputs':[rec(args.out/n) for n in ['q.mem','scale.mem','q.i8.bin','scale.f16.bin']]}
    (args.out/'quant_gold.json').write_text(json.dumps(info,indent=2)+'\n')
    print(json.dumps({'gold_elements':16384,'groups':512,'unique_source_words':info['unique_source_words']}))

if __name__=='__main__':main()
