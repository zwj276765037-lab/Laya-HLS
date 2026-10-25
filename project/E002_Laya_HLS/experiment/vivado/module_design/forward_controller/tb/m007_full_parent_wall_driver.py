#!/usr/bin/env python3
import argparse,datetime as dt,json,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args();assert a.command[0]=='--';start=time.monotonic();utc=dt.datetime.now(dt.timezone.utc).isoformat();events=[]
with subprocess.Popen(a.command[1:],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1) as child:
 for line in child.stdout:
  print(line,end='',flush=True)
  if any(x in line for x in ['MATRIX_PROGRESS parent_state=','MATRIX_PROGRESS parent_QKV_retired_s=','M007_PARENT_QKV_ALL_END','M007_PARENT_HEAD_BEGIN','M007_PARENT_HEAD_END','M007_PARENT_LAYER_ALL_END','M007_PARENT_A_PUBLISH','M007_PARENT_CONTEXT_ALL_END','M007_PARENT_WO_BEGIN','M007_PARENT_WO_BLOCK_END','M007_PARENT_WO_ALL_END','M007_PARENT_WO_DONE','M007_PARENT_FIRST_SUCCESS','M007_PARENT_SUCCESS_HELD_PASS','M007_PARENT_FULL_CYCLES']):events.append({'elapsed_s':time.monotonic()-start,'line':line.rstrip()})
 rc=child.wait()
a.out.write_text(json.dumps({'scope':'Flushed actual event wall observations; numerical progress comes only from independently checked markers','started_at':utc,'finished_at':dt.datetime.now(dt.timezone.utc).isoformat(),'elapsed_s':time.monotonic()-start,'events':events,'child_exit':rc},indent=2)+'\n');raise SystemExit(rc)
