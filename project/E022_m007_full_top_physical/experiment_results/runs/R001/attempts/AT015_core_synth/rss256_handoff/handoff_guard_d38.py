#!/usr/bin/env python3
"""Fail-safe external supervision while the original parent/lock owner sleeps.

Only the original Python guard is stopped. No debugger or Vivado injection is
used. The immutable original receipt is augmented by a separate effective one.
"""
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

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]
sys.path.insert(0, str(ROOT/'project/E002_Laya_HLS/experiment/tools'))
import hls_guard_helpers as owned

def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()

def dump(p, value):
    p = Path(p)
    p.parent.mkdir(parents=True, exist_ok=True)
    tmp = p.with_name(p.name+'.'+str(os.getpid())+'.tmp')
    tmp.write_text(json.dumps(value, indent=2)+'\n')
    os.replace(tmp, p)

def read(p):
    return json.loads(Path(p).read_text())

def state(pid, tick):
    if owned.process_start(pid) != tick:
        return None
    try:
        s = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()[0]
        return None if s == 'Z' else s
    except FileNotFoundError:
        return None

def send(pid, tick, sig):
    if state(pid, tick) is not None:
        os.kill(pid, sig)
        return True
    return False

def lock_held(path):
    with Path(path).open('a+') as f:
        try:
            fcntl.flock(f, fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError:
            return True
        fcntl.flock(f, fcntl.LOCK_UN)
    return False

def cpu(pid):
    try:
        x = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()
        return int(x[11])+int(x[12])
    except (FileNotFoundError, ProcessLookupError):
        return 0

def watchdog(config):
    c = read(config)
    out = Path(c['output'])
    dump(out/'watchdog_ready.json', {'utc': now(), 'pid': os.getpid(),
         'start': owned.process_start(os.getpid())})
    while True:
        if (out/'watchdog_done.json').exists():
            return
        h = {}
        try:
            h = read(out/'heartbeat.json')
            fresh = time.time()-h['epoch'] < c.get('watchdog_timeout', 15)
        except (FileNotFoundError, json.JSONDecodeError):
            fresh = False
        if not state(c['monitor_pid'], c['monitor_start']) or not fresh:
            resumed = send(c['guard_pid'], c['guard_start'], signal.SIGCONT)
            dump(out/'watchdog_fallback.json', {'utc': now(),
                 'resumed_original_guard': resumed, 'effective_cap_after_fallback_GiB': c.get('old_cap_gib', 128),
                 'reason': 'monitor_missing_or_heartbeat_expired'})
            if resumed:
                resumed_epoch = time.time()
                until = time.monotonic()+60
                while time.monotonic() < until:
                    receipt = Path(c['attempt'])/'receipt.json'
                    sample = Path(c['attempt'])/'live_status.json'
                    confirmed = receipt.exists() or (sample.exists() and sample.stat().st_mtime >= resumed_epoch)
                    if confirmed:
                        dump(out/'watchdog_fallback_confirmed.json', {'utc': now(),
                             'original_guard_resumed': True, 'evidence': str(receipt if receipt.exists() else sample),
                             'effective_cap_GiB': c.get('old_cap_gib', 128)})
                        return
                    if state(c['guard_pid'], c['guard_start']) is None: break
                    time.sleep(.25)
                resumed = False
            if not resumed:
                known = {int(k):v for k,v in h.get('known', {}).items()}
                items = owned.owned_processes(owned.process_table(), c['leader'], known)
                owned.OUT = out
                owned.stop_and_kill(c['leader'], known, items,
                                    {'reason': 'no_monitor_or_original_guard', 'utc': now()})
            return
        time.sleep(.25)

def supervise(config):
    c = read(config)
    out = Path(c['output']); out.mkdir(parents=True, exist_ok=True)
    at = Path(c['attempt'])
    assert not (out/'activation.json').exists(), 'No repeated handoff'
    gp, gs = c['guard_pid'], c['guard_start']
    leader, lt = c['leader'], c['leader_start']
    assert state(gp, gs) and state(leader, lt), 'PID/start identity mismatch'
    assert lock_held(c['lock']), 'Original lock not held'
    assert os.stat(c['lock']).st_ino == c['lock_inode']
    known = {leader: lt}
    peak = 0; minimum = owned.mem_available_kb(); policy = {}; cpus = {}
    last_files = {}; last_progress = time.monotonic(); reason = None
    deadline_epoch = dt.datetime.fromisoformat(c['started_utc']).timestamp()+c['maximum_seconds']
    stop_requested = False
    def stop(signum, frame):
        nonlocal stop_requested
        stop_requested = True
    signal.signal(signal.SIGTERM, stop); signal.signal(signal.SIGINT, stop)
    c.update({'monitor_pid': os.getpid(), 'monitor_start': owned.process_start(os.getpid())})
    dump(config, c)
    def heartbeat():
        dump(out/'heartbeat.json', {'utc': now(), 'epoch': time.time(), 'known': known})
    heartbeat()
    wd = subprocess.Popen([sys.executable, str(Path(__file__).resolve()), '--watchdog', str(config)],
                          start_new_session=True, stdout=subprocess.DEVNULL, stderr=(out/'watchdog_stderr.log').open('w'))
    paused = False
    items = {}
    try:
        for _ in range(80):
            if (out/'watchdog_ready.json').exists(): break
            assert wd.poll() is None
            time.sleep(.05)
        else: raise RuntimeError('Watchdog did not become ready')
        # Stop only at the original monitor's sleep boundary, with ample old-cap
        # margin. SIGSTOP is single PID; the Vivado session is never signalled.
        for _ in range(1000):
            heartbeat()
            assert state(gp, gs) not in (None, 'T', 't')
            if Path(f'/proc/{gp}/wchan').read_text().strip() == 'hrtimer_nanosleep':
                os.kill(gp, signal.SIGSTOP); paused = True
                break
            time.sleep(.01)
        else: raise RuntimeError('No safe sleep boundary found')
        for _ in range(100):
            if state(gp, gs) in ('T', 't'): break
            time.sleep(.01)
        assert state(gp, gs) in ('T', 't')
        items = owned.owned_processes(owned.process_table(), leader, known)
        assert sum(x['rss_kb'] for x in items.values()) < c['old_cap_kb'], 'Old-cap margin lost before pause'
        assert state(leader, lt) not in (None, 'T', 't'), 'Workload must continue'
        # Preserve the original monitor's observed progress age. First CPU/file
        # observations are baselines, not newly demonstrated progress.
        baseline = read(at/'live_status.json')
        baseline_age = max(0, time.time()-dt.datetime.fromisoformat(baseline['utc']).timestamp())
        last_progress = time.monotonic()-baseline.get('last_progress_age_seconds', 0)-baseline_age
        cpus = {f'{pid}:{x["start_time_ticks"]}': cpu(pid) for pid,x in items.items()}
        for path in [at/'driver.log', at/'vivado.log', *Path(c['checkpoint_directory']).glob('*.dcp')]:
            if path.exists():
                s = path.stat(); last_files[path] = (s.st_size, s.st_mtime_ns)
        activation = {'utc': now(), 'config': c, 'deadline_utc': dt.datetime.fromtimestamp(deadline_epoch, dt.timezone.utc).isoformat(),
                      'original_guard_state': state(gp, gs), 'original_lock_retained': lock_held(c['lock']),
                      'original_receipt_immutable': True, 'effective_RSS_limit_kb': c['rss_limit_kb'],
                      'vivado_or_workload_state': state(leader, lt), 'mechanism': 'single-PID SIGSTOP of original guard; external supervisor plus fail-safe watchdog'}
        dump(out/'activation.json', activation)
        print(json.dumps({'event': 'HANDOFF_ACTIVE', **activation}), flush=True)
        next_policy = 0
        with (out/'samples.jsonl').open('a') as samples:
            while True:
                heartbeat()
                if state(gp, gs) not in ('T', 't'):
                    reason = 'original_guard_resumed_or_disappeared'; break
                if wd.poll() is not None:
                    raise RuntimeError('Watchdog exited unexpectedly')
                assert lock_held(c['lock']), 'Original lock lost'
                current = time.monotonic()
                items = owned.owned_processes(owned.process_table(), leader, known)
                active = {p:x for p,x in items.items() if not x['state'].startswith('Z')}
                rss = sum(x['rss_kb'] for x in items.values()); peak = max(peak, rss)
                available = owned.mem_available_kb(); minimum = min(minimum, available)
                advanced = False
                for pid, item in active.items():
                    key = f'{pid}:{item["start_time_ticks"]}'; v = cpu(pid)
                    if v > cpus.get(key, 0): advanced = True
                    cpus[key] = max(v, cpus.get(key, 0))
                for path in [at/'driver.log', at/'vivado.log', *Path(c['checkpoint_directory']).glob('*.dcp')]:
                    if path.exists():
                        s = path.stat(); v = (s.st_size, s.st_mtime_ns)
                        if path in last_files and v != last_files[path]: advanced = True
                        last_files[path] = v
                if advanced: last_progress = current
                if current >= next_policy:
                    next_policy = current+10
                    for pid, item in active.items():
                        if not owned.still_owned(item): continue
                        try:
                            affinity = sorted(os.sched_getaffinity(pid))
                            io = subprocess.run(['/usr/bin/ionice', '-p', str(pid)], capture_output=True, text=True, timeout=3)
                            bad = [int(p.name) for p in Path(f'/proc/{pid}/task').iterdir()
                                   if not set(os.sched_getaffinity(int(p.name))).issubset({0,1,2,3})]
                            ok = item['nice'] == 19 and bool(affinity) and set(affinity).issubset({0,1,2,3}) and io.returncode == 0 and 'idle' in io.stdout.lower() and not bad
                            policy[f'{pid}:{item["start_time_ticks"]}'] = {**item, 'affinity': affinity, 'ionice': io.stdout.strip(), 'bad_thread_affinity': bad, 'matches': ok}
                            if not ok: reason = 'owned_resource_policy_mismatch'
                        except (FileNotFoundError, ProcessLookupError, subprocess.TimeoutExpired): pass
                if not active: break
                if stop_requested: reason = 'external_guard_requested_stop'
                elif rss >= c['rss_limit_kb']: reason = 'owned_RSS_at_or_above_effective_cap'
                elif available <= c['minimum_available_kb']: reason = 'MemAvailable_at_or_below_192GiB'
                elif time.time() >= deadline_epoch: reason = 'original_stage_or_category_deadline'
                elif current-last_progress >= c.get('stall_seconds', 300): reason = 'no_owned_CPU_log_checkpoint_progress_300s'
                sample = {'utc': now(), 'elapsed_seconds': time.time()-dt.datetime.fromisoformat(c['started_utc']).timestamp(),
                          'owned_rss_kb': rss, 'peak_owned_rss_kb': peak, 'available_kb': available,
                          'owned_CPU_ticks_observed': sum(cpus.values()), 'last_progress_age_seconds': current-last_progress,
                          'owned_processes': len(active), 'trigger': reason, 'effective_maximum_owned_RSS_GiB': c['rss_limit_kb']/1024**2,
                          'original_guard_state': state(gp, gs), 'watchdog_pid': wd.pid}
                samples.write(json.dumps(sample)+'\n'); samples.flush(); dump(out/'live_status.json', sample)
                if reason: break
                time.sleep(c.get('sample_seconds', 1))
        if reason and reason != 'original_guard_resumed_or_disappeared':
            owned.OUT = out
            owned.stop_and_kill(leader, known, items, {'reason': reason, 'utc': now()})
    except BaseException as exc:
        reason = 'external_guard_exception'
        dump(out/'exception.json', {'utc': now(), 'exception': repr(exc)})
        # Resume the original guard as the conservative 128 GiB fail-safe.
    finally:
        resumed = send(gp, gs, signal.SIGCONT) if paused else False
        dump(out/'handoff_end.json', {'utc': now(), 'reason': reason, 'resumed_original_guard': resumed,
                                    'peak_owned_rss_kb': peak, 'minimum_MemAvailable_kb': minimum,
                                    'known_owned_identities': known, 'policy_samples': list(policy.values())})
        dump(out/'watchdog_done.json', {'utc': now()})
        wd.wait(timeout=5)
    # Original parent performs wait, subreaping, source verification, cleanup,
    # ledger update and its own immutable receipt. Do not touch its live ledger.
    if reason in ('external_guard_exception', 'original_guard_resumed_or_disappeared'):
        return 2
    until = time.monotonic()+180
    while not (at/'receipt.json').exists() and time.monotonic() < until:
        time.sleep(.25)
    assert (at/'receipt.json').exists(), 'Original receipt missing after resume'
    until = time.monotonic()+15
    while state(gp, gs) and time.monotonic() < until:
        time.sleep(.1)
    raw = (at/'receipt.json').read_bytes(); original = json.loads(raw)
    merged_known = {**original['known_owned_identities'], **{str(k):v for k,v in known.items()}}
    remaining = owned.owned_processes(owned.process_table(), leader, {int(k):v for k,v in merged_known.items()})
    assert not remaining, f'Owned processes still present: {remaining}'
    effective = {**original, 'receipt_kind': 'effective_supervision_augmentation',
                 'original_receipt_sha256': hashlib.sha256(raw).hexdigest(),
                 'original_receipt_path': str(at/'receipt.json'), 'handoff_evidence': str(out),
                 'original_launch_RSS_limit_GiB': c.get('old_cap_gib', 128),
                 'handoff_RSS_limit_GiB': c['rss_limit_kb']/1024**2,
                 'peak_owned_rss_kb': max(peak, original['peak_owned_rss_kb']),
                 'minimum_MemAvailable_kb': min(minimum, original['minimum_MemAvailable_kb']),
                 'known_owned_identities': merged_known,
                 'policy_samples_before_handoff': original['policy_samples'],
                 'policy_samples_after_handoff': list(policy.values()),
                 'policy_samples': list({**{f'{x["pid"]}:{x["start_time_ticks"]}':x for x in original['policy_samples']}, **policy}.values()),
                 'external_guard_trigger': reason, 'owned_after_cleanup': [],
                 'original_lock_released': not lock_held(c['lock'])}
    if reason: effective.update({'verdict': 'COST_STOP', 'guard_trigger': reason})
    dump(out/'effective_receipt.json', effective)
    print(json.dumps({'event': 'HANDOFF_COMPLETE', 'verdict': effective['verdict'], 'effective_receipt': str(out/'effective_receipt.json')}), flush=True)
    return 0 if effective['verdict'] == 'PASS' else 1

if __name__ == '__main__':
    p = argparse.ArgumentParser(); g = p.add_mutually_exclusive_group(required=True)
    g.add_argument('--supervise'); g.add_argument('--watchdog'); a = p.parse_args()
    if a.watchdog: watchdog(Path(a.watchdog))
    else: sys.exit(supervise(Path(a.supervise)))
