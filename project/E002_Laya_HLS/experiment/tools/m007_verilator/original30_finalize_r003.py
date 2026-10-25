#!/usr/bin/env python3
"""Merge primary guard and attached composite guard; never infer full PASS from one alone."""
import argparse,datetime as dt,hashlib,json
from pathlib import Path
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def proc(pid):
 try:
  z=(Path('/proc')/str(pid)/'stat').read_text().rsplit(')',1)[1].split();return z[0],int(z[19])
 except OSError:return None
p=argparse.ArgumentParser();p.add_argument('--attempt',required=True,type=Path);a=p.parse_args();at=a.attempt;out=at/'final_merged_receipt.json'
if out.exists():raise SystemExit('preserve actual final merged receipt')
primary=at/'receipt_rtl.json';extra=at/'additional_handoff_guard/result.json'
if not primary.exists():raise SystemExit('primary actual run not completed; no premature finalization')
x=json.loads(primary.read_text());e=json.loads(extra.read_text()) if extra.exists() else None
cost=x['verdict']=='COST_STOP' or (e and e['verdict']=='COST_STOP');good=x['verdict']=='PASS' and e and e['verdict']=='PASS';verdict='COST_STOP' if cost else 'PASS' if good else 'FAIL';issues=[]
if e is None:issues.append('additional_composite_guard_result_missing; full acceptance forbidden')
elif e['verdict']!='PASS':issues.append('additional_composite_guard:'+e['verdict']+':'+e['reason'])
if x['verdict']!='PASS':issues.append('primary_guard_or_driver:'+x['verdict'])
if good:
 try:
  d=x['driver_receipt'];assert d['fullgraph_complete'] and d['raw_child_return_code']==0 and not x['guard']['trigger'];assert d['completed_global_layers']==list(range(30));assert len(d['completed_stages'])==782;assert sum(z['stage'].startswith('head') for z in d['completed_stages'])==480;assert len(d['actual_output_integrity']['all30_actual_H_capture_integrity'])==30
  assert all(z['threads']==1 for z in d['actual_thread_samples']);assert max(z['duration_seconds'] for z in d['layer_records'])<=600;assert max(z['duration_seconds'] for z in d['completed_stages'])<=120;assert d['elapsed_seconds']<=15000
  events=e['events'];assert len(events)==4 and events[0]['line'].startswith('M007_FULLGRAPH_LAYER_END global=27 checkpoint=27 ');assert e['whole_handoff_event_seconds']<=120 and e['original_anchor_never_reset_by_intermediate_success'];assert events[0]['elapsed_s']==e['boundary_anchor_original_elapsed_s']
  assert 'global=27 state=91 ' in events[1]['line'] and 'global=27 state=96 ' in events[2]['line'] and 'global=28 state=86 ' in events[3]['line']
  for item in json.loads((at/'source_manifest.json').read_text())['sources_and_inputs']:
   assert hashlib.sha256(Path(item['path']).read_bytes()).hexdigest()==item['sha256'],'execution input changed '+item['path']
  assert identify(at/'frozen/original30_driver_r003.py')['sha256']==json.loads((at/'rtl_execution_identity.json').read_text())['driver']['sha256']
 except Exception as failure:verdict='FAIL';issues.append('final_invariant_or_identity:'+repr(failure))
known={};policies=[];unknown=set();mismatches=[]
for gpath in at.glob('guard_*/guard_result.json'):
 g=json.loads(gpath.read_text());pol=gpath.parent/'policy_checks.json';samples=json.loads(pol.read_text()) if pol.exists() else [];checked={(str(z['pid']),str(z['start_time_ticks'])) for z in samples}
 for z in g.get('observed_owned_identities',[]):
  key=(str(z['pid']),str(z['start_time_ticks']));known[key]=z
  if key not in checked:unknown.add(key)
 mismatches.extend(z for z in samples if not z.get('matches',False));policies.append({'guard':str(gpath),'observed_identities':len(g.get('observed_owned_identities',[])),'actually_policy_checked':len(checked)})
launch=at/'additional_handoff_guard/launch.json'
if launch.exists():
 z=json.loads(launch.read_text());key=(str(z['supervisor_pid']),str(z['supervisor_start_time_ticks']));known[key]={'pid':z['supervisor_pid'],'start_time_ticks':z['supervisor_start_time_ticks']}
 ep=at/'additional_handoff_guard/actual_policy_check.json'
 if not ep.exists():unknown.add(key)
 elif not json.loads(ep.read_text()).get('matches'):mismatches.append(json.loads(ep.read_text()))
watch=at/'live_watch.launch.json'
if watch.exists():
 z=json.loads(watch.read_text());key=(str(z['pid']),str(z['start_time_ticks']));known[key]={'pid':z['pid'],'start_time_ticks':z['start_time_ticks']}
 if z.get('nice')!=19 or z.get('affinity')!=[0,1,2,3] or z.get('ioprio_class')!=3:mismatches.append(z)
live=[];zombies=[]
for (pid,ticks),z in known.items():
 current=proc(pid)
 if not current or current[1]!=int(ticks):continue
 (zombies if current[0]=='Z' else live).append(z|{'state':current[0]})
if live or zombies or mismatches:
 verdict='FAIL' if verdict=='PASS' else verdict;issues.append('owned_cleanup_or_actual_policy_incomplete')
cleanup={'checked_at':dt.datetime.now(dt.timezone.utc).isoformat(),'known_identity_count':len(known),'remaining_live_owned_identities':live,'remaining_zombie_owned_identities':zombies,'mismatched_policy_samples':mismatches,'missing_policy_identities':[{'pid':int(pid),'start_time_ticks':ticks} for pid,ticks in sorted(unknown)],'guard_summaries':policies,'unmeasured_preparation_policy_scope':'UNKNOWN; source-identity read-only preparation not guarded; no heavy model build','finalizer_itself_not_in_finished_experiment_process_set':True};(at/'owned_cleanup_and_policy.json').write_text(json.dumps(cleanup,indent=2)+'\n')
result={'verdict':verdict,'fullgraph_complete':verdict=='PASS','primary_receipt':identify(primary),'primary_verdict':x['verdict'],'additional_composite_receipt':identify(extra) if extra.exists() else None,'additional_verdict':e['verdict'] if e else 'MISSING','all_original_and_both_supervisors_required':True,'issues':issues,'cleanup':identify(at/'owned_cleanup_and_policy.json'),'scope':'original30 normal path, same fixed-batch single-thread compiled backend; no four-state/physical/board/exceptional recovery acceptance','created_at':dt.datetime.now(dt.timezone.utc).isoformat()};out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));raise SystemExit(0 if verdict=='PASS' else 124 if verdict=='COST_STOP' else 1)
