#!/usr/bin/env python3
"""Freeze and verify one real dual-A parent lease attempt within the pilot cap."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
QUANT = Path('vivado/module_design/activation_quantizer')


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--fixture', type=Path, required=True)
    args = parser.parse_args()
    attempt, fixture = args.attempt.resolve(), args.fixture.resolve()
    attempt.mkdir(exist_ok=False)
    source = attempt / 'frozen'
    files = [MODULE / 'rtl/laya_compute_portal_layout_v1.sv',
             MODULE / 'rtl/laya_parent_a_lease_v2.sv',
             MODULE / 'tb/laya_parent_a_lease_tb_v2.sv',
             MODULE / 'tb/make_parent_a_tb.py',
             MODULE / 'tb/run_parent_a_lease.tcl',
             QUANT / 'rtl/quant_a_row_bank_v1.sv',
             QUANT / 'rtl/quant_dual_a_v1.sv']
    records = []
    for rel in files:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    frozen_fixture = attempt / 'fixture'
    frozen_fixture.mkdir()
    shutil.copyfile(fixture / 'command.hex', frozen_fixture / 'command.hex')
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
               '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
               '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
               '-notrace', '-log', str(attempt / 'vivado.log'), '-journal',
               str(attempt / 'vivado.jou'), '-source',
               str(source / MODULE / 'tb/run_parent_a_lease.tcl'), '-tclargs',
               str(attempt / 'work'), str(source), str(frozen_fixture)]
    scope = ('Real complete dual-A store, prequantized diagnostic fixture; '
             'parent pin/view/cancel only, no numerical, caller or full-chain claim')
    inputs = {'files': records, 'fixture_original': rec(fixture / 'command.hex'),
              'fixture_frozen': rec(frozen_fixture / 'command.hex'),
              'runner': rec(Path(__file__)), 'guard': rec(guard),
              'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'),
              'tool': rec(tool), 'command': command, 'scope': scope,
              'expected': {'physical_acquire': 3, 'physical_release': 3,
                           'fills': 3, 'views': 9, 'rejects': 7,
                           'independent_q_byte_checks': 94464}}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = (attempt / 'guard/driver.log').read_text()
    passed = (result.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and 'FULL_CURRENT_PARENT_A_PASS' in driver)
    (attempt / 'receipt.json').write_text(json.dumps({
        'status': 'PASS' if passed else 'FAIL', 'scope': scope, 'guard_result': state,
        'input_manifest': rec(attempt / 'input_manifest.json'),
        'driver_log': rec(attempt / 'guard/driver.log')}, indent=2) + '\n')
    print('FULL_CURRENT_PARENT_A_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
