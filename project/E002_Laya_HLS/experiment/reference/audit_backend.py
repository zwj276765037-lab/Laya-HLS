#!/usr/bin/env python3
import subprocess,json,os,pathlib,hashlib,collections,csv,re
ROOT=pathlib.Path(__file__).resolve().parent
R=ROOT/'runs/typed_q8_ref_20261005'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 for profile in ['original_native','abi_replay']:
  d=R/profile;b=ROOT/'build/cpu/examples/laya/laya';model=ROOT.parents[2]/'model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf';env=os.environ.copy();env.update(LAYA_REFERENCE_AUDIT='1',LAYA_REFERENCE_DUMP=str(d/'audited_outputs'),LAYA_REFERENCE_OUTPUT_ONLY='1')
  if profile=='abi_replay':env['LAYA_REFERENCE_ABI128']='1'
  cmd=[str(b),'daemon',str(model),'--device','cpu','--threads','1'];p=subprocess.run(cmd,input=json.dumps(json.loads((d/'request.json').read_text()),ensure_ascii=False)+'\n',text=True,capture_output=True,env=env)
  (d/'backend_path_audit.log').write_text(p.stderr);(d/'audited_stdout.jsonl').write_text(p.stdout)
  lines=p.stderr.splitlines();ops=[l for l in lines if l.startswith('[REF_MUL_MAT]')];branches=[l for l in lines if l.startswith('[REF_BRANCH]')];eq={n:(d/'native/forward_0'/f'{n}.bin').read_bytes()==(d/'audited_outputs/forward_0'/f'{n}.bin').read_bytes() for n in ['ir_1469','ir_1616']}
  scratch=[]
  for l in lines:
   if not l.startswith('[REF_Q8_SCRATCH]'):continue
   v=dict(re.findall(r'(\w+)=([^ ]+)',l));f=pathlib.Path(v['file']);v.update(sha256=sha(f),path=str(f.relative_to(d)),endianness='little',block_format='IEEE FP16 scale d at bytes 0..1 followed by 32 signed int8 q at bytes 2..33; native block_q8_0 sizeof=34',storage_bytes=f.stat().st_size);scratch.append(v)
  topo=list(csv.DictReader((d/'audited_outputs/topology.tsv').open(),delimiter='\t'))
  audit={'binary_sha256':sha(b),'command':cmd,'environment':{k:v for k,v in env.items() if k.startswith('LAYA_REFERENCE')},'returncode':p.returncode,'raw_output_bitwise_equal_to_full_capture':eq,'mul_mat_count':len(ops),'operand_types':dict(collections.Counter(l.split('weight_type=')[1].split()[0]+'/'+l.split('activation_type=')[1].split()[0] for l in ops)),'branches':dict(collections.Counter(l.split('path=')[1] for l in branches)),'op_counts':dict(collections.Counter(x['op'] for x in topo)),'attention_f16_copies':[{k:x[k] for k in x} for x in topo if x['op']=='FLASH_ATTN_EXT'],'native_quantized_activation_scratch':scratch,'native_attention_unavailable':['attention scores','softmax probability matrix'],'numeric_profile':'GGML CPU Q8_0×Q8_0 (122 converted llamafile GEMMs), native fused FLASH_ATTN_EXT using F16 K/V/mask; not hardware Q8-F'}
  (d/'backend_path_audit.json').write_text(json.dumps(audit,indent=2)+'\n');print(profile,len(scratch),eq,audit['op_counts'].get('FLASH_ATTN_EXT'))
if __name__=='__main__':main()
