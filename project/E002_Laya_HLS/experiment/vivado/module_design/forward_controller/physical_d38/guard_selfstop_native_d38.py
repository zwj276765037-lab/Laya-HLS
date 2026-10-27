#!/usr/bin/python3
"""Bounded native primitive. No production command-line entry is provided."""
if not __debug__:
    raise RuntimeError('Optimized Python forbidden')
import ctypes
import hashlib
import json
import os
from pathlib import Path
import signal
import struct
import time

LIBC = Path('/usr/lib/x86_64-linux-gnu/libc.so.6')
LIBC_SHA = '3a15d66867d83762c7f2f1e37359cb8f6c5743edb369c65285cb0b1c4f7498bf'
SLOT, LENGTH = 0x1b0040, 48
SEIZE, INTERRUPT, GETREGS, SETREGS, CONT, DETACH, PEEK, POKE = 0x4206, 0x4207, 12, 13, 7, 17, 1, 4
NAMES = 'r15 r14 r13 r12 rbp rbx r11 r10 r9 r8 rax rcx rdx rsi rdi orig_rax rip cs eflags rsp ss fs_base gs_base ds es fs gs'.split()
class Registers(ctypes.Structure):
    _fields_ = [(name, ctypes.c_ulonglong) for name in NAMES]
libc = ctypes.CDLL(None,use_errno=True)
libc.ptrace.restype = ctypes.c_long
libc.ptrace.argtypes = [ctypes.c_ulong,ctypes.c_ulong,ctypes.c_void_p,ctypes.c_void_p]

def proc(pid):
    try:
        p=Path(f'/proc/{pid}')
        s=(p/'stat').read_text().rsplit(')',1)[1].split()
        tracer=int(next(v.split(':')[1] for v in (p/'status').read_text().splitlines() if v.startswith('TracerPid:')))
        return dict(pid=pid,start=int(s[19]),state=s[0],ppid=int(s[1]),tracer=tracer)
    except (FileNotFoundError,ProcessLookupError):return None

def same(pid,start):
    item=proc(pid);assert item and item['start']==start and item['state']!='Z';return item

def call(request,pid,address=0,data=0):
    ctypes.set_errno(0);v=libc.ptrace(request,pid,address,data)
    if v==-1 and ctypes.get_errno():raise OSError(ctypes.get_errno(),os.strerror(ctypes.get_errno()))
    return v

def waitstop(pid,timeout=.3):
    end=time.monotonic()+timeout
    while time.monotonic()<end:
        found,status=os.waitpid(pid,os.WNOHANG|os.WUNTRACED|0x40000000)
        if found:
            assert os.WIFSTOPPED(status),(pid,status)
            return status
        time.sleep(.001)
    raise TimeoutError('Exact tracee stop timed out')

def regs(pid):
    value=Registers();call(GETREGS,pid,data=ctypes.byref(value));return value

def memory(pid,address):
    return b''.join((call(PEEK,pid,address+n)&((1<<64)-1)).to_bytes(8,'little') for n in range(0,LENGTH,8))

def write(pid,address,value,hook=lambda phase:None):
    assert len(value)==LENGTH and address%8==0
    for n in range(0,LENGTH,8):
        call(POKE,pid,address+n,int.from_bytes(value[n:n+8],'little'))
        if n==16:hook('partial_write')
    assert memory(pid,address)==value

def attach(pid,start):
    item=same(pid,start);assert item['state']=='T' and item['tracer']==0
    assert len(list(Path(f'/proc/{pid}/task').iterdir()))==1
    call(SEIZE,pid);call(INTERRUPT,pid);waitstop(pid)

def detach_stopped(pid,start):
    call(DETACH,pid,data=signal.SIGSTOP)
    end=time.monotonic()+.2
    while time.monotonic()<end:
        item=same(pid,start)
        if item['state']=='T' and item['tracer']==0:return item
        time.sleep(.001)
    raise RuntimeError('Real job-control T/untraced not established')

def location(pid):
    before=LIBC.stat();assert before.st_ino==227566829
    assert f'{os.major(before.st_dev):x}:{os.minor(before.st_dev):02x}'=='103:02'
    data=LIBC.read_bytes();assert hashlib.sha256(data).hexdigest()==LIBC_SHA
    phoff=struct.unpack_from('<Q',data,32)[0]
    entsize,count=struct.unpack_from('<HH',data,54);assert entsize==56
    headers=[struct.unpack_from('<IIQQQQQQ',data,phoff+n*56) for n in range(count)]
    rx=[v for v in headers if v[0]==1 and v[1]==5]
    assert len(rx)==1 and rx[0][2:6]==(0x28000,0x28000,0x28000,0x188039) and rx[0][6]==0x188039
    assert rx[0][3]+rx[0][6] == 0x1b0039 < SLOT and SLOT+LENGTH<=0x1b1000
    assert any(v[0]==1 and v[2]==v[3]==0x1b1000 and v[1]==4 for v in headers)
    assert data[0x1b0039:0x1b1000]==bytes(4039)
    matches=[]
    for line in Path(f'/proc/{pid}/maps').read_text().splitlines():
        f=line.split(None,5)
        if len(f)==6 and f[1]=='r-xp' and f[2]=='00028000' and f[3]=='103:02' and int(f[4])==227566829 and Path(f[5]).resolve()==LIBC:
            lo,hi=[int(v,16) for v in f[0].split('-')];bias=lo-0x28000
            assert bias+SLOT+LENGTH<=hi and hi==bias+0x1b1000
            matches.append(dict(bias=bias,address=bias+SLOT,mapping=line))
    assert len(matches)==1
    after=LIBC.stat();assert (before.st_ino,before.st_size,before.st_mtime_ns)==(after.st_ino,after.st_size,after.st_mtime_ns)
    return matches[0]

def stub(child,parent):
    assert 0<child<1<<31 and 0<parent<1<<31 and child!=parent
    value=(b'\xb8\x3d\0\0\0\xbf'+struct.pack('<I',child)+b'\x31\xf6\xba\x01\0\0\0\x45\x31\xd2\x0f\x05\x49\x89\xc4\xb8\x3e\0\0\0\xbf'+struct.pack('<I',parent)+b'\xbe\x13\0\0\0\x0f\x05\xeb\xed')
    assert len(value)==44
    return value+bytes(4)

def snapshot(pid,start,child,child_start):
    assert os.uname().machine=='x86_64'
    worker=proc(child)
    assert worker and worker['start']==child_start and worker['state']=='Z' and worker['ppid']==pid
    loc=location(pid);attach(pid,start)
    try:
        original=memory(pid,loc['address']);assert original==bytes(LENGTH)
        saved=regs(pid)
        result=dict(pid=pid,start=start,child=child,child_start=child_start,location=loc,
                    original_bytes=original.hex(),registers={n:getattr(saved,n) for n in NAMES})
    finally:detach_stopped(pid,start)
    return result

def execute(journal,hook=lambda phase:None):
    """Leave guard at real T with native bytes present; restoration is separate."""
    pid,start=journal['pid'],journal['start'];address=journal['location']['address']
    assert location(pid)==journal['location']
    worker=proc(journal['child']);assert worker and worker['start']==journal['child_start'] and worker['state']=='Z' and worker['ppid']==pid
    attach(pid,start)
    saved=Registers(**journal['registers'])
    assert bytes(regs(pid))==bytes(saved) and memory(pid,address).hex()==journal['original_bytes']
    hook('before_write')
    write(pid,address,stub(journal['child'],pid),hook)
    injected=Registers.from_buffer_copy(saved);injected.rip=address;injected.rax=0;injected.orig_rax=(1<<64)-1;injected.eflags &= ~0x100
    call(SETREGS,pid,data=ctypes.byref(injected));hook('after_registers')
    events=[];result=None
    for index in range(5):
        call(CONT,pid)
        hook('running_'+str(index))
        status=waitstop(pid);events.append(status)
        current=regs(pid)
        if address+25<=current.rip<=address+44 and current.r12==journal['child']:
            result=dict(wait4_return=current.r12,stop_registers={n:getattr(current,n) for n in NAMES},events=events)
            hook('before_real_stop')
            detach_stopped(pid,start);hook('after_real_stop')
            return result
        assert current.rip==address, 'Unexpected native execution path'
    raise RuntimeError('Native self-stop was not reached')

def restore(journal,hook=lambda phase:None):
    """Attach only from real T. Never restart after restoring old context."""
    pid,start=journal['pid'],journal['start'];address=journal['location']['address']
    item=same(pid,start);assert item['state']=='T' and item['tracer']==0
    assert location(pid)==journal['location']
    attach(pid,start)
    write(pid,address,bytes.fromhex(journal['original_bytes']),lambda phase:hook('restore_'+phase))
    original=Registers(**journal['registers']);call(SETREGS,pid,data=ctypes.byref(original))
    assert bytes(regs(pid))==bytes(original);hook('restore_after_registers')
    assert memory(pid,address).hex()==journal['original_bytes']
    return detach_stopped(pid,start)
