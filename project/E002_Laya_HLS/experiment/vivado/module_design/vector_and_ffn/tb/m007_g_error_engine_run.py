#!/usr/bin/env python3
"""Original G numerical-rank and public error/discard/new-generation lifecycle."""
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
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);p.add_argument('--errors',type=Path);p.add_argument('--case',choices=('gate_then_late_input','gate_then_late_v','gate_then_late_z','gate_inverse_row'),default='gate_then_late_input');p.add_argument('--groups',type=int,default=8);p.add_argument('--count',type=int);a=p.parse_args()
 assert 8<=a.groups<=82 and (a.count is None or a.count==a.groups*4096)
 o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 shared=[]
 for src in SHARED:
  dst=f/src.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst);shared.append(dst)
 names=['rtl/laya_m007_tanh_fast_leaves_v1.sv','rtl/laya_m007_tanh_add3_e_v1.sv','rtl/laya_m007_tanh_div12_r4_v1.sv','rtl/laya_m007_tanh_lane_v1.sv','rtl/laya_m007_tanh8_v1.sv','rtl/laya_m007_g_vector_pool_v1.sv','rtl/laya_m007_g_math_v1.sv','rtl/laya_m007_g_pairs_v1.sv','rtl/laya_m007_g_engine_v1.sv','tb/m007_g_engine_validation_shell.sv','tb/m007_g_error_engine_tb.sv'];sources=[*shared,*[f/LOCAL/name for name in names]]
 if a.stage=='build':
  execute([VIV/'xvlog','--sv',*sources],o);execute([VIV/'xelab','work.m007_g_error_engine_tb','--relax','-mt','4','--O3','-s','g_error_sim'],o)
  save(o/'report.json',{'status':'BUILD_COMPLETE','scope':'Same production G/native storage/56mul16add/TANH8; independent sparse original-error observer and public lifecycle TB','source_sha256':{str(x.relative_to(f)):sha(x)for x in sources},'driver_sha256':sha(Path(__file__)),'semantic_progress_schema':'m007-tanh-consumed-v1','snapshot':{str(x.relative_to(o)):sha(x)for x in(o/'xsim.dir').rglob('*')if x.is_file()}})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert sha(Path(__file__))==m['driver_sha256']
  for path,digest in m['source_sha256'].items():assert sha(f/path)==digest,'selected source/build mismatch'
  for path,digest in m['snapshot'].items():assert sha(b/path)==digest,'snapshot mismatch'
  fi=json.loads((a.fixture/'report.json').read_text());vectors=a.fixture/'geglu_vectors.hex';assert fi['schema']=='m007-g-original-fixture-v1'and sha(vectors)==fi['vectors_sha256']and fi['count']==335872
  er=json.loads((a.errors/'report.json').read_text());assert er['schema']=='m007-g-sparse-error-fixture-v1';case=er['cases'][a.case];patches=a.errors/case['patch_file'];assert sha(patches)==case['patch_sha256'];first=case['first_error'];recovery=12288 if a.groups==82 else 0
  save(o/'input_identity.json',{'fixture_report_sha256':sha(a.fixture/'report.json'),'vectors_sha256':sha(vectors),'error_report_sha256':sha(a.errors/'report.json'),'patch_sha256':sha(patches),'case':a.case,'groups':a.groups,'scalar_inputs':a.groups*4096,'recovery_scalar_inputs':recovery,'expected_full_first_error':first,'scope':'Unchanged original128-row products with two independently recomputed original-primitive scalar changes; single full-task production command, then held done, matching discard and no-reset newgen prefix'})
  cmd=[VIV/'xsim','g_error_sim','-runall','-testplusarg','GROUPS='+str(a.groups),'-testplusarg','VECTORS='+str(vectors),'-testplusarg','PATCH_FILE='+str(patches),'-testplusarg','PATCH_COUNT='+str(case['patch_count']),'-testplusarg','ERROR_RANK='+str(first['rank']),'-testplusarg','ERROR_ROW='+str(first['row']),'-testplusarg','ERROR_COLUMN='+str(first['column']),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')]
  print('COMMAND',*[str(x)for x in cmd],flush=True);events=[];started=time.monotonic();child=subprocess.Popen([str(x)for x in cmd],cwd=b,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
  try:
   for line in child.stdout:
    print(line,end='',flush=True);kind='main_begin'if line.strip()=='run -all'else('main_end'if line.startswith('HARDWARE_AGENT_SIM_PASS G_ERROR')else None)
    if kind:events.append({'event':kind,'received_utc':datetime.now(timezone.utc).isoformat(),'seconds_since_xsim_launch':time.monotonic()-started,'actual_log_line':line.rstrip()})
   rc=child.wait()
  finally:save(o/'runtime_events.json',{'events':events,'host_elapsed_s':time.monotonic()-started,'basis':'actual stdout reception; full guarded child wall used for cost estimate'})
  if rc:raise subprocess.CalledProcessError(rc,cmd)
  log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS G_ERROR'));metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',marker)}
  included=[q for q in case['patches']if q['column']<a.groups*32];expected_nodes=a.groups*4096*10-sum(10-q['node_check_mask'].bit_count()for q in included)
  assert metrics['main_checked']==a.groups*4096 and metrics['main_node_checks']==expected_nodes
  assert metrics['total_checked']==a.groups*4096+recovery and metrics['node_checks']==expected_nodes+recovery*10
  assert metrics['error_outputs']==len(included)and metrics['recovery_checked']==recovery
  assert metrics['full_error_done']==metrics['no_reset_newgen']==int(a.groups==82)
  assert metrics['held_done17']==metrics['wrong_discard17']==(17 if a.groups==82 else 0)
  if a.groups==82:assert (metrics['expected_rank'],metrics['expected_row'],metrics['expected_column'])==(first['rank'],first['row'],first['column'])
  progress=[json.loads(line)for line in(o/'semantic_progress.jsonl').read_text().splitlines()];assert progress[-1]['checked']==metrics['total_checked']and progress[-1]['node_checks']==metrics['node_checks']
  save(o/'report.json',{'status':'PASS','scope':'Original G numerical-domain/rank, real output/error drain; full case also held done, wrong/matching public discard and no-reset new generation3-block prefix; prefix alone is not full command completion; peer-return fault injection not covered','case':a.case,'main_input_count':a.groups*4096,'total_input_count':a.groups*4096+recovery,'recovery_input_count':recovery,'all_real_rows':128,'groups':a.groups,'full_error_complete':a.groups==82,'expected_full_first_error':first,'expected_evaluated_full':case['expected_evaluated'],'expected_nodes_main':expected_nodes,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'fixture_report_sha256':sha(a.fixture/'report.json'),'error_report_sha256':sha(a.errors/'report.json'),'patch_sha256':sha(patches),'metrics':metrics,'semantic_progress_sha256':sha(o/'semantic_progress.jsonl'),'semantic_progress_event_count':len(progress),'last_semantic_progress':progress[-1],'actual_runtime_events':events,'result_marker':marker,'xsim_log_sha256':sha(o/'xsim.log')})
if __name__=='__main__':main()
