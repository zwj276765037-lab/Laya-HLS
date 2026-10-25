#!/usr/bin/env python3
"""Audit immutable attempt closures and version-qualified F32 claims, not old reruns."""
import argparse,datetime as dt,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
root=a.root.resolve();run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003'
limits={'reference':900.,'static':1800.,'rtl':4800.,'ooc':600.};used={k:0. for k in limits};verified={};attempts=[]
def sha(f):
 f=Path(f).resolve()
 if str(f) not in verified:
  verified[str(f)]=hashlib.sha256(f.read_bytes()).hexdigest()
 return verified[str(f)]
def checked(f,expected):
 actual=sha(f)
 assert actual==expected,(str(f),actual,expected)
 return actual
def load(f):return json.loads(Path(f).read_text())
def sv_identity(at,rtl_only=False):return {e['path']:e['sha256'] for e in load(Path(at)/'source_manifest.json')['sources'] if e['path'].endswith('.sv') and (not rtl_only or '/rtl/' in e['path'])}
for rp in sorted((run/'attempts').glob('*/receipt_*.json')):
 at=rp.parent;r=load(rp);category=r['category'];wall=float(r['wall_s']);assert category in limits and wall>=0
 used[category]+=wall
 manifest=at/'source_manifest.json'
 if manifest.exists():
  for s in load(manifest)['sources']:checked(at/'frozen'/s['frozen'],s['sha256'])
 if 'guard' in r:
  g=r['guard'];assert abs(float(g['elapsed_seconds'])-wall)<1e-6
  gd=at/('guard_'+category);checked(gd/'driver.log',r['driver_sha256'])
  command=load(at/('command_'+category+'.json'));assert command['lock_held_through_children'] is True
  argv=command['argv'];cap=float(argv[argv.index('--timeout-seconds')+1]);rss=float(argv[argv.index('--rss-gib')+1]);stall=float(argv[argv.index('--semantic-stall-seconds')+1]);assert stall==120
  assert cap<=(1200 if category=='rtl' else 600) and rss<={'reference':16,'static':24,'rtl':8,'ooc':24}[category]
  if r['verdict']=='PASS':
   assert not g['trigger'] and r['guard_exit']==0 and g['child_exit_code']==0 and not r['error_or_fatal']
   assert not r['required_marker'] or r['marker_found']
  assert load(gd/'guard_result.json')==g
  plan=load(gd/'guard_plan.json');assert plan['selected_cpu_ids']==[0,1,2,3] and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']>=192*1024*1024
  assert plan['maximum_owned_rss_kb']==int(rss*1024*1024) and plan['maximum_seconds']==cap
  assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in load(gd/'policy_checks.json'))
  if r['verdict']=='PASS':assert g['minimum_mem_available_kb']>=192*1024*1024 and g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb']
  sha(gd/'guard_result.json');sha(gd/'guard_plan.json');sha(gd/'policy_checks.json')
 elif wall!=0:raise AssertionError('charged attempt has no actual guard')
 fi=at/'fixture_identity.json'
 if fi.exists():
  identity=load(fi);build=Path(identity['build']);checked(build/'source_manifest.json',identity['build_source_manifest_sha256'])
  for s in (at/'frozen').glob('*.sv'):checked(s,sha(build/'frozen'/s.name))
  for f in identity['files']:checked(Path(f['path']),f['sha256'])
  for f in identity['snapshot_files']:checked(at/'work'/f['path'],f['sha256'])
 cost=at/'cost_gate.json'
 if cost.exists():
  c=load(cost);assert c['required_directed_reserve_s']>=0
  pilot=Path(c['pilot']);pr=load(pilot/'receipt_rtl.json');assert pr['verdict']=='PASS'
  checked(pilot/'receipt_rtl.json',c['pilot_receipt_sha256'])
  pi=load(pilot/'fixture_identity.json');checked(Path(pi['build'])/'source_manifest.json',pi['build_source_manifest_sha256'])
  assert sv_identity(at)==sv_identity(pi['build']),('cost gate pilot build mismatch',at)
  plog=(pilot/'guard_rtl/driver.log').read_text();pm=re.search(r'M007_F32_PREFIX_PASS .*',plog);assert pm
  pf={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',pm.group(0))}
  assert c['pilot_cycles']==pf['total_cycles'] and c['pilot_blocks']==pf['blocks'] and c['pilot_wall_s']==pr['wall_s']
  for source in c['measured_cost_sources']:
   sd=Path(source['attempt']);sr=load(sd/'receipt_rtl.json');assert sr['verdict']=='PASS' and source['wall_s']==sr['wall_s']
   slog=(sd/'guard_rtl/driver.log').read_text();sm=re.search(r'M007_(?:F32_PREFIX|F32_MATRIX|FULL_MATRIX)_PASS .*?total_cycles=(\d+)',slog);assert sm
   assert source['total_cycles']==int(sm.group(1))
   assert abs(source['wall_s_per_cycle']-source['wall_s']/source['total_cycles'])<1e-12
   sha(sd/'receipt_rtl.json');sha(sd/'guard_rtl/driver.log')
  expected=max(x['wall_s_per_cycle'] for x in c['measured_cost_sources'])*c['projected_cycles']*1.35+10
  assert c['checker_and_data_safety_factor']==1.35 and abs(c['conservative_estimate_s']-expected)<1e-9
  admitted=c['conservative_estimate_s']<=min(c['requested_timeout_s'],1200,c['remaining_rtl_s']-c['required_directed_reserve_s'])
  assert admitted==c['passed']
  if not admitted:assert r['verdict']=='COST_STOP' and wall==0 and 'guard' not in r
 attempts.append({'id':at.name,'category':category,'verdict':r['verdict'],'wall_s':wall,'receipt_sha256':sha(rp)})
for k,v in used.items():assert v<=limits[k],(k,v,limits[k])
# Source identities qualify inheritance; no old audit is rerun against new working source.
build=run/'attempts/AT018_f32_shared_div_idle_build'
base=run/'attempts/AT006_f32_shell_build'
assert load(build/'receipt_static.json')['verdict']=='PASS'
changed=[]
for f in (build/'frozen').glob('*.sv'):
 if not (base/'frozen'/f.name).exists() or sha(f)!=sha(base/'frozen'/f.name):changed.append(f.name)
assert sorted(changed)==['laya_shared_div8_v1.sv','m007_matrix_f32_tb.sv'],changed
checked(build/'frozen/laya_m007_quant_group32_v1.sv','555ac5492af12929112d5f513538f205a1607021d602356083956c909e955add')
checked(build/'frozen/laya_m007_matrix_superblock_v1.sv','c13b2f8bf601631c33b206b42f57f6060889c2a26d507aa8cdd52a9da966c349')
checked(build/'frozen/laya_shared_div8_v1.sv','8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79')
checked(build/'frozen/laya_shared_fp256_v2.sv','80f91e30e26b7f23d84b6b1972335cce5c634b4a0e2fe20b7030e2b91d472230')
# Stronger observation builds import exact immutable DUT bytes, not the evolving shared owner source.
strong=run/'attempts/AT024_stronger_observation_build'
assert load(strong/'receipt_static.json')['verdict']=='PASS'
def dut_manifest(at):return sv_identity(at,rtl_only=True)
assert dut_manifest(strong)==dut_manifest(build)
strong_changes=[f.name for f in (strong/'frozen').glob('*.sv') if sha(f)!=sha(build/'frozen'/f.name)]
assert strong_changes==['m007_matrix_f32_tb.sv'],strong_changes
strong_tb=(strong/'frozen/m007_matrix_f32_tb.sv').read_text()
assert 'logic [189:0] held' in strong_tb or 'logic [189:0] snapshot' in strong_tb
# Every accepted current full claim must have actually completed all independent checks.
full=[];remaining=[]
shape_attempts=[('AT022_current_complete_f32_qkv',0,1024,3072,57344),('AT023_current_complete_f32_wo',1,1024,1024,22528),('AT028_current_full_wi_cost_gate',2,1024,5248,92160),('AT030_current_complete_f32_down',3,2624,1024,56576),('AT032_current_complete_f32_fc1',4,1024,4096,73728),('AT036_current_complete_f32_fc2',5,4096,1024,86016)]
for attempt,case,K,N,cap in shape_attempts:
 at=run/'attempts'/attempt;rp=at/'receipt_rtl.json'
 if not rp.exists() and case==5:
  replan=load(run/'fc2_pilot_replan_status.json');assert any(x['attempt']==attempt and x['verdict']=='NOT_RUN' for x in replan)
  remaining.append({'attempt':attempt,'case':case,'verdict':'NOT_RUN','reason':'bounded FC2 pilot did not pass; no full attempt fabricated'});continue
 assert rp.exists(),('missing authorized shape exit',attempt)
 r=load(rp)
 if r['verdict']!='PASS':
  assert case>=2 and r['verdict']=='COST_STOP',('not a completed full or declared cost exit',attempt,r['verdict'])
  remaining.append({'attempt':attempt,'case':case,'verdict':r['verdict'],'wall_s':r['wall_s'],'reason':r.get('reason'),'cost_gate':load(at/'cost_gate.json') if (at/'cost_gate.json').exists() else None})
  continue
 assert dut_manifest(Path(load(at/'fixture_identity.json')['build']))==dut_manifest(build)
 log=(at/'guard_rtl/driver.log').read_text();m=re.search(r'M007_F32_MATRIX_PASS .*',log);assert m
 fields={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',m.group(0))}
 assert fields['case']==case and fields['K']==K and fields['N']==N and fields['final_values']==128*N and fields['f32_cycles']<=cap
 assert fields['real_inputs']==fields['real_Awrites']==fields['real_Aacks']==128*(K//32)
 assert fields['blocks']==N//64
 block_lines=re.findall(r'M007_F32_BLOCK_PASS .*',log);assert len(block_lines)==N//64
 for i,line in enumerate(block_lines):
  bf={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)}
  assert bf['s']==i and bf['issue_span']==K and bf['gap_from_previous']==(0 if i==0 else 35)
  if case in (4,5):assert bf['bias_read']==bf['bias_add']==bf['bias_ack']==32
 real_retired=re.findall(r'MATRIX_PROGRESS real_retired_s=(\d+)',log)
 assert [int(x) for x in real_retired]==list(range(N//64))
 full.append({'attempt':attempt,**fields,'cap':cap,'MAC_per_joint_service_cycle':128*K*N/fields['f32_cycles'],'compiled_manifest_sha256':load(at/'fixture_identity.json')['build_source_manifest_sha256']})
for attempt in ['AT003_a_cancel_directed','AT008_f32_qkv_pilot','AT009_f32_wi_handoff_pilot','AT011_f32_decision_wo_bias_pilot','AT012_failed_publication_peer','AT013_global_inverse_error_recovery','AT014_global_input_error_recovery','AT015_last_quant_and_A_ack_hold','AT016_input_identity_order_reject','AT017_quant_inflight_reset_recovery','AT019_current_div_release_idle_recovery','AT020_current_f32_qkv_pilot','AT021_current_f32_wo_bias_pilot','AT025_quant_response_full_hold','AT026_full_input_identity_reject','AT027_current_wi_pilot','AT029_current_down_pilot','AT031_current_fc1_bias_pilot']:
 assert load(run/'attempts'/attempt/'receipt_rtl.json')['verdict']=='PASS'
hold_log=(run/'attempts/AT025_quant_response_full_hold/guard_rtl/driver.log').read_text()
assert 'mode=7 phase=1 row=127 group=31 elem=17 actual_inputs=4096 retired=4096 real_A_writes=1 real_A_acks=1 zero_W_AR=1 zero_matrix=1 scale_divisions=4095 inverse_divisions=4094' in hold_log
div_observation=re.search(r'M007_F32_DIV_GATE_OBSERVATION actual_idle_clocks=(\d+) new_epoch_handoffs=(\d+) active_leaf_pause=0',hold_log);assert div_observation and int(div_observation.group(1))>0 and int(div_observation.group(2))==1
for attempt in ['AT025_quant_response_full_hold','AT026_full_input_identity_reject','AT027_current_wi_pilot','AT029_current_down_pilot','AT031_current_fc1_bias_pilot']:
 ident=load(run/'attempts'/attempt/'fixture_identity.json');checked(strong/'source_manifest.json',ident['build_source_manifest_sha256'])
for attempt,blocks in [('AT029_current_down_pilot',2)]:
 log=(run/'attempts'/attempt/'guard_rtl/driver.log').read_text();assert re.search(r'M007_F32_PREFIX_PASS .*?blocks='+str(blocks)+r' ',log)
fc2_old=run/'attempts/AT033_current_fc2_bias_pilot';fc2_old_receipt=load(fc2_old/'receipt_rtl.json')
assert fc2_old_receipt['verdict']=='COST_STOP' and fc2_old_receipt['guard']['trigger']=='timeout'
assert re.search(r'MATRIX_PROGRESS real_retired_s=0 .*actual_commits=4096 bias_acks=32', (fc2_old/'guard_rtl/driver.log').read_text())
fc2_single=run/'attempts/AT035_current_fc2_bias_single_pilot';fc2_single_receipt=load(fc2_single/'receipt_rtl.json')
assert fc2_single_receipt['verdict'] in ('PASS','COST_STOP')
if fc2_single_receipt['verdict']=='PASS':
 sf=(fc2_single/'guard_rtl/driver.log').read_text();assert re.search(r'M007_F32_PREFIX_PASS case=5 blocks=1 ',sf)
 assert load(fc2_single/'fixture_identity.json')['build_source_manifest_sha256']==sha(strong/'source_manifest.json')
report={'audit_time':dt.datetime.now(dt.timezone.utc).isoformat(),'verdict':'PASS_SCOPED_VERSIONED_EVIDENCE','unique_files_verified':len(verified),'files':verified,'limits_s':limits,'used_before_audit_charge_s':used,'remaining_before_audit_charge_s':{k:limits[k]-used[k] for k in limits},'attempts':attempts,'current_full_F32_claims':full,'remaining_shape_cost_exits':remaining,'FC2_original_two_block_pilot':{'verdict':fc2_old_receipt['verdict'],'wall_s':fc2_old_receipt['wall_s'],'one_real_block_retired_before_timeout':True},'FC2_bounded_single_block_pilot':{'verdict':fc2_single_receipt['verdict'],'wall_s':fc2_single_receipt['wall_s']},'original_AT034_full':'NOT_RUN because AT033 two-block pilot timed out; no attempt created','stronger_observation_build':str(strong),'stronger_build_changed_SV':strong_changes,'current_build':str(build),'old_main_build':str(base),'current_DIV_changed_from_old':changed,'prior_directed_scope':'Old AT006 DIV source; own matrix/quant/A bytes identical. AT018 actual phase5 release/idle/new-epoch recovery and full QKV/WO validate new DIV boundary. Peer AT012 has no real A cache. AT024/025 explicitly add full190-bit F32 adapter done tuple hold and actual DIV counts/idle observation; older held done scope is only each frozen TB assertion. Original graph Check is outside this adapter proof.','prior_R002':'Frozen R002 final audit/publication inherited only by explicit unchanged component identities; no R002 budget transfer or new execution claim.','limitations':'Functional simulation only. Whole graph/full model, global matrix original-first-error, physical synthesis/route/300MHz/HBM/CDC/board are not established.'}
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(report,indent=2)+'\n')
print('M007_R003_AUDIT_PASS unique_files='+str(len(verified)))
