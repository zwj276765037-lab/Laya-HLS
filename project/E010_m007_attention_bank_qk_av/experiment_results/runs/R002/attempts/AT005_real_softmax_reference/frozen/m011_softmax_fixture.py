#!/usr/bin/env python3
"""Independent full/sliding softmax/head intermediate oracle; no DUT imports."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
import numpy as np
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('independent_reference',a.reference);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
def load(n,shape):return np.fromfile(a.input/(n+'.bin'),dtype='<f4').reshape(shape)
def save(n,x):
 u=np.asarray(x,dtype='<f4').reshape(-1).view('<u4');(a.out/(n+'.mem')).write_text(''.join(f'{int(z):08x}\n'for z in u))
def same(x,y):return np.array_equal(np.asarray(x,dtype='<f4').view('u4'),np.asarray(y,dtype='<f4').view('u4'))
q=load('q',(128,64));k=load('k',(128,64));v=load('v',(128,64));mask=np.array([int(z,16)for z in(a.input/'mask.mem').read_text().split()],dtype=np.uint8)
for n,x in [('q',q),('k',k),('v',v)]:save(n,x)
(a.out/'mask.mem').write_text((a.input/'mask.mem').read_text());shifts=[]
for slide in (False,True):
 prefix='sliding_'if slide else'full_';score=np.stack([ref.qk_row(q[r],k,mask,128,r,slide)for r in range(128)])
 maximum=score[:,0].copy()
 for key in range(1,128):
  for row in range(128):
   if score[row,key]>maximum[row]:maximum[row]=score[row,key]
 shift=np.subtract(score,maximum[:,None],dtype=np.float32);assert np.isfinite(shift).all()and(shift<=0).all()
 exp=np.array([ref.libm_exp(x)for x in shift.reshape(-1)],dtype='<f4').reshape(128,128);tree=exp
 for level in range(1,8):tree=np.add(tree[:,::2],tree[:,1::2],dtype=np.float32);save(prefix+'sum_l'+str(level),tree)
 total=tree[:,0];assert np.isfinite(total).all()and(total>0).all();prob=np.divide(exp,total[:,None],dtype=np.float32)
 out=np.stack([ref.av_row(prob[row],v,128)for row in range(128)])
 for n,x in [('score',score),('maximum',maximum),('shift',shift),('exp',exp),('total',total),('prob',prob),('out',out)]:save(prefix+n,x)
 if not slide:
  for n,x,shape in [('score',score,(128,128)),('maximum',maximum,(128,)),('prob',prob,(128,128)),('out',out,(128,64))]:assert same(x,load(n,shape)),n+'original differs'
 shifts.extend(int(x)for x in shift.reshape(-1).view('<u4'))
directed=[0,0x80000000,0x80000001,0x80000002,0x807fffff,0x80800000,0x80800001,0xb2800000,0xb3000000,0xb3800000,0xbf800000,0xc2b00000,0xc61c4000]
directed+=list(range(0xc2cff1a4,0xc2cff1c5))+list(range(0xc2aeac40,0xc2aeac61))
words=shifts+directed;gold=[ref.bits(ref.libm_exp(np.array([x],dtype='<u4').view('<f4')[0]))for x in words]
for name,vals in [('exp_x',words),('exp_gold',gold),('exp_status',[0]*len(words))]:(a.out/(name+'.mem')).write_text(''.join(f'{x:08x}\n'for x in vals))
libm=Path('/lib/x86_64-linux-gnu/libm.so.6').resolve();paths=[a.reference,libm,*sorted(a.input.glob('*.bin')),a.input/'mask.mem',*sorted(a.out.glob('*.mem'))]
(a.out/'manifest.json').write_text(json.dumps({'scope':'original real head0 full plus independent local sliding; no new full-model gold','exp_count':len(words),'actual_full_shift_count':16384,'actual_sliding_shift_count':16384,'directed_count':len(directed),'numpy':np.__version__,'python':sys.version,'files':[{'path':str(f),'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()}for f in paths]},indent=2)+'\n')
print(f'M011_SOFTMAX_REFERENCE_PASS exp_count{len(words)} full16384 sliding16384 original_score_prob_context_bit_equal1',flush=True)
