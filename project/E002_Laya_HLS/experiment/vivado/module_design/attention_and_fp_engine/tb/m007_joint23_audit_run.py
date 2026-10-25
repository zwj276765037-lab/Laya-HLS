#!/usr/bin/env python3
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
h=o/'hierarchy_scopes.txt';t=o/'hierarchy.tcl';t.write_text('set h [open {'+str(h)+'} w]\nforeach scope [get_scopes -r /*] {puts $h $scope}\nclose $h\nquit\n')
t.write_text(t.read_text().replace('quit\n', 'set v [get_value -radix unsigned /m007_joint23_tb/dut/joint/vector_engine/EXTERNAL_CONTROL]\nset p [open {'+str(o/'vector_external_control.txt')+'} w]\nputs $p $v\nclose $p\nquit\n'))
subprocess.run([str(VIV/'xsim'),'joint23_sim','-tclbatch',str(t)],cwd=a.build,check=True)
helper=ROOT/'project/E019_m007_residual_ln_residency/experiment_source/audit_joint23_release.py'
subprocess.run(['python3',str(helper),'--output',str(o/'audit'),'--hierarchy',str(h),'--vector-parameter',str(o/'vector_external_control.txt')],check=True)
r=json.loads((o/'audit/report.json').read_text());r['hierarchy_scope_count']=len(h.read_text().splitlines());(o/'report.json').write_text(json.dumps(r,indent=2)+'\n')
