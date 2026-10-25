#!/usr/bin/env python3
"""Reuse original all128 Encoder0 context/WO gold; compute only frozen quant oracle."""
import argparse,hashlib,importlib.util,json,shutil
from pathlib import Path
import numpy as np
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();root=a.root.resolve()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def identity(p):p=Path(p);return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
refp=root/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py';assert sha(refp)=='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
original=root/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work';report=json.loads((original/'report.json').read_text());products=report['products'];assert report['real_rows']==128
for name in ['wo_input_context','wo']:
 x=products[name];assert sha(root/x['path'])==x['sha256'] and (root/x['path']).stat().st_size==x['bytes']==128*1024*4
old=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture/wo_0_weight';meta=json.loads((old/'fixture.json').read_text());assert meta['bias_name'] is None
for record in report['inputs']:
 if 'wo_0_weight/' in record['path']:assert sha(root/record['path'])==record['sha256']
a.out.mkdir(parents=True);d=a.out/'wo_0_weight';d.mkdir();source=root/products['wo_input_context']['path'];expected=root/products['wo']['path'];x=np.frombuffer(source.read_bytes(),dtype='<f4').reshape(128,1024);gold=np.frombuffer(expected.read_bytes(),dtype='<f4').reshape(128,1024)
spec=importlib.util.spec_from_file_location('r004_original_reference',refp);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref);aq=ref.quantize_many(x);assert len(aq)==128*32*34
shutil.copy2(source,d/'source_f32.bin');shutil.copy2(expected,d/'expected_f32.bin');(d/'activation_q8.bin').write_bytes(aq)
(d/'a_write.hex').write_text(''.join((aq[i+2:i+34]+aq[i:i+2])[::-1].hex()+'\n' for i in range(0,len(aq),34)))
b=source.read_bytes();(d/'input.hex').write_text(''.join(b[i:i+128][::-1].hex()+'\n' for i in range(0,len(b),128)))
for name in ['original_weight_q8.bin','bias.hex']+[f'p{p}.{s}' for p in range(4) for s in ['bin','hex']]:shutil.copy2(old/name,d/name)
with (d/'output.hex').open('w') as f:
 for s in range(16):
  for row in range(128):
   for half in range(2):f.write(gold[row,64*s+32*half:64*s+32*half+32].tobytes()[::-1].hex()+'\n')
# Original Encoder0 WO has no bias; last-group prebias equals the original final WO gold.
with (d/'pre_bias.hex').open('w') as f:
 for s in range(16):
  for pp in range(4):
   for mm in range(8):f.write(gold[16*mm:16*mm+16,64*s+16*pp:64*s+16*pp+16].tobytes()[::-1].hex()+'\n')
new={'case':1,'tensor':'wo.0.weight','K':1024,'N':1024,'G':32,'superblocks':16,'bias_name':None,'activation_classification':'ACTUAL_ENCODER0_ALL128_CONTEXT_INDEPENDENT_REFERENCE_LOCAL_CHAIN','original_model_real_rows':list(range(128)),'diagnostic_rows':[],'reference':identity(refp),'original_context':identity(source),'original_WO_gold':identity(expected),'original_E015_report':identity(original/'report.json'),'W_fixture':identity(old/'fixture.json'),'tensor_source':meta['tensor_source'],'layout':meta['layout'],'gold_recomputed':False,'quant_oracle':'original frozen quantize_many only','prebias_identity_reason':'Original Encoder0 WO has no bias, so final group PS is final original WO output','limitations':'Input is independent original local-reference context, not an actual Attention hardware output','files':[identity(f) for f in sorted(d.iterdir()) if f.is_file()]}
(d/'fixture.json').write_text(json.dumps(new,indent=2)+'\n');(a.out/'fixture.json').write_text(json.dumps({'scope':new['activation_classification'],'real_rows':128,'new_full_model_gold':False,'case':new},indent=2)+'\n');print('M007_F32_INPUT_FIXTURE_PASS original_context_rows=128 quant_groups=4096 WO_gold_values=131072')
