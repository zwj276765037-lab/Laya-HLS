#!/usr/bin/env python3
"""Freeze and verify native AXI ownership; no production-chain claim."""
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
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    source = attempt / 'frozen'
    records = []
    for rel in [MODULE / 'rtl/laya_axi_owner_v1.sv',
                MODULE / 'tb/laya_axi_owner_tb_v1.sv', MODULE / 'tb/run_axi_owner.tcl']:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
               '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
               '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
               '-notrace', '-log', str(attempt / 'vivado.log'), '-journal',
               str(attempt / 'vivado.jou'), '-source',
               str(source / MODULE / 'tb/run_axi_owner.tcl'), '-tclargs',
               str(attempt / 'work'), str(source)]
    scope = ('One native BO owner arbiter with independent manual AXI peers; '
             'held R/B, W-before-AW, offered AW, simultaneous read/write, '
             'fault clear and malformed LAST recovery. No current 13BO/generated '
             'controller or numerical production-chain claim.')
    inputs = {'files': records, 'runner': rec(Path(__file__)), 'guard': rec(guard),
              'tool': rec(tool), 'command': command, 'scope': scope}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = (attempt / 'guard/driver.log').read_text()
    passed = (result.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and 'FULL_CURRENT_AXI_OWNER_PASS' in driver)
    (attempt / 'receipt.json').write_text(json.dumps({
        'status': 'PASS' if passed else 'FAIL', 'scope': scope, 'guard_result': state,
        'input_manifest': rec(attempt / 'input_manifest.json'),
        'driver_log': rec(attempt / 'guard/driver.log')}, indent=2) + '\n')
    print('FULL_CURRENT_AXI_OWNER_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
