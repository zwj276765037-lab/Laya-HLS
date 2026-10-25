#!/usr/bin/env python3
"""One original kind7 process, consecutive real success phases, actual layer0 capture, planned stop."""
import argparse,json,os,re,resource,selectors,subprocess,sys,time
from pathlib import Path
PHASE=re.compile(r'^M007_FULLGRAPH_PHASE global=(\d+) state=(\d+) heads=(\d+) matrix_done=(\d+) cycle=(\d+)$')
LAYER=re.compile(r'^M007_FULLGRAPH_LAYER_END global=0 checkpoint=0 cycle=(\d+)$')
CAPTURE=re.compile(r'^M007_LAYER0_CAPTURE_COMPLETE groups=4096 bytes=524288 cycle=(\d+) eval_calls=(\d+)$')
STAGES=['QKV_success']+['head'+str(i)+'_success' for i in range(16)]+['Attention_success','WO_success','residualA_success','LN_success','Down_admitted_after_Wi_G_quant','Down_success','residualB_success','original_layer0_and_actual_H_capture']
class Stop(Exception):
 def __init__(self,verdict,reason):self.verdict=verdict;self.reason=reason
class Segments:
 def __init__(self):self.index=0;self.anchor=0.;self.records=[];self.heads=0;self.matrix=0;self.layer=False;self.capture=False;self.cycle=0;self.ready=False
 def check(self,t):
  if t>600:raise Stop('COST_STOP','global600s_cap')
  if t-self.anchor>120:raise Stop('COST_STOP','continuous120s_cap:'+STAGES[self.index])
 def advance(self,name,line,t):
  if self.ready or name!=STAGES[self.index]:raise Stop('FAIL','missing_duplicate_or_out_of_order:'+name+' expected:'+STAGES[self.index])
  rec={'stage':name,'start_elapsed_s':self.anchor,'end_elapsed_s':t,'duration_seconds':t-self.anchor,'actual_success_line':line,'cycle':self.cycle}
  if self.index==len(STAGES)-1:self.ready=True;rec['pending_planned_child_stop_without_deadline_reset']=True
  else:self.records.append(rec);self.index+=1;self.anchor=t
  return rec
 def feed(self,line,t):
  self.check(t);found=None;p=PHASE.fullmatch(line)
  if p:
   gl,st,heads,md,cy=map(int,p.groups());self.cycle=cy
   if gl==0:
    if heads!=self.heads:
     if heads<=self.heads or heads&(heads+1):raise Stop('FAIL','invalid_head_completion_mask')
     i=heads.bit_length()-1
     if heads!=((self.heads<<1)|1):raise Stop('FAIL','skipped_head_completion')
     self.heads=heads;found='head'+str(i)+'_success'
    if md!=self.matrix:
     if md!=self.matrix+1:raise Stop('FAIL','matrix_retirement_order')
     self.matrix=md
     if md in [1,2,4]:
      if found:raise Stop('FAIL','ambiguous_phase')
      found={1:'QKV_success',2:'WO_success',4:'Down_success'}[md]
    if st==8:found=found or 'Attention_success'
    if st==42:found=found or 'residualA_success'
    if st==47:found=found or 'LN_success'
    if st==12 and md==3:found=found or 'Down_admitted_after_Wi_G_quant'
    if st==55:found=found or 'residualB_success'
  if LAYER.fullmatch(line):
   if self.layer:raise Stop('FAIL','duplicate_original_layer_endpoint')
   self.layer=True;self.cycle=int(LAYER.fullmatch(line).group(1))
  if CAPTURE.fullmatch(line):
   if self.capture:raise Stop('FAIL','duplicate_capture_endpoint')
   self.capture=True;self.cycle=int(CAPTURE.fullmatch(line).group(1))
  if self.layer and self.capture:found='original_layer0_and_actual_H_capture'
  return self.advance(found,line,t) if found else None
 def stopped(self,t):
  self.check(t)
  if not self.ready:raise Stop('FAIL','stopped_without_both_original_endpoint_and_actual_capture')
  self.records.append({'stage':STAGES[-1],'start_elapsed_s':self.anchor,'end_elapsed_s':t,'duration_seconds':t-self.anchor,'includes_planned_child_stop_cleanup':True,'cycle':self.cycle})
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def replay(path,out):
 state=Segments();events=[json.loads(s) for s in path.read_text().splitlines()]
 for z in events:state.feed(z['line'],z['elapsed_s'])
 assert state.index==9 and STAGES[state.index]=='head8_success'
 valid=[z for z in events if PHASE.fullmatch(z['line'])];last=next(z for z in reversed(valid) if 'heads=255 ' in z['line']);cy=153057
 for i in range(8,16):cy+=11044;state.feed(f'M007_FULLGRAPH_PHASE global=0 state=7 heads={(1<<(i+1))-1} matrix_done=1 cycle={cy}',119+(i-7)*8)
 tail=[(8,1),(35,2),(42,2),(47,2),(25,3),(12,3),(31,4),(55,4)]
 t=200
 for st,md in tail:state.feed(f'M007_FULLGRAPH_PHASE global=0 state={st} heads=65535 matrix_done={md} cycle={cy+int(t)}',t);t+=10
 state.feed(f'M007_FULLGRAPH_LAYER_END global=0 checkpoint=0 cycle={cy+300}',300)
 state.feed(f'M007_LAYER0_CAPTURE_COMPLETE groups=4096 bytes=524288 cycle={cy+301} eval_calls=900000',300.01);state.stopped(300.02);assert len(state.records)==25
 checks=[]
 def reject(name,lines,verdict):
  x=Segments()
  try:
   for line,t in lines:x.feed(line,t)
  except Stop as e:assert e.verdict==verdict;checks.append({'case':name,'verdict':e.verdict,'reason':e.reason})
  else:raise AssertionError(name)
 reject('head_before_QKV',[('M007_FULLGRAPH_PHASE global=0 state=7 heads=1 matrix_done=0 cycle=1',1)],'FAIL')
 reject('skip_head',[('M007_FULLGRAPH_PHASE global=0 state=6 heads=0 matrix_done=1 cycle=1',1),('M007_FULLGRAPH_PHASE global=0 state=7 heads=3 matrix_done=1 cycle=2',2)],'FAIL')
 reject('matrix_skip',[('M007_FULLGRAPH_PHASE global=0 state=35 heads=0 matrix_done=2 cycle=1',1)],'FAIL')
 reject('late_success',[('M007_FULLGRAPH_PHASE global=0 state=6 heads=0 matrix_done=1 cycle=1',120.01)],'COST_STOP')
 reject('retired_not_phase_clock',[('M007_RTL_RETIRE_PROGRESS retired=999 cycle=100',119),('M007_RTL_RETIRE_PROGRESS retired=1000 cycle=101',120.01)],'COST_STOP')
 reject('generic_obs_not_phase',[('M007_FULLGRAPH_OBS commands=1 cycle=1',120.01)],'COST_STOP')
 x=Segments();x.index=24;x.anchor=500;x.layer=True;x.capture=True;x.ready=True
 try:x.stopped(600.01)
 except Stop as e:assert e.verdict=='COST_STOP';checks.append({'case':'final_cleanup_counts_global','verdict':e.verdict})
 dump(out,{'verdict':'PASS','actual_prefix_completed_phases':9,'next_expected_phase':'head8_success','synthetic_full_ordered_phases':25,'reject_cases':checks,'only_exact_real_success_predicates_reset_phase':True,'original600_and120_caps':True});print('LAYER0_SEGMENT_REPLAY_PASS',flush=True)
def run(a):
 st=Segments();start=time.monotonic();child=subprocess.Popen(a.command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,bufsize=0);sel=selectors.DefaultSelector();sel.register(child.stdout,selectors.EVENT_READ);pending=b'';first_threads=None;verdict=None;reason=None;fatal=False;original_layer=None;io_last=None
 with a.events.open('x') as ev,a.segments.open('x') as seg:
  try:
   while True:
    elapsed=time.monotonic()-start;st.check(elapsed)
    for key,mask in sel.select(min(.2,600-elapsed,120-(elapsed-st.anchor))):
     chunk=os.read(key.fd,65536)
     if not chunk:raise Stop('FAIL','original_child_exited_before_prefix_endpoint')
     sys.stdout.buffer.write(chunk);sys.stdout.buffer.flush();pending+=chunk
     while b'\n' in pending:
      raw,pending=pending.split(b'\n',1);line=raw.decode('utf-8','replace').rstrip('\r');t=time.monotonic()-start
      if first_threads is None:
       try:first_threads=len(list(Path('/proc',str(child.pid),'task').iterdir()))
       except OSError:first_threads='UNKNOWN'
      if line.startswith(('M007_','HARDWARE_AGENT_SIM_PASS','%Error')):ev.write(json.dumps({'line':line,'elapsed_s':t})+'\n');ev.flush()
      if re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b|M007_LAYER0_CAPTURE_ERROR',line):fatal=True;raise Stop('FAIL','original_or_capture_failure')
      if LAYER.fullmatch(line):original_layer=line
      rec=st.feed(line,t)
      if rec:seg.write(json.dumps(rec)+'\n');seg.flush()
      if st.ready:raise Stop('PREFIX_ENDPOINT_REACHED','original_layer0_and_complete_actual_H')
  except Stop as e:verdict=e.verdict;reason=e.reason
  finally:
   try:io_last={k:int(v) for line in Path('/proc',str(child.pid),'io').read_text().splitlines() for k,v in [line.split(':',1)]}
   except OSError:pass
   if child.poll() is None:
    child.terminate()
    try:child.wait(timeout=.5)
    except subprocess.TimeoutExpired:child.kill();child.wait(timeout=1)
   else:child.wait()
   sel.close()
 elapsed=time.monotonic()-start;artifact=None
 if verdict=='PREFIX_ENDPOINT_REACHED':
  try:
   st.stopped(elapsed);meta=json.loads(a.capture_meta.read_text());assert meta['complete'] and meta['accepted_groups32']==meta['unique_groups32']==4096
   binary=a.capture_binary.read_bytes();assert len(binary)==524288 and binary==a.gold.read_bytes();trace=[json.loads(z) for z in a.capture_trace.read_text().splitlines()];reconstructed=bytearray(524288);seen=set()
   for i,z in enumerate(trace):
    address=z['address'];assert z['accept_seq']==i and 0<=address<4096 and address not in seen;seen.add(address);reconstructed[address*128:(address+1)*128]=int(z['data_hex_lane0_lsb'],16).to_bytes(128,'little')
   assert len(trace)==len(seen)==4096 and bytes(reconstructed)==binary
   st.check(time.monotonic()-start);st.records[-1]['end_elapsed_s']=time.monotonic()-start;st.records[-1]['duration_seconds']=st.records[-1]['end_elapsed_s']-st.anchor
   artifact={'metadata':meta,'bytes':len(binary),'trace_count':len(trace),'unique_groups32':len(seen),'trace_reconstruction_equal_binary':True,'bit_exact_original_encoder0_gold':True,'binary_path':str(a.capture_binary)};verdict='PREFIX_PASS'
  except Stop as e:verdict=e.verdict;reason=e.reason
  except Exception as e:verdict='FAIL';reason='actual_output_integrity:'+repr(e)
 usage=resource.getrusage(resource.RUSAGE_CHILDREN);dump(a.receipt,{'verdict':verdict,'reason':reason,'elapsed_seconds':time.monotonic()-start,'raw_child_return_code':child.returncode,'planned_prefix_stop':verdict=='PREFIX_PASS','fullgraph_complete':False,'original_complete_layer_line':original_layer,'completed_segments':st.records,'next_expected_stage':STAGES[st.index],'observed_child_threads_at_first_stdout':first_threads,'child_cpu_user_seconds':usage.ru_utime,'child_cpu_system_seconds':usage.ru_stime,'child_cpu_total_seconds':usage.ru_utime+usage.ru_stime,'child_maxrss_kb':usage.ru_maxrss,'io_counters_last_observed':io_last,'error_or_fatal':fatal,'actual_output_integrity':artifact,'eval_observer_cost_separately_measured':False,'all_original_stdout_forwarded_unchanged':True});raise SystemExit(0 if verdict=='PREFIX_PASS' else 124 if verdict=='COST_STOP' else 1)
p=argparse.ArgumentParser();p.add_argument('mode',choices=['replay','run']);p.add_argument('--stream',type=Path);p.add_argument('--receipt',type=Path,required=True);p.add_argument('--events',type=Path);p.add_argument('--segments',type=Path);p.add_argument('--capture-meta',type=Path);p.add_argument('--capture-binary',type=Path);p.add_argument('--capture-trace',type=Path);p.add_argument('--gold',type=Path);p.add_argument('--command',nargs=argparse.REMAINDER);a=p.parse_args()
if a.mode=='replay':replay(a.stream,a.receipt)
else:run(a)
