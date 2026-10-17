#!/usr/bin/env python3
"""Frozen real inputs plus independently libm-generated branch/domain cases."""
import ctypes, hashlib, json, struct, sys
from pathlib import Path
P=Path(__file__).resolve().parents[4]
R=P/'results/compute_throughput_optimization_20261010'
def identity(p):
    b=p.read_bytes(); return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
    out=Path(sys.argv[1]); out.mkdir(parents=True,exist_ok=False)
    ref=R/'attempts/vector_wi_reference_01/reference/manifest.json'
    m=json.loads(ref.read_text())
    for k in ('z_f32.bin','tanh_f32.bin'):
        p=Path(m['products'][k]['path'])
        assert identity(p)==m['products'][k]
    lib=Path(m['libm']['path']); assert identity(lib)==m['libm']
    lm=ctypes.CDLL(str(lib)); lm.tanhf.argtypes=[ctypes.c_float]; lm.tanhf.restype=ctypes.c_float
    real=list(struct.unpack('<2624I',Path(m['products']['z_f32.bin']['path']).read_bytes()))
    gold=list(struct.unpack('<2624I',Path(m['products']['tanh_f32.bin']['path']).read_bytes()))
    # Every nontrivial tanh branch, expm1 reduction threshold, exponent rebuild,
    # subnormal/normal extrema and sign; boundaries use the actual FP argument.
    centers=[0,1,0x007fffff,0x00800000,0x24000000,0x32800000,
             0x3e317218,0x3f051592,0x3f800000,0x4115b844,0x41b00000,0x7f7fffff]
    for k in list(range(-3,5))+[21,22,23,24,55,56,57,63]:
        x=abs(k*0.6931471805599453/2)
        centers.append(struct.unpack('<I',struct.pack('<f',x))[0])
    cases=[]
    for c in centers:
        for d in range(-4,5):
            a=c+d
            if 0<=a<0x7f800000:
                cases += [a,a|0x80000000]
    cases=list(dict.fromkeys(cases))
    state=0x72459013
    for _ in range(256):
        state=(1664525*state+1013904223)&0xffffffff
        a=state
        if (a&0x7f800000)==0x7f800000: a^=0x00800000
        cases.append(a)
    for a in cases:
        x=struct.unpack('<f',struct.pack('<I',a))[0]
        gold.append(struct.unpack('<I',struct.pack('<f',lm.tanhf(x)))[0]); real.append(a)
    invalid=[0x7f800000,0xff800000,0x7fc00000,0xffc01234,0x7f800001,0xff800001]
    real+=invalid; gold += [0]*len(invalid)
    for name,v in [('x',real),('gold',gold)]:
        (out/f'{name}.bin').write_bytes(struct.pack('<%dI'%len(v),*v))
        (out/f'{name}.mem').write_text(''.join(f'{x:08x}\n' for x in v))
    info=dict(schema='laya-tanh-libm-round1-fixture-v1',real_count=2624,
              finite_boundary_random_count=len(cases),invalid_count=len(invalid),count=len(real),
              independent_reference=identity(ref),libm=identity(lib),
              generator=identity(Path(__file__)),products={p.name:identity(p) for p in out.iterdir()})
    (out/'manifest.json').write_text(json.dumps(info,indent=2,sort_keys=True)+'\n')
    print(f'FIXTURE_FROZEN count={len(real)} real=2624 finite_extra={len(cases)} invalid={len(invalid)}')
if __name__=='__main__': main()
