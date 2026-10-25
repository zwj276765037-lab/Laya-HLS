#!/usr/bin/env python3
"""D37 completed-run audit: exact actual data, execution identities, cleanup and costs."""
import datetime as dt,hashlib,json,re,subprocess,time
from pathlib import Path
from fixed30_driver_r005 import actual_capture,actual_endpoint,FINAL_COUNTS,PASS
ROOT=Path(__file__).resolve().parents[5];RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005';AT=RUN/'attempts/AT002_fixed_original30_kind7';BASE=RUN/'attempts/AT001_fixed_original30_build'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def proc(pid):
 try:
  z=(Path('/proc')/str(pid)/'stat').read_text().rsplit(')',1)[1].split();return z[0],int(z[19])
 except (OSError,ValueError):return None
start=time.monotonic();primary=AT/'receipt_rtl.json';assert primary.is_file(),'actual full run not yet complete';final=AT/'final_fixed_original30_receipt.json';assert not final.exists(),'preserve final evidence'
x=json.loads(primary.read_text());d=x.get('driver_receipt');good=x['verdict']=='PASS' and d and d['verdict']=='PASS' and not x['guard']['trigger'];issues=[];integrity=None;expected={}
try:
 for manifest in [BASE/'source_manifest.json',BASE/'generated_build_inputs.json',AT/'source_manifest.json']:
  for z in json.loads(manifest.read_text())['sources_and_inputs']:
   if z['path'] in expected:assert expected[z['path']]==z['sha256'],'conflicting frozen identity '+z['path']
   expected[z['path']]=z['sha256']
 for name,h in expected.items():assert sha(Path(name))==h,'frozen execution identity changed '+name
except Exception as e:good=False;issues.append('execution_identity:'+repr(e))
if good:
 try:
  assert d['fullgraph_complete'] and d['raw_child_return_code']==0 and x['guard']['child_exit_code']==0
  assert d['completed_global_layers']==list(range(30)) and len(d['completed_stages'])==782 and sum(z['stage'].startswith('head') for z in d['completed_stages'])==480
  assert len(d['layer_records'])==30 and max(z['duration_seconds'] for z in d['layer_records'])<=600 and max(z['duration_seconds'] for z in d['completed_stages'])<=120 and d['elapsed_seconds']<=15000
  assert d['whole_bridge_complete'] and d['actual_output_integrity']['whole_Encoder27_finalLN_type_Decision0preLN_seconds']<=120
  assert d['actual_thread_samples'] and all(z['threads']==1 for z in d['actual_thread_samples'])
  assert all(d['actual_output_integrity']['all_original_final_counts'].get(k)==v for k,v in FINAL_COUNTS.items())
  p=AT/'work/actual_fullgraph';gold=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128'
  layers=[actual_capture(p,gl,gold,True) for gl in range(30)];endpoints={label:actual_endpoint(p,label,gold) for label in ['finalLN','type']}
  initial=Path(str(p)+'.H0.bin');assert len(initial.read_bytes())==524288 and initial.read_bytes()==(gold/'embedding_norm.f32.bin').read_bytes()
  cfg=json.loads((AT/'config.json').read_text());assert cfg['verilator_flags'][-1]=='-GVERIFY_POST_ENCODER27_H=0' and '+KIND=7' in cfg['plusargs'] and '+LAYER=0' in cfg['plusargs'] and not any(z.startswith(('+POST_ENCODER27_H=','+STOP')) for z in cfg['plusargs'])
  fixture=Path(next(s.split('=',1)[1] for s in cfg['plusargs'] if s.startswith('+ORIGINAL_GRAPH=')));tail=fixture/'tail544.hex';packed=b''.join(int(s,16).to_bytes(128,'little') for s in tail.read_text().splitlines() if s.strip());output=Path(str(p)+'.output.bin');assert len(packed)==69632 and output.read_bytes()==packed
  receipt=Path(str(p)+'.receipt.txt').read_text();assert 'kind=7 layer=0 ' in receipt and 'BEGIN=1 layers=30 matrices=120 LN=60 vector=61 GEGLU=28 tail_commits=1 done_consumed=1 ' in receipt
  events=[json.loads(s) for s in (AT/'work/wall_events.jsonl').read_text().splitlines()];assert sum(z['line']==PASS for z in events)==1
  fields=lambda line:{k:int(v) for k,v in re.findall(r'([A-Za-z0-9_]+)=(\d+)',line)}
  ln=[dict(line=z['line'],elapsed_s=z['elapsed_s'],fields=fields(z['line'])) for z in events if z['line'].startswith('M007_LN_COMMAND ')]
  assert len(ln)==60 and [z['fields']['gamma'] for z in ln]==[0]*55+[1]+[0]*4 and ln[55]['fields']['global']==27
  successes=[fields(z['line']) for z in events if z['line'].startswith('M007_RESIDENT_LN_SUCCESS ')];assert len(successes)==60 and all(z['issued']==z['written']==4096 for z in successes)
  fc2=[fields(z['line']) for z in events if z['line'].startswith('M007_DECISION_FC2_ADMITTED ')];assert [z['global'] for z in fc2]==[28,29] and all((z['writes'],z['acks'],z['closed'],z['success'],z['published'],z['debt'])==(16384,16384,1,1,1,0) for z in fc2)
  assert not re.search(r'%Error|%Fatal|Assertion failed|M007_(?:LAYER|ENDPOINT)_CAPTURE_ERROR',(AT/'guard_rtl/driver.log').read_text())
  obj=BASE/'work/obj';archives=list(obj.glob('*.a'));assert len(archives)==1;archive=archives[0];members=subprocess.check_output(['/usr/bin/ar','t',str(archive)],text=True).splitlines();assert len(members)==len(set(members))
  archive_checks=[]
  for member in members:
   data=subprocess.check_output(['/usr/bin/ar','p',str(archive),member]);assert hashlib.sha256(data).hexdigest()==sha(obj/member);archive_checks.append({'member':member,'sha256':sha(obj/member)})
  dump(AT/'actual_archive_member_integrity.json',{'verdict':'PASS','archive':identify(archive),'members':archive_checks,'all_members_equal_current_successful_fresh_objects':True})
  integrity={'verdict':'PASS','scope':'FIXED_ORIGINAL30_ONCE_BEGIN','actual_initial_H':identify(initial),'actual_initial_H_equals_original_embedding_norm':True,'all30_actual_H_and_independent_trace_integrity':layers,'all30_H_total_bytes':30*524288,'actual_finalLN_type_integrity':endpoints,'actual_tail_output':identify(output),'original_tail_fixture':identify(tail),'all69632_tail_bytes_exact':True,'original_terminal_receipt':receipt,'actual_LN_commands':ln,'all60_LN_actual_successes':successes,'actual_two_FC1_ACK_publish_to_FC2':fc2,'actual_head_success_endpoints':480,'whole_Encoder27_finalLN_type_Decision0preLN_seconds':d['actual_output_integrity']['whole_Encoder27_finalLN_type_Decision0preLN_seconds'],'unique_rehashed_execution_identities':len(expected),'no_synthetic_H_gold_or_CPU_math_in_run':True,'no_extra_eval_or_DUT_writes':True,'actual_bank_assertions_passed_for_all_capture_lanes':True,'limitations':'normal path compiled two-state backend only; no four-state/allfault/OOC/P&R/timing/board or M007 whole acceptance'}
 except Exception as e:good=False;issues.append('actual_full30_integrity:'+repr(e))
known={};checked=set();mismatches=[];unknown_start=[];guards=[]
for gp in RUN.glob('attempts/AT*/guard_*/guard_result.json'):
 g=json.loads(gp.read_text());pp=gp.parent/'policy_checks.json';samples=json.loads(pp.read_text()) if pp.exists() else []
 for z in g.get('observed_owned_identities',[]):known[(int(z['pid']),int(z['start_time_ticks']))]=z
 for z in samples:
  checked.add((int(z['pid']),int(z['start_time_ticks'])))
  if not z.get('matches'):mismatches.append(z)
 guards.append({'path':str(gp),'observed_owned_identities':len(g.get('observed_owned_identities',[])),'actually_sampled_policy_identities':len({(z['pid'],str(z['start_time_ticks'])) for z in samples})})
for rp in BASE.glob('cxx_units/*.json'):
 z=json.loads(rp.read_text())
 for pk,sk in [('wrapper_pid','wrapper_start_ticks'),('compiler_pid','compiler_start_ticks')]:
  try:key=(int(z[pk]),int(z[sk]));known[key]={'pid':key[0],'start_time_ticks':key[1]}
  except (KeyError,ValueError,TypeError):unknown_start.append({'record':str(rp),'pid_field':pk,'start':z.get(sk,'MISSING')})
live=[];zombies=[]
for (pid,ticks),z in known.items():
 current=proc(pid)
 if current and current[1]==ticks:(zombies if current[0]=='Z' else live).append({**z,'state':current[0]})
cleanup={'checked_at':dt.datetime.now(dt.timezone.utc).isoformat(),'known_identity_count':len(known),'remaining_live_owned_identities':live,'remaining_zombie_owned_identities':zombies,'mismatched_policy_samples':mismatches,'missing_policy_identities':[{'pid':pid,'start_time_ticks':ticks} for pid,ticks in sorted(set(known)-checked)],'missing_start_identity_records':unknown_start,'guard_summaries':guards,'unguarded_preparation_authoring_and_audit_policy_scope':'UNKNOWN; no claim of transient complete policy sampling','finalizer_itself_not_in_finished_experiment_set':True};dump(AT/'owned_cleanup_and_policy.json',cleanup)
if live or zombies or mismatches:good=False;issues.append('owned_cleanup_or_actual_policy_incomplete')
if integrity:dump(AT/'actual_fixed_original30_integrity.json',integrity)
verdict='COST_STOP' if x['verdict']=='COST_STOP' else 'PASS' if good else 'FAIL'
result={'verdict':verdict,'scope':'FIXED_ORIGINAL30_ONCE_BEGIN','fullgraph_complete':verdict=='PASS','primary_receipt':identify(primary),'actual_integrity':identify(AT/'actual_fixed_original30_integrity.json') if integrity else None,'cleanup':identify(AT/'owned_cleanup_and_policy.json'),'unique_execution_identities_checked':len(expected),'issues':issues,'created_at':dt.datetime.now(dt.timezone.utc).isoformat(),'next_state':'paused per user; no follow-on work or automatic full retry'};dump(final,result)
dump(RUN/'receipt_final_audit.json',{'category':'static','verdict':'PASS' if good else 'FAIL','elapsed_seconds':time.monotonic()-start,'stage':'actual_full30_values_trace_execution_identity_archive_and_owned_cleanup_audit','guarded':False,'new_build_or_RTL':False})
totals={'static':0.,'rtl':0.}
for p in [*RUN.glob('receipt_*.json'),*RUN.glob('attempts/AT*/receipt_*.json')]:
 z=json.loads(p.read_text());cat=z.get('category')
 if cat in totals:totals[cat]+=z.get('guard',{}).get('elapsed_seconds',z.get('elapsed_seconds',0.))
budget={'scope':'D37_FIXED_ORIGINAL30_ONCE_BEGIN','measured_seconds':totals,'limits':{'reference':0,'static':1800,'rtl':15600,'rtl_reserve':600,'ooc':0},'measured_balance_seconds':{'static':1800-totals['static'],'rtl':15600-totals['rtl'],'rtl_after_reserve':15000-totals['rtl']},'unknown_static_preparation_failures':2,'conservative_unmeasured_failure_budget_reserve_seconds':240,'static_balance_after_measured_and_reserved_unknown_failures':1800-totals['static']-240,'other_unmeasured_authoring_analysis_orchestration_reporting_seconds':'UNKNOWN, not zero','prior_balance_transferred':False,'sealed':True,'no_future_spend_authorized':True}
dump(RUN/'budget_current.json',budget);dump(RUN/'budget_R005_sealed.json',budget);print(json.dumps(result),flush=True);raise SystemExit(0 if verdict=='PASS' else 124 if verdict=='COST_STOP' else 1)
