#!/usr/bin/env python3
"""One actual256lane shared FP phase6 dependency and affected phase1/3 regression."""
import argparse
from datetime import datetime,timezone
import json
from pathlib import Path
import tarfile
from m007_ln_scalars_run import ROOT,VIV,LOCAL,execute,save,inventory,sha
SHARED=Path('vivado/module_design/attention_and_fp_engine/rtl')
SOURCES=[SHARED/name for name in('laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv','laya_fp_return_credit_v1.sv','laya_shared_fp256_v2.sv')]+[LOCAL/'tb/m007_ln_phase6_tb.sv']
def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',choices=('build','rtl'),required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--fixture',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 fixture=json.loads((a.fixture/'report.json').read_text());assert fixture['status']=='PASS_ORIGINAL_LN_REFERENCE_AND_SCALARS'
 for name,info in fixture['files'].items():assert sha(a.fixture/name)==info['sha256']
 if a.stage=='build':
  frozen=a.output/'frozen';frozen.mkdir()
  with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
  execute([VIV/'xvlog','--sv',*[frozen/name for name in SOURCES]],a.output);execute([VIV/'xelab','work.m007_ln_phase6_tb','--relax','-mt','4','--O3','-s','m007_ln_phase6_sim'],a.output)
  save(a.output/'source_identity.json',{str(path):sha(frozen/path)for path in SOURCES});save(a.output/'snapshot_build_sha256.json',{'files':inventory(a.output),'captured_utc':datetime.now(timezone.utc).isoformat()});print('M007_LN_PHASE6_BUILD_PASS',flush=True)
 else:
  assert a.build;identity=json.loads((a.build/'source_identity.json').read_text());assert all(sha(ROOT/name)==value and sha(a.build/'frozen'/name)==value for name,value in identity.items())
  pre=inventory(a.build);built=json.loads((a.build/'snapshot_build_sha256.json').read_text());assert all(pre.get(name)==value for name,value in built['files'].items())
  argv=[VIV/'xsim','m007_ln_phase6_sim','-runall','-testplusarg','FIXTURE='+str(a.fixture)];save(a.output/'snapshot_prerun_sha256.json',{'files':pre,'command':[str(x)for x in argv],'captured_utc':datetime.now(timezone.utc).isoformat()})
  log=execute(argv,a.build);assert 'HARDWARE_AGENT_SIM_PASS M007_LN_PHASE6'in log
  post=inventory(a.build);assert all(post.get(name)==value for name,value in built['files'].items());save(a.output/'snapshot_postrun_sha256.json',{'files':post,'captured_utc':datetime.now(timezone.utc).isoformat()})
  save(a.output/'report.json',{'status':'PASS_REAL_PHASE6_AND_PHASE1_3_REGRESSION','lanes':256,'add_groups':7,'phase6_dependency_cycles':8,'phase1_dependency_cycles':9,'phase3_dependency_cycles':8,
   'full_mul_and_add_64_reservations':True,'real_hold_falls_into_reserved_slot':True,'active_reset_and_new_generation':True,'source_identity':identity,
   'snapshot_prerun_sha256':sha(a.output/'snapshot_prerun_sha256.json'),'snapshot_postrun_sha256':sha(a.output/'snapshot_postrun_sha256.json'),'full_LN_engine':'NOT_RUN','timing_300MHz':'NOT_RUN'})
if __name__=='__main__':main()
