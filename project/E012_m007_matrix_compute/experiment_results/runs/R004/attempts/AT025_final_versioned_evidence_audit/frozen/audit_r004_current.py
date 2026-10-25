#!/usr/bin/env python3
"""Audit immutable attempt closures and version-qualified F32 claims, not old reruns."""
import argparse,datetime as dt,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
root=a.root.resolve();run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R004'
limits={'reference':120.,'static':1200.,'rtl':2400.,'ooc':0.};used={k:0. for k in limits};verified={};attempts=[]
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
  assert cap<=600 and rss<={'reference':16,'static':24,'rtl':8,'ooc':24}[category]
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
  assert c['pilot_cycles']==pf['total_cycles'] and c.get('pilot_blocks',3)==pf['blocks'] and c['pilot_wall_s']==pr['wall_s']
  if 'pilot_blocks' not in c:assert at.name in ['AT022_current_complete_f32_qkv','AT023_current_complete_f32_wo'] and pf['blocks']==3  # older fixed-three-block cost schema
  for source in c['measured_cost_sources']:
   sd=Path(source['attempt']);sr=load(sd/'receipt_rtl.json');assert sr['verdict']=='PASS' and source['wall_s']==sr['wall_s']
   slog=(sd/'guard_rtl/driver.log').read_text();sm=re.search(r'M007_(?:F32_PREFIX|F32_MATRIX|FULL_MATRIX)_PASS .*?total_cycles=(\d+)',slog);assert sm
   assert source['total_cycles']==int(sm.group(1))
   assert abs(source['wall_s_per_cycle']-source['wall_s']/source['total_cycles'])<1e-12
   sha(sd/'receipt_rtl.json');sha(sd/'guard_rtl/driver.log')
  expected=max(x['wall_s_per_cycle'] for x in c['measured_cost_sources'])*c['projected_cycles']*1.35+10
  assert c['checker_and_data_safety_factor']==1.35 and abs(c['conservative_estimate_s']-expected)<1e-9
  admitted=c['conservative_estimate_s']<=min(c['requested_timeout_s'],600,c['remaining_rtl_s']-c['required_directed_reserve_s'])
  assert admitted==c['passed']
  if not admitted:assert r['verdict']=='COST_STOP' and wall==0 and 'guard' not in r
 attempts.append({'id':at.name,'category':category,'verdict':r['verdict'],'wall_s':wall,'receipt_sha256':sha(rp)})
for k,v in used.items():assert v<=limits[k],(k,v,limits[k])
# Immutable arithmetic and controller extraction identities.
baseline=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT018_f32_shared_div_idle_build'
build=run/'attempts/AT006_pure_response_error_build'
profile_off=run/'attempts/AT001_pure_production_build';profile_on=run/'attempts/AT003_profile_compatibility_build'
def dut(at):return sv_identity(at,rtl_only=True)
for at in [profile_off,profile_on,build,run/'attempts/AT009_real_producer_cancel_build',run/'attempts/AT017_live_close_observation_build']:
 assert load(at/'receipt_static.json')['verdict']=='PASS'
 assert dut(at)==dut(build)
for name,expected in [('laya_shared_fp256_v2.sv','80f91e30e26b7f23d84b6b1972335cce5c634b4a0e2fe20b7030e2b91d472230'),('laya_shared_div8_v1.sv','8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79'),('laya_m007_quant_group32_v1.sv','555ac5492af12929112d5f513538f205a1607021d602356083956c909e955add')]:checked(build/'frozen'/name,expected)
changed=[]
for f in (baseline/'frozen').glob('*.sv'):
 if (build/'frozen'/f.name).exists() and sha(f)!=sha(build/'frozen'/f.name):changed.append(f.name)
assert sorted(changed)==['laya_m007_matrix_f32_v1.sv','laya_m007_matrix_full_v1.sv','laya_m007_matrix_superblock_v1.sv']
engine=(build/'frozen/laya_m007_matrix_engine_v1.sv').read_text();facade=(build/'frozen/laya_m007_matrix_facade_v1.sv').read_text();resources=(build/'frozen/laya_m007_matrix_resources_v1.sv').read_text()
assert 'laya_shared_fp256_v2 fp(' not in engine+facade and 'laya_attention_storage_v1 storage(' not in engine+facade and 'laya_shared_div8_v1' not in engine+facade
assert resources.count('laya_shared_fp256_v2 fp(')==resources.count('laya_attention_storage_v1 storage(')==1
for name in ['laya_m007_matrix_full_v1.sv','laya_m007_matrix_superblock_v1.sv']:
 wrapper=(build/'frozen'/name).read_text();assert 'always_ff' not in wrapper and wrapper.count('laya_m007_matrix_resources_v1 resources(.*)')==1
# Exact sequential numerical/credit/error/retirement FSM, excluding removed telemetry only.
old=(baseline/'frozen/laya_m007_matrix_superblock_v1.sv').read_text();expected=old[old.index(' always_ff @(posedge clk)begin'):]
for token in ['issue_time[issue_count[5:0]]<=tick;','ps_time[ps_next[5:0]]<=tick;','max_issue_commit<=0;','max_ps_feedback<=0;']:expected=expected.replace(token,'')
for token in ['     if(tick-issue_time[ps_wr_rsp_tag[5:0]]>max_issue_commit)max_issue_commit<=tick-issue_time[ps_wr_rsp_tag[5:0]];\n','     if(tick-ps_time[ps_wr_rsp_tag[5:0]]>max_ps_feedback)max_ps_feedback<=tick-ps_time[ps_wr_rsp_tag[5:0]];\n']:expected=expected.replace(token,'')
actual=engine[engine.index(' always_ff @(posedge clk)begin',engine.index('end endgenerate')):]
assert re.sub(r'\s+','',expected)==re.sub(r'\s+','',actual),'extracted sequential FSM changed beyond telemetry'
expected=(baseline/'frozen/laya_m007_matrix_full_v1.sv').read_text().split(');\n',1)[1].replace('laya_m007_matrix_superblock_v1 core(', 'laya_m007_matrix_engine_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) core(')
assert expected==facade.split(');\n',1)[1],'facade body changed beyond pure instance substitution'
profile_block=engine[engine.index(' generate if(PROFILE_ENABLE)'):engine.index('end endgenerate')+len('end endgenerate')]
assert profile_block.count('logic [63:0][31:0] issue_time,ps_time;')==1 and 'issue_time' not in engine.replace(profile_block,'') and 'ps_time' not in engine.replace(profile_block,'')
assert "assign max_issue_commit=32'b0;assign max_ps_feedback=32'b0;" in profile_block and 'assign profile_valid=PROFILE_ENABLE;' in engine
for at,enabled in [(profile_off,False),(profile_on,True),(build,False)]:
 assert load(at/'source_manifest.json')['profile_enabled_build'] is enabled
 script=at/'work/build.sh';assert '-generic_top PROFILE_ENABLE='+str(int(enabled)) in script.read_text();sha(script)
# Exact profile-off/on actual observation equivalence.
def fields(line):return {k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)}
profile=[]
for name,enabled in [('AT002_pure_production_qkv3',0),('AT004_profile_compatibility_qkv3',1)]:
 at=run/'attempts'/name;assert load(at/'receipt_rtl.json')['verdict']=='PASS';log=(at/'guard_rtl/driver.log').read_text()
 f=fields(re.search(r'M007_F32_PREFIX_PASS .*',log).group(0));assert f['case']==0 and f['blocks']==3
 observation=fields(re.search(r'M007_PURE_PROFILE_OBSERVATION .*',log).group(0));assert observation=={'enabled':enabled,'profile_valid':enabled,'passive_issue_to_ack':31,'passive_actual_PS_feedback':13}
 profile.append({'attempt':name,'fields':f,'observation':observation})
assert profile[0]['fields']==profile[1]['fields']
# Original all128 local-reference context -> actual quant/A -> complete WO.
at=run/'attempts/AT008_complete_real_context_wo';assert load(at/'receipt_rtl.json')['verdict']=='PASS';log=(at/'guard_rtl/driver.log').read_text();f=fields(re.search(r'M007_F32_MATRIX_PASS .*',log).group(0));assert f['case']==1 and f['K']==f['N']==1024 and f['blocks']==16 and f['final_values']==131072 and f['f32_cycles']==22129<=22528 and f['real_inputs']==f['real_Awrites']==f['real_Aacks']==4096
assert [int(v) for v in re.findall(r'MATRIX_PROGRESS real_retired_s=(\d+)',log)]==list(range(16))
for i,line in enumerate(re.findall(r'M007_F32_BLOCK_PASS .*',log)):
 b=fields(line);assert b['s']==i and b['issue_span']==1024 and b['gap_from_previous']==(0 if i==0 else 35)
fixture=run/'attempts/AT005_original_context_wo_fixture/work/fixture/wo_0_weight';meta=load(fixture/'fixture.json');assert meta['original_model_real_rows']==list(range(128)) and not meta['diagnostic_rows'] and not meta['gold_recomputed']
checked(fixture/'source_f32.bin','aca5d09a7576509008648256fa271af8e809e04af2c0ead843eef9f5c5468cd4');checked(fixture/'expected_f32.bin','1527544ebbc58548cacd152ba0a98fe679332fc83d651f3c2ffed15b4eca19dc')
assert load(at/'cost_gate.json')['required_directed_reserve_s']>=240
old_fixture=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture/wo_0_weight'
for name in ['original_weight_q8.bin','bias.hex']+[f'p{pp}.{suffix}' for pp in range(4) for suffix in ['bin','hex']]:checked(fixture/name,sha(old_fixture/name))
source_bytes=(fixture/'source_f32.bin').read_bytes();gold_bytes=(fixture/'expected_f32.bin').read_bytes();quant_bytes=(fixture/'activation_q8.bin').read_bytes()
assert (fixture/'input.hex').read_text().splitlines()==[source_bytes[j:j+128][::-1].hex() for j in range(0,len(source_bytes),128)]
assert (fixture/'a_write.hex').read_text().splitlines()==[(quant_bytes[j+2:j+34]+quant_bytes[j:j+2])[::-1].hex() for j in range(0,len(quant_bytes),34)]
expected_output=[];expected_pre=[]
for ss in range(16):
 for rr in range(128):
  for hh in range(2):
   begin=4*(1024*rr+64*ss+32*hh);expected_output.append(gold_bytes[begin:begin+128][::-1].hex())
 for pp in range(4):
  for mm in range(8):
   vector=b''.join(gold_bytes[4*(1024*(16*mm+aa)+64*ss+16*pp):4*(1024*(16*mm+aa)+64*ss+16*pp+16)] for aa in range(16));expected_pre.append(vector[::-1].hex())
assert (fixture/'output.hex').read_text().splitlines()==expected_output and (fixture/'pre_bias.hex').read_text().splitlines()==expected_pre
# Actual physical A cancellation, all accepted work and no-reset recovery.
for name,live in [('AT010_real_producer_cancel_recovery',False),('AT018_actual_DIV_live_producer_close',True)]:
 at=run/'attempts'/name;assert load(at/'receipt_rtl.json')['verdict']=='PASS';log=(at/'guard_rtl/driver.log').read_text();cases=[fields(v) for v in re.findall(r'M007_PURE_PRODUCER_CLOSE_PASS .*',log)];recoveries=[fields(v) for v in re.findall(r'M007_PURE_PRODUCER_RECOVERY_PASS .*',log)]
 assert len(cases)==len(recoveries)==3
 for i,c in enumerate(cases):
  assert c['mode']==i and c['accepted_groups']==c['quant_returns']==(0 if i==0 else 117) and c['real_A_writes']==c['real_A_acks']==(0 if i==0 else 32) and c['accepted_on_close_edge']==(1 if i==1 else 0) and c['real_cancel_held']==8 and c['old_A_slot_invalid']==1
 for c in recoveries:assert c['actual_inputs']==c['actual_quant_returns']==c['real_A_writes']==c['real_A_acks']==4096 and c['actual_publications']==1 and c['public_read_verified']==1
 if live:
  observations=[fields(v) for v in re.findall(r'M007_PURE_PRODUCER_LIVE_CLOSE .*',log)];assert len(observations)==3
  for c in observations[1:]:assert c['quant_reservations']>0 and c['actual_DIV_vectors']+c['actual_DIV_pending']>0 and c['actual_DIV_scalars']>0
  assert observations[1]['same_edge_input_fire']==1 and observations[2]['held_physical_A_ack']==1 and observations[2]['actual_A_write_debt']>0
# Required affected scope can name a later honest repair attempt without rewriting failures.
accepted=load(run/'accepted_evidence_map.json')
for scope,name in accepted.items():
 at=run/'attempts'/name;assert load(at/'receipt_rtl.json')['verdict']=='PASS';log=(at/'guard_rtl/driver.log').read_text();pf=fields(re.search(r'M007_F32_PREFIX_PASS .*',log).group(0))
 if scope=='down':assert pf['case']==3 and pf['blocks']==2 and pf['real_inputs']==10496
 elif scope=='decision_bias':assert pf['case']==7 and pf['blocks']==3 and 'M007_F32_BIAS_OVERLAP_PASS actual_bias_ack_new_issue=87' in log
 elif scope=='K4096_bias':assert pf['case']==5 and pf['blocks']==1 and pf['real_inputs']==16384
 elif scope=='matrix_error_recovery':assert 'M007_PURE_MATRIX_ERROR_RELEASE_PASS real_RRESP_errors=1' in log and pf['case']==1 and pf['blocks']==3
 elif scope=='held_PS_bias':assert pf['case']==4 and pf['blocks']==3 and 'M007_F32_STRESS_PASS' in log
 elif scope=='held_quant_A_ack':assert pf['case']==0 and pf['blocks']==3
 else:raise AssertionError(('unknown accepted scope',scope))
assert set(accepted)=={'down','decision_bias','K4096_bias','matrix_error_recovery','held_PS_bias','held_quant_A_ack'}
# Explicit same-budget consumer migration, preserving all old-FP claims.
selection=load(run/'fp_migration_selection.json');new_sha='f4508add0e4fccd60314359a2a5fc0a8fa29530d209b92901e9bef5d413232d0';assert selection['selected_FP_sha256']==new_sha
checked(root/selection['selected_source'],new_sha)
for receipt in selection['A007_validation_receipts']:
 checked(root/receipt['path'],receipt['sha256']);assert receipt['verdict']=='PASS' and load(root/receipt['path'])['verdict']=='PASS'
sha(run/'old_FP_phase_boundary.json');sha(run/'fp_migration_selection.json')
new_build=run/'attempts/AT019_new_FP_consumer_build';assert load(new_build/'receipt_static.json')['verdict']=='PASS';nm=load(new_build/'source_manifest.json');assert nm['selected_sharedFP_sha256']==nm['requested_sharedFP_sha256']==new_sha and Path(nm['explicit_sharedFP_source']).resolve()==(root/selection['selected_source']).resolve()
checked(new_build/'frozen/laya_shared_fp256_v2.sv',new_sha);checked(new_build/'frozen/laya_shared_div8_v1.sv','8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79')
new_changes=[f.name for f in (build/'frozen').glob('*.sv') if sha(f)!=sha(new_build/'frozen'/f.name)];assert new_changes==['laya_shared_fp256_v2.sv'],new_changes
new_results=[];new_full=None;terminal_cost=False
for name,case,stress,prefix in [('AT020_new_FP_qkv3',0,0,3),('AT021_new_FP_error_release_recovery',1,9,3),('AT022_new_FP_bias_PS_output_holds',4,1,3),('AT023_new_FP_real_context_wo3',1,0,3),('AT024_new_FP_complete_real_context_wo',1,0,0)]:
 at=run/'attempts'/name;rp=at/'receipt_rtl.json'
 if not rp.exists():
  assert terminal_cost,('missing authorized migration exit',name);new_results.append({'attempt':name,'verdict':'NOT_RUN_after_actual_cost_exit'});continue
 receipt=load(rp);assert receipt['verdict'] in ('PASS','COST_STOP'),(name,receipt['verdict'])
 if receipt['verdict']=='COST_STOP':terminal_cost=True;new_results.append({'attempt':name,'verdict':'COST_STOP','wall_s':receipt['wall_s']});continue
 ident=load(at/'fixture_identity.json');checked(new_build/'source_manifest.json',ident['build_source_manifest_sha256']);assert sv_identity(at)==sv_identity(new_build)
 log=(at/'guard_rtl/driver.log').read_text();marker='M007_F32_PREFIX_PASS' if prefix else 'M007_F32_MATRIX_PASS';sf=fields(re.search(marker+r' .*',log).group(0));assert sf['case']==case and sf['blocks']==(prefix if prefix else 16) and sf['real_inputs']==sf['real_Awrites']==sf['real_Aacks']==4096
 observation=fields(re.search(r'M007_PURE_PROFILE_OBSERVATION .*',log).group(0));assert observation['enabled']==observation['profile_valid']==0
 if stress==0:assert observation['passive_issue_to_ack']<=64 and observation['passive_actual_PS_feedback']<=24
 if stress==9:
  error=fields(re.search(r'M007_PURE_MATRIX_ERROR_RELEASE_PASS .*',log).group(0));assert error['real_RRESP_errors']==1 and error['actual_issues']==error['actual_PS_acks']>0 and error['output_before_failure']==0 and error['actual_FP_PS_A_W_released']==1
 if stress==1:assert 'M007_F32_STRESS_PASS' in log
 if prefix==0:
  assert sf['final_values']==131072 and sf['f32_cycles']<=22528 and load(at/'cost_gate.json')['required_directed_reserve_s']>=240
  assert [int(v) for v in re.findall(r'MATRIX_PROGRESS real_retired_s=(\d+)',log)]==list(range(16));new_full=sf
 new_results.append({'attempt':name,'verdict':'PASS','wall_s':receipt['wall_s'],'fields':sf,'profile_observation':observation})
sha(run/'fp_migration_status.json')
report={'audit_time':dt.datetime.now(dt.timezone.utc).isoformat(),'verdict':'PASS_SCOPED_PURE_EXTRACTION_REAL_CONTEXT_AND_CANCEL','unique_files_verified':len(verified),'files':verified,'limits_s':limits,'used_before_audit_charge_s':used,'remaining_before_audit_charge_s':{k:limits[k]-used[k] for k in limits},'attempts':attempts,'old_frozen_sharedFP':'80f91e30e26b7f23d84b6b1972335cce5c634b4a0e2fe20b7030e2b91d472230','explicit_new_sharedFP':new_sha,'new_FP_only_SV_change':new_changes,'new_FP_actual_results':new_results,'new_FP_complete_real_context_WO':new_full,'frozen_sharedDIV':'8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79','old_existing_SV_changed':changed,'controller_FSM_only_telemetry_removed':True,'facade_body_only_pure_instance_substitution':True,'profile_equivalence':profile,'old_FP_complete_real_context_WO':f,'affected_actual_scope':accepted,'control_storage_bytes':{'persistent_module_rounded':929,'with_same_cycle_scratch_allowance':955,'conservative_agreed512_only_reduction_allocation':963,'profile_on_extra':520,'joint4KiB_fit':False},'limitations':'Local original-reference context input, not hardware Attention output. Full parent/global original matrix first-error/physical synthesis-route300MHz/HBM-CDC/board/full-model remain unverified. Original producer error cause remains parent-owned; pure close tests validate control-interface termination, not complete G parent error propagation. Fixed numerical per-lane tag storage stays in separate physical declaration account.'}
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(report,indent=2)+'\n');print('M007_R004_AUDIT_PASS unique_files='+str(len(verified)))
