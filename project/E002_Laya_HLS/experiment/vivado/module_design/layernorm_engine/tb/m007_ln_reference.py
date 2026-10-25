#!/usr/bin/env python3
"""Frozen local LN reference, saved final_norm association, independent scalar gold."""
import argparse
import ctypes
import importlib.util
import json
import math
from pathlib import Path
import struct
import warnings
import numpy as np
from m007_ln_guard import EXPERIMENT as ROOT,sha

REF_SHA='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
MODEL_SHA='6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18'
INVENTORY_SHA='40983ab871903db1281eb82901521fae5f5e1b862d8c2d4f22deba7cbe44c5c6'
ORACLE=ROOT/'results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128'
INPUTS={'encoder_00_out.f32.bin':'9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b',
 'encoder_27_out.f32.bin':'964be7a3b198234aa78643f9dda0d538af70f04a31b2a71b8b652f17710f9f38'}
FINAL_SHA='6501eb1ea077d04a36e3955a1f995afb215c2d862fcea1c78f6e2fc3be3b74ef'
def bits(value):return int(np.asarray(value,dtype='<f4').view('<u4'))
def fbits(value):return np.asarray(value,dtype='<u4').view('<f4')[()]
def line(data):return bytes(data)[::-1].hex()
def dump_vectors(folder,name,tensor):
 data=np.asarray(tensor,dtype='<f4');(folder/(name+'.f32.bin')).write_bytes(data.tobytes())
 (folder/(name+'.hex')).write_text(''.join(line(row.tobytes())+'\n'for row in data.reshape(-1,32)))
def integer_sqrt_bits(b):
 frac=b&0x7fffff;exponent=(b>>23)&255
 if exponent==0:
  shift=24-frac.bit_length();mant=frac<<shift;e=-126-shift
 else:mant=(1<<23)|frac;e=exponent-127
 if e&1:mant<<=1;e-=1
 radicand=mant<<23;root=math.isqrt(radicand)
 rounded=root+int(4*radicand>(2*root+1)**2)
 result_exp=e//2+127
 if rounded==(1<<24):rounded>>=1;result_exp+=1
 return result_exp<<23|(rounded&0x7fffff)
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--model',type=Path,default=ROOT.parents[3]/'model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 reference=ROOT/'tests/full_reference.py';inventory=ROOT/'reference/runs/typed_q8_ref_20261005/gguf_inventory.json'
 assert sha(reference)==REF_SHA and sha(inventory)==INVENTORY_SHA and sha(a.model)==MODEL_SHA and a.model.stat().st_size==455179648
 spec=importlib.util.spec_from_file_location('m007_ln_original',reference);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
 item=next(item for item in json.loads(inventory.read_text())['tensors']if item['name']=='final_norm_w');assert item['ggml_type_id']==0 and math.prod(item['ggml_ne'])==1024
 with a.model.open('rb')as stream:stream.seek(item['absolute_file_offset']);gamma_raw=stream.read(4096)
 gamma=np.frombuffer(gamma_raw,dtype='<f4');assert gamma.size==1024 and np.isfinite(gamma).all()
 (a.output/'gamma.f32.bin').write_bytes(gamma_raw);(a.output/'gamma.hex').write_text(''.join(line(row.tobytes())+'\n'for row in gamma.reshape(-1,32)))
 report={'reference_sha256':REF_SHA,'model_sha256':MODEL_SHA,'model_path':str(a.model),'inventory_sha256':INVENTORY_SHA,'numpy':np.__version__,
  'gamma':{'tensor':'final_norm_w','absolute_file_offset':item['absolute_file_offset'],'bytes':4096,'sha256':sha(a.output/'gamma.f32.bin')},'cases':[],'files':{}}
 scalar_bits=[]
 for name,digest in INPUTS.items():
  assert sha(ORACLE/name)==digest and(ORACLE/name).stat().st_size==524288
  source=np.fromfile(ORACLE/name,dtype='<f4').reshape(128,1024);g=gamma if name.startswith('encoder_27')else None
  original=ref.layernorm_many(source,g);tree=source.copy();tree1=[]
  for level in range(10):tree=ref.add(tree[:,::2],tree[:,1::2]);tree1.append(tree.copy())
  total=tree[:,0];mean=ref.div(total,np.float32(1024));delta=ref.sub(source,mean[:,None]);square=ref.mul(delta,delta);tree=square.copy();tree2=[]
  for level in range(10):tree=ref.add(tree[:,::2],tree[:,1::2]);tree2.append(tree.copy())
  square_total=tree[:,0];variance=ref.div(square_total,np.float32(1024));shifted=ref.add(variance,fbits(0x3727c5ac));root=np.sqrt(shifted,dtype=np.float32);inverse=ref.div(np.float32(1),root)
  normalized=ref.mul(delta,inverse[:,None]);output=normalized if g is None else ref.mul(normalized,g)
  assert output.tobytes()==original.tobytes()
  folder=a.output/('gamma_encoder27'if g is not None else'plain_encoder00');folder.mkdir()
  for field,tensor in(('raw',source),('delta',delta),('square',square),('normalized',normalized),('output',output)):dump_vectors(folder,field,tensor)
  for field,levels in(('tree1',tree1),('tree2',tree2)):
   all_nodes=np.concatenate(levels,axis=1);(folder/(field+'.f32.bin')).write_bytes(all_nodes.tobytes());(folder/(field+'.hex')).write_text(''.join(f'{int(b):08x}\n'for b in all_nodes.view('<u4').reshape(-1)))
  stats=np.stack((total,mean,square_total,variance,shifted,root,inverse),axis=1).astype('<f4');(folder/'stats.f32.bin').write_bytes(stats.tobytes());(folder/'stats.hex').write_text(''.join(line(row.tobytes())+'\n'for row in stats))
  scalar_bits+=stats.view('<u4').reshape(-1).tolist()
  case={'name':folder.name,'input':name,'input_sha256':digest,'output_sha256':sha(folder/'output.f32.bin'),'rows':128,'tree_nodes_each':128*1023,'original_local_layernorm_exact':True}
  if g is not None:
   assert sha(ORACLE/'final_norm.f32.bin')==FINAL_SHA and(ORACLE/'final_norm.f32.bin').read_bytes()==output.tobytes();case.update(saved_final_norm_sha256=FINAL_SHA,saved_final_norm_all128_exact=True)
  report['cases'].append(case)
 # Every exponent class, directed underflow ties/signs, and seeded random bits.
 values=[(sign<<31)|(exponent<<23)|mant for sign in(0,1)for exponent in range(256)for mant in(0,1,2,0x3fffff,0x400000,0x7ffffe,0x7fffff)]
 values +=[0x00000200,0x00000600,0x00000a00,0x007ffe00,0x00800200,0x04ffffff,0x05000001]
 values +=np.random.default_rng(20261021).integers(0,1<<32,8192,dtype=np.uint32).tolist()+scalar_bits
 sqrtf=ctypes.CDLL('libm.so.6').sqrtf;sqrtf.argtypes=[ctypes.c_float];sqrtf.restype=ctypes.c_float
 vectors=[];finite_sqrt=0
 for b in values:
  x=fbits(b);div_error=(b>>23&255)==255;sqrt_error=div_error or bool(b>>31 and b&0x7fffffff)
  with np.errstate(all='ignore'),warnings.catch_warnings():
   warnings.simplefilter('ignore');d=ref.div(x,np.float32(1024));s=np.sqrt(x,dtype=np.float32)
  if not sqrt_error and b&0x7fffffff:
   assert bits(s)==bits(sqrtf(ctypes.c_float(float(x))))==integer_sqrt_bits(b);finite_sqrt+=1
  elif not sqrt_error:assert bits(s)==b
  vectors.append(f'{int(sqrt_error):x}{int(div_error):x}{bits(s)if not sqrt_error else 0:08x}{bits(d)if not div_error else 0:08x}{b:08x}')
 (a.output/'scalars.hex').write_text('\n'.join(vectors)+'\n')
 report.update(status='PASS_ORIGINAL_LN_REFERENCE_AND_SCALARS',scalar_count=len(values),sqrt_numpy_libm_integer_agreements=finite_sqrt,seed=20261021,full_model_gold_generated=False)
 for path in sorted(a.output.rglob('*')):
  if path.is_file():report['files'][str(path.relative_to(a.output))]={'sha256':sha(path),'bytes':path.stat().st_size}
 (a.output/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(f'M007_LN_REFERENCE_PASS rows=256 saved_final_norm128_exact=1 scalar_vectors={len(values)} sqrt_independent_agreements={finite_sqrt} full_model_gold=0',flush=True)
if __name__=='__main__':main()
