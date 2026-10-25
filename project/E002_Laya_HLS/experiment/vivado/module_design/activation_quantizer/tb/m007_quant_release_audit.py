#!/usr/bin/env python3
"""Bounded source/evidence identity audit and explicit RTL storage declaration ledger."""
import argparse
import json
import math
from pathlib import Path
from m007_quant_local_run import ROOT,LOCAL,sha
from m007_quant_engine_run import verify

RUN=ROOT.parents[2]/'project/E013_m007_quant_group32/experiment_results/runs/R001'
ENGINE_SHA='555ac5492af12929112d5f513538f205a1607021d602356083956c909e955add'
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--audit-attempt',required=True);a=p.parse_args()
 at=RUN/'attempts';engine=ROOT/LOCAL/'rtl/laya_m007_quant_group32_v1.sv';assert sha(engine)==ENGINE_SHA
 full=json.loads((at/'AT015_snapshot_bound_full/work/report.json').read_text());assert full['status']=='PASS_REAL_QUANT_ENGINE_FULL'
 protocol=json.loads((at/'AT016_snapshot_bound_protocol/work/report.json').read_text());assert protocol['status']=='PASS_REAL_QUANT_ENGINE_PROTOCOL'
 for name,report in(('AT015_snapshot_bound_full',full),('AT016_snapshot_bound_protocol',protocol)):
  assert sha(at/name/'work/snapshot_prerun_sha256.json')==report['snapshot_prerun_sha256']
  assert sha(at/name/'work/snapshot_postrun_sha256.json')==report['snapshot_postrun_sha256']
  pre=json.loads((at/name/'work/snapshot_prerun_sha256.json').read_text());assert pre['files']and any(path.endswith('/xsimk')for path in pre['files'])
 for report in(full,protocol):
  for path,value in report['source_identity'].items():assert sha(ROOT/path)==value,'version mismatch '+path
 expected=[(4096,4180,1024),(10496,10580,2624),(16384,16468,4096)]
 for stream,(groups,span,K)in zip(full['streams'][:3],expected):
  assert stream['groups']==groups and stream['span_cycles']==span and span<=4*K+128
  assert stream['first_cycles']==85<=128 and stream['products']==groups and stream['max_reservations']==84
 assert len(full['streams'])==4 and sum(s['groups']for s in full['streams'][:3])==30976
 assert len(full['lease_initialization_metrics'])==4
 assert all(s['wait_cycles']==1 for s in full['lease_initialization_metrics'])
 text=(at/'AT016_snapshot_bound_protocol/stdout.log').read_text()
 assert 'M007_QUANT_PROTOCOL_PASS rejects=8 releases=4 saturation=128 held=1 release_debt=1 active_reset=1 new_generation=2'in text
 assert protocol['streams'][0]['max_reservations']==128
 fixture=at/'AT001_independent_norm128_reference/fixture';diagnostics=at/'AT004_original_intermediates/fixture'
 original=verify(fixture,'PASS_INDEPENDENT_QUANT_REFERENCE');verify(diagnostics,'PASS_ORIGINAL_QUANT_INTERMEDIATES')
 leaf=json.loads((at/'AT013_amax_same_dcp_retime/work/report.json').read_text())
 assert leaf['status']=='COMPLETE_HELPER_AMAX_OOC' and all(v==0 for v in leaf['timing_coverage'].values())
 assert leaf['source_sha256']==sha(ROOT/LOCAL/'rtl/laya_m007_quant_amax32_v1.sv')
 # Registered declarations, before synthesis optimizes constants/invalid payload.
 # Combinational wires/functions/aliases are not storage; shared div is not copied.
 buckets={
  'raw_mem_128x1024':128*1024,'packed_mem_128x272':128*272,
  'per_slot_metadata_128x251':128*(4+8+8+96+32*3+16+8+8+5+2),
  'strict_mul_32x605':32*(8+96+16+33+96+36+27+25+32+6+6+192+32),
  'amax_pipeline':31*(16+8+4+2+1)+5+5+5*5+5*7,
  'raw_read_payload_inverse_slot_valid':1024+32+7+1,
  'mul_slot_tag_valid_pipeline':8*7+8,
  'divider_request_holding':1+2+7+7+32+32,
  'lease_identity_counters_and_flags':64+32+32+13+7*32+9+3}
 bits=sum(buckets.values());other=bits-buckets['raw_mem_128x1024']-buckets['packed_mem_128x272']
 assert bits==219993 and math.ceil(bits/8)==27500 and other<=8192*8 and bits<=32768*8
 receipts=[];spent={phase:0. for phase in('reference','static','rtl','ooc')};peak=0
 for path in sorted(at.glob('AT*/receipt.json')):
  receipt=json.loads(path.read_text())
  if receipt['attempt']==a.audit_attempt:continue
  expected_status='FAIL'if receipt['attempt']=='AT017_release_audit'else'EXIT_ZERO'
  assert receipt['status']==expected_status,receipt['attempt']
  assert receipt['actual_CPU_affinity']==[0,1,2,3]and receipt['actual_nice']==19 and receipt['actual_ioprio']==24576
  spent[receipt['phase']]+=receipt['child_wall_s'];peak=max(peak,receipt['RSS_sampled_peak_bytes'])
  receipts.append({'path':str(path.relative_to(RUN)),'sha256':sha(path),'phase':receipt['phase'],'child_wall_s':receipt['child_wall_s'],'status':receipt['status']})
 for phase,cap in{'reference':900,'static':1800,'rtl':2400,'ooc':600}.items():assert spent[phase]<cap
 source_paths=sorted((ROOT/LOCAL/'rtl').glob('laya_m007_*'))+sorted((ROOT/LOCAL/'tb').glob('m007_*'))
 report={'schema':'m007-quant03-release-v1','status':'PASS_SCOPED_STRICT_GROUP32_ENGINE','engine_sha256':ENGINE_SHA,
  'sources':{str(path.relative_to(ROOT)):sha(path)for path in source_paths if path.is_file()},'consumed_arithmetic_and_rtl':full['source_identity'],
  'actual_input_sha256':original['input_sha256'],'actual_first4_original_association':original['original_first4_rows'],
  'full_streams':full['streams'],'lease_initialization_metrics':full['lease_initialization_metrics'],'protocol_streams':protocol['streams'],
  'compiled_snapshot_prerun_identity':{name:{'manifest':'attempts/'+name+'/work/snapshot_prerun_sha256.json','sha256':report['snapshot_prerun_sha256'],
   'frozen_source_binding':report['frozen_source_binding']}for name,report in(('AT015_snapshot_bound_full',full),('AT016_snapshot_bound_protocol',protocol))},
  'real_shared_div8_instances':1,'real_quant_mul_instances':32,
  'storage_ledger':{'kind':'manual_registered_RTL_declaration_audit_not_synthesis_mapping','bits_by_bucket':buckets,'total_bits':bits,'total_bytes_ceil':math.ceil(bits/8),
   'all_storage_other_than_raw_packed_bits':other,'all_storage_other_than_raw_packed_bytes_ceil':math.ceil(other/8),'raw_bytes':16384,'packed_bytes':4352,'slot_metadata_bytes':4016},
  'amax_leaf_ooc':leaf,'historical_attempt_limitations':{'AT009_amax_leaf_ooc':'Netlist/resource complete; initial XDC remove_from_collection unsupported,1001 missing input delays. Its runner timing PASS is invalid for overall IO timing; AT013 corrects same DCP without resynthesis.',
   'AT017_release_audit':'FAIL retained: manual storage ledger expected705 bits per original multiplier but its listed fields sum605. Corrected arithmetic reduces total400B; no DUT/gold change.'},
  'costs_before_this_audit_s':spent,'resource_peak_sampled_bytes_before_this_audit':peak,'receipts':receipts,'audit_receipt':'attempts/'+a.audit_attempt+'/receipt.json',
  'unverified':['A cache actual publication and full-slot cancellation','global parent Check/first-error ordering','future Q/G or idle_Q physical sharing','full engine resource/BRAM mapping','full engine300MHz/place-route','FPGA board/complete model'],
  'runtime_id':'/root/m007_host_tail_engineering','desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':None,'actual_effort':None}
 a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(report,indent=2)+'\n')
 print('M007_QUANT_RELEASE_AUDIT_PASS groups=30976 full_first=85 storage_bits=219993 storage_ceil_bytes=27500 protocol_rejects=8 raw_data_unchanged=1',flush=True)
if __name__=='__main__':main()
