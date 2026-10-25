#!/usr/bin/env python3
"""G-RING-TAG-15 exact single-array/full-ring/current-regression release audit; old identities retained."""
import argparse,hashlib,json,tarfile
from decimal import Decimal
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5]
RUN=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 attempts=[];builds=[];results=[];archives=0;archive_files=0;snapshot_files=0;source_checks=0
 for at in sorted((RUN/'attempts').glob('AT*')):
  try:number=int(at.name[2:5])
  except ValueError:continue
  if not 126<=number<=148:continue
  r=read(at/'receipt.json');guard=Path(r['guard_entrypoint'])
  if r['status']=='COST_GATE_STOP':
   assert r['child_wall_s']==0 and 'pid'not in r and not(at/'sources.tar.gz').exists()and not(at/'work').exists()
   assert sha(guard)==r['guard_self_sha256_at_startup']==r['guard_self_sha256_at_lock']
   attempts.append({'attempt':at.name,'status':r['status'],'phase':r['phase'],'child_wall_s':0,'receipt_sha256':sha(at/'receipt.json'),'guard_sha256':sha(guard),'child_launched':False,'source_archive_created':False,'reason':r['error']})
   continue
  assert r['status']in('EXIT_ZERO','FAIL','SEMANTIC_STALL_STOP')and r['owned_after_cleanup']==[]and not r['owned_group_after_cleanup_exists']
  assert sha(guard)==r['guard_self_sha256_at_startup']==r['guard_self_sha256_at_lock']and guard.stat().st_mode&0o222==0
  assert r['CPU_affinity']==[0,1,2,3]and r['nice']==19 and r['ioprio']==24576 and r['MemAvailable_bytes']>192<<30
  assert r['child_subreaper_enabled']and r['RSS_sampled_peak_bytes']<=r['RSS_limit_bytes']
  assert sha(at/'sources.tar.gz')==r['source_archive_sha256']
  with tarfile.open(at/'sources.tar.gz')as arc:
   for path,digest in r['source_sha256'].items():
    assert hashlib.sha256(arc.extractfile(path).read()).hexdigest()==digest,(at.name,path);archive_files+=1
   assert hashlib.sha256(arc.extractfile('e015_protocol.md').read()).hexdigest()==r['protocol_sha256'];archive_files+=1
   assert r['source_sha256'][str(guard.relative_to(ROOT))]==sha(guard)
  archives+=1
  item={'attempt':at.name,'status':r['status'],'phase':r['phase'],'child_wall_s':r['child_wall_s'],'receipt_sha256':sha(at/'receipt.json'),'source_archive_sha256':r['source_archive_sha256'],'guard_sha256':sha(guard),'owned_cleanup_empty':True}
  rp=at/'work/report.json'
  if rp.exists():
   m=read(rp);item['report_sha256']=sha(rp);item['report_status']=m['status']
   if m['status']=='BUILD_COMPLETE':
    current_differences=[]
    for path,digest in m['source_sha256'].items():
     assert sha(at/'work/frozen'/path)==digest;source_checks+=1
     if sha(ROOT/path)!=digest:current_differences.append(path)
    for path,digest in m['snapshot'].items():assert sha(at/'work'/path)==digest;snapshot_files+=1
    driver=Path(r['command'][1]);assert sha(driver)==m['driver_sha256']
    builds.append({'attempt':at.name,'manifest_sha256':sha(rp),'selected_source_count':len(m['source_sha256']),'snapshot_file_count':len(m['snapshot']),'current_selected_source_differences':current_differences,'source_sha256':m['source_sha256'],'driver_sha256':m['driver_sha256']})
   elif m.get('status')=='PASS':
    cmd=r['command'];build=Path(cmd[cmd.index('--build')+1]);assert sha(build/'report.json')==m['build_manifest_sha256']
    assert sha(at/'work/xsim.log')==m['xsim_log_sha256']and m['result_marker']in(at/'stdout.log').read_text()
    if 'semantic_progress' in r:
     raw=at/'work/semantic_progress.jsonl';events=[json.loads(x)for x in raw.read_text().splitlines()]
     assert len(events)==m['semantic_progress_event_count']==r['semantic_progress']['event_count']
     assert sha(raw)==m['semantic_progress_sha256']==r['semantic_progress']['raw_sha256']
     last_checked=0;last_cycle=-1;last_nodes=0
     for event in events:
      assert event['checked']>last_checked and event['cycle']>last_cycle and event['node_checks']>=last_nodes
      last_checked=event['checked'];last_cycle=event['cycle'];last_nodes=event['node_checks']
     assert last_checked==m['last_semantic_progress']['checked']==r['semantic_progress']['last_checked']
     assert not r['semantic_progress']['unparsed_tail']
    results.append({'attempt':at.name,'report_sha256':sha(rp),'metrics':m['metrics'],'scope':m['scope'],'semantic_event_count':m.get('semantic_progress_event_count'),'maximum_guard_event_gap_s':r.get('semantic_progress',{}).get('maximum_observed_gap_s')})
  attempts.append(item)
 assert len(attempts)==23
 failed={q['attempt']for q in attempts if q['status']=='FAIL'}
 assert failed=={'AT129_g_ring15_tag_probe_build'}
 stopped={q['attempt']for q in attempts if q['status']=='SEMANTIC_STALL_STOP'}
 assert stopped==set()
 gates={q['attempt']for q in attempts if q['status']=='COST_GATE_STOP'}
 assert gates==set()
 fixture=RUN/'attempts/AT058_g_original_product_fixture/work';fi=read(fixture/'report.json');assert sha(fixture/'geglu_vectors.hex')==fi['vectors_sha256']and fi['count']==335872
 for q in fi['inputs'].values():assert sha(ROOT/q['path'])==q['sha256'];source_checks+=1
 errors=RUN/'attempts/AT070_g_sparse_original_error_reference/work';er=read(errors/'report.json')
 for q in er['cases'].values():assert sha(errors/q['patch_file'])==q['patch_sha256'];source_checks+=1
 census=RUN/'attempts/AT133_g_ring15_exact_state_census/work/report.json';c=read(census)
 for path,digest in c['source_sha256'].items():assert sha(ROOT/path)==digest;source_checks+=1
 assert c['g_control_bits']==13661 and c['g_stage_target_met']and c['new_context_valid_order_bits']==291 and c['unread_tail_bits_removed']==0 and c['ring_tag_bits_saved']==2048 and c['ring_tag_new_storage_bits']==0
 assert sum(q['bits']for q in c['entries']if q['owner']=='laya_m007_g_math_v1'and q['category'].startswith('control_'))==11343
 # Frozen TANH evidence is identified and reused, never rerun for this audit.
 tanh=RUN/'attempts/AT055_tanh8_complete_original/work/report.json';t=read(tanh)
 assert t['status']=='PASS'
 used={k:Decimal(0)for k in ('reference','static','rtl','ooc')};receipt_count=0
 for path in(RUN/'attempts').glob('*/receipt.json'):
  r=json.loads(path.read_text(),parse_float=Decimal)
  if r['status']in('RUNNING','WAITING_LOCK'):continue
  used[r['phase']]+=Decimal(str(r.get('child_wall_s',0)));receipt_count+=1
 caps={'reference':900,'static':1800,'rtl':3000,'ooc':1800};remaining={k:str(Decimal(v)-used[k])for k,v in caps.items()};assert all(Decimal(x)>0 for x in remaining.values())
 normal=read(RUN/'attempts/AT146_g_ring15_complete_original_normal/work/report.json')
 old_normal=read(RUN/'attempts/AT118_g_compact16_complete_original_normal/work/report.json')
 for field in ('checked','node_checks','writes','write_acks','read_vectors','releases','first_actual_consume','full_done_cycles','max_read_gap','max_output_gap'):
  assert normal['metrics'][field]==old_normal['metrics'][field],('normal performance/data count changed',field)
 assert normal['metrics']['checked']==335872 and normal['metrics']['full_done_cycles']<=42240 and max(q['service_cycles']for q in normal['block_timings'])<=768
 error_names=['AT147_g_ring15_complete_rank0_recovery','AT148_g_ring15_complete_inverse_row_recovery']
 error_metrics=[]
 for name,rank,nodes in zip(error_names,(0,7),(3358710,3358720)):
  q=read(RUN/'attempts'/name/'work/report.json');assert q['expected_full_first_error']['rank']==rank
  assert q['metrics']['main_checked']==335872 and q['metrics']['main_node_checks']==nodes and q['metrics']['held_done17']==q['metrics']['wrong_discard17']==17 and q['metrics']['recovery_checked']==12288 and q['metrics']['accepted_debt_zero']==1
  error_metrics.append({'attempt':name,'first_error':q['expected_full_first_error'],'metrics':q['metrics']})
 tag_names=['AT138_g_ring15_seq512_vs256_real_return','AT139_g_ring15_old_generation_real_return','AT140_g_ring15_wrong_epoch_real_return','AT141_g_ring15_reserved_field_real_return','AT142_g_ring15_extra_FP_before_real_return']
 for name in tag_names:
  q=read(RUN/'attempts'/name/'work/report.json');assert q['metrics']['invalid_retired']==0 and q['metrics']['restored_real']==q['metrics']['debt_checks']==1
 for name in ['AT126_g_ring15_full_ring_build','AT127_g_ring15_math_domain_build','AT128_g_ring15_production_build','AT130_g_ring15_tag_probe_build','AT131_g_ring15_numeric_build','AT132_g_ring15_peer_build']:
  q=next(x for x in builds if x['attempt']==name);assert not q['current_selected_source_differences']
 assert Decimal(remaining['rtl'])>=120,'required short/archive reserve'
 ring=read(RUN/'attempts/AT134_g_ring15_full256_same_address/work/report.json')
 assert ring['metrics']['pending_peak']==256 and ring['metrics']['full_same_address_swaps']==1280 and ring['metrics']['held_cycles']==51 and ring['metrics']['held_records']==3
 assert ring['metrics']['checked']==12288 and ring['metrics']['node_checks']==122880 and ring['metrics']['boundary255']==ring['metrics']['boundary511']==1
 reused=[]
 for name,rank,nodes in [('AT121_g_compact16_complete_rank2_recovery',2,3358713),('AT122_g_compact16_complete_rank5_recovery',5,3358715)]:
  q=RUN/'attempts'/name/'work/report.json';v=read(q);assert v['status']=='PASS' and v['expected_full_first_error']['rank']==rank and v['metrics']['main_node_checks']==nodes
  reused.append({'attempt':name,'original_report_sha256':sha(q),'boundary':'Original compact16 identity reused for unchanged arithmetic/error-order logic, not rerun under current ring-high8 source'})
 delta=read(RUN/'g_ring15_source_delta_v1.json');assert len(delta['changes'])==1 and delta['changes'][0]['ring_high8_sha256']==sha(ROOT/delta['changes'][0]['path'])
 for path,digest in delta['unchanged_selected_production_and_numeric'].items():assert sha(ROOT/path)==digest
 report={'schema':'m007-g-ring15-release-evidence-v1','status':'G_RING_TAG_CONTROL_AND_FUNCTIONAL_CYCLE_STAGE_COMPLETE_JOINT_OPEN','scope':'Current13661-bit G-only high8 slot tags with explicit fullseq16 reconstruction, actual full256 same-address replacement/held, complete current normal/rank0/inverse-row and full-tag/debt/status/clear counterexamples. Original rank2/5 identities separately reused. No parent physical sharing or joint fit claimed.','attempts':attempts,'builds':builds,'functional_results':results,'audit_counts':{'ring_stage_attempts':len(attempts),'verified_source_archives':archives,'verified_archived_files':archive_files,'verified_build_snapshot_files':snapshot_files,'verified_selected_source_and_input_files':source_checks},'normal_full_attempt':'AT146_g_ring15_complete_original_normal','normal_metrics':normal['metrics'],'error_full_attempts':error_names,'error_metrics':error_metrics,'reused_old_rank2_rank5':reused,'public_extra_return_attempts':tag_names,'peer_status_attempt':'AT143_g_ring15_matching_status8_recovery','clear_same_seq0_attempt':'AT135_g_ring15_clear_same_seq0_domains','full_ring_attempt':'AT134_g_ring15_full256_same_address','full_ring_metrics':ring['metrics'],'retained_failed_attempts':sorted(failed),'failure_resolution':{'AT129':'Test-only observation still named old tag_mem; preserve fullseq512 precondition by explicit high8 plus slot0, fresh AT130 built and all tag faults passed'},'g_state_census_report_sha256':sha(census),'g_control_bits':13661,'g_control_bytes':1707.625,'math_control_bits':11343,'ring_tag_bits_saved':2048,'ring_added_storage_bits':0,'old_context_valid_order_bits_fully_charged':291,'mask_debt_coverage_or_tail_bits_removed':0,'receipt_count_before_own_audit_completion':receipt_count,'remaining_s_before_own_audit_completion':remaining,'limitations':['Joint4KiB/parent physical reuse/SFU/896DSP/FFN/Decision/physical300MHz remainOPEN','No new OOC/P&R or storage credited from architecture candidates','Current rank2/5 not rerun; original AT121/122 source/report identities preserved','Recovery12288 is three-block prefix waiting for unprovided s3, not whole newgen completion','Full-ring first consume273 includes intentional full-queue held output and is not production no-stall performance','All Compact14 failures/stall/zero-child stop, AT124 cwd audit failure, historical guardSHA UNKNOWN and AT034 never-launched boundaries remain unchanged']}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('G_RING_TAG_RELEASE_EVIDENCE_AUDIT_PASS',json.dumps(report['audit_counts']),flush=True)
if __name__=='__main__':main()
