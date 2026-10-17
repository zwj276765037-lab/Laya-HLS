#!/usr/bin/env python3
import pathlib,json,os,subprocess,hashlib
ROOT=pathlib.Path(__file__).resolve().parent
def main():
 for profile in ['original_native','abi_replay']:
  d=ROOT/'runs/typed_q8_ref_20261005'/profile;m=json.loads((d/'manifest.json').read_text());env=os.environ.copy();env['LAYA_REFERENCE_DUMP']=str(d/'normal_final');env['LAYA_REFERENCE_OUTPUT_ONLY']='1';env.pop('LAYA_REFERENCE_AUDIT',None);env.pop('LAYA_REFERENCE_FORCE_PIN',None)
  if profile=='abi_replay':env['LAYA_REFERENCE_ABI128']='1'
  p=subprocess.run(m['command'],input=json.dumps(json.loads((d/'request.json').read_text()),ensure_ascii=False)+'\n',text=True,capture_output=True,env=env)
  (d/'normal_final_stdout.jsonl').write_text(p.stdout);(d/'normal_final_stderr.log').write_text(p.stderr)
  eq={n:(d/'native/forward_0'/f'{n}.bin').read_bytes()==(d/'normal_final/forward_0'/f'{n}.bin').read_bytes() for n in ['ir_1469','ir_1616']}
  result={'returncode':p.returncode,'binary_sha256':hashlib.sha256(pathlib.Path(m['command'][0]).read_bytes()).hexdigest(),'full_pin_vs_normal_allocation_raw_outputs':eq};assert p.returncode==0 and all(eq.values());assert result['binary_sha256']==m['runtime']['binary_sha256']
  (d/'capture_normal_comparison.json').write_text(json.dumps(result,indent=2)+'\n');m['capture_normal_output_comparison']=result
  for t in m['tensors']:
   if t.get('name') in ['add','add_1','sum_1','softmax']:t['capture_state']='end-of-graph storage overwritten by native in-place CLAMP; not original pre-op value'
  m['preclamp_checkpoints']=[{'index':i,'path':f'audited_outputs/preclamp_{i}.bin','sha256':hashlib.sha256((d/f'audited_outputs/preclamp_{i}.bin').read_bytes()).hexdigest(),'stage':'immediately before native CLAMP','threads':1} for i in range(32)]
  (d/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n');print(profile,result)
if __name__=='__main__':main()
