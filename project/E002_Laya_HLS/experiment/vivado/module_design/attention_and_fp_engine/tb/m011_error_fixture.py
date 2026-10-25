#!/usr/bin/env python3
"""Finite diagnostic operands that distinguish logical Check from arrival."""
import argparse,hashlib,json
from pathlib import Path
import numpy as np
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
q=np.zeros((128,64),dtype='<f4');k=np.zeros_like(q);q[0,:2]=np.float32(1);q[4,2]=np.array([0x7f7fffff],dtype='<u4').view('<f4')[0];k[0,:2]=q[4,2];k[127,2]=np.float32(2)
with np.errstate(over='ignore',invalid='ignore'):
 prod=np.multiply(q[:8,None,:],k[None,:,:],dtype=np.float32)
 bad=np.argwhere(~np.isfinite(prod));assert bad.tolist()==[[4,127,2]]
 tree=np.add(prod[...,::2],prod[...,1::2],dtype=np.float32)
 assert not np.isfinite(tree[0,0,0])
# Original tile8 reference checks all products before any tree level. q4/key127
# arrives physically after q0/key0's tree overflow in the four-query schedule.
rank=0x1000000000000000|(4<<32)|(127<<16)|2;element=4*128*64+127*64+2
for n,x in [('error_q',q),('error_k',k)]:
 u=x.reshape(-1).view('<u4');(a.out/(n+'.mem')).write_text(''.join(f'{int(v):08x}\n'for v in u))
(a.out/'error_expected.mem').write_text(f'{rank&0xffffffff:08x}\n{rank>>32:08x}\n00000000\n00000000\n{element:08x}\n')
(a.out/'error_manifest.json').write_text(json.dumps({'scope':'finite diagnostic head-local Check ordering, not model-trace fixture','source':str(Path(__file__)),'source_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'independent':'numpy F32 multiply/add; original full_reference attention_many tile8 product-before-tree order','first_logical_error':{'phase':0,'tile':0,'q':4,'key':127,'channel':2,'element':element,'rank':f'{rank:016x}'},'earlier_physical_candidate':{'phase':1,'q':0,'key':0,'node':0},'files':[{'name':f.name,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()}for f in sorted(a.out.glob('*.mem'))]},indent=2)+'\n')
print('M011_ERROR_REFERENCE_PASS logical_product_q4_k127_c2 earlier_tree_q0_k0_node0',flush=True)
