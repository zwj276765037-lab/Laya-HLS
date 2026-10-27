#!/usr/bin/python3
"""Real isolated native-stop fault cases; production PID operation is forbidden."""
if not __debug__:
    raise RuntimeError('Optimized Python forbidden')
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
import guard_selfstop_native_d38 as n

HERE=Path(__file__).resolve().parent
def dump(path,value):
    tmp=path.with_suffix('.tmp');tmp.write_text(json.dumps(value,indent=2)+'\n');tmp.replace(path)

def stopped(pid,timeout=.5):
    end=time.monotonic()+timeout
    while time.monotonic()<end:
        value=n.proc(pid)
        if value and value['state']=='T' and value['tracer']==0:return value
        time.sleep(.001)
    raise AssertionError(('Guard did not remain T',n.proc(pid)))

def fixture(out):
    assert n.libc.prctl(0x59616d61,n.ctypes.c_ulong(-1).value,0,0,0)==0
    lock=(out/'lock').open('w');fcntl.flock(lock,fcntl.LOCK_EX)
    leader=os.fork()
    if leader==0:
        lock.close()
        while True:time.sleep(.02)
    child=os.fork()
    if child==0:os._exit(0)
    while n.proc(child)['state']!='Z':time.sleep(.001)
    dump(out/'fixture.json',dict(guard=n.proc(os.getpid()),zombie=n.proc(child),leader=n.proc(leader)))
    time.sleep(60)
    (out/'OLD_PYTHON_RESUMED').write_text('Unexpected resume\n')
    while True:time.sleep(1)

def child_action(journal,phase,restore=False):
    value=json.loads(journal.read_text());assert value['pid'] not in (3582995,3583093)
    def fault(point):
        if phase==point:os.kill(os.getpid(),signal.SIGKILL)
    result=n.restore(value,fault) if restore else n.execute(value,fault)
    dump(journal.parent/('restore_action.json' if restore else 'execute_action.json'),result)

def main():
    os.sched_setaffinity(0,{0,1,2,3});os.setpriority(os.PRIO_PROCESS,0,19)
    subprocess.run(['/usr/bin/ionice','-c','3','-p',str(os.getpid())],check=True,timeout=2)
    assert n.libc.prctl(36,1,0,0,0)==0
    out=HERE.parents[6]/'project/E022_m007_full_top_physical/experiment_results/runs/R001'/('guard_selfstop_tests_'+str(time.time_ns()))
    out.mkdir();results=[];begun=time.monotonic()
    modes=['normal','before_write','partial_write','after_registers','running_1','before_real_stop','after_real_stop','restore_partial_write','restore_after_registers']
    try:
        for mode in modes:
            case=out/mode;case.mkdir();data=None
            guard=subprocess.Popen([sys.executable,__file__,'--fixture',str(case)],start_new_session=True)
            try:
                end=time.monotonic()+2
                while not (case/'fixture.json').exists() and time.monotonic()<end:time.sleep(.005)
                data=json.loads((case/'fixture.json').read_text());pid=guard.pid
                end=time.monotonic()+.5
                while Path(f'/proc/{pid}/wchan').read_text().strip()!='hrtimer_nanosleep' and time.monotonic()<end:time.sleep(.001)
                assert Path(f'/proc/{pid}/wchan').read_text().strip()=='hrtimer_nanosleep'
                os.kill(pid,signal.SIGSTOP);stopped(pid)
                journal=n.snapshot(pid,data['guard']['start'],data['zombie']['pid'],data['zombie']['start'])
                journal['isolated_fixture']=True;path=case/'journal.json';dump(path,journal)
                exec_mode='' if mode.startswith('restore_') or mode=='normal' else mode
                child=subprocess.run([sys.executable,__file__,'--execute',str(path),exec_mode],capture_output=True,text=True,timeout=2)
                (case/'execute.stderr').write_text(child.stderr)
                stopped(pid)
                if exec_mode:assert child.returncode==-9,(mode,child.stderr)
                else:assert child.returncode==0,(mode,child.stderr)
                before_restore=n.proc(pid)
                if mode=='normal':
                    assert json.loads((case/'execute_action.json').read_text())['wait4_return']==data['zombie']['pid']
                    os.kill(pid,signal.SIGCONT);time.sleep(.02);stopped(pid)
                restore_exit=None
                if mode.startswith('restore_'):
                    fault=subprocess.run([sys.executable,__file__,'--restore',str(path),mode],capture_output=True,text=True,timeout=2)
                    (case/'restore.stderr').write_text(fault.stderr);restore_exit=fault.returncode
                    assert restore_exit==-9;stopped(pid)
                n.restore(journal)
                n.attach(pid,journal['start'])
                actual=n.regs(pid);register_match=all(getattr(actual,k)==v for k,v in journal['registers'].items())
                bytes_match=n.memory(pid,journal['location']['address']).hex()==journal['original_bytes']
                n.detach_stopped(pid,journal['start'])
                with (case/'lock').open('a') as lock:
                    try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB);held=False
                    except BlockingIOError:held=True
                leader=n.proc(data['leader']['pid']);worker=n.proc(data['zombie']['pid'])
                result=dict(case=mode,execute_exit=child.returncode,restore_fault_exit=restore_exit,guard_before_restore=before_restore,
                            guard_after=n.proc(pid),registers_restored=register_match,bytes_restored=bytes_match,lock_held=held,
                            leader_unchanged=bool(leader and leader['start']==data['leader']['start'] and leader['state']!='Z'),
                            worker_after=worker,old_python_marker=(case/'OLD_PYTHON_RESUMED').exists())
                assert register_match and bytes_match and held and result['leader_unchanged'] and not result['old_python_marker'],result
                dump(case/'result.json',result);results.append(result)
            finally:
                if data:
                    for identity in [data['leader'],data['guard']]:
                        item=n.proc(identity['pid'])
                        if item and item['start']==identity['start']:os.kill(identity['pid'],signal.SIGKILL)
                elif guard.poll() is None:guard.kill()
                guard.wait(timeout=2)
                if data:
                    for identity in [data['leader'],data['zombie']]:
                        try:os.waitpid(identity['pid'],0)
                        except ChildProcessError:pass
                    assert all(n.proc(data[k]['pid']) is None for k in ['guard','leader','zombie'])
        receipt=dict(PASS=True,scope='Nine real isolated guard/zombie/leader cases only; no production attach, signals or recovery',elapsed_seconds=time.monotonic()-begun,tests=results,
                     source_sha256={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [Path(__file__),HERE/'guard_selfstop_native_d38.py']})
        dump(out/'test_result.json',receipt)
        print(json.dumps(dict(PASS=True,output=str(out),tests=len(results),elapsed_seconds=receipt['elapsed_seconds'])))
    except BaseException as exc:
        dump(out/'test_result.json',dict(PASS=False,error=repr(exc),completed=results));print(str(out),flush=True);raise

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='--fixture':fixture(Path(sys.argv[2]))
    elif len(sys.argv)>1 and sys.argv[1] in ('--execute','--restore'):child_action(Path(sys.argv[2]),sys.argv[3],sys.argv[1]=='--restore')
    else:main()
