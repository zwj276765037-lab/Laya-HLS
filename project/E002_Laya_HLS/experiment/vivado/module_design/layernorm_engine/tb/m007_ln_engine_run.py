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
SOURCES += [LOCAL/'rtl/laya_m007_ln_scalars_v1.sv',LOCAL/'rtl/laya_m007_layernorm32_v1.sv',LOCAL/'tb/m007_ln_engine_tb.sv']
def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',choices=('build','rtl'),required=True);p.add_argument('--output',type=Path,required=True)
 p.add_argument('--fixture',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--pilot',type=Path);p.add_argument('--rows',type=int,default=4);p.add_argument('--gamma',type=int,default=0);p.add_argument('--stall',type=int,default=0);p.add_argument('--mode',type=int,default=0)
 a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 fixture=json.loads((a.fixture/'report.json').read_text());assert fixture['status']=='PASS_ORIGINAL_LN_REFERENCE_AND_SCALARS'
 for name,info in fixture['files'].items():assert sha(a.fixture/name)==info['sha256']
 if a.stage=='build':
  frozen=a.output/'frozen';frozen.mkdir()
  with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
  execute([VIV/'xvlog','--sv',*[frozen/name for name in SOURCES]],a.output);execute([VIV/'xelab','work.m007_ln_engine_tb','--relax','-mt','4','--O3','-s','m007_ln_engine_sim'],a.output)
  save(a.output/'source_identity.json',{str(path):sha(frozen/path)for path in SOURCES});save(a.output/'snapshot_build_sha256.json',{'files':inventory(a.output),'captured_utc':datetime.now(timezone.utc).isoformat()});print('M007_LN_ENGINE_BUILD_PASS',flush=True)
 else:
  assert a.build;identity=json.loads((a.build/'source_identity.json').read_text());assert all(sha(ROOT/name)==value and sha(a.build/'frozen'/name)==value for name,value in identity.items())
  if a.rows==128:
   assert a.pilot;pilot=json.loads((a.pilot/'work/report.json').read_text());receipt=json.loads((a.pilot/'receipt.json').read_text())
   assert pilot['status']=='PASS_REAL_LN_ENGINE'and pilot['source_identity']==identity and pilot['measurements']['rows']>=16 and pilot['measurements']['gamma']>=a.gamma
   projection=1.2*receipt['child_wall_s']*128/pilot['measurements']['rows'];assert projection<=120,projection
   save(a.output/'cost_projection.json',{'same_compiled_source_identity':True,'pilot_receipt_sha256':sha(a.pilot/'receipt.json'),'pilot_report_sha256':sha(a.pilot/'work/report.json'),'pilot_wall_s':receipt['child_wall_s'],'pilot_rows':pilot['measurements']['rows'],'conservative_full_projection_s':projection,'current_child_limit_s':120})
  built=json.loads((a.build/'snapshot_build_sha256.json').read_text());pre=inventory(a.build);assert all(pre.get(name)==value for name,value in built['files'].items())
  argv=[VIV/'xsim','m007_ln_engine_sim','-runall','-testplusarg','FIXTURE='+str(a.fixture),'-testplusarg','ROWS='+str(a.rows),'-testplusarg','GAMMA='+str(a.gamma),'-testplusarg','STALL='+str(a.stall),'-testplusarg','MODE='+str(a.mode)]
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
  save(a.output/'report.json',{'status':'PASS_REAL_LN_PROTOCOL_RESET_RECOVERY'if a.mode==2 else'PASS_REAL_LN_NUMERIC_DRAIN'if a.mode else'PASS_REAL_LN_ENGINE','measurements':result,'source_identity':identity,'fixture_report_sha256':sha(a.fixture/'report.json'),
   'snapshot_prerun_sha256':sha(a.output/'snapshot_prerun_sha256.json'),'snapshot_postrun_sha256':sha(a.output/'snapshot_postrun_sha256.json'),'timing_300MHz':'NOT_RUN','parent_phase_physical_sharing':'NOT_RUN'})
if __name__=='__main__':main()
