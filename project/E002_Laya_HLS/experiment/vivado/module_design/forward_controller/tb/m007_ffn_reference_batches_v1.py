#!/usr/bin/env python3
"""R005 fixed disjoint16-row original-reference batches; no model/RTL execution."""
import argparse,hashlib,importlib.util,json,sys,time
from pathlib import Path
import numpy as np
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[7];RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005'
OLD=Path(__file__).with_name('m007_ffn_reference_v1.py')
spec=importlib.util.spec_from_file_location('frozen_r004_adapter_functions',OLD);old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('--mode',choices=['batch','merge'],required=True);p.add_argument('--row0',type=int,default=0);p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);start=time.monotonic();ids,data=old.inputs();ref=old.load_reference();runtime=old.runtime(o)
 if a.mode=='batch':
  assert a.row0 in range(0,128,16);row1=a.row0+16
  if a.row0==0:old.console(o,'running','R005 fixed16-row original-reference batches, rows0..127 exactly once','Complete128-row fixture, then production FFN kind3 implementation')
  g=np.frombuffer(data['geglu'],dtype='<f4').reshape(128,2624)[a.row0:row1];norm=np.frombuffer(data['norm_ff'],dtype='<f4').reshape(128,1024)[a.row0:row1]
  qg=ref.quantize_many(g);qn=ref.quantize_many(norm);assert qg==ref.quantize_rows(g)and qn==ref.quantize_rows(norm)
  down=ref.q8_linear_full(qg,data['down_weight'],16,2624,1024)[0];assert down.shape==(16,1024)and np.isfinite(down).all()
  old.write_quant(o,'g_quant',g,qg,16,82);old.write_quant(o,'norm_ff_quant',norm,qn,16,32);(o/'down_expected_f32.bin').write_bytes(down.tobytes())
  if a.row0==0:
   previous=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R004/attempts/AT002_one_row_reference_pilot/work'
   assert qg[:2788]==(previous/'g_quant/activation_q8.bin').read_bytes();assert qn[:1088]==(previous/'norm_ff_quant/activation_q8.bin').read_bytes();assert down[:1].tobytes()==(previous/'down/expected_f32.bin').read_bytes()
  details={'row0':a.row0,'row1':row1,'rows':16,'g_groups':16*82,'g_codes':16*2624,'down_f32':16*1024,'scalar_vs_batched_quant':'BITWISE_PASS','row0_R004_overlap':'BITWISE_PASS'if a.row0==0 else'NOT_THIS_BATCH'}
 else:
  batches=[]
  for row0 in range(0,128,16):
   work=RUN/'attempts'/f'AT{row0//16+1:03d}_reference_rows_{row0:03d}_{row0+16:03d}'/'work';r=json.loads((work/'report.json').read_text());assert r['status']=='PASS'and r['row0']==row0 and r['row1']==row0+16
   for d in r['outputs'].values():assert old.sha(ROOT/d['path'])==d['sha256']
   batches.append((work,r))
  qg=b''.join((w/'g_quant/activation_q8.bin').read_bytes()for w,r in batches);qn=b''.join((w/'norm_ff_quant/activation_q8.bin').read_bytes()for w,r in batches);down=b''.join((w/'down_expected_f32.bin').read_bytes()for w,r in batches)
  assert len(qg)==128*82*34 and len(qn)==128*32*34 and len(down)==128*1024*4
  g=np.frombuffer(data['geglu'],dtype='<f4').reshape(128,2624);norm=np.frombuffer(data['norm_ff'],dtype='<f4').reshape(128,1024)
  old.write_quant(o,'g_quant',g,qg,128,82);old.write_quant(o,'norm_ff_quant',norm,qn,128,32)
  d=o/'down';d.mkdir();(d/'expected_f32.bin').write_bytes(down);x=np.frombuffer(down,dtype='<f4').reshape(128,1024)
  with(d/'output.hex').open('w')as f:
   for s in range(16):
    for row in range(128):
     for half in range(2):f.write(x[row,64*s+32*half:64*s+32*half+32].tobytes()[::-1].hex()+'\n')
  wi=np.frombuffer(data['wi'],dtype='<f4').reshape(128,5248)
  with(o/'wi_native_output.hex').open('w')as f:
   for s in range(82):
    for row in range(128):
     for half in range(2):f.write(wi[row,32*s+2624*half:32*s+2624*half+32].tobytes()[::-1].hex()+'\n')
  save(o/'batches.json',[{'work':str(w.relative_to(ROOT)),'report_sha256':sha(w/'report.json'),'row0':r['row0'],'row1':r['row1']}for w,r in batches]);details={'rows':128,'coverage':list(range(128)),'g_groups':10496,'g_codes':335872,'down_f32':131072,'independent_rows_merged':True,'arithmetic_recomputed_at_merge':False}
 outputs={str(q.relative_to(o)):old.identity(q)for q in sorted(o.rglob('*'))if q.is_file()and q.name!='report.json'}
 save(o/'report.json',{'schema':'m007-ffn-fixed16-original-reference-v1','status':'PASS','mode':a.mode,'driver':old.identity(Path(__file__).resolve()),'R004_adapter':old.identity(OLD),'original_reference':old.identity(old.REF),'inputs':ids,'runtime':runtime,**details,'outputs':outputs,'elapsed_s':time.monotonic()-start,'verdict':'LOCAL_CPU_REFERENCE_ONLY_NOT_RTL'})
 print('M007_FFN_BATCH_REFERENCE_PASS '+json.dumps(details),flush=True)
if __name__=='__main__':main()
