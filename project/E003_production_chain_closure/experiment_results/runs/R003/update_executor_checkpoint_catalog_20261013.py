#!/usr/bin/env python3
"""Record scoped host checkpoint evidence without changing historical attempts."""
import datetime as dt
import hashlib
import json
from pathlib import Path
RUN=Path(__file__).resolve().parent
PROJECT=RUN.parents[4]
IMPL=PROJECT/'project/E002_Laya_HLS/experiment'
NAMES=['executor_checkpoint_host_04','executor_bootstrap_host_04','task_lifecycle_fsm_host_04','graph_lifecycle_split_host_05']
PREFIX='project/E003_production_chain_closure/experiment_results/runs/R003/'
def rec(p):
 p=Path(p).resolve();b=p.read_bytes();return {'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def main():
 out=RUN/'executor_checkpoint_catalog_delta_20261013.json'
 if out.exists():raise RuntimeError('delta already exists')
 verification=json.loads((RUN/'executor_checkpoint_verification_20261013.json').read_text())
 if not verification['passed']:raise RuntimeError('stage verification failed')
 paths=[IMPL/'config/full_module_registry.json',IMPL/'config/production_hls_partitions.json']
 before=[rec(p) for p in paths];registry,partitions=[json.loads(p.read_text()) for p in paths]
 boundary={'contract':'results/executor_checkpoint_high_water_contract_20261012.md','mode':'finite same-admitted-request NORM_LAYER1_ATTN diagnostic only','request_magic':'LBS2','response_magic':'LBR2','version':2,'bytes':1024,'beats512':16,'target_domains':1,'sources':1,'header':'include/laya_executor_checkpoint.h','codec':'hls/control/executor_checkpoint_protocol.cpp','import_helper':'hls/control/executor_checkpoint.cpp','shared_sv_layout':'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_checkpoint_layout_v2.sv','source_closure':'config/executor_checkpoint_sources.cmake','high_water_authority':{'task':'unique hub typed_last_task, diagnostic baseline without local retirement','LPV':'actual laya_generated_provenance_v1.last_event_seq via unique shell, never accepted_events','source_target_epoch':'complete physical allocation-domain history plus larger retained local floors','producer_compute':'retained executor/transport; not imported from hub','action':'program allocation; retained executor validation floor'},'atomic_import':'whole-frame/binding/known/complete/no-hole/geometry/capacity/overflow checks before source mirror, inactive target epoch-history cache, allocator and predecessor baseline commit; no TaskDone, retirement, owner claim or publication during import','validation':'PASS_SCOPED_HOST executor_checkpoint_host_04: 2048B independent oracle, 46 wire/36 import/4 prepare negatives, dynamic bases4/7/3 and LPV23/97/119, actual C++ program/port/FSM/adapter four retirements per action; controlled snapshot/fences/remote responses','hardware_state':'NOT_RUN: actual hub/transport v2 authority, 16beat depth2 handshake, dispatch handoff/source-target protection and executor top pending','v1':'768B LBS1/LBR1 remains source-only; cannot enable v2 floor import','scope':'No full graph, encoder arithmetic, actual LN in this host runtime, final13BO, unknown-hole/partial-failure recovery or physical resource/timing claim'}
 partitions['executor_checkpoint_boundary']=boundary
 e=next(x for x in partitions['partitions'] if x['name']=='task_lifecycle_executor')
 e['sources']='config/executor_checkpoint_sources.cmake'
 e['state']='host_v2_checkpoint_and_shared_FSM_pass_real_hub_transport_handoff_executor_top_pending'
 e['implementation'].update(checkpoint_header=boundary['header'],checkpoint_codec=boundary['codec'],checkpoint_import=boundary['import_helper'],retirement_statistics='actual tasks_retired delta; last_task_id only contiguous range consistency and external checkpoint predecessor')
 e['evidence'].update(checkpoint=PREFIX+NAMES[0],bootstrap_v1_compatibility=PREFIX+NAMES[1],shared_FSM_compatibility=PREFIX+NAMES[2],synchronous_F11_F13_compatibility=PREFIX+NAMES[3],scope=boundary['validation']+'; '+boundary['hardware_state'])
 partitions['bootstrap_source_guard_boundary']['validation']='F15 scoped closure on guard_07 retained; F16 controller closure R-SM003-GUARDED-LAYERNORM-F16-20261012 on frozen hub, actual C++ decoder/adapter and finite RTL. Full source protection remains pending.'
 registry['executor_checkpoint']=boundary
 registry['executor_checkpoint_sources']=boundary['source_closure']
 registry['bootstrap_source_guard']['validation']=partitions['bootstrap_source_guard_boundary']['validation']
 for p,d in zip(paths,[registry,partitions]):p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
 differences=[];refs=[];total=0
 def walk(v):
  if isinstance(v,dict):
   if all(k in v for k in ['path','bytes','sha256']):
    actual=rec(v['path']);refs.append({'declared':v,'actual':actual,'match':v==actual})
   for x in v.values():walk(x)
  elif isinstance(v,list):
   for x in v:walk(x)
 for n in NAMES:
  m=json.loads((RUN/n/'input_manifest.json').read_text());r=json.loads((RUN/n/'receipt.json').read_text());pairs=list(m['files'])
  for k in ['contract','bootstrap_contract']:
   if k in m:pairs.append(m[k])
  total+=len(pairs)
  for p in pairs:
   actual=rec(p['original']['path'])
   if actual!=p['original']:differences.append({'attempt':n,'original':p['original'],'current':actual})
   if rec(p['frozen']['path'])!=p['frozen'] or p['original']['sha256']!=p['frozen']['sha256']:raise RuntimeError('frozen drift')
  walk(m);walk(r)
 allowed={str(p.resolve()) for p in paths}
 if any(x['current']['path'] not in allowed for x in differences) or any(x['actual']['path'] not in allowed for x in refs if not x['match']):raise RuntimeError('unexpected current source drift')
 result={'schema':'laya-executor-checkpoint-catalog-delta-v2','at_utc':dt.datetime.now(dt.timezone.utc).isoformat(),'catalogs':[{'before':b,'after':rec(p)} for b,p in zip(before,paths)],'attempts':NAMES,'total_pairs':total,'current_matching_pairs':total-len(differences),'frozen_and_declared_pairs_match':True,'live_differences':differences,'reference_count':len(refs),'matching_references':sum(x['match'] for x in refs),'reference_differences':[x for x in refs if not x['match']]}
 out.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
 print({k:result[k] for k in ['total_pairs','current_matching_pairs','reference_count','matching_references']})
if __name__=='__main__':main()
