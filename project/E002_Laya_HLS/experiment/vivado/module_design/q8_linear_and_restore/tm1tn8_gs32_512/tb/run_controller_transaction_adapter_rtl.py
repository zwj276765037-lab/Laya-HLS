#!/usr/bin/env python3
"""Bounded depth2 RTL transaction checks of the actual generated adapter."""
import argparse
import hashlib
import json
import os
from pathlib import Path
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
        MODULE / 'rtl/laya_controller_transaction_adapter_shell_v1.sv',
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
    case_order = ['compute', 'begin', 'producer', 'wait_end', 'wrong_end',
                  'bad_producer', 'cancel_producer', 'end']
    commands = {
        'static': [sys.executable, str(guard), '--out', str(attempt / 'guard_static'),
                   '--cwd', str(ROOT), '--rss-gib', '24', '--timeout-seconds', '1800',
                   '--semantic-stall-seconds', '120', '--', str(VIVADO),
                   '-mode', 'batch', '-notrace', '-log', str(attempt / 'vivado.log'),
                   '-journal', str(attempt / 'vivado.jou'),
                   '-source', str(frozen / MODULE / 'tb/run_controller_transaction_adapter_rtl_v1.tcl'),
                   '-tclargs', str(work), str(frozen), str(fixture)]
    }
    for case in case_order:
        commands['case_' + case] = [
            sys.executable, str(guard), '--out', str(attempt / ('guard_case_' + case)),
            '--cwd', str(run_cwd), '--rss-gib', '8', '--timeout-seconds', '120',
            '--semantic-stall-seconds', '120', '--', str(XSIM), snapshot,
            '-tclbatch', str(frozen / MODULE / 'tb/run_layernorm_producer_portal_nowave_v1.tcl'),
            '-testplusarg', 'FIXTURE=' + str(fixture), '-testplusarg', 'CASE=' + case,
            '-log', str(attempt / (case + '_xsim.log'))]
    scope = ('actual generated adapter with eight real depth2 FIFOs and an RTL '
        'consumer-handshake interlock; eight independently reset bounded protocol '
        'cases compare whole-byte request/completion data and hold after the 14th '
        'and 15th completion reads while a next descriptor waits. Each case proves '
        'only its own transaction and cleanup behavior; the independent runs do not '
        'prove a same-runtime graph. No graph sequencer, physical hub, arithmetic '
        'payload, producer engine/master fence, complete request, joint resources '
        'or hardware claim.')
    manifest = dict(schema='laya-controller-adapter-rtl-input-v1', scope=scope,
        files=files, launcher=rec(attempt / 'launcher.json'), port_evidence=ports,
        fixture_build=dict(command=command, exit_code=built.returncode, elapsed_seconds=time.monotonic()-build_started,
                           log=rec(attempt / 'fixture_build.log')),
        fixture_run=dict(exit_code=ran.returncode, log=rec(attempt / 'fixture_run.log')),
        fixture_files=[rec(p) for p in sorted(fixture.glob('*.hex'))],
        commands=commands, maximum_cycles_per_case=1000000,
        case_order=case_order,
        cost_decision=dict(status='RUN_BOUNDED_INDEPENDENT_CASES', started=False,
                           rationale='each named case has an independent 120 second and 1M cycle cap; this does not restart the refused eight-case full profile'))
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    receipt = dict(schema='laya-controller-adapter-rtl-receipt-v1',
                   scope=scope, input_manifest=rec(manifest_path),
                   cost_decision=dict(manifest['cost_decision']))
    receipt_path = attempt / 'receipt.json'
    receipt['cases'] = {}
    for mode in ['static'] + ['case_' + case for case in case_order]:
        if mode == 'case_compute':
            staged = []
            for p in sorted((frozen / 'external/adapter_rtl').glob('*.dat')):
                target = run_cwd / p.name
                shutil.copyfile(p, target)
                if rec(target)['sha256'] != rec(p)['sha256']:
                    raise RuntimeError('ROM DAT staging identity mismatch')
                staged.append(dict(source=rec(p), staged=rec(target)))
            receipt['rom_dat_staging'] = staged
            manifest['cost_decision']['started'] = True
            receipt['cost_decision']['started'] = True
            manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
            receipt['input_manifest'] = rec(manifest_path)
        tool = subprocess.run(commands[mode],cwd=ROOT)
        gp = attempt / ('guard_static' if mode == 'static' else 'guard_' + mode)
        g=json.loads((gp/'guard_result.json').read_text())
        log=gp/'driver.log';body=log.read_text(errors='replace')
        case = mode[5:] if mode.startswith('case_') else None
        marker = ('FULL_CURRENT_CONTROLLER_ADAPTER_RTL_STATIC_PASS' if mode == 'static'
                  else 'FULL_CURRENT_CONTROLLER_ADAPTER_RTL_PASS case=' + case)
        okay=tool.returncode==0 and g['child_exit_code']==0 and g['trigger'] is None and marker in body and 'Fatal:' not in body and 'ERROR:' not in body
        result=dict(status='PASS' if okay else 'FAIL',started=True,exit_code=tool.returncode,
                    guard=g,driver_log=rec(log),marker=[line for line in body.splitlines() if marker in line])
        if mode == 'static':
            receipt['static'] = result
        else:
            receipt['cases'][case] = result
        receipt_path.write_text(json.dumps(receipt,indent=2)+'\n')
        print('FULL_CURRENT_CONTROLLER_ADAPTER_RTL_'+mode.upper()+'_'+result['status'],flush=True)
        if not okay:return 1
    receipt['status']='PASS_SCOPED_RTL_INDEPENDENT_PROTOCOL_CASES'
    receipt_path.write_text(json.dumps(receipt,indent=2)+'\n')
    return 0

if __name__=='__main__':
    raise SystemExit(main())
