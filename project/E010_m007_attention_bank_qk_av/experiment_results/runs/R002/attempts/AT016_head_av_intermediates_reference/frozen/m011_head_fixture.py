#!/usr/bin/env python3
"""Local AV intermediates from frozen independent softmax oracle, no DUT imports."""
import argparse,hashlib,json
from pathlib import Path
import numpy as np
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
def load(n,shape):return np.array([int(s,16)for s in(a.input/(n+'.mem')).read_text().split()],dtype='<u4').view('<f4').reshape(shape)
def save(n,x):(a.out/(n+'.mem')).write_text(''.join(f'{int(z):08x}\n'for z in np.asarray(x,dtype='<f4').reshape(-1).view('<u4')))
v=load('v',(128,64))
for prefix in('full_','sliding_'):
 prob=load(prefix+'prob',(128,128));acc=np.zeros((128,64),dtype='<f4');prod=[];partial=[]
 for k in range(128):
  z=np.multiply(prob[:,k,None],v[k,None,:],dtype=np.float32);acc=np.add(acc,z,dtype=np.float32);prod.append(z);partial.append(acc.copy())
 save(prefix+'av_product',np.stack(prod));save(prefix+'av_partial',np.stack(partial));assert np.array_equal(acc.view('u4'),load(prefix+'out',(128,64)).view('u4'))
paths=[a.reference,*sorted(a.input.glob('*.mem')),*sorted(a.out.glob('*.mem'))]
(a.out/'manifest.json').write_text(json.dumps({'scope':'full and local sliding actual softmax probability AV intermediates; no full-model gold','files':[{'path':str(f),'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'bytes':f.stat().st_size}for f in paths]},indent=2)+'\n')
print('M011_HEAD_REFERENCE_PASS full_and_sliding products1048576 partials1048576 output8192 independent_softmax_prob1',flush=True)
