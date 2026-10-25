#!/usr/bin/env python3
"""Bounded pair-client verification against one actual native storage instance."""
import argparse,hashlib,json,re,shutil,subprocess,tarfile
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5];LOCAL=MODULE.relative_to(ROOT)
SHARED=MODULE.parent/'attention_and_fp_engine/rtl/laya_attention_storage_v1.sv'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def execute(cmd,cwd):print('COMMAND',*[str(x)for x in cmd],flush=True);subprocess.run([str(x)for x in cmd],cwd=cwd,check=True)
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','rtl'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 shared=f/SHARED.relative_to(ROOT);shared.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(SHARED,shared)
 sources=[shared,f/LOCAL/'rtl/laya_m007_g_pairs_v1.sv',f/LOCAL/'tb/m007_g_pairs_tb.sv']
 if a.stage=='build':
  execute([VIV/'xvlog','--sv',*sources],o);execute([VIV/'xelab','work.m007_g_pairs_tb','--relax','-mt','4','--O3','-s','g_pairs_sim'],o)
  save(o/'report.json',{'status':'BUILD_COMPLETE','scope':'G pair client and exactly one full native storage; PS/context ports disabled; no GEGLU arithmetic','source_sha256':{str(x.relative_to(f)):sha(x)for x in sources},'driver_sha256':sha(Path(__file__)),'snapshot':{str(x.relative_to(o)):sha(x)for x in(o/'xsim.dir').rglob('*')if x.is_file()}})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert sha(Path(__file__))==m['driver_sha256']
  for path,digest in m['source_sha256'].items():assert sha(f/path)==digest,'selected source/build mismatch'
  for path,digest in m['snapshot'].items():assert sha(b/path)==digest,'compiled snapshot mismatch'
  execute([VIV/'xsim','g_pairs_sim','-runall'],b)
  log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS G_PAIRS'))
  metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',marker)}
  assert metrics['writes']==1025 and metrics['read_vectors']==1537 and metrics['f32_checks']==24592 and metrics['real_overlap']>0
  save(o/'report.json',{'status':'PASS','scope':'Independent bank-pattern/identity/ACK/coverage and read-return/slot0->1->0/release/discard protocol only; no G arithmetic/output-rate or full-rank claim','build_manifest_sha256':sha(b/'report.json'),'selected_sources_sha256':m['source_sha256'],'metrics':metrics,'client_consumed_vectors':'diagnostic client model follows actual read-response consumption; not a GEGLU output retirement proof','result_marker':marker,'xsim_log_sha256':sha(o/'xsim.log')})
if __name__=='__main__':main()
