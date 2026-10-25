#!/usr/bin/env python3
"""Independent E014 budgets; the project heavy lock covers every child lifetime."""
import argparse
import ctypes
from datetime import datetime,timezone
import fcntl
import hashlib
import json
import os
from pathlib import Path
import resource
import signal
import subprocess
import tarfile
import time
from m007_ln_process_guard import enable_subreaper,sample_rss,work_remains,finish

MODULE=Path(__file__).resolve().parents[1];EXPERIMENT=MODULE.parents[2];PROJECT=EXPERIMENT.parents[2]
SELF_PATH=Path(__file__).resolve();SELF_SHA=hashlib.sha256(SELF_PATH.read_bytes()).hexdigest()
RUN=PROJECT/'project/E014_m007_layernorm32/experiment_results/runs/R002'
BUDGET={'reference':60,'static':600,'rtl':1200};RSS={'reference':16,'static':24,'rtl':8}
def sha(path):
 h=hashlib.sha256()
 with path.open('rb')as stream:
  for block in iter(lambda:stream.read(8<<20),b''):h.update(block)
 return h.hexdigest()
def utc():return datetime.now(timezone.utc).isoformat()
def write_receipt(at,value):
 temporary=at/'receipt.json.tmp';temporary.write_text(json.dumps(value,indent=2)+'\n');temporary.replace(at/'receipt.json')
def descendants(pid):
 ids=[pid]
 try:
  for child in Path(f'/proc/{pid}/task/{pid}/children').read_text().split():ids+=descendants(int(child))
 except (FileNotFoundError,ProcessLookupError):pass
 return ids
def rss(pid):
 total=0
 for child in descendants(pid):
  try:
   total+=sum(int(line.split()[1])*1024 for line in Path(f'/proc/{child}/status').read_text().splitlines()if line.startswith('VmRSS:'))
  except (FileNotFoundError,ProcessLookupError):pass
 return total
def limits(cap):
 os.setsid();os.sched_setaffinity(0,{0,1,2,3});os.nice(19);resource.setrlimit(resource.RLIMIT_AS,(cap,cap))
 libc=ctypes.CDLL(None,use_errno=True)
 if libc.syscall(251,1,0,3<<13):raise OSError(ctypes.get_errno(),'ioprio idle')
class SemanticObserverError(RuntimeError):pass
class SemanticProgress:
 """Read only flushed actual checked-consume records, never mtimes/heartbeats."""
 def __init__(self,path,start):
  self.path=path;self.start=start;self.last=start;self.offset=0;self.pending='';self.checked=0;self.cycle=-1;self.nodes=0;self.events=[];self.max_gap=0.
 def sample(self,now):
  if not self.path.exists():return
  if self.path.stat().st_size<self.offset:raise SemanticObserverError('progress file truncated')
  with self.path.open()as f:f.seek(self.offset);data=f.read();self.offset=f.tell()
  self.pending+=data
  while '\n'in self.pending:
   line,self.pending=self.pending.split('\n',1)
   try:
    x=json.loads(line)
    assert x['schema']=='m007-tanh-consumed-v1'
    assert type(x['checked'])is int and x['checked']>self.checked
    assert type(x['cycle'])is int and x['cycle']>self.cycle
    assert type(x['node_checks'])is int and x['node_checks']>=self.nodes
    assert type(x['phase'])is int and x['phase']in(1,2,4,5)
    assert type(x['returned'])is int and x['returned']>0
   except Exception as e:raise SemanticObserverError('invalid/nonadvancing checked-consume event: '+repr(line))from e
   self.max_gap=max(self.max_gap,now-self.last);self.last=now;self.checked=x['checked'];self.cycle=x['cycle'];self.nodes=x['node_checks']
   self.events.append(dict(x,received_utc=utc(),guard_child_elapsed_s=now-self.start))
 def stalled(self,now):return now-self.last>=120.
 def report(self,now):return {'path':str(self.path),'semantic_stall_limit_s':120,'observer_basis':'TB flushed event only after actual output consume and independent numeric/status/tag assertions','event_count':len(self.events),'last_checked':self.checked,'last_cycle':self.cycle,'last_node_checks':self.nodes,'last_progress_child_elapsed_s':self.last-self.start,'seconds_without_progress_at_finish':now-self.last,'maximum_observed_gap_s':max(self.max_gap,now-self.last),'events':self.events,'raw_sha256':sha(self.path)if self.path.exists()else None,'unparsed_tail':self.pending}

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--attempt',required=True);p.add_argument('--phase',choices=tuple(BUDGET),required=True)
 p.add_argument('--seconds',type=float,default=120);p.add_argument('--semantic-progress',type=Path);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args();cmd=a.command[1:]if a.command[:1]==['--']else a.command
 if not a.attempt.startswith('AT')or'/'in a.attempt or not 0<a.seconds<=(20 if a.phase=='reference' else 120) or not cmd:p.error('fresh AT and <=120s child limit required')
 at=RUN/'attempts'/a.attempt;at.mkdir(parents=True,exist_ok=False);cap=RSS[a.phase]<<30
 receipt={'schema':'m007-ln-compact22-r002-guard-v1','guard_entrypoint':str(SELF_PATH),'guard_self_sha256_at_startup':SELF_SHA,'attempt':a.attempt,'phase':a.phase,'phase_budget_s':BUDGET[a.phase],'command':cmd,'cwd':str(Path.cwd()),
  'host':os.uname().nodename,'started':utc(),'limit_s':a.seconds,'RSS_limit_bytes':cap,'CPU_requested':[0,1,2,3],'nice':19,'io_priority':'idle',
  'status':'WAITING_LOCK','child_wall_s':0.,'exit_code':None}
 lock_path=PROJECT/'.research-agent/m007_heavy.lock';receipt['lock']=str(lock_path)
 with lock_path.open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
  child=None;start=None;tracked={};peak=0;semantic=None
  semantic_path=a.semantic_progress.resolve()if a.semantic_progress else None
  if semantic_path and(a.phase!='rtl'or semantic_path!=at/'work/semantic_progress.jsonl'):raise RuntimeError('semantic path must be this RTL work/semantic_progress.jsonl')
  try:
   receipt['lock_acquired']=utc();assert sha(SELF_PATH)==SELF_SHA,'guard changed after startup';receipt['guard_self_sha256_at_lock']=SELF_SHA;spent=sum(json.loads(path.read_text()).get('child_wall_s',0)for path in(RUN/'attempts').glob('AT*/receipt.json')if json.loads(path.read_text()).get('phase')==a.phase)
   adjustments=RUN/'budget_adjustments.json'
   measured_spent=spent;reserved=0
   if adjustments.exists():reserved=sum(item['conservative_debit_s']for item in json.loads(adjustments.read_text())['adjustments']if item['phase']==a.phase)
   spent+=reserved;receipt['previous_measured_phase_wall_s']=measured_spent;receipt['previous_conservative_debit_s']=reserved;receipt['previous_budget_debit_s']=spent
   if spent+a.seconds>BUDGET[a.phase]:raise RuntimeError('requested child timeout exceeds remaining E014 budget')
   available=int(next(line.split()[1]for line in Path('/proc/meminfo').read_text().splitlines()if line.startswith('MemAvailable:')))*1024;receipt['MemAvailable_bytes']=available
   if available<=192<<30 or not{0,1,2,3}<=os.sched_getaffinity(0):raise RuntimeError('required memory/CPU0..3 unavailable')
   shared=EXPERIMENT/'vivado/module_design/attention_and_fp_engine/rtl'
   sources=sorted((MODULE/'rtl').glob('laya_m007_*'))+sorted((MODULE/'tb').glob('m007_*'))
   sources += [shared/name for name in('laya_shared_fp256_v2.sv','laya_fp_return_credit_v1.sv','laya_fadd_rne_v1.sv','laya_fmul_rne_v1.sv',
    'laya_shared_div8_v1.sv','laya_return_vector_credit_v1.sv','laya_fdiv_rne_v1.sv','laya_ln_exp_storage_v1.sv','laya_attention_storage_v1.sv')]
   sources += [EXPERIMENT/'tests/full_reference.py',EXPERIMENT/'reference/runs/typed_q8_ref_20261005/gguf_inventory.json'];sources=[path for path in sources if path.is_file()]
   receipt['source_sha256']={str(path.relative_to(EXPERIMENT)):sha(path)for path in sources}
   protocol=PROJECT/'project/E014_m007_layernorm32/experiment_source/protocol_r002_ln_compact22.md';receipt['protocol_sha256']=sha(protocol)
   with tarfile.open(at/'sources.tar.gz','w:gz')as snapshot:
    for path in sources:snapshot.add(path,arcname=str(path.relative_to(EXPERIMENT)),recursive=False)
    snapshot.add(protocol,arcname='e014_protocol.md',recursive=False)
   receipt['source_archive_sha256']=sha(at/'sources.tar.gz');receipt['child_started']=utc();start=time.monotonic()
   receipt['child_subreaper_enabled']=enable_subreaper()
   if semantic_path and semantic_path.exists():raise RuntimeError('semantic progress exists before launch')
   semantic=SemanticProgress(semantic_path,start)if semantic_path else None
   with(at/'stdout.log').open('wb')as out,(at/'stderr.log').open('wb')as err:
    child=subprocess.Popen(cmd,stdout=out,stderr=err,preexec_fn=lambda:limits(cap),env=dict(os.environ,OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',PYTHONDONTWRITEBYTECODE='1'))
    receipt.update(pid=child.pid,status='RUNNING',actual_CPU_affinity=sorted(os.sched_getaffinity(child.pid)),actual_nice=os.getpriority(os.PRIO_PROCESS,child.pid),actual_ioprio=ctypes.CDLL(None).syscall(252,1,child.pid))
    write_receipt(at,receipt)
    while work_remains(child,tracked):
     peak=max(peak,sample_rss(child,tracked))
     if semantic:
      semantic.sample(time.monotonic())
      if semantic.stalled(time.monotonic()):receipt['status']='SEMANTIC_STALL_STOP';break
     if time.monotonic()-start>=a.seconds or peak>cap:
      receipt['status']='COST_STOP'if peak<=cap else'RSS_STOP';break
     time.sleep(.05)
    if semantic:semantic.sample(time.monotonic())
    if receipt['status']=='RUNNING':receipt['status']='EXIT_ZERO'if child.poll()==0 else'FAIL'
    if receipt['status']=='EXIT_ZERO'and semantic and(not semantic.events or semantic.pending):raise RuntimeError('successful RTL lacks real checked-consume events')
  except BaseException as error:
   receipt.update(status='INFRASTRUCTURE_FAILURE',error=f'{type(error).__name__}: {error}')
  finally:
   try:
    if child is not None:
     finish(child,tracked,receipt,receipt['status']not in ('EXIT_ZERO','FAIL'))
     receipt.update(child_wall_s=time.monotonic()-start,RSS_sampled_peak_bytes=peak)
   finally:
    receipt['finished']=utc()
    if semantic:receipt['semantic_progress']=semantic.report(time.monotonic())
    try:write_receipt(at,receipt)
    finally:fcntl.flock(lock,fcntl.LOCK_UN)
 print(json.dumps({k:receipt.get(k)for k in('attempt','status','child_wall_s','error','owned_after_cleanup','owned_group_after_cleanup_exists')}),flush=True);return 0 if receipt['status']=='EXIT_ZERO'else 1
if __name__=='__main__':raise SystemExit(main())
