#!/usr/bin/env python3
"""Bind frozen real ACT source to r2 BOs and recompute independent R0 gold."""
import hashlib,json,sys
from pathlib import Path
import numpy as np
from make_real_fixtures import oracle,digest
P=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
sys.path.insert(0,str(P/'tests'))
import full_reference as ref
from full_fixture_test import Evidence
out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False)
source_manifest=P/'results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/manifest.json'
m=json.loads(source_manifest.read_text());case=next(x for x in m['cases'] if x['name']=='act')
for r in case['products'].values():
 p=Path(r['path']);assert p.stat().st_size==r['bytes'] and digest(p)['sha256']==r['sha256']
source=Path(case['products']['source_f32']['path']).read_bytes()
loader=P/'results/compute_throughput_optimization_20261010/attempts/t4_dual_w_fixture_01/work'
lm=json.loads((loader/'fixture_manifest.json').read_text())
for name,r in lm['files'].items():
 p=loader/name;assert p.stat().st_size==r['bytes'] and digest(p)['sha256']==r['sha256']
 assert name!='fixture_manifest.json'
 if name.startswith('act_') or name in ('model_identity.hex','aux_header.hex','expected_aux_header.hex'):
  (out/name).write_bytes(p.read_bytes())
def unhex(name,width):
 return b''.join(int(x,16).to_bytes(width,'little') for x in (out/name).read_text().split())
q0=unhex('act_q0.hex',64);ws=unhex('act_scale.hex',64);bias=unhex('act_bias.hex',4)
e=Evidence(P,out/'gguf_evidence');w=e.weight('act_fc2.weight');b=e.weight('act_fc2.bias')
assert b==bias and len(source)==1024 and len(w)==544
for n in range(2):
 for g in range(8):
  assert q0[g*256+n*32:g*256+n*32+32]==w[(n*8+g)*34+2:(n*8+g+1)*34]
  assert ws[g*16+n*2:g*16+n*2+2]==w[(n*8+g)*34:(n*8+g)*34+2]
aq,sa,steps,y,packed=oracle(ref,source,w,bias,1,256,2)
assert aq==Path(case['products']['a8_q']['path']).read_bytes()
assert sa==Path(case['products']['a8_scale']['path']).read_bytes()
assert y==Path(case['products']['output_f32']['path']).read_bytes()
def emit(name,data,width):
 assert len(data)%width==0
 (out/name).write_text(''.join(f'{int.from_bytes(data[i:i+width],"little"):0{width*2}x}\n' for i in range(0,len(data),width)))
emit('source.mem',source,64);emit('gold_q.mem',aq,16);emit('gold_scale.mem',sa,2);emit('gold_y.mem',y,4)
a=np.frombuffer(steps,dtype='<u4').reshape(8,2,6)
for col,name in ((0,'dot'),(3,'product'),(4,'term'),(5,'ps')):
 records=bytearray()
 for g in range(8): records+=a[g,:,col].tobytes()+bytes(120)
 emit(name+'.mem',records,128)
dot=np.frombuffer(steps,dtype='<u4').reshape(8,2,6)[:,:,0].view('<i4').astype('<f4').view('<u4')
emit('dotf.mem',b''.join(dot[g].tobytes()+bytes(120) for g in range(8)),128)
record={'schema':'laya_act_production_fixture_v1','source_manifest':digest(source_manifest),
 'loader_manifest':digest(loader/'fixture_manifest.json'),'reference':digest(P/'tests/full_reference.py'),
 'generator':digest(Path(__file__)),'model_sha256':'6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18',
 'scope':{'B':1,'S':128,'rows':1,'K':256,'N':2,'source':'independent frozen ACT_HIDDEN F32'},
 'files':{p.name:digest(p) for p in out.iterdir() if p.is_file()}}
(out/'manifest.json').write_text(json.dumps(record,indent=2,sort_keys=True)+'\n')
print('ACT_PRODUCTION_FIXTURE_PASS rows=1 K=256 N=2 independent_R0=1 frozen_r2_BO=1',flush=True)
