#!/usr/bin/env python3
"""Build and verify production-ineligible request-v1 fixture from ABI native capture."""
import hashlib,json,pathlib,struct
ROOT=pathlib.Path(__file__).resolve().parent
R=ROOT/'runs/typed_q8_ref_20261005';A=R/'abi_replay';O=R/'original_native'
def floats(p):return struct.unpack('<'+'f'*(p.stat().st_size//4),p.read_bytes())
def main():
 m=json.loads((A/'manifest.json').read_text());t={x['name']:x for x in m['tensors'] if x['name']!='output_anchor'}
 b,s=2,128
 names=['input_ids','attention_mask_abi_u8','marker_pos','marker_mask_abi_u8','qtype'];data=[(A/t[n]['path']).read_bytes() for n in names]
 lengths=[4*b*s,b*s,64*b,16*b,4*b];offsets=[];off=320
 for x,l in zip(data,lengths):assert len(x)==l;offsets.append(off);off=(off+l+63)&~63
 frame=bytearray(off)
 struct.pack_into('<4s6HI2H2Q',frame,0,b'LYRQ',1,0,128,32,5,0,off,b,s,1,1)
 frame[40:56]=bytes.fromhex(m['model']['sha256'])[:16]
 struct.pack_into('<4I',frame,104,128,320,16384,4096)
 for i,(x,o,l) in enumerate(zip(data,offsets,lengths)):
  dtype=2 if i in [1,3] else 1;rank=1 if i==4 else 2;dim=s if i<2 else 16 if i<4 else 1;elem=1 if dtype==2 else 4
  struct.pack_into('<HBBIIHHIIII',frame,128+32*i,i+1,dtype,rank,o,l,b,dim,dim*elem,0 if rank==1 else elem,b*dim,0)
  frame[o:o+l]=x
 for i,x in enumerate(data):
  e=struct.unpack_from('<HBBIIHHIIII',frame,128+32*i);assert frame[e[3]:e[3]+e[4]]==x
 assert offsets==[320,1344,1600,1728,1792] and len(frame)==1856
 (A/'request_v1.bin').write_bytes(frame)
 comparison={}
 for name,node in [('candidate_raw_logits','ir_1469'),('act_raw_logits','ir_1616')]:
  p=O/'native/forward_0'/f'{node}.bin';q=A/'native/forward_0'/f'{node}.bin';u=floats(p);v=floats(q)
  comparison[name]={'max_abs_diff':max(abs(x-y) for x,y in zip(u,v)),'bitwise_equal':p.read_bytes()==q.read_bytes(),'original_values':u,'abi_values':v}
 # Check row padding and marker adaptation from actual native tensors.
 old={x['name']:x for x in json.loads((O/'manifest.json').read_text())['tensors']}
 for bidx in range(2):
  u=(O/old['input_ids']['path']).read_bytes();v=data[0];assert u[bidx*94*4:(bidx+1)*94*4]==v[bidx*128*4:bidx*128*4+94*4]
  pad=struct.unpack('<34i',v[bidx*128*4+94*4:(bidx+1)*128*4]);assert all(x==50283 for x in pad)
 metadata={'profile':'reference-only; production-ineligible','numeric_layout_build_tags':'zero placeholders; no frozen hardware contracts or xclbin exist','model_tag':frame[40:56].hex(),'frame_bytes':len(frame),'sha256':hashlib.sha256(frame).hexdigest(),'payload_offsets':offsets,'roundtrip_five_inputs':'byte-exact PASS','mask_conversion':'only exact F32 0/1 converted to U8','input_adaptation':'S94 to S128 PAD50283/mask0; valid flattened markers rebased; invalid markers set to per-row CLS','comparisons':comparison}
 (A/'fixture_metadata.json').write_text(json.dumps(metadata,indent=2)+'\n')
 for folder in [O,A]:
  mf=folder/'manifest.json';z=json.loads(mf.read_text());z['semantic_aliases']={'candidate_raw_logits':{'tensor_id':'ir_1469','name':'add_119','path':'native/forward_0/ir_1469.bin','temperature_applied':False},'candidate_before_mask':{'tensor_id':'ir_1464','name':'squeeze','path':'native/forward_0/ir_1464.bin'},'act_raw_logits':{'tensor_id':'ir_1616','name':'linear_123','path':'native/forward_0/ir_1616.bin','temperature_applied':False}}
  z['request_profile']='abi_replay S128 per-row invalid CLS' if folder==A else 'original_native S94 upstream invalid flattened index 0';z['production_eligible']=False
  mf.write_text(json.dumps(z,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps(metadata))
if __name__=='__main__':main()
