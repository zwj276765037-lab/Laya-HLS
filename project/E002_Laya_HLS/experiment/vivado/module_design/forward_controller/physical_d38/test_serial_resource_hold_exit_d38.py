#!/usr/bin/env python3
"""Exercise the exact continuation stop handler using only tiny child processes."""
import argparse
import hashlib
import inspect
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]
OUT = ROOT / 'project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/exit_fixture'
sys.path.insert(0, str(HERE))
from continue_physical_d38 import Continuation


def dump(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def proc(pid):
    try:
        raw = Path(f'/proc/{pid}/stat').read_text()
        fields = raw[raw.rfind(')') + 2:].split()
        return {'pid': pid, 'state': fields[0], 'ppid': int(fields[1]),
                'start_time_ticks': int(fields[19])}
    except FileNotFoundError:
        return None


def fixture(directory, exit_code):
    continuation = Continuation.__new__(Continuation)
    continuation.requested_stop = False
    continuation.child = subprocess.Popen([sys.executable, '-c', f'raise SystemExit({exit_code})'])
    signal.signal(signal.SIGTERM, continuation.stop)
    signal.signal(signal.SIGINT, continuation.stop)
    dump(directory / 'ready.json', {'serial': proc(os.getpid()), 'child_pid': continuation.child.pid})
    while not (directory / 'release.json').exists():
        time.sleep(.01)
    # This is the existing driver's Popen poll/wait and next-stage stop boundary.
    while continuation.child.poll() is None:
        time.sleep(.01)
    child_result = continuation.child.wait()
    continuation.child = None
    facade_started = False
    try:
        for _stage in ['facade_synth']:
            if continuation.requested_stop:
                raise InterruptedError('Continuation cancelled before next stage')
            facade_started = True
    except InterruptedError:
        pass
    dump(directory / 'result.json', {
        'requested_stop': continuation.requested_stop,
        'child_exit_code': child_result,
        'facade_started': facade_started,
        'child_after_reap': proc(json.loads((directory / 'ready.json').read_text())['child_pid'])})


def test():
    OUT.mkdir(parents=True, exist_ok=False)
    cases = []
    for exit_code in [0, 7]:
        directory = OUT / f'child_exit_{exit_code}'
        directory.mkdir()
        process = subprocess.Popen([sys.executable, str(Path(__file__).resolve()),
                                    '--fixture', str(directory), '--exit-code', str(exit_code)])
        try:
            deadline = time.monotonic() + 10
            while not (directory / 'ready.json').exists():
                assert time.monotonic() < deadline
                time.sleep(.01)
            ready = json.loads((directory / 'ready.json').read_text())
            while True:
                child = proc(ready['child_pid'])
                if child and child['state'] == 'Z':
                    break
                assert time.monotonic() < deadline
                time.sleep(.01)
            fd = os.pidfd_open(process.pid)
            try:
                assert proc(process.pid)['start_time_ticks'] == ready['serial']['start_time_ticks']
                signal.pidfd_send_signal(fd, signal.SIGSTOP, None, 0)
                while proc(process.pid)['state'] != 'T':
                    assert time.monotonic() < deadline
                    time.sleep(.01)
                dump(directory / 'release.json', {'test_only': True})
                signal.pidfd_send_signal(fd, signal.SIGTERM, None, 0)
                status = Path(f'/proc/{process.pid}/status').read_text()
                pending = {line.split(':')[0]: int(line.split(':')[1].strip(), 16)
                           for line in status.splitlines() if line.startswith(('SigPnd:', 'ShdPnd:'))}
                assert (pending['SigPnd'] | pending['ShdPnd']) & (1 << (signal.SIGTERM - 1))
                signal.pidfd_send_signal(fd, signal.SIGCONT, None, 0)
            finally:
                os.close(fd)
            assert process.wait(timeout=10) == 0
            result = json.loads((directory / 'result.json').read_text())
            assert result == {'requested_stop': True, 'child_exit_code': exit_code,
                              'facade_started': False, 'child_after_reap': None}
            assert proc(process.pid) is None
            cases.append({'child_exit_code': exit_code, 'pending_before_CONT': pending, **result})
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()
    result = {'verdict': 'PASS', 'cases': cases,
              'exact_handler_source': inspect.getsource(Continuation.stop),
              'continuation_sha256': hashlib.sha256((HERE / 'continue_physical_d38.py').read_bytes()).hexdigest(),
              'production_processes_signalled': False}
    dump(OUT / 'test_result.json', result)
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--fixture', type=Path)
    parser.add_argument('--exit-code', type=int)
    args = parser.parse_args()
    if args.fixture:
        fixture(args.fixture, args.exit_code)
    else:
        test()
