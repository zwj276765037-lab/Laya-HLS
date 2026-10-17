#!/usr/bin/env python3
"""Freeze exact independent-rational addition vectors, without the RTL helper."""
import argparse,hashlib,importlib.util,json,random
from pathlib import Path

def main():
    ap=argparse.ArgumentParser();ap.add_argument('reference',type=Path);ap.add_argument('output',type=Path);a=ap.parse_args()
    spec=importlib.util.spec_from_file_location('frozen_original',a.reference);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
    directed=[(0x0c000000,0x8bffffff),(0x0c000001,0x8c000000),(0x0c800000,0x8c7fffff),(0x0c800001,0x8c800000),
              (0x00000001,0x80000001),(0x80000000,0x80000000),(0,0x80000000),(0,1),(0x80000000,0x80000001),
              (0x007fffff,1),(0x00800000,0x80000001),(0x3f800000,0x33800000),(0x3f800001,0x33800000),
              (0x3fffffff,0x33800000),(0x7f7fffff,0x7f7fffff)]
    pairs=[]
    for x,y in directed:
        pairs.extend([(x,y),(y,x),(x^0x80000000,y^0x80000000),(y^0x80000000,x^0x80000000)])
    rng=random.Random(0x41628)
    for _ in range(4096):
        x=rng.getrandbits(32)
        while not ref.is_finite(x):x=rng.getrandbits(32)
        if len(pairs)%3==0:
            exponent=max(0,min(254,((x>>23)&255)+rng.choice([-1,0,1])))
            y=(x^0x80000000)&0x80000000 | (exponent<<23) | rng.getrandbits(23)
        else:
            y=rng.getrandbits(32)
            while not ref.is_finite(y):y=rng.getrandbits(32)
        pairs.append((x,y))
    a.output.mkdir(parents=True)
    path=a.output/'vectors.hex';path.write_text(''.join(f'{x:08x}{y:08x}{ref.f32_add_bits(x,y):08x}\n' for x,y in pairs))
    manifest={'schema':'tm4-bias-exact-rational-vectors-v1','count':len(pairs),'directed':len(directed)*4,
              'reference':str(a.reference.resolve()),'reference_sha256':hashlib.sha256(a.reference.read_bytes()).hexdigest(),
              'generator_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'vectors_sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
    (a.output/'manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
    print(f'TM4_BIAS_VECTOR_FIXTURE_PASS pairs={len(pairs)} exact_rational=1 boundary_exp24=1')
if __name__=='__main__':main()
