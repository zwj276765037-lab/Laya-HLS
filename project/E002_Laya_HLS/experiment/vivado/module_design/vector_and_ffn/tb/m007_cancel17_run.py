#!/usr/bin/env python3
"""Bounded actual matching-FP-status fault, partial cancellation and newgen."""
import argparse,hashlib,json,re,shutil,subprocess,tarfile,time
from datetime import datetime,timezone
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5];LOCAL=MODULE.relative_to(ROOT)
SHARED=[MODULE.parent/'attention_and_fp_engine/rtl'/name for name in ('laya_return_vector_credit_v1.sv','laya_attention_storage_v1.sv')]
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def execute(cmd,cwd):print('COMMAND',*[str(x)for x in cmd],flush=True);subprocess.run([str(x)for x in cmd],cwd=cwd,check=True)
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);p.add_argument('--mode',type=int,choices=range(7),default=0);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 shared=[]
 for src in SHARED:
  dst=f/src.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst);shared.append(dst)
 names=['rtl/laya_m007_tanh_fast_leaves_v1.sv','rtl/laya_m007_tanh_add3_e_v1.sv','rtl/laya_m007_tanh_div12_r4_v1.sv','rtl/laya_m007_tanh_lane_v1.sv','rtl/laya_m007_tanh8_v1.sv','rtl/laya_m007_g_vector_pool_v1.sv','rtl/laya_m007_g_math_v1.sv','rtl/laya_m007_g_pairs_v1.sv','rtl/laya_m007_g_engine_v1.sv','tb/m007_cancel17_validation_shell.sv','tb/m007_cancel17_tb.sv'];sources=[*shared,*[f/LOCAL/name for name in names],f/(MODULE.parent/'attention_and_fp_engine/rtl/laya_m007_control_workspace_v1.sv').relative_to(ROOT)]
 if a.stage=='build':
  execute([VIV/'xvlog','--sv',*sources],o);execute([VIV/'xelab','work.m007_cancel17_tb','--relax','-mt','4','--O3','-s','cancel17_sim'],o)
  save(o/'report.json',{'status':'BUILD_COMPLETE','scope':'Unchanged production G/resources; separate test-only interposer changes one matching public FP status, preserving actual valid/tag/data; no force or fake debt','source_sha256':{str(x.relative_to(f)):sha(x)for x in sources},'driver_sha256':sha(Path(__file__)),'semantic_progress_schema':'m007-tanh-consumed-v1','snapshot':{str(x.relative_to(o)):sha(x)for x in(o/'xsim.dir').rglob('*')if x.is_file()}})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert sha(Path(__file__))==m['driver_sha256']
  for path,digest in m['source_sha256'].items():assert sha(f/path)==digest,'selected source/build mismatch'
  for path,digest in m['snapshot'].items():assert sha(b/path)==digest,'snapshot mismatch'
  fi=json.loads((a.fixture/'report.json').read_text());vectors=a.fixture/'geglu_vectors.hex';assert fi['schema']=='m007-g-original-fixture-v1'and sha(vectors)==fi['vectors_sha256']and fi['count']==335872
  save(o/'input_identity.json',{'fixture_report_sha256':sha(a.fixture/'report.json'),'vectors_sha256':sha(vectors),'mode':a.mode,'scope':'Actual cancellation/bank/FP/SFU/output debt and DONE/discard/no-reset recovery; mode6 injects one public NaN and checks policy zero/status6 with original unaffected lanes; mode5 changes one genuine matching FP status only'})
  cmd=[VIV/'xsim','cancel17_sim','-runall','-testplusarg','CANCEL_MODE='+str(a.mode),'-testplusarg','VECTORS='+str(vectors),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')]
  print('COMMAND',*[str(x)for x in cmd],flush=True);events=[];started=time.monotonic();child=subprocess.Popen([str(x)for x in cmd],cwd=b,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
  try:
   for line in child.stdout:
    print(line,end='',flush=True);kind='main_begin'if line.strip()=='run -all'else('main_end'if line.startswith('HARDWARE_AGENT_SIM_PASS G_CANCEL17')else None)
    if kind:events.append({'event':kind,'received_utc':datetime.now(timezone.utc).isoformat(),'seconds_since_xsim_launch':time.monotonic()-started,'actual_log_line':line.rstrip()})
   rc=child.wait()
  finally:save(o/'runtime_events.json',{'events':events,'host_elapsed_s':time.monotonic()-started,'basis':'actual stdout reception'})
  if rc:raise subprocess.CalledProcessError(rc,cmd)
  log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS G_CANCEL17'));metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',marker)}
  assert metrics['cancel_fires']==1 and metrics['done_cancelled']==1 and metrics['done_held17']==17 and metrics['explicit_discard']==1 and metrics['recovery_checked']==12288
  assert metrics['main_read_vectors']==metrics['main_accepted_vectors']
  assert metrics['total_checked']==metrics['main_accepted_vectors']*8+12288
  assert metrics['node_checks']==(metrics['main_accepted_vectors']+1536)*80-(10 if a.mode==6 else 0)
  assert metrics['output_held17']==(17 if a.mode in(2,6)else 0) and metrics['bank_held17']==(17 if a.mode in(3,4)else 0)
  assert metrics['peer_events']==int(a.mode==5)
  progress=[json.loads(line)for line in(o/'semantic_progress.jsonl').read_text().splitlines()];assert progress[-1]['checked']==metrics['total_checked']and progress[-1]['node_checks']==metrics['node_checks']
  save(o/'report.json',{'status':'PASS','mode':a.mode,'scope':'Real partial producer cancellation, exact output/accepted-read debt, committed bank valid stability, held done_cancelled17, actual discard, no-reset newgen3 blocks; no full-domain success claim','main_input_count':metrics['main_accepted_vectors']*8,'recovery_input_count':12288,'total_input_count':metrics['total_checked'],'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'fixture_report_sha256':sha(a.fixture/'report.json'),'metrics':metrics,'semantic_progress_sha256':sha(o/'semantic_progress.jsonl'),'semantic_progress_event_count':len(progress),'last_semantic_progress':progress[-1],'actual_runtime_events':events,'result_marker':marker,'xsim_log_sha256':sha(o/'xsim.log')})
if __name__=='__main__':main()
