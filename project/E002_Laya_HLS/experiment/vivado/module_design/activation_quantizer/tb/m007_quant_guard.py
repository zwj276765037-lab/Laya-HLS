#!/usr/bin/env python3
"""E013 independent guard; the common heavy lock covers every child lifetime."""
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

MODULE=Path(__file__).resolve().parents[1]
EXPERIMENT=MODULE.parents[2]
PROJECT=EXPERIMENT.parents[2]
RUN=PROJECT/'project/E013_m007_quant_group32/experiment_results/runs/R001'
BUDGET={'reference':900,'static':1800,'rtl':2400,'ooc':600}
RSS={'reference':16,'static':24,'rtl':8,'ooc':24}


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def utc():return datetime.now(timezone.utc).isoformat()
def descendants(pid):
    children=[pid]
    try:
        for child in Path(f'/proc/{pid}/task/{pid}/children').read_text().split():children+=descendants(int(child))
    except FileNotFoundError:pass
    return children
def rss(pid):
    total=0
    for child in descendants(pid):
        try:
            for line in Path(f'/proc/{child}/status').read_text().splitlines():
                if line.startswith('VmRSS:'):total+=int(line.split()[1])*1024
        except FileNotFoundError:pass
    return total
def limits(cap):
    os.setsid();os.sched_setaffinity(0,{0,1,2,3});os.nice(19)
    resource.setrlimit(resource.RLIMIT_AS,(cap,cap))
    libc=ctypes.CDLL(None,use_errno=True)
    if libc.syscall(251,1,0,3<<13):raise OSError(ctypes.get_errno(),'ioprio idle')


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--attempt',required=True);p.add_argument('--phase',choices=tuple(BUDGET),required=True)
    p.add_argument('--seconds',type=float,default=120);p.add_argument('command',nargs=argparse.REMAINDER)
    a=p.parse_args();cmd=a.command[1:]if a.command[:1]==['--']else a.command
    if not a.attempt.startswith('AT')or'/'in a.attempt or not 0<a.seconds<=120 or not cmd:p.error('fresh AT and <=120s required')
    at=RUN/'attempts'/a.attempt;at.mkdir(parents=True,exist_ok=False)
    cap=RSS[a.phase]<<30
    receipt={'schema':'m007-quant03-guard-v1','attempt':a.attempt,'phase':a.phase,'phase_budget_s':BUDGET[a.phase],
        'command':cmd,'cwd':str(Path.cwd()),'host':os.uname().nodename,'started':utc(),'limit_s':a.seconds,
        'RSS_limit_bytes':cap,'CPU_requested':[0,1,2,3],'nice':19,'io_priority':'idle','status':'NOT_STARTED','child_wall_s':0.,'exit_code':None}
    lock_path=PROJECT/'.research-agent/m007_heavy.lock';receipt['lock']=str(lock_path)
    with lock_path.open('a+')as lock:
        print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
        try:
            receipt['lock_acquired']=utc()
            spent=sum(json.loads(path.read_text()).get('child_wall_s',0)for path in(RUN/'attempts').glob('AT*/receipt.json')
                      if json.loads(path.read_text()).get('phase')==a.phase)
            receipt['previous_phase_spent_s']=spent
            if spent+a.seconds>BUDGET[a.phase]:raise RuntimeError('requested timeout exceeds remaining E013 phase budget')
            available=int(next(line.split()[1]for line in Path('/proc/meminfo').read_text().splitlines()if line.startswith('MemAvailable:')))*1024
            receipt['MemAvailable_bytes']=available
            if available<=192<<30:raise RuntimeError('MemAvailable<=192GiB')
            if not{0,1,2,3}<=os.sched_getaffinity(0):raise RuntimeError('CPU0..3 unavailable')
            shared=EXPERIMENT/'vivado/module_design/attention_and_fp_engine/rtl'
            sources=sorted((MODULE/'rtl').glob('laya_m007_*'))+sorted((MODULE/'tb').glob('m007_*'))
            sources += [shared/name for name in('laya_shared_div8_v1.sv','laya_return_vector_credit_v1.sv','laya_fdiv_rne_v1.sv','laya_fmul_rne_v1.sv')]
            sources += [EXPERIMENT/'tests/full_reference.py']
            sources=[path for path in sources if path.is_file()]
            receipt['source_sha256']={str(path.relative_to(EXPERIMENT)):sha(path)for path in sources}
            archive=at/'sources.tar.gz'
            with tarfile.open(archive,'w:gz')as snapshot:
                for path in sources:snapshot.add(path,arcname=str(path.relative_to(EXPERIMENT)),recursive=False)
            receipt['source_archive_sha256']=sha(archive)
            start=time.monotonic();receipt['child_started']=utc()
            with(at/'stdout.log').open('wb')as out,(at/'stderr.log').open('wb')as err:
                child=subprocess.Popen(cmd,stdout=out,stderr=err,preexec_fn=lambda:limits(cap),
                    env=dict(os.environ,OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',PYTHONDONTWRITEBYTECODE='1'))
                receipt.update(pid=child.pid,status='RUNNING',actual_CPU_affinity=sorted(os.sched_getaffinity(child.pid)),
                    actual_nice=os.getpriority(os.PRIO_PROCESS,child.pid),actual_ioprio=ctypes.CDLL(None).syscall(252,1,child.pid))
                (at/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
                high=0
                while child.poll()is None:
                    high=max(high,rss(child.pid))
                    if time.monotonic()-start>=a.seconds or high>cap:
                        receipt['status']='COST_STOP'if high<=cap else'RSS_STOP';os.killpg(child.pid,signal.SIGKILL);break
                    time.sleep(.05)
                receipt.update(exit_code=child.wait(),child_wall_s=time.monotonic()-start,RSS_sampled_peak_bytes=high)
                if receipt['status']=='RUNNING':receipt['status']='EXIT_ZERO'if child.returncode==0 else'FAIL'
        except Exception as error:receipt.update(status='INFRASTRUCTURE_FAILURE',error=f'{type(error).__name__}: {error}')
        finally:
            receipt['finished']=utc();(at/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');fcntl.flock(lock,fcntl.LOCK_UN)
    print(json.dumps(receipt,indent=2),flush=True)
    return 0 if receipt['status']=='EXIT_ZERO'else 1


if __name__=='__main__':raise SystemExit(main())
