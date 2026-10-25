#!/usr/bin/env python3
"""Actual terminal-output arrival times; no cycle-based wall-time inference."""
import argparse,datetime,errno,json,os,pty,re,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',required=True);p.add_argument('argv',nargs=argparse.REMAINDER);a=p.parse_args();cmd=a.argv[1:]if a.argv and a.argv[0]=='--'else a.argv
start=time.monotonic();events=[];master,slave=pty.openpty();child=subprocess.Popen(cmd,stdin=subprocess.DEVNULL,stdout=slave,stderr=slave);os.close(slave);pending=b''
try:
 while True:
  try:chunk=os.read(master,65536)
  except OSError as e:
   if e.errno==errno.EIO:break
   raise
  if not chunk:break
  pending+=chunk
  while b'\n'in pending:
   raw,pending=pending.split(b'\n',1);line=raw.decode(errors='replace').rstrip('\r');print(line,flush=True)
   if'M011_LAYER_'in line:
    e={'elapsed_seconds':time.monotonic()-start,'line':line};m=re.search(r'HEAD_(BEGIN|END) head=(\d+)',line)
    if m:e.update(kind=m.group(1).lower(),head=int(m.group(2)))
    events.append(e);Path(a.out).write_text(json.dumps({'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'events':events,'elapsed_seconds':time.monotonic()-start,'complete':False},indent=2)+'\n')
 if pending:print(pending.decode(errors='replace'),flush=True)
finally:os.close(master)
rc=child.wait();Path(a.out).write_text(json.dumps({'events':events,'elapsed_seconds':time.monotonic()-start,'complete':True,'child_exit':rc,'timing':'monotonic actual PTY line arrival, never cycle extrapolation'},indent=2)+'\n');raise SystemExit(rc)
