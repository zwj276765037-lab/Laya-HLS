#!/usr/bin/env python3
"""Original public kind6 process; fixed consecutive success stages, normal DONE and exit."""
import argparse,hashlib,json,os,re,resource,selectors,subprocess,sys,time
from pathlib import Path
PHASE=re.compile(r'^M007_FULLGRAPH_PHASE global=(\d+) state=(\d+) heads=(\d+) matrix_done=(\d+) cycle=(\d+)$')
FC2=re.compile(r'^M007_DECISION_FC2_ADMITTED global=(\d+) writes=(\d+) acks=(\d+) closed=(\d+) success=(\d+) published=(\d+) debt=(\d+) cycle=(\d+)$')
LAYER=re.compile(r'^M007_FULLGRAPH_LAYER_END global=28 checkpoint=30 cycle=(\d+)$')
CAPTURE=re.compile(r'^M007_LAYER_CAPTURE_COMPLETE global=28 groups=4096 bytes=524288 cycle=(\d+) eval_calls=(\d+)$')
PASS='HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=6 layers=1 matrix=4 outputs=4096 actual_tail_commit=0'
STAGES=['preLN_success','QKV_success']+['head'+str(i)+'_success' for i in range(16)]+['Attention_success','WO_success','residualA_success','postLN_success','FC2_admitted_after_full_FC1_ReLU_quant','FC2_success','residualB_success','original_layer28_actual_H_public4096_success_DONE_idle_exit']
class Stop(Exception):
 def __init__(self,verdict,reason):self.verdict=verdict;self.reason=reason
class Segments:
 def __init__(self):self.index=0;self.anchor=0.;self.records=[];self.heads=0;self.matrix=0;self.layer=False;self.capture=False;self.passed=False;self.cycle=0;self.fc2_state=False;self.ready=False
 def check(self,t):
  if t>600:raise Stop('COST_STOP','global600s_cap')
  if t-self.anchor>120:raise Stop('COST_STOP','continuous120s_cap:'+STAGES[self.index])
 def advance(self,name,line,t):
  if self.ready or name!=STAGES[self.index]:raise Stop('FAIL','missing_duplicate_or_out_of_order:'+name+' expected:'+STAGES[self.index])
  rec={'stage':name,'start_elapsed_s':self.anchor,'end_elapsed_s':t,'duration_seconds':t-self.anchor,'actual_success_line':line,'cycle':self.cycle}
  if self.index==len(STAGES)-1:self.ready=True
  else:self.records.append(rec);self.index+=1;self.anchor=t
  return rec
 def feed(self,line,t):
  self.check(t);found=None;p=PHASE.fullmatch(line)
  if p:
   gl,st,heads,md,cy=map(int,p.groups());self.cycle=cy
   if gl==28:
    if heads!=self.heads:
     if heads<=self.heads or heads&(heads+1) or heads!=((self.heads<<1)|1):raise Stop('FAIL','invalid_or_skipped_head_mask')
     self.heads=heads;found='head'+str(heads.bit_length()-1)+'_success'
    if md!=self.matrix:
     if md!=self.matrix+1:raise Stop('FAIL','matrix_retirement_order')
     self.matrix=md
     if md in [1,2,4]:
      if found:raise Stop('FAIL','ambiguous_success')
      found={1:'QKV_success',2:'WO_success',4:'FC2_success'}[md]
    if st==86:found=found or 'preLN_success'
    if st==8:found=found or 'Attention_success'
    if st==42:found=found or 'residualA_success'
    if st==47:found=found or 'postLN_success'
    if st==102:
     if md!=3:raise Stop('FAIL','FC2_before_three_matrix_successes')
     self.fc2_state=True
    if st==55:found=found or 'residualB_success'
  f=FC2.fullmatch(line)
  if f:
   gl,writes,acks,closed,success,published,debt,cy=map(int,f.groups());self.cycle=cy
   if gl!=28 or (writes,acks,closed,success,published,debt)!=(16384,16384,1,1,1,0) or not self.fc2_state:raise Stop('FAIL','FC2_full_actual_write_ACK_publish_barrier')
   found='FC2_admitted_after_full_FC1_ReLU_quant'
  if LAYER.fullmatch(line):
   if self.layer:raise Stop('FAIL','duplicate_original_layer_endpoint')
   if self.index!=25:raise Stop('FAIL','early_layer_endpoint')
   self.layer=True
  if CAPTURE.fullmatch(line):
   if self.capture:raise Stop('FAIL','duplicate_capture_endpoint')
   if self.index!=25:raise Stop('FAIL','early_capture_endpoint')
   self.capture=True
  if line==PASS:
   if self.passed or not self.layer or not self.capture or self.index!=25:raise Stop('FAIL','original_PASS_before_complete_Decision_endpoints')
   self.passed=True;found=STAGES[-1]
  return self.advance(found,line,t) if found else None
 def exited(self,t):
  self.check(t)
  if not self.ready or not self.passed:raise Stop('FAIL','child_exited_without_original_success_DONE_and_idle')
  self.records.append({'stage':STAGES[-1],'start_elapsed_s':self.anchor,'end_elapsed_s':t,'duration_seconds':t-self.anchor,'normal_child_exit_included':True,'cycle':self.cycle})
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def replay(out):
 lines=[('M007_FULLGRAPH_PHASE global=28 state=86 heads=0 matrix_done=0 cycle=1',1),('M007_FULLGRAPH_PHASE global=28 state=6 heads=0 matrix_done=1 cycle=2',2)]
 for i in range(16):lines.append((f'M007_FULLGRAPH_PHASE global=28 state=7 heads={(1<<(i+1))-1} matrix_done=1 cycle={i+3}',i+3))
 for st,md in [(8,1),(35,2),(42,2),(47,2),(100,3),(102,3)]:lines.append((f'M007_FULLGRAPH_PHASE global=28 state={st} heads=65535 matrix_done={md} cycle={len(lines)+1}',len(lines)+1))
 lines.append(('M007_DECISION_FC2_ADMITTED global=28 writes=16384 acks=16384 closed=1 success=1 published=1 debt=0 cycle=25',25))
 lines += [('M007_FULLGRAPH_PHASE global=28 state=103 heads=65535 matrix_done=4 cycle=26',26),('M007_FULLGRAPH_PHASE global=28 state=55 heads=65535 matrix_done=4 cycle=27',27),('M007_FULLGRAPH_LAYER_END global=28 checkpoint=30 cycle=28',28),('M007_LAYER_CAPTURE_COMPLETE global=28 groups=4096 bytes=524288 cycle=28 eval_calls=64',28.01),(PASS,29)]
 state=Segments()
 for line,t in lines:state.feed(line,t)
 state.exited(29.1);assert len(state.records)==26
 checks=[]
 def reject(name,events,verdict):
  x=Segments()
  try:
   for line,t in events:x.feed(line,t)
  except Stop as e:assert e.verdict==verdict,(name,e.verdict);checks.append({'case':name,'verdict':e.verdict,'reason':e.reason})
  else:raise AssertionError(name)
 reject('QKV_before_preLN',[lines[1]],'FAIL')
 reject('skipped_head',lines[:2]+[('M007_FULLGRAPH_PHASE global=28 state=7 heads=3 matrix_done=1 cycle=3',3)],'FAIL')
 reject('early_PASS',[(PASS,1)],'FAIL')
 reject('FC2_short_ACK',[(l.replace('acks=16384','acks=16383'),t) for l,t in lines],'FAIL')
 reject('FC2_missing_publication',[(l.replace('published=1','published=0'),t) for l,t in lines],'FAIL')
 reject('FC2_before_real_state102',[(l,t) for l,t in lines if 'state=102 ' not in l],'FAIL')
 reject('duplicate_preLN',[lines[0],lines[0]],'FAIL')
 reject('heartbeat_does_not_reset',[('M007_RTL_RETIRE_PROGRESS retired=1 cycle=1',119),('M007_RTL_RETIRE_PROGRESS retired=2 cycle=2',120.01)],'COST_STOP')
 reject('FC1_BEGIN_does_not_reset',[(l,t) for l,t in lines if t<=22]+[('M007_FULLGRAPH_PHASE global=28 state=99 heads=65535 matrix_done=2 cycle=100',141),('M007_RTL_RETIRE_PROGRESS retired=1000 cycle=200',142.01)],'COST_STOP')
 reject('wrong_global_no_credit',[('M007_FULLGRAPH_PHASE global=0 state=86 heads=0 matrix_done=0 cycle=1',120.01)],'COST_STOP')
 reject('overall600',[(l,t) for l,t in lines[:2]]+[('M007_FULLGRAPH_OBS cycle=100',600.01)],'COST_STOP')
 dump(out,{'verdict':'PASS','synthetic_source_predicate_ordered_phases':26,'reject_cases':checks,'global_seconds':600,'consecutive_seconds':120,'FC1_BEGIN_counters_and_retirement_do_not_reset_phase':True,'final_requires_original_PASS_and_normal_exit':True});print('DECISION_SEGMENT_REPLAY_PASS',flush=True)
def run(a):
 st=Segments();start=time.monotonic();child=subprocess.Popen(a.command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,bufsize=0);sel=selectors.DefaultSelector();sel.register(child.stdout,selectors.EVENT_READ);pending=b'';verdict='FAIL';reason='incomplete';fatal=False;first_threads=None;io_last=None
 with a.events.open('x') as ev,a.segments.open('x') as seg:
  try:
   done=False
   while not done:
    elapsed=time.monotonic()-start;st.check(elapsed)
    for key,mask in sel.select(min(.2,600-elapsed,120-(elapsed-st.anchor))):
     chunk=os.read(key.fd,65536)
     if not chunk:done=True;break
     sys.stdout.buffer.write(chunk);sys.stdout.buffer.flush();pending+=chunk
     while b'\n' in pending:
      raw,pending=pending.split(b'\n',1);line=raw.decode('utf-8','replace').rstrip('\r');t=time.monotonic()-start
      if first_threads is None:
       try:first_threads=len(list(Path('/proc',str(child.pid),'task').iterdir()))
       except OSError:first_threads='UNKNOWN'
      if line.startswith(('M007_','HARDWARE_AGENT_SIM_PASS','%Error')):ev.write(json.dumps({'line':line,'elapsed_s':t})+'\n');ev.flush()
      if re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b|M007_LAYER_CAPTURE_ERROR',line):fatal=True;raise Stop('FAIL','original_or_capture_failure')
      rec=st.feed(line,t)
      if rec:seg.write(json.dumps(rec)+'\n');seg.flush()
   child.wait(timeout=max(.01,min(1,600-(time.monotonic()-start))));st.exited(time.monotonic()-start)
   if child.returncode!=0:raise Stop('FAIL','nonzero_original_child_exit')
   meta=json.loads(a.capture_meta.read_text());assert meta['complete'] and meta['global_layer']==28 and meta['accepted_groups32']==meta['unique_groups32']==4096
   binary=a.capture_binary.read_bytes();gold=a.gold.read_bytes();public=a.public_output.read_bytes();assert len(binary)==524288 and binary==gold==public
   trace=[json.loads(z) for z in a.capture_trace.read_text().splitlines()];rebuilt=bytearray(524288);seen=set()
   for i,z in enumerate(trace):
    address=z['address'];assert z['global_layer']==28 and z['accept_seq']==i and 0<=address<4096 and address not in seen;seen.add(address);rebuilt[128*address:128*(address+1)]=int(z['data_hex_lane0_lsb'],16).to_bytes(128,'little')
   assert len(trace)==len(seen)==4096 and bytes(rebuilt)==binary
   receipt=a.original_receipt.read_text();assert 'kind=6 layer=0 ' in receipt and 'layers=1 matrices=4 LN=2 vector=2 GEGLU=0 tail_commits=0 done_consumed=1 ' in receipt
   st.check(time.monotonic()-start);verdict='PASS';reason='complete_original_Decision0_26_phases_actual_H_public_output_DONE_idle_normal_exit'
   artifact={'metadata':meta,'bytes':len(binary),'sha256':hashlib.sha256(binary).hexdigest(),'trace_count':len(trace),'unique_groups32':len(seen),'trace_reconstruction_equal_binary':True,'bit_exact_original_decision0_gold_and_public_output':True,'original_receipt':receipt}
  except Stop as e:verdict=e.verdict;reason=e.reason;artifact=None
  except Exception as e:verdict='FAIL';reason='driver_or_actual_integrity:'+repr(e);artifact=None
  finally:
   try:io_last={k:int(v) for line in Path('/proc',str(child.pid),'io').read_text().splitlines() for k,v in [line.split(':',1)]}
   except OSError:pass
   if child.poll() is None:
    child.terminate()
    try:child.wait(timeout=.5)
    except subprocess.TimeoutExpired:child.kill();child.wait(timeout=1)
   else:child.wait()
   sel.close()
 usage=resource.getrusage(resource.RUSAGE_CHILDREN);dump(a.receipt,{'verdict':verdict,'reason':reason,'elapsed_seconds':time.monotonic()-start,'raw_child_return_code':child.returncode,'planned_prefix_stop':False,'fullgraph_complete':False,'public_kind6_component_complete':verdict=='PASS','completed_segments':st.records,'next_expected_stage':None if verdict=='PASS' else STAGES[st.index],'observed_child_threads_at_first_stdout':first_threads,'child_cpu_user_seconds':usage.ru_utime,'child_cpu_system_seconds':usage.ru_stime,'child_cpu_total_seconds':usage.ru_utime+usage.ru_stime,'child_maxrss_kb':usage.ru_maxrss,'io_counters_last_observed':io_last,'error_or_fatal':fatal,'actual_output_integrity':artifact,'observer_cost_separately_measured':False,'all_original_stdout_forwarded_unchanged':True});raise SystemExit(0 if verdict=='PASS' else 124 if verdict=='COST_STOP' else 1)
p=argparse.ArgumentParser();p.add_argument('mode',choices=['replay','run']);p.add_argument('--receipt',type=Path,required=True)
for name in ['events','segments','capture-meta','capture-binary','capture-trace','gold','public-output','original-receipt']:p.add_argument('--'+name,type=Path)
p.add_argument('--command',nargs=argparse.REMAINDER);a=p.parse_args()
if a.mode=='replay':replay(a.receipt)
else:run(a)
