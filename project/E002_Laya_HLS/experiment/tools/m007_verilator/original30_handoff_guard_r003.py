#!/usr/bin/env python3
"""Additional D35 composite layer27->finalLN->type->Decision0 preLN deadline.

Attach to the existing unique process without altering or restarting its frozen driver.
Only exact source-success events change state; original event elapsed time sets anchor.
"""
import argparse,datetime as dt,json,os,re,signal,time
from pathlib import Path
LAYER=re.compile(r'^M007_FULLGRAPH_LAYER_END global=27 checkpoint=27 cycle=(\d+)$')
PHASE=re.compile(r'^M007_FULLGRAPH_PHASE global=(\d+) state=(\d+) heads=(\d+) matrix_done=(\d+) cycle=(\d+)$')
class Violation(Exception):
 def __init__(self,verdict,reason):self.verdict=verdict;self.reason=reason
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def proc(pid):
 try:
  parts=(Path('/proc')/str(pid)/'stat').read_text().rsplit(')',1)[1].split();return {'state':parts[0],'start_time_ticks':int(parts[19])}
 except OSError:return None
class Boundary:
 def __init__(self):self.anchor=None;self.state=0;self.complete=False;self.events=[]
 def check(self,elapsed):
  if self.anchor is not None and not self.complete and elapsed-self.anchor>120:raise Violation('COST_STOP','whole_layer27_finalLN_type_Decision0_preLN_exceeded120s')
 def feed(self,z):
  line=z['line'];elapsed=z['elapsed_s'];self.check(elapsed)
  if LAYER.fullmatch(line):
   if self.anchor is not None:raise Violation('FAIL','duplicate_original_layer27_endpoint')
   self.anchor=elapsed;self.state=1;self.events.append(z)
  p=PHASE.fullmatch(line)
  if p and self.anchor is not None and not self.complete:
   gl,st,heads,md,cy=map(int,p.groups())
   if gl==27 and st==91:
    if self.state!=1:raise Violation('FAIL','final_gamma_missing_or_duplicate_order')
    self.state=2;self.events.append(z)
   elif gl==27 and st==96:
    if self.state!=2:raise Violation('FAIL','type_before_final_gamma_or_duplicate')
    self.state=3;self.events.append(z)
   elif gl==28 and st==86:
    if self.state!=3:raise Violation('FAIL','Decision0_preLN_before_final_gamma_type')
    self.state=4;self.complete=True;self.events.append(z)
   elif gl>=28 and self.state<3:raise Violation('FAIL','Decision0_entered_before_final_gamma_type')
def test(out):
 valid=[{'line':'M007_FULLGRAPH_LAYER_END global=27 checkpoint=27 cycle=100','elapsed_s':9000.}, {'line':'M007_FULLGRAPH_PHASE global=27 state=91 heads=65535 matrix_done=4 cycle=200','elapsed_s':9040.}, {'line':'M007_FULLGRAPH_PHASE global=27 state=96 heads=65535 matrix_done=4 cycle=300','elapsed_s':9070.}, {'line':'M007_FULLGRAPH_PHASE global=28 state=86 heads=65535 matrix_done=0 cycle=400','elapsed_s':9119.9}]
 b=Boundary()
 for z in valid:b.feed(z)
 assert b.complete and b.anchor==9000
 tests=[]
 for name,events,verdict in [('intermediate_success_does_not_reset',[*valid[:3],dict(valid[3],elapsed_s=9120.01)],'COST_STOP'),('missing_finalLN',[valid[0],valid[2]],'FAIL'),('missing_type',[*valid[:2],valid[3]],'FAIL')]:
  b=Boundary()
  try:
   for z in events:b.feed(z)
  except Violation as e:assert e.verdict==verdict;tests.append({'case':name,'verdict':e.verdict,'reason':e.reason})
  else:raise AssertionError(name)
 b=Boundary();b.feed(valid[0])
 try:b.check(9120.01)
 except Violation as e:assert e.verdict=='COST_STOP';tests.append({'case':'silence_deadline_uses_original_anchor','verdict':e.verdict})
 else:raise AssertionError('silence deadline')
 dump(out,{'verdict':'PASS','valid_whole_duration_seconds':119.9,'original_anchor_preserved_through_finalLN_and_type':True,'reject_cases':tests})
def run(a):
 out=a.attempt/'additional_handoff_guard';out.mkdir(exist_ok=False);test(out/'selftest.json')
 launch=json.loads((a.attempt/'guard_rtl/launch.json').read_text());leader=launch['leader_pid'];ticks=int(launch['leader_start_time_ticks']);p=proc(leader);assert p and p['start_time_ticks']==ticks
 # Kernel process start precedes the original driver's monotonic start by Python startup.
 # Adding original wall_event elapsed_s to this lower bound gives an earlier deadline,
 # never one extended by the late attachment time. Record the exact clock conversion.
 boot_to_mono=time.monotonic()-time.clock_gettime(time.CLOCK_BOOTTIME);origin_lower=ticks/os.sysconf('SC_CLK_TCK')+boot_to_mono
 self_ticks=proc(os.getpid())['start_time_ticks'];attached=dt.datetime.now(dt.timezone.utc).isoformat();identity={'attached_at':attached,'supervisor_pid':os.getpid(),'supervisor_start_time_ticks':self_ticks,'protected_leader_pid':leader,'protected_leader_start_time_ticks':ticks,'original_events_path':str(a.attempt/'work/wall_events.jsonl'),'deadline_seconds':120,'clock_origin_basis':'kernel driver process-start lower bound + original event elapsed_s; conservative, no attach-time reset','clock_origin_lower_monotonic_seconds':origin_lower,'boot_to_monotonic_offset_seconds':boot_to_mono,'nice':os.getpriority(os.PRIO_PROCESS,0),'affinity':sorted(os.sched_getaffinity(0)),'no_model_driver_source_or_signal_mutation':True};dump(out/'launch.json',identity)
 boundary=Boundary();offset=0;pending='';verdict='NOT_REACHED';reason='protected_process_exited_before_boundary';stopped=False
 try:
  while True:
   with (a.attempt/'work/wall_events.jsonl').open() as stream:stream.seek(offset);new=stream.read();offset=stream.tell()
   pending+=new;lines=pending.split('\n');pending=lines.pop()
   for line in lines:
    if not line:continue
    boundary.feed(json.loads(line))
    if boundary.complete:break
   if boundary.complete:verdict='PASS';reason='original_layer27_finalLN_type_Decision0_preLN_completed_within_same120s';break
   current=proc(leader)
   if not current or current['start_time_ticks']!=ticks or current['state']=='Z':break
   # Applies to silence too, bound to original PID creation and original event timestamps.
   boundary.check(time.monotonic()-origin_lower)
   time.sleep(.2)
 except Violation as e:
  verdict=e.verdict;reason=e.reason;current=proc(leader)
  trigger={'verdict':verdict,'reason':reason,'at':dt.datetime.now(dt.timezone.utc).isoformat(),'protected_pid':leader,'protected_start_time_ticks':ticks,'boundary_anchor_original_elapsed_s':boundary.anchor,'events':boundary.events,'supervisor':identity}
  dump(out/'trigger.json',trigger)
  if current and current['start_time_ticks']==ticks and current['state']!='Z':os.kill(leader,signal.SIGTERM);stopped=True
 finally:
  dump(out/'result.json',{'verdict':verdict,'reason':reason,'finished_at':dt.datetime.now(dt.timezone.utc).isoformat(),'launch':identity,'events':boundary.events,'boundary_anchor_original_elapsed_s':boundary.anchor,'whole_handoff_event_seconds':boundary.events[-1]['elapsed_s']-boundary.anchor if boundary.complete else None,'original_anchor_never_reset_by_intermediate_success':True,'verified_owned_leader_terminated':stopped,'fullgraph_acceptance_requires_this_PASS_and_original_driver_guard_PASS':True})
 print(json.dumps({'verdict':verdict,'reason':reason,'handoff_seconds':boundary.events[-1]['elapsed_s']-boundary.anchor if boundary.complete else None}),flush=True)
 raise SystemExit(0 if verdict=='PASS' else 124 if verdict=='COST_STOP' else 1)
p=argparse.ArgumentParser();p.add_argument('mode',choices=['test','run']);p.add_argument('--attempt',type=Path);p.add_argument('--output',type=Path);a=p.parse_args()
if a.mode=='test':test(a.output)
else:run(a)
