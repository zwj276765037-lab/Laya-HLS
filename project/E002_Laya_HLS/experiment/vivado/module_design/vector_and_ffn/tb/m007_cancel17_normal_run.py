#!/usr/bin/env python3
"""One-command production G, sole native banks and real frozen arithmetic."""
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
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);p.add_argument('--groups',type=int,default=3);p.add_argument('--mode',type=int,choices=(0,1,2),default=0);p.add_argument('--count',type=int);a=p.parse_args()
 assert 3<=a.groups<=82 and (a.count is None or a.count==a.groups*4096)
 o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 shared=[]
 for src in SHARED:
  dst=f/src.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst);shared.append(dst)
 names=['rtl/laya_m007_tanh_fast_leaves_v1.sv','rtl/laya_m007_tanh_add3_e_v1.sv','rtl/laya_m007_tanh_div12_r4_v1.sv','rtl/laya_m007_tanh_lane_v1.sv','rtl/laya_m007_tanh8_v1.sv','rtl/laya_m007_g_vector_pool_v1.sv','rtl/laya_m007_g_math_v1.sv','rtl/laya_m007_g_pairs_v1.sv','rtl/laya_m007_g_engine_v1.sv','tb/m007_cancel17_normal_shell.sv','tb/m007_cancel17_normal_tb.sv'];sources=[*shared,*[f/LOCAL/name for name in names]]
 sources += [f/(MODULE.parent/'attention_and_fp_engine/rtl'/n).relative_to(ROOT) for n in ['laya_m007_control_workspace_v1.sv','laya_m007_control_workspace_joint_v1.sv','laya_attention_layer_engine_v1.sv','laya_attention_head_engine_v1.sv','laya_attention_qk_av_engine_v1.sv','laya_attention_softmax_engine_v1.sv','laya_attention_rope_engine_v1.sv','laya_attention_check_order_v1.sv','laya_attention_qkv_bank_v2.sv']]
 if a.stage=='build':
  execute([VIV/'xvlog','--sv',*sources],o);execute([VIV/'xelab','work.m007_cancel17_normal_tb','--relax','-mt','4','--O3','-s','cancel17_normal_sim'],o)
  save(o/'report.json',{'status':'BUILD_COMPLETE','scope':'Pure production G engine plus exactly one native full storage,56mul16add pool and frozen TANH8; PS/context disabled','source_sha256':{str(x.relative_to(f)):sha(x)for x in sources},'driver_sha256':sha(Path(__file__)),'semantic_progress_schema':'m007-tanh-consumed-v1','snapshot':{str(x.relative_to(o)):sha(x)for x in(o/'xsim.dir').rglob('*')if x.is_file()}})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert sha(Path(__file__))==m['driver_sha256']
  for path,digest in m['source_sha256'].items():assert sha(f/path)==digest,'selected source/build mismatch'
  for path,digest in m['snapshot'].items():assert sha(b/path)==digest,'snapshot mismatch'
  fi=json.loads((a.fixture/'report.json').read_text());vectors=a.fixture/'geglu_vectors.hex';assert fi['schema']=='m007-g-original-fixture-v1'and sha(vectors)==fi['vectors_sha256']and fi['count']==335872
  save(o/'input_identity.json',{'fixture_report_sha256':sha(a.fixture/'report.json'),'vectors_sha256':sha(vectors),'groups':a.groups,'mode':a.mode,'scalar_inputs':a.groups*4096,'scope':'Original real128-row columns s=0..groups-1, single full-task command, real native32F32 fills; no DUT-derived gold'})
  cmd=[VIV/'xsim','cancel17_normal_sim','-runall','-testplusarg','GROUPS='+str(a.groups),'-testplusarg','MODE='+str(a.mode),'-testplusarg','VECTORS='+str(vectors),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')]
  print('COMMAND',*[str(x)for x in cmd],flush=True);events=[];started=time.monotonic();child=subprocess.Popen([str(x)for x in cmd],cwd=b,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
  try:
   for line in child.stdout:
    print(line,end='',flush=True);kind='main_begin'if line.strip()=='run -all'else('main_end'if line.startswith('HARDWARE_AGENT_SIM_PASS G_ENGINE')else None)
    if kind:events.append({'event':kind,'received_utc':datetime.now(timezone.utc).isoformat(),'seconds_since_xsim_launch':time.monotonic()-started,'actual_log_line':line.rstrip()})
   rc=child.wait()
  finally:save(o/'runtime_events.json',{'events':events,'host_elapsed_s':time.monotonic()-started,'basis':'actual stdout reception; full guarded child wall used for cost estimate'})
  if rc:raise subprocess.CalledProcessError(rc,cmd)
  log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS G_ENGINE'));metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',marker)}
  assert metrics['checked']==a.groups*4096 and metrics['node_checks']==a.groups*4096*10 and metrics['first_actual_consume']<=256
  assert metrics['read_vectors']==a.groups*512 and metrics['writes']==a.groups*256 and metrics['write_acks']==metrics['writes']and metrics['releases']==a.groups
  assert metrics['prefix']==int(a.groups!=82) and metrics['independent_slot_release']>0 and metrics['actual_overlap']>0
  assert metrics['held_final17']==(17 if a.mode==1 else 0)
  blocks=[{k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',line)}for line in log.splitlines()if line.startswith('G_BLOCK ')];assert len(blocks)==a.groups
  if not a.mode:
   assert metrics['max_read_gap']==metrics['max_output_gap']==1
   assert all(x['service_cycles']<=768 and x['first_read']<=x['eligible']+1 for x in blocks)
   if a.groups==82:assert metrics['full_done_cycles']<=42240
  progress=[json.loads(line)for line in(o/'semantic_progress.jsonl').read_text().splitlines()];assert progress[-1]['checked']==a.groups*4096
  save(o/'report.json',{'status':'PASS','scope':'Normal original GEGLU with actual native fills/reads, production autonomous cross-s FSM and real slot debt release; prefix is not command completion; error/global-rank recovery not yet covered','main_input_count':a.groups*4096,'all_real_rows':128,'groups':a.groups,'mode':a.mode,'complete_S128':a.groups==82,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'fixture_report_sha256':sha(a.fixture/'report.json'),'metrics':metrics,'block_timings':blocks,'semantic_progress_sha256':sha(o/'semantic_progress.jsonl'),'semantic_progress_event_count':len(progress),'last_semantic_progress':progress[-1],'actual_runtime_events':events,'result_marker':marker,'xsim_log_sha256':sha(o/'xsim.log')})
if __name__=='__main__':main()
