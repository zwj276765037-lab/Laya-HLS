#!/usr/bin/env python3
"""Timestamp flushed actual parent-stage records; never synthesizes progress."""
import argparse,datetime as dt,json,subprocess,time,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args();assert a.command[0]=='--'
t=time.monotonic();events=[]
with subprocess.Popen(a.command[1:],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1) as child:
 for line in child.stdout:
  print(line,end='',flush=True)
  if any(v in line for v in ['MATRIX_PROGRESS parent_state=','MATRIX_PROGRESS parent_QKV_retired_s=','M007_PARENT_HEAD_BEGIN','M007_PARENT_QKV_PREFIX_PASS','M007_PARENT_FIRST_HEAD_PASS']):
   events.append({'elapsed_s':time.monotonic()-t,'line':line.rstrip()})
 rc=child.wait()
a.out.write_text(json.dumps({'scope':'Host observation of flushed actual stage events; no independent cycle oracle','started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'elapsed_s':time.monotonic()-t,'events':events,'child_exit':rc},indent=2)+'\n')
raise SystemExit(rc)
