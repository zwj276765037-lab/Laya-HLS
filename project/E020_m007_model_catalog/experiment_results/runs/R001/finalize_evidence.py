#!/usr/bin/env python3
"""Bookkeeping audit of already executed E020 attempts; launches no experiment."""
from datetime import datetime,timezone
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import tarfile

RUN=Path(__file__).resolve().parent
PROJECT=RUN.parents[4]
EXPERIMENT=PROJECT/'project/E002_Laya_HLS/experiment'
MODULE=EXPERIMENT/'vivado/module_design/model_catalog'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def save(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
receipts=[];totals={phase:Decimal(0) for phase in ('reference','static','rtl')};policies=0;corrections=0;archive_checks=[]
for at in sorted((RUN/'attempts').glob('AT*')):
 receipt=json.loads((at/'receipt.json').read_text());receipts.append(receipt)
 assert receipt['owned_after_cleanup']==[] and receipt['owned_group_after_cleanup_exists'] is False
 assert receipt['exit_code']==(1 if at.name=='AT001_host' else 0)
 assert receipt['status']==('FAIL' if at.name=='AT001_host' else 'EXIT_ZERO')
 totals[receipt['phase']]+=Decimal(str(receipt['child_wall_s']))
 assert sha(at/'sources.tar.gz')==receipt['source_archive_sha256']
 with tarfile.open(at/'sources.tar.gz')as archive:
  expected=dict(receipt['source_sha256'])
  expected['e020_catalog_protocol.md']=receipt['protocol_sha256']
  expected.update({'authority/'+key:value for key,value in receipt.get('authority_sha256',{}).items()})
  for name,digest in expected.items():assert hashlib.sha256(archive.extractfile(name).read()).hexdigest()==digest,name
  archive_checks.append({'attempt':at.name,'verified_files':len(expected),'archive_sha256':sha(at/'sources.tar.gz')})
 for item in receipt['descendant_policy_checks']:
  assert item['nice']==19 and set(item['affinity'])<={0,1,2,3} and item['ioprio']==3<<13
  policies+=item['samples'];corrections+=len(item['corrections'])
ref=RUN/'attempts/AT002_host_fix/work/host'
build=RUN/'attempts/AT003_reader_build/work'
rtl=RUN/'attempts/AT004_reader_rtl/work'
reference=json.loads((ref/'report.json').read_text());compile_report=json.loads((build/'report.json').read_text());rtl_report=json.loads((rtl/'report.json').read_text())
assert reference['status']=='PASS' and reference['tests_run']==8 and rtl_report['status']=='PASS_PUBLIC_CATALOG_READER'
for name,digest in receipts[1]['source_sha256'].items():
 if name.startswith(('tools/','tests/','reference/','build/')):assert sha(EXPERIMENT/name)==digest,name
for name,digest in compile_report['sources_sha256'].items():assert sha(EXPERIMENT/name)==digest,name
pre=json.loads((rtl/'snapshot_prerun_sha256.json').read_text());post=json.loads((rtl/'snapshot_postrun_sha256.json').read_text())
assert pre==compile_report['snapshot']
assert all(post[name]==digest for name,digest in pre.items())
progress=json.loads((RUN/'attempts/AT004_reader_rtl/receipt.json').read_text())['semantic_progress']
assert progress['event_count']==132 and not progress['unparsed_tail'] and progress['last_checked']==132
identity={str(path.relative_to(EXPERIMENT)):sha(path)for path in [MODULE/'rtl/laya_m007_catalog_reader_v1.sv',*sorted((MODULE/'tb').glob('m007_catalog*')),EXPERIMENT/'tools/m007_model_catalog.py',EXPERIMENT/'tests/test_m007_model_catalog.py']if path.is_file()}
save(RUN/'production_manifest_v1.json',{'schema':'e020-catalog-source-v1','created_utc':datetime.now(timezone.utc).isoformat(),'source_sha256':identity,'original_model_package_manifest_sha256':receipts[-1]['source_sha256']['build/model-q8-session-v2-actual-r2-20261010/manifest.json'],'original_inventory_sha256':receipts[-1]['source_sha256']['reference/runs/typed_q8_ref_20261005/gguf_inventory.json'],'authority_at_final_run':receipts[-1]['authority_sha256'],'current_build_report_sha256':sha(build/'report.json'),'reader_census_sha256':sha(build/'reader_control_census.json'),'snapshot_original_files':len(pre),'snapshot_original_files_unchanged':True,'snapshot_runtime_added_files':{k:v for k,v in post.items()if k not in pre},'host_actual_input_manifest_sha256':sha(ref/'report.json'),'coefficient_provenance_sha256':sha(ref/'coefficients/report.json'),'type_original_reference_comparison_sha256':sha(ref/'type_reference_comparison.json'),'catalog_bin_sha256':sha(ref/'catalog.bin'),'address_space':'SIM','actual_platform_aperture_or_DMA':'NOT_RUN','whole_model_payload_rehashed':False})
caps={'reference':120,'static':300,'rtl':300}
ledger={'schema':'e020-r001-budget-closure-v1','fresh_scope':'MODEL-CATALOG-28 only; no E014/E015 transfer','status':'BOUNDED_WORK_COMPLETE_NO_ACTIVE_OR_QUEUED_TOOL','phase_wall_s':{k:str(v)for k,v in totals.items()},'phase_cap_s':caps,'unused_s':{k:str(Decimal(caps[k])-totals[k])for k in totals},'recovery_archive_reserve_s':60,'reserve_retained':all(Decimal(caps[k])-totals[k]>=60 for k in totals),'unused_balance_transferred':False,'OOC_PnR_board_GPU':0,'attempts':[{'attempt':r['attempt'],'phase':r['phase'],'status':r['status'],'child_wall_s':r['child_wall_s'],'receipt_sha256':sha(RUN/'attempts'/r['attempt']/'receipt.json'),'sampled_RSS_peak_bytes':r['RSS_sampled_peak_bytes'],'cleanup_empty':True}for r in receipts]}
save(RUN/'budget_closure_v1.json',ledger)
delivery={'schema':'e020-independent-catalog-delivery-v1','status':'PASS_BOUNDED_HOST_AND_READER','review_state':'PENDING_A001_SCOPE_REVIEW','runtime_id':'/root/m007_host_tail_engineering','desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','host_test_groups':8,'record_count':120,'valid_reader_words':124,'reader_source_control_FF_bits':2,'reader_payload_address_identity_FF_bits':0,'reader_descriptor_slots':0,'TB_peer_descriptor_slots':2,'RTL_measurements':rtl_report['measurements'],'original_type_rows_bitexact':3,'original_type_F32_bitexact':3072,'coefficient_products':json.loads((ref/'coefficients/report.json').read_text())['products'],'coefficient_chunks_setup_only':704,'archive_verification':archive_checks,'owned_policy_samples':policies,'owned_policy_ioprio_corrections':corrections,'all_owned_cleanup_empty':True,'checked_consume_events':progress['event_count'],'semantic_max_observed_gap_s':progress['maximum_observed_gap_s'],'snapshot_original_files':len(pre),'snapshot_original_files_unchanged':True,'snapshot_runtime_added_files':list(sorted(set(post)-set(pre))),'production_manifest_sha256':sha(RUN/'production_manifest_v1.json'),'budget_closure_sha256':sha(RUN/'budget_closure_v1.json'),'not_run':['production_parent_W_mux_transport_idle','device_setup_model_committed','device_coefficient_commits','actual_platform_DMA','full_layers_or_30_layer','device_SHA_compute','OOC_PnR_timing_board'],'reset_boundary':'common peer reset; arbitrary late pre-reset RID7 is outside checked contract','retained_failure':'AT001_host:1-based tensor index and exact raw tensor-name preparation errors; corrected against original pinned metadata'}
save(RUN/'independent_delivery_v1.json',delivery)
print(json.dumps({'status':delivery['status'],'phase_wall_s':ledger['phase_wall_s'],'unused_s':ledger['unused_s'],'policy_samples':policies,'ioprio_corrections':corrections,'archive_verified_files':[x['verified_files']for x in archive_checks],'snapshot_original_files':len(pre),'snapshot_added':len(delivery['snapshot_runtime_added_files'])}))
