#!/usr/bin/env python3
import argparse,hashlib,json,re,subprocess,tarfile,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MODULE=Path(__file__).resolve().parents[1];VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);p.add_argument('--mode',type=int,choices=range(5),default=0);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
names=['rtl/laya_fadd_rne_v1.sv','rtl/laya_fmul_rne_v1.sv','rtl/laya_fp_return_credit_v1.sv','rtl/laya_shared_fp256_v2.sv','rtl/laya_attention_qkv_bank_v2.sv','rtl/laya_m007_hidden32_v1.sv','rtl/laya_m007_qscratch32_v1.sv','rtl/laya_m007_resident_vector32_v1.sv','tb/m007_resident21_tb.sv'];sources=[f/(MODULE/n).relative_to(ROOT)for n in names]
if a.stage=='build':
 for cmd in [[str(VIV/'xvlog'),'--sv',*[str(s)for s in sources]],[str(VIV/'xelab'),'work.m007_resident21_tb','--relax','-mt','4','--O3','-s','resident21_sim']]:print('COMMAND',cmd,flush=True);subprocess.run(cmd,cwd=o,check=True)
 save(o/'report.json',{'status':'BUILD_COMPLETE','driver_sha256':sha(Path(__file__)),'source_sha256':{str(s.relative_to(f)):sha(s)for s in sources},'snapshot':{str(s.relative_to(o)):sha(s)for s in(o/'xsim.dir').rglob('*')if s.is_file()},'physical_resources':'One new hidden32, sole native3plane QKV, one real default256lane FP service; parent layer/matrix/quant qualifications not tested'})
else:
 b=a.build;m=json.loads((b/'report.json').read_text());assert sha(Path(__file__))==m['driver_sha256']
 for n,d in m['source_sha256'].items():assert sha(f/n)==d,'selected source/build differs '+n
 for n,d in m['snapshot'].items():assert sha(b/n)==d,'snapshot changed '+n
 fi=json.loads((a.fixture/'report.json').read_text());assert fi['status']=='PASS'
 cmd=[str(VIV/'xsim'),'resident21_sim','-runall','-testplusarg','MODE='+str(a.mode),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')]
 for n in ['H','Q','GOLD']:assert sha(a.fixture/(n+'.hex'))==fi['products'][n]['hex_sha256'];cmd+=['-testplusarg',n+'='+str(a.fixture/(n+'.hex'))]
 started=time.monotonic();print('COMMAND',cmd,flush=True);subprocess.run(cmd,cwd=b,check=True);log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
 marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS RESIDENT21_'));v={k:int(val)for k,val in re.findall(r'(\w+)=(\d+)',marker)}
 if a.mode==1:assert v['vectors']==512 and v['checked']==16384 and v['no_done']==1;scope='16row_prefix_not_DONE'
 elif a.mode==0:assert v['full_vectors']==4096 and v['held17']==17;scope='banks_full_address_public_protocol'
 else:
  assert v['lease_count']==v['release_count']==1 and v['done_held']==17
  if a.mode==4:assert v['status']==6;scope='nonfinite_first_error_actual_drain'
  else:assert v['commits']==4096 and v['checked']==131072 and v['scan_checked']==131104 and v['status']==0 and v['done_cycles']<=4160 and v['first_commit']<=32;scope='full_original_residual_component'
 save(o/'report.json',{'status':'PASS','scope':scope,'mode':a.mode,'metrics':v,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'fixture_report_sha256':sha(a.fixture/'report.json'),'semantic_progress_sha256':sha(o/'semantic_progress.jsonl'),'result_marker':marker,'xsim_log_sha256':sha(o/'xsim.log'),'child_body_wall_s':time.monotonic()-started,'parent_layer_matrix_quant_handoff':'NOT_RUN explicit parent qualification inputs only'})
