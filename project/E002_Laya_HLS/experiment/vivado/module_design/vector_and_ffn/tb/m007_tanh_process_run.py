#!/usr/bin/env python3
"""D31 independent per-target source audit and original-workload equality/cost runner."""
import argparse
from datetime import datetime,timezone
import hashlib,json
from pathlib import Path
import re,subprocess,tarfile,time

MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[2];PROJECT=ROOT.parents[2];LOCAL=MODULE.relative_to(ROOT)
RUN=PROJECT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R003'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
NAMES=('laya_m007_tanh_fast_leaves_v1.sv','laya_m007_tanh_add3_e_v1.sv','laya_m007_tanh_div12_r4_v1.sv','laya_m007_tanh_core_v2.sv','laya_m007_tanh_core_v3.sv','laya_m007_tanh8_v2.sv','laya_m007_tanh8_v3.sv')
SOURCES=[LOCAL/'rtl'/x for x in NAMES]+[Path('vivado/module_design/attention_and_fp_engine/rtl/laya_return_vector_credit_v1.sv'),LOCAL/'tb/m007_tanh_process_tb.sv']
FIXTURE=PROJECT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work'
NODES=PROJECT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT018_original_tanh_native_node_reference/work'
OLD_INPUT=PROJECT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R002/attempts/AT002_ce26_three_version_4096/work/input_identity.json'
OLD_BUILD=PROJECT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R002/attempts/AT001_ce26_equivalence_build'

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def save(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
def inventory(path):return {str(p.relative_to(path)):sha(p)for p in sorted((path/'xsim.dir').rglob('*'))if p.is_file()}
def execute(argv,cwd):
 print('COMMAND',list(map(str,argv)),flush=True);start=time.monotonic();process=subprocess.Popen(list(map(str,argv)),cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
 lines=[];events=[]
 for line in process.stdout:
  print(line,end='',flush=True);lines.append(line)
  match=re.search(r'TANH_PROCESS_STAGE stage=(\w+) cycle=(\d+)',line)
  if match:events.append({'stage':match[1],'cycle':int(match[2]),'elapsed_s':time.monotonic()-start,'received_utc':datetime.now(timezone.utc).isoformat()})
 code=process.wait();elapsed=time.monotonic()-start;log=''.join(lines)
 if code or re.search(r'(?im)^\s*(?:Fatal|ERROR):',log):raise RuntimeError(f'tool failure exit={code}')
 return log,events,elapsed

def audit(frozen,output):
 rtl=frozen/LOCAL/'rtl';old=(rtl/NAMES[3]).read_text();new=(rtl/NAMES[4]).read_text()
 assert sha(rtl/NAMES[3])=='13df84ea5dc06ece43a3d83b8af2d778fcd3b9bd1bda78e831d0e35ffd53dd10'
 old_lines=old.splitlines(keepends=True);old_base=[];assignments={};order=[]
 for i,line in enumerate(old_lines):
  if not re.match(r'\s*always\b',line):old_base.append(line);continue
  match=re.fullmatch(r'\s*always @\(posedge clk\) if\(core_ce\) (\w+) <= (.+);\n',line)
  if match:
   assert match[1]not in assignments;assignments[match[1]]={'condition':'core_ce','RHS':match[2],'old_line':i+1};order.append(match[1])
  else:assert line.strip()=='always @(posedge clk)if(reset)valid_pipe<=0;else if(core_ce)valid_pipe<={valid_pipe[150:0],in_valid};'
 assert len(assignments)==2446
 assert len(re.findall(r'\balways\s*@',old))==2447 and len(re.findall(r'\balways\s*@',new))==1
 marker=' always @(posedge clk) begin\n';start=new.index(marker);end=new.index('\nendmodule',start)
 body=new[start:end]+'\n';new_base=new[:start]+new[end+1:]
 assert ''.join(old_base)==new_base.replace('laya_m007_tanh_core_v3','laya_m007_tanh_core_v2'),'all non-process bytes/functions/declarations/instances must match'
 prefix=marker+'  if(reset) valid_pipe<=0;\n  else if(core_ce) valid_pipe<={valid_pipe[150:0],in_valid};\n  if(core_ce) begin\n'
 assert body.startswith(prefix) and body.endswith('  end\n end\n')
 parsed=[]
 for line in body[len(prefix):-len('  end\n end\n')].splitlines():
  match=re.fullmatch(r'   (\w+) <= (.+);',line);assert match
  target,expr=match.groups();assert target in assignments and expr==assignments[target]['RHS']
  assignments[target].update(new_condition='core_ce',new_RHS=expr,nonblocking=True);parsed.append(target)
 assert parsed==order and len(set(parsed))==2446
 assert old.count('.aclken(core_ce)')==new.count('.aclken(core_ce)')==42
 wrapper_old=(rtl/NAMES[5]).read_text();wrapper_new=(rtl/NAMES[6]).read_text()
 assert sha(rtl/NAMES[5])=='8c37896cbc20d0cf20b024cb39a771bb39b19aea5ad60f7434bef34d7ebdf248'
 assert wrapper_old==wrapper_new.replace('laya_m007_tanh8_v3','laya_m007_tanh8_v2').replace('laya_m007_tanh_core_v3','laya_m007_tanh_core_v2')
 valid={'target':'valid_pipe','priority':'if(reset)0 else if(core_ce){old[150:0],in_valid}','nonblocking':True,'unchanged':True}
 save(output/'per_target_source_equivalence.json',{'status':'PASS_EXACT_PER_TARGET_CONDITIONS_DAG_AND_NONPROCESS_BODY','baseline_core_sha256':sha(rtl/NAMES[3]),'new_core_sha256':sha(rtl/NAMES[4]),'baseline_processes':2447,'new_processes':1,'distinct_NBA_targets':2447,'data_targets':assignments,'valid_target':valid,'same_assignment_order':True,'unchanged_function_declaration_scope_and_leaves':True,'leaf_instances_unchanged':42,'new_FF_bits':0,'clock_gates':0,'wrapper_protocol_bytes_unchanged':True,'old_D26_audit_preserved':str(OLD_BUILD/'work/complete_CE_reset_coverage.json'),'old_D26_audit_sha256':sha(OLD_BUILD/'work/complete_CE_reset_coverage.json')})


def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--variant',choices=('eq','v2','v3'),required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args()
 output=a.output;output.mkdir(parents=True,exist_ok=False);frozen=output/'frozen';frozen.mkdir()
 with tarfile.open(output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
 assert sha(Path(__file__))==sha(frozen/LOCAL/'tb/m007_tanh_process_run.py')
 if a.stage=='build':
  audit(frozen,output)
  old_receipt=json.loads((OLD_BUILD/'receipt.json').read_text());command=old_receipt['command'];schedule_path=Path(command[command.index('--schedule')+1]);schedule=json.loads(schedule_path.read_text());assert schedule['selected_result_edge']==152
  assert sha(schedule_path)==json.loads((OLD_BUILD/'work/report.json').read_text())['schedule_sha256']
  nodes=sorted(schedule['nodes'],key=lambda n:({'add':0,'mul':1,'div':2}[n['op']],int(re.search(r'\d+',n['name'])[0])))
  assert len(nodes)==42
  checks=[]
  for lane in range(8):
   for index,node in enumerate(nodes):
    edge,name=node['consumer_edge'],node['name']
    checks.append(f'''always @(posedge clk)if(rst_n&&dut.tanh_lane[{lane}].core.valid_pipe[{edge-1}]&&mask_pipe[{edge-1}][{lane}])begin
 if(dut.tanh_lane[{lane}].core.{name}!==nodes[id_pipe[{edge-1}][{lane}]][{1343-32*index}-:32])$fatal(1,"PRIMARY_NODE_{name}");node_checks=node_checks+1;
`ifdef TANH_EQ
 if(auto_dut.tanh_lane[{lane}].core.{name}!==nodes[id_pipe[{edge-1}][{lane}]][{1343-32*index}-:32]||auto_dut.tanh_lane[{lane}].core.{name}!==dut.tanh_lane[{lane}].core.{name})$fatal(1,"SECONDARY_NODE_{name}");secondary_node_checks=secondary_node_checks+1;
`endif
 end''')
  (output/'m007_tanh_process_nodes.svh').write_text('\n'.join(checks)+'\n')
  definitions=['--define','TANH_EQ']if a.variant=='eq'else['--define','TANH_V3']if a.variant=='v3'else[]
  execute([VIV/'xvlog','--sv','-i',output,*definitions,*[frozen/path for path in SOURCES]],output)
  log,_,_=execute([VIV/'xelab','work.m007_tanh_process_tb','--relax','-mt','4','--O3','-s','tanh_process31_sim'],output)
  if a.variant!='eq':assert ('Compiling module work.laya_m007_tanh8_'+('v3'if a.variant=='v2'else'v2'))not in log,'single snapshot contains other wrapper'
  save(output/'report.json',{'status':'BUILD_COMPLETE','variant':a.variant,'source_sha256':{str(path):sha(frozen/path)for path in SOURCES},'driver_sha256':sha(Path(__file__)),'schedule_sha256':sha(schedule_path),'audit_sha256':sha(output/'per_target_source_equivalence.json'),'node_checker_sha256':sha(output/'m007_tanh_process_nodes.svh'),'defines':definitions,'xelab_options':['--relax','-mt','4','--O3'],'expected_actual_TANH8_instances':2 if a.variant=='eq' else 1,'snapshot':inventory(output)})
 else:
  assert a.build;build=json.loads((a.build/'report.json').read_text());assert build['variant']==a.variant and build['driver_sha256']==sha(Path(__file__))
  for name,digest in build['source_sha256'].items():assert sha(frozen/name)==digest and sha(ROOT/name)==digest
  for name,digest in build['snapshot'].items():assert sha(a.build/name)==digest
  previous=json.loads(OLD_INPUT.read_text());fixture=json.loads((FIXTURE/'report.json').read_text());nodes=json.loads((NODES/'report.json').read_text())
  vectors_path=FIXTURE/'tanh_vectors.hex';nodes_path=NODES/'nodes.hex'
  assert sha(vectors_path)==previous['vectors_sha256']==fixture['tanh_vectors']['sha256']==nodes['input_sha256']
  assert sha(nodes_path)==previous['nodes_sha256']==nodes['nodes_sha256']
  save(output/'input_identity.json',dict(previous,reused_original_CE26_input_identity_sha256=sha(OLD_INPUT),count=4096,source_sha256=build['source_sha256'],build_report_sha256=sha(a.build/'report.json')))
  save(output/'snapshot_prerun_sha256.json',inventory(a.build))
  log,events,elapsed=execute([VIV/'xsim','tanh_process31_sim','-runall','-testplusarg','COUNT=4096','-testplusarg','TOTAL_COUNT='+str(fixture['count']),'-testplusarg','VECTORS='+str(vectors_path),'-testplusarg','NODES='+str(nodes_path),'-testplusarg','PROGRESS_FILE='+str(output/'semantic_progress.jsonl'),'-testplusarg','TRACE_FILE='+str(output/'actual_response_trace.txt')],a.build)
  (output/'xsim.log').write_text(log)
  assert 'HARDWARE_AGENT_SIM_PASS TANH8' in log and ('TANH_PROCESS_SAME_RUNTIME_PASS' in log)==(a.variant=='eq')
  match=re.search(r'TANH_PROCESS_WORKLOAD_PASS idle_ce0=(\d+) active_ce1=(\d+) pending_empty_pipe=(\d+) first=(\d+) middle=(\d+) last=(\d+) valid_events=(\d+) core152_checks=(\d+) wrapper_consume_latency=(\d+)',log);assert match and int(match[9])==153
  metrics=dict(zip(('idle_ce0','active_ce1','pending_empty_pipe','first_stage','middle_stage','last_stage','valid_events','core152_checks','public_consume_latency'),map(int,match.groups())))
  match2=re.search(r'HARDWARE_AGENT_SIM_PASS TANH8 checked=(\d+) node_checks=(\d+) first_actual_consume=(\d+) pending_peak=(\d+) flight_peak=(\d+) held_cycles=(\d+) rejects=(\d+)',log);assert match2
  metrics.update(dict(zip(('scalar_checks','node_checks','first_consume','pending_peak','flight_peak','held_cycles','rejects'),map(int,match2.groups()))))
  assert metrics['scalar_checks']==6726
  progress=[json.loads(x)for x in(output/'semantic_progress.jsonl').read_text().splitlines()];assert progress[-1]['checked']==6726
  post=inventory(a.build);assert all(post[name]==digest for name,digest in build['snapshot'].items());save(output/'snapshot_postrun_sha256.json',post)
  assert events[0]['stage']=='INIT'and events[-1]['stage']=='DONE'
  category={'INIT':0.,'RUN':0.,'IDLE':0.}
  for before,after in zip(events,events[1:]):category[before['stage']]+=after['elapsed_s']-before['elapsed_s']
  timing={'xsim_launch_to_exit_s':elapsed,'startup_before_TB_INIT_s':events[0]['elapsed_s'],'TB_fixture_initialization_s':category['INIT'],'active_and_protocol_s':category['RUN'],'explicit_idle_noise_s':category['IDLE'],'shutdown_after_TB_DONE_s':elapsed-events[-1]['elapsed_s'],'actual_cycles':progress[-1]['cycle'],'basis':'host monotonic receipt of flushed same-TB stage markers; category costs include fixed checker/control overhead, single sample','stage_events':events}
  save(output/'report.json',{'status':'PASS_SAME_RUNTIME_V2_V3'if a.variant=='eq'else'PASS_SINGLE_TANH8_COST','variant':a.variant,'measurements':metrics,'timing':timing,'actual_response_trace_sha256':sha(output/'actual_response_trace.txt'),'actual_response_trace_lines':len((output/'actual_response_trace.txt').read_text().splitlines()),'source_sha256':build['source_sha256'],'build_report_sha256':sha(a.build/'report.json'),'input_identity_sha256':sha(output/'input_identity.json'),'last_checked_consumption':progress[-1],'snapshot_original_files_unchanged':True,'joint_speedup_or_hardware_timing':'NOT_RUN'})
if __name__=='__main__':main()
