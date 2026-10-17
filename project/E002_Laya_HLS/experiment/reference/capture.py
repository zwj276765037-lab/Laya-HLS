#!/usr/bin/env python3
"""Capture fixed-commit native GGML Typed Q8 inference; no numerical reimplementation."""
import csv,hashlib,json,os,pathlib,platform,struct,subprocess,sys,time
ROOT=pathlib.Path(__file__).resolve().parent
LAYA=ROOT.parents[2]
MODEL=LAYA/'model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf'
RUN=ROOT/'runs/typed_q8_ref_20261005'/('abi_replay' if os.getenv('LAYA_REFERENCE_ABI128') else 'original_native')
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1<<20),b''):h.update(b)
 return h.hexdigest()
def main():
 RUN.mkdir(parents=True,exist_ok=True)
 request=json.loads((LAYA/'results/gpu_inference_20261005_run01/request.json').read_text());request['id']='typed_q8_ref_20261005'
 (RUN/'request.json').write_text(json.dumps(request,ensure_ascii=False,indent=2)+'\n')
 binary=ROOT/'build/cpu/examples/laya/laya'
 cmd=[str(binary),'daemon',str(MODEL),'--device','cpu','--threads','1']
 env=os.environ.copy();env['LAYA_REFERENCE_DUMP']=str(RUN/'native')
 t=time.time()
 with (RUN/'stderr.log').open('w') as err:
  p=subprocess.run(cmd,input=json.dumps(request,ensure_ascii=False)+'\n',text=True,stdout=subprocess.PIPE,stderr=err,env=env)
 (RUN/'stdout.jsonl').write_text(p.stdout)
 tensors=[]
 for tab in sorted((RUN/'native').glob('*/tensors.tsv')):
  for row in csv.DictReader(tab.open(),delimiter='\t'):
   file=tab.parent/row['file'];row['sha256']=sha(file);row['path']=str(file.relative_to(RUN));row['endianness']=sys.byteorder
   row['ggml_ne']=[int(row.pop('ne'+str(i))) for i in range(4)];row['ggml_nb_bytes']=[int(row.pop('nb'+str(i))) for i in range(4)]
   row['storage_span_bytes']=int(row.pop('bytes'));row['logical_elements']=__import__('math').prod(row['ggml_ne'])
   if row['dtype'] in ('f32','i32'):row['logical_bytes']=row['logical_elements']*4
   tensors.append(row)
   if row['name'] in ('attention_mask','marker_mask') and row['dtype']=='f32':
    vals=struct.unpack('<'+'f'*(file.stat().st_size//4),file.read_bytes());assert all(v in (0,1) for v in vals)
    dst=tab.parent/(row['name']+'_abi_u8.bin');dst.write_bytes(bytes(map(int,vals)))
    tensors.append({'name':row['name']+'_abi_u8','dtype':'u8','derived_from':row['path'],'derivation':'exact F32 binary mask to U8 conversion','path':str(dst.relative_to(RUN)),'sha256':sha(dst),'shape_BS_or_BK':list(reversed(row['ggml_ne'][:2])),'endianness':sys.byteorder})
 manifest={'status':'success' if p.returncode==0 else 'failed','returncode':p.returncode,'elapsed_s':time.time()-t,'command':cmd,'environment_capture':{'LAYA_REFERENCE_DUMP':env['LAYA_REFERENCE_DUMP']},'model':{'path':str(MODEL.resolve()),'bytes':MODEL.stat().st_size,'sha256':sha(MODEL)},'runtime':{'source_commit':'dcc300def5c5bc8fa778223589244abb0555a5de','instrumentation':'mark every graph node output before allocation; read native backend buffers after compute','binary_sha256':sha(binary),'backend':'GGML CPU','threads':1,'platform':platform.platform(),'build_flags':'Release GGML_NATIVE=ON GGMLC_ENABLE_CUDA=OFF'},'tokenizer':{'source':'GGUF embedded metadata through native BPETokenizer and native build_sequence/pad_encoded_batch','identity_bound_to_model_sha256':sha(MODEL)},'tensors':tensors,'limitations':['Runtime quantized MUL_MAT scratch activation is not a graph tensor; no scratch capture claimed.','Noncontiguous tensors are native storage spans described by GGML ne/nb; no implicit contiguous conversion.','Unused marker columns retain upstream zero flattened indices, including B>0 rows; differs from ABI per-row CLS fill.']}
 (RUN/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'returncode':p.returncode,'tensors':len(tensors),'run':str(RUN),'stdout':p.stdout},ensure_ascii=False))
if __name__=='__main__':main()
