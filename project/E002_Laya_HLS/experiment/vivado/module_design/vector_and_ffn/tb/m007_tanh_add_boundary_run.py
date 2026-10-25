#!/usr/bin/env python3
import argparse,hashlib,json,re,subprocess,tarfile
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5];LOCAL=MODULE.relative_to(ROOT)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','reference'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 if a.stage=='build':
  f=o/'frozen';f.mkdir()
  with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
  src=f/LOCAL/'tb/m007_tanh_add_boundary_reference.cpp';cmd=['/usr/bin/g++','-O2','-std=c++17','-fno-fast-math','-frounding-math','-ffp-contract=off',str(src),'-o',str(o/'native_add_boundary')];subprocess.run(cmd,check=True);save(o/'report.json',{'status':'BUILD_COMPLETE','source_sha256':sha(src),'binary_sha256':sha(o/'native_add_boundary'),'command':cmd})
 else:
  b=a.build;m=json.loads((b/'report.json').read_text());assert sha(b/'native_add_boundary')==m['binary_sha256'];r=subprocess.run([str(b/'native_add_boundary'),str(o/'vectors.hex')],check=True,text=True,capture_output=True);print(r.stdout,flush=True);count=int(re.search(r'count=(\d+)',r.stdout)[1]);assert count==sum(1 for _ in(o/'vectors.hex').open());identity={'sha256':sha(o/'vectors.hex'),'bytes':(o/'vectors.hex').stat().st_size,'count':count,'generator_source_sha256':m['source_sha256'],'binary_sha256':m['binary_sha256'],'independent_reference':'native SSE separate volatile F32 add, FE_TONEAREST, FTZ/DAZ off; maxfinite/half-ULP neighbor/carry/cancellation/both-sign and tiny boundaries'};save(o.parent/'fixture_identity.json',identity);save(o/'report.json',{'status':'REFERENCE_COMPLETE',**identity})
if __name__=='__main__':main()
