"""A014's fixed AT019 read-only object decoder; explicitly sourced by gdb."""
if not __debug__:
    raise RuntimeError('Optimized Python is forbidden: all safety assertions must remain enabled')
import hashlib
import json
import os
from pathlib import Path
import struct
import sys

PID, START, LWP, LWP_START = 3583093, 66052106, 3634083, 66421453
STRIDE, MAX_WORKERS = 0x2050, 64
LIBS = [
    dict(name='synth', path='/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/lib/lnx64.o/libxv_synth.so',
         sha256='f8aa557764afc68ab13fb747fa3801ec4d66659ce404ffef3d38f380dceeb6cc',
         inode=158628289, dev='103:02', bias=0x773067400000,
         rx=0x773068202000, offset=0xe02000, vaddr=0xe02000),
    dict(name='libc', path='/usr/lib/x86_64-linux-gnu/libc.so.6',
         sha256='3a15d66867d83762c7f2f1e37359cb8f6c5743edb369c65285cb0b1c4f7498bf',
         inode=227566829, dev='103:02', bias=0x77307a800000,
         rx=0x77307a828000, offset=0x28000, vaddr=0x28000),
]

def process_identity(pid, task=None):
    p = Path('/proc')/str(pid)
    if task is not None:
        p = p/'task'/str(task)
    fields = (p/'stat').read_text().rsplit(')', 1)[1].split()
    return dict(pid=pid, lwp=task, start=int(fields[19]), state=fields[0],
                ppid=int(fields[1]), pgid=int(fields[2]), sid=int(fields[3]))

def maps():
    items = []
    for line in (Path('/proc')/str(PID)/'maps').read_text().splitlines():
        fields = line.split(None, 5)
        lo, hi = [int(x, 16) for x in fields[0].split('-')]
        items.append(dict(lo=lo, hi=hi, perms=fields[1], offset=int(fields[2], 16),
                          dev=fields[3], inode=int(fields[4]), path=fields[5] if len(fields)>5 else ''))
    return items

def region(items, address, size, execute=False):
    assert isinstance(address, int) and 0 < address < (1 << 47)
    assert 0 < size <= 0x1000 and address+size <= (1 << 47)
    matches = [x for x in items if x['lo'] <= address and address+size <= x['hi'] and
               'r' in x['perms'] and (not execute or 'x' in x['perms'])]
    assert len(matches) == 1, 'Address not inside one permitted readable mapping'
    return matches[0]

def validate_libraries(items):
    result = []
    for lib in LIBS:
        p = Path(lib['path']); before = p.stat()
        assert before.st_ino == lib['inode']
        assert f'{os.major(before.st_dev):x}:{os.minor(before.st_dev):02x}' == lib['dev']
        digest = hashlib.sha256()
        with p.open('rb') as f:
            header = f.read(64)
            assert header[:6] == b'\x7fELF\x02\x01', 'Expected little-endian ELF64'
            phoff = struct.unpack_from('<Q', header, 32)[0]
            entsize, count = struct.unpack_from('<HH', header, 54)
            assert entsize == 56 and 0 < count <= 128
            f.seek(phoff); headers = [struct.unpack('<IIQQQQQQ', f.read(56)) for _ in range(count)]
            assert any(x[0] == 1 and x[1] & 1 and x[2] == lib['offset'] and
                       x[3] == lib['vaddr'] for x in headers), 'PT_LOAD mismatch'
            f.seek(0)
            for chunk in iter(lambda: f.read(1024*1024), b''):
                digest.update(chunk)
        assert digest.hexdigest() == lib['sha256'], 'ELF file hash mismatch'
        after = p.stat()
        assert (before.st_ino, before.st_size, before.st_mtime_ns) == (after.st_ino, after.st_size, after.st_mtime_ns)
        rx = [x for x in items if x['lo'] == lib['rx'] and x['offset'] == lib['offset'] and
              'x' in x['perms'] and 'r' in x['perms'] and x['inode'] == lib['inode'] and
              x['dev'] == lib['dev'] and x['path'] and Path(x['path']).resolve() == p.resolve()]
        assert len(rx) == 1 and rx[0]['lo']-lib['vaddr'] == lib['bias'], 'ELF mapping/bias mismatch'
        result.append(dict(name=lib['name'], sha256=digest.hexdigest(), mapping=rx[0],
                           bias=lib['bias'], file_bytes=before.st_size, mtime_ns=before.st_mtime_ns))
    return result

def decode(read_memory, registers, items, result):
    """Only small reads: five stack words, four object fields, <=64 four-byte PIDs."""
    libc, synth = LIBS[1], LIBS[0]
    assert registers['pc'] == libc['bias']+0xecbdf, 'Unexpected selected-thread PC; stop'
    assert region(items, registers['pc'], 1, execute=True)['inode'] == libc['inode']
    b, sp = registers['rbp'], registers['rsp']
    assert b % 16 == 0 and 0 <= b-sp <= 0x1000, 'Unexpected frame0 alignment/shape'
    stack = region(items, sp, 8)
    assert 'w' in stack['perms'] and 'x' not in stack['perms']
    assert stack['lo'] <= b-0x28 and b+0x70 <= stack['hi'], 'Frame exceeds selected readable stack'
    raw = result.setdefault('raw_reads', [])
    def value(name, address, fmt):
        size = struct.calcsize(fmt)
        region(items, address, size)
        v = struct.unpack(fmt, bytes(read_memory(address, size)))[0]
        raw.append(dict(name=name, address=hex(address), bytes=size, value=v))
        return v
    nframe = value('clock_saved_rbp_N', b, '<Q')
    ret1 = value('clock_return', b+8, '<Q')
    assert nframe == b+0x10 and nframe % 16 == 0, 'Unexpected nanosleep frame'
    assert ret1 == libc['bias']+0xf9b27, 'Unexpected libc return address'
    assert region(items, ret1, 1, execute=True)['inode'] == libc['inode']
    hartframe = value('nanosleep_saved_rbp_H', nframe, '<Q')
    ret2 = value('nanosleep_return', nframe+8, '<Q')
    assert hartframe == nframe+0x50 and hartframe % 16 == 0, 'Unexpected HARTS frame'
    assert region(items, hartframe, 8) == stack
    assert ret2 == synth['bias']+0x18869c5, 'Unexpected synth return address'
    assert region(items, ret2, 1, execute=True)['inode'] == synth['inode']
    this = value('saved_caller_rbx_this', b-0x28, '<Q')
    assert this % 8 == 0
    region(items, this, 0x132)
    count = value('worker_count', this+0x10, '<I')
    assert count <= MAX_WORKERS, 'Worker count exceeds fixed cap'
    flag = value('termination_flag', this+0x131, '<B')
    begin = value('worker_vector_begin', this+0xe0, '<Q')
    end = value('worker_vector_end', this+0xe8, '<Q')
    assert begin <= end and (end-begin) % STRIDE == 0, 'Invalid vector bounds/stride'
    vector_count = (end-begin)//STRIDE
    assert count <= vector_count <= MAX_WORKERS, 'Invalid vector element count'
    if count:
        assert begin > 0 and begin % 8 == 0
    addresses = [begin+i*STRIDE+8 for i in range(count)]
    for address in addresses:
        region(items, address, 4)
    pids = [value(f'worker_pid[{i}]', address, '<i') for i, address in enumerate(addresses)]
    result.update(this=hex(this), stack_frame_B=hex(b), stack_frame_N=hex(nframe),
                  stack_frame_H=hex(hartframe), worker_count=count, termination_flag=flag,
                  vector_begin=hex(begin), vector_end=hex(end), vector_elements=vector_count,
                  worker_pids=pids)

def main():
    import gdb
    cfg = json.loads(Path(os.environ['D38_HARTS_CONFIG']).read_text())
    output = Path(cfg['output'])
    result = dict(valid=False, scope='Read-only object fields; no recovery or root-cause claim')
    try:
        assert process_identity(PID)['start'] == START
        assert process_identity(PID, LWP)['start'] == LWP_START
        inferior = gdb.selected_inferior()
        assert inferior.pid == PID
        candidates = [t for t in inferior.threads() if t.ptid[1] == LWP]
        assert len(candidates) == 1
        candidates[0].switch()
        gdb.newest_frame().select()
        registers = {name: int(gdb.parse_and_eval('$'+name)) for name in ['pc', 'rbp', 'rsp']}
        result.update(lwp=LWP, lwp_start=LWP_START, registers={k: hex(v) for k,v in registers.items()})
        items = maps()
        result['ELF_attestations'] = validate_libraries(items)
        decode(inferior.read_memory, registers, items, result)
        identities = []
        for pid in result['worker_pids']:
            if pid <= 0:
                identities.append(dict(raw_pid=pid, interpretation='Not a normal positive worker PID'))
                continue
            try:
                identities.append(dict(raw_pid=pid, proc=process_identity(pid)))
            except (FileNotFoundError, ProcessLookupError):
                identities.append(dict(raw_pid=pid, proc=None))
        result['worker_process_observations'] = identities
        result['valid'] = True
    except BaseException as exc:
        result['error'] = repr(exc)
    output.write_text(json.dumps(result, indent=2)+'\n')
    print('D38_HARTS_FIELDS valid='+str(result['valid'])+' output='+str(output))

if 'gdb' in sys.modules:
    main()
