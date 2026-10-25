#!/usr/bin/env python3
"""E018 R003 CANCEL-END-19: corrected TB full replay; R002 remains immutable."""
import argparse,ctypes,fcntl,hashlib,json,os,resource,subprocess,sys,tarfile,time
from datetime import datetime,timezone
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];EXPERIMENT=MODULE.parents[2];ROOT=EXPERIMENT.parents[2]
HELPER=MODULE.parent/'layernorm_engine/tb/m007_ln_process_guard.py'
sys.dont_write_bytecode=True
sys.path.insert(0,str(HELPER.parent))
from m007_ln_process_guard import enable_subreaper,sample_rss,work_remains,finish
RUN=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R003'
SELF_PATH=Path(__file__).resolve();SELF_SHA=hashlib.sha256(SELF_PATH.read_bytes()).hexdigest()
BUDGET={'reference':0,'static':120,'rtl':300,'ooc':0};RSS={'reference':16,'static':24,'rtl':8,'ooc':24}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def utc():return datetime.now(timezone.utc).isoformat()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def limits(cap):
 os.setsid();os.sched_setaffinity(0,{0,1,2,3});os.nice(19);resource.setrlimit(resource.RLIMIT_AS,(cap,cap))
 if ctypes.CDLL(None,use_errno=True).syscall(251,1,0,3<<13):raise RuntimeError('idle I/O priority failed')
class CostGateError(RuntimeError):pass
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
def validate_cost_plan(path,cmd,seconds,semantic_path):
 try:
  path=path.resolve();assert path.is_relative_to(RUN.resolve()),'plan outside E018 R003'
  p=json.loads(path.read_text());assert p['schema']=='m007-cancel-end19-corrected-build-cost-v1'
  assert p['command']==cmd and p['requested_timeout_s']==seconds==200
  prior=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002'
  for name,digest in p['authority_files_sha256'].items():assert sha(ROOT/name)==digest,'authority changed: '+name
  for name,digest in p['frozen_R002_receipt_sha256'].items():assert sha(prior/'attempts'/name/'receipt.json')==digest,'R002 receipt changed'
  build=Path(p['build_work']);manifest=json.loads((build/'report.json').read_text())
  assert sha(build/'report.json')==p['build_manifest_sha256']
  assert sha(Path(cmd[1]))==manifest['driver_sha256']==p['driver_sha256']
  assert cmd[cmd.index('--build')+1]==str(build) and cmd[cmd.index('--groups')+1]=='82' and cmd[cmd.index('--mode')+1]=='2' and cmd[cmd.index('--count')+1]=='335872'
  for name,digest in manifest['source_sha256'].items():assert sha(ROOT/name)==digest,'current source differs from AT021 corrected build: '+name
  for name,digest in manifest['snapshot'].items():assert sha(build/name)==digest,'AT021 snapshot changed'
  normal=prior/'attempts/AT018_full_original_normal';nr=json.loads((normal/'receipt.json').read_text());nm=json.loads((normal/'work/report.json').read_text())
  failed=json.loads((prior/'attempts/AT020_full_terminal_cancel_priority/receipt.json').read_text())
  assert nr['status']=='EXIT_ZERO' and nm['status']=='PASS' and nm['main_input_count']==335872 and nm['metrics']['node_checks']==3358720
  assert failed['status']=='FAIL' and failed['semantic_progress']['last_checked']==335872
  assert nr['child_wall_s']==p['normal_child_wall_s'] and failed['child_wall_s']==p['failed_prefixed_TB_child_wall_s']
  bound=nr['child_wall_s']*1.35+10
  assert bound==p['conservative_wall_bound_s'] and bound<=seconds and failed['child_wall_s']<seconds
  old_build=prior/'attempts/AT002_normal_build/work';om=json.loads((old_build/'report.json').read_text())
  tbname='project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_normal_tb.sv'
  assert manifest['source_sha256'].keys()==om['source_sha256'].keys()
  for name,digest in manifest['source_sha256'].items():
   if name!=tbname:assert digest==om['source_sha256'][name],'production source changed'
  before=(old_build/'frozen'/tbname).read_text();after=(build/'frozen'/tbname).read_text()
  assert before.replace('slot_fp_debt||protocol_fault||needs_discard)$fatal(1,"FINAL_REAL_DEBT")','slot_fp_debt||protocol_fault||(needs_discard&&mode!=2))$fatal(1,"FINAL_REAL_DEBT")',1)==after,'correction differs from sole authorized TB expression'
  fixture=Path(cmd[cmd.index('--fixture')+1]);fi=json.loads((fixture/'report.json').read_text())
  assert sha(fixture/'report.json')==p['fixture_report_sha256'] and sha(fixture/'geglu_vectors.hex')==fi['vectors_sha256']==p['fixture_vectors_sha256'] and fi['count']==335872
  assert semantic_path==Path(cmd[cmd.index('--output')+1])/'semantic_progress.jsonl'
  return {'plan_path':str(path),'plan_sha256':sha(path),'baseline':'R002 AT018 full normal; AT020 retained failed TB; corrected AT021 build','normal_child_wall_s':nr['child_wall_s'],'failed_prefixed_TB_child_wall_s':failed['child_wall_s'],'conservative_wall_bound_s':bound,'requested_timeout_s':seconds,'corrected_build_manifest_sha256':p['build_manifest_sha256'],'only_selected_TB_expression_changed':True,'required_RTL_reserve_s':60}
 except Exception as e:raise CostGateError(type(e).__name__+': '+str(e))from e

def main():
 p=argparse.ArgumentParser();p.add_argument('--attempt',required=True);p.add_argument('--phase',choices=tuple(BUDGET),required=True)
 p.add_argument('--seconds',type=float,default=120);p.add_argument('--cost-plan',type=Path);p.add_argument('--semantic-progress',type=Path);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
 cmd=a.command[1:]if a.command[:1]==['--']else a.command
 limit=200 if a.phase=='rtl'and a.cost_plan else 120
 if not a.attempt.startswith('AT')or'/'in a.attempt or not 0<a.seconds<=limit or not cmd:p.error('fresh AT; <=120s pilot or measured same-build RTL cost plan <=200s required')
 at=RUN/'attempts'/a.attempt;at.mkdir(parents=True,exist_ok=False);cap=RSS[a.phase]<<30
 semantic_path=a.semantic_progress.resolve()if a.semantic_progress else None
 if semantic_path and(a.phase!='rtl'or semantic_path!=at/'work/semantic_progress.jsonl'):p.error('semantic progress must be this RTL attempt work/semantic_progress.jsonl')
 if a.seconds>120 and not semantic_path:p.error('long RTL requires actual checked-consume semantic progress')
 r={'schema':'m007-producer-cancel-guard-v1','phase':a.phase,'attempt':a.attempt,'command':cmd,'cwd':str(Path.cwd()),'host':os.uname().nodename,
    'started':utc(),'guard_entrypoint':str(SELF_PATH),'guard_self_sha256_at_startup':SELF_SHA,'limit_s':a.seconds,'phase_budget_s':BUDGET[a.phase],'RSS_limit_bytes':cap,'child_wall_s':0.,'status':'WAITING_LOCK'}
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
  child=None;start=None;tracked={};peak=0;semantic=None;policy={}
  try:
   r['lock_acquired']=utc()
   if sha(SELF_PATH)!=SELF_SHA:raise RuntimeError('frozen guard changed since startup')
   r['guard_self_sha256_at_lock']=SELF_SHA
   r['previous_phase_wall_s']=sum(json.loads(x.read_text()).get('child_wall_s',0)for x in(RUN/'attempts').glob('AT*/receipt.json')if json.loads(x.read_text()).get('phase')==a.phase)
   if r['previous_phase_wall_s']+a.seconds>BUDGET[a.phase]:raise RuntimeError('E018 independent budget exceeded')
   if a.phase=='rtl'and a.seconds>120 and r['previous_phase_wall_s']+a.seconds>240:raise RuntimeError('60s RTL reserve required')
   if a.seconds>120:r['validated_measured_cost_plan']=validate_cost_plan(a.cost_plan,cmd,a.seconds,semantic_path)
   available=int(next(x.split()[1]for x in Path('/proc/meminfo').read_text().splitlines()if x.startswith('MemAvailable:')))*1024
   r['MemAvailable_bytes']=available
   if available<=192<<30 or not{0,1,2,3}<=os.sched_getaffinity(0):raise RuntimeError('CPU/memory prerequisites unavailable')
   sources=sorted((MODULE/'rtl').glob('laya_m007_*'))+sorted((MODULE/'tb').glob('m007_*'))+sorted((MODULE.parent/'attention_and_fp_engine/rtl').glob('*.sv'))+sorted((MODULE.parent/'attention_and_fp_engine/tb').glob('m007_control*'))+sorted((MODULE.parent/'attention_and_fp_engine/tb').glob('m007_cancel17*'))+[HELPER]+[x for x in (ROOT/'project/E018_m007_control_workspace_joint/experiment_source').glob('*')if x.is_file()]
   protocol=ROOT/'project/E018_m007_control_workspace_joint/experiment_source/protocol_r003.md'
   r['source_sha256']={str(x.relative_to(ROOT)):sha(x)for x in sources if x.is_file()}
   r['protocol_sha256']=sha(protocol);r['process_helper_reused_read_only']=str(HELPER.relative_to(ROOT))
   with tarfile.open(at/'sources.tar.gz','w:gz')as archive:
    for x in sources:
     if x.is_file():archive.add(x,arcname=str(x.relative_to(ROOT)),recursive=False)
    archive.add(protocol,arcname='e018_protocol.md',recursive=False)
   r['source_archive_sha256']=sha(at/'sources.tar.gz');r['child_subreaper_enabled']=enable_subreaper()
   if semantic_path and semantic_path.exists():raise SemanticObserverError('progress file exists before child launch')
   start=time.monotonic();r['child_started']=utc();semantic=SemanticProgress(semantic_path,start)if semantic_path else None
   with(at/'stdout.log').open('wb')as out,(at/'stderr.log').open('wb')as err:
    child=subprocess.Popen(cmd,stdout=out,stderr=err,preexec_fn=lambda:limits(cap),env=dict(os.environ,OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',PYTHONDONTWRITEBYTECODE='1'))
    r.update(pid=child.pid,status='RUNNING',CPU_affinity=sorted(os.sched_getaffinity(child.pid)),nice=os.getpriority(os.PRIO_PROCESS,child.pid),ioprio=ctypes.CDLL(None).syscall(252,1,child.pid));save(at/'receipt.json',r)
    while work_remains(child,tracked):
     peak=max(peak,sample_rss(child,tracked))
     now=time.monotonic()
     available_now=int(next(x.split()[1]for x in Path('/proc/meminfo').read_text().splitlines()if x.startswith('MemAvailable:')))*1024
     r['minimum_MemAvailable_bytes']=min(r.get('minimum_MemAvailable_bytes',available_now),available_now)
     if available_now<=192<<30:r['status']='MEMAVAILABLE_STOP';break
     for key,info in list(tracked.items()):
      if key in policy:continue
      try:
       pid=info['pid'];aff=sorted(os.sched_getaffinity(pid));ni=os.getpriority(os.PRIO_PROCESS,pid);io_lib=ctypes.CDLL(None,use_errno=True);io=io_lib.syscall(252,1,pid)
       if io<0 and ctypes.get_errno()==3:continue
       policy[key]={'pid':pid,'start_ticks':info['start_ticks'],'affinity':aff,'nice':ni,'ioprio':io}
       if not aff or not set(aff)<={0,1,2,3}or ni!=19 or io!=(3<<13):raise RuntimeError('owned descendant policy mismatch: '+str(policy[key]))
      except ProcessLookupError:pass
     if semantic:
      semantic.sample(now)
      if semantic.stalled(now):r['status']='SEMANTIC_STALL_STOP';break
     if now-start>=a.seconds or peak>cap:r['status']='COST_STOP'if peak<=cap else'RSS_STOP';break
     time.sleep(.05)
    if semantic:semantic.sample(time.monotonic())
    if r['status']=='RUNNING':r['status']='EXIT_ZERO'if child.poll()==0 else'FAIL'
    if r['status']=='EXIT_ZERO'and semantic and(not semantic.events or semantic.pending):raise SemanticObserverError('successful child lacks complete checked-consume event')
  except BaseException as e:r.update(status='COST_GATE_STOP'if isinstance(e,CostGateError)else('SEMANTIC_OBSERVER_FAILURE'if isinstance(e,SemanticObserverError)else'INFRASTRUCTURE_FAILURE'),error=type(e).__name__+': '+str(e))
  finally:
   try:
    if child is not None:finish(child,tracked,r,r['status']not in('EXIT_ZERO','FAIL'));r.update(child_wall_s=time.monotonic()-start,RSS_sampled_peak_bytes=peak)
   finally:
    r['finished']=utc();r['descendant_policy_checks']=list(policy.values())
    if semantic:r['semantic_progress']=semantic.report(time.monotonic());save(at/'semantic_observations.json',r['semantic_progress'])
    try:save(at/'receipt.json',r)
    finally:fcntl.flock(lock,fcntl.LOCK_UN)
 print(json.dumps({k:r.get(k)for k in('attempt','status','child_wall_s','error','owned_after_cleanup','owned_group_after_cleanup_exists')}),flush=True)
 return 0 if r['status']=='EXIT_ZERO'else 1
if __name__=='__main__':raise SystemExit(main())
