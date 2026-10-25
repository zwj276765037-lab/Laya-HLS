#!/usr/bin/env python3
"""E015-only budgets; reuse the frozen, adversarially verified lifetime helper."""
import argparse,ctypes,fcntl,hashlib,json,os,resource,subprocess,sys,tarfile,time
from datetime import datetime,timezone
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];EXPERIMENT=MODULE.parents[2];ROOT=EXPERIMENT.parents[2]
HELPER=MODULE.parent/'layernorm_engine/tb/m007_ln_process_guard.py'
sys.dont_write_bytecode=True
sys.path.insert(0,str(HELPER.parent))
from m007_ln_process_guard import enable_subreaper,sample_rss,work_remains,finish
RUN=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001'
BUDGET={'reference':900,'static':1800,'rtl':3000,'ooc':1800};RSS={'reference':16,'static':24,'rtl':8,'ooc':24}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def utc():return datetime.now(timezone.utc).isoformat()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def limits(cap):
 os.setsid();os.sched_setaffinity(0,{0,1,2,3});os.nice(19);resource.setrlimit(resource.RLIMIT_AS,(cap,cap))
 if ctypes.CDLL(None,use_errno=True).syscall(251,1,0,3<<13):raise RuntimeError('idle I/O priority failed')
def main():
 p=argparse.ArgumentParser();p.add_argument('--attempt',required=True);p.add_argument('--phase',choices=tuple(BUDGET),required=True)
 p.add_argument('--seconds',type=float,default=120);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
 cmd=a.command[1:]if a.command[:1]==['--']else a.command
 if not a.attempt.startswith('AT')or'/'in a.attempt or not 0<a.seconds<=120 or not cmd:p.error('fresh AT, command and <=120s required')
 at=RUN/'attempts'/a.attempt;at.mkdir(parents=True,exist_ok=False);cap=RSS[a.phase]<<30
 r={'schema':'m007-tanh-g8-guard-v1','phase':a.phase,'attempt':a.attempt,'command':cmd,'cwd':str(Path.cwd()),'host':os.uname().nodename,
    'started':utc(),'limit_s':a.seconds,'phase_budget_s':BUDGET[a.phase],'RSS_limit_bytes':cap,'child_wall_s':0.,'status':'WAITING_LOCK'}
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
  child=None;start=None;tracked={};peak=0
  try:
   r['lock_acquired']=utc();r['previous_phase_wall_s']=sum(json.loads(x.read_text()).get('child_wall_s',0)for x in(RUN/'attempts').glob('AT*/receipt.json')if json.loads(x.read_text()).get('phase')==a.phase)
   if r['previous_phase_wall_s']+a.seconds>BUDGET[a.phase]:raise RuntimeError('E015 independent budget exceeded')
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
   start=time.monotonic();r['child_started']=utc()
   with(at/'stdout.log').open('wb')as out,(at/'stderr.log').open('wb')as err:
    child=subprocess.Popen(cmd,stdout=out,stderr=err,preexec_fn=lambda:limits(cap),env=dict(os.environ,OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',PYTHONDONTWRITEBYTECODE='1'))
    r.update(pid=child.pid,status='RUNNING',CPU_affinity=sorted(os.sched_getaffinity(child.pid)),nice=os.getpriority(os.PRIO_PROCESS,child.pid),ioprio=ctypes.CDLL(None).syscall(252,1,child.pid));save(at/'receipt.json',r)
    while work_remains(child,tracked):
     peak=max(peak,sample_rss(child,tracked))
     if time.monotonic()-start>=a.seconds or peak>cap:r['status']='COST_STOP'if peak<=cap else'RSS_STOP';break
     time.sleep(.05)
    if r['status']=='RUNNING':r['status']='EXIT_ZERO'if child.poll()==0 else'FAIL'
  except BaseException as e:r.update(status='INFRASTRUCTURE_FAILURE',error=type(e).__name__+': '+str(e))
  finally:
   try:
    if child is not None:finish(child,tracked,r,r['status']not in('EXIT_ZERO','FAIL'));r.update(child_wall_s=time.monotonic()-start,RSS_sampled_peak_bytes=peak)
   finally:
    r['finished']=utc()
    try:save(at/'receipt.json',r)
    finally:fcntl.flock(lock,fcntl.LOCK_UN)
 print(json.dumps({k:r.get(k)for k in('attempt','status','child_wall_s','error','owned_after_cleanup','owned_group_after_cleanup_exists')}),flush=True)
 return 0 if r['status']=='EXIT_ZERO'else 1
if __name__=='__main__':raise SystemExit(main())
