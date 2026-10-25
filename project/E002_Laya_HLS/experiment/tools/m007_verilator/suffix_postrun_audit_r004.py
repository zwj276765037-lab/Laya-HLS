#!/usr/bin/env python3
"""Seal only completed actual D36 evidence; no build/simulation or production edits."""
import datetime as dt,hashlib,json,re,time
from pathlib import Path
from suffix_driver_r004 import endpoint_capture,actual_capture,FINAL_COUNTS,PASS
ROOT=Path(__file__).resolve().parents[5];RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004';AT=RUN/'attempts/AT006_fixed_complete_suffix'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def dump(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def proc(pid):
 try:
  z=(Path('/proc')/str(pid)/'stat').read_text().rsplit(')',1)[1].split();return z[0],int(z[19])
 except (OSError,ValueError):return None
start=time.monotonic();primary=AT/'receipt_rtl.json';assert primary.is_file(),'actual main run not yet complete';out=AT/'final_suffix_receipt.json';assert not out.exists(),'preserve final evidence'
x=json.loads(primary.read_text());d=x.get('driver_receipt');good=x['verdict']=='PASS' and d and d['verdict']=='PASS' and not x['guard']['trigger'];issues=[];integrity=None
if good:
 try:
  assert not x['original30_fullgraph_complete'] and x['segmented_suffix_complete'] and d['scope']=='SEGMENTED_SUFFIX' and not d['original30_fullgraph_complete'] and d['segmented_suffix_complete']
  assert d['raw_child_return_code']==0 and x['guard']['child_exit_code']==0 and d['completed_suffix_layers']==[28,29]
  assert len(d['completed_stages'])==55 and sum(z['stage'].startswith('head') for z in d['completed_stages'])==32
  assert len(d['layer_records'])==2 and max(z['duration_seconds'] for z in d['layer_records'])<=600 and max(z['duration_seconds'] for z in d['completed_stages'])<=120 and d['elapsed_seconds']<=1800
  assert d['actual_thread_samples'] and all(z['threads']==1 for z in d['actual_thread_samples'])
  assert all(d['actual_output_integrity']['actual_final_counts'].get(k)==v for k,v in FINAL_COUNTS.items())
  assert len(d['actual_provider_LN_commands'])==5 and [z['fields']['gamma'] for z in d['actual_provider_LN_commands']]==[1,0,0,0,0]
  p=AT/'work/actual_fullgraph';gold=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128'
  endpoints={label:endpoint_capture(p,label,gold/name) for label,name in [('finalLN','final_norm.f32.bin'),('type','type_add.f32.bin')]}
  layers=[actual_capture(p,gl,gold,True) for gl in [28,29]]
  actual_input=Path(str(p)+'.H0.bin');assert actual_input.read_bytes()==(RUN/'frozen_input/encoder27.actual.f32.bin').read_bytes()
  cfg=json.loads((AT/'config.json').read_text());fixture=Path(next(s.split('=',1)[1] for s in cfg['plusargs'] if s.startswith('+ORIGINAL_GRAPH=')));tail=fixture/'tail544.hex';packed=b''.join(int(s,16).to_bytes(128,'little') for s in tail.read_text().splitlines() if s.strip());output=Path(str(p)+'.output.bin');assert len(packed)==69632 and output.read_bytes()==packed
  receipt=Path(str(p)+'.receipt.txt').read_text();assert 'layers=2 matrices=8 LN=5 vector=5 GEGLU=0 tail_commits=1 done_consumed=1 ' in receipt and 'scope=SEGMENTED_SUFFIX original_prefix_replayed=0 actual_input=encoder27 actual_heads=32 actual_gamma_commands=1' in receipt
  events=[json.loads(s) for s in (AT/'work/wall_events.jsonl').read_text().splitlines()];assert sum(z['line']==PASS for z in events)==1
  holds=[dict(line=z['line'],elapsed_s=z['elapsed_s'],fields={k:int(v) for k,v in re.findall(r'([A-Za-z0-9_]+)=(\d+)',z['line'])}) for z in events if z['line'].startswith('M007_LN_COMMAND_HOLD_OK ')]
  assert len(holds)==5 and [z['fields']['gamma'] for z in holds]==[1,0,0,0,0] and all(z['fields']['natural_delay_cycles']>0 for z in holds)
  obs=[z for z in events if z['line'].startswith('M007_LN_COMMAND_OBSERVE ')];assert obs
  for z in obs:
   fields={k:int(v) for k,v in re.findall(r'([A-Za-z0-9_]+)=(\d+)',z['line'])};assert fields['gamma']==fields['expected_gamma']
  assert not any('M007_LN_HOLD_ERROR' in z['line'] or '%Fatal' in z['line'] or '%Error' in z['line'] for z in events)
  manifests=[*RUN.glob('attempts/AT*/source_manifest.json'),*RUN.glob('attempts/AT*/generated_build_inputs.json')];expected={}
  for m in manifests:
   for z in json.loads(m.read_text())['sources_and_inputs']:
    if z['path'] in expected:assert expected[z['path']]==z['sha256'],'conflicting identity '+z['path']
    expected[z['path']]=z['sha256']
  for name,h in expected.items():assert sha(Path(name))==h,'frozen input changed '+name
  integrity={'verdict':'PASS_FOR_ACTUAL_SEGMENTED_SUFFIX_ONLY','actual_input':identify(actual_input),'actual_input_equals_saved_Encoder27_H':True,'finalLN_type_actual_fullvalue_integrity':endpoints,'twoDecision_actual_H_and_trace_integrity':layers,'actual_tail_output':identify(output),'actual_tail544_original_hex':identify(tail),'all69632_actual_tail_bytes_bit_exact':True,'original_terminal_receipt':receipt,'actual_provider_LN_commands':d['actual_provider_LN_commands'],'natural_delay_hold_checks':holds,'valid_unaccepted_wait_cycles_total':sum(z['fields']['valid_wait_cycles'] for z in holds),'forced_backpressure_applied':False,'request_generation_separately_sampled':False,'original_identity_checker_retained':True,'unique_rehashed_execution_input_identities':len(expected),'source_manifest_files':[identify(p) for p in manifests],'original30_once_BEGIN_acceptance':False,'two_state_or_physical_limit':'no original30 end-to-end performance, four-state, allfault, OOC/P&R/board acceptance'}
 except Exception as e:good=False;issues.append('postrun_actual_integrity:'+repr(e))
known={};checked=set();mismatches=[];guards=[];unknown_start=[]
for gp in RUN.glob('attempts/AT*/guard_*/guard_result.json'):
 g=json.loads(gp.read_text());pp=gp.parent/'policy_checks.json';samples=json.loads(pp.read_text()) if pp.exists() else []
 for z in g.get('observed_owned_identities',[]):known[(int(z['pid']),int(z['start_time_ticks']))]=z
 for z in samples:
  checked.add((int(z['pid']),int(z['start_time_ticks'])))
  if not z.get('matches'):mismatches.append(z)
 guards.append({'path':str(gp),'observed_owned_identities':len(g.get('observed_owned_identities',[])),'actual_policy_identities':len({(z['pid'],str(z['start_time_ticks'])) for z in samples})})
for rp in RUN.glob('attempts/AT*/cxx_units/*.json'):
 z=json.loads(rp.read_text())
 for pk,sk in [('wrapper_pid','wrapper_start_ticks'),('compiler_pid','compiler_start_ticks')]:
  if pk not in z:continue
  try:key=(int(z[pk]),int(z[sk]));known[key]={'pid':key[0],'start_time_ticks':key[1]}
  except (KeyError,ValueError,TypeError):unknown_start.append({'record':str(rp),'pid_field':pk,'start_ticks':z.get(sk,'MISSING')})
live=[];zombies=[]
for (pid,ticks),z in known.items():
 current=proc(pid)
 if current and current[1]==ticks:(zombies if current[0]=='Z' else live).append({**z,'state':current[0]})
cleanup={'checked_at':dt.datetime.now(dt.timezone.utc).isoformat(),'known_identity_count':len(known),'remaining_live_owned_identities':live,'remaining_zombie_owned_identities':zombies,'mismatched_policy_samples':mismatches,'missing_policy_identities':[{'pid':pid,'start_time_ticks':ticks} for pid,ticks in sorted(set(known)-checked)],'missing_start_identity_records':unknown_start,'guard_summaries':guards,'static_preparation_unmeasured_policy_scope':'UNKNOWN; authoring/read-only source/packing/audit not guarded; no production mutation','finalizer_itself_not_in_finished_experiment_process_set':True};dump(AT/'owned_cleanup_and_policy.json',cleanup)
if live or zombies or mismatches:good=False;issues.append('owned_cleanup_or_actual_policy_incomplete')
if integrity:dump(AT/'actual_segmented_suffix_integrity.json',integrity)
verdict='COST_STOP' if x['verdict']=='COST_STOP' else 'PASS' if good else 'FAIL';result={'verdict':verdict,'scope':'SEGMENTED_SUFFIX','segmented_suffix_complete':verdict=='PASS','original30_fullgraph_complete':False,'main_primary_receipt':identify(primary),'old_expected_failure_receipt':identify(RUN/'attempts/AT003_old_gamma_reproduction/receipt_rtl.json'),'fixed_prefix_receipt':identify(RUN/'attempts/AT005_fixed_finalLN_type_preLN/receipt_rtl.json'),'actual_integrity':identify(AT/'actual_segmented_suffix_integrity.json') if integrity else None,'cleanup':identify(AT/'owned_cleanup_and_policy.json'),'issues':issues,'created_at':dt.datetime.now(dt.timezone.utc).isoformat(),'next_state':'paused per explicit user instruction; no successor work'};dump(out,result)
dump(RUN/'receipt_final_audit.json',{'category':'static','verdict':'PASS' if good else 'FAIL','stage':'final_actual_suffix_values_identity_and_owned_cleanup_audit','elapsed_seconds':time.monotonic()-start,'guarded':False,'new_simulation_or_build':False})
print(json.dumps(result));raise SystemExit(0 if verdict=='PASS' else 124 if verdict=='COST_STOP' else 1)
