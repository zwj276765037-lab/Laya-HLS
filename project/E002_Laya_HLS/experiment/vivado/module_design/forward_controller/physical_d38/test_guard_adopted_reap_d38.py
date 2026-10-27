#!/usr/bin/python3
"""Exact-child collection regression; never launches Vivado."""
import ctypes
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import run_physical_d38 as r

def proc(pid):
    try:
        s=Path(f'/proc/{pid}/stat').read_text().rsplit(')',1)[1].split()
        return dict(pid=pid,start=int(s[19]),state=s[0],ppid=int(s[1]))
    except FileNotFoundError:return None

def waitfor(predicate):
    end=time.monotonic()+1
    while time.monotonic()<end:
        value=predicate()
        if value:return value
        time.sleep(.002)
    raise TimeoutError('Fixture did not reach expected state')

def leader(out):
    pid=os.fork()
    if pid==0:time.sleep(.08);os._exit(11)
    (out/'orphan.json').write_text(json.dumps(proc(pid)))
    os._exit(7)

def main():
    os.sched_setaffinity(0,{0,1,2,3});os.setpriority(os.PRIO_PROCESS,0,19)
    subprocess.run(['/usr/bin/ionice','-c','3','-p',str(os.getpid())],check=True,timeout=1)
    assert ctypes.CDLL(None).prctl(36,1,0,0,0)==0
    out=r.RUN/('adopted_reap_tests_'+str(time.time_ns()));out.mkdir()
    child=subprocess.Popen([sys.executable,__file__,'--leader',str(out)])
    managed=subprocess.Popen([sys.executable,'-c','import os;os._exit(13)'])
    direct=[];orphan=None
    try:
        waitfor(lambda:(out/'orphan.json').exists());orphan=json.loads((out/'orphan.json').read_text())
        for code in [19,17,None]:
            pid=os.fork()
            if pid==0:
                if code is None:time.sleep(3);os._exit(0)
                os._exit(code)
            direct.append((pid,code))
        waitfor(lambda:proc(child.pid)['state']=='Z' and proc(managed.pid)['state']=='Z')
        waitfor(lambda:proc(orphan['pid'])['state']=='Z' and proc(orphan['pid'])['ppid']==os.getpid())
        waitfor(lambda:all(proc(pid)['state']=='Z' for pid,code in direct if code is not None))
        known={child.pid:proc(child.pid)['start'],orphan['pid']:orphan['start'],managed.pid:proc(managed.pid)['start'],direct[1][0]:proc(direct[1][0])['start']+1,direct[2][0]:proc(direct[2][0])['start']}
        records=[];collected=r.reap_adopted_zombies(known,child.pid,{managed.pid},records,out/'actual_reaps.jsonl')
        assert len(collected)==1 and collected[0]['pid']==orphan['pid'] and collected[0]['exit_code']==11
        assert proc(orphan['pid']) is None
        assert proc(managed.pid)['state']=='Z' and proc(child.pid)['state']=='Z'
        assert proc(direct[0][0])['state']=='Z' and proc(direct[1][0])['state']=='Z' and proc(direct[2][0])['state']!='Z'
        assert child.wait()==7 and managed.wait()==13
        assert records==collected and r.reap_adopted_zombies(known,child.pid,{managed.pid})==[]
        receipt=dict(PASS=True,scope='Real adopted orphan Z plus leader/managed/nonowned/start mismatch/running exclusions; no EDA',reaped=collected,
                     leader_exit_code=child.returncode,managed_exit_code=managed.returncode,nonowned_Z_skipped=True,wrong_start_Z_skipped=True,running_child_skipped=True,
                     runner_sha256=hashlib.sha256(Path(r.__file__).read_bytes()).hexdigest(),frozen_AT019_sha256=hashlib.sha256((r.RUN/'attempts/AT019_core_synth/frozen/run_physical_d38.py').read_bytes()).hexdigest())
        (out/'test_result.json').write_text(json.dumps(receipt,indent=2)+'\n')
        print(json.dumps(dict(PASS=True,output=str(out),result=receipt)))
    finally:
        for p in [child,managed]:
            if p.poll() is None:p.kill()
            p.wait(timeout=2)
        for pid,code in direct:
            if proc(pid) and proc(pid)['state']!='Z':os.kill(pid,9)
            try:os.waitpid(pid,0)
            except ChildProcessError:pass
        if orphan:
            try:os.waitpid(orphan['pid'],os.WNOHANG)
            except ChildProcessError:pass

if __name__=='__main__':
    if len(sys.argv)>1:leader(Path(sys.argv[2]))
    else:main()
