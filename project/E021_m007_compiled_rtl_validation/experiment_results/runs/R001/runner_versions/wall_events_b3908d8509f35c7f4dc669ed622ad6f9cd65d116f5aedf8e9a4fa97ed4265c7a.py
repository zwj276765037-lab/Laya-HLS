#!/usr/bin/env python3
"""Forward original RTL output unchanged and append real event timestamps."""
import argparse,json,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--events',type=Path,required=True);p.add_argument('cmd',nargs=argparse.REMAINDER);a=p.parse_args();assert a.cmd[0]=='--';start=time.monotonic();child=subprocess.Popen(a.cmd[1:],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
with a.events.open('x') as events:
 for line in child.stdout:
  stamp=time.monotonic()-start;print(line,end='',flush=True)
  if line.startswith(('M007_','JOINT','HARDWARE_AGENT_SIM_PASS','%Error')):
   events.write(json.dumps({'line':line.rstrip('\n'),'elapsed_s':stamp})+'\n');events.flush()
raise SystemExit(child.wait())
