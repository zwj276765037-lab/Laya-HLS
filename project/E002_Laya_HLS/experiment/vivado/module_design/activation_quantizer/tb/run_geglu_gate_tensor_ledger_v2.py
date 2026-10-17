#!/usr/bin/env python3
"""Freeze and verify the bounded GATE tensor/provenance ledger."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
MODULE = Path('vivado/module_design/activation_quantizer')
GUARD = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py')


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--attempt', type=Path, required=True)
    args = p.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    source = attempt / 'frozen'
    files = [MODULE / 'rtl/geglu_gate_tensor_ledger_v2.sv',
             MODULE / 'tb/geglu_gate_tensor_ledger_tb_v2.sv',
             MODULE / 'tb/run_geglu_gate_tensor_ledger_v2.tcl']
    records = []
    for rel in files:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / GUARD
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
               '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
               '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
               '-notrace', '-log', str(attempt / 'vivado.log'), '-journal', str(attempt / 'vivado.jou'),
               '-source', str(source / MODULE / 'tb/run_geglu_gate_tensor_ledger_v2.tcl'),
               '-tclargs', str(attempt / 'work'), str(source)]
    scope = ('GATE owner/provenance metadata with explicit write/read debt; '
             'no GEGLU arithmetic, physical payload, portal hub or full-chain claim')
    inputs = {'files': records, 'runner': rec(Path(__file__)), 'guard': rec(guard),
              'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'),
              'tool': rec(tool), 'command': command, 'scope': scope,
              'expected': {'maximum_windows': 128, 'maximum_rows': 2048,
                           'same_epoch': True, 'held_write_and_read_debt': True}}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    run = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    log = attempt / 'guard/driver.log'
    passed = (run.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and 'FULL_CURRENT_GATE_TENSOR_PASS' in log.read_text())
    (attempt / 'receipt.json').write_text(json.dumps({
        'status': 'PASS' if passed else 'FAIL', 'scope': scope, 'guard_result': state,
        'input_manifest': rec(attempt / 'input_manifest.json'), 'driver_log': rec(log)}, indent=2) + '\n')
    print('FULL_CURRENT_GATE_TENSOR_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
