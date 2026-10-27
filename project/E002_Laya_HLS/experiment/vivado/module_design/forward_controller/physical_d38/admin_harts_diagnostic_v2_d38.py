#!/usr/bin/python3
"""Fixed AT019 v2: bounded read-only HARTS fields, using A014's verified layout."""
if not __debug__:
    raise RuntimeError('Optimized Python is forbidden: all safety assertions must remain enabled')
import argparse
import datetime as dt
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import time
import uuid

HERE = Path(__file__).resolve().parent
V1 = HERE/'admin_stack_diagnostic_d38.py'
READER = HERE/'admin_harts_object_reader_d38.py'
V1_SHA = '6621497d6e4e815a2076ce565d9d820e7f5e8236c21b5149b17f0157c286e4b0'
READER_SHA = '389c4dcd41fc3c9deb84016684751decdadb31cd55f5dbca52d43e94c987492a'

def load(name, path, expected):
    assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, 'Diagnostic dependency changed'
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

base = load('immutable_v1_stack_diagnostic', V1, V1_SHA)
reader = load('fixed_harts_object_reader', READER, READER_SHA)

def policy():
    os.sched_setaffinity(0, {0, 1, 2, 3})
    os.setpriority(os.PRIO_PROCESS, 0, 19)
    subprocess.run(['/usr/bin/ionice', '-c', '3', '-p', str(os.getpid())], check=True, timeout=2)
    io = subprocess.run(['/usr/bin/ionice', '-p', str(os.getpid())], capture_output=True,
                        text=True, check=True, timeout=2).stdout.strip()
    assert os.sched_getaffinity(0) == {0, 1, 2, 3}
    assert os.getpriority(os.PRIO_PROCESS, 0) == 19 and 'idle' in io.lower()
    return dict(CPU_ids=[0, 1, 2, 3], nice=19, IO=io)

def preflight():
    result = base.preflight()
    if result['guard']['state'] != 'T' or result['guard']['tracer_pid'] != 0:
        raise RuntimeError('Original guard must remain untraced and stopped in state T')
    assert reader.process_identity(reader.PID, reader.LWP)['start'] == reader.LWP_START
    result['fixed_LWP'] = reader.process_identity(reader.PID, reader.LWP)
    result['ELF_attestations'] = reader.validate_libraries(reader.maps())
    result['read_scope'] = 'worker_count, termination_flag, bounded worker PID list; supporting frame/vector bounds only'
    return result

def command(frozen_reader):
    argv = ['/usr/bin/gdb', '-q', '-nx', '-nh', '--batch',
            '-iex', 'set auto-load off', '-iex', 'set debuginfod enabled off']
    commands = ['set pagination off', 'set confirm off', 'set auto-solib-add off',
                'set print thread-events off', 'set print frame-arguments none',
                'set may-call-functions off', 'set may-write-memory off',
                'set may-write-registers off', 'set may-insert-breakpoints off',
                'set may-insert-tracepoints off', f'attach {reader.PID}', 'info threads',
                'source '+str(frozen_reader), 'detach', 'quit']
    for item in commands:
        argv += ['-ex', item]
    return argv

def capture(out, frozen_reader):
    before = base.same(reader.PID, reader.START)
    assert before['tracer_pid'] == 0 and before['state'] not in ('T', 't')
    cfg = out/'reader_config.json'
    base.dump(cfg, {'output': str(out/'object_fields.json')})
    env = os.environ.copy()
    env.update(DEBUGINFOD_URLS='', GDBHISTFILE='/dev/null', LC_ALL='C', D38_HARTS_CONFIG=str(cfg))
    argv = command(frozen_reader)
    result = dict(started_utc=base.now(), target_before=before, argv=argv,
                  timeout_seconds=20, timed_out=False, cleanup_signals=[])
    begun = time.monotonic()
    with (out/'gdb.txt').open('wb') as log:
        debugger = subprocess.Popen(argv, stdin=subprocess.DEVNULL, stdout=log,
                                    stderr=subprocess.STDOUT, env=env, start_new_session=True)
        result['debugger_pid'] = debugger.pid
        try:
            debugger.wait(timeout=20)
        except subprocess.TimeoutExpired:
            result['timed_out'] = True
        finally:
            # Only the newly created gdb group can be signalled; never a production group.
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
    after = base.proc(reader.PID)
    result['target_after'] = after
    result['detach_verified'] = bool(after and after['start'] == reader.START and
                                     after['tracer_pid'] == 0 and after['state'] not in ('T', 't', 'Z'))
    result['elapsed_seconds'] = time.monotonic()-begun
    result['ended_utc'] = base.now()
    base.dump(out/'capture.json', result)
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    diagnostic_policy = policy()
    before = preflight()
    before['diagnostic_policy'] = diagnostic_policy
    if not args.execute:
        print(json.dumps(dict(mode='plan_only_no_attach', preflight=before,
                              v1_sha256=V1_SHA, reader_sha256=READER_SHA)))
        return
    out = base.DEST/(dt.datetime.now(dt.timezone.utc).strftime('DG_OBJECT_%Y%m%dT%H%M%SZ_')+uuid.uuid4().hex[:8])
    out.mkdir(mode=0o750, parents=False)
    try:
        base.dump(out/'preflight.json', before)
        base.dump(out/'script_identity.json', {'path': str(Path(__file__).resolve()),
                  'sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  'reader_path': str(READER), 'reader_sha256': READER_SHA,
                  'immutable_v1_path': str(V1), 'immutable_v1_sha256': V1_SHA})
        frozen = out/'frozen_harts_reader.py'
        shutil.copyfile(READER, frozen)
        assert hashlib.sha256(frozen.read_bytes()).hexdigest() == READER_SHA
        result = capture(out, frozen)
        base.dump(out/'postflight.json', preflight())
        assert result['detach_verified'], 'Detach not verified; inspect capture.json immediately'
        fields = base.read(out/'object_fields.json') if (out/'object_fields.json').exists() else {}
        print(json.dumps(dict(output=str(out), debugger_exit=result['debugger_exit'],
                              timed_out=result['timed_out'], detach_verified=result['detach_verified'],
                              fields_valid=fields.get('valid', False), elapsed_seconds=result['elapsed_seconds'])))
        assert result['debugger_exit'] == 0 and not result['timed_out'] and fields.get('valid') is True
    except BaseException as exc:
        base.dump(out/'error.json', {'utc': base.now(), 'error': repr(exc),
                  'target': base.proc(reader.PID), 'guard': base.proc(base.GUARD)})
        raise
    finally:
        base.permissions(out)

if __name__ == '__main__':
    main()
