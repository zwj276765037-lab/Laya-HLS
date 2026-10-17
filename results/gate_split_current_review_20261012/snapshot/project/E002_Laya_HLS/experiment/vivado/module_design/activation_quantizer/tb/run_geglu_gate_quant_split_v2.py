#!/usr/bin/env python3
"""Freeze and run bounded pilot/full evidence for split GEGLU and QUANT."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
Q = Path('vivado/module_design/activation_quantizer')
V = Path('vivado/module_design/vector_and_ffn')
R0 = Path('vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv')
GUARD = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py')
OLD = Path('results/compute_throughput_optimization_20261010/attempts')
CANONICAL = OLD / 't2_geglu_gate_quant_bridge_rtl_04/canonical_rtl'
QUANT_IP = OLD / 'quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog'
FIXTURE = OLD / 't2_geglu_gate_quant_bridge_rtl_04/work/fixture'
PREVIOUS = OLD / 't2_geglu_gate_quant_bridge_rtl_04/receipt.json'


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
    frozen = attempt / 'frozen'
    qrtl = '''quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127
quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1
quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1
geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2
geglu_gate_quant_split_v2'''.split()
    files = [Q / 'rtl' / (name + '.sv') for name in qrtl]
    files += [V / 'rtl' / (name + '.sv') for name in
              ['tanh_libm_canonical', 'geglu_canonical_core', 'geglu_row_bank_v1',
               'geglu_canonical_row_adapter']]
    files += [R0, Q / 'tb/geglu_gate_quant_split_tb_v2.sv',
              Q / 'tb/run_geglu_gate_quant_split_v2.tcl']
    records = []
    for rel in files:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    for src in sorted((ROOT / CANONICAL).glob('*.v')):
        target = frozen / 'external/canonical_rtl' / src.name
        target.parent.mkdir(parents=True, exist_ok=True);shutil.copyfile(src, target)
        records.append({'original': rec(src), 'frozen': rec(target)})
    for name in ['laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl',
                 'laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl']:
        src = ROOT / QUANT_IP / name;target = frozen / 'external/quant_ip' / name
        target.parent.mkdir(parents=True, exist_ok=True);shutil.copyfile(src, target)
        records.append({'original': rec(src), 'frozen': rec(target)})
    fixture_records = []
    frozen_fixture = frozen / 'fixture'
    frozen_fixture.mkdir(parents=True)
    for src in sorted((ROOT / FIXTURE).iterdir()):
        if src.is_file():
            target = frozen_fixture / src.name;shutil.copyfile(src, target)
            fixture_records.append({'original': rec(src), 'frozen': rec(target)})
    previous = json.loads((ROOT / PREVIOUS).read_text())
    old_seconds = float(previous['guard']['elapsed_seconds'])
    estimate = int(old_seconds * (64 / 4) * 1.5 + 0.999999)
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / GUARD
    scope = ('Actual canonical GEGLU over four rows16 G commands sharing one GATE epoch, '
             'then one distinct QUANT command reads window0 and publishes full dual-A; repeated '
             'four-row real fixture, no portal hub, LOAD/matrix/full-chain claim')
    inputs = {'files': records, 'fixture_files': fixture_records,
              'previous_four_row_runtime': rec(ROOT / PREVIOUS),
              'runner': rec(Path(__file__)), 'guard': rec(guard),
              'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'), 'tool': rec(tool),
              'scope': scope,
              'full_cost_basis': {'previous_rows': 4, 'full_rows': 64,
                                  'previous_seconds': old_seconds,
                                  'scale_factor': 16, 'conservative_multiplier': 1.5,
                                  'conservative_estimate_seconds': estimate,
                                  'full_cap_seconds': 3600,
                                  'prerequisite': 'current bounded one-row pilot PASS'}}
    results = {'scope': scope}
    for mode, rss, seconds in [('static', 24, 1800), ('pilot', 8, 120), ('full', 8, 3600)]:
        if mode == 'full' and estimate > 3600:
            results['full'] = {'status': 'COST_STOP', 'started': False,
                               'reason': 'prior measured conservative estimate exceeds cap',
                               'estimate_seconds': estimate, 'cap_seconds': 3600}
            inputs['full_cost_basis']['decision'] = 'COST_STOP'
            (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
            results['input_manifest'] = rec(attempt / 'input_manifest.json')
            (attempt / 'receipt.json').write_text(json.dumps(results, indent=2) + '\n')
            print('FULL_CURRENT_GATE_QUANT_SPLIT_FULL_COST_STOP', flush=True)
            sys.exit(2)
        command = [sys.executable, str(guard), '--out', str(attempt / ('guard_' + mode)),
                   '--cwd', str(ROOT), '--rss-gib', str(rss), '--timeout-seconds', str(seconds),
                   '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
                   '-notrace', '-log', str(attempt / (mode + '.log')),
                   '-journal', str(attempt / (mode + '.jou')),
                   '-source', str(frozen / Q / 'tb/run_geglu_gate_quant_split_v2.tcl'),
                   '-tclargs', str(attempt / 'work'), str(frozen), mode, str(frozen_fixture)]
        inputs[mode + '_command'] = command
        (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
        run = subprocess.run(command, cwd=ROOT)
        state = json.loads((attempt / ('guard_' + mode) / 'guard_result.json').read_text())
        log = attempt / ('guard_' + mode) / 'driver.log'
        marker = {'static': 'FULL_CURRENT_GATE_QUANT_SPLIT_STATIC_PASS',
                  'pilot': 'FULL_CURRENT_GATE_QUANT_SPLIT_PILOT_PASS',
                  'full': 'FULL_CURRENT_GATE_QUANT_SPLIT_FULL_PASS'}[mode]
        passed = (run.returncode == 0 and state['child_exit_code'] == 0 and
                  state['trigger'] is None and marker in log.read_text())
        results[mode] = {'status': 'PASS' if passed else 'FAIL', 'guard': state,
                         'marker': [line for line in log.read_text().splitlines() if marker in line],
                         'driver_log': rec(log)}
        if mode == 'pilot' and passed:
            match = re.search(r'FULL_CURRENT_GATE_QUANT_SPLIT_PILOT_PASS.*cycles=(\d+)', log.read_text())
            inputs['full_cost_basis']['current_pilot_cycles'] = int(match.group(1))
            inputs['full_cost_basis']['current_pilot_seconds'] = state['elapsed_seconds']
            inputs['full_cost_basis']['decision'] = 'RUN_FULL' if estimate <= 3600 else 'COST_STOP'
            (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
        results['input_manifest'] = rec(attempt / 'input_manifest.json')
        results['native_ip'] = [rec(path) for path in (attempt / 'work').rglob('*.xci')]
        (attempt / 'receipt.json').write_text(json.dumps(results, indent=2) + '\n')
        print('FULL_CURRENT_GATE_QUANT_SPLIT_' + mode.upper() + '_' + ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            sys.exit(1)


if __name__ == '__main__':
    main()
