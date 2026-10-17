#!/usr/bin/env python3
"""Freeze one QWIGQD0 source-quantized chain and run bounded serial RTL phases."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

E = Path(__file__).resolve().parents[5]
P = E.parents[2]
ROOT = P / 'project/E005_full_request_performance/experiment_results/runs/R001'
BASE = ROOT / 'attempts/AT032_WIGQD1_observation_01'
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
TB_DIR = E / MODULE / 'tb'
TB_REL = MODULE / 'tb/wigqd0_chain_tb_v1.sv'
BRIDGE_REL = Path('vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv')
SOURCE = E / 'results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin'
SOURCE_SHA = '658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883'
OVERRIDES = {
    Path('frozen') / TB_REL: E / TB_REL,
    Path('frozen') / BRIDGE_REL: E / BRIDGE_REL,
    Path('frozen') / MODULE / 'tb/run_wigqd0_static_v1.tcl': TB_DIR / 'run_wigqd0_static_v1.tcl',
    Path('frozen') / MODULE / 'tb/run_wigqd0_rtl_v1.tcl': TB_DIR / 'run_wigqd0_rtl_v1.tcl',
}


def record(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return {'path': str(path), 'bytes': path.stat().st_size, 'sha256': h.hexdigest()}


def check(path, identity):
    now = record(path)
    if any(now[k] != identity[k] for k in ('bytes', 'sha256')):
        raise RuntimeError(f'identity drift: {path}')
    return now


def write(path, obj):
    path.write_text(json.dumps(obj, indent=2) + '\n')


def copy(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dst)
    return {'source': record(src), 'frozen': record(dst)}


def prepare(attempt):
    if attempt.exists():
        raise RuntimeError('attempt already exists')
    base = json.loads((BASE / 'input_manifest.json').read_text())
    if json.loads((BASE / 'receipt.json').read_text())['status'] != 'PASS_SCOPED_WIGQD1':
        raise RuntimeError('accepted AT032 base changed')
    if len(base['files']) != 103 or record(SOURCE)['sha256'] != SOURCE_SHA or SOURCE.stat().st_size != 16384:
        raise RuntimeError('base/source identity changed')
    attempt.mkdir(parents=True)
    rows = []
    seen = set()
    for row in base['files']:
        old = Path(row['frozen']['path'])
        check(old, row['frozen'])
        rel = old.relative_to(BASE)
        src = OVERRIDES.get(rel, old)
        dst = attempt / rel
        if dst in seen:
            check(dst, record(src))
        else:
            info = copy(src, dst)
        seen.add(dst)
        rows.append({'role': 'QWIGQD0_modified' if src != old else row['role'],
                     'source': record(src), 'frozen': record(dst)})
    if sum(1 for r in rows if r['role'] == 'QWIGQD0_modified') != 4:
        raise RuntimeError('expected bridge, TB, two Tcl overrides')
    runner = attempt / 'frozen/tools/run_qwigqd0_chain.py'
    rows.append({'role': 'QWIGQD0_runner', **copy(__file__, runner)})
    binary = attempt / 'frozen/inputs/wi_rows4_source_f32.bin'
    rows.append({'role': 'LN_FFN_source_binary', **copy(SOURCE, binary)})
    source_hex = attempt / 'work/fixtures/source/f32_bytes.mem'
    source_hex.parent.mkdir(parents=True, exist_ok=True)
    source_hex.write_text(''.join(f'{v:02x}\n' for v in SOURCE.read_bytes()))
    rows.append({'role': 'LN_FFN_source_bytes', 'source': record(binary),
                 'frozen': record(source_hex)})
    manifest = {'scope': 'QWIGQD0 original LN_FFN F32 AXI quant to Wi, then same-runtime Wi/G/quant/Down',
                'status': 'NOT_RUN', 'files': rows, 'tool': base['tool'],
                'upstream': {'AT032_manifest': record(BASE / 'input_manifest.json'),
                             'AT032_receipt': record(BASE / 'receipt.json')},
                'limits': base['limits'], 'restriction': 'one integration, at most two reasoned repairs'}
    write(attempt / 'input_manifest.json', manifest)
    write(attempt / 'receipt.json', {'status': 'NOT_RUN', 'manifest': record(attempt / 'input_manifest.json'),
                                     'phases': {}})
    print('QWIGQD0_PREPARED_NOT_RUN', attempt, flush=True)


def run(attempt):
    receipt_path = attempt / 'receipt.json'
    receipt = json.loads(receipt_path.read_text())
    if receipt['status'] != 'NOT_RUN' or receipt['phases']:
        raise RuntimeError('only fresh NOT_RUN attempt may execute')
    manifest = json.loads((attempt / 'input_manifest.json').read_text())
    check(attempt / 'input_manifest.json', receipt['manifest'])
    for row in manifest['files']:
        check(row['frozen']['path'], row['frozen'])
    check(manifest['tool']['path'], manifest['tool'])
    if not {0, 1, 2, 3}.issubset(os.sched_getaffinity(0)):
        raise RuntimeError('CPU0-3 unavailable')
    os.sched_setaffinity(0, {0, 1, 2, 3})
    frozen = attempt / 'frozen'
    work = attempt / 'work'
    fixtures = [str(work / 'fixtures' / k) for k in
                ('g', 'a', 'w', 'streams', 'wi_a', 'wi_w', 'wi_streams')]
    source_hex = work / 'fixtures/source/f32_bytes.mem'
    for mode, rss, seconds in (('static', 24, 1800), ('pilot', 8, 120), ('full', 8, 3600)):
        if mode == 'full':
            pilot = receipt['phases']['pilot']['guard']['elapsed_seconds']
            base_full = json.loads((BASE / 'receipt.json').read_text())['phases']['full']['guard']['elapsed_seconds']
            estimate = 1.5 * base_full + 2 * pilot
            receipt['full_cost_basis'] = {'AT032_full_seconds': base_full, 'pilot_seconds': pilot,
                                          'conservative_seconds': estimate,
                                          'method': '1.5x accepted full plus 2x new pilot'}
            if estimate > 3600:
                receipt['status'] = 'COST_STOP'
                receipt['phases']['full'] = {'status': 'COST_STOP', 'launched': False}
                write(receipt_path, receipt)
                print('QWIGQD0_FULL_COST_STOP_NOT_LAUNCHED', flush=True)
                return
        for row in manifest['files']:
            check(row['frozen']['path'], row['frozen'])
        script = frozen / MODULE / 'tb' / ('run_wigqd0_static_v1.tcl' if mode == 'static' else 'run_wigqd0_rtl_v1.tcl')
        args = ([str(work), str(frozen), *fixtures, str(source_hex)] if mode == 'static'
                else [str(work), mode])
        cmd = [sys.executable, str(frozen / 'tools/production_guard.py'),
               '--out', str(attempt / ('guard_' + mode)), '--cwd', str(E),
               '--rss-gib', str(rss), '--timeout-seconds', str(seconds),
               '--semantic-stall-seconds', '120', '--', manifest['tool']['path'],
               '-mode', 'batch', '-notrace', '-log', str(attempt / (mode + '.log')),
               '-journal', str(attempt / (mode + '.jou')), '-source', str(script), '-tclargs', *args]
        write(attempt / (mode + '_command.json'), cmd)
        child = subprocess.run(cmd, cwd=E)
        guard_path = attempt / ('guard_' + mode) / 'guard_result.json'
        state = json.loads(guard_path.read_text()) if guard_path.exists() else {'trigger': 'missing_guard_result'}
        driver = attempt / ('guard_' + mode) / 'driver.log'
        log = driver.read_text(errors='replace') if driver.exists() else ''
        marker = {'static': 'WIGQD0_STATIC_PASS', 'pilot': 'QWIGQD0_PILOT_PASS',
                  'full': 'QWIGQD0_CHAIN_PASS'}[mode]
        passed = child.returncode == 0 and state.get('trigger') is None and state.get('child_exit_code') == 0 and marker in log
        phase = {'status': 'PASS' if passed else 'COST_STOP' if state.get('trigger') else 'FAIL',
                 'guard': state, 'driver': record(driver) if driver.exists() else None,
                 'marker': marker if marker in log else None}
        raw = work / 'vivado/wigqd0_chain_tb_v1.sim/sim_1/behav/xsim/simulate.log'
        if raw.exists() and mode != 'static':
            dest = attempt / ('raw_' + mode + '.log')
            shutil.copyfile(raw, dest)
            phase['raw'] = record(dest)
            if re.search(r'(^|\n)(Fatal:|ERROR:)', dest.read_text(errors='replace')):
                phase['status'] = 'FAIL'
                passed = False
        receipt['phases'][mode] = phase
        receipt['status'] = ('PASS_SCOPED_QWIGQD0' if passed and mode == 'full'
                             else 'IN_PROGRESS' if passed else phase['status'])
        write(receipt_path, receipt)
        print('QWIGQD0_' + mode.upper() + '_' + phase['status'], flush=True)
        if not passed:
            return


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--attempt', required=True, type=Path)
    ap.add_argument('--prepare-only', action='store_true')
    ap.add_argument('--execute-prepared', action='store_true')
    args = ap.parse_args()
    attempt = args.attempt.resolve()
    if not attempt.is_relative_to((ROOT / 'attempts').resolve()):
        ap.error('attempt must be in E005/R001/attempts')
    if args.execute_prepared:
        run(attempt)
    else:
        prepare(attempt)
        if not args.prepare_only:
            run(attempt)


if __name__ == '__main__':
    main()
