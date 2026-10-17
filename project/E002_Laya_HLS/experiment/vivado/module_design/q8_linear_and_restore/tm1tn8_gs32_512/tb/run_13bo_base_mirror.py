#!/usr/bin/env python3
"""Freeze and run one bounded original-control/base-mirror RTL test; never overwrite an attempt."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--control', type=Path, required=True)
    args = parser.parse_args()
    attempt, control = args.attempt.resolve(), args.control.resolve()
    attempt.mkdir(exist_ok=False)
    source = attempt / 'frozen'
    files = [MODULE / 'rtl' / (n + '.sv') for n in
             ['laya_13bo_abi_v1', 'laya_13bo_base_mirror_v1']]
    files += [MODULE / 'tb/laya_13bo_base_mirror_tb_v1.sv', MODULE / 'tb/run_13bo_base_mirror.tcl']
    records = []
    for rel in files:
        target = source / rel; target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    frozen_control = source / 'reference' / control.name
    frozen_control.parent.mkdir(parents=True)
    shutil.copyfile(control, frozen_control)
    records.append({'original': rec(control), 'frozen': rec(frozen_control)})
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'), '--cwd', str(ROOT),
        '--rss-gib', '8', '--timeout-seconds', '120', '--semantic-stall-seconds', '120', '--', str(tool),
        '-mode', 'batch', '-notrace', '-log', str(attempt / 'vivado.log'), '-journal', str(attempt / 'vivado.jou'),
        '-source', str(source / MODULE / 'tb/run_13bo_base_mirror.tcl'), '-tclargs',
        str(attempt / 'work'), str(source), str(frozen_control)]
    inputs = {'files': records, 'original_control': rec(control),
              'runner': rec(Path(__file__)), 'guard': rec(guard), 'tool': rec(tool), 'command': command,
              'scope': 'Passive base mirror compared to actual historical generated control RTL; current generated production connection remains unverified'}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = (attempt / 'guard/driver.log').read_text()
    passed = result.returncode == 0 and state['child_exit_code'] == 0 and state['trigger'] is None and \
             'FULL_CURRENT_13BO_BASE_PASS' in driver
    (attempt / 'receipt.json').write_text(json.dumps({'status': 'PASS' if passed else 'FAIL',
        'scope': inputs['scope'], 'guard_result': state, 'input_manifest': rec(attempt / 'input_manifest.json'),
        'driver_log': rec(attempt / 'guard/driver.log')}, indent=2) + '\n')
    print('FULL_CURRENT_13BO_BASE_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)


if __name__ == '__main__': main()
