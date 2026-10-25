#!/usr/bin/env python3
"""Own-process lifetime tracking. Never signal an unverified external PID."""
import ctypes
from datetime import datetime,timezone
import os
from pathlib import Path
import signal
import time
def utc():return datetime.now(timezone.utc).isoformat()
def identity(pid):
 try:
  stat=Path(f'/proc/{pid}/stat').read_text();tail=stat[stat.rfind(')')+2:].split()
  return {'pid':pid,'start_ticks':int(tail[19]),'pgid':int(tail[2])}
 except (FileNotFoundError,ProcessLookupError):return None
def descendants(pid):
 result=[]
 try:
  children=Path(f'/proc/{pid}/task/{pid}/children').read_text().split()
 except (FileNotFoundError,ProcessLookupError):return result
 for value in children:
  child=int(value);result.append(child);result.extend(descendants(child))
 return result
def enable_subreaper():
 libc=ctypes.CDLL(None,use_errno=True)
 if libc.prctl(36,1,0,0,0):raise OSError(ctypes.get_errno(),'PR_SET_CHILD_SUBREAPER')
 value=ctypes.c_int()
 if libc.prctl(37,ctypes.byref(value),0,0,0)or value.value!=1:raise RuntimeError('child subreaper not active')
 return True
def observe(tracked):
 for pid in descendants(os.getpid()):
  info=identity(pid)
  if info is not None:tracked[(pid,info['start_ticks'])]=info
def live(tracked):
 result=[]
 for (_,token),info in tuple(tracked.items()):
  current=identity(info['pid'])
  if current is not None and current['start_ticks']==token:result.append(current)
 return result
def group_alive(pgid):
 try:os.killpg(pgid,0);return True
 except ProcessLookupError:return False
def reap(child,tracked):
 child.poll() # Popen owns its leader's wait status.
 observe(tracked)
 for info in live(tracked):
  if info['pid']==child.pid:continue
  try:os.waitpid(info['pid'],os.WNOHANG)
  except (ChildProcessError,ProcessLookupError):pass
def work_remains(child,tracked):
 reap(child,tracked)
 return child.poll()is None or bool(live(tracked))or group_alive(child.pid)
def sample_rss(child,tracked):
 reap(child,tracked);total=0
 for info in live(tracked):
  try:total+=sum(int(line.split()[1])*1024 for line in Path(f"/proc/{info['pid']}/status").read_text().splitlines()if line.startswith('VmRSS:'))
  except (FileNotFoundError,ProcessLookupError):pass
 return total
def finish(child,tracked,receipt,force):
 receipt['cleanup_started']=utc();observe(tracked)
 receipt['owned_before_cleanup']=[x['pid']for x in live(tracked)]
 while True:
  try:
   observe(tracked)
   if force:
    # Signal our original PGID even if its leader already exited.
    try:os.killpg(child.pid,signal.SIGKILL)
    except ProcessLookupError:pass
    for info in live(tracked):
     current=identity(info['pid'])
     if current is not None and current['start_ticks']==info['start_ticks']:
      try:os.kill(info['pid'],signal.SIGKILL)
      except ProcessLookupError:pass
   if not work_remains(child,tracked):break
   time.sleep(.01)
  except BaseException as error:
   # Cleanup cannot be interrupted into an unlock with live owned work.
   force=True;receipt.setdefault('cleanup_exceptions',[]).append(type(error).__name__+': '+str(error))
 receipt['exit_code']=child.wait();receipt['owned_after_cleanup']=[]
 receipt['owned_group_after_cleanup_exists']=group_alive(child.pid)
 receipt['observed_owned_processes']=sorted(tracked.values(),key=lambda x:(x['pid'],x['start_ticks']))
 receipt['cleanup_forced']=force;receipt['cleanup_finished']=utc()
