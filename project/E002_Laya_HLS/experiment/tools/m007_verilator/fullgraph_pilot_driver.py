#!/usr/bin/env python3
"""Bound one original kind7 process; preserve stdout and measure real child work."""
import argparse,importlib.util,json,os,re,resource,selectors,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--events',type=Path,required=True);p.add_argument('--receipt',type=Path,required=True);p.add_argument('--seconds',type=float,default=119);p.add_argument('--guard-module',type=Path,required=True);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args();assert 0<a.seconds<=119 and a.command[0]=='--'
spec=importlib.util.spec_from_file_location('progress_guard',a.guard_module);g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
start=time.monotonic();child=subprocess.Popen(a.command[1:],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,bufsize=0);selector=selectors.DefaultSelector();selector.register(child.stdout,selectors.EVENT_READ);pending=b'';highwater=None;first_threads=None;event_count=0;last_line=None;last_cycle=None;terminal_count=0;fatal=False;io_first=None;io_last=None;io_elapsed=None;io_next=0;layers=[];reason=None;verdict=None
terminal='HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=7 layers=30 matrix=120 outputs=544 actual_tail_commit=1'
def sample_io():
 global io_first,io_last,io_elapsed
 try:
  val={k:int(v.strip()) for line in Path('/proc',str(child.pid),'io').read_text().splitlines() for k,v in [line.split(':',1)]}
 except OSError:return
 if io_first is None:io_first=val
 io_last=val;io_elapsed=time.monotonic()-start
with a.events.open('x') as events:
 def line(raw,elapsed):
  global highwater,first_threads,event_count,last_line,last_cycle,terminal_count,fatal
  text=raw.decode('utf-8','replace').rstrip('\r\n')
  if first_threads is None:
   try:first_threads=len(list(Path('/proc',str(child.pid),'task').iterdir()))
   except OSError:first_threads='UNKNOWN'
  if text.startswith(('M007_','HARDWARE_AGENT_SIM_PASS','%Error')):
   events.write(json.dumps({'line':text,'elapsed_s':elapsed})+'\n');events.flush();event_count+=1;last_line=text
  m=re.search(r'\bcycle=(\d+)',text)
  if m:last_cycle=int(m.group(1))
  ok,highwater=g.semantic_progress_advances(text,highwater,'rtl')
  if text.startswith('M007_FULLGRAPH_LAYER_END '):layers.append({'line':text,'elapsed_s':elapsed})
  terminal_count+=text==terminal
  fatal=fatal or bool(re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b',text))
 try:
  eof=False
  while not eof:
   elapsed=time.monotonic()-start
   if elapsed>=a.seconds:verdict='COST_STOP';reason='unknown_kind7_pilot_wall_cap';break
   if elapsed>=io_next:sample_io();io_next=elapsed+1
   for key,mask in selector.select(min(.2,a.seconds-elapsed)):
    chunk=os.read(key.fd,65536)
    if not chunk:eof=True;break
    sys.stdout.buffer.write(chunk);sys.stdout.buffer.flush();pending+=chunk
    while b'\n' in pending:
     raw,pending=pending.split(b'\n',1);line(raw,time.monotonic()-start)
  if pending and eof:line(pending,time.monotonic()-start)
  if verdict=='COST_STOP' and child.poll() is None:
   sample_io();child.terminate()
   try:child.wait(timeout=.3)
   except subprocess.TimeoutExpired:child.kill();child.wait(timeout=.5)
  else:
   sample_io()
   while child.poll() is None:
    if time.monotonic()-start>=a.seconds:
     verdict='COST_STOP';reason='unknown_kind7_pilot_cleanup_cap';child.terminate();child.wait(timeout=.5);break
    time.sleep(.01)
   rc=child.wait()
   if verdict is None:verdict='PASS' if rc==0 and terminal_count==1 and not fatal else 'FAIL';reason='exact_original_terminal_and_normal_exit' if verdict=='PASS' else 'original_process_incomplete_or_nonzero_or_fatal'
 finally:selector.close()
usage=resource.getrusage(resource.RUSAGE_CHILDREN);result={'verdict':verdict,'reason':reason,'elapsed_seconds':time.monotonic()-start,'raw_child_return_code':child.returncode,'child_pid':child.pid,'observed_child_threads_at_first_stdout':first_threads,'child_cpu_user_seconds':usage.ru_utime,'child_cpu_system_seconds':usage.ru_stime,'child_cpu_total_seconds':usage.ru_utime+usage.ru_stime,'child_ru_maxrss_kb':usage.ru_maxrss,'semantic_event_count':event_count,'last_semantic_line':last_line,'last_cycle':last_cycle,'exact_terminal_count':terminal_count,'error_or_fatal':fatal,'progress_stream_highwaters':highwater,'original_layer_endpoints':layers,'io_counters_first_observed':io_first,'io_counters_last_observed':io_last,'io_last_sample_elapsed_s':io_elapsed,'io_scope':'raw OS counters for actual child; read_bytes may be0 for page-cache IO; file IO wall time not separately attributable','all_original_stdout_forwarded_unchanged':True,'source_arithmetic_and_stimulus_unchanged':True}
a.receipt.write_text(json.dumps(result,indent=2)+'\n');raise SystemExit(0 if verdict=='PASS' else 124 if verdict=='COST_STOP' else 1)
