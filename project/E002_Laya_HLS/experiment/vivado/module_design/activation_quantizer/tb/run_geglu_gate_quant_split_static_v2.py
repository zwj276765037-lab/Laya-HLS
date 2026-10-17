#!/usr/bin/env python3
"""Freeze and compile/elaborate the real split GEGLU/GATE/QUANT hierarchy."""
import argparse
import hashlib
import json
from pathlib import Path
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
    files += [R0, Q / 'tb/geglu_gate_quant_split_static_tb_v2.sv',
              Q / 'tb/run_geglu_gate_quant_split_static_v2.tcl']
    records = []
    for rel in files:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    canonical_records = []
    for src in sorted((ROOT / CANONICAL).glob('*.v')):
        target = frozen / 'external/canonical_rtl' / src.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, target)
        canonical_records.append({'original': rec(src), 'frozen': rec(target)})
    ip_records = []
    for name in ['laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl',
                 'laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl']:
        src = ROOT / QUANT_IP / name
        target = frozen / 'external/quant_ip' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, target)
        ip_records.append({'original': rec(src), 'frozen': rec(target)})
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / GUARD
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard_static'),
               '--cwd', str(ROOT), '--rss-gib', '24', '--timeout-seconds', '1800',
               '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
               '-notrace', '-log', str(attempt / 'static.log'),
               '-journal', str(attempt / 'static.jou'),
               '-source', str(frozen / Q / 'tb/run_geglu_gate_quant_split_static_v2.tcl'),
               '-tclargs', str(attempt / 'work'), str(frozen)]
    scope = ('Static compile/elaboration of the real canonical GEGLU producer, physical GATE '
             'tensor store, delayed QUANT task and full dual-A; no runtime/numeric/full-chain claim')
    inputs = {'files': records, 'canonical_generated_verilog': canonical_records,
              'quant_ip_tcl': ip_records, 'runner': rec(Path(__file__)),
              'guard': rec(guard), 'guard_helper': rec(ROOT / 'tools/hls_guard_helpers.py'),
              'tool': rec(tool), 'command': command, 'scope': scope}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    run = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard_static/guard_result.json').read_text())
    log = attempt / 'guard_static/driver.log'
    passed = (run.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and 'FULL_CURRENT_GATE_QUANT_SPLIT_STATIC_PASS' in log.read_text())
    receipt = {'status': 'PASS' if passed else 'FAIL', 'scope': scope,
               'guard_result': state, 'input_manifest': rec(attempt / 'input_manifest.json'),
               'driver_log': rec(log),
               'native_ip': [rec(path) for path in (attempt / 'work').rglob('*.xci')]}
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_GATE_QUANT_SPLIT_STATIC_' + ('PASS' if passed else 'FAIL'), flush=True)
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
