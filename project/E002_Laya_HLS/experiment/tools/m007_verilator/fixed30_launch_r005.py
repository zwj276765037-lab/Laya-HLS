#!/usr/bin/env python3
"""D37: validate new observer/driver, then launch exactly one full original30 request."""
import argparse,datetime as dt,fcntl,hashlib,importlib.util,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005'
BASE=RUN/'attempts/AT001_fixed_original30_build';AT=RUN/'attempts/AT002_fixed_original30_kind7'
VROOT=Path('/home/user/EDA-202/zhuowenjun/.local-tools/verilator-5.020/usr/share/verilator')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def budget():
 totals={'static':0.,'rtl':0.}
 for p in [*RUN.glob('receipt_*.json'),*RUN.glob('attempts/AT*/receipt_*.json')]:
  x=json.loads(p.read_text());cat=x.get('category')
  if cat in totals:totals[cat]+=x.get('guard',{}).get('elapsed_seconds',x.get('elapsed_seconds',0.))
 return totals
def verify(p):
 for z in json.loads(p.read_text())['sources_and_inputs']:assert sha(Path(z['path']))==z['sha256'],'identity changed '+z['path']
def validate():
 assert not (RUN/'receipt_driver_validate.json').exists(),'preserve validation'
 start=time.monotonic();out=RUN/'driver_validation.json'
 subprocess.run([sys.executable,str(HERE/'fixed30_driver_r005.py'),'replay','--root',str(ROOT),'--receipt',str(out)],check=True,cwd=ROOT)
 spec=__import__('importlib.util',fromlist=['']).spec_from_file_location('fixed30driver',HERE/'fixed30_driver_r005.py');m=__import__('importlib.util',fromlist=['']).module_from_spec(spec);spec.loader.exec_module(m)
 valid=[('M007_FULLGRAPH_LAYER_END global=27 checkpoint=27 cycle=100',9000.),('M007_FULLGRAPH_PHASE global=27 state=91 heads=65535 matrix_done=4 cycle=200',9040.),('M007_FULLGRAPH_PHASE global=27 state=96 heads=65535 matrix_done=4 cycle=300',9070.),('M007_FULLGRAPH_PHASE global=28 state=86 heads=65535 matrix_done=0 cycle=400',9119.9)]
 def bridge_flow():
  f=m.Flow(27);f.index=len(m.plan(27))-1;f.anchor=8990;f.layer_anchor=8900;f.layer_seen=False;f.capture_seen=True;return f
 f=bridge_flow()
 for line,t in valid:f.feed(line,t)
 assert f.bridge_complete and abs(f.bridge_duration-119.9)<1e-6
 rejects=[]
 for label,events in [('whole_bridge_cap',valid[:3]+[(valid[3][0],9120.01)]),('missing_gamma',[valid[0],valid[2]]),('missing_type',valid[:2]+valid[3:])]:
  f=bridge_flow()
  try:
   for line,t in events:f.feed(line,t)
  except m.Stop as e:rejects.append({'case':label,'verdict':e.verdict,'reason':e.reason})
  else:raise AssertionError(label)
 f=bridge_flow();f.feed(*valid[0])
 try:f.check(9120.01)
 except m.Stop as e:assert e.verdict=='COST_STOP';rejects.append({'case':'bridge_silence_cap','verdict':e.verdict})
 else:raise AssertionError('bridge silence')
 dump(RUN/'bridge_validation.json',{'verdict':'PASS','actual_code_order_and_deadline_rejects':rejects,'synthetic_only_not_new_RTL':True})
 dump(RUN/'receipt_driver_validate.json',{'category':'static','verdict':'PASS','elapsed_seconds':time.monotonic()-start,'stage':'original_actual_component_replays_full_order_and_whole_handoff_rejection','new_RTL_run':False})
 print('D37_DRIVER_VALIDATION_PASS',flush=True)
def launch():
 start=time.monotonic();assert not AT.exists(),'unique full attempt; preserve failure/no automatic retry'
 verify(BASE/'source_manifest.json');verify(BASE/'generated_build_inputs.json')
 build=json.loads((BASE/'complete_build_dispatch.json').read_text());assert build['status']=='PASS'
 build_guard_seconds=sum(json.loads(p.read_text())['guard']['elapsed_seconds'] for p in BASE.glob('receipt_build*.json'))
 dispatch_overhead=build['elapsed_seconds']-build_guard_seconds;assert dispatch_overhead>=0
 dump(BASE/'receipt_build_dispatch_overhead.json',{'category':'static','verdict':'PASS','elapsed_seconds':dispatch_overhead,'stage':'measured_complete_build_dispatch_overhead_not_already_in_batch_guards'})
 records=sorted((BASE/'cxx_units').glob('*.json'));assert records and all(json.loads(p.read_text())['state']=='COMPLETE' and json.loads(p.read_text())['exit_code']==0 for p in records),'all actual compilations must succeed'

 assert json.loads((RUN/'receipt_driver_validate.json').read_text())['verdict']=='PASS'
 assert json.loads((BASE/'actual_full_parameter_expansion.json').read_text())['verdict']=='PASS'
 work=AT/'work';work.mkdir(parents=True);frozen=AT/'frozen';frozen.mkdir();cfg=json.loads((BASE/'config.json').read_text());exe=BASE/'work/obj'/('V'+cfg['top']);assert sha(exe)==build['executable']['sha256']
 cfg['source_executable']=str(exe);cfg['plusargs']=[z.replace(str(BASE/'work'),str(work)) if z.startswith('+EXPORT=') else z for z in cfg['plusargs']]
 assert cfg['verilator_flags'][-1]=='-GVERIFY_POST_ENCODER27_H=0' and '+KIND=7' in cfg['plusargs'] and '+LAYER=0' in cfg['plusargs']
 assert not any('POST_ENCODER27_H=' in z or z.startswith('+STOP') for z in cfg['plusargs'])
 dump(AT/'config.json',cfg)
 for q in (BASE/'work').glob('*.dat'):(work/q.name).symlink_to(q.resolve())
 driver=HERE/'fixed30_driver_r005.py';guard=HERE/'fullgraph_guard_v1.py'
 for q in [driver,Path(__file__),BASE/'frozen/D37_contract.md',ROOT/'AGENTS.md']:(frozen/q.name).write_bytes(q.read_bytes())
 paths=[exe,driver,guard,Path(__file__),AT/'config.json',BASE/'source_manifest.json',BASE/'generated_build_inputs.json',BASE/'generated_scale_gate.json',BASE/'actual_full_parameter_expansion.json',BASE/'complete_build_dispatch.json',RUN/'receipt_driver_validate.json',RUN/'bridge_validation.json',frozen/'D37_contract.md']
 for manifest in [BASE/'source_manifest.json',BASE/'generated_build_inputs.json']:paths.extend(Path(z['path']) for z in json.loads(manifest.read_text())['sources_and_inputs'])
 # Freeze every actual object and link dependency used, including fresh generated PCH.
 paths.extend((BASE/'work/obj').glob('*.o'));paths.extend((BASE/'work/obj').glob('*.a'));paths.extend((BASE/'work/obj').glob('*.gch'));paths.extend((BASE/'work/obj').glob('*.d'));paths.extend(records);paths.extend(VROOT.rglob('*.h'));paths.extend([Path('/usr/bin/g++'),Path('/usr/bin/make'),BASE/'readonly_capture_source_audit.json',RUN/'unmeasured_preparation_failure_reserve.json'])
 dump(AT/'source_manifest.json',{'scope':'FIXED_ORIGINAL30_ONCE_BEGIN','sources_and_inputs':[identify(p) for p in dict.fromkeys(paths)],'expected_model':'gpt-6.1-sol','expected_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','configuration_evidence':'agent/A013/launch_evidence_20261024.json','same_math_and_interfaces_no_new_gold':True,'actual_parameter':0,'all_model_generated_objects_fresh':True,'single_eval_no_DUT_writes':True})
 elapsed=time.monotonic()-start;dump(AT/'receipt_prepare.json',{'category':'static','verdict':'PASS' if elapsed<=120 else 'COST_STOP','stage':'freeze_full30_execution_and_dependencies','elapsed_seconds':elapsed,'guarded':False});assert elapsed<=120
 assert 15600-budget()['rtl']>=15600,'D37 startup requires full15600 RTL remaining'
 assert budget()['static']+240<=1800,'independent static budget including conservative240s unknown preparation failure reserve'
 prefix=Path(next(z.split('=',1)[1] for z in cfg['plusargs'] if z.startswith('+EXPORT=')));gold=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128';fixture=Path(next(z.split('=',1)[1] for z in cfg['plusargs'] if z.startswith('+ORIGINAL_GRAPH=')))
 cmd=[sys.executable,str(driver),'run','--receipt',str(work/'fixed30_driver_receipt.json'),'--events',str(work/'wall_events.jsonl'),'--segments',str(work/'stage_retirements.jsonl'),'--layers',str(work/'layer_endpoints.jsonl'),'--status',str(work/'live_status.json'),'--prefix',str(prefix),'--gold-dir',str(gold),'--tail-hex',str(fixture/'tail544.hex'),'--command',str(exe),*cfg['plusargs']]
 out=AT/'guard_rtl';argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','8','--timeout-seconds','15000','--semantic-stall-seconds','120','--phase','rtl','--',*cmd]
 dump(AT/'command_rtl.json',{'category':'rtl','argv':argv,'budget_before_seconds':budget(),'scope':'FIXED_ORIGINAL30_ONCE_BEGIN','one_full_run_no_retry':True,'resource_policy':{'CPU':[0,1,2,3],'model_threads':1,'nice':19,'IOclass':3,'MemAvailable_min_GiB':192,'RSS_GiB':8,'max_cycles':40000000,'global_seconds':15000,'layer_seconds':600,'continuous_stage_seconds':120,'semantic_stall_seconds':120,'Encoder27_finalLN_type_Decision0preLN_combined_seconds':120,'Decision1_tail_DONE_idle_combined_seconds':120}})
 dump(AT/'rtl_execution_identity.json',{'executable':identify(exe),'source_manifest':identify(AT/'source_manifest.json'),'config':identify(AT/'config.json'),'driver':identify(driver),'launcher':identify(Path(__file__)),'formal_parameter':0,'original_initial_H_only':True,'one_kind7_BEGIN':True,'no_saved_H_STOP_CPU_math_or_layer_jump':True})
 env=os.environ.copy();env['VERILATOR_ROOT']=str(VROOT);env['PYTHONPATH']=str(ROOT/'project/E002_Laya_HLS/experiment/tools')
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  with (AT/'rtl_wrapper.log').open('w') as f:rc=subprocess.call(argv,cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT)
 g=json.loads((out/'guard_result.json').read_text());inner=json.loads((work/'fixed30_driver_receipt.json').read_text()) if (work/'fixed30_driver_receipt.json').exists() else None
 ok=rc==0 and not g['trigger'] and inner and inner['verdict']=='PASS';cost=bool(g['trigger']) or bool(inner and inner['verdict']=='COST_STOP');verdict='PASS' if ok else 'COST_STOP' if cost else 'FAIL'
 dump(AT/'receipt_rtl.json',{'category':'rtl','verdict':verdict,'guard':g,'guard_wrapper_exit':rc,'driver_receipt':inner,'scope':'FIXED_ORIGINAL30_ONCE_BEGIN','fullgraph_complete':bool(ok)})
 dump(RUN/'budget_current.json',{'measured_seconds':budget(),'limits':{'static':1800,'rtl':15600,'rtl_reserve':600,'reference':0,'ooc':0},'old_balance_transferred':False,'failed_unmeasured_preparations_and_authoring_orchestration':'UNKNOWN additional, not0; see preserved preparation failure records'})
 print(json.dumps({'verdict':verdict,'guard_seconds':g['elapsed_seconds'],'reason':inner.get('reason') if inner else None,'trigger':g['trigger']}),flush=True)
 return 0 if ok else 124 if cost else 1
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('mode',choices=['validate','run']);a=p.parse_args()
 if a.mode=='validate':validate()
 else:raise SystemExit(launch())
