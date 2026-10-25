import argparse,json,tarfile,subprocess,hashlib,re
from pathlib import Path
M=Path(__file__).resolve().parents[1];ROOT=M.parents[5];V=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);a=p.parse_args();o=a.output;o.mkdir();f=o/'frozen';f.mkdir()
with tarfile.open(o.parent/'sources.tar.gz')as z:z.extractall(f,filter='data')
src=[M/'rtl/laya_m007_control_workspace_v1.sv',M/'tb/m007_control_workspace_tb.sv'];src=[f/x.relative_to(ROOT)for x in src]
if a.stage=='build':
 for cmd in [[V/'xvlog','--sv',*src],[V/'xelab','work.m007_control_workspace_tb','--relax','-mt','4','--O3','-s','control_unit_sim']]:subprocess.run(list(map(str,cmd)),cwd=o,check=True)
 report={'status':'BUILD_COMPLETE','source_sha256':{str(x.relative_to(f)):sha(x)for x in src}}
else:
 subprocess.run([str(V/'xsim'),'control_unit_sim','-runall'],cwd=a.build,check=True);s=(a.build/'xsim.log').read_text();assert 'HARDWARE_AGENT_SIM_PASS CONTROL_WORKSPACE'in s and not re.search(r'(?im)^\s*(?:Fatal|ERROR):',s);(o/'xsim.log').write_text(s);report={'status':'PASS','build_manifest_sha256':sha(a.build/'report.json'),'marker':next(x for x in s.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS'))}
(o/'report.json').write_text(json.dumps(report,indent=2)+'\n')
