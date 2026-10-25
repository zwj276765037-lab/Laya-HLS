#!/usr/bin/env python3
"""Real light children: orphan lifetime, sampler/write/interrupt cleanup."""
import argparse
from datetime import datetime,timezone
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import re
import m007_ln_guard as guard
from m007_ln_process_guard import identity,group_alive
SCRIPT=Path(__file__).resolve()
def utc():return datetime.now(timezone.utc).isoformat()
def main():
 p=argparse.ArgumentParser();p.add_argument('--child',choices=('early','live'));p.add_argument('--grandchild',choices=('early','live'));p.add_argument('--pids',type=Path);p.add_argument('--state',type=Path);p.add_argument('--lock',type=Path);p.add_argument('--output',type=Path);p.add_argument('--first-at',type=int,default=26);a=p.parse_args()
 if a.grandchild:
  if a.grandchild=='early':
   time.sleep(.12)
   with a.lock.open('a+')as lock:
    try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB);blocked=False;fcntl.flock(lock,fcntl.LOCK_UN)
    except BlockingIOError:blocked=True
   a.state.write_text(json.dumps({'pid':os.getpid(),'lock_was_still_held_after_leader_exit':blocked,'observed_at':utc()}))
   time.sleep(.15)
  else:
   a.state.write_text(json.dumps({'pid':os.getpid(),'actually_alive':True,'observed_at':utc()}));time.sleep(30)
  return 0
 if a.child:
  child=subprocess.Popen([sys.executable,str(SCRIPT),'--grandchild',a.child,'--state',str(a.state),'--lock',str(a.lock)])
  a.pids.write_text(json.dumps({'leader':identity(os.getpid()),'grandchild':identity(child.pid),'written_at':utc()}))
  if a.child=='live':time.sleep(30)
  return 0
 assert a.output;a.output.parent.mkdir(parents=True,exist_ok=True);results=[]
 original_argv=sys.argv[:];original_sample=guard.sample_rss;original_write=guard.write_receipt
 lock_path=guard.PROJECT/'.research-agent/m007_heavy.lock'
 cases=((f'AT{a.first_at:03d}_guard_orphan_lifetime','early',None),(f'AT{a.first_at+1:03d}_guard_sampling_exception','live','sample'),
        (f'AT{a.first_at+2:03d}_guard_receipt_write_exception','live','write'),(f'AT{a.first_at+3:03d}_guard_keyboard_interrupt','live','interrupt'))
 for attempt,child_mode,fault in cases:
  at=guard.RUN/'attempts'/attempt;pids=at/'child_pids.json';state=at/'grandchild_state.json';injected=[False]
  def wait_live():
   deadline=time.monotonic()+2
   while not(pids.exists()and state.exists()):
    assert time.monotonic()<deadline,'real grandchild did not start';time.sleep(.005)
  def sample(child,tracked):
   value=original_sample(child,tracked)
   if fault in ('sample','interrupt')and pids.exists()and state.exists()and not injected[0]:
    injected[0]=True
    if fault=='interrupt':raise KeyboardInterrupt('SELFTEST_REAL_OWNED_GRANDCHILD')
    raise RuntimeError('SELFTEST_SAMPLING_EXCEPTION_REAL_OWNED_GRANDCHILD')
   return value
  def write(path,value):
   if fault=='write'and value.get('status')=='RUNNING'and not injected[0]:
    wait_live();injected[0]=True;raise OSError('SELFTEST_RECEIPT_WRITE_EXCEPTION_REAL_OWNED_GRANDCHILD')
   return original_write(path,value)
  guard.sample_rss=sample;guard.write_receipt=write
  sys.argv=[str(SCRIPT),'--attempt',attempt,'--phase','static','--seconds','5','--',sys.executable,str(SCRIPT),'--child',child_mode,'--pids',str(pids),'--state',str(state),'--lock',str(lock_path)]
  started=utc();rc=guard.main();returned=utc();receipt=json.loads((at/'receipt.json').read_text());family=json.loads(pids.read_text())
  assert rc==(0 if fault is None else 1)
  assert receipt['status']==('EXIT_ZERO'if fault is None else'INFRASTRUCTURE_FAILURE')
  assert receipt['child_subreaper_enabled']and receipt['owned_after_cleanup']==[]and not receipt['owned_group_after_cleanup_exists']
  assert not group_alive(receipt['pid'])
  for info in family.values():
   if isinstance(info,dict):
    current=identity(info['pid']);assert current is None or current['start_ticks']!=info['start_ticks']
  assert family['grandchild']['pid']in[x['pid']for x in receipt['observed_owned_processes']]
  if fault is None:
   assert json.loads(state.read_text())['lock_was_still_held_after_leader_exit'];assert receipt['child_wall_s']>=.27 and not receipt['cleanup_forced']
  else:assert injected[0]and receipt['cleanup_forced']
  with lock_path.open('a+')as lock:
   try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB);fresh_lock=True;fcntl.flock(lock,fcntl.LOCK_UN)
   except BlockingIOError:fresh_lock=False # A different project task may win immediately after unlock.
  own_lock_rows=[]
  for line in Path('/proc/locks').read_text().splitlines():
   match=re.search(r'\bFLOCK\s+\w+\s+\w+\s+(\d+)\s+(\S+)',line)
   if match and int(match[1])==os.getpid()and match[2].rsplit(':',1)[-1]==str(lock_path.stat().st_ino):own_lock_rows.append(line)
  assert not own_lock_rows,'harness retained its flock after guard return'
  result={'attempt':attempt,'expected_fault':fault,'actual_status':receipt['status'],'guard_return_code':rc,'started':started,'returned':returned,
   'leader':family['leader'],'grandchild':family['grandchild'],'child_wall_s':receipt['child_wall_s'],'cleanup_started':receipt['cleanup_started'],'cleanup_finished':receipt['cleanup_finished'],
   'owned_group_and_all_tracked_descendants_gone':True,'own_flock_absent_after_return':True,'fresh_lock_after_return_acquired':fresh_lock,'other_task_contention_after_return':not fresh_lock,
   'lock_held_after_leader_exit':fault is None,'receipt':'attempts/'+attempt+'/receipt.json'}
  results.append(result)
 guard.sample_rss=original_sample;guard.write_receipt=original_write;sys.argv=original_argv
 a.output.write_text(json.dumps({'status':'PASS_REAL_PROCESS_LIFETIME_AND_EXCEPTION_CLEANUP','host':os.uname().nodename,'harness_pid':os.getpid(),'cases':results,'finished':utc()},indent=2)+'\n')
 print('M007_LN_GUARD_SELFTEST_PASS cases=4 orphan_wait=1 sample_exception=1 write_exception=1 keyboard_interrupt=1 owned_all_gone=1',flush=True)
 return 0
if __name__=='__main__':raise SystemExit(main())
