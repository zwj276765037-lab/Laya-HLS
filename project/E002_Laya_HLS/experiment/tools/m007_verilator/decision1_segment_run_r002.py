#!/usr/bin/env python3
"""D34 same-executable original Decision1, bounded by measured Decision0 cost."""
import fcntl,importlib.util,json,os,subprocess,sys,time
from pathlib import Path
started=time.monotonic();h=Path(__file__).resolve().parent;s=importlib.util.spec_from_file_location('m',h/'fullgraph_run_r002.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
at=m.RUN/'attempts/AT011_kind6_decision1';base=m.RUN/'attempts/AT010_kind6_public_abi';work=at/'work';cfg=json.loads((at/'config.json').read_text());guard=Path(cfg['guard_path']);driver=h/'decision1_segment_driver_r002.py';exe=Path(cfg['source_executable']);prefix=next(q.split('=',1)[1] for q in cfg['plusargs'] if q.startswith('+EXPORT='));E=331.58745134505443*1.35+10
oracle=m.ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128';gold=oracle/'decision_01_out.f32.bin';input_bin=oracle/'decision_00_out.f32.bin'
build=json.loads((base/'receipt_build.json').read_text());assert build['verdict']=='PASS' and m.sha(exe)==build['executable']['sha256'];assert json.loads((base/'receipt_rtl.json').read_text())['verdict']=='PASS';assert cfg['runtime_identity']==json.loads((base/'config.json').read_text())['runtime_identity']
oldmanifest=json.loads((base/'source_manifest.json').read_text());identities={q['path']:q for q in oldmanifest['sources_and_inputs']}
for name in cfg['sources']:
 assert m.sha(Path(name))==identities[name]['sha256'],name
assert '+KIND=6' in cfg['plusargs'] and '+LAYER=1' in cfg['plusargs'] and not any(q=='+LAYER=0' for q in cfg['plusargs'])
tb=next(Path(q) for q in cfg['sources'] if Path(q).name=='m007_fullgraph_binary_tb.sv');txt=tb.read_text();assert 'else $readmemh({original_dir,"/decision1_input.hex"},initial_h);' in txt and 'checkpoint_index(28+decision_local)' in txt
fixture=next(Path(q.split('=',1)[1]) for q in cfg['plusargs'] if q.startswith('+ORIGINAL_GRAPH='));input_hex=fixture/'decision1_input.hex';rebuilt=b''.join(int(z.strip(),16).to_bytes(128,'little') for z in input_hex.read_text().splitlines() if z.strip());assert rebuilt==input_bin.read_bytes() and len(rebuilt)==524288
for q in (base/'work').glob('*.dat'):
 dst=work/q.name
 if not dst.exists():dst.symlink_to(q.resolve())
pred=json.loads((base/'phase_source_predicates.json').read_text());pred.update(global_layer=29,checkpoint_index=31,local_layer=1,global_seconds=500,consecutive_seconds=120,source_same_exact_executable=True,measured_Decision0_guard_seconds=331.58745134505443,conservative_plan_E_seconds=E,final='original layer29/checkpoint31 + actual4096 group H capture + public original4096 output + successful heldDONE consumption + actual idle + PASS + normal exit + original decision_01_out bit-exact');m.dump(at/'phase_source_predicates.json',pred)
paths=[at/'config.json',exe,base/'receipt_build.json',base/'receipt_rtl.json',base/'source_manifest.json',base/'incremental_reuse_proof.json',base/'phase_source_predicates.json',at/'phase_source_predicates.json',driver,Path(__file__),gold,input_bin,input_hex,*map(Path,cfg['sources'])];m.dump(at/'source_manifest.json',{'sources_and_inputs':[m.identify(q) for q in dict.fromkeys(paths)],'same_executable_no_mathematical_rebuild':True,'generated_objects_and_runtime_reused_from_actual_AT010_PASS':True,'kind6_local1_only':True,'input_fixture_bit_exact_original_decision0_output':True,'actual_model':'UNKNOWN','actual_effort':'UNKNOWN'})
preparation=time.monotonic()-started;assert preparation<=20,'bounded source/parameter preflight';m.dump(at/'preflight_measurement.json',{'elapsed_seconds':preparation,'cap_seconds':20,'category':'static_preparation_non_guard','verdict':'PASS','fixture_original_input_equal':True,'E_seconds':E})
env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
 for stage in ['validate','rtl']:
  out=at/('guard_'+stage);assert not out.exists(),'preserve previous stage'
  if stage=='validate':cmd=[sys.executable,str(driver),'replay','--receipt',str(work/'decision_segment_replay_result.json')];cap=20;cat='static';assert m.budget()['static']+20<=1200
  else:
   assert json.loads((at/'receipt_validate.json').read_text())['verdict']=='PASS' and 7200-m.budget()['rtl']>=E+600
   cmd=[sys.executable,str(driver),'run','--events',str(work/'wall_events.jsonl'),'--segments',str(work/'segment_retirements.jsonl'),'--receipt',str(work/'decision_driver_receipt.json'),'--capture-meta',prefix+'.layer29.capture.json','--capture-binary',prefix+'.layer29.f32.bin','--capture-trace',prefix+'.layer29.accepted.jsonl','--gold',str(gold),'--public-output',prefix+'.output.bin','--original-receipt',prefix+'.receipt.txt','--command',str(exe),*cfg['plusargs']];cap=500;cat='rtl';m.dump(at/'rtl_execution_identity.json',{'executable':m.identify(exe),'source_manifest':m.identify(at/'source_manifest.json'),'driver':m.identify(driver),'launcher':m.identify(Path(__file__)),'original_input':m.identify(input_bin),'original_gold':m.identify(gold),'same_model_no_build':True,'kind6_local1':True,'whole_kind7_complete':False,'plan_E_seconds':E})
  argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','24' if cat=='static' else '8','--timeout-seconds',str(cap),'--semantic-stall-seconds','120','--phase',cat]
  if cat=='static':argv+=['--artifact-progress-root',str(work)]
  argv+=['--',*cmd];m.dump(at/('command_'+stage+'.json'),{'category':cat,'argv':argv,'budget_before':m.budget(),'E_seconds':E,'retained_RTL_reserve_seconds':600})
  with (at/(stage+'_wrapper.log')).open('w') as f:rc=subprocess.call(argv,cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT)
  g=json.loads((out/'guard_result.json').read_text());ip=work/('decision_segment_replay_result.json' if stage=='validate' else 'decision_driver_receipt.json');inner=json.loads(ip.read_text()) if ip.exists() else None;ok=rc==0 and not g['trigger'] and inner and inner['verdict']=='PASS';cost=bool(g['trigger']) or bool(inner and inner['verdict']=='COST_STOP');verdict='PASS' if ok else 'COST_STOP' if cost else 'FAIL';m.dump(at/('receipt_'+stage+'.json'),{'category':cat,'verdict':verdict,'guard':g,'guard_wrapper_exit':rc,'driver_receipt':inner,'fullgraph_complete':False,'public_kind6_local1_complete':ok and stage=='rtl'});print(json.dumps({'stage':stage,'verdict':verdict,'elapsed_seconds':g['elapsed_seconds'],'reason':inner.get('reason') if inner else None,'trigger':g['trigger']}),flush=True)
  if not ok:raise SystemExit(124 if cost else 1)
