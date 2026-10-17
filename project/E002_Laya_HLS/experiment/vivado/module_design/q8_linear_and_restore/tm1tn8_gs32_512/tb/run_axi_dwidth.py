#!/usr/bin/env python3
"""Freeze and test the actual AMD native-to-original-BO width converter."""
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
    parser.add_argument('--si-width', type=int, choices=(128, 512), required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    source = attempt / 'frozen'
    records = []
    for rel in [MODULE / 'rtl/create_laya_axi_dwidth.tcl',
                MODULE / 'tb/laya_axi_dwidth_tb_v1.sv', MODULE / 'tb/run_axi_dwidth.tcl']:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    component = tool.parents[2] / 'data/ip/xilinx/axi_dwidth_converter_v2_1/component.xml'
    guard = ROOT / MODULE / 'tb/production_guard.py'
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
               '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
               '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
               '-notrace', '-log', str(attempt / 'vivado.log'), '-journal',
               str(attempt / 'vivado.jou'), '-source',
               str(source / MODULE / 'tb/run_axi_dwidth.tcl'), '-tclargs',
               str(attempt / 'work'), str(source), str(args.si_width)]
    scope = (f'Actual AMD AXI dwidth2.1 {args.si_width}->32 simulation, 64-bit '
             'addresses, independently checked read bytes/errors and sparse write '
             'bytes, split bursts ending at 4KiB, held last R/B and upstream '
             'backpressure. No OOC or production13BO connection claim.')
    inputs = {'files': records, 'runner': rec(Path(__file__)), 'guard': rec(guard),
              'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'),
              'tool': rec(tool), 'component': rec(component), 'command': command,
              'si_width': args.si_width, 'mi_width': 32, 'address_bits': 64,
              'scope': scope}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = (attempt / 'guard/driver.log').read_text()
    passed = (result.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and 'FULL_CURRENT_AXI_DWIDTH_PASS' in driver)
    generated = [rec(path) for path in sorted((attempt / 'work').rglob('*'))
                 if path.is_file() and path.suffix in ('.xci', '.v', '.sv', '.vhd', '.prj')]
    (attempt / 'receipt.json').write_text(json.dumps({
        'status': 'PASS' if passed else 'FAIL', 'scope': scope, 'guard_result': state,
        'input_manifest': rec(attempt / 'input_manifest.json'), 'generated': generated,
        'driver_log': rec(attempt / 'guard/driver.log')}, indent=2) + '\n')
    print('FULL_CURRENT_AXI_DWIDTH_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
