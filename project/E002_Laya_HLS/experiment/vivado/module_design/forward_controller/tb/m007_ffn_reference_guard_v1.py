#!/usr/bin/env python3
"""E016/R004 FFN-REFERENCE-18: independent CPU reference only; no EDA."""
import argparse,ctypes,fcntl,hashlib,json,os,resource,subprocess,sys,tarfile,time
from datetime import datetime,timezone
from pathlib import Path
sys.dont_write_bytecode=True
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5]
RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R004'
HELPER=MODULE.parent/'layernorm_engine/tb/m007_ln_process_guard.py';sys.path.insert(0,str(HELPER.parent))
from m007_ln_process_guard import enable_subreaper,sample_rss,work_remains,finish
SELF=Path(__file__).resolve();DRIVER=SELF.with_name('m007_ffn_reference_v1.py')
REF=ROOT/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def utc():return datetime.now(timezone.utc).isoformat()
def save(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def limits():
 os.setsid();os.sched_setaffinity(0,{0,1,2,3});os.nice(19);resource.setrlimit(resource.RLIMIT_AS,(16<<30,16<<30))
 if ctypes.CDLL(None,use_errno=True).syscall(251,1,0,3<<13):raise RuntimeError('idle I/O priority failed')
def main():
 p=argparse.ArgumentParser();p.add_argument('--attempt',required=True);p.add_argument('--mode',choices=['prepare','pilot','full','audit'],required=True);p.add_argument('--seconds',type=float,required=True);p.add_argument('--pilot',default='AT002_one_row_reference_pilot');a=p.parse_args()
 assert a.attempt.startswith('AT')and'/'not in a.attempt;assert 0<a.seconds<=(120 if a.mode=='full' else 20)
 at=RUN/'attempts'/a.attempt;at.mkdir(parents=True,exist_ok=False);work=at/'work'
 cmd=[sys.executable,str(DRIVER),'--mode',a.mode,'--output',str(work)]
 r={'schema':'m007-ffn-cpu-reference-guard-v1','phase':'reference','attempt':a.attempt,'mode':a.mode,'command':cmd,'cwd':str(ROOT),'host':os.uname().nodename,'started':utc(),'limit_s':a.seconds,'phase_budget_s':180,'child_wall_s':0.,'status':'WAITING_LOCK','guard_sha256':sha(SELF),'driver_sha256':sha(DRIVER),'reference_sha256':sha(REF),'RSS_limit_bytes':16<<30}
 save(at/'receipt.json',r)
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK '+a.attempt,flush=True);fcntl.flock(lock,fcntl.LOCK_EX);child=None;start=None;tracked={};peak=0
  try:
   r['lock_acquired']=utc();assert sha(SELF)==r['guard_sha256']and sha(DRIVER)==r['driver_sha256'];assert sha(REF)=='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
   used=sum(json.loads(x.read_text()).get('child_wall_s',0)for x in(RUN/'attempts').glob('AT*/receipt.json')if x!=at/'receipt.json')+json.loads((RUN/'reports/bootstrap_reads.json').read_text())['elapsed_s']
   r['previous_reference_wall_s']=used;assert used+a.seconds<=180
   available=int(next(x.split()[1]for x in Path('/proc/meminfo').read_text().splitlines()if x.startswith('MemAvailable:')))*1024;r['MemAvailable_bytes']=available;assert available>192<<30
   if a.mode=='full':
    pilot=RUN/'attempts'/a.pilot;pr=json.loads((pilot/'receipt.json').read_text());pp=json.loads((pilot/'work/report.json').read_text());bound=1.35*128*pr['child_wall_s']+10
    assert pr['status']=='EXIT_ZERO'and pp['status']=='PASS'and pp['rows']==1 and pr['mode']=='pilot'
    assert pr['guard_sha256']==r['guard_sha256']and pr['driver_sha256']==r['driver_sha256']and pr['reference_sha256']==r['reference_sha256']
    assert bound<=a.seconds<=120 and 180-used>=a.seconds+20
    r['cost_gate']={'pilot_attempt':a.pilot,'pilot_receipt_sha256':sha(pilot/'receipt.json'),'pilot_report_sha256':sha(pilot/'work/report.json'),'pilot_child_wall_s':pr['child_wall_s'],'formula':'1.35*128*pilot_child_wall_s+10','bound_s':bound,'requested_timeout_s':a.seconds,'reserved_reference_s':20,'decision':'ADMIT'}
   r['subreaper_enabled']=enable_subreaper()
   sources=[SELF,DRIVER,REF,HELPER,ROOT/'project/E016_m007_single_resource_parent/experiment_source/protocol_ffn_r004.md']
   r['sources']={str(q.relative_to(ROOT)):sha(q)for q in sources}
   with tarfile.open(at/'sources.tar.gz','w:gz')as ar:
    for q in sources:ar.add(q,arcname=str(q.relative_to(ROOT)),recursive=False)
   r['source_archive_sha256']=sha(at/'sources.tar.gz')
   with(at/'stdout.log').open('wb')as out,(at/'stderr.log').open('wb')as err:
    start=time.monotonic();r['child_started']=utc()
    child=subprocess.Popen(cmd,cwd=ROOT,stdout=out,stderr=err,preexec_fn=limits,env=dict(os.environ,OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',MKL_NUM_THREADS='1',PYTHONDONTWRITEBYTECODE='1'))
    r.update(pid=child.pid,status='RUNNING',CPU_affinity=sorted(os.sched_getaffinity(child.pid)),nice=os.getpriority(os.PRIO_PROCESS,child.pid),ioprio=ctypes.CDLL(None).syscall(252,1,child.pid));save(at/'receipt.json',r)
    while work_remains(child,tracked):
     peak=max(peak,sample_rss(child,tracked))
     if time.monotonic()-start>=a.seconds or peak>16<<30:r['status']='COST_STOP'if peak<=16<<30 else'RSS_STOP';break
     time.sleep(.01)
    if r['status']=='RUNNING':r['status']='EXIT_ZERO'if child.poll()==0 else'FAIL'
    if r['status']=='EXIT_ZERO':
     report=json.loads((work/'report.json').read_text());assert report['status']=='PASS';r['report_sha256']=sha(work/'report.json')
  except BaseException as e:r.update(status='INFRASTRUCTURE_FAILURE',error=type(e).__name__+': '+str(e))
  finally:
   try:
    if child is not None:finish(child,tracked,r,r['status']not in['EXIT_ZERO','FAIL']);r.update(child_wall_s=time.monotonic()-start,RSS_sampled_peak_bytes=peak)
   finally:r['finished']=utc();save(at/'receipt.json',r);fcntl.flock(lock,fcntl.LOCK_UN)
 print(json.dumps({k:r.get(k)for k in ['attempt','status','child_wall_s','cost_gate','error','owned_after_cleanup','owned_group_after_cleanup_exists']}),flush=True)
 return 0 if r['status']=='EXIT_ZERO' else 1
if __name__=='__main__':raise SystemExit(main())
