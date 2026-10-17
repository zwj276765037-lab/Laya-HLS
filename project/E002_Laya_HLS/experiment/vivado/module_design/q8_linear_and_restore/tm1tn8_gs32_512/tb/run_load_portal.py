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
    for rel in [MODULE / 'rtl/laya_compute_portal_layout_v1.sv', MODULE / 'rtl/laya_load_portal_binding_v1.sv',
                MODULE / 'tb/laya_load_portal_tb_v1.sv', MODULE / 'tb/run_load_portal.tcl',
                MODULE / 'tb/make_load_portal_binding.py', MODULE / 'tb/make_load_portal_tb.py'] + [
                Path('vivado/module_design/hbm_loader_and_cache/rtl') / (name+'.sv') for name in
                ['t4_w_reader_port_v1','t4_three_port_reader_v1','t4_aux_bias_reader_v1','t4_w_cache_bank_v1','t4_dual_w_cache_v1']]:
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
               str(source / MODULE / 'tb/run_load_portal.tcl'), '-tclargs',
               str(attempt / 'work'), str(source)]
    scope = ('One actual full-capacity dualW/cache LOAD binding; native manual AXI peers '
             'with diagnostic q/scale and nonzero bias, cancel/physical debt and error/recovery. '
             'No current generated controller, 13BO or real-GGUF numerical-chain claim.')
    inputs = {'files': records, 'runner': rec(Path(__file__)), 'guard': rec(guard),
              'tool': rec(tool), 'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'), 'command': command, 'scope': scope}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = (attempt / 'guard/driver.log').read_text()
    passed = (result.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and 'FULL_CURRENT_LOAD_PORTAL_PASS' in driver)
    (attempt / 'receipt.json').write_text(json.dumps({
        'status': 'PASS' if passed else 'FAIL', 'scope': scope, 'guard_result': state,
        'input_manifest': rec(attempt / 'input_manifest.json'),
        'driver_log': rec(attempt / 'guard/driver.log')}, indent=2) + '\n')
    print('FULL_CURRENT_LOAD_PORTAL_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
