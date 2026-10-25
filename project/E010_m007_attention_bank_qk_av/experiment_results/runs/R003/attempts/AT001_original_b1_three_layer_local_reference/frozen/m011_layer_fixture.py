#!/usr/bin/env python3
"""Original B1 local Encoder0/1 and Decision0 references, never a new whole graph."""
import argparse,hashlib,importlib.util,json,platform,struct,sys,time
from pathlib import Path
import numpy as np
REFSHA='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def ident(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--input',type=Path,required=True);ap.add_argument('--model',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();i=a.input;o=a.out;o.mkdir(parents=True,exist_ok=True)
 rp=i/'full_reference.py';assert sha(rp)==REFSHA;s=importlib.util.spec_from_file_location('original_local_reference',rp);ref=importlib.util.module_from_spec(s);sys.modules[s.name]=ref;s.loader.exec_module(ref)
 model=json.loads((i/'manifest.json').read_text());td={z['name']:z for z in model['tensors']};orig=json.loads((i/'full_forward_oracle_report.json').read_text());cp={z['name']:z for z in orig['runs']['B1_from_b0_S128']['checkpoints']}
 for name in('embedding_norm','encoder_00_out','type_add'):assert sha(i/(name+'.f32.bin'))==cp[name]['sha256']
 frame=(i/'B1_from_b0_S128.request.bin').read_bytes();assert frame[:4]==b'LYRQ'and struct.unpack_from('<HHQQ',frame,20)==(1,128,3,1)
 req=json.loads((i/'identity_manifest.json').read_text());rec=next(z for z in req['requests']if z['name']=='B1_from_b0_S128');assert hashlib.sha256(frame).hexdigest()==rec['target_sha256']
 for n,name in enumerate(('model','numeric','layout','build')):assert frame[40+n*16:56+n*16]==bytes.fromhex(req['tags'][name])
 off,n=struct.unpack_from('<II',frame,164);assert n==128;mask=np.frombuffer(frame[off:off+n],dtype=np.uint8).copy();assert np.isin(mask,[0,1]).all()and mask.any();(o/'mask.mem').write_text(''.join(f'{int(x):08x}\n'for x in mask))
 def save(name,x):
  arr=np.asarray(x,dtype='<f4');(o/(name+'.bin')).write_bytes(arr.tobytes());(o/(name+'.mem')).write_text(''.join(f'{int(z):08x}\n'for z in arr.reshape(-1).view('<u4')))
 used=[];wdir=o/'source_weights';wdir.mkdir(exist_ok=True)
 gf=a.model.open('rb')
 def weight(name):
  d=td[name];gf.seek(d['source_offset']);raw=gf.read(d['source_bytes']);assert hashlib.sha256(raw).hexdigest()==d['source_sha256'];p=wdir/(name.replace('.','_')+'.bin');p.write_bytes(raw);used.append({'tensor':name,'source_offset':d['source_offset'],'source_bytes':len(raw),'sha256':d['source_sha256'],'saved':str(p)});return raw
 tables={}
 for name in('cos_full','sin_full','cos_slide','sin_slide'):
  raw=weight(name);z=np.frombuffer(raw,dtype='<f4').reshape(1025,64)[:128].copy();assert np.isfinite(z).all();tables[name]=z;save(name,z)
 reused=json.loads((i/'fixture.json').read_text());assert reused['tensor']=='qkv.0.weight'and reused['activation_classification']=='ACTUAL_ENCODER0_QKV_128_ROWS'and len(reused['original_model_real_rows'])==128
 enc0desc=next(z for z in reused['files']if Path(z['path']).name=='expected_f32.bin');assert sha(i/'expected_f32.bin')==enc0desc['sha256'];assert reused['original_norm128']['sha256']==sha(i/'embedding_norm.f32.bin')
 cases=[]
 for case,name,source_name,sliding,isencoder in[(0,'encoder0','embedding_norm',False,True),(1,'encoder1','encoder_00_out',True,True),(2,'decision0','type_add',False,False)]:
  started=time.monotonic();source=np.fromfile(i/(source_name+'.f32.bin'),dtype='<f4').reshape(128,1024)
  source=source.copy()if case==0 else ref.layernorm_many(source)
  if case==0:
   pre=np.fromfile(i/'expected_f32.bin',dtype='<f4').reshape(128,3072).copy();wb=weight('qkv.0.weight');check=ref.q8_linear_many(source[:16],wb,3072);assert check.tobytes()==pre[:16].tobytes()
  else:
   wn='qkv.1.weight'if case==1 else'head_qkv.0.weight';bias=None if case==1 else np.frombuffer(weight('head_qkv.0.bias'),dtype='<f4').copy();pre=ref.q8_linear_many(source,weight(wn),3072,bias)
  pre=pre.reshape(1,128,3072);save(name+'_pre_qkv',pre)
  if isencoder:
   family='slide'if sliding else'full';co=tables['cos_'+family];si=tables['sin_'+family];post=ref.rope_qkv_many(pre,co,si);heads=pre.reshape(128,3,16,64)
   for plane in(0,1):
    h=heads[:,plane];x=h[...,:32];y=h[...,32:]
    for op,z in enumerate((ref.mul(x,co[:,None,:32]),ref.mul(y,si[:,None,:32]),ref.mul(y,co[:,None,32:]),ref.mul(x,si[:,None,32:]))):save(name+f'_rope_p{plane}_m{op}',z)
   assert post.reshape(128,3,16,64)[:,2].tobytes()==heads[:,2].tobytes()
  else:post=pre.copy()
  save(name+'_post_qkv',post);planes=post.reshape(128,3,16,64);scores=[];maxima=[];probs=[];contexts=[]
  for h in range(16):
   q=planes[:,0,h];k=planes[:,1,h];v=planes[:,2,h];score=np.stack([ref.qk_row(q[r],k,mask,128,r,sliding)for r in range(128)]);mx=score[:,0].copy()
   for key in range(1,128):mx=np.where(score[:,key]>mx,score[:,key],mx)
   shift=ref.sub(score,mx[:,None]);exp=ref.libm_array('expf',shift);tree=exp
   selected=h in(0,15)
   if selected:
    prefx=name+f'_h{h:02d}_';save(prefx+'shift',shift);save(prefx+'exp',exp);qtree=ref.mul(q[:,None,:],k[None,:,:]);save(prefx+'qk_l0',qtree)
    for lv in range(1,7):qtree=ref.add(qtree[...,::2],qtree[...,1::2]);save(prefx+'qk_l'+str(lv),qtree)
    save(prefx+'qk_scale',ref.mul(qtree[...,0],np.float32(.125)))
   for lv in range(1,8):
    tree=ref.add(tree[:,::2],tree[:,1::2])
    if selected:save(prefx+'sum_l'+str(lv),tree)
   total=tree[:,0];assert np.isfinite(total).all()and(total>0).all();prob=ref.div(exp,total[:,None]);acc=np.zeros((128,64),dtype='<f4');product=[];partial=[]
   for key in range(128):
    prod=ref.mul(prob[:,key,None],v[None,key,:]);acc=ref.add(acc,prod)
    if selected:product.append(prod);partial.append(acc.copy())
   if selected:save(prefx+'av_product',np.stack(product));save(prefx+'av_partial',np.stack(partial));save(prefx+'total',total)
   scores.append(score);maxima.append(mx);probs.append(prob);contexts.append(acc)
  score=np.stack(scores);maximum=np.stack(maxima);prob=np.stack(probs);context=np.stack(contexts);original=ref.attention_many(post,mask[None,:],sliding);expected=context.transpose(1,0,2).reshape(1,128,1024);assert expected.tobytes()==original.tobytes()
  for z,arr in [('score',score),('maximum',maximum),('prob',prob),('context',context)]:save(name+'_'+z,arr)
  cases.append({'name':name,'source_checkpoint':source_name,'source_sha256':cp[source_name]['sha256'],'encoder':isencoder,'sliding':sliding,'real_rows':128,'heads':16,'scope':'original local LN/QKV/RoPE/Attention only','reused_Encoder0_pre_QKV':enc0desc if case==0 else None,'full_context_equal_original_attention_many':True,'elapsed_seconds':time.monotonic()-started})
  print('M011_LAYER_REFERENCE_CASE_PASS '+name+' real_rows128 heads16 score262144 prob262144 context131072 original_attention_many_exact1',flush=True)
 gf.close();libm=Path('/lib/x86_64-linux-gnu/libm.so.6').resolve();outfiles=[ident(p)for p in sorted(o.rglob('*'))if p.is_file()];report={'scope':'original B1 local Encoder0/full Encoder1/sliding Decision0/no-RoPE; no whole-model gold; native/t5 capture not used','reference':ident(rp),'libm':ident(libm),'model_full_sha256_inherited':'6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18','full_model_sha_recomputed':False,'actual_tensor_payloads_hash_verified':used,'request_identity':{'request_id':3,'generation':1,'B':1,'S':128,'mask_valid':int(mask.sum()),'frame':ident(i/'B1_from_b0_S128.request.bin')},'cases':cases,'python':platform.python_version(),'numpy':np.__version__,'files':outfiles};(o/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print('M011_LAYER_REFERENCE_PASS cases3 each_full16head1 all_real_rows128 new_whole_model_gold0',flush=True)
if __name__=='__main__':main()
