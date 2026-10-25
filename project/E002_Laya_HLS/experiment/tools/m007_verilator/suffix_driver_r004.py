#!/usr/bin/env python3
"""D36 independently bounded SEGMENTED_SUFFIX; never original30 once-BEGIN PASS."""
import argparse,hashlib,json,os,re,resource,selectors,subprocess,sys,time
from pathlib import Path
from original30_driver_r003 import Flow as OriginalFlow,Stop,actual_capture,PHASE,plan
PASS='HARDWARE_AGENT_SIM_PASS M007_SEGMENTED_SUFFIX layers=2 matrix=8 heads=32 LN=5 vector=5 outputs=544 actual_tail_commit=1'
FINAL_COUNTS={'commands':1,'h_count':4096,'catalog_runtime':8,'matrix_commands':8,'layers_completed':2,'ln_commands':5,'vector_commands':5,'g_commands':0,'exports':544,'tail_commits':1,'tail_writes':544,'final_norm_count':4096,'type_count':4096,'global_layer':29}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def sha(b):return hashlib.sha256(b).hexdigest()
class Flow(OriginalFlow):
 def __init__(self):
  super().__init__(27);self.mode='finalLN';self.entered=False;self.handoff_done=False
 def check(self,t):
  if t>1800:raise Stop('COST_STOP','suffix_global1800s_cap')
  if not self.handoff_done and t>120:raise Stop('COST_STOP','setup_finalLN_type_Decision0_preLN_combined120s_cap')
  if self.mode=='layer' and t-self.layer_anchor>600:raise Stop('COST_STOP','Decision600s_cap:global'+str(self.gl))
  if t-self.anchor>120:raise Stop('COST_STOP','continuous120s_cap:'+self.expected())
 def advance(self,name,line,t):
  rec=super().advance(name,line,t)
  if name=='preLN_success' and rec['global_layer']==28:self.handoff_done=True
  return rec
 def feed(self,line,t):
  self.check(t)
  p=PHASE.fullmatch(line)
  if p and self.mode=='finalLN':
   gl,st,*_=map(int,p.groups())
   if gl==0 and not self.entered:return None
   if gl==27:self.entered=True
  if line==PASS:
   if self.mode!='tail' or self.completed!=[28,29] or any(self.obs.get(k)!=v for k,v in FINAL_COUNTS.items()):raise Stop('FAIL','suffix_PASS_before_actual_full_counts_and_two_layers')
   return self.advance(self.expected(),line,t)
  return super().feed(line,t)
def endpoint_capture(prefix,label,gold):
 suffix={'finalLN':'final_norm','type':'type_add'}[label];p=Path(str(prefix)+'.'+suffix+'.f32.bin');binary=p.read_bytes();assert len(binary)==524288 and binary==gold.read_bytes()
 return {'endpoint':label,'bytes':len(binary),'sha256':sha(binary),'actual_file':str(p),'original_gold_path':str(gold),'unique_actual_groups32':4096,'actual_capture_provenance':'A010 frozen TB at actual committed interface, address-indexed write, original4096 unique/full-coverage checker; source identity frozen','all131072_actual_words_equal_original_gold':True}

def run(a):
 start=time.monotonic();flow=Flow();sel=selectors.DefaultSelector();child=subprocess.Popen(a.command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,bufsize=0);sel.register(child.stdout,selectors.EVENT_READ);pending=b'';verdict='FAIL';reason='incomplete';fatal=False;thread_samples=[];last_thread=-10.;captures={};gamma_commands=[];ln_success=[];fatal_lines=[];diagnostics=[];planned_stop=False;output=None
 def status(t):dump(a.status,{'execution_state':'running','scope':'SEGMENTED_SUFFIX','mode':a.mode,'elapsed_seconds':t,'completed_suffix_layers':flow.completed,'current_global_layer':flow.gl,'next_expected_stage':flow.expected(),'stage_anchor_elapsed_s':flow.anchor,'last_actual_cycle':flow.cycle,'last_completed_stage':flow.records[-1] if flow.records else None,'actual_thread_samples':thread_samples})
 with a.events.open('x') as ev,a.segments.open('x') as seg:
  try:
   eof=False
   while not eof:
    elapsed=time.monotonic()-start;flow.check(elapsed)
    if a.mode in ['old','pilot'] and elapsed>120:raise Stop('COST_STOP','unknown120s_short_run_cap')
    if elapsed-last_thread>=10:
     try:n=len(list(Path('/proc',str(child.pid),'task').iterdir()))
     except OSError:n=0
     if n:
      thread_samples.append({'elapsed_s':elapsed,'threads':n})
      if n!=1:raise Stop('FAIL','actual_model_process_not_single_thread')
     last_thread=elapsed;status(elapsed)
    for key,mask in sel.select(.2):
     chunk=os.read(key.fd,65536)
     if not chunk:eof=True;break
     sys.stdout.buffer.write(chunk);sys.stdout.buffer.flush();pending+=chunk
     while b'\n' in pending:
      raw,pending=pending.split(b'\n',1);line=raw.decode('utf-8','replace').rstrip('\r');t=time.monotonic()-start
      if line.startswith(('M007_','HARDWARE_AGENT_SIM_PASS','%Error','%Fatal')) or '%Fatal:' in line:
       ev.write(json.dumps({'line':line,'elapsed_s':t})+'\n');ev.flush()
      if line.startswith('M007_LN_COMMAND '):gamma_commands.append({'line':line,'elapsed_s':t,'fields':{k:int(v) for k,v in re.findall(r'([A-Za-z0-9_]+)=(\d+)',line)}})
      if line.startswith('M007_RESIDENT_LN_SUCCESS '):ln_success.append({'line':line,'elapsed_s':t,'fields':{k:int(v) for k,v in re.findall(r'([A-Za-z0-9_]+)=(\d+)',line)}})
      if line.startswith('M007_') and any(z in line for z in ['CHECK_FAIL','CHECK_DETAIL','MISMATCH','GAMMA_HOLD','FINAL_NORM_CHECK','LN_DIAGNOSTIC','FINAL_GAMMA_DIAG']):diagnostics.append({'line':line,'elapsed_s':t})
      if re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b|M007_(?:LAYER|SUFFIX)_CAPTURE_ERROR',line):
       fatal=True;fatal_lines.append(line);raise Stop('FAIL','original_or_actual_capture_failure')
      match=PHASE.fullmatch(line)
      if match:
       gl,st,*_=map(int,match.groups())
       label='finalLN' if gl==27 and st==91 else 'type' if gl==27 and st==96 else None
       if label and label not in captures:captures[label]=endpoint_capture(a.prefix,label,a.gold_dir/('final_norm.f32.bin' if label=='finalLN' else 'type_add.f32.bin'))
      rec=flow.feed(line,t)
      if rec:
       seg.write(json.dumps(rec)+'\n');seg.flush()
       if rec['stage']=='original_layer_endpoint_and_actual_H':captures['global'+str(rec['global_layer'])]=actual_capture(a.prefix,rec['global_layer'],a.gold_dir,True)
       status(time.monotonic()-start)
       if a.mode=='pilot' and flow.handoff_done:
        assert set(captures)=={'finalLN','type'}
        assert any(z['fields'].get('global')==27 and z['fields'].get('gamma')==1 and z['fields'].get('rows')==128 for z in gamma_commands)
        assert any(z['fields'].get('global')==28 and z['fields'].get('gamma')==0 for z in gamma_commands)
        assert any(z['fields'].get('global')==28 and z['fields'].get('issued')==z['fields'].get('written')==4096 for z in ln_success)
        planned_stop=True;raise Stop('PREFIX_PASS','actual_finalLN_type_full_values_and_Decision0_preLN_success_planned_stop')
   child.wait(timeout=1)
   if child.returncode!=0:raise Stop('FAIL','nonzero_original_exit')
   assert a.mode=='full' and flow.completed==[28,29] and set(captures)=={'finalLN','type','global28','global29'}
   actual_input=Path(str(a.prefix)+'.H0.bin').read_bytes();assert len(actual_input)==524288 and actual_input==a.actual_input.read_bytes()
   b=Path(str(a.prefix)+'.output.bin').read_bytes();tail=b''.join(int(s,16).to_bytes(128,'little') for s in a.tail_hex.read_text().splitlines() if s.strip());assert len(b)==69632 and b==tail
   original_receipt=Path(str(a.prefix)+'.receipt.txt').read_text();assert 'tail_commits=1' in original_receipt and 'done_consumed=1' in original_receipt
   assert any(z['fields'].get('global')==27 and z['fields'].get('gamma')==1 for z in gamma_commands)
   assert len(gamma_commands)==5 and sum(z['fields'].get('gamma',0) for z in gamma_commands)==1
   flow.exited(time.monotonic()-start);verdict='PASS';reason='complete_SEGMENTED_SUFFIX_actual_H_all_values_two_Decision_real_tail_DONE_idle_normal_exit';output={'actual_input_bytes':len(actual_input),'actual_input_sha256':sha(actual_input),'actual_input_matches_frozen_saved_H':True,'output_bytes':len(b),'output_sha256':sha(b),'all544_original_tail_groups_equal':True,'original_receipt':original_receipt,'actual_suffix_captures':captures,'actual_final_counts':flow.obs}
  except Stop as e:verdict=e.verdict;reason=e.reason
  except Exception as e:verdict='FAIL';reason='driver_or_integrity:'+repr(e)
  finally:
   if child.poll() is None:
    child.terminate()
    try:child.wait(timeout=.5)
    except subprocess.TimeoutExpired:child.kill();child.wait(timeout=1)
   else:child.wait()
   sel.close()
 diag_fields=[{k:int(v) for k,v in re.findall(r'([A-Za-z0-9_]+)=(\d+)',z['line'])} for z in diagnostics if z['line'].startswith('M007_FINAL_GAMMA_DIAG ')]
 if a.mode=='old' and fatal and any('original final gamma LN checkpoint' in s for s in fatal_lines) and any(z['fields'].get('global')==27 and z['fields'].get('gamma')==0 for z in gamma_commands) and any(all(z.get(k)==v for k,v in {'kind_bad':0,'duplicate':0,'offset_bad':0,'data_bad':1}.items()) for z in diag_fields):
  verdict='EXPECTED_FAIL_REPRODUCED';reason='old_actual_provider_gamma0_and_original_final_gamma_checkpoint_failure; exact fields in raw event stream'
 usage=resource.getrusage(resource.RUSAGE_CHILDREN)
 result={'verdict':verdict,'scope':'SEGMENTED_SUFFIX','mode':a.mode,'reason':reason,'elapsed_seconds':time.monotonic()-start,'raw_child_return_code':child.returncode,'original30_fullgraph_complete':False,'segmented_suffix_complete':verdict=='PASS','planned_prefix_stop':planned_stop,'completed_suffix_layers':flow.completed,'completed_stages':flow.records,'layer_records':flow.layers,'next_expected_stage':None if verdict=='PASS' else flow.expected(),'actual_thread_samples':thread_samples,'child_cpu_user_seconds':usage.ru_utime,'child_cpu_system_seconds':usage.ru_stime,'child_cpu_total_seconds':usage.ru_utime+usage.ru_stime,'child_maxrss_kb':usage.ru_maxrss,'original_error_or_fatal':fatal,'first_original_fatal_lines':fatal_lines,'actual_provider_LN_commands':gamma_commands,'actual_LN_success_events':ln_success,'diagnostics':diagnostics,'actual_endpoint_integrity':captures,'actual_output_integrity':output,'observer_cost_separately_measured':False,'all_original_stdout_forwarded_unchanged':True}
 dump(a.receipt,result);dump(a.status,{'execution_state':'completed','verdict':verdict,'scope':'SEGMENTED_SUFFIX','reason':reason,'elapsed_seconds':result['elapsed_seconds'],'segmented_suffix_complete':verdict=='PASS','original30_fullgraph_complete':False});raise SystemExit(0 if verdict in ['PASS','PREFIX_PASS','EXPECTED_FAIL_REPRODUCED'] else 124 if verdict=='COST_STOP' else 1)
def main():
 p=argparse.ArgumentParser();p.add_argument('mode',choices=['old','pilot','full']);p.add_argument('--receipt',type=Path,required=True)
 for name in ['events','segments','status','prefix','gold-dir','tail-hex','actual-input']:p.add_argument('--'+name,type=Path,required=True)
 p.add_argument('--command',nargs=argparse.REMAINDER);run(p.parse_args())
if __name__=='__main__':main()
