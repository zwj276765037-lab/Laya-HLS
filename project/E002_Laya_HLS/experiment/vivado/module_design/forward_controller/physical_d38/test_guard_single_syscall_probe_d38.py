#!/usr/bin/python3
"""Isolated feasibility probe only. No production PID or administrator mode."""
if not __debug__:
    raise RuntimeError('Optimized Python forbidden')
import ctypes
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

libc = ctypes.CDLL(None, use_errno=True)
libc.ptrace.restype = ctypes.c_long
libc.ptrace.argtypes = [ctypes.c_ulong, ctypes.c_ulong, ctypes.c_void_p, ctypes.c_void_p]
SEIZE, INTERRUPT, GETREGS, SETREGS, STEP, DETACH = 0x4206, 0x4207, 12, 13, 9, 17
NAMES = 'r15 r14 r13 r12 rbp rbx r11 r10 r9 r8 rax rcx rdx rsi rdi orig_rax rip cs eflags rsp ss fs_base gs_base ds es fs gs'.split()
class Registers(ctypes.Structure):
    _fields_ = [(name, ctypes.c_ulonglong) for name in NAMES]

def dump(path, data):
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(data, indent=2)+'\n')
    temporary.replace(path)

def proc(pid):
    try:
        fields = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()
        return dict(pid=pid, start=int(fields[19]), state=fields[0], ppid=int(fields[1]))
    except FileNotFoundError:
        return None

def ptrace(request, pid, address=0, data=0):
    ctypes.set_errno(0)
    value = libc.ptrace(request, pid, address, data)
    if value == -1 and ctypes.get_errno():
        raise OSError(ctypes.get_errno(), os.strerror(ctypes.get_errno()))
    return value

def stopped(pid, timeout=.5):
    end = time.monotonic()+timeout
    while time.monotonic() < end:
        found, status = os.waitpid(pid, os.WNOHANG | os.WUNTRACED | 0x40000000)
        if found:
            assert os.WIFSTOPPED(status), (found, status)
            return status
        time.sleep(.001)
    raise TimeoutError('Specific tracee did not stop')

def getregs(pid):
    r = Registers(); ptrace(GETREGS, pid, data=ctypes.byref(r)); return r

def tracer(cfg, mode):
    data = json.loads(cfg.read_text()); pid = data['guard']['pid']
    assert proc(pid)['start'] == data['guard']['start']
    assert proc(pid)['state'] == 'T' and pid not in (3582995, 3583093)
    begun = time.monotonic(); attached = False; saved = None
    result = dict(mode=mode, target_before=proc(pid), syscall_count=0)
    try:
        ptrace(SEIZE, pid); attached = True
        ptrace(INTERRUPT, pid); result['initial_stop'] = stopped(pid)
        saved = getregs(pid)
        result['saved_registers'] = {name: getattr(saved,name) for name in NAMES}
        dump(cfg.parent/'registers.json', result['saved_registers'])
        gadget = None
        for line in Path(f'/proc/{pid}/maps').read_text().splitlines():
            f = line.split(None, 5)
            if len(f) == 6 and f[1] == 'r-xp' and f[5] == '/usr/lib/x86_64-linux-gnu/libc.so.6':
                gadget = int(f[0].split('-')[0],16)-int(f[2],16)+0xecbdd
        assert gadget
        with Path('/usr/lib/x86_64-linux-gnu/libc.so.6').open('rb') as stream:
            stream.seek(0xecbdd); assert stream.read(2) == b'\x0f\x05'
        injected = Registers.from_buffer_copy(saved)
        injected.rip = gadget; injected.rax = 61; injected.orig_rax = (1 << 64)-1
        injected.rdi = data['zombie']['pid']; injected.rsi = 0; injected.rdx = os.WNOHANG; injected.r10 = 0
        ptrace(SETREGS, pid, data=ctypes.byref(injected))
        if mode == 'tracer_killed_before_step':
            os.kill(os.getpid(), signal.SIGKILL)
        result['step_stops'] = []
        for step_index in range(3):
            ptrace(STEP, pid)
            if mode == 'tracer_killed_during_step' and step_index == 1:
                os.kill(os.getpid(), signal.SIGKILL)
            result['step_stops'].append(stopped(pid))
            after = getregs(pid)
            if after.rip == gadget+2:
                result['syscall_count'] = 1
                break
            assert after.rip == gadget and after.rax == 61
        result['syscall_result'] = {name:getattr(after,name) for name in ['rax','orig_rax','rip']}
        dump(cfg.parent/'step_result.json', result)
        if mode == 'tracer_killed_after_step':
            os.kill(os.getpid(), signal.SIGKILL)
        assert after.rip == gadget+2 and after.rax == data['zombie']['pid'], result
    finally:
        if attached:
            if saved is not None:
                ptrace(SETREGS, pid, data=ctypes.byref(saved))
                assert bytes(getregs(pid)) == bytes(saved), 'Register restore differs'
                if mode == 'tracer_killed_after_restore':
                    os.kill(os.getpid(),signal.SIGKILL)
            os.kill(pid, signal.SIGSTOP)
            ptrace(DETACH, pid, data=signal.SIGSTOP)
    result.update(target_after=proc(pid), elapsed_seconds=time.monotonic()-begun)
    dump(cfg.parent/'tracer_result.json', result)

def restore(cfg):
    data = json.loads(cfg.read_text()); pid = data['guard']['pid']
    assert proc(pid)['state'] == 'T'
    registers = Registers(**json.loads((cfg.parent/'registers.json').read_text()))
    ptrace(SEIZE,pid); ptrace(INTERRUPT,pid); stopped(pid)
    ptrace(SETREGS,pid,data=ctypes.byref(registers))
    assert bytes(getregs(pid)) == bytes(registers)
    os.kill(pid,signal.SIGSTOP); ptrace(DETACH,pid,data=signal.SIGSTOP)

def fixture(out):
    assert libc.prctl(0x59616d61, ctypes.c_ulong(-1).value, 0, 0, 0) == 0
    lock=(out/'fixture.lock').open('w'); fcntl.flock(lock,fcntl.LOCK_EX)
    child=os.fork()
    if child == 0:
        os._exit(0)
    until=time.monotonic()+1
    while proc(child)['state'] != 'Z' and time.monotonic()<until:
        time.sleep(.001)
    dump(out/'fixture.json',dict(guard=proc(os.getpid()),zombie=proc(child)))
    time.sleep(10)
    (out/'FORBIDDEN_PYTHON_RESUMED').write_text('Original fixture Python resumed\n')
    while True:
        time.sleep(.1)

def main():
    assert os.uname().machine == 'x86_64'
    os.sched_setaffinity(0,{0,1,2,3}); os.setpriority(os.PRIO_PROCESS,0,19)
    subprocess.run(['/usr/bin/ionice','-c','3','-p',str(os.getpid())],check=True,timeout=2)
    assert libc.prctl(36,1,0,0,0) == 0
    root=Path(__file__).resolve().parents[7]
    out=root/'project/E022_m007_full_top_physical/experiment_results/runs/R001'/('guard_single_syscall_probe_'+str(time.time_ns()))
    out.mkdir(); results=[]
    for mode in ['normal','tracer_killed_before_step','tracer_killed_during_step','tracer_killed_after_step','tracer_killed_after_restore']:
        case=out/mode;case.mkdir()
        guard=subprocess.Popen([sys.executable,__file__,'--fixture',str(case)],start_new_session=True)
        data=None
        try:
            until=time.monotonic()+2
            while not (case/'fixture.json').exists() and time.monotonic()<until:time.sleep(.005)
            data=json.loads((case/'fixture.json').read_text())
            until=time.monotonic()+1
            while Path(f'/proc/{guard.pid}/wchan').read_text().strip()!='hrtimer_nanosleep' and time.monotonic()<until:time.sleep(.001)
            assert Path(f'/proc/{guard.pid}/wchan').read_text().strip()=='hrtimer_nanosleep'
            os.kill(guard.pid,signal.SIGSTOP)
            until=time.monotonic()+.2
            while proc(guard.pid)['state']!='T' and time.monotonic()<until:time.sleep(.001)
            data['guard']=proc(guard.pid)
            assert data['guard']['state']=='T' and data['zombie']['state']=='Z'
            dump(case/'fixture.json',data)
            result=subprocess.run([sys.executable,__file__,'--trace',str(case/'fixture.json'),mode],capture_output=True,text=True,timeout=2)
            (case/'tracer.stderr').write_text(result.stderr)
            time.sleep(.03)
            after=proc(guard.pid)
            with (case/'fixture.lock').open('w') as check_lock:
                try:
                    fcntl.flock(check_lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
                    held=False
                except BlockingIOError:
                    held=True
            observed=dict(mode=mode,tracer_exit=result.returncode,guard_after=after,zombie_after=proc(data['zombie']['pid']),python_resumed=(case/'FORBIDDEN_PYTHON_RESUMED').exists(),lock_held=held)
            dump(case/'observed.json',observed)
            results.append(observed)
            assert after and after['state']=='T' and not observed['python_resumed'] and held, observed
            if mode != 'normal':restore(case/'fixture.json')
            if mode == 'normal':assert result.returncode==0, result.stderr
        finally:
            if guard.poll() is None:os.kill(guard.pid,signal.SIGKILL)
            guard.wait(timeout=2)
            if data:
                try:os.waitpid(data['zombie']['pid'],os.WNOHANG)
                except ChildProcessError:pass
    dump(out/'test_result.json',dict(PASS=True,scope='Isolated feasibility only; no production operation',results=results))
    print(json.dumps(dict(output=str(out),PASS=True,results=results)))

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='--fixture':fixture(Path(sys.argv[2]))
    elif len(sys.argv)>1 and sys.argv[1]=='--trace':tracer(Path(sys.argv[2]),sys.argv[3])
    else:main()
