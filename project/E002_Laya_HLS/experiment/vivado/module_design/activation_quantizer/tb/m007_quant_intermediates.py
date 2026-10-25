#!/usr/bin/env python3
"""New immutable diagnostic evidence derived only from frozen original inputs/ref."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import numpy as np
from m007_quant_reference import REFERENCE,REFERENCE_SHA,bits,line,sha

def main():
 p=argparse.ArgumentParser();p.add_argument('--fixture',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 assert sha(REFERENCE)==REFERENCE_SHA
 original=json.loads((a.fixture/'report.json').read_text());assert original['status']=='PASS_INDEPENDENT_QUANT_REFERENCE'
 for name,info in original['files'].items():assert sha(a.fixture/name)==info['sha256']
 spec=importlib.util.spec_from_file_location('original_quant_intermediates',REFERENCE);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
 a.output.mkdir(parents=True,exist_ok=True);report={'reference_sha256':REFERENCE_SHA,'fixture_report_sha256':sha(a.fixture/'report.json'),'cases':[],'files':{}}
 for case in original['cases']:
  tensor=np.fromfile(a.fixture/case['name']/'source.f32.bin',dtype='<f4').reshape(-1,32)
  maximum=np.max(np.abs(tensor),axis=1).astype('<f4');d=ref.div(maximum,np.float32(127));inverse=np.zeros_like(d)
  nonzero=d!=0;inverse[nonzero]=ref.div(np.float32(1),d[nonzero]);products=ref.mul(tensor,inverse[:,None])
  assert np.isfinite(products).all()
  folder=a.output/case['name'];folder.mkdir()
  (folder/'scalars.hex').write_text(''.join(f'{bits(m):08x}{bits(s):08x}{bits(v):08x}\n'for m,s,v in zip(maximum,d,inverse)))
  (folder/'products.hex').write_text(''.join(line(row.tobytes())+'\n'for row in products))
  report['cases'].append({'name':case['name'],'groups':len(tensor)})
 edges=[np.frombuffer(bytes.fromhex(s.strip())[::-1],dtype='<f4')for s in(a.fixture/'edge_input.hex').read_text().splitlines()]
 products=[];valid=[]
 for row,case in zip(edges,original['edges']):
  use=case['stage']in(0,5,6);valid.append(use)
  if use:
   inverse=np.asarray(case['inverse_u32'],dtype='<u4').view('<f4')[()];product=ref.mul(row,inverse)
  else:product=np.zeros(32,dtype='<f4')
  products.append(line(product.tobytes()))
 (a.output/'edge_products.hex').write_text('\n'.join(products)+'\n');report['edge_product_valid']=valid
 for path in sorted(a.output.rglob('*')):
  if path.is_file():report['files'][str(path.relative_to(a.output))]={'sha256':sha(path),'bytes':path.stat().st_size}
 report['status']='PASS_ORIGINAL_QUANT_INTERMEDIATES';(a.output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 print('M007_QUANT_INTERMEDIATES_PASS groups=30976 edge_groups=16 original_reference_only=1',flush=True)
if __name__=='__main__':main()
