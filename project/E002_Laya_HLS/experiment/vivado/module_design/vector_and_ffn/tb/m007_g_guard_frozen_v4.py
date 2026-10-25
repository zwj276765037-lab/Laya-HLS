#!/usr/bin/env python3
"""E015 v4 G: bound original fixture and production same-build cost; v3 lifecycle preserved."""
import argparse,ctypes,fcntl,hashlib,json,os,resource,subprocess,sys,tarfile,time
from datetime import datetime,timezone
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];EXPERIMENT=MODULE.parents[2];ROOT=EXPERIMENT.parents[2]
HELPER=MODULE.parent/'layernorm_engine/tb/m007_ln_process_guard.py'
sys.dont_write_bytecode=True
sys.path.insert(0,str(HELPER.parent))
from m007_ln_process_guard import enable_subreaper,sample_rss,work_remains,finish
RUN=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001'
SELF_PATH=Path(__file__).resolve();SELF_SHA=hashlib.sha256(SELF_PATH.read_bytes()).hexdigest()
BUDGET={'reference':900,'static':1800,'rtl':3000,'ooc':1800};RSS={'reference':16,'static':24,'rtl':8,'ooc':24}
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
  path=path.resolve();assert path.is_relative_to(RUN.resolve()),'plan outside E015 R001'
  p=json.loads(path.read_text());assert p['schema']=='m007-g-engine-same-build-cost-v1'and p['phase']=='rtl'
  assert p['command']==cmd and p['requested_timeout_s']==seconds,'planned/actual command or timeout mismatch'
  pilot=RUN/'attempts'/p['pilot_attempt'];assert pilot.parent==RUN/'attempts'
  rr=pilot/'receipt.json';rp=pilot/'work/report.json';ii=pilot/'work/input_identity.json'
  assert sha(rr)==p['pilot_receipt_sha256']and sha(rp)==p['pilot_report_sha256']and sha(ii)==p['pilot_input_identity_sha256'],'pilot receipt identity'
  r=json.loads(rr.read_text());m=json.loads(rp.read_text());i=json.loads(ii.read_text())
  assert r['status']=='EXIT_ZERO'and r['phase']=='rtl'and m['status']=='PASS'
  assert r['guard_self_sha256_at_startup']==r['guard_self_sha256_at_lock']==SELF_SHA==p['pilot_guard_sha256'],'pilot guard/version differs'
  assert r['semantic_progress']['event_count']>0 and r['semantic_progress']['last_checked']==m['last_semantic_progress']['checked']==m['main_input_count']
  assert sha(pilot/'work/semantic_progress.jsonl')==m['semantic_progress_sha256']==p['pilot_semantic_progress_sha256']
  assert r['child_wall_s']==p['measured_pilot_child_wall_s']and m['main_input_count']==p['pilot_count']>=32768
  assert m['mode']==i['mode']==0 and m['all_real_rows']==128 and m['groups']*4096==p['pilot_count']
  assert m['metrics']['node_checks']==10*p['pilot_count']and m['metrics']['independent_slot_release']>0
  events=m['actual_runtime_events'];beg=next(x for x in events if x['event']=='main_begin');end=next(x for x in events if x['event']=='main_end')
  assert end['seconds_since_xsim_launch']>beg['seconds_since_xsim_launch'],'missing actual runtime interval'
  bound=r['child_wall_s']*p['target_count']/p['pilot_count']*1.10+10
  assert p['conservative_wall_bound_s']>=bound and bound<=seconds<=1200,'measured cost bound'
  assert p['target_count']==335872 and cmd[cmd.index('--count')+1]==str(p['target_count'])and cmd[cmd.index('--groups')+1]=='82'and cmd[cmd.index('--mode')+1]=='0'
  build=Path(p['build_work']).resolve();assert build.is_relative_to(ROOT.resolve())
  assert cmd[cmd.index('--build')+1]==str(build)and sha(build/'report.json')==p['build_manifest_sha256']==m['build_manifest_sha256']
  manifest=json.loads((build/'report.json').read_text())
  assert sha(Path(cmd[1]))==manifest['driver_sha256']==m['driver_sha256']==p['driver_sha256'],'driver/build/pilot mismatch'
  assert manifest['semantic_progress_schema']=='m007-tanh-consumed-v1'
  assert str(semantic_path)==p['semantic_progress_path']==str(Path(cmd[cmd.index('--output')+1])/'semantic_progress.jsonl'),'semantic path/command mismatch'
  for name,digest in manifest['source_sha256'].items():
   src=(ROOT/name).resolve();assert src.is_relative_to(ROOT.resolve())and sha(src)==digest,'current selected DUT/TB differs from compiled pilot'
  fixture=Path(cmd[cmd.index('--fixture')+1]);fi=json.loads((fixture/'report.json').read_text())
  assert sha(fixture/'report.json')==p['fixture_report_sha256']==i['fixture_report_sha256']==m['fixture_report_sha256']
  assert fi['schema']=='m007-g-original-fixture-v1'and fi['count']==p['target_count']
  assert sha(fixture/'geglu_vectors.hex')==fi['vectors_sha256']==i['vectors_sha256']==p['fixture_vectors_sha256']
  return {'plan_path':str(path),'plan_sha256':sha(path),'pilot_attempt':p['pilot_attempt'],'pilot_count':p['pilot_count'],'target_count':p['target_count'],'measured_pilot_child_wall_s':r['child_wall_s'],'conservative_wall_bound_s':bound,'requested_timeout_s':seconds,'same_build_manifest_sha256':p['build_manifest_sha256']}
 except Exception as e:raise CostGateError(type(e).__name__+': '+str(e))from e

def main():
 p=argparse.ArgumentParser();p.add_argument('--attempt',required=True);p.add_argument('--phase',choices=tuple(BUDGET),required=True)
 p.add_argument('--seconds',type=float,default=120);p.add_argument('--cost-plan',type=Path);p.add_argument('--semantic-progress',type=Path);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
 cmd=a.command[1:]if a.command[:1]==['--']else a.command
 limit=1200 if a.phase=='rtl'and a.cost_plan else 120
 if not a.attempt.startswith('AT')or'/'in a.attempt or not 0<a.seconds<=limit or not cmd:p.error('fresh AT; <=120s pilot or measured same-build RTL cost plan <=1200s required')
 at=RUN/'attempts'/a.attempt;at.mkdir(parents=True,exist_ok=False);cap=RSS[a.phase]<<30
 semantic_path=a.semantic_progress.resolve()if a.semantic_progress else None
 if semantic_path and(a.phase!='rtl'or semantic_path!=at/'work/semantic_progress.jsonl'):p.error('semantic progress must be this RTL attempt work/semantic_progress.jsonl')
 if a.seconds>120 and not semantic_path:p.error('long RTL requires actual checked-consume semantic progress')
 r={'schema':'m007-g-engine-guard-v4','phase':a.phase,'attempt':a.attempt,'command':cmd,'cwd':str(Path.cwd()),'host':os.uname().nodename,
    'started':utc(),'guard_entrypoint':str(SELF_PATH),'guard_self_sha256_at_startup':SELF_SHA,'limit_s':a.seconds,'phase_budget_s':BUDGET[a.phase],'RSS_limit_bytes':cap,'child_wall_s':0.,'status':'WAITING_LOCK'}
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
  child=None;start=None;tracked={};peak=0;semantic=None
  try:
   r['lock_acquired']=utc()
   if sha(SELF_PATH)!=SELF_SHA:raise RuntimeError('frozen guard changed since startup')
   r['guard_self_sha256_at_lock']=SELF_SHA
   r['previous_phase_wall_s']=sum(json.loads(x.read_text()).get('child_wall_s',0)for x in(RUN/'attempts').glob('AT*/receipt.json')if json.loads(x.read_text()).get('phase')==a.phase)
   if r['previous_phase_wall_s']+a.seconds>BUDGET[a.phase]:raise RuntimeError('E015 independent budget exceeded')
   if a.seconds>120:r['validated_measured_cost_plan']=validate_cost_plan(a.cost_plan,cmd,a.seconds,semantic_path)
   available=int(next(x.split()[1]for x in Path('/proc/meminfo').read_text().splitlines()if x.startswith('MemAvailable:')))*1024
   r['MemAvailable_bytes']=available
   if available<=192<<30 or not{0,1,2,3}<=os.sched_getaffinity(0):raise RuntimeError('CPU/memory prerequisites unavailable')
   sources=sorted((MODULE/'rtl').glob('laya_m007_*'))+sorted((MODULE/'tb').glob('m007_*'))+[HELPER]
   protocol=ROOT/'project/E015_m007_tanh_geglu8/experiment_source/protocol.md'
   r['source_sha256']={str(x.relative_to(ROOT)):sha(x)for x in sources if x.is_file()}
   r['protocol_sha256']=sha(protocol);r['process_helper_reused_read_only']=str(HELPER.relative_to(ROOT))
   with tarfile.open(at/'sources.tar.gz','w:gz')as archive:
    for x in sources:
     if x.is_file():archive.add(x,arcname=str(x.relative_to(ROOT)),recursive=False)
    archive.add(protocol,arcname='e015_protocol.md',recursive=False)
   r['source_archive_sha256']=sha(at/'sources.tar.gz');r['child_subreaper_enabled']=enable_subreaper()
   if semantic_path and semantic_path.exists():raise SemanticObserverError('progress file exists before child launch')
   start=time.monotonic();r['child_started']=utc();semantic=SemanticProgress(semantic_path,start)if semantic_path else None
   with(at/'stdout.log').open('wb')as out,(at/'stderr.log').open('wb')as err:
    child=subprocess.Popen(cmd,stdout=out,stderr=err,preexec_fn=lambda:limits(cap),env=dict(os.environ,OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',PYTHONDONTWRITEBYTECODE='1'))
    r.update(pid=child.pid,status='RUNNING',CPU_affinity=sorted(os.sched_getaffinity(child.pid)),nice=os.getpriority(os.PRIO_PROCESS,child.pid),ioprio=ctypes.CDLL(None).syscall(252,1,child.pid));save(at/'receipt.json',r)
    while work_remains(child,tracked):
     peak=max(peak,sample_rss(child,tracked))
     now=time.monotonic()
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
    r['finished']=utc()
    if semantic:r['semantic_progress']=semantic.report(time.monotonic());save(at/'semantic_observations.json',r['semantic_progress'])
    try:save(at/'receipt.json',r)
    finally:fcntl.flock(lock,fcntl.LOCK_UN)
 print(json.dumps({k:r.get(k)for k in('attempt','status','child_wall_s','error','owned_after_cleanup','owned_group_after_cleanup_exists')}),flush=True)
 return 0 if r['status']=='EXIT_ZERO'else 1
if __name__=='__main__':raise SystemExit(main())
