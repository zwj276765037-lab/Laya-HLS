#!/usr/bin/env python3
"""Replay frozen layernorm_quant_source_03 with an observation-only testbench."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

import run_layernorm_quant_source_shell_v1 as base

ROOT = base.ROOT
PROJECT = base.PROJECT
M = base.M
SOURCE = PROJECT / 'project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_quant_source_03'
OBS_TB = ROOT / M / 'tb/laya_layernorm_quant_source_measure_tb_v1.sv'
TOOL = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')


def rec(path):
    return base.rec(Path(path))


def put(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def check_source(manifest):
    items = manifest['files']
    for item in items:
        path = Path(item['frozen']['path'])
        if rec(path)['sha256'] != item['frozen']['sha256']:
            raise RuntimeError('historical frozen source changed: ' + str(path))
    for item in manifest['generation_attempt']['rtl_files']:
        if rec(item['path'])['sha256'] != item['sha256']:
            raise RuntimeError('historical generated LN changed: ' + item['path'])
    for key in ('fixture_files', 'pilot_fixture_files'):
        for item in manifest[key]:
            if rec(item['path'])['sha256'] != item['sha256']:
                raise RuntimeError('historical fixture changed: ' + item['path'])
    return len(items)


def guarded(attempt, frozen, fixture, mode, cmd, marker, receipt, manifest):
    guard = frozen / M / 'tb/production_guard.py'
    rss = '24' if mode == 'static' else '8'
    timeout = '1800' if mode == 'static' else ('120' if mode == 'pilot' else '3600')
    cwd = ROOT if mode == 'static' else attempt / 'work/vivado/layernorm_quant_source.sim/sim_1/behav/xsim'
    command = [sys.executable, str(guard), '--out', str(attempt / ('guard_' + mode)),
               '--cwd', str(cwd), '--rss-gib', rss, '--timeout-seconds', timeout,
               '--semantic-stall-seconds', '120', '--', *cmd]
    manifest['commands'][mode] = command
    put(attempt / 'input_manifest.json', manifest)
    result = subprocess.run(command, cwd=ROOT)
    state_file = attempt / ('guard_' + mode) / 'guard_result.json'
    state = json.loads(state_file.read_text()) if state_file.is_file() else {'trigger': 'missing_guard_result'}
    driver_log = attempt / ('guard_' + mode) / 'driver.log'
    body = driver_log.read_text(errors='replace') if driver_log.is_file() else ''
    matched = [line for line in body.splitlines() if marker in line]
    passed = (result.returncode == 0 and state.get('child_exit_code') == 0 and
              state.get('trigger') is None and bool(matched) and
              'Fatal:' not in body and 'ERROR:' not in body)
    receipt[mode] = {'status': 'PASS' if passed else 'FAIL', 'runner_exit_code': result.returncode,
                     'guard': state, 'marker': matched,
                     'driver_log': rec(driver_log) if driver_log.is_file() else None,
                     'started': True}
    receipt['input_manifest'] = rec(attempt / 'input_manifest.json')
    receipt['native_ip'] = [rec(path) for path in sorted((attempt / 'work').rglob('*.xci'))]
    put(attempt / 'receipt.json', receipt)
    print('LQ0_' + mode.upper() + '_' + receipt[mode]['status'], flush=True)
    return passed


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = base.launcher_state()
    put(attempt / 'launcher.json', launcher)
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')
    historical_manifest = json.loads((SOURCE / 'input_manifest.json').read_text())
    historical_count = check_source(historical_manifest)
    frozen = attempt / 'frozen'
    shutil.copytree(SOURCE / 'frozen', frozen)
    target_tb = frozen / M / 'tb/laya_layernorm_quant_source_shell_tb_v1.sv'
    old_tb = rec(target_tb)
    shutil.copyfile(OBS_TB, target_tb)
    shutil.copytree(SOURCE / 'fixture', attempt / 'fixture')
    shutil.copytree(SOURCE / 'fixture_pilot', attempt / 'fixture_pilot')
    if not target_tb.is_file():
        raise RuntimeError('observation testbench missing')
    for path in sorted((SOURCE / 'fixture').iterdir()):
        if rec(path)['sha256'] != rec(attempt / 'fixture' / path.name)['sha256']:
            raise RuntimeError('fixture copy mismatch')
    manifest = {
        'schema': 'laya-LQ0-measurement-input-v1',
        'scope': 'original frozen layernorm_quant_source_03 normal rows16 path; only TB observer changes; no F9 rerun',
        'historical_source_manifest': rec(SOURCE / 'input_manifest.json'),
        'historical_receipt': rec(SOURCE / 'receipt.json'),
        'historical_frozen_file_count_checked': historical_count,
        'historical_tb': old_tb,
        'observer_tb': rec(OBS_TB),
        'observer_installed': rec(target_tb),
        'runner': rec(Path(__file__)),
        'frozen_files': [rec(path) for path in sorted(frozen.rglob('*')) if path.is_file()],
        'fixture_files': [rec(path) for path in sorted((attempt / 'fixture').iterdir())],
        'pilot_fixture_files': [rec(path) for path in sorted((attempt / 'fixture_pilot').iterdir())],
        'launcher': rec(attempt / 'launcher.json'),
        'commands': {},
        'profiles': {'static': '24GiB/1800s/120s semantic stall',
                     'pilot': '8GiB/120s/5M cycles/120s semantic stall',
                     'full': '8GiB/3600s/5M cycles/120s semantic stall'},
        'cost_decision': {'status': 'PENDING_CURRENT_PILOT', 'started': False},
    }
    put(attempt / 'input_manifest.json', manifest)
    receipt = {'schema': 'laya-LQ0-measurement-receipt-v1',
               'scope': manifest['scope'], 'launcher': rec(attempt / 'launcher.json'),
               'input_manifest': rec(attempt / 'input_manifest.json')}
    put(attempt / 'receipt.json', receipt)
    static = [str(TOOL), '-mode', 'batch', '-notrace', '-log', str(attempt / 'static.log'),
              '-journal', str(attempt / 'static.jou'), '-source',
              str(frozen / M / 'tb/run_layernorm_quant_source_shell_v1.tcl'),
              '-tclargs', str(attempt / 'work'), str(frozen), str(attempt / 'fixture')]
    if not guarded(attempt, frozen, attempt / 'fixture', 'static', static,
                   'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_STATIC_PASS', receipt, manifest):
        return 1
    run_cwd = attempt / 'work/vivado/layernorm_quant_source.sim/sim_1/behav/xsim'
    staged = []
    for source in sorted((frozen / 'external/layernorm_producer_rtl').glob('*.dat')):
        target = run_cwd / source.name
        shutil.copyfile(source, target)
        if rec(source)['sha256'] != rec(target)['sha256']:
            raise RuntimeError('runtime DAT mismatch: ' + source.name)
        staged.append({'source': rec(source), 'staged': rec(target)})
    if not staged:
        raise RuntimeError('no generated ROM DAT files staged')
    receipt['runtime_dat_staging'] = staged
    put(attempt / 'receipt.json', receipt)
    def sim(mode, rows, fixture):
        return [str(TOOL.parent / 'xsim'), 'laya_layernorm_quant_source_shell_tb_v1_behav',
                '-key', 'Behavioral:sim_1:Functional:laya_layernorm_quant_source_shell_tb_v1',
                '-tclbatch', str(frozen / M / 'tb/run_layernorm_producer_portal_nowave_v1.tcl'),
                '-log', str(attempt / (mode + '_sim.log')),
                '-testplusarg', 'FIXTURE=' + str(fixture), '-testplusarg', 'ROWS=' + str(rows)]
    if not guarded(attempt, frozen, attempt / 'fixture_pilot', 'pilot',
                   sim('pilot', 1, attempt / 'fixture_pilot'),
                   'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS rows=1 ', receipt, manifest):
        return 1
    old = json.loads((SOURCE / 'receipt.json').read_text())
    old_full = old['full']['guard']['elapsed_seconds']
    old_pilot = old['pilot']['guard']['elapsed_seconds']
    new_pilot = receipt['pilot']['guard']['elapsed_seconds']
    reference = max(old_full, old_full * new_pilot / old_pilot)
    projected = math.ceil(reference * 1.5 + 10)
    pilot_markers = receipt['pilot']['marker']
    pilot_cycles = re.findall(r'cycles=(\d+)', pilot_markers[0]) if len(pilot_markers) == 1 else []
    allowed = bool(pilot_cycles) and projected <= 3600 and int(pilot_cycles[0]) * 16 * 1.5 <= 5000000
    manifest['cost_decision'] = {'status': 'RUN_FULL' if allowed else 'COST_STOP',
                                 'old_full_seconds': old_full, 'old_pilot_seconds': old_pilot,
                                 'new_pilot_seconds': new_pilot, 'reference_seconds': reference,
                                 'projected_seconds': projected, 'pilot_cycles': pilot_cycles,
                                 'projection_is_guarantee': False,
                                 'reason': 'frozen full with current pilot ratio and 1.5 safety factor plus 10s'}
    put(attempt / 'input_manifest.json', manifest)
    receipt['cost_decision'] = manifest['cost_decision']
    receipt['input_manifest'] = rec(attempt / 'input_manifest.json')
    put(attempt / 'receipt.json', receipt)
    if not allowed:
        print('LQ0_FULL_COST_STOP', flush=True)
        return 1
    if not guarded(attempt, frozen, attempt / 'fixture', 'full',
                   sim('full', 16, attempt / 'fixture'),
                   'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS rows=16 ', receipt, manifest):
        return 1
    full_log = (attempt / 'full_sim.log').read_text(errors='replace')
    if not all(marker in full_log for marker in ('LQ0_EVENT ', 'LQ0_AXI ', 'LQ0_WAIT ',
                                                'LQ0_LIFECYCLE ')):
        receipt['measurement_status'] = 'FAIL_MISSING_OBSERVER'
        put(attempt / 'receipt.json', receipt)
        return 1
    receipt['measurement_status'] = 'PASS_SCOPED'
    put(attempt / 'receipt.json', receipt)
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
