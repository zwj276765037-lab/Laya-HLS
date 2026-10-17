#!/usr/bin/env python3
"""Freeze and run bounded same-runtime G/QUANT/fullA/parent-matrix integration."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[5]
MATRIX = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
Q = Path('vivado/module_design/activation_quantizer')
V = Path('vivado/module_design/vector_and_ffn')
C = Path('vivado/module_design/hbm_loader_and_cache')
R0 = Path('vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv')
OLD = ROOT / 'results/compute_throughput_optimization_20261010/attempts'
R003 = ROOT.parent.parent / 'E003_production_chain_closure/experiment_results/runs/R003'
CANONICAL = OLD / 't2_geglu_gate_quant_bridge_rtl_04/canonical_rtl'
QUANT_IP = OLD / 'quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog'


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
    quant_rtl = '''quant16_slot_banks quant16_amax16 quant16_half_rne
quant16_tiny_div127 quant16_divider_service quant16_stream_row
quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1
quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1
geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2
geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2'''.split()
    files = [MATRIX / 'rtl' / (name + '.sv') for name in matrix_rtl]
    files += [Q / 'rtl' / (name + '.sv') for name in quant_rtl]
    files += [V / 'rtl' / (name + '.sv') for name in
              ['tanh_libm_canonical', 'geglu_canonical_core', 'geglu_row_bank_v1',
               'geglu_canonical_row_adapter']]
    files += [C / 'rtl' / (name + '.sv') for name in
              't4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1'.split()]
    files += [R0, MATRIX / 'tb/create_fp_ip.tcl',
              MATRIX / 'tb/laya_gate_quant_matrix_parent_tb_v2.sv',
              MATRIX / 'tb/run_gate_quant_matrix_parent_v2.tcl',
              MATRIX / 'tb/run_gate_quant_matrix_parent_nowave_v2.tcl']
    records = []
    for rel in files:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    for src in sorted((ROOT / CANONICAL).glob('*.v')):
        target = frozen / 'external/canonical_rtl' / src.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, target)
        records.append({'original': rec(src), 'frozen': rec(target)})
    for name in ['laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl',
                 'laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl']:
        src = ROOT / QUANT_IP / name
        target = frozen / 'external/quant_ip' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, target)
        records.append({'original': rec(src), 'frozen': rec(target)})

    fixture_dirs = [OLD / 't2_geglu_gate_quant_bridge_rtl_04/work/fixture',
                    OLD / 't2_tm4_matrix_resident_pilot_02/work/afixture',
                    OLD / 't4_dual_w_fixture_01/work',
                    OLD / 't2_tm4_real_stream_down_01/work/streams']
    fixture_names = [
        ['wi.mem', 'gate.mem', 'q.mem', 'scale.mem', 'd.mem', 'recip.mem'],
        ['output.mem'],
        ['model_identity.hex', 'expected_aux_header.hex', 'aux_header.hex',
         'down_config.hex', 'down_q0.hex', 'down_q1.hex', 'down_scale.hex'],
        ['w8.mem', 'ps.mem']]
    fixture_records = [rec(directory / name)
                       for directory, names in zip(fixture_dirs, fixture_names)
                       for name in names]
    if (fixture_records[2]['sha256'] != rec(OLD / 't2_tm4_matrix_resident_pilot_02/work/afixture/q.mem')['sha256'] or
            fixture_records[3]['sha256'] != rec(OLD / 't2_tm4_matrix_resident_pilot_02/work/afixture/scale.mem')['sha256']):
        raise RuntimeError('G/QUANT and matrix reference A fixtures differ')

    prior_receipts = [R003 / 'gate_split_04/receipt.json',
                      R003 / 'matrix_parent_cache_03/receipt.json']
    prior_manifests = [R003 / 'gate_split_04/input_manifest.json',
                       R003 / 'matrix_parent_cache_03/input_manifest.json']
    prior_seconds = [float(json.loads(path.read_text())['full']['guard']['elapsed_seconds'])
                     for path in prior_receipts]
    prior_markers = [json.loads(path.read_text())['full']['marker'][0]
                     for path in prior_receipts]
    prior_cycles = [int(re.search(r'cycles=(\d+)', marker).group(1))
                    for marker in prior_markers]
    allowance = 1.25
    conservative = math.ceil(sum(prior_seconds) * allowance)
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    xsim = tool.with_name('xsim')
    guard = ROOT / MATRIX / 'tb/production_guard.py'
    scope = ('Same runtime: four physical canonical GEGLU G windows sharing one GATE epoch, '
             'one distinct Q command produces actual fullA window0, strict physical fullW load, '
             'then one rows16/four-view v2 parent matrix with independent PS/final gold, actual '
             'AW/W/B, measured A/W acquire/release and one parent ledger completion. Covers only '
             'the first 16 rows of the B2/S128 tensor; no second parent, unique production hub or '
             'generated caller, L2/L3, CPU/CSim, or M003/M004 completion claim. Runtime is batch '
             'xsim without whole-hierarchy WDB logging; all functional assertions and markers remain.')
    inputs = {'files': records, 'fixture_files': fixture_records,
              'runner': rec(Path(__file__)), 'guard': rec(guard),
              'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'),
              'tool': rec(tool), 'runtime_tool': rec(xsim),
              'scope': scope,
              'full_cost_basis': {
                  'prior_full_receipts': [rec(path) for path in prior_receipts],
                  'prior_input_manifests': [rec(path) for path in prior_manifests],
                  'prior_component_seconds': prior_seconds,
                  'prior_component_cycles': prior_cycles,
                  'planned_full_cycles_upper_bound': sum(prior_cycles),
                  'sum_component_seconds': sum(prior_seconds),
                  'same_runtime_allowance': allowance,
                  'conservative_estimate_seconds': conservative,
                  'full_cap_seconds': 3600, 'full_cycle_cap': 40000000,
                  'applicability': ('The current frozen design reuses the already measured G/Q and '
                                    'matrix/cache DUTs, fixture, independent gold and full workloads '
                                    'in serial in one xsim run. The 25% allowance covers added '
                                    'cross-module wiring/monitors; one process startup is removed. '
                                    'Current pilot rate is measured with the same batch no-wave '
                                    'runtime profile used for full.'),
                  'prerequisite': 'current static and bounded one-row physical G pilot PASS'}}
    results = {'scope': scope}
    pilot_projected_seconds = None
    for mode, rss, seconds in [('static', 24, 1800), ('pilot', 8, 120), ('full', 8, 3600)]:
        if mode == 'full' and (conservative > 3600 or
                               pilot_projected_seconds is not None and
                               pilot_projected_seconds > 3600):
            results['full'] = {'status': 'COST_STOP', 'started': False,
                               'reason': ('current combined pilot cycle rate projects the frozen '
                                          'full workload above the RTL wall-clock cap'),
                               'estimate_seconds': pilot_projected_seconds,
                               'pre_run_component_estimate_seconds': conservative,
                               'cap_seconds': 3600}
            inputs['full_cost_basis']['decision'] = 'COST_STOP'
            snapshot(attempt, inputs, results)
            print('L0_GATE_QUANT_MATRIX_PARENT_FULL_COST_STOP', flush=True)
            return 2
        if mode == 'static':
            run_cwd = ROOT
            payload = [str(tool), '-mode', 'batch', '-notrace',
                       '-log', str(attempt / 'static.log'),
                       '-journal', str(attempt / 'static.jou'),
                       '-source', str(frozen / MATRIX / 'tb/run_gate_quant_matrix_parent_v2.tcl'),
                       '-tclargs', str(attempt / 'work'), str(frozen), mode,
                       *map(str, fixture_dirs)]
        else:
            run_cwd = (attempt / 'work/vivado/gate_quant_matrix_parent_v2.sim/'
                       'sim_1/behav/xsim')
            payload = [str(xsim), 'laya_gate_quant_matrix_parent_tb_v2_behav',
                       '-key', ('Behavioral:sim_1:Functional:'
                                'laya_gate_quant_matrix_parent_tb_v2'),
                       '-tclbatch', str(frozen / MATRIX /
                                        'tb/run_gate_quant_matrix_parent_nowave_v2.tcl'),
                       '-log', str(attempt / (mode + '_sim.log'))]
            for label, directory in zip(('GFIXTURE', 'AFIXTURE', 'WFIXTURE', 'STREAMS'),
                                        fixture_dirs):
                payload += ['-testplusarg', label + '=' + str(directory)]
            if mode == 'pilot':
                payload += ['-testplusarg', 'PILOT']
        command = [sys.executable, str(guard), '--out', str(attempt / ('guard_' + mode)),
                   '--cwd', str(run_cwd), '--rss-gib', str(rss),
                   '--timeout-seconds', str(seconds), '--semantic-stall-seconds', '120',
                   '--', *payload]
        inputs[mode + '_command'] = command
        snapshot(attempt, inputs, results)
        run = subprocess.run(command, cwd=ROOT)
        state = json.loads((attempt / ('guard_' + mode) / 'guard_result.json').read_text())
        log = attempt / ('guard_' + mode) / 'driver.log'
        marker = {'static': 'L0_GATE_QUANT_MATRIX_PARENT_STATIC_PASS',
                  'pilot': 'L0_GATE_QUANT_MATRIX_PARENT_PILOT_PASS',
                  'full': 'L0_GATE_QUANT_MATRIX_PARENT_FULL_PASS'}[mode]
        markers = [line for line in log.read_text().splitlines() if marker in line]
        passed = (run.returncode == 0 and state['child_exit_code'] == 0 and
                  state['trigger'] is None and bool(markers))
        results[mode] = {'status': 'PASS' if passed else 'FAIL', 'guard': state,
                         'marker': markers, 'driver_log': rec(log)}
        if mode == 'pilot' and passed:
            match = re.search(r'L0_GATE_QUANT_MATRIX_PARENT_PILOT_PASS.*cycles=(\d+)', log.read_text())
            pilot_cycles = int(match.group(1))
            pilot_rate = pilot_cycles / state['elapsed_seconds']
            pilot_projected_seconds = math.ceil(sum(prior_cycles) / pilot_rate * 1.10)
            inputs['full_cost_basis']['current_pilot_cycles'] = pilot_cycles
            inputs['full_cost_basis']['current_pilot_seconds'] = state['elapsed_seconds']
            inputs['full_cost_basis']['current_pilot_cycles_per_second'] = pilot_rate
            inputs['full_cost_basis']['pilot_projection_multiplier'] = 1.10
            inputs['full_cost_basis']['current_pilot_projected_full_seconds'] = pilot_projected_seconds
            inputs['full_cost_basis']['decision'] = ('RUN_FULL' if pilot_projected_seconds <= 3600
                                                      else 'COST_STOP')
        results['native_ip'] = [rec(path) for path in (attempt / 'work').rglob('*.xci')]
        snapshot(attempt, inputs, results)
        print('L0_GATE_QUANT_MATRIX_PARENT_' + mode.upper() + '_' + ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
