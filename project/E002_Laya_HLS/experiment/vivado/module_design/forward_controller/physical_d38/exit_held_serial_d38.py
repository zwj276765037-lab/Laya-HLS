#!/usr/bin/env python3
"""Graceful exact-PID exit only after the held serial's report guard has finished."""
import argparse
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]
RUN = ROOT / 'project/E022_m007_full_top_physical/experiment_results/runs/R001'
OUT = RUN / 'serial_continuation/resource_stage_hold'
SERIAL = (3603650, 66216629)
GUARD = (109263, 71064760)
CONTINUATION_SHA = 'dd2e55be3148db77c7c5547d174ecccaf6dbdc9731188c3bf80caefa944fa4c3'


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def dump(name, value):
    path = OUT / name
    temporary = path.with_suffix(path.suffix + '.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def proc(pid):
    try:
        raw = Path(f'/proc/{pid}/stat').read_text()
        fields = raw[raw.rfind(')') + 2:].split()
        return {'pid': pid, 'state': fields[0], 'ppid': int(fields[1]),
                'start_time_ticks': int(fields[19]), 'raw_exit_status': int(fields[49])}
    except FileNotFoundError:
        return None


def preflight():
    assert not (OUT / 'serial_exit_receipt.json').exists(), 'Exit action already recorded'
    assert hashlib.sha256((HERE / 'continue_physical_d38.py').read_bytes()).hexdigest() == CONTINUATION_SHA
    launched = json.loads((RUN / 'serial_continuation/launch_inputs.json').read_text())
    continuation = next(row for row in launched['sources']
                        if Path(row['source']).name == 'continue_physical_d38.py')
    assert continuation['sha256'] == CONTINUATION_SHA
    assert hashlib.sha256(Path(continuation['frozen']).read_bytes()).hexdigest() == CONTINUATION_SHA
    fixture = json.loads((OUT / 'exit_fixture/test_result.json').read_text())
    assert fixture['verdict'] == 'PASS' and fixture['continuation_sha256'] == CONTINUATION_SHA
    hold = json.loads((OUT / 'hold_receipt.json').read_text())
    assert hold['serial_held'] and hold['signal_sent']
    serial = proc(SERIAL[0])
    assert serial and serial['start_time_ticks'] == SERIAL[1] and serial['state'] == 'T'
    state = json.loads((RUN / 'serial_continuation/state.json').read_text())
    assert state['current_stage'] == 'report_core' and state['current_guard']['pid'] == GUARD[0]
    assert state['current_guard']['start_time_ticks'] == GUARD[1]
    receipt_path = RUN / 'attempts/AT020_report_core/receipt.json'
    assert receipt_path.exists(), 'AT020 receipt not yet complete; no signal permitted'
    raw = receipt_path.read_bytes()
    receipt = json.loads(raw)
    assert receipt['verdict'] == 'PASS' and receipt['source_verify_after'] is True
    assert receipt['child_exit_code'] == 0 and not receipt['owned_after_cleanup']
    assert receipt['maximum_seconds'] is None and receipt['wall_time_limit_disabled'] is True
    guard = proc(GUARD[0])
    assert guard is None or (guard['start_time_ticks'] == GUARD[1] and guard['state'] == 'Z' and guard['raw_exit_status'] == 0)
    for pid, start in receipt['known_owned_identities'].items():
        actual = proc(int(pid))
        assert actual is None or actual['start_time_ticks'] != start, ('AT020 tool identity survives', actual)
    with (ROOT / '.research-agent/m007_heavy.lock').open('a+') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        fcntl.flock(lock, fcntl.LOCK_UN)
    return {'ready': True, 'utc': now(), 'serial': serial, 'guard': guard,
            'AT020_receipt_sha256': hashlib.sha256(raw).hexdigest(),
            'AT020_receipt_PASS': True, 'AT020_tools_all_gone': True,
            'heavy_lock_released': True, 'continuation_sha256': CONTINUATION_SHA}


def execute():
    value = preflight()
    value.update({'schema': 'm007-d38-held-serial-graceful-exit-v1',
                  'source_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  'SIGTERM_queued': False, 'SIGCONT_sent': False,
                  'only_serial_signalled': True})
    attempts_before = {path.name for path in (RUN / 'attempts').iterdir()}
    dump('serial_exit_preflight.json', value)
    fd = os.pidfd_open(SERIAL[0])
    try:
        actual = proc(SERIAL[0])
        assert actual['start_time_ticks'] == SERIAL[1] and actual['state'] == 'T'
        signal.pidfd_send_signal(fd, signal.SIGTERM, None, 0)
        value['SIGTERM_queued'] = True
        value['SIGTERM_utc'] = now()
        status = Path(f'/proc/{SERIAL[0]}/status').read_text()
        pending = {line.split(':')[0]: int(line.split(':')[1].strip(), 16)
                   for line in status.splitlines() if line.startswith(('SigPnd:', 'ShdPnd:'))}
        assert (pending['SigPnd'] | pending['ShdPnd']) & (1 << (signal.SIGTERM - 1))
        value['pending_before_CONT'] = pending
        dump('serial_exit_signal_queued.json', value)
        signal.pidfd_send_signal(fd, signal.SIGCONT, None, 0)
        value['SIGCONT_sent'] = True
        value['SIGCONT_utc'] = now()
    finally:
        os.close(fd)
    deadline = time.monotonic() + 45
    observations = []
    last = None
    while True:
        actual = proc(SERIAL[0])
        guard = proc(GUARD[0])
        current = (actual['state'] if actual else None, guard['state'] if guard else None)
        if current != last:
            observations.append({'utc': now(), 'serial': actual, 'guard': guard})
            last = current
        if actual is None and guard is None:
            break
        if time.monotonic() >= deadline:
            break
        time.sleep(.05)
    state = json.loads((RUN / 'serial_continuation/state.json').read_text())
    attempts_after = {path.name for path in (RUN / 'attempts').iterdir()}
    value.update({'observations': observations,
                  'serial_after': proc(SERIAL[0]), 'guard_after': proc(GUARD[0]),
                  'serial_state_after': state,
                  'new_attempts': sorted(attempts_after - attempts_before),
                  'no_facade_attempt_started': attempts_after == attempts_before,
                  'serial_exit_verified': proc(SERIAL[0]) is None and proc(GUARD[0]) is None,
                  'finished_utc': now()})
    dump('serial_exit_receipt.json', value)
    assert value['serial_exit_verified'], 'Serial exited or exiting; parent reaping needs inspection; do not signal parent'
    assert state['execution_state'] == 'paused' and state['phase'] == 'stopped_no_retry'
    assert [row['stage'] for row in state['completed_stages']] == ['core_synth', 'report_core']
    assert value['no_facade_attempt_started']
    print(json.dumps(value, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    if args.execute:
        execute()
    else:
        try:
            print(json.dumps(preflight(), indent=2))
        except AssertionError as error:
            print(json.dumps({'ready': False, 'reason': str(error), 'no_signal_sent': True}))
