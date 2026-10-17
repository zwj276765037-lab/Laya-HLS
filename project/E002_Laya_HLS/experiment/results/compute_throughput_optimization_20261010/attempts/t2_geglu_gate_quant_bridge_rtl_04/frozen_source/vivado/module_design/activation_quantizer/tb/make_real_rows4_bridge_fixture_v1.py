#!/usr/bin/env python3
"""Convert immutable original four-row binary fixtures without changing gold."""
import argparse, hashlib, importlib.util, json, struct
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--fixtures',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False)
def words(name,fmt):
    b=(a.fixtures/name).read_bytes();return list(struct.unpack('<'+fmt*(len(b)//struct.calcsize(fmt)),b))
def emit(name,items,width):
    (a.out/name).write_text(''.join(f'{x:0{width}x}\n' for x in items))
wi=words('wi_rows4_output_f32.bin','I');gate=words('down_rows4_source_f32.bin','I')
qold=(a.fixtures/'down_rows4_a8_q.bin').read_bytes();sold=words('down_rows4_a8_scale.bin','H')
assert len(wi)==4*5248 and len(gate)==4*2624 and len(set(tuple(wi[r*5248:(r+1)*5248]) for r in range(4)))==4
spec=importlib.util.spec_from_file_location('immutable_original_r0_reference',a.reference);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
q=[];scale=[];d=[];recip=[]
for r in range(4):
    for g in range(82):
        i=r*82+g;j=r*2624+g*32;x=ref.original_r0_group(gate[j:j+32],r,g)
        assert x['status']==0 and x['commit']
        qb=bytes(v&255 for v in x['q'])
        assert qb==qold[i*32:(i+1)*32] and x['saved_half']==sold[i]
        q.append(int.from_bytes(qb,'little'));scale.append(x['saved_half']);d.append(x['d_bits']);recip.append(x['reciprocal_bits'])
emit('wi.mem',wi,8);emit('gate.mem',gate,8);emit('q.mem',q,64);emit('scale.mem',scale,4);emit('d.mem',d,8);emit('recip.mem',recip,8)
def h(path):
    return {'path':str(path.resolve()),'bytes':path.stat().st_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
manifest={'schema':'immutable-four-distinct-real-row-bridge-fixture-v1','scope':'Four distinct original enc0 WI outputs, original GEGLU GATE outputs and original q/scale. Exact rational R0 d/reciprocal/q/half derivation cross-checks all 328 original groups. No DUT-generated expected values.','inputs':[h(a.fixtures/n) for n in ['manifest.json','wi_rows4_output_f32.bin','down_rows4_source_f32.bin','down_rows4_a8_q.bin','down_rows4_a8_scale.bin']]+[h(a.reference)],'outputs':[h(f) for f in sorted(a.out.glob('*.mem'))],'rows':4,'groups':328}
(a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('FOUR_DISTINCT_REAL_BRIDGE_FIXTURE_PASS rows=4 groups=328 immutable_q_scale_checked=1')
