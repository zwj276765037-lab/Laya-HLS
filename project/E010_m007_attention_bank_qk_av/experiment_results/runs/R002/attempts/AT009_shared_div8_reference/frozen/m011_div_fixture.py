#!/usr/bin/env python3
import argparse,hashlib,importlib.util,json
from pathlib import Path
import numpy as np
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
s=importlib.util.spec_from_file_location('reference',a.reference);ref=importlib.util.module_from_spec(s);s.loader.exec_module(ref)
def read(n):return np.array([int(x,16)for x in(a.input/n).read_text().split()],dtype='<u4')
aa=[];bb=[];gg=[];ee=[]
with np.errstate(over='ignore',under='ignore',invalid='ignore',divide='ignore'):
 for prefix in('full_','sliding_'):
  numer=read(prefix+'exp.mem');denom=np.repeat(read(prefix+'total.mem'),128);expected=read(prefix+'prob.mem')
  for n,d,g in zip(numer,denom,expected):
   value=ref.bits(ref.div(np.array([n],dtype='<u4').view('<f4')[0],np.array([d],dtype='<u4').view('<f4')[0]));assert value==int(g)
   aa.append(int(n));bb.append(int(d));gg.append(value);ee.append(0)
 main=len(aa)
 for n,d in zip([0x3f800000,0x7fc00001,0x7f800000,0x3f800000,1,0x3f800000,0x7f7fffff,0x80000000],[0,0x3f800000,0x3f800000,0x7fc00001,0x3f800000,0x7f7fffff,1,0x3f800000]):
  invalid=(n&0x7f800000)==0x7f800000 or(d&0x7f800000)==0x7f800000 or(d&0x7fffffff)==0
  value=0 if invalid else ref.bits(ref.div(np.array([n],dtype='<u4').view('<f4')[0],np.array([d],dtype='<u4').view('<f4')[0]))
  aa.append(n);bb.append(d);gg.append(value);ee.append(int(invalid or(value&0x7f800000)==0x7f800000))
for name,x in [('div_a',aa),('div_b',bb),('div_gold',gg),('div_error',ee)]:(a.out/(name+'.mem')).write_text(''.join(f'{v:08x}\n'for v in x))
files=[a.reference,*sorted(a.input.glob('*.mem')),*sorted(a.out.glob('*.mem'))]
(a.out/'manifest.json').write_text(json.dumps({'scope':'R002 real full/sliding exp/total direct-div pairs and8accepted-error/underflow directed lanes','div_main_count':main,'div_total_count':len(aa),'files':[{'path':str(f),'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'bytes':f.stat().st_size}for f in files]},indent=2)+'\n')
print(f'M011_DIV_REFERENCE_PASS actual_pairs{main} directed8 subnormal_and_error_retirement1',flush=True)
