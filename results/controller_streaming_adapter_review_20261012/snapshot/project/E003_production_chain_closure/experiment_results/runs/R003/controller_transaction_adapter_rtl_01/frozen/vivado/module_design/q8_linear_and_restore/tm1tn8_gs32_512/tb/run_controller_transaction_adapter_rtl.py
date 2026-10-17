#!/usr/bin/env python3
"""Bounded depth2 RTL transaction checks of the actual generated adapter."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import resource
import runpy
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
VITIS_INCLUDE = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include')
VIVADO = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
XSIM = VIVADO.with_name('xsim')


def rec(path):
    path = path.resolve()
    return dict(path=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def copy(source, destination, files):
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    files.append(dict(original=rec(source), frozen=rec(destination)))


def limit():
    resource.setrlimit(resource.RLIMIT_AS, (24 * 1024**3, 24 * 1024**3))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--generation', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    generation = args.generation.resolve()
    helper_path = ROOT / MODULE / 'tb/run_controller_transaction_adapter_hls.py'
    helper = runpy.run_path(str(helper_path))
    launcher = helper['launcher_state']()
    (attempt / 'launcher.json').write_text(json.dumps(launcher, indent=2) + '\n')
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')
    previous = json.loads((generation / 'receipt.json').read_text())
    if previous['exit_code'] != 0 or previous['guard_result']['child_exit_code'] != 0 or previous['guard_result']['trigger'] is not None:
        raise RuntimeError('generation tool did not complete safely')
    candidates = list((generation / 'work').glob('**/syn/verilog/laya_command_provenance_adapter.v'))
    if len(candidates) != 1:
        raise RuntimeError('actual generated adapter is absent/ambiguous')
    ports = helper['port_evidence'](candidates[0])
    if ports['fifo_signal_count'] != 24 or ports['external_fifo_signal_count'] != 18 or any(ports['forbidden_control'].values()):
        raise RuntimeError('adapter top interface mismatch')
    frozen = attempt / 'frozen'
    files = []
    sources = helper['source_list'](ROOT / 'config/controller_adapter_sources.cmake')
    fixture_source = Path('tests/controller_transaction_adapter_rtl_fixture.cpp')
    roots = sources + [fixture_source, Path('config/controller_adapter_sources.cmake'),
        MODULE / 'rtl/laya_private_fifo2_v1.sv',
        MODULE / 'tb/laya_controller_transaction_adapter_tb_v1.sv',
        MODULE / 'tb/run_controller_transaction_adapter_rtl_v1.tcl',
        MODULE / 'tb/run_layernorm_producer_portal_nowave_v1.tcl',
        MODULE / 'tb/production_guard.py', Path('tools/hls_guard_helpers.py'),
        helper_path.relative_to(ROOT), Path(__file__).resolve().relative_to(ROOT)]
    helper['freeze_closure'](roots, frozen, files)
    rtl_directory = candidates[0].parent
    for source in sorted(rtl_directory.iterdir()):
        if source.suffix in {'.v', '.dat'}:
            copy(source, frozen / 'external/adapter_rtl' / source.name, files)
    for name in ['receipt.json', 'input_manifest.json', 'work/hls/syn/report/laya_command_provenance_adapter_csynth.rpt', 'work/hls/syn/report/csynth_design_size.rpt']:
        copy(generation / name, frozen / 'external/generation' / name, files)
    contract = PROJECT / 'results/production_hls_partition_contract_20261012.md'
    copy(contract, frozen / 'external/production_hls_partition_contract_20261012.md', files)
    fixture = attempt / 'fixture'
    fixture.mkdir()
    compiler = shutil.which('g++')
    binary = attempt / 'fixture_generator'
    flags = ['-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror',
             '-Wno-aggressive-loop-optimizations', '-Wno-unknown-pragmas',
             '-Wno-unused-parameter', '-fno-fast-math', '-fno-associative-math', '-ffp-contract=off',
             '-I' + str(frozen / 'include'), '-I' + str(frozen / 'hls'),
             '-I' + str(frozen / 'hls/platform'), '-I' + str(frozen / MODEL),
             '-isystem', str(VITIS_INCLUDE)]
    command = [compiler, *flags, str(frozen / fixture_source),
               *[str(frozen / source) for source in sources], '-o', str(binary)]
    build_started = time.monotonic()
    with (attempt / 'fixture_build.log').open('w') as log:
        built = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                               timeout=1800, preexec_fn=limit)
    if built.returncode:
        raise RuntimeError('fixture compile failed; raw log retained')
    with (attempt / 'fixture_run.log').open('w') as log:
        ran = subprocess.run([str(binary), str(fixture)], stdout=log,
                             stderr=subprocess.STDOUT, timeout=120, preexec_fn=limit)
    if ran.returncode:
        raise RuntimeError('fixture generation failed')
    guard = frozen / MODULE / 'tb/production_guard.py'
    work = attempt / 'work'
    run_cwd = work / 'vivado/controller_adapter_rtl.sim/sim_1/behav/xsim'
    snapshot = 'laya_controller_transaction_adapter_tb_v1_behav'
    commands = {}
    for mode, cap, rss, executable, extra, cwd in [
        ('static', 1800, 24, VIVADO,
         ['-mode', 'batch', '-notrace', '-log', str(attempt / 'vivado.log'),
          '-journal', str(attempt / 'vivado.jou'), '-source', str(frozen / MODULE / 'tb/run_controller_transaction_adapter_rtl_v1.tcl'),
          '-tclargs', str(work), str(frozen), str(fixture)], ROOT),
        ('pilot', 120, 8, XSIM,
         [snapshot, '-tclbatch', str(frozen / MODULE / 'tb/run_layernorm_producer_portal_nowave_v1.tcl'),
          '-testplusarg', 'FIXTURE=' + str(fixture), '-testplusarg', 'CASES=1', '-log', str(attempt / 'pilot_xsim.log')], run_cwd),
        ('full', 3600, 8, XSIM,
         [snapshot, '-tclbatch', str(frozen / MODULE / 'tb/run_layernorm_producer_portal_nowave_v1.tcl'),
          '-testplusarg', 'FIXTURE=' + str(fixture), '-testplusarg', 'CASES=8', '-log', str(attempt / 'full_xsim.log')], run_cwd)]:
        commands[mode] = [sys.executable, str(guard), '--out', str(attempt / ('guard_' + mode)),
            '--cwd', str(cwd), '--rss-gib', str(rss), '--timeout-seconds', str(cap),
            '--semantic-stall-seconds', '120', '--', str(executable), *extra]
    scope = 'actual generated adapter with eight real depth2 FIFOs, whole-byte request/completion comparisons and controlled remote replies; partial response/internal frame, held cancel cleanup/local rejection, undrained END, stale binding, malformed completion, output backpressure. No graph sequencer, physical hub, arithmetic payload, producer engine/master fence, complete request, joint resources or hardware claim.'
    manifest = dict(schema='laya-controller-adapter-rtl-input-v1', scope=scope,
        files=files, launcher=rec(attempt / 'launcher.json'), port_evidence=ports,
        fixture_build=dict(command=command, exit_code=built.returncode, elapsed_seconds=time.monotonic()-build_started,
                           log=rec(attempt / 'fixture_build.log')),
        fixture_run=dict(exit_code=ran.returncode, log=rec(attempt / 'fixture_run.log')),
        fixture_files=[rec(p) for p in sorted(fixture.glob('*.hex'))],
        commands=commands, maximum_cycles=1000000,
        cost_decision=dict(status='PENDING_CURRENT_PILOT', started=False))
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    receipt = dict(schema='laya-controller-adapter-rtl-receipt-v1',scope=scope,input_manifest=rec(manifest_path))
    receipt_path = attempt / 'receipt.json'
    for mode in ['static', 'pilot', 'full']:
        if mode == 'pilot':
            staged = []
            for p in sorted((frozen / 'external/adapter_rtl').glob('*.dat')):
                target = run_cwd / p.name
                shutil.copyfile(p, target)
                if rec(target)['sha256'] != rec(p)['sha256']:
                    raise RuntimeError('ROM DAT staging identity mismatch')
                staged.append(dict(source=rec(p), staged=rec(target)))
            receipt['rom_dat_staging'] = staged
        if mode == 'full':
            pilot = receipt['pilot']; body = Path(pilot['driver_log']['path']).read_text()
            matches = re.findall(r'FULL_CURRENT_CONTROLLER_ADAPTER_RTL_PASS cases=1 .*cycles=(\d+)', body)
            seconds = pilot['guard']['elapsed_seconds']; cycles = int(matches[0]) if len(matches)==1 else 0
            valid = cycles > 0 and math.isfinite(seconds) and 0 < seconds <= 120
            reference_cycles = cycles * 8 * 3
            projected = math.ceil(reference_cycles * 1.5 / (cycles / seconds)) if valid else None
            allowed = valid and projected <= 3600 and reference_cycles * 1.5 <= 1000000
            decision = dict(status='RUN_FULL' if allowed else 'COST_STOP',started=False,
                current_pilot_cycles=cycles, current_pilot_seconds=seconds,
                current_cycles_per_second=cycles/seconds if valid else None,
                reference_full_cycles=reference_cycles, safety_factor=1.5,
                projected_full_seconds=projected, maximum_seconds=3600, maximum_cycles=1000000,
                reference_kind='eight protocol cases times current compute/local-reject pilot, with extra 3x per-case complexity allowance; not proven cycle upper bound')
            manifest['cost_decision']=decision;receipt['cost_decision']=decision
            manifest_path.write_text(json.dumps(manifest,indent=2)+'\n');receipt['input_manifest']=rec(manifest_path)
            if not allowed:
                receipt['full']=dict(status='COST_STOP',started=False)
                receipt_path.write_text(json.dumps(receipt,indent=2)+'\n')
                return 1
        tool = subprocess.run(commands[mode],cwd=ROOT)
        gp=attempt/('guard_'+mode);g=json.loads((gp/'guard_result.json').read_text())
        log=gp/'driver.log';body=log.read_text(errors='replace')
        marker='FULL_CURRENT_CONTROLLER_ADAPTER_RTL_STATIC_PASS' if mode=='static' else 'FULL_CURRENT_CONTROLLER_ADAPTER_RTL_PASS'
        okay=tool.returncode==0 and g['child_exit_code']==0 and g['trigger'] is None and marker in body and 'Fatal:' not in body and 'ERROR:' not in body
        receipt[mode]=dict(status='PASS' if okay else 'FAIL',started=True,exit_code=tool.returncode,
                           guard=g,driver_log=rec(log),marker=[line for line in body.splitlines() if marker in line])
        receipt_path.write_text(json.dumps(receipt,indent=2)+'\n')
        print('FULL_CURRENT_CONTROLLER_ADAPTER_RTL_'+mode.upper()+'_'+receipt[mode]['status'],flush=True)
        if not okay:return 1
    receipt['status']='PASS_SCOPED_RTL'
    receipt_path.write_text(json.dumps(receipt,indent=2)+'\n')
    return 0

if __name__=='__main__':
    raise SystemExit(main())
