#!/usr/bin/env python3
"""Finite Decision-QKV fault: original head order conflicts with local tile order."""
import argparse,hashlib,importlib.util,json,warnings
from pathlib import Path
import numpy as np
p=argparse.ArgumentParser();p.add_argument('--input',required=True);p.add_argument('--out',required=True);a=p.parse_args();i=Path(a.input);o=Path(a.out);o.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
rp=i/'full_reference.py';assert sha(rp)=='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784';spec=importlib.util.spec_from_file_location('original_ref',rp);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
x=np.fromfile(i/'decision0_pre_qkv.bin',dtype='<f4').reshape(128,3,16,64).copy();original=x.copy();maxf=np.array([0x7f7fffff],dtype='<u4').view('<f4')[0]
# Head0's first product failure is atquery127/tile15. Every later head fails
# atquery0/tile0. All source operands remain finite; V is original throughout.
for h in range(16):
 x[:,0,h,0]=np.float32(0);x[:,1,h,0]=np.float32(0);x[127 if h==0 else 0,0,h,0]=maxf;x[0,1,h,0]=maxf
assert np.isfinite(x).all();assert x[:,2].tobytes()==original[:,2].tobytes();mask=np.array([int(z,16)for z in(i/'mask.mem').read_text().splitlines()],dtype=np.uint8);assert int(mask.sum())==72
expected=[]
with np.errstate(over='ignore',invalid='ignore'):
 for h in range(16):
  first=None
  for tile in range(16):
   prod=ref.mul(x[tile*8:tile*8+8,0,h,None,:],x[None,:,1,h,:]);bad=np.argwhere(~np.isfinite(prod))
   if len(bad):
    q,k,node=map(int,bad[0]);first=(11,h,tile,0,q,k,node);break
   tree=prod
   for level in range(1,7):
    tree=ref.add(tree[...,::2],tree[...,1::2]);bad=np.argwhere(~np.isfinite(tree))
    if len(bad):q,k,node=map(int,bad[0]);first=(11,h,tile,level,q,k,node);break
   if first:break
  assert first is not None;expected.append(first)
 try:ref.attention_many(x.reshape(1,128,3072),mask[None,:],False)
 except ArithmeticError as e:message=str(e);assert message=='attention QK products: nonfinite'
 else:raise AssertionError('original graph did not reject actual finite fault')
assert expected[0]==(11,0,15,0,7,0,0);assert all(t==(11,h,0,0,0,0,0)for h,t in enumerate(expected)if h>0);first=min(expected);assert first==expected[0]
bits=x.astype('<f4').view('<u4').reshape(-1);(o/'decision0_reverse_qk_pre.bin').write_bytes(x.astype('<f4').tobytes());(o/'decision0_reverse_qk_pre.mem').write_text(''.join(f'{int(v):08x}\n'for v in bits))
report={'scope':'original B1 Decision0 actual finite source perturbation; no normal gold regeneration and no DUT imports','source':{'path':str(i/'decision0_pre_qkv.bin'),'sha256':sha(i/'decision0_pre_qkv.bin')},'original_reference_sha256':sha(rp),'all393216_source_words_finite':True,'all131072_V_words_unchanged':True,'mutation':'Q/K channel0 zeros except finite max at head0 Q127/K0 and heads1..15 Q0/K0','per_head_first_original_QK_tuple':expected,'first_original_layer_tuple':first,'naive_local_tile_min_would_select_head1':True,'actual_original_attention_many_exception':message,'outputs':[{'name':q.name,'bytes':q.stat().st_size,'sha256':sha(q)}for q in sorted(o.iterdir())if q.is_file()]};(o/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print('M011_LAYER_FAULT_REFERENCE_PASS finite393216 Vunchanged131072 real_original_QK_overflow1 first_head0_tile15 local_tile_min_wrong1',flush=True)
