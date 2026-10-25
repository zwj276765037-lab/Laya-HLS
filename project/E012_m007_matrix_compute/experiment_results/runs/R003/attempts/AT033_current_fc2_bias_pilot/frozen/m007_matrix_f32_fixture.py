#!/usr/bin/env python3
import argparse,hashlib,json,importlib.util,warnings
import numpy as np
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
src=a.root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
a.out.mkdir(parents=True)
records=[]
for f in sorted(src.glob('*/source_f32.bin')):
 b=f.read_bytes();assert len(b)%128==0
 d=a.out/f.parent.name;d.mkdir();o=d/'input.hex'
 o.write_text(''.join(b[i:i+128][::-1].hex()+'\n' for i in range(0,len(b),128)))
 records.append({'source':str(f),'source_sha256':hashlib.sha256(b).hexdigest(),'groups':len(b)//128,'input_hex':str(o),'input_sha256':hashlib.sha256(o.read_bytes()).hexdigest(),'provenance':json.loads((f.parent/'fixture.json').read_text())})
(a.out/'fixture.json').write_text(json.dumps({'operation':'byte-to-1024bit little-endian hex only; no oracle arithmetic','source_fixture':str(src),'records':records},indent=2)+'\n')
reference=a.root/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py'
assert hashlib.sha256(reference.read_bytes()).hexdigest()=='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
spec=importlib.util.spec_from_file_location('m007_f32_original',reference);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
base=np.frombuffer((src/'qkv_0_weight/source_f32.bin').read_bytes(),dtype='<f4').reshape(128,1024)
edge=[]
for label in ['half_then_inverse','half_then_last_input_nan']:
 x=base.copy();bits=x.view('<u4').reshape(-1,32);bits[1,:]=0x7f7fffff
 if label=='half_then_inverse':bits[-1,:]=0x0000007f;expected='Q8 sequence inverse';phase=3;element=0
 else:bits[-1,17]=0x7fc00000;expected='Q8 sequence input';phase=1;element=17
 with warnings.catch_warnings():
  warnings.simplefilter('ignore')
  try:ref.quantize_many(x)
  except ArithmeticError as err:message=str(err)
  else:raise AssertionError('expected original reference error')
 assert expected in message,(label,message)
 # Explicit original F32 arithmetic proves early half-overflow has finite inverse.
 d=ref.div(np.asarray(0x7f7fffff,dtype='<u4').view('<f4'),ref.F32(127));inv=ref.div(ref.F32(1),d)
 assert np.isfinite(d) and d>=65520 and np.isfinite(inv)
 if phase==3:
  late_d=ref.div(np.asarray(0x7f,dtype='<u4').view('<f4'),ref.F32(127))
  with np.errstate(over='ignore'):late_inv=ref.div(ref.F32(1),late_d)
  assert np.isfinite(late_d) and late_d>0 and not np.isfinite(late_inv)
 edge.append({'case':label,'expected_phase':phase,'row':127,'group':31,'element':element,'original_reference_exception':message,'input_sha256':hashlib.sha256(x.tobytes()).hexdigest(),'modifications':'group1 all0x7f7fffff; last group all0x7f or element17 NaN','early_half_d_full_bits':hex(ref.bits(d)),'early_half_actual_inverse_finite':bool(np.isfinite(inv))})
(a.out/'global_quant_errors.json').write_text(json.dumps({'reference_sha256':hashlib.sha256(reference.read_bytes()).hexdigest(),'edges':edge},indent=2)+'\n')
print('M007_F32_INPUT_FIXTURE_PASS tensors='+str(len(records)))
