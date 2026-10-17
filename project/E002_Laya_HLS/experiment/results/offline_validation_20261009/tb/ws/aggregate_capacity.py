#!/usr/bin/env python3
"""Require every independent bit-identity phase of the actual eight-bank run."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import sys

DEPTH = 20992
BANKS = 8
WIDTH = 16
PHASES = 22
PHASE_LINE = re.compile(r'(?m)^WS_CAPACITY_PHASE_PASS phase=(\d+) words_per_bank=(\d+)$')
RUN_LINE = re.compile(
    r'(?m)^WS_CAPACITY_RUN_PASS banks=8 depth=20992 width=16 '
    r'first_phase=(\d+) phase_count=(\d+) reads=(\d+) high_reads=(\d+)$')


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit('usage: aggregate_capacity.py ATTEMPTS_DIR FRESH_REPORT')
    root, output = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
    if output.exists():
        raise SystemExit('fresh report required')
    if (BANKS * DEPTH * WIDTH + 1) > (1 << PHASES):
        raise SystemExit('22-bit cell identifiers cannot distinguish all cells')
    phase_records = []
    for phase in range(PHASES):
        attempt = root / f'ws_capacity_phase_{phase:02d}'
        log = attempt / 'work/xsim.log'
        guard = attempt / 'guard/guard_result.json'
        manifest = attempt / 'input_manifest.json'
        if not log.is_file() or not guard.is_file() or not manifest.is_file():
            raise SystemExit(f'missing actual run evidence phase={phase}')
        result = json.loads(guard.read_text())
        if result['child_exit_code'] != 0 or result['trigger'] is not None or not result['rss_captured']:
            raise SystemExit(f'guard did not pass phase={phase}: {result}')
        text = log.read_text(errors='replace')
        if 'WS_CAPACITY_PILOT_ONLY' in text or re.search(r'(?mi)^.*(?:ERROR:|FATAL:|\$fatal)', text):
            raise SystemExit(f'error or partial marker phase={phase}')
        if 'WS_CAPACITY_INIT_PASS banks=8 addresses=0,16383,16384,20991' not in text:
            raise SystemExit(f'initialization checks missing phase={phase}')
        phase_lines = PHASE_LINE.findall(text)
        run_lines = RUN_LINE.findall(text)
        if phase_lines != [(str(phase), str(DEPTH))] or run_lines != [
            (str(phase), '1', str(BANKS * DEPTH),
             str(BANKS * (DEPTH - 16384)))]:
            raise SystemExit(f'incomplete full phase={phase}: {phase_lines} {run_lines}')
        phase_records.append({
            'phase': phase, 'attempt': str(attempt), 'log_sha256': sha(log),
            'manifest_sha256': sha(manifest), 'guard': result,
            'read_words': BANKS * DEPTH,
            'high_address_read_words': BANKS * (DEPTH - 16384)})
    report = {
        'schema': 'ws_actual_eight_bank_exhaustive_bit_identity_v1',
        'status': 'PASS' if len(phase_records) == PHASES else 'FAIL',
        'bank_count': BANKS, 'depth_words_per_bank': DEPTH, 'word_width_bits': WIDTH,
        'phase_count': PHASES,
        'logical_cell_count': BANKS * DEPTH * WIDTH,
        'tag_rule': 'tag=((bank*20992+address)*16+bit)+1, bits phase 0..21',
        'tag_injective_range': [1, BANKS * DEPTH * WIDTH],
        'read_word_count': BANKS * DEPTH * PHASES,
        'high_address_read_word_count': BANKS * (DEPTH - 16384) * PHASES,
        'evidence': phase_records,
        'scope': 'settled functional simulation of hash-bound same-parent DCP funcsim banks; '
                 'no timing, placement, board, or full-model conclusion'}
    output.write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print('WS_CAPACITY_AGGREGATE_PASS phases=22 banks=8 depth=20992 width=16')


if __name__ == '__main__':
    main()
