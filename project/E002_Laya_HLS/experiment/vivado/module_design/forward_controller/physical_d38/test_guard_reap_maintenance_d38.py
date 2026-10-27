#!/usr/bin/python3
"""Isolated real monitor/watchdog/observer maintenance with a tiny workload."""
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
import guard_reap_maintenance_d38 as m
import guard_selfstop_native_d38 as n
import handoff_guard_d38 as h

HERE=Path(__file__).resolve().parent
def wait(path,timeout=4):
    end=time.monotonic()+timeout
    while time.monotonic()<end:
        if path.exists():return h.read(path)
        time.sleep(.005)
    raise TimeoutError(str(path))

def toy_guard(out):
    assert n.libc.prctl(0x59616d61,n.ctypes.c_ulong(-1).value,0,0,0)==0
    with (out/'lock').open('a') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        child=os.fork()
        if child==0:os._exit(0)
        while n.proc(child)['state']!='Z':time.sleep(.001)
        leader=subprocess.Popen([sys.executable,__file__,'--leader',str(out)],start_new_session=True)
        started=h.now();t=time.monotonic();count=0
        h.dump(out/'launch.json',dict(pid=leader.pid,start=n.proc(leader.pid)['start'],guard_pid=os.getpid(),guard_start=n.proc(os.getpid())['start'],worker=n.proc(child),started_utc=started))
        while leader.poll() is None:
            count+=1
            h.dump(out/'live_status.json',dict(utc=h.now(),last_progress_age_seconds=0,counter=count))
            if time.monotonic()-t>2:
                (out/'EXPIRED_OLD_PYTHON_RAN').write_text('Expired guard executed\n');leader.kill();break
            time.sleep(.02)
        code=leader.wait()
        try:os.waitpid(child,os.WNOHANG)
        except ChildProcessError:pass
        h.dump(out/'receipt.json',dict(verdict='PASS' if code==0 else 'FAIL',elapsed_seconds=time.monotonic()-t,
               peak_owned_rss_kb=1,minimum_MemAvailable_kb=h.owned.mem_available_kb(),known_owned_identities={leader.pid:n.proc(leader.pid)['start'] if n.proc(leader.pid) else 1},
               policy_samples=[],guard_trigger=None,owned_after_cleanup=[],source_verify_after=True,child_exit_code=code))

def main():
    m.policy();assert n.libc.prctl(36,1,0,0,0)==0
    out=HERE.parents[6]/'project/E022_m007_full_top_physical/experiment_results/runs/R001'/('reap_maintenance_tests_'+str(time.time_ns()))
    out.mkdir();results=[]
    try:
        for mode in ['normal','before_write','native_timeout','native_killed','worker_killed']:
            case=out/mode;case.mkdir();(case/'checkpoints').mkdir();guard=None;monitor=None;observer=None;launch=None
            try:
                guard=subprocess.Popen([sys.executable,__file__,'--guard',str(case)],start_new_session=True)
                launch=wait(case/'launch.json');wait(case/'live_status.json')
                c=dict(attempt=str(case),output=str(case/'handoff'),guard_pid=launch['guard_pid'],guard_start=launch['guard_start'],leader=launch['pid'],leader_start=launch['start'],lock=str(case/'lock'),lock_inode=(case/'lock').stat().st_ino,
                       started_utc=launch['started_utc'],maximum_seconds=None,wall_time_limit_disabled=True,original_maximum_seconds=2,old_cap_kb=1024**2,old_cap_gib=1,rss_limit_kb=1024**2,minimum_available_kb=0,checkpoint_directory=str(case/'checkpoints'),sample_seconds=.05,watchdog_timeout=15)
                cfg=case/'handoff_config.json';h.dump(cfg,c)
                monitor=subprocess.Popen([sys.executable,str(HERE/'handoff_guard_d38.py'),'--supervise',str(cfg)],stdout=(case/'monitor.log').open('w'),stderr=subprocess.STDOUT,start_new_session=True)
                wait(case/'handoff/activation.json');c=h.read(cfg)
                observer=subprocess.Popen([sys.executable,str(HERE/'handoff_observer_d38.py'),str(cfg)],stdout=(case/'observer.log').open('w'),stderr=subprocess.STDOUT,start_new_session=True)
                obs=wait(case/'handoff/observer/ready.json');wd=wait(case/'handoff/watchdog_ready.json')
                time.sleep(2.05) # The retired guard's original two-second limit is now expired.
                before=h.read(case/'live_status.json')['counter']
                maintenance=case/'maintenance';maintenance.mkdir()
                journal=n.snapshot(c['guard_pid'],c['guard_start'],launch['worker']['pid'],launch['worker']['start'])
                m.dump(maintenance/'journal.json',journal)
                c.update(maintenance_output=str(maintenance),handoff=str(case/'handoff'),known=h.read(case/'handoff/heartbeat.json')['known'],
                         monitor=dict(pid=c['monitor_pid'],start=c['monitor_start']),watchdog=dict(pid=wd['pid'],start=wd['start']),observer=dict(pid=obs['pid'],start=obs['start']),fixture=True)
                if mode=='native_killed':c['test_fault']='running_1'
                if mode=='before_write':c['test_fault']='before_write'
                if mode=='native_timeout':c['test_hold_native']=True
                if mode=='worker_killed':c['test_kill_worker']=True
                mc=maintenance/'config.json';m.dump(mc,c);result=m.run(mc)
                after=h.read(case/'live_status.json')['counter'];assert after==before
                assert not (case/'EXPIRED_OLD_PYTHON_RAN').exists() and n.same(c['guard_pid'],c['guard_start'])['state']=='T'
                assert h.lock_held(case/'lock') and n.same(c['leader'],c['leader_start'])['state']!='Z'
                assert not (case/'handoff/watchdog_fallback.json').exists() and not (case/'handoff/observer/fallback_owned_cleanup.json').exists()
                assert (maintenance/'restoration.json').exists()
                results.append(dict(case=mode,PASS=True,maintenance_result=result,old_python_counter_before=before,old_python_counter_after=after,guard_T=True,lock_retained=True,leader_retained=True,old_watchdog_observer_no_fallback=True))
            finally:
                if launch:
                    (case/'finish').write_text('finish\n')
                    try:
                        if monitor:monitor.wait(timeout=6)
                        if guard:guard.wait(timeout=3)
                        if observer:observer.wait(timeout=3)
                    except subprocess.TimeoutExpired:
                        for identity in [dict(pid=launch['pid'],start=launch['start']),dict(pid=launch['guard_pid'],start=launch['guard_start'])]:
                            item=n.proc(identity['pid'])
                            if item and item['start']==identity['start']:os.kill(item['pid'],signal.SIGKILL)
                        for item in [monitor,observer,guard]:
                            if item and item.poll() is None:item.kill()
                        for item in [monitor,observer,guard]:
                            if item:item.wait(timeout=2)
                if launch:
                    for pid in [launch['pid'],launch['worker']['pid']]:
                        try:os.waitpid(pid,os.WNOHANG)
                        except ChildProcessError:pass
        m.dump(out/'test_result.json',dict(PASS=True,scope='Five real isolated supervision-maintenance cases; no production changes',tests=results))
        print(json.dumps(dict(PASS=True,output=str(out),tests=len(results))))
    except BaseException as exc:
        m.dump(out/'test_result.json',dict(PASS=False,error=repr(exc),completed=results));print(str(out));raise

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='--guard':toy_guard(Path(sys.argv[2]))
    elif len(sys.argv)>1 and sys.argv[1]=='--leader':
        while not (Path(sys.argv[2])/'finish').exists():
            for i in range(1000):i*i
            time.sleep(.01)
    else:main()
