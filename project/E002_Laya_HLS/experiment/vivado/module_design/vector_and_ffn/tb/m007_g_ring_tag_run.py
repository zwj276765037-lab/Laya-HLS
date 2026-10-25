#!/usr/bin/env python3
"""Pure G arithmetic with actual56M/16A vector pool and real frozen TANH8."""
import argparse,hashlib,json,re,shutil,subprocess,tarfile,time
from datetime import datetime,timezone
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5];LOCAL=MODULE.relative_to(ROOT)
SHARED=MODULE.parent/'attention_and_fp_engine/rtl/laya_return_vector_credit_v1.sv'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def execute(cmd,cwd):print('COMMAND',*[str(x)for x in cmd],flush=True);subprocess.run([str(x)for x in cmd],cwd=cwd,check=True)
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);p.add_argument('--groups',type=int,default=3);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 shared=f/SHARED.relative_to(ROOT);shared.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(SHARED,shared)
 names=['rtl/laya_m007_tanh_fast_leaves_v1.sv','rtl/laya_m007_tanh_add3_e_v1.sv','rtl/laya_m007_tanh_div12_r4_v1.sv','rtl/laya_m007_tanh_lane_v1.sv','rtl/laya_m007_tanh8_v1.sv','rtl/laya_m007_g_vector_pool_v1.sv','rtl/laya_m007_g_math_v1.sv','tb/m007_g_ring_tag_tb.sv'];sources=[shared,*[f/LOCAL/name for name in names]]
 if a.stage=='build':
  execute([VIV/'xvlog','--sv',*sources],o);execute([VIV/'xelab','work.m007_g_ring_tag_tb','--relax','-mt','4','--O3','-s','g_ring_tag_sim'],o)
  save(o/'report.json',{'status':'BUILD_COMPLETE','scope':'Ring-tag actual256-full math with56mul16add physical pool and actual TANH8; public handshakes only, no forced state','source_sha256':{str(x.relative_to(f)):sha(x)for x in sources},'driver_sha256':sha(Path(__file__)),'semantic_progress_schema':'m007-tanh-consumed-v1','snapshot':{str(x.relative_to(o)):sha(x)for x in(o/'xsim.dir').rglob('*')if x.is_file()}})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert sha(Path(__file__))==m['driver_sha256']
  for path,digest in m['source_sha256'].items():assert sha(f/path)==digest,'selected source/build mismatch'
  for path,digest in m['snapshot'].items():assert sha(b/path)==digest,'snapshot mismatch'
  fi=json.loads((a.fixture/'report.json').read_text());vectors=a.fixture/'geglu_vectors.hex';assert fi['schema']=='m007-g-original-fixture-v1'and sha(vectors)==fi['vectors_sha256']and fi['count']==335872
  save(o/'input_identity.json',{'fixture_report_sha256':sha(a.fixture/'report.json'),'vectors_sha256':sha(vectors),'groups':a.groups,'scalar_inputs':a.groups*4096,'scope':'Original real128-row columns s=0..groups-1; no substituted diagnostic rows'})
  cmd=[VIV/'xsim','g_ring_tag_sim','-runall','-testplusarg','GROUPS='+str(a.groups),'-testplusarg','VECTORS='+str(vectors),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')]
  print('COMMAND',*[str(x)for x in cmd],flush=True);events=[];started=time.monotonic();child=subprocess.Popen([str(x)for x in cmd],cwd=b,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
  try:
   for line in child.stdout:
    print(line,end='',flush=True);kind='main_begin'if line.strip()=='run -all'else('main_end'if line.startswith('HARDWARE_AGENT_SIM_PASS G_RING_TAG')else None)
    if kind:events.append({'event':kind,'received_utc':datetime.now(timezone.utc).isoformat(),'seconds_since_xsim_launch':time.monotonic()-started,'actual_log_line':line.rstrip()})
   rc=child.wait()
  finally:save(o/'runtime_events.json',{'events':events,'host_elapsed_s':time.monotonic()-started,'basis':'actual stdout reception; full guarded child wall used for any cost estimate'})
  if rc:raise subprocess.CalledProcessError(rc,cmd)
  log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS G_RING_TAG'));metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',marker)}
  assert metrics['checked']==a.groups*4096 and metrics['node_checks']==a.groups*4096*10 and metrics['pending_peak']==256 and metrics['full_same_address_swaps']==1280 and metrics['held_cycles']==51 and metrics['held_records']==3 and metrics['output_hold_gaps']==2 and metrics['boundary255']==metrics['boundary511']==1
  progress=[json.loads(line)for line in(o/'semantic_progress.jsonl').read_text().splitlines()];assert progress[-1]['checked']==a.groups*4096
  save(o/'report.json',{'status':'PASS','scope':'Actual256-full ring same-address consume+accept, three held17 records, original full FP9/H/output and fullseq across255/256/511/512; external holds separate, no bank/full-task performance claim','main_input_count':a.groups*4096,'all_real_rows':128,'groups':a.groups,'complete_S128':a.groups==82,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'fixture_report_sha256':sha(a.fixture/'report.json'),'metrics':metrics,'semantic_progress_sha256':sha(o/'semantic_progress.jsonl'),'semantic_progress_event_count':len(progress),'last_semantic_progress':progress[-1],'actual_runtime_events':events,'result_marker':marker,'xsim_log_sha256':sha(o/'xsim.log')})
if __name__=='__main__':main()
