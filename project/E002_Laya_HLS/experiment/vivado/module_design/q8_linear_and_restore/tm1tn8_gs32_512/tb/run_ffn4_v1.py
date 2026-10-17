#!/usr/bin/env python3
"""Freeze the affected FFN4 Wi binding and run bounded compile/reader checks."""
import argparse
import datetime as dt
import difflib
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
E002 = ROOT / 'project/E002_Laya_HLS/experiment'
TB = E002 / 'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb'
ATTEMPTS = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
PRIOR = ATTEMPTS / 'AT059_FFN1_progress_replay_02'
NEW = ATTEMPTS / 'AT063_FFN4_wi_descriptor_01'
DOWN = ATTEMPTS / 'AT035_QAR0_shared_admission_01/frozen'
LN = ATTEMPTS / 'AT040_LNF0_ffn4_02/frozen'
LEAF = (E002 / 'results/compute_throughput_optimization_20261010/attempts/'
        'tanh_libm_round1_02/hls_project/solution1/syn/verilog/'
        'tanh_libm_leaf_fp_add_bits.v')
VIVADO = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
CURRENT = ('ffn0_chain_tb_v1.sv', 'run_ffn4_chain_v1.tcl',
           'ffn4_wi_descriptor_short_tb_v1.sv', 'run_ffn4_wi_short_v1.tcl',
           'run_ffn4_typed_xsim_v1.py', 'run_ffn4_v1.py')
ROOTS = (ATTEMPTS / 'AT035_QAR0_shared_admission_01/work/fixtures/g',
         ATTEMPTS / 'AT035_QAR0_shared_admission_01/work/fixtures/a',
         ATTEMPTS / 'AT035_QAR0_shared_admission_01/work/fixtures/w',
         ATTEMPTS / 'AT035_QAR0_shared_admission_01/work/fixtures/streams',
         ATTEMPTS / 'AT035_QAR0_shared_admission_01/work/fixtures/wi_a',
         ATTEMPTS / 'AT035_QAR0_shared_admission_01/work/fixtures/wi_w',
         ATTEMPTS / 'AT035_QAR0_shared_admission_01/work/fixtures/wi_streams',
         ATTEMPTS / 'AT040_LNF0_ffn4_02/fixture',
         ATTEMPTS / 'AT043_LNQ0_chain_02/bound_identity',
         ATTEMPTS / 'AT057_FFN0_single_runtime_03/fixture')


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return {'bytes': path.stat().st_size, 'sha256': h.hexdigest()}


def entry(path, role):
    return {'path': str(path.resolve()), 'role': role, **digest(path)}


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def freeze():
    if NEW.exists():
        raise RuntimeError('FFN4 frozen attempt already exists; do not overwrite')
    prior_manifest = PRIOR / 'source_manifest.json'
    previous = json.loads(prior_manifest.read_text())
    if len(previous['files']) != 336:
        raise RuntimeError('unexpected parent manifest')
    for item in previous['files']:
        if digest(Path(item['path'])) != {k: item[k] for k in ('bytes', 'sha256')}:
            raise RuntimeError(f'old frozen identity changed: {item["path"]}')
    frozen = NEW / 'frozen_new'
    ffn = NEW / 'frozen_ffn'
    frozen.mkdir(parents=True)
    shutil.copytree(PRIOR / 'frozen_ffn', ffn)
    for p in (PRIOR / 'frozen_new').iterdir():
        if p.is_file():
            shutil.copy2(p, frozen / p.name)
    for name in CURRENT:
        shutil.copy2(TB / name, frozen / name)
    shutil.copy2(PRIOR / 'direct_xsim_candidate_readonly.json',
                 NEW / 'direct_xsim_candidate_readonly.json')
    old = (PRIOR / 'frozen_new/ffn0_chain_tb_v1.sv').read_text().splitlines(True)
    new = (frozen / 'ffn0_chain_tb_v1.sv').read_text().splitlines(True)
    (NEW / 'wi_tb.diff').write_text(''.join(difflib.unified_diff(
        old, new, fromfile='AT059/ffn0_chain_tb_v1.sv',
        tofile='AT063/ffn0_chain_tb_v1.sv')))
    entries = list(previous['files'])
    entries.extend(entry(frozen / name, 'ffn4_affected') for name in CURRENT)
    write(NEW / 'source_manifest.json', {
        'schema': 'ffn4_source_closure_v1', 'stage': 'D-M004-FFN-WI-DESCRIPTOR-REPLAY-01',
        'at': dt.datetime.now(dt.timezone.utc).isoformat(),
        'parent_manifest': str(prior_manifest), 'files': entries,
        'active_chain_tb': str(frozen / 'ffn0_chain_tb_v1.sv'),
        'active_chain_tcl': str(frozen / 'run_ffn4_chain_v1.tcl'),
        'limits': {'static_seconds': 1800, 'static_rss_gib': 24,
                   'short_seconds': 120, 'short_rss_gib': 8,
                   'pilot_seconds': 120, 'full_seconds': 3600,
                   'full_rss_gib': 8, 'full_cycles': 40000000}})
    write(NEW / 'change_scope.json', {
        'parent': str(PRIOR), 'active_tb_diff': str(NEW / 'wi_tb.diff'),
        'new_files': list(CURRENT[1:]),
        'functional_dut': [entry(p, 'unchanged_functional_DUT')
                           for p in sorted(ffn.glob('*.sv'))],
        'source_references': len(entries), 'parent_references': len(previous['files']),
        'normal_profile_gold_fixtures_unchanged': True})
    print(f'FFN4_FROZEN refs={len(entries)}')


def verify():
    manifest = json.loads((NEW / 'source_manifest.json').read_text())
    for item in manifest['files']:
        if digest(Path(item['path'])) != {k: item[k] for k in ('bytes', 'sha256')}:
            raise RuntimeError(f'frozen identity changed: {item["path"]}')
    return manifest


def run(phase):
    verify()
    if phase not in ('static', 'short'):
        raise RuntimeError('bad phase')
    if (NEW / f'launch_{phase}.json').exists():
        raise RuntimeError(f'{phase} already launched in this attempt')
    work = NEW / f'work_{phase}'
    work.mkdir()
    frozen = NEW / 'frozen_new'
    if phase == 'static':
        tcl = frozen / 'run_ffn4_chain_v1.tcl'
        args = ['static', work, DOWN, LN, frozen, NEW / 'frozen_ffn',
                LEAF, *ROOTS]
        marker, seconds, rss, mode = 'FFN0_STATIC_PASS', 1800, 24, 'static'
    else:
        if json.loads((NEW / 'result_static.json').read_text())['verdict'] != 'PASS':
            raise RuntimeError('short test requires current static PASS')
        tcl = frozen / 'run_ffn4_wi_short_v1.tcl'
        args = [work, DOWN, frozen, ROOTS[0]]
        marker, seconds, rss, mode = 'FFN4_WI_SHORT_SCRIPT_PASS', 120, 8, 'error'
    command = [str(VIVADO), '-mode', 'batch', '-notrace',
               '-log', str(NEW / f'{phase}.log'), '-journal', str(NEW / f'{phase}.jou'),
               '-source', str(tcl), '-tclargs', *map(str, args)]
    guarded = [sys.executable, str(frozen / 'ffn0_guard.py'), '--out',
               str(NEW / f'guard_{phase}'), '--cwd', str(E002), '--rss-gib', str(rss),
               '--timeout-seconds', str(seconds), '--semantic-stall-seconds', '120',
               '--phase', mode, '--', *command]
    write(NEW / f'launch_{phase}.json', {
        'at': dt.datetime.now(dt.timezone.utc).isoformat(),
        'command': command, 'guard_command': guarded,
        'source_manifest_sha256': digest(NEW / 'source_manifest.json')['sha256']})
    result = subprocess.run(guarded, cwd=E002, check=False)
    guard = json.loads((NEW / f'guard_{phase}/guard_result.json').read_text())
    log = (NEW / f'guard_{phase}/driver.log').read_text(errors='replace')
    passed = result.returncode == 0 and guard['trigger'] is None and marker in log and \
        'Fatal:' not in log and 'ERROR:' not in log
    write(NEW / f'result_{phase}.json', {
        'verdict': 'PASS' if passed else 'FAIL', 'exit_code': result.returncode,
        'marker': marker, 'guard': guard})
    print(f'FFN4_{phase.upper()}_{"PASS" if passed else "FAIL"}')
    return 0 if passed else 1


def main():
    p = argparse.ArgumentParser()
    p.add_argument('phase', choices=('freeze', 'static', 'short'))
    phase = p.parse_args().phase
    if phase == 'freeze':
        freeze()
        return 0
    return run(phase)


if __name__ == '__main__':
    raise SystemExit(main())
