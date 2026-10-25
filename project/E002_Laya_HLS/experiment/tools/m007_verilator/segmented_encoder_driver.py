#!/usr/bin/env python3
"""Preserve RTL stdout; enforce ordered, contiguous retirement segments and one total cap."""
import argparse, json, os, re, resource, selectors, subprocess, sys, time
from pathlib import Path

class StageStop(Exception):
    def __init__(self, verdict, reason):
        self.verdict, self.reason = verdict, reason
        super().__init__(reason)

class Segments:
    def __init__(self, contract):
        self.c = contract
        self.index = 0
        self.anchor = 0.0
        self.records = []
        self.complete_line = False
        self.terminal_line = False
        self.last_cycle = None

    def check(self, elapsed):
        if elapsed > self.c['overall_seconds']:
            raise StageStop('COST_STOP', 'overall_wall_cap')
        if elapsed - self.anchor > self.c['segment_seconds']:
            raise StageStop('COST_STOP', 'contiguous_segment_wall_cap:' + self.c['stages'][self.index]['id'])

    def feed(self, line, elapsed):
        self.check(elapsed)
        cycle = re.search(r'\bcycle=(\d+)', line)
        if cycle:
            self.last_cycle = int(cycle[1])
        if line == self.c['exact_terminal']:
            if not self.complete_line:
                raise StageStop('FAIL', 'terminal_before_complete_retirement')
            self.terminal_line = True
            return None
        if not re.match(self.c['recognized_retirement_pattern'], line):
            return None
        stage = self.c['stages'][self.index]
        if self.complete_line or not re.match(stage['end_pattern'], line):
            raise StageStop('FAIL', 'missing_duplicate_or_out_of_order_retirement:' + stage['id'])
        record = {'stage': stage['id'], 'start_elapsed_s': self.anchor, 'end_elapsed_s': elapsed,
                  'duration_seconds': elapsed - self.anchor, 'original_retirement_line': line,
                  'cycle': int(cycle[1]) if cycle else None}
        if self.index == len(self.c['stages']) - 1:
            # Keep the final segment anchor until normal child exit: export/held DONE/cleanup count.
            self.complete_line = True
            record['awaiting_normal_exit_without_deadline_reset'] = True
        else:
            self.records.append(record)
            self.index += 1
            self.anchor = elapsed
        return record

    def normal_exit(self, elapsed):
        self.check(elapsed)
        if not self.complete_line or not self.terminal_line:
            raise StageStop('FAIL', 'normal_exit_without_all_original_complete_markers')
        self.records.append({'stage': self.c['stages'][-1]['id'], 'start_elapsed_s': self.anchor,
                             'end_elapsed_s': elapsed, 'duration_seconds': elapsed-self.anchor,
                             'original_retirement_line': self.c['exact_terminal'],
                             'includes_normal_child_exit': True, 'cycle': self.last_cycle})

def write_json(path, value):
    path.with_suffix(path.suffix+'.tmp').write_text(json.dumps(value, indent=2)+'\n')
    path.with_suffix(path.suffix+'.tmp').replace(path)

def replay(contract, streams, output):
    results = []
    for path in streams:
        events = [json.loads(x) for x in path.read_text().splitlines()]
        state = Segments(contract)
        for event in events:
            state.feed(event['line'], event['elapsed_s'])
        expected = 2 if 'AT029_' in str(path) else 5
        if len(state.records) != expected:
            raise RuntimeError('actual recorded stream retirement count mismatch')
        results.append({'stream': str(path), 'completed_ordered_segments': len(state.records),
                        'expected_next': contract['stages'][state.index]['id']})
    first = 'M007_FULLMODEL_ENCODER0_MATRIX_END phase=0 cycle=62942'
    head0 = 'M007_FULLMODEL_HEAD_END head=0 cycle=76057 head_cycles=11038'
    head1 = 'M007_FULLMODEL_HEAD_END head=1 cycle=87101 head_cycles=11038'
    scenarios = [('missing_first_retirement', [(head0, 70)], 'FAIL'),
                 ('wrong_head_order', [(first, 60), (head1, 72)], 'FAIL'),
                 ('duplicate_retirement', [(first, 60), (first, 61)], 'FAIL'),
                 ('late_real_boundary', [(first, 120.01)], 'COST_STOP'),
                 ('partial_logs_do_not_reset_deadline', [('M007_PARENT_CHECKED checked=10 phase=SCORE cycle=5', 119),
                                                          ('M007_PARENT_CHECKED checked=20 phase=SCORE cycle=6', 120.01)], 'COST_STOP')]
    checks = []
    for name, events, expected in scenarios:
        state = Segments(contract)
        try:
            for line, stamp in events:
                state.feed(line, stamp)
        except StageStop as stop:
            if stop.verdict != expected:
                raise
            checks.append({'case': name, 'actual': stop.verdict, 'reason': stop.reason})
        else:
            raise RuntimeError('required rejection absent: '+name)
    # Retiring every preceding stage does not allow final-marker receipt to omit process cleanup.
    state = Segments(contract)
    state.index = len(contract['stages'])-1
    state.anchor = 700.0
    state.feed('M007_FULLMODEL_ENCODER0_COMPLETE_PASS kind=5', 790.0)
    state.feed(contract['exact_terminal'], 790.01)
    try:
        state.normal_exit(800.01)
    except StageStop as stop:
        if stop.reason != 'overall_wall_cap':
            raise
        checks.append({'case': 'final_cleanup_counts_in_total_cap', 'actual': stop.verdict})
    else:
        raise RuntimeError('cleanup omitted from total cap')
    write_json(output, {'verdict': 'PASS', 'actual_stream_replays': results, 'required_rejections': checks,
                        'all_segments_contiguous': True, 'interior_BEGIN_and_progress_do_not_reset': True})
    print('SEGMENT_DRIVER_REPLAY_PASS', flush=True)

def run(contract, args):
    state = Segments(contract)
    start = time.monotonic()
    child = subprocess.Popen(args.command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=0)
    selector = selectors.DefaultSelector()
    selector.register(child.stdout, selectors.EVENT_READ)
    pending = b''
    verdict, reason = None, None
    first_threads = None
    event_count = 0
    eof = False
    records = []
    with args.events.open('x') as events, args.segments.open('x') as segments:
        def handle_line(raw, elapsed):
            nonlocal event_count, first_threads
            line = raw.decode('utf-8', errors='replace').rstrip('\r\n')
            if first_threads is None:
                try:
                    first_threads = len(list(Path('/proc',str(child.pid),'task').iterdir()))
                except OSError:
                    first_threads = 'UNKNOWN'
            if line.startswith(('M007_', 'JOINT', 'MATRIX_PROGRESS', 'HARDWARE_AGENT_SIM_PASS', '%Error')):
                events.write(json.dumps({'line': line, 'elapsed_s': elapsed})+'\n')
                events.flush()
                event_count += 1
            record = state.feed(line, elapsed)
            if record:
                records.append(record)
                segments.write(json.dumps(record)+'\n')
                segments.flush()
        try:
            while not eof:
                elapsed = time.monotonic()-start
                state.check(elapsed)
                delay = min(0.25, contract['overall_seconds']-elapsed,
                            contract['segment_seconds']-(elapsed-state.anchor))
                for key, mask in selector.select(max(0, delay)):
                    chunk = os.read(key.fd, 65536)
                    if not chunk:
                        selector.unregister(key.fileobj)
                        eof = True
                        break
                    sys.stdout.buffer.write(chunk)
                    sys.stdout.buffer.flush()
                    pending += chunk
                    while b'\n' in pending:
                        line, pending = pending.split(b'\n', 1)
                        handle_line(line+b'\n', time.monotonic()-start)
            if pending:
                handle_line(pending, time.monotonic()-start)
            while child.poll() is None:
                state.check(time.monotonic()-start)
                time.sleep(0.02)
            rc = child.wait()
            if rc != 0:
                verdict, reason = 'FAIL', 'original_child_nonzero_exit'
            else:
                state.normal_exit(time.monotonic()-start)
                verdict, reason = 'PASS', 'all_original_retirements_terminal_and_normal_exit'
        except StageStop as stop:
            verdict, reason = stop.verdict, stop.reason
            if child.poll() is None:
                child.terminate()
                try:
                    child.wait(timeout=0.5)
                except subprocess.TimeoutExpired:
                    child.kill()
                    child.wait(timeout=1)
        finally:
            selector.close()
    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    elapsed = time.monotonic()-start
    result = {'verdict': verdict, 'reason': reason, 'elapsed_seconds': elapsed,
              'raw_child_return_code': child.returncode, 'child_cpu_user_seconds': usage.ru_utime,
              'child_cpu_system_seconds': usage.ru_stime, 'child_cpu_total_seconds': usage.ru_utime+usage.ru_stime,
              'observed_child_threads_at_first_stdout': first_threads, 'child_pid': child.pid,
              'semantic_event_count': event_count, 'completed_segments': state.records,
              'next_expected_stage': contract['stages'][state.index]['id'],
              'current_segment_anchor_s': state.anchor, 'last_cycle': state.last_cycle,
              'exact_complete_marker_seen': state.complete_line, 'exact_terminal_seen': state.terminal_line,
              'all_original_stdout_forwarded_unchanged': True}
    write_json(args.receipt, result)
    raise SystemExit(0 if verdict == 'PASS' else 124 if verdict == 'COST_STOP' else 1)

def main():
    p = argparse.ArgumentParser()
    p.add_argument('mode', choices=['replay','run'])
    p.add_argument('--contract', type=Path, required=True)
    p.add_argument('--streams', type=Path, nargs='*')
    p.add_argument('--events', type=Path)
    p.add_argument('--segments', type=Path)
    p.add_argument('--receipt', type=Path, required=True)
    p.add_argument('--command', nargs=argparse.REMAINDER, default=[])
    a = p.parse_args()
    if a.command and a.command[0] == '--':
        a.command = a.command[1:]
    contract = json.loads(a.contract.read_text())
    if contract['overall_seconds'] != 800 or contract['segment_seconds'] != 120:
        raise SystemExit('only the explicit current D33 contract is supported')
    if a.mode == 'replay':
        replay(contract, a.streams, a.receipt)
    else:
        if not a.command:
            raise SystemExit('original child executable and original plusargs required')
        run(contract, a)

if __name__ == '__main__':
    main()
