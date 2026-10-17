#!/usr/bin/env python3
"""Run one full bit-identity phase in a fresh, resource-guarded XSim process."""
from __future__ import annotations

import json
from pathlib import Path
import re
import subprocess
import sys
import hashlib

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
STAGE = BASE / 'results/offline_validation_20261009'
XBIN = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim')


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit('usage: run_capacity_phase.py PHASE BUILD_DIR PREPARED_DIR')
    phase = int(sys.argv[1])
    build = Path(sys.argv[2]).resolve()
    prepared = Path(sys.argv[3]).resolve()
    if not 0 <= phase < 22 or not (build / 'xsim.dir').is_dir():
        raise SystemExit('invalid phase or compiled snapshot')
    if not (build / 'compile_identity.json').is_file() or not (prepared / 'preparation.json').is_file():
        raise SystemExit('missing bound compile/preparation identity')
    compile_identity = json.loads((build / 'compile_identity.json').read_text())
    if compile_identity['schema'] != 'ws_capacity_compiled_snapshot_identity_v1':
        raise SystemExit('compiled snapshot identity schema mismatch')
    for entry in compile_identity['files']:
        path = Path(entry['path'])
        if not path.is_file() or path.stat().st_size != entry['bytes']:
            raise SystemExit(f'compiled/prepared file changed: {path}')
        h = hashlib.sha256()
        with path.open('rb') as stream:
            for block in iter(lambda: stream.read(1 << 20), b''):
                h.update(block)
        if h.hexdigest() != entry['sha256']:
            raise SystemExit(f'compiled/prepared file changed: {path}')
    attempt = STAGE / 'attempts' / f'ws_capacity_phase_{phase:02d}'
    if attempt.exists():
        raise SystemExit(f'phase attempt already exists: {attempt}')
    subprocess.run([
        'python3', str(STAGE / 'tools/record_attempt.py'), str(attempt),
        str(STAGE / 'tb/ws'), str(prepared), str(build / 'compile_identity.json')],
        check=True)
    work = attempt / 'work'
    work.mkdir()
    (work / 'xsim.dir').symlink_to(build / 'xsim.dir', target_is_directory=True)
    command = [
        'python3', str(STAGE / 'tools/guard_16g.py'),
        '--out', str(attempt / 'guard'), '--cwd', str(work),
        '--rss-gib', '4', '--timeout-seconds', '120', '--', str(XBIN),
        'ws_capacity_static', '-runall', '-onerror', 'quit', '-onfinish', 'quit',
        '-testplusarg', f'WS_FIRST_PHASE={phase}',
        '-testplusarg', 'WS_PHASE_COUNT=1', '-log', 'xsim.log']
    completed = subprocess.run(command)
    guard = json.loads((attempt / 'guard/guard_result.json').read_text())
    if completed.returncode or guard['child_exit_code'] or guard['trigger'] is not None:
        raise SystemExit(f'phase {phase} simulator/guard failed; see {attempt}')
    log = (work / 'xsim.log').read_text(errors='replace')
    expected = (f'WS_CAPACITY_RUN_PASS banks=8 depth=20992 width=16 '
                f'first_phase={phase} phase_count=1 reads=167936 high_reads=36864')
    if (expected not in log or
            f'WS_CAPACITY_PHASE_PASS phase={phase} words_per_bank=20992' not in log or
            re.search(r'(?mi)^.*(?:ERROR:|FATAL:|\$fatal)', log)):
        raise SystemExit(f'phase {phase} output checks failed; see {attempt}')
    print(f'WS_CAPACITY_PHASE_VERIFIED phase={phase} words=167936')


if __name__ == '__main__':
    main()
