#!/usr/bin/env python3
"""Actual sole LN-exp bankset public-port mapping/hold/collision/reset test."""
import argparse
from datetime import datetime,timezone
import json
from pathlib import Path
import tarfile
from m007_ln_scalars_run import ROOT,VIV,LOCAL,execute,save,inventory,sha
SHARED=Path('vivado/module_design/attention_and_fp_engine/rtl')
SOURCES=[SHARED/'laya_attention_storage_v1.sv',SHARED/'laya_ln_exp_storage_v1.sv',LOCAL/'tb/m007_ln_bank_tb.sv']
def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',choices=('build','rtl'),required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 if a.stage=='build':
  frozen=a.output/'frozen';frozen.mkdir()
  with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
  execute([VIV/'xvlog','--sv',*[frozen/name for name in SOURCES]],a.output);execute([VIV/'xelab','work.m007_ln_bank_tb','--relax','-mt','4','--O3','-s','m007_ln_bank_sim'],a.output)
  save(a.output/'source_identity.json',{str(path):sha(frozen/path)for path in SOURCES});save(a.output/'snapshot_build_sha256.json',{'files':inventory(a.output),'captured_utc':datetime.now(timezone.utc).isoformat()});print('M007_LN_BANK_BUILD_PASS',flush=True)
 else:
  assert a.build;identity=json.loads((a.build/'source_identity.json').read_text());assert all(sha(ROOT/name)==value and sha(a.build/'frozen'/name)==value for name,value in identity.items())
  built=json.loads((a.build/'snapshot_build_sha256.json').read_text());pre=inventory(a.build);assert all(pre.get(name)==value for name,value in built['files'].items())
  argv=[VIV/'xsim','m007_ln_bank_sim','-runall'];save(a.output/'snapshot_prerun_sha256.json',{'files':pre,'command':[str(x)for x in argv],'captured_utc':datetime.now(timezone.utc).isoformat()})
  log=execute(argv,a.build);assert 'HARDWARE_AGENT_SIM_PASS M007_LN_BANK'in log
  post=inventory(a.build);assert all(post.get(name)==value for name,value in built['files'].items());save(a.output/'snapshot_postrun_sha256.json',{'files':post,'captured_utc':datetime.now(timezone.utc).isoformat()})
  save(a.output/'report.json',{'status':'PASS_REAL_LN_EXP_BANK256X32','bytes':32768,'banks':256,'depth':32,'same_bank_read_priority_collision':True,'different_context_parallel':True,
   'held_read_ack_rebind_barrier':True,'old_identity_blocked':True,'active_reset_newgen_retains_payload':True,'source_identity':identity,
   'snapshot_prerun_sha256':sha(a.output/'snapshot_prerun_sha256.json'),'snapshot_postrun_sha256':sha(a.output/'snapshot_postrun_sha256.json'),'full_LN_engine':'NOT_RUN'})
if __name__=='__main__':main()
