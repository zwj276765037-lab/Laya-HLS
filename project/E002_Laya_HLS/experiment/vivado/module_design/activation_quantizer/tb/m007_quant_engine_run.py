#!/usr/bin/env python3
"""Real shared-div8/32mul XSim integration; always launched through E013 guard."""
import argparse
from datetime import datetime,timezone
import json
from pathlib import Path
import re
import tarfile
from m007_quant_local_run import ROOT,VIV,LOCAL,sha,execute

SHARED=Path('vivado/module_design/attention_and_fp_engine/rtl')
SOURCES=[LOCAL/'rtl/laya_m007_quant_format_v1.sv',LOCAL/'rtl/laya_m007_quant_amax32_v1.sv',
 *[SHARED/name for name in('laya_return_vector_credit_v1.sv','laya_fdiv_rne_v1.sv','laya_shared_div8_v1.sv','laya_fmul_rne_v1.sv')],
 LOCAL/'rtl/laya_m007_quant_group32_v1.sv',LOCAL/'tb/m007_quant_engine_tb.sv']
def verify(folder,status):
 report=json.loads((folder/'report.json').read_text());assert report['status']==status
 for name,info in report['files'].items():assert sha(folder/name)==info['sha256']
 return report
def inventory(build):
 return {str(path.relative_to(build)):{'sha256':sha(path),'bytes':path.stat().st_size}
  for path in sorted((build/'xsim.dir').rglob('*'))if path.is_file()and path.suffix!='.log'}
def save_json(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',choices=('build','rtl'),required=True);p.add_argument('--mode',choices=('pilot','full','protocol'),default='pilot')
 p.add_argument('--output',type=Path,required=True);p.add_argument('--fixture',type=Path,required=True);p.add_argument('--diagnostics',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args()
 a.output.mkdir(parents=True,exist_ok=True);verify(a.fixture,'PASS_INDEPENDENT_QUANT_REFERENCE');verify(a.diagnostics,'PASS_ORIGINAL_QUANT_INTERMEDIATES')
 if a.stage=='build':
  frozen=a.output/'frozen';frozen.mkdir()
  with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
  execute([VIV/'xvlog','--sv',*[frozen/name for name in SOURCES]],a.output)
  execute([VIV/'xelab','work.m007_quant_engine_tb','--relax','-mt','4','--O3','-s','m007_quant_engine_sim'],a.output)
  save_json(a.output/'source_identity.json',{str(path):sha(frozen/path)for path in SOURCES})
  save_json(a.output/'source_binding.json',{'kind':'actually_compiled_frozen_sources','archive_sha256':sha(a.output.parent/'sources.tar.gz'),
   'frozen_root':str(frozen),'source_identity_sha256':sha(a.output/'source_identity.json')})
  compiled=inventory(a.output);assert any(name.endswith('/xsimk')for name in compiled),'missing actual simulation executable'
  save_json(a.output/'snapshot_build_sha256.json',{'captured_utc':datetime.now(timezone.utc).isoformat(),'files':compiled,'excluded':'*.log only'})
  print('M007_QUANT_ENGINE_BUILD_PASS real_shared_div8=1 real_strict_mul=32',flush=True)
 else:
  assert a.build
  identity=json.loads((a.build/'source_identity.json').read_text());assert all(sha(ROOT/name)==value and sha(a.build/'frozen'/name)==value for name,value in identity.items()),'stale static build'
  argv=[VIV/'xsim','m007_quant_engine_sim','-runall']
  for value in('FIXTURE='+str(a.fixture),'DIAGNOSTICS='+str(a.diagnostics),'MODE='+a.mode):argv+=['-testplusarg',value]
  pre=inventory(a.build);built=json.loads((a.build/'snapshot_build_sha256.json').read_text())
  assert all(pre.get(name)==value for name,value in built['files'].items()),'compiled snapshot differs from actual build'
  save_json(a.output/'snapshot_prerun_sha256.json',{'captured_utc':datetime.now(timezone.utc).isoformat(),'build':str(a.build),'command':[str(x)for x in argv],
   'files':pre,'build_inventory_sha256':sha(a.build/'snapshot_build_sha256.json'),'frozen_source_identity_sha256':sha(a.build/'source_identity.json'),'excluded':'*.log only'})
  log=execute(argv,a.build);assert 'HARDWARE_AGENT_SIM_PASS M007_QUANT_ENGINE mode='+a.mode in log,'missing terminal self-check'
  post=inventory(a.build);assert all(post.get(name)==value for name,value in built['files'].items()),'compiled snapshot changed during run'
  save_json(a.output/'snapshot_postrun_sha256.json',{'captured_utc':datetime.now(timezone.utc).isoformat(),'files':post,'excluded':'*.log only'})
  metrics=[]
  for match in re.finditer(r'M007_QUANT_STREAM_PASS name=(\S+) groups=(\d+) first_cycles=(\d+) span_cycles=(\d+) max_reservations=(\d+) products=(\d+)',log):
   name,*values=match.groups();metrics.append(dict(zip(('name','groups','first_cycles','span_cycles','max_reservations','products'),(name,*map(int,values)))))
  lease_metrics=[]
  for match in re.finditer(r'M007_QUANT_LEASE_METRIC name=(\S+) wait_cycles=(\d+) lease_to_first_input=(\d+) observed_reset_edges_total=(\d+)',log):
   name,*values=match.groups();lease_metrics.append(dict(zip(('name','wait_cycles','lease_to_first_input','observed_reset_edges_total'),(name,*map(int,values)))))
  assert len(lease_metrics)==len(metrics),'missing separately observed lease/init metrics'
  (a.output/'report.json').write_text(json.dumps({'status':'PASS_REAL_QUANT_ENGINE_'+a.mode.upper(),'streams':metrics,'lease_initialization_metrics':lease_metrics,'real_shared_div8_instances':1,
   'strict_mul_instances':32,'source_identity':identity,'fixture_report_sha256':sha(a.fixture/'report.json'),
   'snapshot_prerun_sha256':sha(a.output/'snapshot_prerun_sha256.json'),'snapshot_postrun_sha256':sha(a.output/'snapshot_postrun_sha256.json'),
   'compiled_snapshot_build_identity_sha256':sha(a.build/'snapshot_build_sha256.json'),'frozen_source_binding':json.loads((a.build/'source_binding.json').read_text()),
   'diagnostic_report_sha256':sha(a.diagnostics/'report.json'),'timing_300MHz':'NOT_RUN','parent_graph':'NOT_RUN'},indent=2)+'\n')
if __name__=='__main__':main()
