#!/usr/bin/env python3
"""Freeze and run bounded real-cache rows16 parent portal integration."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
OLD = ROOT / 'results/compute_throughput_optimization_20261010/attempts'
R003 = ROOT.parent.parent / 'E003_production_chain_closure/experiment_results/runs/R003'


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def snapshot(attempt, inputs, results):
    manifest = attempt / 'input_manifest.json'
    manifest.write_text(json.dumps(inputs, indent=2) + '\n')
    results['input_manifest'] = rec(manifest)
    (attempt / 'receipt.json').write_text(json.dumps(results, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    frozen = attempt / 'frozen'
    matrix_rtl = '''laya_compute_portal_layout_v1 tm4tn8_bias_bits_v1
tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed
tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1
tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2
tm4tn8_final_ps_adapter_v1 tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1
tm4tn8_matrix_owner_ledger_v2 tm4tn8_matrix_resident_v2
laya_parent_a_lease_v2 laya_parent_w_lease_v2 laya_matrix_portal_binding_v1'''.split()
    files = [MODULE / 'rtl' / (name + '.sv') for name in matrix_rtl]
    for mod, names in [
            ('activation_quantizer', 'quant_a_row_bank_v1 quant_dual_a_v1'),
            ('hbm_loader_and_cache', 't4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1')]:
        files += [Path('vivado/module_design') / mod / 'rtl' / (name + '.sv')
                  for name in names.split()]
    files += [MODULE / 'tb' / name for name in
              ['create_fp_ip.tcl', 'laya_matrix_parent_cache_tb_v2.sv',
               'run_matrix_parent_cache_v2.tcl']]
    records = []
    for rel in files:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})

    fixture_dirs = [OLD / 't2_tm4_matrix_resident_pilot_02/work/afixture',
                    OLD / 't4_dual_w_fixture_01/work',
                    OLD / 't2_tm4_real_stream_down_01/work/streams']
    fixture_names = [['q.mem', 'scale.mem', 'output.mem'],
                     ['model_identity.hex', 'expected_aux_header.hex', 'aux_header.hex',
                      'down_config.hex', 'down_q0.hex', 'down_q1.hex', 'down_scale.hex'],
                     ['w8.mem', 'ps.mem']]
    fixture_records = []
    for directory, names in zip(fixture_dirs, fixture_names):
        for name in names:
            fixture_records.append(rec(directory / name))

    prior_receipts = [R003 / 'resident_regression_01/receipt.json',
                      R003 / 'resident_regression_02/receipt.json']
    prior_seconds = [float(json.loads(path.read_text())['full']['guard']['elapsed_seconds'])
                     for path in prior_receipts]
    conservative = math.ceil(max(prior_seconds) * 4 * 1.5)
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    scope = ('One rows16 parent through v2 matrix commands with four distinct portal generations; '
             'actual prequantized fullA, strict physical fullW, native FP, independent PS/final gold, '
             'actual AW/W/B and one parent completion. No actual G/quant producer, multi-parent tensor, '
             'unique production hub/generated caller, L2/L3, CPU/CSim, or M003/M004 completion claim.')
    inputs = {'files': records, 'fixture_files': fixture_records,
              'runner': rec(Path(__file__)), 'guard': rec(guard),
              'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'), 'tool': rec(tool),
              'scope': scope,
              'full_cost_basis': {
                  'prior_same_matrix_cache_receipts': [rec(path) for path in prior_receipts],
                  'prior_single_view_seconds': prior_seconds,
                  'planned_views': 4, 'conservative_multiplier': 1.5,
                  'conservative_estimate_seconds': conservative,
                  'full_cap_seconds': 3600, 'full_cycle_cap': 40000000,
                  'applicability': ('Same K2624/N1024 native-FP, physical A/W caches, fixture and output '
                                    'work per view; parent wrapper retains leases across four serial views.'),
                  'prerequisite': 'current static and bounded first-view pilot PASS'}}
    results = {'scope': scope}
    for mode, rss, seconds in [('static', 24, 1800), ('pilot', 8, 120), ('full', 8, 3600)]:
        if mode == 'full' and conservative > 3600:
            results['full'] = {'status': 'COST_STOP', 'started': False,
                               'reason': 'conservative prior measured estimate exceeds RTL cap',
                               'estimate_seconds': conservative, 'cap_seconds': 3600}
            inputs['full_cost_basis']['decision'] = 'COST_STOP'
            snapshot(attempt, inputs, results)
            print('L0_PARENT_CACHE_FULL_COST_STOP', flush=True)
            return 2
        command = [sys.executable, str(guard), '--out', str(attempt / ('guard_' + mode)),
                   '--cwd', str(ROOT), '--rss-gib', str(rss), '--timeout-seconds', str(seconds),
                   '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch', '-notrace',
                   '-log', str(attempt / (mode + '.log')), '-journal', str(attempt / (mode + '.jou')),
                   '-source', str(frozen / MODULE / 'tb/run_matrix_parent_cache_v2.tcl'),
                   '-tclargs', str(attempt / 'work'), str(frozen), mode, *map(str, fixture_dirs)]
        inputs[mode + '_command'] = command
        snapshot(attempt, inputs, results)
        run = subprocess.run(command, cwd=ROOT)
        state = json.loads((attempt / ('guard_' + mode) / 'guard_result.json').read_text())
        log = attempt / ('guard_' + mode) / 'driver.log'
        marker = {'static': 'L0_PARENT_CACHE_STATIC_PASS',
                  'pilot': 'L0_PARENT_CACHE_PILOT_PASS',
                  'full': 'L0_PARENT_CACHE_FULL_PASS'}[mode]
        markers = [line for line in log.read_text().splitlines() if marker in line]
        passed = (run.returncode == 0 and state['child_exit_code'] == 0 and
                  state['trigger'] is None and bool(markers))
        results[mode] = {'status': 'PASS' if passed else 'FAIL', 'guard': state,
                         'marker': markers, 'driver_log': rec(log)}
        if mode == 'pilot' and passed:
            inputs['full_cost_basis']['current_pilot_seconds'] = state['elapsed_seconds']
            inputs['full_cost_basis']['decision'] = 'RUN_FULL'
        results['native_ip'] = [rec(path) for path in (attempt / 'work').rglob('*.xci')]
        snapshot(attempt, inputs, results)
        print('L0_PARENT_CACHE_' + mode.upper() + '_' + ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
