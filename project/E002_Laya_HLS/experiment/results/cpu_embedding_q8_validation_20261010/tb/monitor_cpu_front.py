#!/usr/bin/env python3
"""Run one guarded cold RTL case and record phase-specific cost evidence."""

import datetime as dt
import json
import os
from pathlib import Path
import re
import signal
import statistics
import subprocess
import sys
import time


BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
STAGE = BASE / 'results/cpu_embedding_q8_validation_20261010'
GUARD = BASE / 'results/offline_validation_20261009/tools/guard_16g.py'
RUN = STAGE / 'tb/run_cpu_front.sh'
PROGRESS = re.compile(r'([a-z][a-z_0-9]*)=(\d+)')
RAW_WORDS = 131072
WALL_CAP = 4300
CYCLE_CAP = 40000000


def utc_now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def save_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def latest_progress(path):
    if not path.exists():
        return None
    with path.open('rb') as stream:
        stream.seek(0, os.SEEK_END)
        end = stream.tell()
        stream.seek(max(0, end - 32768))
        lines = stream.read().decode(errors='replace').splitlines()
    for line in reversed(lines):
        if line.startswith('CPU_FRONT_PROGRESS '):
            return {key: int(value) for key, value in PROGRESS.findall(line)}
    return None


def semantic_key(v):
    return tuple(v.get(name, 0) for name in (
        'raw', 'norm', 'observed', 'import_words', 'ln_words', 'gamma_words',
        'accepted', 'ln_rows', 'ln_local', 'ln_mean_steps',
        'ln_mean_levels', 'ln_variance_steps', 'ln_variance_levels',
        'ln_row', 'ln_mean_i', 'ln_variance_i'))


def phase(v):
    if v['observed']:
        return 'observed'
    if v['norm']:
        return 'LN_write_or_later'
    if v['ln_rows'] or v['ln_local'] or v['ln_mean_steps'] or v['ln_variance_steps']:
        return 'LN_arithmetic'
    if v['ln_words']:
        return 'LN_read'
    if v['gamma_words']:
        return 'gamma'
    return 'import'


def prediction(elapsed, v, import_end, row_events):
    words = v['import_words']
    if import_end is None:
        import_wall = elapsed * RAW_WORDS / words if words else 600.0
        import_cycles = v['cycles'] * RAW_WORDS / words if words else 10500000.0
    else:
        import_wall, import_cycles = import_end

    row_pairs = []
    window_pairs = []
    for before, after in zip(row_events, row_events[1:]):
        delta_rows = after[0] - before[0]
        delta_wall = after[1] - before[1]
        delta_cycles = after[2] - before[2]
        if delta_rows != 1:
            continue
        if delta_wall < 60 and delta_cycles < 200000:
            row_pairs.append((delta_wall, delta_cycles))
        elif before[0] % 16 == 0 and delta_wall < 180:
            window_pairs.append((delta_wall, delta_cycles))

    row_wall = statistics.median(x[0] for x in row_pairs[-16:]) if len(row_pairs) >= 6 else 17.0
    row_cycles = statistics.median(x[1] for x in row_pairs[-16:]) if len(row_pairs) >= 6 else 45000.0
    # A row16->row17 pair includes the block write/read window and one row.
    window_wall = statistics.median(x[0] - row_wall for x in window_pairs) if len(window_pairs) >= 2 else 125.0
    window_cycles = statistics.median(x[1] - row_cycles for x in window_pairs) if len(window_pairs) >= 2 else 2200000.0
    window_wall = max(0.0, window_wall)
    window_cycles = max(0.0, window_cycles)
    total_wall = import_wall + 128 * row_wall + 8 * window_wall + 60
    total_cycles = import_cycles + 128 * row_cycles + 8 * window_cycles + 500000
    return {
        'import_seconds': import_wall, 'import_cycles': import_cycles,
        'row_seconds': row_wall, 'row_cycles': row_cycles,
        'row_samples': len(row_pairs), 'window_seconds': window_wall,
        'window_cycles': window_cycles, 'window_samples': len(window_pairs),
        'predicted_total_seconds': total_wall,
        'predicted_total_cycles': total_cycles,
        'remaining_seconds': max(0.0, total_wall - elapsed),
        'remaining_cycles': max(0.0, total_cycles - v['cycles']),
    }


def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: monitor_cpu_front.py FRESH_ATTEMPT_DIRECTORY')
    attempt = Path(sys.argv[1]).resolve()
    work = attempt / 'work'
    output = attempt / 'guard'
    if not work.is_dir() or output.exists():
        raise RuntimeError('attempt must contain a fresh work directory')
    if not (attempt / 'input_manifest.json').is_file():
        raise RuntimeError('missing sealed input manifest')
    command = [sys.executable, str(GUARD), '--out', str(output),
               '--cwd', str(work), '--rss-gib', '8',
               '--timeout-seconds', str(WALL_CAP), '--', '/bin/bash',
               str(RUN), str(work)]
    started = time.monotonic()
    guard = subprocess.Popen(command)
    samples = attempt / 'phase_progress.jsonl'
    stop_path = attempt / 'monitor_stop.json'
    last_key = None
    last_change = started
    last_sample = started - 60
    last_over = None
    import_end = None
    row_events = []
    last_rows = 0
    stop_reason = None
    try:
        while guard.poll() is None:
            now = time.monotonic()
            elapsed = now - started
            v = latest_progress(output / 'driver.log')
            if v is not None:
                key = semantic_key(v)
                if key != last_key:
                    last_key = key
                    last_change = now
                if import_end is None and v['import_words'] >= RAW_WORDS:
                    import_end = (elapsed, v['cycles'])
                if v['ln_rows'] > last_rows:
                    row_events.append((v['ln_rows'], elapsed, v['cycles']))
                    last_rows = v['ln_rows']
                if now - last_sample >= 60:
                    forecast = prediction(elapsed, v, import_end, row_events)
                    entry = {'utc': utc_now(), 'elapsed_seconds': elapsed,
                             'phase': phase(v), 'progress': v,
                             'prediction': forecast}
                    with samples.open('a') as stream:
                        stream.write(json.dumps(entry, sort_keys=True) + '\n')
                    print(json.dumps(entry, sort_keys=True), flush=True)
                    last_sample = now
                    over = (forecast['predicted_total_seconds'] > WALL_CAP or
                            forecast['predicted_total_cycles'] > CYCLE_CAP)
                    if over and last_over is not None and now - last_over >= 60:
                        stop_reason = 'two_over_cap_predictions'
                    elif over:
                        last_over = now
                    else:
                        last_over = None
                if now - last_change >= 120:
                    stop_reason = 'no_semantic_progress_120s'
            elif elapsed >= 120:
                stop_reason = 'no_progress_log_120s'
            if stop_reason:
                save_json(stop_path, {'at': utc_now(), 'reason': stop_reason,
                                      'elapsed_seconds': elapsed,
                                      'last_progress': v})
                guard.send_signal(signal.SIGTERM)
                break
            time.sleep(5)
        rc = guard.wait(timeout=90)
    finally:
        if guard.poll() is None:
            guard.send_signal(signal.SIGTERM)
            guard.wait(timeout=90)
    save_json(attempt / 'monitor_result.json', {
        'at': utc_now(), 'guard_runner_exit_code': rc,
        'monitor_stop_reason': stop_reason,
        'sample_count': sum(1 for _ in samples.open()) if samples.exists() else 0,
    })
    return 0 if rc == 0 and stop_reason is None else 1


if __name__ == '__main__':
    raise SystemExit(main())
