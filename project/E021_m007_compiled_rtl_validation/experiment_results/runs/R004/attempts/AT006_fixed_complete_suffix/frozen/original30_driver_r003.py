#!/usr/bin/env python3
"""D35 once-BEGIN original30: fixed global/layer/stage deadlines and actual artifacts."""
import argparse,hashlib,json,os,re,resource,selectors,subprocess,sys,time
from pathlib import Path
PHASE=re.compile(r'^M007_FULLGRAPH_PHASE global=(\d+) state=(\d+) heads=(\d+) matrix_done=(\d+) cycle=(\d+)$')
FC2=re.compile(r'^M007_DECISION_FC2_ADMITTED global=(\d+) writes=(\d+) acks=(\d+) closed=(\d+) success=(\d+) published=(\d+) debt=(\d+) cycle=(\d+)$')
LAYER=re.compile(r'^M007_FULLGRAPH_LAYER_END global=(\d+) checkpoint=(\d+) cycle=(\d+)$')
CAPTURE=re.compile(r'^M007_LAYER_CAPTURE_COMPLETE global=(\d+) groups=4096 bytes=524288 cycle=(\d+) eval_calls=(\d+)$')
LEGACY=re.compile(r'^M007_LAYER0_CAPTURE_COMPLETE groups=4096 bytes=524288 cycle=(\d+) eval_calls=(\d+)$')
PASS='HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=7 layers=30 matrix=120 outputs=544 actual_tail_commit=1'
FINAL_COUNTS={'commands':1,'h_count':4096,'catalog_runtime':120,'matrix_commands':120,'layers_completed':30,'ln_commands':60,'vector_commands':61,'g_commands':28,'exports':544,'tail_commits':1,'tail_writes':544,'final_norm_count':4096,'type_count':4096,'global_layer':29}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def sha(data):return hashlib.sha256(data).hexdigest()
def plan(gl):return ([] if gl==0 else ['preLN_success'])+['QKV_success']+['head'+str(i)+'_success' for i in range(16)]+['Attention_success','WO_success','residualA_success','postLN_success',('Down_admitted_after_complete_Wi_G_quant' if gl<28 else 'FC2_admitted_after_complete_FC1_ReLU_quant'),('Down_success' if gl<28 else 'FC2_success'),'residualB_success','original_layer_endpoint_and_actual_H']
class Stop(Exception):
 def __init__(self,verdict,reason):self.verdict=verdict;self.reason=reason
class Flow:
 def __init__(self,gl=0,replay_component=False,legacy=False):
  self.gl=gl;self.mode='layer';self.index=0;self.anchor=0.;self.layer_anchor=0.;self.heads=0;self.matrix=0;self.qkv=False;self.fc2_state=False;self.layer_seen=False;self.capture_seen=False;self.completed=[];self.records=[];self.layers=[];self.cycle=0;self.obs={};self.passed=False;self.replay_component=replay_component;self.legacy=legacy
 def expected(self):return plan(self.gl)[self.index] if self.mode=='layer' else {'finalLN':'final_gamma_LN_success','type':'type_add_success','tail':'complete_original_tail_flush_commit_DONE_idle_exit'}[self.mode]
 def check(self,t):
  if t>15000:raise Stop('COST_STOP','global15000s_cap')
  if self.mode=='layer' and t-self.layer_anchor>600:raise Stop('COST_STOP',f'layer600s_cap:global{self.gl}')
  if t-self.anchor>120:raise Stop('COST_STOP','continuous120s_cap:'+self.expected())
 def advance(self,name,line,t):
  if self.passed or name!=self.expected():raise Stop('FAIL','missing_duplicate_or_out_of_order:'+name+' expected:'+self.expected())
  rec={'global_layer':self.gl,'stage':name,'start_elapsed_s':self.anchor,'end_elapsed_s':t,'duration_seconds':t-self.anchor,'cycle':self.cycle,'actual_success_line':line};self.records.append(rec)
  if self.mode=='layer':
   if name==plan(self.gl)[-1]:
    self.layers.append({'global_layer':self.gl,'start_elapsed_s':self.layer_anchor,'end_elapsed_s':t,'duration_seconds':t-self.layer_anchor,'cycle':self.cycle});self.completed.append(self.gl)
    if self.gl==27:self.mode='finalLN'
    elif self.gl==29:self.mode='tail'
    else:self.new_layer(self.gl+1,t)
   else:self.index+=1
  elif self.mode=='finalLN':self.mode='type'
  elif self.mode=='type':self.new_layer(28,t)
  else:self.passed=True
  # Only these exact successful stage endpoints move the stage anchor.
  if not self.passed:self.anchor=t
  return rec
 def new_layer(self,gl,t):
  self.gl=gl;self.mode='layer';self.index=0;self.layer_anchor=t;self.heads=0;self.matrix=0;self.qkv=False;self.fc2_state=False;self.layer_seen=False;self.capture_seen=False
 def feed(self,line,t):
  self.check(t);found=None;p=PHASE.fullmatch(line)
  if p:
   gl,st,heads,md,cy=map(int,p.groups())
   if cy<self.cycle:raise Stop('FAIL','phase_cycle_regression')
   self.cycle=cy
   if self.replay_component and gl==0 and self.gl>=28 and not self.qkv:return None
   if self.mode in ['finalLN','type']:
    if gl!=27:raise Stop('FAIL','Decision_before_final_gamma_and_type')
    if self.mode=='finalLN' and st==91:found='final_gamma_LN_success'
    elif self.mode=='type' and st==96:found='type_add_success'
   elif self.mode=='tail':
    if gl!=29:raise Stop('FAIL','wrong_global_during_final_tail')
   elif gl!=self.gl:
    if gl in self.completed and st==97:return None
    raise Stop('FAIL',f'global_handoff_before_prior_actual_endpoint:{gl} expected:{self.gl}')
   else:
    # The previous head mask may remain until the new actual prepare. No credit before QKV.
    if md!=self.matrix:
     if md!=self.matrix+1:raise Stop('FAIL','matrix_retirement_order')
     self.matrix=md
     if md==1:
      if heads!=0:raise Stop('FAIL','new_QKV_with_nonzero_head_mask')
      self.qkv=True;self.heads=0;found='QKV_success'
     elif md==2:found='WO_success'
     elif md==4:found='Down_success' if gl<28 else 'FC2_success'
    if self.qkv and heads!=self.heads:
     if heads<=self.heads or heads&(heads+1) or heads!=((self.heads<<1)|1):raise Stop('FAIL','invalid_skipped_or_regressed_head_mask')
     if found:raise Stop('FAIL','ambiguous_success_events')
     self.heads=heads;found='head'+str(heads.bit_length()-1)+'_success'
    if st==86:found=found or 'preLN_success'
    if st==8:found=found or 'Attention_success'
    if st==42:found=found or 'residualA_success'
    if st==47:found=found or 'postLN_success'
    if st==12 and md==3 and gl<28:found=found or 'Down_admitted_after_complete_Wi_G_quant'
    if st==102:
     if gl<28 or md!=3:raise Stop('FAIL','FC2_before_three_actual_matrix_successes')
     self.fc2_state=True
    if st==55:found=found or 'residualB_success'
  f=FC2.fullmatch(line)
  if f:
   gl,writes,acks,closed,success,published,debt,cy=map(int,f.groups())
   if self.mode!='layer' or gl!=self.gl or gl<28 or not self.fc2_state or (writes,acks,closed,success,published,debt)!=(16384,16384,1,1,1,0):raise Stop('FAIL','FC2_before_full16384_actual_write_ACK_success_publish')
   self.cycle=cy;found='FC2_admitted_after_complete_FC1_ReLU_quant'
  l=LAYER.fullmatch(line);c=CAPTURE.fullmatch(line);legacy=LEGACY.fullmatch(line) if self.legacy else None
  if l or c or legacy:
   gl=int((l or c).group(1)) if not legacy else 0
   if self.mode!='layer' or gl!=self.gl or self.expected()!=plan(gl)[-1]:raise Stop('FAIL','early_wrong_or_duplicate_actual_layer_endpoint')
   if l:
    if int(l.group(2))!=(gl if gl<28 else gl+2) or self.layer_seen:raise Stop('FAIL','checkpoint_identity_or_duplicate_layer')
    self.layer_seen=True;self.cycle=int(l.group(3))
   else:
    if self.capture_seen:raise Stop('FAIL','duplicate_actual_capture')
    self.capture_seen=True;self.cycle=int(legacy.group(1) if legacy else c.group(2))
   if self.layer_seen and self.capture_seen:found=plan(gl)[-1]
  if line.startswith('M007_FULLGRAPH_OBS '):
   self.obs={k:int(v) for k,v in re.findall(r'([A-Za-z0-9_]+)=(\d+)',line)}
  if line==PASS:
   if self.mode!='tail' or self.completed!=list(range(30)) or any(self.obs.get(k)!=v for k,v in FINAL_COUNTS.items()):raise Stop('FAIL','PASS_before30_layers_or_full_original_counts')
   found=self.expected()
  return self.advance(found,line,t) if found else None
 def exited(self,t):
  self.check(t)
  if not self.passed:raise Stop('FAIL','normal_exit_without_complete_original_PASS')
  self.records[-1]['end_elapsed_s']=t;self.records[-1]['duration_seconds']=t-self.anchor;self.records[-1]['normal_child_exit_and_artifact_integrity_included']=True
def actual_capture(prefix,gl,gold_dir,trace_check=True):
 stem=Path(str(prefix)+'.layer'+str(gl));binary=Path(str(stem)+'.f32.bin').read_bytes();meta=json.loads(Path(str(stem)+'.capture.json').read_text());gold=gold_dir/(f'encoder_{gl:02d}_out.f32.bin' if gl<28 else f'decision_{gl-28:02d}_out.f32.bin')
 assert len(binary)==524288 and binary==gold.read_bytes() and meta['complete'] and meta['global_layer']==gl and meta['accepted_groups32']==meta['unique_groups32']==4096
 if trace_check:
  seen=set();rebuilt=bytearray(524288);count=0
  with Path(str(stem)+'.accepted.jsonl').open() as f:
   for i,line in enumerate(f):
    z=json.loads(line);a=z['address'];assert z['global_layer']==gl and z['accept_seq']==i and 0<=a<4096 and a not in seen;seen.add(a);rebuilt[128*a:128*(a+1)]=int(z['data_hex_lane0_lsb'],16).to_bytes(128,'little');count+=1
  assert count==len(seen)==4096 and bytes(rebuilt)==binary
 return {'global_layer':gl,'bytes':len(binary),'sha256':sha(binary),'original_gold_path':str(gold),'metadata':meta,'trace_unique4096_and_independent_reconstruction_equal':trace_check}
def replay(a):
 root=a.root;r2=root/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002/attempts';actual=[]
 for name,gl in [('AT005_first_original_layer',0),('AT010_kind6_public_abi',28),('AT011_kind6_decision1',29)]:
  f=Flow(gl,replay_component=True,legacy=True)
  for raw in (r2/name/'work/wall_events.jsonl').read_text().splitlines():
   z=json.loads(raw);f.feed(z['line'],z['elapsed_s'])
   if f.completed==[gl]:break
  assert f.completed==[gl] and len(f.layers)==1
  actual.append({'attempt':name,'raw_event_replay':True,'component_only':True,'completed_global_layer':gl,'real_stage_count':len(f.records),'layer_seconds':f.layers[0]['duration_seconds']})
 synthetic=[];t=0.;cy=0
 def add(line):
  nonlocal t,cy;t+=1;cy+=1;synthetic.append((line.format(cy=cy),t))
 for gl in range(30):
  add(f'M007_FULLGRAPH_PHASE global={gl} state=82 heads=65535 matrix_done=0 cycle={{cy}}')
  if gl:add(f'M007_FULLGRAPH_PHASE global={gl} state=86 heads=65535 matrix_done=0 cycle={{cy}}')
  add(f'M007_FULLGRAPH_PHASE global={gl} state=6 heads=0 matrix_done=1 cycle={{cy}}')
  for i in range(16):add(f'M007_FULLGRAPH_PHASE global={gl} state=7 heads={(1<<(i+1))-1} matrix_done=1 cycle={{cy}}')
  for st,md in [(8,1),(35,2),(42,2),(47,2),(25 if gl<28 else 100,3),(12 if gl<28 else 102,3)]:add(f'M007_FULLGRAPH_PHASE global={gl} state={st} heads=65535 matrix_done={md} cycle={{cy}}')
  if gl>=28:add(f'M007_DECISION_FC2_ADMITTED global={gl} writes=16384 acks=16384 closed=1 success=1 published=1 debt=0 cycle={{cy}}')
  add(f'M007_FULLGRAPH_PHASE global={gl} state={31 if gl<28 else 103} heads=65535 matrix_done=4 cycle={{cy}}')
  add(f'M007_FULLGRAPH_PHASE global={gl} state=55 heads=65535 matrix_done=4 cycle={{cy}}')
  add(f'M007_FULLGRAPH_LAYER_END global={gl} checkpoint={gl if gl<28 else gl+2} cycle={{cy}}')
  add(f'M007_LAYER_CAPTURE_COMPLETE global={gl} groups=4096 bytes=524288 cycle={{cy}} eval_calls=9999999')
  if gl==27:
   for st in [91,96]:add(f'M007_FULLGRAPH_PHASE global=27 state={st} heads=65535 matrix_done=4 cycle={{cy}}')
 add('M007_FULLGRAPH_OBS '+' '.join(k+'='+str(v) for k,v in FINAL_COUNTS.items()));add(PASS)
 flow=Flow()
 for line,stamp in synthetic:flow.feed(line,stamp)
 flow.exited(t+.1);assert flow.completed==list(range(30)) and len(flow.records)==782
 checks=[]
 def reject(name,lines,verdict,start_gl=0):
  f=Flow(start_gl)
  try:
   for line,stamp in lines:f.feed(line,stamp)
  except Stop as e:assert e.verdict==verdict,(name,e.reason);checks.append({'case':name,'verdict':e.verdict,'reason':e.reason})
  else:raise AssertionError(name)
 reject('skip_layer',[('M007_FULLGRAPH_PHASE global=1 state=82 heads=0 matrix_done=0 cycle=1',1)],'FAIL')
 reject('skip_head',synthetic[:2]+[('M007_FULLGRAPH_PHASE global=0 state=7 heads=3 matrix_done=1 cycle=3',3)],'FAIL')
 reject('missing_actual_capture',[(l,s) for l,s in synthetic if not l.startswith('M007_LAYER_CAPTURE_COMPLETE global=0 ')],'FAIL')
 reject('missing_final_gamma',[(l,s) for l,s in synthetic if not ('global=27 state=91 ' in l)],'FAIL')
 reject('missing_type',[(l,s) for l,s in synthetic if not ('global=27 state=96 ' in l)],'FAIL')
 reject('FC2_short_ACK',[(l.replace('acks=16384','acks=16383'),s) for l,s in synthetic],'FAIL')
 reject('early_PASS',[(PASS,1)],'FAIL')
 reject('heartbeat_does_not_reset',[('M007_RTL_RETIRE_PROGRESS retired=1 cycle=1',119),('M007_RTL_RETIRE_PROGRESS retired=2 cycle=2',120.01)],'COST_STOP')
 reject('global_cap',[('M007_FULLGRAPH_OBS cycle=1',15000.01)],'COST_STOP')
 f=Flow();f.anchor=590
 try:f.check(600.01)
 except Stop as e:assert e.reason.startswith('layer600');checks.append({'case':'layer600_not_reset_by_stage','verdict':e.verdict})
 else:raise AssertionError('layer cap')
 f=Flow();f.mode='tail';f.gl=29;f.anchor=500
 try:f.feed('M007_FULLGRAPH_PHASE global=29 state=108 heads=65535 matrix_done=4 cycle=1',620.01)
 except Stop as e:assert e.verdict=='COST_STOP';checks.append({'case':'tail_wait_does_not_reset_final120','verdict':e.verdict})
 else:raise AssertionError('tail cap')
 dump(a.receipt,{'verdict':'PASS','raw_actual_component_replays':actual,'synthetic_fullgraph_ordered_stages':782,'synthetic_fullgraph_layers':30,'reject_cases':checks,'global_seconds':15000,'layer_seconds':600,'consecutive_seconds':120,'finalLN_and_type_explicit':True,'tail_all_work_through_exit_one120_segment':True});print('ORIGINAL30_REPLAY_PASS',flush=True)
def run(a):
 start=time.monotonic();flow=Flow();child=subprocess.Popen(a.command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,bufsize=0);sel=selectors.DefaultSelector();sel.register(child.stdout,selectors.EVENT_READ);pending=b'';verdict='FAIL';reason='incomplete';fatal=False;thread_samples=[];last_thread=-10.;artifacts=[];io_last=None
 def status(t):dump(a.status,{'execution_state':'running','elapsed_seconds':t,'completed_layers':flow.completed,'current_global_layer':flow.gl,'mode':flow.mode,'next_expected_stage':flow.expected(),'stage_anchor_elapsed_s':flow.anchor,'layer_anchor_elapsed_s':flow.layer_anchor,'last_cycle':flow.cycle,'last_stage':flow.records[-1] if flow.records else None,'actual_thread_samples':thread_samples,'observer_or_status_not_semantic_progress':True})
 with a.events.open('x') as ev,a.segments.open('x') as seg,a.layers.open('x') as layers:
  try:
   eof=False
   while not eof:
    elapsed=time.monotonic()-start;flow.check(elapsed)
    if elapsed-last_thread>=10:
     n=len(list(Path('/proc',str(child.pid),'task').iterdir()));thread_samples.append({'elapsed_s':elapsed,'threads':n});last_thread=elapsed
     if n!=1:raise Stop('FAIL','actual_model_process_not_single_thread')
     status(elapsed)
    for key,mask in sel.select(.2):
     chunk=os.read(key.fd,65536)
     if not chunk:eof=True;break
     sys.stdout.buffer.write(chunk);sys.stdout.buffer.flush();pending+=chunk
     while b'\n' in pending:
      raw,pending=pending.split(b'\n',1);line=raw.decode('utf-8','replace').rstrip('\r');t=time.monotonic()-start
      if line.startswith(('M007_','HARDWARE_AGENT_SIM_PASS','%Error')):ev.write(json.dumps({'line':line,'elapsed_s':t})+'\n');ev.flush()
      if re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b|M007_LAYER_CAPTURE_ERROR',line):fatal=True;raise Stop('FAIL','original_or_actual_capture_failure')
      rec=flow.feed(line,t)
      if rec:
       seg.write(json.dumps(rec)+'\n');seg.flush()
       if rec['stage']=='original_layer_endpoint_and_actual_H':
        gl=rec['global_layer'];capture=actual_capture(a.prefix,gl,a.gold_dir,True);artifacts.append(capture);endpoint={**flow.layers[-1],'actual_output_integrity':capture};layers.write(json.dumps(endpoint)+'\n');layers.flush()
       status(time.monotonic()-start)
   child.wait(timeout=max(.01,min(1,15000-(time.monotonic()-start))))
   if child.returncode!=0:raise Stop('FAIL','nonzero_original_exit')
   assert len(artifacts)==30 and [z['global_layer'] for z in artifacts]==list(range(30))
   actual_input=Path(str(a.prefix)+'.H0.bin').read_bytes();assert actual_input==(a.gold_dir/'embedding_norm.f32.bin').read_bytes() and len(actual_input)==524288
   output=Path(str(a.prefix)+'.output.bin').read_bytes();tail=b''.join(int(z.strip(),16).to_bytes(128,'little') for z in a.tail_hex.read_text().splitlines() if z.strip());assert len(output)==len(tail)==69632 and output==tail
   receipt=Path(str(a.prefix)+'.receipt.txt').read_text();assert 'kind=7 layer=0 ' in receipt and 'layers=30 matrices=120 LN=60 vector=61 GEGLU=28 tail_commits=1 done_consumed=1 ' in receipt
   flow.exited(time.monotonic()-start);verdict='PASS';reason='complete_original30_once_BEGIN_all_checkpoints_actual_H_tail_DONE_idle_normal_exit';final={'input_bytes':len(actual_input),'input_sha256':sha(actual_input),'input_bit_exact_original_embedding_norm':True,'output_bytes':len(output),'output_sha256':sha(output),'output_groups32':544,'output_bit_exact_original_tail544_hex':True,'original_receipt':receipt,'all30_actual_H_capture_integrity':artifacts,'all_original_final_counts':flow.obs}
  except Stop as e:verdict=e.verdict;reason=e.reason;final=None
  except Exception as e:verdict='FAIL';reason='driver_or_integrity:'+repr(e);final=None
  finally:
   try:io_last={k:int(v) for line in Path('/proc',str(child.pid),'io').read_text().splitlines() for k,v in [line.split(':',1)]}
   except OSError:pass
   if child.poll() is None:
    child.terminate()
    try:child.wait(timeout=.5)
    except subprocess.TimeoutExpired:child.kill();child.wait(timeout=1)
   else:child.wait()
   sel.close()
 usage=resource.getrusage(resource.RUSAGE_CHILDREN);result={'verdict':verdict,'reason':reason,'elapsed_seconds':time.monotonic()-start,'raw_child_return_code':child.returncode,'fullgraph_complete':verdict=='PASS','completed_global_layers':flow.completed,'layer_records':flow.layers,'completed_stages':flow.records,'next_expected_stage':None if verdict=='PASS' else flow.expected(),'actual_thread_samples':thread_samples,'child_cpu_user_seconds':usage.ru_utime,'child_cpu_system_seconds':usage.ru_stime,'child_cpu_total_seconds':usage.ru_utime+usage.ru_stime,'child_maxrss_kb':usage.ru_maxrss,'io_counters_last_observed':io_last,'error_or_fatal':fatal,'actual_output_integrity':final,'observer_cost_separately_measured':False,'all_original_stdout_forwarded_unchanged':True};dump(a.receipt,result);dump(a.status,{'execution_state':'completed','verdict':verdict,'reason':reason,'completed_layers':flow.completed,'elapsed_seconds':result['elapsed_seconds'],'fullgraph_complete':verdict=='PASS'});raise SystemExit(0 if verdict=='PASS' else 124 if verdict=='COST_STOP' else 1)
def main():
 p=argparse.ArgumentParser();p.add_argument('mode',choices=['replay','run']);p.add_argument('--receipt',type=Path,required=True);p.add_argument('--root',type=Path)
 for name in ['events','segments','layers','status','prefix','gold-dir','tail-hex']:p.add_argument('--'+name,type=Path)
 p.add_argument('--command',nargs=argparse.REMAINDER);a=p.parse_args()
 if a.mode=='replay':replay(a)
 else:run(a)
if __name__=='__main__':main()
