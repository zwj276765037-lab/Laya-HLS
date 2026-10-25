from pathlib import Path
import argparse,hashlib,json
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'project/E019_m007_residual_ln_residency';RUN=E/'experiment_results/runs/R002';A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--hierarchy',type=Path);p.add_argument('--vector-parameter',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
checks=[]
def check(name,yes):
 assert yes,name
 checks.append(name)
base=read(RUN/'input_identity.json')
for n,h in base['preserved_source_sha256'].items():check('preserved '+n,sha(ROOT/n)==h)
bundle=read(RUN/'production_bundle_checkpoint_v1.json')
for n,h in bundle['source_sha256'].items():check('current checkpoint '+n,sha(ROOT/n)==h)
pilot=ROOT/bundle['pilot_receipt'];pr=read(pilot);report=ROOT/bundle['pilot_report'];pm=read(report)
check('actual pilot EXIT_ZERO',pr['status']=='EXIT_ZERO'and not pr['owned_after_cleanup']and not pr['owned_group_after_cleanup_exists'])
check('actual source-bound pilot report',sha(report)==bundle['pilot_report_sha256']and pm['scope']=='JOINT_RESIDUAL_LN_16_PASS')
check('real main data and final return',pm['metrics']['residual_vectors']==4096 and pm['metrics']['ln_vectors']==512 and pm['metrics']['switches']==5 and pm['metrics']['g_fp_nodes']>0 and pm['metrics']['g_tanh_nodes']>0)
# Existing independent fixture identity, with no reference recomputation.
rf=read(E/'experiment_results/runs/R001/attempts/AT001_original_residual_fixture/work/report.json')
gf=read(ROOT/'project/E014_m007_layernorm32/experiment_results/runs/R001/attempts/AT001_original_ln_reference/fixture/report.json')
expected={n:rf['products'][n]['hex_sha256']for n in ['H','Q','GOLD']}
expected.update(NORM='6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863',GRAW=gf['files']['gamma_encoder27/raw.hex']['sha256'],GGOLD=gf['files']['gamma_encoder27/output.hex']['sha256'],GAMMA=gf['files']['gamma.hex']['sha256'])
for at,scope in [('AT010_retired_A_return_real_LN16','JOINT_RESIDUAL_LN_16_PASS'),('AT011_actual_cross_owner_gamma_reuse','JOINT_GAMMA_REUSE_PASS'),('AT012_public_NaN_newgen_full_recovery','JOINT_NAN_RECOVERY_PASS')]:
 d=read(RUN/'attempts'/at/'work/report.json');fi=read(RUN/'attempts'/at/'work/fixture_identity.json')
 check('actual scenario '+at,d['status']=='PASS'and d['scope']==scope and sha(RUN/'attempts'/at/'work/fixture_identity.json')==d['fixture_identity_sha256'])
 for n,h in expected.items():check('original checker/input '+at+' '+n,fi['files'][n]['sha256']==h)
# Supplementary results remain separate actual runtimes and bound to unchanged production.
hold_at='AT016_legal_FP_DIV_held17_and_inactive';hr=read(RUN/'attempts'/hold_at/'receipt.json');hm=read(RUN/'attempts'/hold_at/'work/report.json')
check('actual FP/DIV held17 runtime',hr['status']=='EXIT_ZERO'and hm['status']=='PASS'and hm['scope']=='REAL_JOINT_FP_DIV_HELD17_AND_INACTIVE_PUBLIC')
check('actual FP/DIV held17 metrics',all(x in hm['result_marker']for x in ['checked=257','fp_held17=17','div_held17=17','real_release=2','inactive_zero_accept=1']))
for mode,at in [(2,'AT018_vector_normal_equivalence'),(3,'AT019_vector_finalH_held17_equivalence'),(4,'AT022_vector_NaN_equivalence_actual_progress')]:
 er=read(RUN/'attempts'/at/'receipt.json');em=read(RUN/'attempts'/at/'work/report.json');eq=em['equivalence_metrics']
 check('actual VECTOR runtime '+str(mode),er['status']=='EXIT_ZERO'and em['status']=='PASS'and em['mode']==mode)
 check('actual VECTOR semantic events '+str(mode),er['semantic_progress']['event_count']>0)
 eb='AT021_vector_NaN_actual_progress_build'if mode==4 else'AT017_vector_three_version_equivalence_build'
 check('actual VECTOR build identity '+str(mode),em['build_manifest_sha256']==sha(RUN/'attempts'/eb/'work/report.json'))
 check('actual VECTOR guarded retirement difference '+str(mode),eq['retired_guard_cycles']>0 and eq['local_control_bits']==48 and eq['external_shadow_bits']==0 and eq['inactive_foreign_q']==1)
 check('VECTOR original fixture '+str(mode),em['fixture_report_sha256']==sha(E/'experiment_results/runs/R001/attempts/AT001_original_residual_fixture/work/report.json'))
 if mode==3:check('actual finalH held17',em['metrics']['external_write_held']==17 and em['metrics']['commits']==4096)
 if mode==4:check('actual NaN original logical first error',em['metrics']['status']==6)
lnm=read(ROOT/bundle['LN_verified_manifest'])
check('LN verified manifest identity',sha(ROOT/bundle['LN_verified_manifest'])==bundle['LN_verified_manifest_sha256'])
for n,h in lnm['source_sha256'].items():check('actual verified LN dependency '+n,sha(ROOT/'project/E002_Laya_HLS/experiment'/n)==h)
check('public header identity',sha(A/'rtl/laya_m007_resident_joint_v2_header.svh')==bundle['header_sha256'])
w=(A/'rtl/laya_m007_resident_joint_v2.sv').read_text();j=(A/'rtl/laya_m007_control_workspace_joint_v2.sv').read_text();v=(A/'rtl/laya_m007_resident_vector32_v2.sv').read_text();l=(A/'rtl/laya_m007_resident_ln32_v1.sv').read_text();ws=(A/'rtl/laya_m007_control_workspace_v2.sv').read_text()
check('wrapper no sequential block','always_ff'not in w and 'always @'not in w and 'always@'not in w)
for module,inst in [('laya_m007_control_workspace_joint_v2','joint'),('laya_attention_resources_v1','resources'),('laya_m007_hidden32_v1','hidden'),('laya_m007_qscratch32_v1','scratch'),('laya_m007_resident_ln32_v1','ln_provider'),('laya_rope_coeff_cache_v1','coeff'),('laya_m007_g_vector_pool_v1','g_pool'),('laya_m007_tanh8_v1','g_tanh')]:check('single declaration '+module,w.count(' '+module+' '+inst+'(')==1)
check('no embedded old arena composition','laya_m007_control_workspace_joint_v1'not in w+j)
check('one arena in pure composition',j.count(')workspace(')==1)
check('actual LN12128 override','LN_CONTROL_BITS=12128'in j and '.LN_CONTROL_BITS(LN_CONTROL_BITS)'in j and 'ln_next[LN_CONTROL_BITS-1:0]'in ws)
check('LN public admission symmetric','assign p_start_valid=resident_ln_start_valid&&resident_owner_valid&&scratch_owner_active;'in w and 'assign resident_ln_start_ready=resident_owner_valid&&scratch_owner_active&&p_start_ready;'in w)
for n in ['res_fp_lease_ready','res_st_bind_ready']:check('A actual q-independent readiness '+n,'assign a_'+n+'=r_'+n+';'in w)
check('external ready stays selected','assign ext_res_fp_lease_ready=ext_allowed&&ext_fp_select?r_res_fp_lease_ready:'in w)
check('actual finite source witness','vector_done_status==0&&vector_issued_vectors==4096&&vector_retired_vectors==4096&&h_bank_idle&&!raw_h_wr_valid'in w and 'p_source_success_valid=vsource'in w)
check('provider borrows identity no assignments','owner_request_id<='not in l and 'owner_generation<='not in l and 'owner_epoch<='not in l)
check('independent PS/G routing','ext_ps_select?'in w and 'g_enable?g_g_wr_valid:'in w)
check('new provider33 declarations','logic[2:0]'in l and 'source_witness,provider_protocol_error;logic[1:0]terminal_kind'in l and 'output logic[12:0]issued_vectors,written_vectors'in l)
for name,bits in [('state',3),('issued_vectors',13),('written_vectors',13),('source_witness',1),('provider_protocol_error',1),('terminal_kind',2)]:checks.append('provider field '+name+' '+str(bits))
projection=32311+13+1+1+132+33
check('known projection arithmetic',projection==32491 and 32768-projection==277)
if a.hierarchy:
 lines=a.hierarchy.read_text().splitlines()
 for suffix in ['/dut/joint/workspace','/dut/resources/fp','/dut/resources/div','/dut/resources/qkv','/dut/hidden','/dut/scratch','/dut/ln_provider','/dut/g_pool','/dut/g_tanh']:
  check('actual hierarchy '+suffix,sum(x.endswith(suffix)for x in lines)==1)
 check('external VECTOR no local storage',not any('/dut/joint/vector_engine/local_control'in x for x in lines))
 check('actual unique VECTOR engine',sum(x.endswith('/dut/joint/vector_engine')for x in lines)==1)
 check('actual external VECTOR parameter',a.vector_parameter and a.vector_parameter.read_text().strip()=='1')
 check('source-bound external VECTOR storage branch','.EXTERNAL_CONTROL(1)) vector_engine('in j and 'generate if(EXTERNAL_CONTROL)begin:external_control'in v and 'end else begin:local_control'in v and v.count('always_ff')==1)
check('128 gate correctly stopped',read(RUN/'LN128_cost_gate.json')['status']=='COST_STOP'and not read(RUN/'LN128_cost_gate.json')['full128_launched'])
receipts=[];used={k:0. for k in ['reference','static','rtl','ooc']}
for q in sorted((RUN/'attempts').glob('AT*/receipt.json')):
 d=read(q)
 if d['status']not in ['RUNNING','WAITING_LOCK']:
  check('terminal cleanup '+q.parent.name,not d.get('owned_after_cleanup',[])and not d.get('owned_group_after_cleanup_exists',False))
  used[d['phase']]+=d.get('child_wall_s',0)
  receipts.append({'attempt':q.parent.name,'status':d['status'],'phase':d['phase'],'wall_s':d.get('child_wall_s',0),'receipt_sha256':sha(q)})
control={'schema':'m007-joint23-declared-increment-census-v1','base_FFN_bits':32311,'physical_arena_bits':12288,'arena_owner_rearm_bits':3,'VECTOR_external_shadow_control_bits':0,'new_hidden_control_bits':13,'new_scratch_control_bits':1,'owner_rearm_increment_bits':1,'persistent_gamma_control_bits':132,'resident_LN_provider_fields_bits':{'state':3,'issued_vectors':13,'written_vectors':13,'source_witness':1,'provider_protocol_error':1,'terminal_kind':2},'resident_LN_provider_control_bits':33,'wrapper_FF_bits':0,'known_total_projection_bits':projection,'known_total_projection_B':projection/8,'remaining_unallocated_bits_before_parent':32768-projection,'final_parent_fit':'NOT_ASSESSED','excluded_control':'parent kind/state/counters/catalog/refill and any actual new parent register beyond baseline; no automatic deduction','payload_increment_bits':{'H':524288*8,'held_H_response':128*8,'LN_gamma':4096*8,'LN_existing_numeric':18055},'identity_copy_bits':0,'Q_payload_copy_bits':0,'functional_simulation_is_physical_timing_evidence':False}
(a.output/'control_census.json').write_text(json.dumps(control,indent=2)+'\n')
(a.output/'report.json').write_text(json.dumps({'status':'PASS','scope':'Source/version/declared-increment/hierarchy audit only; final parent fit not assessed','checks':checks,'checks_count':len(checks),'receipts':receipts,'completed_cost_s':used,'control_census_sha256':sha(a.output/'control_census.json'),'hierarchy_sha256':sha(a.hierarchy)if a.hierarchy else None},indent=2)+'\n')
print('HARDWARE_AGENT_SIM_PASS JOINT23_RELEASE_AUDIT checks='+str(len(checks))+' known_control_bits='+str(projection)+' final_fit=NOT_ASSESSED')
