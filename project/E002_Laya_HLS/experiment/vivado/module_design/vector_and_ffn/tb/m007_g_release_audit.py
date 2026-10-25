#!/usr/bin/env python3
"""Bounded source/result/process audit for the resumed G functional stage."""
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
  if not 56<=number<=80:continue
  r=read(at/'receipt.json');guard=Path(r['guard_entrypoint'])
  assert r['status']in('EXIT_ZERO','FAIL')and r['owned_after_cleanup']==[]and not r['owned_group_after_cleanup_exists']
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
 assert len(attempts)==25
 failed={q['attempt']for q in attempts if q['status']=='FAIL'}
 assert failed=={'AT060_g_math_three_original_groups','AT062_g_math_packed_output_three_groups','AT065_g_engine_sole_resources_build'}
 fixture=RUN/'attempts/AT058_g_original_product_fixture/work';fi=read(fixture/'report.json');assert sha(fixture/'geglu_vectors.hex')==fi['vectors_sha256']and fi['count']==335872
 for q in fi['inputs'].values():assert sha(ROOT/q['path'])==q['sha256'];source_checks+=1
 errors=RUN/'attempts/AT070_g_sparse_original_error_reference/work';er=read(errors/'report.json')
 for q in er['cases'].values():assert sha(errors/q['patch_file'])==q['patch_sha256'];source_checks+=1
 census=RUN/'attempts/AT071_g_exact_source_state_census/work/report.json';c=read(census)
 for path,digest in c['source_sha256'].items():assert sha(ROOT/path)==digest;source_checks+=1
 assert c['g_control_bits']==46938 and c['g_control_exceeds_4KiB']
 # Frozen TANH evidence is identified and reused, never rerun for this audit.
 tanh=RUN/'attempts/AT055_tanh8_complete_original/work/report.json';t=read(tanh)
 assert t['status']=='PASS'
 used={k:Decimal(0)for k in ('reference','static','rtl','ooc')};receipt_count=0
 for path in(RUN/'attempts').glob('*/receipt.json'):
  r=json.loads(path.read_text(),parse_float=Decimal)
  if r['status']in('RUNNING','WAITING_LOCK'):continue
  used[r['phase']]+=Decimal(str(r.get('child_wall_s',0)));receipt_count+=1
 caps={'reference':900,'static':1800,'rtl':3000,'ooc':1800};remaining={k:str(Decimal(v)-used[k])for k,v in caps.items()};assert all(Decimal(x)>0 for x in remaining.values())
 report={'schema':'m007-g-stage-release-evidence-v1','status':'FUNCTIONAL_AND_CYCLE_STAGE_COMPLETE_CAPACITY_OPEN','scope':'Resumed G component/arithmetic, full original normal335872, reachable global-rank cases and real public error/discard/no-reset recovery; exact source census identifies capacity violation. No parent FFN/combined SFU/physical timing or fit claim.','attempts':attempts,'builds':builds,'functional_results':results,'audit_counts':{'resumed_attempts':len(attempts),'verified_source_archives':archives,'verified_archived_files':archive_files,'verified_build_snapshot_files':snapshot_files,'verified_selected_source_and_input_files':source_checks},'normal_full_attempt':'AT072_g_engine_full_original_335872','error_full_attempts':['AT075_g_error_gate_then_late_input_full','AT076_g_error_gate_then_late_v_full','AT077_g_error_gate_then_late_z_full','AT078_g_error_inverse_row_full'],'peer_protocol_only_attempt':'AT080_g_peer_status_partial_discard_newgen','retained_failed_attempts':sorted(failed),'frozen_tanh_report_sha256':sha(tanh),'original_fixture_report_sha256':sha(fixture/'report.json'),'sparse_error_reference_report_sha256':sha(errors/'report.json'),'g_state_census_report_sha256':sha(census),'g_control_bits':46938,'g_control_bytes':5867.25,'g_control_fit':False,'receipt_count_before_own_audit_completion':receipt_count,'remaining_s_before_own_audit_completion':remaining,'limitations':['G control exceeds4KiB; compact keys/lifetime reuse are candidates only, no deduction implemented','Single SFU EXP/TANH shared lease/queue/physical-resource combination remains future A007/controller work','G validation shell is independent; no Wi/G/Down parent overlap or whole FFN/Decision/deployment success','No full8lane/G OOC, P&R, physical300MHz or joint896DSP/resource fit; existing small-leaf hold failures retained','Public peer test covers one matching status8 return; wrong/missing-tag G peer injection not run','Every newgen recovery is an actual3-block prefix waiting for unprovided s3, not whole newgen command completion','Historical AT008–013 exact guard self-SHA unknown and AT034 not launched boundaries remain unchanged']}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('G_RELEASE_EVIDENCE_AUDIT_PASS',json.dumps(report['audit_counts']),flush=True)
if __name__=='__main__':main()
