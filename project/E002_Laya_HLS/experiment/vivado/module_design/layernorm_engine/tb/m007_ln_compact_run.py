#!/usr/bin/env python3
"""Frozen actual full-resource LN shell build and independent-reference run."""
import argparse
from datetime import datetime,timezone
import json
from pathlib import Path
import re
import tarfile
from m007_ln_scalars_run import ROOT,VIV,LOCAL,execute,save,inventory,sha
SHARED=Path('vivado/module_design/attention_and_fp_engine/rtl')
SOURCES=[SHARED/name for name in ('laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv','laya_fp_return_credit_v1.sv','laya_shared_fp256_v2.sv',
 'laya_fdiv_rne_v1.sv','laya_return_vector_credit_v1.sv','laya_shared_div8_v1.sv','laya_attention_storage_v1.sv','laya_ln_exp_storage_v1.sv')]
SOURCES += [LOCAL/'rtl/laya_m007_ln_scalars_v1.sv',LOCAL/'rtl/laya_m007_ln_compact_scalars_v2.sv',LOCAL/'rtl/laya_m007_layernorm32_compact_v2.sv',LOCAL/'rtl/laya_m007_layernorm32_v1.sv']
def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',choices=('build','rtl'),required=True);p.add_argument('--output',type=Path,required=True)
 p.add_argument('--kind',choices=('default','canonical'),required=True);p.add_argument('--fixture',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--pilot',type=Path,action='append');p.add_argument('--rows',type=int,default=4);p.add_argument('--gamma',type=int,default=0);p.add_argument('--stall',type=int,default=0);p.add_argument('--mode',type=int,default=0)
 a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 top='m007_ln_compact_engine_tb'if a.kind=='canonical'else'm007_ln_engine_tb';sources=SOURCES+[LOCAL/'tb'/(top+'.sv')]
 fixture=json.loads((a.fixture/'report.json').read_text());assert fixture['status']=='PASS_ORIGINAL_LN_REFERENCE_AND_SCALARS'
 for name,info in fixture['files'].items():assert sha(a.fixture/name)==info['sha256']
 if a.stage=='build':
  frozen=a.output/'frozen';frozen.mkdir()
  with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
  execute([VIV/'xvlog','--sv',*[frozen/name for name in sources]],a.output);execute([VIV/'xelab','work.'+top,'--relax','-mt','4','--O3','-s','m007_ln_engine_sim'],a.output)
  save(a.output/'source_identity.json',{str(path):sha(frozen/path)for path in sources});save(a.output/'snapshot_build_sha256.json',{'files':inventory(a.output),'captured_utc':datetime.now(timezone.utc).isoformat()});save(a.output/'report.json',{'status':'BUILD_COMPLETE','kind':a.kind,'source_identity':{str(path):sha(frozen/path)for path in sources},'driver_sha256':sha(Path(__file__))});print('M007_LN_ENGINE_BUILD_PASS',flush=True)
 else:
  assert a.build;identity=json.loads((a.build/'source_identity.json').read_text());assert all(sha(ROOT/name)==value and sha(a.build/'frozen'/name)==value for name,value in identity.items())
  if a.rows==128:
   assert a.pilot,'full128 needs applicable same-build16row pilots'
   walls=[];pilots=[]
   for path in a.pilot:
    pilot=json.loads((path/'work/report.json').read_text());receipt=json.loads((path/'receipt.json').read_text())
    assert receipt['status']=='EXIT_ZERO'and pilot['source_identity']==identity and pilot['kind']==a.kind and pilot['measurements']['rows']==16 and pilot['measurements']['mode']==0
    walls.append(receipt['child_wall_s']);pilots.append({'attempt':path.name,'receipt_sha256':sha(path/'receipt.json'),'report_sha256':sha(path/'work/report.json'),'gamma':pilot['measurements']['gamma'],'wall_s':receipt['child_wall_s']})
   assert any(p['gamma']>=a.gamma for p in pilots)
   projection=1.35*8*max(walls)+10;assert projection<=120,projection
   run=a.output.parent.parent.parent;spent=sum(json.loads(p.read_text()).get('child_wall_s',0)for p in(run/'attempts').glob('*/receipt.json')if json.loads(p.read_text())['phase']=='rtl')
   assert 1200-spent>=projection+120,'required originalR002 RTL reserve'
   save(a.output/'cost_projection.json',{'formula':'1.35*8*max(applicable16row child_wall)+10','same_compiled_source_identity':True,'pilots':pilots,'estimated_full_wall_s':projection,'actual_remaining_before_s':1200-spent,'current_child_limit_s':120,'required_archive_reserve_s':120})
  built=json.loads((a.build/'snapshot_build_sha256.json').read_text());pre=inventory(a.build);assert all(pre.get(name)==value for name,value in built['files'].items())
  argv=[VIV/'xsim','m007_ln_engine_sim','-runall','-testplusarg','FIXTURE='+str(a.fixture),'-testplusarg','ROWS='+str(a.rows),'-testplusarg','GAMMA='+str(a.gamma),'-testplusarg','STALL='+str(a.stall),'-testplusarg','MODE='+str(a.mode),'-testplusarg','PROGRESS_FILE='+str(a.output/'semantic_progress.jsonl')]
  save(a.output/'snapshot_prerun_sha256.json',{'files':pre,'command':[str(x)for x in argv],'captured_utc':datetime.now(timezone.utc).isoformat()})
  log=execute(argv,a.build);assert 'HARDWARE_AGENT_SIM_PASS M007_LN_ENGINE' in log
  post=inventory(a.build);assert all(post.get(name)==value for name,value in built['files'].items());save(a.output/'snapshot_postrun_sha256.json',{'files':post,'captured_utc':datetime.now(timezone.utc).isoformat()})
  match=re.search(r'HARDWARE_AGENT_SIM_PASS M007_LN_ENGINE rows=(\d+) gamma=(\d+) stall=(\d+) first=(\d+) done=(\d+) tree_nodes=(\d+) outputs=(\d+) max_contexts=(\d+) held_outputs=(\d+) peak_add=(\d+) peak_mul=(\d+)',log);assert match
  result=dict(zip(('rows','gamma','stall','first_cycles','done_available_cycles','tree_nodes','output_vectors','max_contexts','held_output_cycles','peak_add_pending','peak_mul_pending'),map(int,match.groups())))
  retirement=re.search(r'M007_LN_DONE_RETIRED command_to_retirement=(\d+) held_done_release_barrier=1 mode=(\d+)',log);assert retirement
  result.update(done_retired_cycles=int(retirement[1]),mode=int(retirement[2]))
  if a.mode==2:assert'M007_LN_GAMMA_BEGIN_CMD_ARBITRATION loader_priority=1 coverage_reloaded=32'in log;result['coefficient_begin_command_arbitration']=True
  stages=re.search(r'M007_LN_STAGE_MAX pass1=(\d+) pass2=(\d+) pass3=(\d+) tree_tail=(\d+) div1024=(\d+) sqrt=(\d+) inverse=(\d+)',log)
  if stages:result['stage_max_cycles']=dict(zip(('pass1','pass2','pass3','tree_tail','div1024_with_scheduler','sqrt_with_scheduler','inverse'),map(int,stages.groups())))
  if a.mode in (1,3,4):
   error=re.search(r'M007_LN_NUMERIC_DRAIN stage=(\d+) level=(\d+) row=(\d+) node=(\d+) actual_error_to_done=(\d+)',log);assert error and'M007_LN_NUMERIC_NEWGEN_RECOVERY no_reset=1'in log
   result['observed_numeric_error']=dict(zip(('stage','level','row','node','error_to_done_cycles'),map(int,error.groups())));result['new_generation_complete_recovery_without_reset']=True
  if a.kind=='canonical':
   codec=re.search(r'M007_LN_PUBLIC_CODEC checks=(\d+) invalid_range_checks=(\d+) production_fault_injection=0',log)
   assert codec and tuple(map(int,codec.groups()))==(2816,1032)
   result['public_codec']={'checked_items':int(codec[1]),'invalid_range_checks':int(codec[2]),'scope':'exact production functions through public local codec wrapper; no internal-state injection'}
   offers=re.search(r'M007_LN_OFFER_COUNTS scale=(\d+) sqrt=(\d+) div=(\d+)',log);assert offers
   result['actual_blocked_offer_cycles']=dict(zip(('scale','sqrt','div'),map(int,offers.groups())))
  if a.mode>=10:
   assert a.kind=='canonical'
   if a.mode==15:
    disabled=re.search(r'M007_LN_DIRECTED_DISABLED_GAMMA checks=(\d+) common_reset_qualification=1 persistent_across_disable_clear=1',log)
    assert disabled and int(disabled[1])==34
    result['disabled_owner_gamma']={'union_view_checks':34,'common_reset_qualification':True,'gamma_retained_across_disable_and_legal_retired_clear':True}
   else:
    recovered=re.search(r'M007_LN_DIRECTED_NEWGEN no_reset=1 mode=(\d+) cancel_cases=(\d+) protocol_cases=(\d+)',log)
    assert recovered and int(recovered[1])==a.mode
    counts=tuple(map(int,recovered.groups()[1:]));assert counts==((0,1)if a.mode in(13,14)else(1,0))
    result['directed_protocol']={'mode':a.mode,'cancel_cases':counts[0],'protocol_cases':counts[1],'actual_service_debt_drained':True,'held_terminal_cycles':17,'normal_new_generation_after_error_without_reset':True}
    if a.mode in(10,11,12):
     rejected=re.search(r'M007_LN_DIRECTED_REJECT_CANCEL mode=(\d+) reject=(\d+) held_cycles=(\d+) actual_debt_drained=1',log)
     assert rejected and tuple(map(int,rejected.groups()))==(a.mode,{10:5,11:8,12:6}[a.mode],17)
     result['directed_protocol'].update(reject_code=int(rejected[2]),held_reject_cycles=int(rejected[3]))
    elif a.mode==13:assert'M007_LN_DIRECTED_ACTIVE_CLEAR actual_debt_drained=1'in log
    elif a.mode==14:assert'M007_LN_DIRECTED_BAD_RETURN genuine_return_preserved=1 actual_debt_drained=1'in log
    elif a.mode in(16,17):
     offered=re.search(r'M007_LN_DIRECTED_OFFER_CANCEL mode=(\d+) checked_offer_cycles=(\d+) actual_debt_drained=1',log)
     assert offered and int(offered[1])==a.mode and int(offered[2])>=17
     result['directed_protocol']['checked_blocked_offer_cycles']=int(offered[2])
     assert result['actual_blocked_offer_cycles']['div']>=17
     if a.mode==17:assert result['actual_blocked_offer_cycles']['sqrt']>=17
    else:raise AssertionError('unknown directed mode')
  save(a.output/'report.json',{'status':'PURE_EXTERNAL_CONTROL_UNIT_PASS'if a.kind=='canonical'else'PASS_DEFAULT_LEGACY_COMPAT','kind':a.kind,'scope':'TB-owned q only; same real sharedFP/DIV/LNbank and original numerical checker. No actual common arena, parent fit, finite-source producer proof or complete CPU-error-order claim.','measurements':result,'source_identity':identity,'fixture_report_sha256':sha(a.fixture/'report.json'),
   'snapshot_prerun_sha256':sha(a.output/'snapshot_prerun_sha256.json'),'snapshot_postrun_sha256':sha(a.output/'snapshot_postrun_sha256.json'),'timing_300MHz':'NOT_RUN','parent_phase_physical_sharing':'NOT_RUN'})
if __name__=='__main__':main()
