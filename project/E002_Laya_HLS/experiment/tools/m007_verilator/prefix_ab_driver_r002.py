#!/usr/bin/env python3
import argparse,json,os,re,resource,selectors,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--events',type=Path,required=True);p.add_argument('--receipt',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--input',type=Path,required=True);p.add_argument('--command',nargs=argparse.REMAINDER,required=True);a=p.parse_args();endpoint=re.compile(r'^M007_FULLGRAPH_PHASE global=0 state=7 heads=1 matrix_done=1 cycle=(\d+)$');qkv=re.compile(r'^M007_FULLGRAPH_PHASE global=0 state=6 heads=0 matrix_done=1 cycle=(\d+)$');expected=[]
for line in a.reference.read_text().splitlines():
 z=json.loads(line);expected.append(z['line'])
 if endpoint.fullmatch(z['line']):break
assert expected and endpoint.fullmatch(expected[-1]);start=time.monotonic();child=subprocess.Popen(a.command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,bufsize=0);sel=selectors.DefaultSelector();sel.register(child.stdout,selectors.EVENT_READ);pending=b'';actual=[];first_threads=None;endwall=None;qkvwall=None;reason=None;verdict=None;fatal=False
with a.events.open('x') as events:
 try:
  while endwall is None:
   elapsed=time.monotonic()-start
   if elapsed>=119:verdict='COST_STOP';reason='unknown_prefix119_cap';break
   for key,mask in sel.select(min(.2,119-elapsed)):
    chunk=os.read(key.fd,65536)
    if not chunk:raise RuntimeError('child exited before real endpoint')
    sys.stdout.buffer.write(chunk);sys.stdout.buffer.flush();pending+=chunk
    while b'\n' in pending:
     raw,pending=pending.split(b'\n',1);line=raw.decode('utf-8','replace').rstrip('\r');t=time.monotonic()-start
     if first_threads is None:
      try:first_threads=len(list(Path('/proc',str(child.pid),'task').iterdir()))
      except OSError:first_threads='UNKNOWN'
     if line.startswith(('M007_','HARDWARE_AGENT_SIM_PASS','%Error')):actual.append(line);events.write(json.dumps({'line':line,'elapsed_s':t})+'\n');events.flush()
     if re.search(r'%Error|%Fatal|Assertion failed|\bAborting\b|M007_LAYER0_CAPTURE_ERROR',line):fatal=True;raise RuntimeError('original child failure')
     if qkv.fullmatch(line):qkvwall=t
     if endpoint.fullmatch(line):
      assert qkvwall is not None;endwall=t;break
  if endwall is not None:verdict='PREFIX_PASS' if actual==expected else 'FAIL';reason='actual_QKV_and_first_head_all_semantics_equal' if actual==expected else 'nonpath_semantic_or_cycle_difference'
 except Exception as e:verdict='FAIL';reason=repr(e)
 finally:
  if child.poll() is None:
   child.terminate()
   try:child.wait(timeout=.5)
   except subprocess.TimeoutExpired:child.kill();child.wait(timeout=1)
  else:child.wait()
  sel.close()
usage=resource.getrusage(resource.RUSAGE_CHILDREN);actual_input=a.input.read_bytes() if a.input.exists() else None;result={'verdict':verdict,'reason':reason,'elapsed_seconds':time.monotonic()-start,'endpoint_elapsed_seconds':endwall,'QKV_success_elapsed_seconds':qkvwall,'raw_child_return_code':child.returncode,'planned_prefix_stop':verdict=='PREFIX_PASS','fullgraph_complete':False,'observed_threads_at_first_stdout':first_threads,'child_cpu_total_seconds':usage.ru_utime+usage.ru_stime,'child_cpu_user_seconds':usage.ru_utime,'child_cpu_system_seconds':usage.ru_stime,'actual_semantic_count':len(actual),'reference_semantic_count':len(expected),'all_nonpath_semantics_cycles_equal':actual==expected,'only_path_normalization':'NONE required in this prefix','error_or_fatal':fatal,'actual_input_bytes':len(actual_input) if actual_input is not None else None,'actual_input_sha256':__import__('hashlib').sha256(actual_input).hexdigest() if actual_input is not None else None,'reference_endpoint':expected[-1],'not_independent_new_internal_gold_PASS':True};a.receipt.write_text(json.dumps(result,indent=2)+'\n');raise SystemExit(0 if verdict=='PREFIX_PASS' else 124 if verdict=='COST_STOP' else 1)
