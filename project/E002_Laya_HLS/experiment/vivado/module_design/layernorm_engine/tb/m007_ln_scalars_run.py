#!/usr/bin/env python3
"""E014 real scalar RTL with frozen-source and actual runtime library identity."""
import argparse
from datetime import datetime,timezone
import json
from pathlib import Path
import re
import subprocess
import tarfile
from m007_ln_guard import EXPERIMENT as ROOT,sha

VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');LOCAL=Path('vivado/module_design/layernorm_engine')
SOURCES=[LOCAL/'rtl/laya_m007_ln_scalars_v1.sv',LOCAL/'tb/m007_ln_scalars_tb.sv']
def execute(argv,cwd):
 print('COMMAND '+repr([str(x)for x in argv]),flush=True);result=subprocess.run([str(x)for x in argv],cwd=cwd,capture_output=True,text=True)
 print(result.stdout,flush=True);print(result.stderr,flush=True)
 if result.returncode or re.search(r'(?im)^(?:ERROR|FATAL|Fatal):',result.stdout+result.stderr):raise RuntimeError('tool failure')
 return result.stdout+result.stderr
def save(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
def inventory(build):return {str(path.relative_to(build)):{'sha256':sha(path),'bytes':path.stat().st_size}for path in sorted((build/'xsim.dir').rglob('*'))if path.is_file()and path.suffix!='.log'}
def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',choices=('build','rtl'),required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--fixture',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 fixture=json.loads((a.fixture/'report.json').read_text());assert fixture['status']=='PASS_ORIGINAL_LN_REFERENCE_AND_SCALARS'
 for name,info in fixture['files'].items():assert sha(a.fixture/name)==info['sha256']
 if a.stage=='build':
  frozen=a.output/'frozen';frozen.mkdir()
  with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
  execute([VIV/'xvlog','--sv',*[frozen/name for name in SOURCES]],a.output);execute([VIV/'xelab','work.m007_ln_scalars_tb','--relax','-mt','4','--O3','-s','m007_ln_scalars_sim'],a.output)
  save(a.output/'source_identity.json',{str(path):sha(frozen/path)for path in SOURCES});save(a.output/'snapshot_build_sha256.json',{'captured_utc':datetime.now(timezone.utc).isoformat(),'files':inventory(a.output),'excluded':'*.log only'})
  print('M007_LN_SCALARS_BUILD_PASS',flush=True)
 else:
  assert a.build;identity=json.loads((a.build/'source_identity.json').read_text());assert all(sha(ROOT/name)==value and sha(a.build/'frozen'/name)==value for name,value in identity.items())
  built=json.loads((a.build/'snapshot_build_sha256.json').read_text());pre=inventory(a.build);assert any(name.endswith('/xsimk')for name in pre)
  assert all(pre.get(name)==value for name,value in built['files'].items())
  argv=[VIV/'xsim','m007_ln_scalars_sim','-runall','-testplusarg','VECTORS='+str(a.fixture/'scalars.hex'),'-testplusarg','COUNT='+str(fixture['scalar_count'])]
  save(a.output/'snapshot_prerun_sha256.json',{'captured_utc':datetime.now(timezone.utc).isoformat(),'files':pre,'command':[str(x)for x in argv],'build_inventory_sha256':sha(a.build/'snapshot_build_sha256.json')})
  log=execute(argv,a.build);assert 'HARDWARE_AGENT_SIM_PASS M007_LN_SCALARS'in log
  post=inventory(a.build);assert all(post.get(name)==value for name,value in built['files'].items());save(a.output/'snapshot_postrun_sha256.json',{'files':post,'captured_utc':datetime.now(timezone.utc).isoformat()})
  save(a.output/'report.json',{'status':'PASS_EXACT_LN_SCALARS','vectors':fixture['scalar_count'],'div1024_availability_cycles':1,'sqrt_availability_cycles':25,
   'hold_checked':True,'active_reset_checked':True,'source_identity':identity,'fixture_report_sha256':sha(a.fixture/'report.json'),
   'snapshot_prerun_sha256':sha(a.output/'snapshot_prerun_sha256.json'),'snapshot_postrun_sha256':sha(a.output/'snapshot_postrun_sha256.json'),'full_LN_engine':'NOT_RUN','timing_300MHz':'NOT_RUN'})
if __name__=='__main__':main()
