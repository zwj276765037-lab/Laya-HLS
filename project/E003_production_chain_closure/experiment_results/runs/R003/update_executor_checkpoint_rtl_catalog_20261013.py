import hashlib,json
from pathlib import Path
RUN=Path(__file__).resolve().parent
# R003 -> runs -> experiment_results -> E003 -> project
ROOT=RUN.parents[3]/'E002_Laya_HLS/experiment'
MODULE='vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512'
def rec(p):
 p=Path(p).resolve();b=p.read_bytes();return {'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
changes=[]
rtl_sources=[MODULE+'/rtl/'+n+'.sv' for n in ['laya_model_identity_13bo_generated_v1','laya_compute_portal_layout_v1','laya_generated_provenance_layout_v1','laya_bootstrap_snapshot_layout_v1','laya_executor_checkpoint_layout_v2','laya_private_fifo2_v1','laya_generated_provenance_v1','laya_executor_checkpoint_transport_v2','laya_generated_provenance_hub_v1','laya_generated_store_monitor_v1','laya_generated_provenance_axi_portal_v1']]
for name,key in [('full_module_registry.json','executor_checkpoint'),('production_hls_partitions.json','executor_checkpoint_boundary')]:
 p=ROOT/'config'/name;before=p.read_bytes();d=json.loads(before);state=d[key]
 state['hardware_state']='PASS_SCOPED_RTL_CHECKPOINT_HANDOFF executor_checkpoint_rtl_05; actual hub task/source-target history, direct LPV transport highwater and real 16beat depth2 consumer. Generated executor import/accepted-request restart/source-action chain pending.'
 state['rtl_transport']=MODULE+'/rtl/laya_executor_checkpoint_transport_v2.sv'
 state['enabled_parameter']='ENABLE_EXECUTOR_CHECKPOINT, default 0'
 state['frontier_witness']='observed contiguous BEGIN and successful terminal END at original typed array; task gap/error prevents diagnostic frontier. Limited single dispatcher; does not prove arbitrary hidden reservations.'
 state['hardware_evidence']={'checkpoint_handoff':'project/E003_production_chain_closure/experiment_results/runs/R003/executor_checkpoint_rtl_05','actual_capture_codec_import':'project/E003_production_chain_closure/experiment_results/runs/R003/executor_checkpoint_rtl_decode_01','compatibility':['bootstrap_snapshot_rtl_06','bootstrap_source_guard_rtl_09','generated_store_monitor_14','generated_source_lease_06']}
 state['dispatch']='predecessor fully drains then holds; hub response owned through actual 16th read; once-only successor selection on same LPV FIFO; base/cancel revoke authority. Diagnostic phase once per reset, not accepted-request restart.'
 if name=='full_module_registry.json':d['rtl_shell_sources']['executor_checkpoint']=rtl_sources
 else:
  for part in d['partitions']:
   if 'implementation' in part and 'checkpoint_import' in part['implementation']:
    part['evidence']['checkpoint_handoff_rtl']=state['hardware_evidence']['checkpoint_handoff']
    part['evidence']['checkpoint_actual_capture_import']=state['hardware_evidence']['actual_capture_codec_import']
 backup=RUN/('executor_checkpoint_rtl_catalog_before_'+name);backup.write_bytes(before)
 old=rec(p);p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
 changes.append({'kind':'catalog_registration','before':old,'after':rec(p),'saved_before':rec(backup)})
p=ROOT/MODULE/'tb/run_executor_checkpoint_rtl.py'
before=p.read_bytes();old=rec(p)
s=p.read_text().replace("'same transport successor CLAIM event178 epoch8; cancel/base change revoke stable bytes; '","'active target CLAIM178 epoch8 rejected then INVALIDATE179; successful handoff observes LPV179/target8; successor CLAIM180 epoch9; cancel/base revoke stable bytes; '")
(RUN/'executor_checkpoint_rtl_runner_scope_before.py').write_bytes(before)
p.write_text(s)
changes.append({'kind':'runner_scope_wording_only_no_DUT_or_validation_change','before':old,'after':rec(p),'saved_before':rec(RUN/'executor_checkpoint_rtl_runner_scope_before.py')})
v=json.loads((RUN/'executor_checkpoint_rtl_verification_20261013.json').read_text())
new_by_path={x['after']['path']:x['after'] for x in changes}
pairs=[];references=[]
for a in v['attempts']:
 for x in a['pairs']:
  r=rec(x['original']['path']);match=r==x['original'];allowed=r==new_by_path.get(r['path'])
  assert match or allowed,r['path']
  assert rec(x['frozen']['path'])==x['frozen']
  pairs.append({'attempt':a['attempt'],'path':r['path'],'match':match,'allowed_metadata_change':not match and allowed})
 for x in a['references']:
  r=rec(x['declared']['path']);match=r==x['declared'];allowed=r==new_by_path.get(r['path'])
  assert match or allowed,r['path']
  references.append({'attempt':a['attempt'],'path':r['path'],'match':match,'allowed_metadata_change':not match and allowed})
result={'changes':changes,'post_registration_pair_count':len(pairs),'post_registration_current_matches':sum(x['match'] for x in pairs),'post_registration_reference_count':len(references),'post_registration_reference_matches':sum(x['match'] for x in references),'pairs':pairs,'references':references,'frozen_unchanged':True,'functional_inputs_unchanged':True,'scope_wording_correction':'Frozen runner scope describes preliminary successor event178/epoch8; final TB actually performs this as an active-target negative before handoff, then successor event180/epoch9. Final successful response LPV179/target8. Original manifests preserved.'}
(RUN/'executor_checkpoint_rtl_catalog_delta_20261013.json').write_text(json.dumps(result,indent=2)+'\n')
print({k:result[k] for k in ['post_registration_pair_count','post_registration_current_matches','post_registration_reference_count','post_registration_reference_matches']})
