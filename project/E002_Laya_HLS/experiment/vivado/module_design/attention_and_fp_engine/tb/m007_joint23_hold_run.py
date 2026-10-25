#!/usr/bin/env python3
import argparse,hashlib,json,re,shutil,subprocess,tarfile
from pathlib import Path
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
ids=json.loads((o.parent/'receipt.json').read_text())['source_sha256'];selected={n:h for n,h in ids.items()if Path(n).suffix in ['.sv','.v','.dat']or n.endswith('/m007_joint23_hold_run.py')}
for n,h in selected.items():assert sha(f/n)==h
for n in ids:
 if n.endswith('.dat'):shutil.copy2(f/n,o/Path(n).name)
if a.stage=='build':
 files=sorted([f/n for n in selected if Path(n).suffix in ['.sv','.v']],key=lambda q:(q.name!='laya_m007_tanh_fast_leaves_v1.sv',q.name))
 for cmd in [[str(VIV/'xvlog'),'--sv',*[str(q)for q in files]],[str(VIV/'xelab'),'work.m007_joint23_hold_tb','--relax','-debug','typical','-mt','4','--O3','-s','joint23_hold_sim']]:subprocess.run(cmd,cwd=o,check=True)
 save(o/'report.json',{'status':'BUILD_COMPLETE','driver_sha256':sha(Path(__file__)),'source_sha256':selected,'snapshot':{str(q.relative_to(o)):sha(q)for q in(o/'xsim.dir').rglob('*')if q.is_file()}})
else:
 b=a.build;m=json.loads((b/'report.json').read_text());assert m['status']=='BUILD_COMPLETE'and sha(Path(__file__))==m['driver_sha256']
 for n,h in m['source_sha256'].items():assert ids[n]==h
 for n,h in m['snapshot'].items():assert sha(b/n)==h
 subprocess.run([str(VIV/'xsim'),'joint23_hold_sim','-runall','-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')],cwd=b,check=True)
 log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log);marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS JOINT23_HOLD '))
 save(o/'report.json',{'status':'PASS','scope':'REAL_JOINT_FP_DIV_HELD17_AND_INACTIVE_PUBLIC','result_marker':marker,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__))})
