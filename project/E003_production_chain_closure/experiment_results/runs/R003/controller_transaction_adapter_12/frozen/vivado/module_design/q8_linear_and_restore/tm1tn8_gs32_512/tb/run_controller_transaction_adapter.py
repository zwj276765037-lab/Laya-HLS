#!/usr/bin/env python3
"""Freeze, build, and run the bounded Controller transaction host tests."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import resource
import shutil
import subprocess
import time


ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def launcher_state():
    available_kib = None
    for line in Path('/proc/meminfo').read_text().splitlines():
        if line.startswith('MemAvailable:'):
            available_kib = int(line.split()[1])
            break
    state = {
        'pid': os.getpid(),
        'cpu_affinity': sorted(os.sched_getaffinity(0)),
        'nice': os.getpriority(os.PRIO_PROCESS, 0),
        'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                 check=True, text=True,
                                 capture_output=True).stdout.strip(),
        'mem_available_kib': available_kib,
        'required_mem_available_kib': 192 * 1024 * 1024,
    }
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and
                     state['nice'] == 19 and
                     state['ionice'].startswith('idle') and
                     available_kib is not None and
                     available_kib > state['required_mem_available_kib'])
    return state


def bounded_child():
    maximum = 24 * 1024**3
    resource.setrlimit(resource.RLIMIT_AS, (maximum, maximum))


def run(command, cwd, log):
    started = time.monotonic()
    with log.open('w') as stream:
        result = subprocess.run(command, cwd=cwd, stdout=stream,
                                stderr=subprocess.STDOUT, timeout=1800,
                                preexec_fn=bounded_child)
    return {'command': command, 'exit_code': result.returncode,
            'elapsed_seconds': time.monotonic() - started,
            'log': rec(log)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    launcher = launcher_state()
    (attempt / 'launcher.json').write_text(json.dumps(launcher, indent=2) + '\n')
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')

    source = attempt / 'frozen'
    relative = [
        Path('hls/common/laya_numeric.cpp'),
        Path('hls/common/laya_tasks.cpp'),
        Path('hls/platform/compute_portal_codec.cpp'),
        Path('hls/platform/generated_provenance_codec.cpp'),
        Path('hls/platform/producer_engine_codec.cpp'),
        Path('hls/platform/controller_transaction_codec.cpp'),
        Path('hls/platform/controller_transaction_adapter.cpp'),
        Path('tests/controller_transaction_codec_test.cpp'),
        Path('tests/controller_transaction_adapter_test.cpp'),
        Path('tests/controller_transaction_sequencer_codec_test.cpp'),
        Path('tests/controller_transaction_oracle.py'),
        Path('build/model-current-production-v2-20261011/laya_model_layout_generated.h'),
        Path('config/full_module_registry.json'),
        Path('config/production_hls_partitions.json'),
        Path('config/controller_adapter_sources.cmake'),
        MODULE / 'rtl/laya_controller_transaction_layout_v1.sv',
        Path(__file__).resolve().relative_to(ROOT),
    ]
    relative += sorted(path.relative_to(ROOT)
                       for path in (ROOT / 'include').glob('*.h'))
    records = []
    for rel in relative:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'relative': str(rel), 'original': rec(ROOT / rel),
                        'frozen': rec(target)})

    contract = PROJECT / 'results/production_hls_partition_contract_20261012.md'
    contract_copy = source / 'external/production_hls_partition_contract_20261012.md'
    contract_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_copy)

    compiler = shutil.which('g++')
    if compiler is None:
        raise RuntimeError('g++ absent')
    vitis_include = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include')
    common_flags = [
        compiler, '-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror',
        '-Wno-aggressive-loop-optimizations', '-Wno-unknown-pragmas',
        '-Wno-unused-parameter', '-fno-fast-math', '-fno-associative-math',
        '-ffp-contract=off', '-I' + str(source / 'include'),
        '-I' + str(source / 'hls'), '-I' + str(source / 'hls/platform'),
        '-I' + str(source / 'build/model-current-production-v2-20261011'),
    ]
    codec_sources = [
        'tests/controller_transaction_codec_test.cpp',
        'hls/platform/controller_transaction_codec.cpp',
        'hls/platform/compute_portal_codec.cpp',
        'hls/platform/generated_provenance_codec.cpp',
        'hls/platform/producer_engine_codec.cpp',
        'hls/common/laya_numeric.cpp', 'hls/common/laya_tasks.cpp',
    ]
    adapter_sources = [
        'tests/controller_transaction_adapter_test.cpp',
        'hls/platform/controller_transaction_adapter.cpp',
    ] + codec_sources[1:]
    codec_binary = attempt / 'controller_transaction_codec_test'
    adapter_binary = attempt / 'controller_transaction_adapter_test'
    sequencer_codec_binary = attempt / 'controller_transaction_sequencer_codec_test'
    codec_compile = common_flags + [str(source / rel) for rel in codec_sources] + [
        '-o', str(codec_binary)]
    adapter_compile = common_flags + ['-isystem', str(vitis_include)] + [
        str(source / rel) for rel in adapter_sources] + ['-o', str(adapter_binary)]
    fixture = attempt / 'fixture'
    fixture.mkdir()
    commands = []
    commands.append(run(codec_compile, source, attempt / 'codec_build.log'))
    commands.append(run([str(codec_binary), str(fixture)], source,
                        attempt / 'codec_run.log'))
    commands.append(run(['python3', str(source /
                        'tests/controller_transaction_oracle.py'),
                        '--fixture', str(fixture)], source,
                        attempt / 'oracle.log'))
    commands.append(run(adapter_compile, source, attempt / 'adapter_build.log'))
    commands.append(run([str(adapter_binary)], source, attempt / 'adapter_run.log'))
    sequencer_codec_sources = [
        'tests/controller_transaction_sequencer_codec_test.cpp',
        'hls/platform/controller_transaction_codec.cpp',
        'hls/common/laya_numeric.cpp', 'hls/common/laya_tasks.cpp',
    ]
    sequencer_codec_compile = common_flags + [
        '-DLAYA_TRANSACTION_SEQUENCER_CODEC'] + [
        str(source / rel) for rel in sequencer_codec_sources] + [
        '-o', str(sequencer_codec_binary)]
    commands.append(run(sequencer_codec_compile, source,
                        attempt / 'sequencer_codec_build.log'))
    commands.append(run([str(sequencer_codec_binary)], source,
                        attempt / 'sequencer_codec_run.log'))

    scope = (
        'normalized fixed-size sequencer/adapter schema for exactly one '
        'COMPUTE, PROVENANCE, or PRODUCER transaction; explicit little-endian '
        'fields and zero reserves, independent Python byte oracle, host stream '
        'adapter ownership of the six external FIFOs (18 signals), partial '
        'response continuation under cancel, pre-admission cancel rejection, '
        'cleanup END admission, stale binding reporting, malformed-frame raw '
        'capture inside the adapter followed by normalized rejection with all '
        'completion trust fields cleared, fixed-header rejection clearing a '
        'pre-populated success or LOCAL_REJECT object in both codec builds, '
        'sequencer-only codec '
        'closure without the three external protocol codec objects, and one '
        'in-flight software '
        'state machine; no HLS RTL generation, actual depth2 '
        'backpressure, graph sequencer integration, physical AXI/fence, '
        'full-model request, resource, timing, or board claim')
    manifest = {
        'schema': 'laya-controller-transaction-host-input-v1',
        'scope': scope,
        'files': records,
        'contract': {'original': rec(contract), 'frozen': rec(contract_copy)},
        'compiler': rec(Path(compiler)),
        'external_headers': [rec(vitis_include / 'ap_int.h'),
                             rec(vitis_include / 'hls_stream.h')],
        'launcher': rec(attempt / 'launcher.json'),
        'commands': commands,
        'profile': {'kind': 'static_host', 'maximum_seconds': 1800,
                    'maximum_rss_gib': 24},
    }
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    fixture_records = [rec(path) for path in sorted(fixture.iterdir())]
    logs = [Path(item['log']['path']) for item in commands]
    markers = [line for path in logs for line in path.read_text().splitlines()
               if 'FULL_CURRENT_CONTROLLER_TRANSACTION_' in line]
    passed = (all(item['exit_code'] == 0 for item in commands) and
              any('CODEC_PASS' in line for line in markers) and
              any('ORACLE_PASS' in line for line in markers) and
              any('ADAPTER_PASS' in line for line in markers) and
              any('SEQUENCER_CODEC_PASS' in line for line in markers))
    receipt = {
        'schema': 'laya-controller-transaction-host-receipt-v1',
        'status': 'PASS' if passed else 'FAIL',
        'scope': scope,
        'launcher': rec(attempt / 'launcher.json'),
        'input_manifest': rec(manifest_path),
        'fixture_files': fixture_records,
        'commands': commands,
        'markers': markers,
    }
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_CONTROLLER_TRANSACTION_HOST_' +
          ('PASS' if passed else 'FAIL'), flush=True)
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
