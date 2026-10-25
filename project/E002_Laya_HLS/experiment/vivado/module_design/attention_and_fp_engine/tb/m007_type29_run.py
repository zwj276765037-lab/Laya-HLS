#!/usr/bin/env python3
import argparse,hashlib,json,re,subprocess,tarfile,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];A=Path(__file__).resolve().parents[1];EXP=A.parents[2];SRC=ROOT/'project/E019_m007_residual_ln_residency/experiment_source';RUN=SRC.parent/'experiment_results/runs/R004';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def selected_sources():
 from m007_joint27_run import selected_sources as accepted_sources
 out=[p for p in accepted_sources()if p.suffix in ['.sv','.v','.dat']and '/tb/'not in str(p)]
 for p in [A/'rtl/laya_m007_type32_v1.sv',A/'rtl/laya_m007_resident_vector32_v3.sv',A/'rtl/laya_m007_control_workspace_joint_v3.sv',A/'rtl/laya_m007_resident_joint_v3.sv',A/'rtl/laya_m007_resident_joint_v3_header.svh',A/'tb/m007_type29_unit_tb.sv',A/'tb/m007_type29_joint_tb.sv',A/'tb/m007_type29_run.py',A/'tb/m007_type29_guard.py',A/'tb/m007_joint23_run.py',A/'tb/m007_joint27_run.py',A.parent/'layernorm_engine/tb/m007_ln_process_guard.py',SRC/'protocol_r004.md',SRC/'generate_type29_unit_tb.py',SRC/'generate_vector29_v3.py',SRC/'generate_joint29_v3.py',SRC/'prepare_type29_fixture.py',RUN/'source_preparation_v1.json']:
  if p.exists():out.append(p)
 return sorted(set(out))
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('--kind',choices=['unit','joint'],default='unit');p.add_argument('--mode',type=int,default=2);p.add_argument('--op',type=int,choices=[0,1],default=1);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as tar:tar.extractall(f,filter='data')
 ids=json.loads((o.parent/'receipt.json').read_text())['source_sha256']
 if a.kind=='unit':
  names=['laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv','laya_fp_return_credit_v1.sv','laya_shared_fp256_v2.sv','laya_attention_qkv_bank_v2.sv','laya_m007_hidden32_v1.sv','laya_m007_qscratch32_v1.sv','laya_m007_resident_vector32_v2.sv','laya_m007_resident_vector32_v3.sv','laya_m007_type32_v1.sv','m007_type29_unit_tb.sv'];used={n:h for n,h in ids.items()if Path(n).name in names};assert len(used)==len(names);top='m007_type29_unit_tb'
 else:used={n:h for n,h in ids.items()if Path(n).suffix in ['.sv','.v','.dat']and not n.endswith('/m007_type29_unit_tb.sv')};top='m007_type29_joint_tb'
 sources=[f/n for n in used if Path(n).suffix in ['.sv','.v']]
 for n,h in used.items():assert sha(f/n)==h
 if a.stage=='build':
  subprocess.run(['python3',str(SRC/'prepare_type29_fixture.py')],check=True)
  for n in used:
   if n.endswith('.dat'):(o/Path(n).name).write_bytes((f/n).read_bytes())
  sources.sort(key=lambda q:(q.name!='laya_m007_tanh_fast_leaves_v1.sv',q.name))
  for cmd in [[str(VIV/'xvlog'),'--sv',*[str(q)for q in sources]],[str(VIV/'xelab'),'work.'+top,'--relax','-debug','typical','-mt','4','--O3','-s','type29_'+a.kind+'_sim']]:print('COMMAND',cmd,flush=True);subprocess.run(cmd,cwd=o,check=True)
  save(o/'report.json',{'status':'BUILD_COMPLETE','kind':a.kind,'driver_sha256':sha(Path(__file__)),'compiled_source_sha256':used,'snapshot':{str(q.relative_to(o)):sha(q)for q in(o/'xsim.dir').rglob('*')if q.is_file()},'fixture_manifest_sha256':sha(RUN/'data/fixture_manifest.json'),'top':top})
 else:
  b=a.build.resolve();m=json.loads((b/'report.json').read_text());assert m['status']=='BUILD_COMPLETE'and m['kind']==a.kind and m['driver_sha256']==sha(Path(__file__))
  for n,h in m['compiled_source_sha256'].items():assert ids.get(n)==h,'source differs from build '+n
  for n,h in m['snapshot'].items():assert sha(b/n)==h,'snapshot drift '+n
  fix=RUN/'data/fixture_manifest.json';fi=json.loads(fix.read_text());assert sha(fix)==m['fixture_manifest_sha256']
  for d in fi['products'].values():assert sha(ROOT/d['source'])==d['sha256']and sha(ROOT/d['words_hex'])==d['hex_sha256']
  rf=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R001/attempts/AT001_original_residual_fixture/work';ri=json.loads((rf/'report.json').read_text())
  for n in ['H','Q','GOLD']:assert sha(rf/(n+'.hex'))==ri['products'][n]['hex_sha256']
  files={'H':rf/'H.hex','Q':rf/'Q.hex'if a.op==0 else ROOT/fi['products']['final_norm']['words_hex'],'GOLD':rf/'GOLD.hex'if a.op==0 else ROOT/fi['products']['type_add']['words_hex'],'TYPE':ROOT/fi['products']['type']['words_hex']}
  cmd=[str(VIV/'xsim'),'type29_'+a.kind+'_sim','-runall','-testplusarg','MODE='+str(a.mode),'-testplusarg','OP='+str(a.op),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')]
  for n,q in files.items():cmd+=['-testplusarg',n+'='+str(q)]
  start=time.monotonic();print('COMMAND',cmd,flush=True);subprocess.run(cmd,cwd=b,check=True);log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(Fatal|ERROR):',log)
  mark=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS TYPE29_'));v={k:int(t)for k,t in re.findall(r'(\w+)=(\d+)',mark)}
  assert v['commits']==4096
  if a.kind=='unit':
   assert v['scan_checked']==131072 and v['type_checked']==3104 and v['external_bits']==48 and v['type_control_bits']==13
   assert v['first_status']==(8 if a.mode>=5 else 6 if a.mode==4 else 0)
   if a.mode>=4:assert v['recovered']==1 and v['lease_count']==v['release_count']==2
   else:assert v['lease_count']==v['release_count']==1
   if a.mode==3:assert v['q_held']==v['type_held']==v['finalH_held']==17
   if a.op==1:assert v['h_reads']==0 and v['q_reads']==v['type_reads']==4096
   else:assert v['op0_compared']>0 and v['h_reads']==v['q_reads']==4096 and v['type_reads']==0
  save(o/'report.json',{'status':'PASS','kind':a.kind,'mode':a.mode,'op':a.op,'scope':'TYPE29_EXTERNAL48_REAL_BANK_FP_UNIT'if a.kind=='unit'else'TYPE29_CURRENT_PRODUCTION_JOINT','metrics':v,'result_marker':mark,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'fixture_manifest_sha256':sha(fix),'original_residual_fixture_sha256':sha(rf/'report.json'),'xsim_log_sha256':sha(o/'xsim.log'),'runtime_body_wall_s':time.monotonic()-start,'NOT_RUN':['preceding28layer producer','real parent setup/H_LOAD source event','full model/physical fit']})
 return 0
if __name__=='__main__':raise SystemExit(main())
