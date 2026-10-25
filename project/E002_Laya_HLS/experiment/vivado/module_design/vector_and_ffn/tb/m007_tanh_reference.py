#!/usr/bin/env python3
"""Original local Encoder0 WO->residual->LN->Wi->G, all 128 real rows."""
import argparse,ctypes,hashlib,importlib.util,json,struct,sys,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[7]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def ident(p):return {'path':str(p.relative_to(ROOT)),'bytes':p.stat().st_size,'sha256':sha(p)}
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);started=time.monotonic()
 rp=ROOT/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py';assert sha(rp)=='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
 s=importlib.util.spec_from_file_location('original_reference',rp);ref=importlib.util.module_from_spec(s);sys.modules[s.name]=ref;s.loader.exec_module(ref)
 context=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle/encoder0_context.bin'
 hidden=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/embedding_norm.f32.bin'
 assert sha(context)=='a6a215cc003c60f2170f7c8844d66b1485113f490dcc2d81b2cd06164f69c6d3'
 assert sha(hidden)=='5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056'
 f=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
 inputs=[rp,context,hidden]
 def weight(name):
  folder=f/name;manifest=folder/'fixture.json';d=json.loads(manifest.read_text());p=folder/'original_weight_q8.bin';assert sha(p)==d['tensor_source']['source_sha256'];inputs.extend((manifest,p));return p.read_bytes()
 products={}
 def save(name,z):
  x=np.asarray(z,dtype='<f4');p=o/(name+'.bin');p.write_bytes(x.tobytes());products[name]={'shape':list(x.shape),**ident(p)};return x
 ctx=save('wo_input_context',np.fromfile(context,dtype='<f4').reshape(16,128,64).transpose(1,0,2).reshape(128,1024))
 wo=save('wo',ref.q8_linear_many(ctx,weight('wo_0_weight'),1024));print('LOCAL_WO_COMPLETE rows128',flush=True)
 residual=save('attention_residual',ref.add(np.fromfile(hidden,dtype='<f4').reshape(128,1024),wo));ref._finite(residual,'Encoder attention residual')
 norm=save('norm_ff',ref.layernorm_many(residual));wi=save('wi',ref.q8_linear_many(norm,weight('mlp_wi_0_weight'),5248));print('LOCAL_WI_COMPLETE rows128 columns5248',flush=True)
 x=save('x',wi[:,:2624]);gate=save('gate',wi[:,2624:]);ref._finite(x,'GELU array input')
 u=save('u',ref.mul(np.float32(.044715),x));v=save('v',ref.mul(u,x));w=save('w',ref.add(np.float32(1),v));t=save('t',ref.mul(np.float32(.7978845608028654),x));z=save('z',ref.mul(t,w))
 for name,value in(('u',u),('v',v),('w',w),('t',t),('z',z)):ref._finite(value,'GELU '+name)
 h=save('h',ref.libm_array('tanhf',z));r=save('r',ref.add(np.float32(1),h));half=save('s',ref.mul(np.float32(.5),x));y=save('y',ref.mul(half,r));ref._finite(y,'GELU array output')
 assert y.tobytes()==ref.gelu_array(x).tobytes();g=save('geglu',ref.mul(y,gate));ref._finite(g,'Encoder GEGLU')
 # Preserve all real z first, then exact neighboring bit patterns and invalid records.
 centers=[0,1,0x007fffff,0x00800000,0x24000000,0x32800000,0x3e317218,0x3f051592,0x3f800000,0x4115b844,0x41b00000,0x7f7fffff]
 for k in list(range(-3,5))+[21,22,23,24,55,56,57,63]:centers.append(struct.unpack('<I',struct.pack('<f',abs(k*.6931471805599453/2)))[0])
 extra=[]
 for c in centers:
  for d in range(-4,5):
   if 0<=c+d<0x7f800000:extra.extend((c+d,(c+d)|0x80000000))
 extra=list(dict.fromkeys(extra));ev=np.array(extra,dtype='<u4').view('<f4');eh=ref.libm_array('tanhf',ev)
 invalid=np.array([0x7f800000,0xff800000,0x7fc00000,0xffc01234,0x7f800001,0xff800001],dtype='<u4')
 inbits=np.concatenate((z.reshape(-1).view('<u4'),ev.view('<u4'),invalid));outbits=np.concatenate((h.reshape(-1).view('<u4'),eh.view('<u4'),np.zeros(len(invalid),dtype='<u4')))
 (o/'tanh_vectors.hex').write_text(''.join(f'{int(a):08x}{int(b):08x}{int(i>=len(inbits)-len(invalid)):08x}\n'for i,(a,b)in enumerate(zip(inbits,outbits))))
 lib=Path('/lib/x86_64-linux-gnu/libm.so.6').resolve()
 report={'status':'ORIGINAL_LOCAL_REFERENCE_COMPLETE','scope':'original B1 Encoder0 all128 rows; no new full-model gold','real_rows':128,'real_tanh_values':int(z.size),'boundary_values':len(extra),'nonfinite_records':len(invalid),'count':len(inbits),'reference':ident(rp),'inputs':[ident(p)for p in inputs],'libm':{'path':str(lib),'sha256':sha(lib),'bytes':lib.stat().st_size},'products':products,'tanh_vectors':ident(o/'tanh_vectors.hex'),'gelu_array_exact':True,'elapsed_s':time.monotonic()-started}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_TANH_LOCAL_REFERENCE_PASS real_rows128 values335872',flush=True)
if __name__=='__main__':main()
