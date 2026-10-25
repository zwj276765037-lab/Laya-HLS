#!/usr/bin/env python3
"""Pack frozen original local GEGLU products; never derive gold from DUT."""
import argparse,hashlib,json
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[7]
ORIGINAL=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 r=json.loads((ORIGINAL/'report.json').read_text());assert r['status']=='ORIGINAL_LOCAL_REFERENCE_COMPLETE'and r['real_rows']==128 and r['real_tanh_values']==335872
 names=['x','gate','u','v','w','t','z','h','r','s','y','geglu'];arrays=[];inputs={}
 for name in names:
  d=r['products'][name];src=ROOT/d['path'];assert sha(src)==d['sha256']and d['shape']==[128,2624]
  arrays.append(np.fromfile(src,dtype='<u4'));inputs[name]={'path':str(src.relative_to(ROOT)),'sha256':sha(src)}
 data=np.stack(arrays,axis=1);assert data.shape==(335872,12)
 target=o/'geglu_vectors.hex'
 with target.open('w')as out:
  for row in data:out.write(''.join(f'{int(x):08x}'for x in row)+'\n')
 report={'schema':'m007-g-original-fixture-v1','status':'PACKED_ORIGINAL_PRODUCTS','count':335872,'shape':[128,2624],'record_fields_msb_first':names,'reference_report_sha256':sha(ORIGINAL/'report.json'),'inputs':inputs,'vectors_sha256':sha(target),'vectors_bytes':target.stat().st_size,'scope':'Bit-preserving serialization of frozen original128-row reference; no new arithmetic or DUT-derived expected values'}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_G_REFERENCE_PACK_PASS count335872 fields12',flush=True)
if __name__=='__main__':main()
