#!/usr/bin/env python3
"""Current resident normal-path regression on unchanged independent Down gold."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
ATTEMPTS = ROOT / 'results/compute_throughput_optimization_20261010/attempts'


def rec(p):
    p = p.resolve()
    return dict(path=str(p), bytes=p.stat().st_size,
                sha256=hashlib.sha256(p.read_bytes()).hexdigest())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    source = attempt / 'frozen'
    rtl = '''tm4tn8_bias_bits_v1 tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair
tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1
tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2
tm4tn8_final_ps_adapter_v1 tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1
tm4tn8_matrix_owner_ledger_v2 tm4tn8_matrix_resident_v2'''.split()
    files = [MODULE / 'rtl' / (f + '.sv') for f in rtl]
    for mod, names in [('activation_quantizer', 'quant_a_row_bank_v1 quant_dual_a_v1'),
                       ('hbm_loader_and_cache', 't4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1')]:
        files += [Path('vivado/module_design') / mod / 'rtl' / (f + '.sv') for f in names.split()]
    files += [MODULE / 'tb' / f for f in ['create_fp_ip.tcl', 'tm4tn8_matrix_resident_tb_v2.sv',
              'run_tm4_matrix_resident_tb_static_v2.tcl', 'run_tm4_matrix_resident_tb_rtl_v2.tcl']]
    inputs = dict(files=[], fixture_files=[], runner=rec(Path(__file__)),
                  scope='Affected current resident normal path; four real prequantized Down rows through actual fullA/dualW/nativeFP/output/lastB. No same-runtime Wi/G/quant or production13BO claim.')
    for rel in files:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        inputs['files'].append(dict(original=rec(ROOT / rel), frozen=rec(target)))
    previous = ATTEMPTS / 't2_tm4_matrix_resident_pilot_02/input_manifest.json'
    expected = json.loads(previous.read_text())['files']
    inputs['original_fixture_identity_manifest'] = rec(previous)
    oldroot = '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/'
    fixture_dirs = [ATTEMPTS / 't2_tm4_matrix_resident_pilot_02/work/afixture',
                    ATTEMPTS / 't4_dual_w_fixture_01/work',
                    ATTEMPTS / 't2_tm4_real_stream_down_01/work/streams']
    fixture_names = [['q.mem', 'scale.mem', 'output.mem'],
                     ['model_identity.hex', 'expected_aux_header.hex', 'aux_header.hex',
                      'down_config.hex', 'down_q0.hex', 'down_q1.hex', 'down_scale.hex'],
                     ['w8.mem', 'ps.mem']]
    for directory, names in zip(fixture_dirs, fixture_names):
        for name in names:
            current = rec(directory / name)
            matches = [r for r in expected if str(ROOT / r['path'].removeprefix(oldroot)) == current['path']]
            assert len(matches) == 1, current['path']
            assert current['sha256'] == matches[0]['sha256'] and current['bytes'] == matches[0]['bytes'], name
            inputs['fixture_files'].append(dict(current=current, original=matches[0]))
    guard = ROOT / MODULE / 'tb/production_guard.py'
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    inputs.update(guard=rec(guard), guard_helpers=rec(ROOT / 'tools/hls_guard_helpers.py'), tool=rec(tool))
    inputs['full_cost_basis'] = dict(previous_full=rec(ATTEMPTS / 't2_tm4_matrix_resident_full_down_01/receipt.json'),
                                   previous_seconds=421.8807475399226, conservative_estimate_seconds=633,
                                   cap_seconds=3600, cycle_cap=40000000, prerequisite='current bounded pilot must PASS')
    results = dict(scope=inputs['scope'])
    for mode, rss, seconds in [('static', 24, 1800), ('pilot', 8, 120), ('full', 8, 3600)]:
        script = 'run_tm4_matrix_resident_tb_static_v2.tcl' if mode == 'static' else 'run_tm4_matrix_resident_tb_rtl_v2.tcl'
        tclargs = [str(attempt / 'work'), str(source), *map(str, fixture_dirs)] if mode == 'static' else [str(attempt / 'work'), mode]
        command = [sys.executable, str(guard), '--out', str(attempt / ('guard_' + mode)), '--cwd', str(ROOT),
                   '--rss-gib', str(rss), '--timeout-seconds', str(seconds), '--semantic-stall-seconds', '120', '--',
                   str(tool), '-mode', 'batch', '-notrace', '-log', str(attempt / (mode + '.log')),
                   '-journal', str(attempt / (mode + '.jou')), '-source', str(source / MODULE / 'tb' / script),
                   '-tclargs', *tclargs]
        inputs[mode + '_command'] = command
        (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
        run = subprocess.run(command, cwd=ROOT)
        log = attempt / ('guard_' + mode) / 'driver.log'
        state = json.loads((log.parent / 'guard_result.json').read_text())
        marker = 'TM4_MATRIX_RESIDENT_TB_STATIC_PASS' if mode == 'static' else 'TM4_MATRIX_RESIDENT_' + mode.upper() + '_PASS'
        markers = [line for line in log.read_text().splitlines() if marker in line]
        passed = run.returncode == 0 and state['child_exit_code'] == 0 and state['trigger'] is None and bool(markers)
        results[mode] = dict(status='PASS' if passed else 'FAIL', guard=state, marker=markers, driver_log=rec(log))
        results['input_manifest'] = rec(attempt / 'input_manifest.json')
        results['native_ip'] = [rec(f) for f in (attempt / 'work').rglob('*.xci')]
        (attempt / 'receipt.json').write_text(json.dumps(results, indent=2) + '\n')
        print('FULL_CURRENT_RESIDENT_' + mode.upper() + '_' + ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            sys.exit(1)


if __name__ == '__main__':
    main()
