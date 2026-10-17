#!/usr/bin/env python3
"""Freeze and validate the actual LOAD/converter/13BO adapter with native peers."""
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
    names = [MODULE / 'rtl' / (name + '.sv') for name in
             ['laya_compute_portal_layout_v1', 'laya_load_portal_binding_v1',
              'laya_axi_owner_v1', 'laya_axi_13bo_owner_v1', 'laya_load_axi_native_v1']]
    names += [MODULE / 'rtl/create_laya_axi_dwidth.tcl']
    names += [MODULE / 'tb' / name for name in
              ['laya_load_native_tb_v1.sv', 'run_load_native.tcl',
               'make_load_portal_binding.py', 'make_load_portal_tb.py',
               'make_load_axi_native.py', 'make_load_native_tb.py',
               'make_13bo_axi_owner.py', 'laya_axi_13bo_ports_v1.json',
               'laya_load_axi_native_ports_v1.json', 'laya_load_portal_tb_v1.sv']]
    names += [Path('vivado/module_design/hbm_loader_and_cache/rtl') / (name + '.sv') for name in
              ['t4_w_reader_port_v1', 't4_three_port_reader_v1', 't4_aux_bias_reader_v1',
               't4_w_cache_bank_v1', 't4_dual_w_cache_v1']]
    records = []
    for rel in names:
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
               str(source / MODULE / 'tb/run_load_native.tcl'), '-tclargs',
               str(attempt / 'work'), str(source)]
    scope = ('One full-capacity physical dualW/cache LOAD binding, four actual AMD converters '
             '(3x512->32 and 1x128->32), full native 13BO owner wrapper, explicit SI/MI debt and '
             'native 32-bit manual memory peers. Diagnostic q/scale and nonzero bias; '
             'not a current generated caller, real GGUF or whole-model numerical chain.')
    inputs = {'files': records, 'runner': rec(Path(__file__)), 'guard': rec(guard),
              'tool': rec(tool), 'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'),
              'historical_ABI_reference': rec(ROOT / 'vivado/project/build/20261008T022231Z-2961016/stage/rtl_verilog/laya_typed_q8_forward.v'),
              'command': command, 'scope': scope}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = (attempt / 'guard/driver.log').read_text()
    passed = (result.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and 'FULL_CURRENT_LOAD_NATIVE_PASS' in driver)
    generated = [rec(path) for path in (attempt / 'work').rglob('*') if path.is_file() and
                 (path.suffix == '.xci' or ('/ip/' in str(path) and path.suffix in ('.v', '.vhd')))]
    (attempt / 'receipt.json').write_text(json.dumps({
        'status': 'PASS' if passed else 'FAIL', 'scope': scope, 'guard_result': state,
        'input_manifest': rec(attempt / 'input_manifest.json'), 'generated': generated,
        'driver_log': rec(attempt / 'guard/driver.log')}, indent=2) + '\n')
    print('FULL_CURRENT_LOAD_NATIVE_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)

if __name__ == '__main__':
    main()
