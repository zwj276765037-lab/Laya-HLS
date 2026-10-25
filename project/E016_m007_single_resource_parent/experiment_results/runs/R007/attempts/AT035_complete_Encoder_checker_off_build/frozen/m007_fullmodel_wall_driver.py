#!/usr/bin/env python3
import argparse,json,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--events',type=Path,required=True);p.add_argument('cmd',nargs=argparse.REMAINDER);a=p.parse_args();assert a.cmd[0]=='--';start=time.monotonic();rows=[]
child=subprocess.Popen(a.cmd[1:],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
for line in child.stdout:
 print(line,end='',flush=True)
 if line.startswith(('JOINT23_LN_','JOINT27_','JOINT23_STAGE','HARDWARE_AGENT_SIM_PASS','M007_FULLMODEL_','M007_PARENT_CHECKED')):
  rows.append({'line':line.strip(),'elapsed_s':time.monotonic()-start});a.events.write_text(json.dumps({'events':rows},indent=2)+'\n')
raise SystemExit(child.wait())
