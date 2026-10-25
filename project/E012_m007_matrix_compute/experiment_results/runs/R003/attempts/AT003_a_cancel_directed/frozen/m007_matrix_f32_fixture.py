#!/usr/bin/env python3
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
src=a.root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
a.out.mkdir(parents=True)
records=[]
for f in sorted(src.glob('*/source_f32.bin')):
 b=f.read_bytes();assert len(b)%128==0
 d=a.out/f.parent.name;d.mkdir();o=d/'input.hex'
 o.write_text(''.join(b[i:i+128][::-1].hex()+'\n' for i in range(0,len(b),128)))
 records.append({'source':str(f),'source_sha256':hashlib.sha256(b).hexdigest(),'groups':len(b)//128,'input_hex':str(o),'input_sha256':hashlib.sha256(o.read_bytes()).hexdigest(),'provenance':json.loads((f.parent/'fixture.json').read_text())})
(a.out/'fixture.json').write_text(json.dumps({'operation':'byte-to-1024bit little-endian hex only; no oracle arithmetic','source_fixture':str(src),'records':records},indent=2)+'\n')
print('M007_F32_INPUT_FIXTURE_PASS tensors='+str(len(records)))
