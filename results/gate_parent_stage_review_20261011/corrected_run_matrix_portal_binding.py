#!/usr/bin/env python3
"""Freeze actual resident binding inputs, then run bounded static and RTL stages."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import re

ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
RTL = '''laya_compute_portal_layout_v1 tm4tn8_bias_bits_v1 tm1tn8_integer_tree_lut
tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1
tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1
tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2 tm4tn8_final_ps_adapter_v1
tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1 tm4tn8_matrix_owner_ledger_v2
tm4tn8_matrix_resident_v2 laya_parent_a_lease_v2 laya_parent_w_lease_v2
laya_matrix_portal_binding_v1'''.split()


def rec(path):
    path = path.resolve()
    return dict(path=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--attempt', type=Path, required=True)
    args = p.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    frozen = attempt / 'frozen'
    files = [MODULE / 'rtl' / (n + '.sv') for n in RTL]
    files += [MODULE / 'tb' / n for n in ['create_fp_ip.tcl',
              'run_matrix_portal_binding.tcl', 'laya_matrix_portal_binding_tb_v1.sv',
              'make_matrix_portal_binding.py']]
    records = []
    for rel in files:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append(dict(original=rec(ROOT / rel), frozen=rec(target)))
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    inputs = dict(files=records, runner=rec(Path(__file__)), guard=rec(guard),
                  guard_helpers=rec(ROOT / 'tools/hls_guard_helpers.py'), tool=rec(tool),
                  scope='Real binding/resident/native FP control and cancellation; controlled A/W lease endpoints; diagnostic zero operands. No physical-cache/13BO/full-model claim.')
    results = {}
    for mode, rss, timeout in [('static', 24, 1800), ('pilot', 8, 120), ('full', 8, 3600)]:
        command = [sys.executable, str(guard), '--out', str(attempt / ('guard_' + mode)),
                   '--cwd', str(ROOT), '--rss-gib', str(rss), '--timeout-seconds', str(timeout),
                   '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch', '-notrace',
                   '-log', str(attempt / (mode + '.log')), '-journal', str(attempt / (mode + '.jou')),
                   '-source', str(frozen / MODULE / 'tb/run_matrix_portal_binding.tcl'),
                   '-tclargs', str(attempt / 'work'), str(frozen), mode]
        inputs[mode + '_command'] = command
        (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
        run = subprocess.run(command, cwd=ROOT)
        result = json.loads((attempt / ('guard_' + mode) / 'guard_result.json').read_text())
        log = attempt / ('guard_' + mode) / 'driver.log'
        marker = {'static': 'FULL_CURRENT_MATRIX_BINDING_STATIC_PASS',
                  'pilot': 'FULL_CURRENT_MATRIX_BINDING_PILOT_PASS',
                  'full': 'FULL_CURRENT_MATRIX_BINDING_PASS'}[mode]
        passed = run.returncode == 0 and result['child_exit_code'] == 0 and result['trigger'] is None and marker in log.read_text()
        results[mode] = dict(status='PASS' if passed else 'FAIL', guard=result, log=rec(log))
        results['native_ip'] = [rec(x) for x in (attempt / 'work').rglob('*.xci')]
        results['input_manifest'] = rec(attempt / 'input_manifest.json')
        results['scope'] = inputs['scope']
        (attempt / 'receipt.json').write_text(json.dumps(results, indent=2) + '\n')
        print('FULL_CURRENT_MATRIX_BINDING_' + mode.upper() + '_' + ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            sys.exit(1)
        if mode == 'pilot':
            match = re.search(r'FULL_CURRENT_MATRIX_BINDING_PILOT_PASS.*cycles=(\d+)', log.read_text())
            if match is None:
                raise RuntimeError('pilot passed without cycle count')
            pilot_cycles = int(match.group(1))
            pilot_seconds = float(result['elapsed_seconds'])
            cycle_cap = 200000
            conservative_estimate = int(pilot_seconds * cycle_cap / pilot_cycles * 1.5 + 0.999999)
            inputs['full_cost_basis'] = dict(
                pilot_cycles=pilot_cycles,
                pilot_seconds=pilot_seconds,
                seconds_per_cycle=pilot_seconds / pilot_cycles,
                full_cycle_cap=cycle_cap,
                conservative_multiplier=1.5,
                conservative_estimate_seconds=conservative_estimate,
                full_cap_seconds=3600,
                prerequisite='static and bounded pilot PASS')
            (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
            if conservative_estimate > 3600:
                raise RuntimeError('full RTL estimate exceeds the 3600 second cap')


if __name__ == '__main__':
    main()
