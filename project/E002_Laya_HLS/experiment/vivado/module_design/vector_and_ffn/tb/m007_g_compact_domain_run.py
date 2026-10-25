#!/usr/bin/env python3
"""Real compact-domain input/context tests for G math and the physical pool."""
import argparse,hashlib,json,re,shutil,subprocess,tarfile
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5];LOCAL=MODULE.relative_to(ROOT)
SHARED=MODULE.parent/'attention_and_fp_engine/rtl/laya_return_vector_credit_v1.sv'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def execute(cmd,cwd):print('COMMAND',*[str(x)for x in cmd],flush=True);subprocess.run([str(x)for x in cmd],cwd=cwd,check=True)
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--kind',choices=('pool','math'),required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 names=['rtl/laya_m007_tanh_fast_leaves_v1.sv','rtl/laya_m007_tanh_add3_e_v1.sv','rtl/laya_m007_g_vector_pool_v1.sv']
 shared=[]
 if a.kind=='math':
  dst=f/SHARED.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(SHARED,dst);shared=[dst]
  names+=['rtl/laya_m007_tanh_div12_r4_v1.sv','rtl/laya_m007_tanh_lane_v1.sv','rtl/laya_m007_tanh8_v1.sv','rtl/laya_m007_g_math_v1.sv']
 names+=['tb/m007_g_compact_'+a.kind+'_domain_tb.sv'];sources=[*shared,*[f/LOCAL/name for name in names]];top='m007_g_compact_'+a.kind+'_domain_tb';snapshot='g_compact_'+a.kind+'_domain_sim'
 if a.stage=='build':
  execute([VIV/'xvlog','--sv',*sources],o);execute([VIV/'xelab','work.'+top,'--relax','-mt','4','--O3','-s',snapshot],o)
  save(o/'report.json',{'status':'BUILD_COMPLETE','kind':a.kind,'scope':'Actual production '+a.kind+' public input-domain/context rejection, full-sequence and held/empty retention tests; no state force','source_sha256':{str(x.relative_to(f)):sha(x)for x in sources},'driver_sha256':sha(Path(__file__)),'snapshot':{str(x.relative_to(o)):sha(x)for x in(o/'xsim.dir').rglob('*')if x.is_file()}})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert m['kind']==a.kind and sha(Path(__file__))==m['driver_sha256']
  for path,digest in m['source_sha256'].items():assert sha(f/path)==digest,'selected source/build mismatch'
  for path,digest in m['snapshot'].items():assert sha(b/path)==digest,'snapshot mismatch'
  cmd=[VIV/'xsim',snapshot,'-runall'];identity={'kind':a.kind}
  if a.kind=='math':
   fi=json.loads((a.fixture/'report.json').read_text());v=a.fixture/'geglu_vectors.hex';assert fi['count']==335872 and sha(v)==fi['vectors_sha256'];identity.update(fixture_report_sha256=sha(a.fixture/'report.json'),vectors_sha256=sha(v));cmd+=['-testplusarg','VECTORS='+str(v)]
  else:identity.update(inputs='F32 exact1.0 and0.5 for actual mul/add channels',independent_expected='exact0.5 multiplication and1.5 addition, full96-bit accepted-tag scoreboard')
  save(o/'input_identity.json',identity);execute(cmd,b);log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS G_COMPACT_'+a.kind.upper()+'_DOMAIN'));metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',marker)}
  if a.kind=='pool':assert metrics['cases']==8 and metrics['actual_accepts']==metrics['actual_returns']==9 and metrics['rejected_inputs']==7 and metrics['f32_checks']==72
  else:assert metrics['cases']==7 and metrics['actual_inputs']==metrics['actual_outputs']==7 and metrics['rejected_inputs']==6 and metrics['node_checks']==560 and metrics['checked']==56 and metrics['held17']==17
  save(o/'report.json',{'status':'PASS','kind':a.kind,'scope':'Actual public full-domain validation before compact encoding; context held across empty/held results, same-low8 different fullseq rejected; private clear only after actual debt drains; not full G performance or parent fit','build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'input_identity_sha256':sha(o/'input_identity.json'),'metrics':metrics,'result_marker':marker,'xsim_log_sha256':sha(o/'xsim.log')})
if __name__=='__main__':main()
