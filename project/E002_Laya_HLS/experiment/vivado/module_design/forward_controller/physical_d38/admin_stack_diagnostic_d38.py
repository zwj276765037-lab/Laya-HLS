#!/usr/bin/python3
"""One read-only, identity-bound AT019 stack capture. No sudo is invoked."""
import argparse
import datetime as dt
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
import uuid

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
RUN = ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
AT = RUN/'attempts/AT019_core_synth'
HANDOFF = AT/'unlimited_wall_handoff'
TARGET, START = 3583093, 66052106
GUARD, GUARD_START = 3582995, 66052065
DEST = AT/'admin_stack_diagnostics'

def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()

def read(path):
    return json.loads(Path(path).read_text())

def dump(path, value):
    Path(path).write_text(json.dumps(value, indent=2, ensure_ascii=False)+'\n')

def proc(pid):
    try:
        p = Path('/proc')/str(pid)
        fields = (p/'stat').read_text().rsplit(')', 1)[1].split()
        status = dict(x.split(':', 1) for x in (p/'status').read_text().splitlines() if ':' in x)
        return {'pid': pid, 'start': int(fields[19]), 'state': fields[0],
                'ppid': int(fields[1]), 'pgid': int(fields[2]), 'sid': int(fields[3]),
                'tracer_pid': int(status['TracerPid']),
                'cmdline': (p/'cmdline').read_bytes().replace(b'\0', b' ').decode(errors='replace')}
    except (FileNotFoundError, ProcessLookupError):
        return None

def same(pid, start):
    item = proc(pid)
    assert item and item['start'] == start and item['state'] != 'Z', 'PID/start mismatch'
    return item

def preflight():
    target = same(TARGET, START)
    assert target['pgid'] == 3583000 and target['sid'] == 3583000
    assert str(AT/'frozen/full_top_d38.tcl') in target['cmdline']
    assert target['tracer_pid'] == 0 and target['state'] not in ('T', 't')
    guard = same(GUARD, GUARD_START)
    assert guard['state'] in ('T', 't'), 'Retired guard must remain stopped'
    c = read(HANDOFF/'config.json')
    assert (c['actual_vivado_pid'], c['actual_vivado_start']) == (TARGET, START)
    assert c['attempt'] == str(AT) and c['maximum_seconds'] is None
    assert c['wall_time_limit_disabled'] is True
    ids = [('monitor', c['monitor_pid'], c['monitor_start'])]
    for role, name in [('watchdog', 'watchdog_ready.json'), ('observer', 'observer/ready.json')]:
        item = read(HANDOFF/name)
        ids.append((role, item['pid'], item['start']))
    supervisors = {}
    for role, pid, start in ids:
        item = same(pid, start)
        assert item['state'] not in ('T', 't') and item['tracer_pid'] == 0
        supervisors[role] = item
    for name in ['live_status.json', 'observer/live_status.json']:
        age = time.time()-dt.datetime.fromisoformat(read(HANDOFF/name)['utc']).timestamp()
        assert 0 <= age < 10, 'Supervision sample stale'
    assert time.time()-read(HANDOFF/'heartbeat.json')['epoch'] < 10
    assert read(RUN/'serial_continuation/state.json')['phase'] == 'waiting_existing_AT019'
    assert not (HANDOFF/'effective_receipt.json').exists(), 'Core already ended'
    with Path(c['lock']).open('r') as lock:
        assert os.fstat(lock.fileno()).st_ino == c['lock_inode']
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            pass
        else:
            fcntl.flock(lock, fcntl.LOCK_UN)
            raise AssertionError('Original heavy lock is not held')
    return {'utc': now(), 'target': target, 'guard': guard, 'supervisors': supervisors}

def command(pid, test_hold=False):
    commands = ['set pagination off', 'set confirm off', 'set auto-solib-add off',
                'set print thread-events off', 'set print frame-arguments none',
                'set may-call-functions off', 'set may-write-memory off',
                'set may-write-registers off', 'set may-insert-breakpoints off',
                'set may-insert-tracepoints off', f'attach {pid}', 'info threads', 'info sharedlibrary']
    if test_hold:
        assert pid != TARGET, 'Test delay forbidden for production target'
        commands.append('shell /usr/bin/sleep 5')  # Isolated timeout fixture only.
    commands += ['thread apply all bt 16', 'detach', 'quit']
    argv = ['/usr/bin/gdb', '-q', '-nx', '-nh', '--batch',
            '-iex', 'set auto-load off', '-iex', 'set debuginfod enabled off']
    for value in commands:
        argv += ['-ex', value]
    return argv

def capture(pid, start, out, timeout=20, test_hold=False):
    before = same(pid, start)
    assert before['tracer_pid'] == 0 and before['state'] not in ('T', 't')
    argv = command(pid, test_hold)
    env = os.environ.copy()
    env.update(DEBUGINFOD_URLS='', GDBHISTFILE='/dev/null', LC_ALL='C')
    result = {'started_utc': now(), 'target_before': before, 'argv': argv,
              'timeout_seconds': timeout, 'timed_out': False, 'cleanup_signals': []}
    begun = time.monotonic()
    with (out/'gdb.txt').open('wb') as log:
        debugger = subprocess.Popen(argv, stdin=subprocess.DEVNULL, stdout=log,
                                    stderr=subprocess.STDOUT, env=env, start_new_session=True)
        result['debugger_pid'] = debugger.pid
        try:
            debugger.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            result['timed_out'] = True
        finally:
            # Only our newly created debugger group is signalled. The target,
            # retired guard, monitors and their process groups are never signalled.
            for sig, seconds in [(signal.SIGINT, 3), (signal.SIGTERM, 2), (signal.SIGKILL, 2)]:
                if debugger.poll() is not None:
                    break
                assert os.getpgid(debugger.pid) == debugger.pid and debugger.pid != before['pgid']
                os.killpg(debugger.pid, sig)
                result['cleanup_signals'].append(signal.Signals(sig).name)
                try:
                    debugger.wait(timeout=seconds)
                except subprocess.TimeoutExpired:
                    pass
    result['debugger_exit'] = debugger.poll()
    result['target_after'] = proc(pid)
    after = result['target_after']
    result['detach_verified'] = bool(after and after['start'] == start and
                                     after['tracer_pid'] == 0 and after['state'] not in ('T', 't', 'Z'))
    result['elapsed_seconds'] = time.monotonic()-begun
    result['ended_utc'] = now()
    dump(out/'capture.json', result)
    return result

def permissions(out):
    owner = AT.stat()
    # Change ownership only inside this one newly created output directory.
    for item in [*out.iterdir(), out]:
        if os.geteuid() == 0:
            os.chown(item, owner.st_uid, owner.st_gid)
        os.chmod(item, 0o750 if item.is_dir() else 0o640)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    # Set only this diagnostic process; gdb inherits the same bounded policy.
    os.sched_setaffinity(0, {0, 1, 2, 3})
    os.setpriority(os.PRIO_PROCESS, 0, 19)
    subprocess.run(['/usr/bin/ionice', '-c', '3', '-p', str(os.getpid())], check=True, timeout=2)
    io = subprocess.run(['/usr/bin/ionice', '-p', str(os.getpid())], capture_output=True,
                        text=True, check=True, timeout=2).stdout.strip()
    assert os.sched_getaffinity(0) == {0, 1, 2, 3} and os.getpriority(os.PRIO_PROCESS, 0) == 19
    assert 'idle' in io.lower()
    before = preflight()
    before['diagnostic_policy'] = {'CPU_ids': [0, 1, 2, 3], 'nice': 19, 'IO': io}
    if not args.execute:
        print(json.dumps({'mode': 'plan_only_no_attach', 'preflight': before,
                          'argv': command(TARGET)}, ensure_ascii=False))
        return
    out = DEST/(dt.datetime.now(dt.timezone.utc).strftime('DG_%Y%m%dT%H%M%SZ_')+uuid.uuid4().hex[:8])
    out.mkdir(mode=0o750, parents=False)
    try:
        dump(out/'preflight.json', before)
        dump(out/'script_identity.json', {'path': str(Path(__file__).resolve()),
             'sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()})
        result = capture(TARGET, START, out)
        # No guard or monitor is attached or resumed, even during cleanup.
        after = preflight()
        dump(out/'postflight.json', after)
        assert result['detach_verified'], 'Detach not verified; inspect capture.json immediately'
        print(json.dumps({'output': str(out), 'debugger_exit': result['debugger_exit'],
                          'timed_out': result['timed_out'], 'detach_verified': True,
                          'elapsed_seconds': result['elapsed_seconds']}))
    except BaseException as exc:
        dump(out/'error.json', {'utc': now(), 'error': repr(exc), 'target': proc(TARGET),
                               'guard': proc(GUARD)})
        raise
    finally:
        permissions(out)

if __name__ == '__main__':
    main()
