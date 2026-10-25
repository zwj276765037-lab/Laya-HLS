#!/usr/bin/env python3
import argparse,datetime as dt,json,os,signal,subprocess,time
from pathlib import Path
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args();cmd=a.command[1:]if a.command[:1]==['--']else a.command;start=time.monotonic();stamp=dt.datetime.now(dt.timezone.utc).isoformat();events=[]
 child=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
 for line in child.stdout:
  print(line,end='',flush=True)
  if 'M007_FFN_'in line:
   events.append({'elapsed_s':time.monotonic()-start,'line':line.strip()});a.out.write_text(json.dumps({'started_at':stamp,'command':cmd,'events':events},indent=2)+'\n')
 rc=child.wait();a.out.write_text(json.dumps({'started_at':stamp,'command':cmd,'events':events,'elapsed_s':time.monotonic()-start,'exit_code':rc},indent=2)+'\n');return rc
if __name__=='__main__':raise SystemExit(main())
