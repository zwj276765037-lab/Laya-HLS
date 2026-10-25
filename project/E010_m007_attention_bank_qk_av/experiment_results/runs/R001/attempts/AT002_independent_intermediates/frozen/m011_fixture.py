#!/usr/bin/env python3
"""Independent intermediate attention oracle; no DUT/helper imports."""
import argparse,hashlib,importlib.util,json
from pathlib import Path
import numpy as np

def main():
 p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
 spec=importlib.util.spec_from_file_location('independent_full_reference',a.reference);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
 def load(n,shape):return np.fromfile(a.input/(n+'.bin'),dtype='<f4').reshape(shape)
 def save(n,x):
  u=np.asarray(x,dtype='<f4').reshape(-1).view('<u4');(a.out/(n+'.mem')).write_text(''.join(f'{int(z):08x}\n'for z in u))
 q=load('q',(128,64));k=load('k',(128,64));v=load('v',(128,64));prob=load('prob',(128,128));mask=np.array([int(z,16)for z in(a.input/'mask.mem').read_text().split()],dtype=np.uint8)
 for n,x in [('q',q),('k',k),('v',v),('prob',prob)]:save(n,x)
 tree=np.multiply(q[:,None,:],k[None,:,:],dtype=np.float32);save('qk_l0',tree)
 for level in range(1,7):tree=np.add(tree[:,:,0::2],tree[:,:,1::2],dtype=np.float32);save('qk_l'+str(level),tree)
 scale=np.multiply(tree[:,:,0],np.float32(.125),dtype=np.float32);save('qk_scale',scale)
 for sliding in (False,True):
  score=np.stack([ref.qk_row(q[r],k,mask,128,r,sliding)for r in range(128)]);save('score_sliding'if sliding else'score',score)
  maximum=np.array([ref.F32(row[0])for row in score],dtype='<f4')
  for r in range(128):
   for z in score[r,1:]:
    if z>maximum[r]:maximum[r]=z
  save('max_sliding'if sliding else'save_max',maximum)
  if not sliding:
   assert np.array_equal(score.view('u4'),load('score',(128,128)).view('u4')),'frozen score differs'
   assert np.array_equal(maximum.view('u4'),load('maximum',(128,)).view('u4')),'frozen maximum differs'
 acc=np.zeros((128,64),dtype='<f4');products=[];partials=[]
 for key in range(128):
  prod=np.multiply(prob[:,key,None],v[key,None,:],dtype=np.float32);acc=np.add(acc,prod,dtype=np.float32);products.append(prod);partials.append(acc.copy())
 save('av_product',np.stack(products));save('av_partial',np.stack(partials));save('out',acc)
 gold=load('out',(128,64));assert np.array_equal(acc.view('u4'),gold.view('u4')),'frozen context differs'
 for r in range(128):assert np.array_equal(ref.av_row(prob[r],v,128).view('u4'),gold[r].view('u4')),'independent av_row differs'
 (a.out/'mask.mem').write_text((a.input/'mask.mem').read_text())
 files=[a.reference,*sorted(a.input.glob('*.bin')),a.input/'mask.mem',*sorted(a.out.glob('*.mem'))]
 (a.out/'manifest.json').write_text(json.dumps({'kind':'independent local attention intermediates; original full fixture final bit equality','sliding':'new local qk_row reference, not full-model gold','files':[{'path':str(f),'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()}for f in files]},indent=2)+'\n')
 print('M011_REFERENCE_PASS score16384 max128 context8192 qk_products1048576 av_products1048576 av_partials1048576',flush=True)
if __name__=='__main__':main()
