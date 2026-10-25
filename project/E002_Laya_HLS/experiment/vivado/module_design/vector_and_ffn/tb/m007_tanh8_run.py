#!/usr/bin/env python3
"""Eight original TANH cores, one vector credit, independent per-node oracle."""
import argparse,hashlib,json,re,shutil,subprocess,tarfile,time
from datetime import datetime,timezone
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5];LOCAL=MODULE.relative_to(ROOT)
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
SHARED=MODULE.parent/'attention_and_fp_engine/rtl/laya_return_vector_credit_v1.sv'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def execute(cmd,cwd):print('COMMAND',*[str(x)for x in cmd],flush=True);subprocess.run([str(x)for x in cmd],cwd=cwd,check=True)
def execute_rtl(cmd,cwd,output):
 print('COMMAND',*[str(x)for x in cmd],flush=True);events=[];started=time.monotonic()
 child=subprocess.Popen([str(x)for x in cmd],cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
 try:
  for line in child.stdout:
   print(line,end='',flush=True);kind='main_begin'if line.strip()=='run -all'else('main_end'if line.startswith('TANH8_MAIN_PASS ')else None)
   if kind:events.append({'event':kind,'received_utc':datetime.now(timezone.utc).isoformat(),'seconds_since_xsim_launch':time.monotonic()-started,'actual_log_line':line.rstrip()})
  rc=child.wait()
 finally:save(output/'runtime_events.json',{'xsim_launch_utc_basis':'host receipt start; events are actual stdout reception times','events':events,'host_elapsed_s':time.monotonic()-started,'caution':'stdout latency may be included; cost gate uses whole guarded child wall'})
 if rc:raise subprocess.CalledProcessError(rc,cmd)
 return events
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--output',type=Path,required=True);p.add_argument('--schedule',type=Path);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);p.add_argument('--nodes',type=Path);p.add_argument('--count',type=int);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 shared=f/SHARED.relative_to(ROOT);shared.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(SHARED,shared)
 if a.stage=='build':
  schedule=json.loads(a.schedule.read_text());assert schedule['selected_result_edge']==152
  add_file=next(n for n in schedule['leaf_sources_sha256']if n.startswith('laya_m007_tanh_add3_'))
  sources=[f/LOCAL/'rtl/laya_m007_tanh_fast_leaves_v1.sv',f/LOCAL/'rtl'/add_file,f/LOCAL/'rtl/laya_m007_tanh_div12_r4_v1.sv',f/LOCAL/'rtl/laya_m007_tanh_lane_v1.sv',shared,f/LOCAL/'rtl/laya_m007_tanh8_v1.sv',f/LOCAL/'tb/m007_tanh8_tb.sv']
  assert sha(sources[3])==schedule['generated_rtl_sha256']
  for name,digest in schedule['leaf_sources_sha256'].items():assert sha(f/LOCAL/'rtl'/name)==digest
  (o/'schedule.json').write_text(a.schedule.read_text());checks=[]
  nodes=sorted(schedule['nodes'],key=lambda n:({'add':0,'mul':1,'div':2}[n['op']],int(re.search(r'\d+',n['name'])[0])))
  for lane in range(8):
   for index,node in enumerate(nodes):
    edge=node['consumer_edge'];name=node['name'];checks.append(f'''always @(posedge clk)if(rst_n&&dut.tanh_lane[{lane}].core.valid_pipe[{edge-1}]&&mask_pipe[{edge-1}][{lane}])begin
 if(dut.tanh_lane[{lane}].core.{name}!==nodes[id_pipe[{edge-1}][{lane}]][{1343-32*index}-:32])$fatal(1,"NODE_{name} lane={lane} index=%0d",id_pipe[{edge-1}][{lane}]);
 node_checks=node_checks+1;end''')
  (o/'m007_tanh8_node_checks.svh').write_text('\n'.join(checks)+'\n')
  execute([VIV/'xvlog','--sv','-i',o,*sources],o);execute([VIV/'xelab','work.m007_tanh8_tb','--relax','-mt','4','--O3','-s','tanh8_sim'],o)
  save(o/'report.json',{'status':'BUILD_COMPLETE','scope':'eight original-DAG cores and one shared vector credit; no EXP/storage copy','source_sha256':{str(x.relative_to(f)):sha(x)for x in sources},'driver_sha256':sha(Path(__file__)),'semantic_progress_schema':'m007-tanh-consumed-v1','node_checks_sha256':sha(o/'m007_tanh8_node_checks.svh'),'original_schedule_sha256':sha(a.schedule),'snapshot':{str(x.relative_to(o)):sha(x)for x in(o/'xsim.dir').rglob('*')if x.is_file()}})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert sha(Path(__file__))==m['driver_sha256']
  for path,digest in m['source_sha256'].items():assert sha(f/path)==digest,'current selected source/build mismatch'
  for path,digest in m['snapshot'].items():assert sha(b/path)==digest,'snapshot mismatch'
  fi=json.loads((a.fixture/'report.json').read_text());ni=json.loads((a.nodes/'report.json').read_text());vectors=a.fixture/'tanh_vectors.hex';nodes=a.nodes/'nodes.hex'
  assert sha(vectors)==fi['tanh_vectors']['sha256']==ni['input_sha256']and sha(nodes)==ni['nodes_sha256']and ni['count']==fi['count']
  count=a.count or fi['count'];save(o/'input_identity.json',{'fixture_report_sha256':sha(a.fixture/'report.json'),'node_report_sha256':sha(a.nodes/'report.json'),'vectors_sha256':sha(vectors),'nodes_sha256':sha(nodes),'requested_count':count,'total_real_inputs':fi['real_tanh_values'],'boundary_inputs':fi['boundary_values'],'nonfinite_inputs':fi['nonfinite_records'],'build_manifest_sha256':sha(b/'report.json')})
  events=execute_rtl([VIV/'xsim','tanh8_sim','-runall','-testplusarg','COUNT='+str(count),'-testplusarg','TOTAL_COUNT='+str(fi['count']),'-testplusarg','VECTORS='+str(vectors),'-testplusarg','NODES='+str(nodes),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')],b,o)
  log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert 'HARDWARE_AGENT_SIM_PASS TANH8'in log and not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  progress=[json.loads(x)for x in(o/'semantic_progress.jsonl').read_text().splitlines()];assert progress and progress[-1]['checked']==count+2566
  assert all(x['schema']=='m007-tanh-consumed-v1'for x in progress)
  assert all(x['checked']<y['checked']and x['cycle']<y['cycle']and x['node_checks']<=y['node_checks']for x,y in zip(progress,progress[1:]))
  save(o/'report.json',{'status':'PASS','scope':'eight original-DAG TANH lanes,96bit tags/masks/lease; complete42-node assertions on every active lane','main_input_count':count,'all_real_and_boundary':count==fi['count'],'original_graph_nodes_per_input':42,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'semantic_progress_sha256':sha(o/'semantic_progress.jsonl'),'semantic_progress_event_count':len(progress),'last_semantic_progress':progress[-1],'xsim_log_sha256':sha(o/'xsim.log'),'actual_runtime_events':events,'result_marker':next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS TANH8')),'normal_main_marker':next(x for x in log.splitlines()if x.startswith('TANH8_MAIN_PASS'))})
if __name__=='__main__':main()
