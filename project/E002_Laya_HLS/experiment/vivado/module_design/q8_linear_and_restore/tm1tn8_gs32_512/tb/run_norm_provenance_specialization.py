#!/usr/bin/env python3
"""Freeze and guard independent NORM provenance equivalence HOST checks."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
TEST = Path('tests/norm_provenance_specialization_test.cpp')
VITIS_INCLUDE = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include')
# Actual link closure for these metadata builders, including the unchanged
# generic comparison and real codec. No stub, GC-discarded validation, or
# arithmetic/controller/actor HLS closure is substituted for a missing symbol.
SOURCES = [Path(p) for p in [
    'hls/common/laya_numeric.cpp',
    'hls/common/laya_tasks.cpp',
    'hls/common/laya_memory_map.cpp',
    'hls/common/laya_full_memory.cpp',
    'hls/common/laya_full_owner.cpp',
    'hls/platform/generated_provenance_codec.cpp',
    'hls/platform/generated_provenance_events.cpp',
]]
CASES = ['matrix', 'owner-rejections', 'capacity', 'begin-rejections',
         'sequence', 'old-owner-model']
MODES = {
    'sequencer': ['-DLAYA_TRANSACTION_SEQUENCER_CODEC'],
    'wire': [],
}
SCOPE = (
    'Independent HOST equivalence of NORM-only metadata specialization with '
    'unchanged generic builders, complete independent LPV1 1024-byte gold, '
    'complete Check/detail/bad-element, request partial prefixes, persistent '
    'sequence and protected-task behavior. Two separately compiled modes: '
    'LAYA_TRANSACTION_SEQUENCER_CODEC and actual encode/decode wire validation. '
    'B1/B2, S1/S16/S64/S1024 and epochs7/41/max legal Ref. S1/S16 preserve '
    'generic E_BUFFER rejection; only S64/S1024 supply accepted ordinary NORM '
    'cases. Every batch rows16 window, supplemental rows1 tail subwindow, '
    'CLAIM/PUBLISH/INVALIDATE, capacity/presence/Ref/region/row-layout/context '
    'edges, UINT64 sequence saturation, complete owner NumericIdentity and '
    'opaque MODEL_IDENTITY propagation, EXCLUSIVE_RW old Ref. The old builders '
    'copy opaque model metadata and require upstream arithmetic/context checks '
    'in sequencer mode; this test preserves rather than strengthens that '
    'contract. Explicit synthetic metadata and non-dereferenced one-byte '
    'physical-presence sentinel, not model arithmetic gold or a payload buffer. '
    'No compiler, test or HLS success is assumed before execution. No HLS, RTL, '
    'physical debt, FIFO depth2, cycles, joint resources, full graph or rearm '
    'claim. Parent owns single-heavy-tool scheduling.')


def rec(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
            size += len(chunk)
    return {'path': str(path), 'bytes': size, 'sha256': digest.hexdigest()}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def launcher_state():
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    result = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
              'nice': os.getpriority(os.PRIO_PROCESS, 0),
              'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                      check=True, text=True, capture_output=True).stdout.strip(),
              'mem_available_kib': available,
              'minimum_mem_available_kib': 192 * 1024 * 1024}
    result['pass'] = (result['cpu_affinity'] == [0, 1, 2, 3] and
                      result['nice'] == 19 and result['ionice'].startswith('idle') and
                      available > result['minimum_mem_available_kib'])
    return result


def guarded(attempt, name, command, cwd, guard, short=False, artifact=None, marker=None):
    output = attempt / ('guard_' + name)
    if output.exists():
        raise RuntimeError('guard output exists: ' + str(output))
    args = [sys.executable, str(guard), '--out', str(output), '--cwd', str(cwd),
            '--rss-gib', '8' if short else '24', '--timeout-seconds',
            '120' if short else '1800', '--semantic-stall-seconds', '120']
    if artifact is not None:
        args += ['--artifact-progress-root', str(artifact)]
    args += ['--', *map(str, command)]
    completed = subprocess.run(args, cwd=cwd)
    result_path = output / 'guard_result.json'
    result = (json.loads(result_path.read_text()) if result_path.is_file() else
              {'child_exit_code': None, 'trigger': 'guard_result_missing'})
    log = output / 'driver.log'
    body = log.read_text(errors='replace') if log.is_file() else ''
    passed = (completed.returncode == 0 and result.get('child_exit_code') == 0 and
              result.get('trigger') is None and
              (marker is None or body.count(marker) == 1))
    return {'status': 'PASS' if passed else 'COST_STOP' if result.get('trigger') else 'FAIL',
            'started': True, 'command': args, 'runner_exit_code': completed.returncode,
            'guard': result, 'driver_log': rec(log) if log.is_file() else None,
            'markers': [line for line in body.splitlines() if marker and marker in line]}


def dependency_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    root = Path(spec['root']).resolve()
    project_paths, external_paths, commands = set(), set(), []
    for mode, definitions in spec['modes'].items():
        for index, unit in enumerate(spec['units']):
            command = [spec['compiler'], *spec['flags'], *definitions, '-M', str(root / unit)]
            commands.append({'mode': mode, 'command': command})
            body = subprocess.check_output(command, cwd=root, text=True)
            for name in body.replace('\\\n', ' ').split(':', 1)[1].split():
                path = Path(name).resolve()
                (project_paths if root in path.parents else external_paths).add(path)
            print(f'FULL_CURRENT_NORM_PROVENANCE_DEPENDENCY_PROGRESS mode={mode} '
                  f'units={index + 1}', flush=True)
    write_json(Path(spec['output']), {
        'files': [rec(p) for p in sorted(project_paths)],
        'external_files': [rec(p) for p in sorted(external_paths)],
        'commands': commands})
    print('FULL_CURRENT_NORM_PROVENANCE_DEPENDENCY_PASS', flush=True)


def build_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    output = Path(spec['objects'])
    output.mkdir(exist_ok=False)
    objects = []
    for index, unit in enumerate(spec['units']):
        obj = output / f'{index:02d}_{Path(unit).stem}.o'
        subprocess.run([spec['compiler'], *spec['flags'], '-c', unit,
                        '-o', str(obj)], cwd=spec['cwd'], check=True)
        objects.append(str(obj))
        print(f'FULL_CURRENT_NORM_PROVENANCE_BUILD_PROGRESS mode={spec["mode"]} '
              f'units={index + 1}', flush=True)
    subprocess.run([spec['compiler'], *objects, '-pthread', '-o', spec['binary']],
                   cwd=spec['cwd'], check=True)
    print('FULL_CURRENT_NORM_PROVENANCE_BUILD_PASS mode=' + spec['mode'], flush=True)


def verify_headers(items):
    for item in items:
        current = rec(item['path'])
        if current['sha256'] != item['sha256'] or current['bytes'] != item['bytes']:
            raise RuntimeError('installed compile header changed: ' + item['path'])


def verify_frozen_files(files):
    for item in files:
        frozen = rec(item['frozen']['path'])
        if frozen['sha256'] != item['original']['sha256'] or frozen['bytes'] != item['original']['bytes']:
            raise RuntimeError('frozen input changed: ' + item['relative'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path)
    parser.add_argument('--prepare-only', action='store_true',
                        help='freeze both dependency modes and compiler identity; do not build/run')
    parser.add_argument('--host-only', action='store_true',
                        help='explicit HOST-only alias; this runner never starts HLS')
    parser.add_argument('--dependency-worker', type=Path, help=argparse.SUPPRESS)
    parser.add_argument('--build-worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_worker:
        dependency_worker(args.dependency_worker)
        return 0
    if args.build_worker:
        build_worker(args.build_worker)
        return 0
    if not args.attempt:
        parser.error('--attempt is required')
    if args.prepare_only and args.host_only:
        parser.error('--prepare-only and --host-only cannot be combined')
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = launcher_state()
    write_json(attempt / 'launcher.json', launcher)
    receipt = {'schema': 'laya-norm-provenance-specialization-receipt-v1',
               'scope': SCOPE, 'status': 'PREPARING', 'operations': {},
               'hls': {'status': 'NOT_RUN', 'started': False},
               'arithmetic_payload': 'NOT_RUN', 'whole_production_chain': 'NOT_RUN',
               'rtl_depth2': 'NOT_RUN', 'close_rearm': 'NOT_RUN'}
    manifest = {'schema': 'laya-norm-provenance-specialization-input-v1',
                'scope': SCOPE, 'files': [], 'sources': [str(p) for p in SOURCES],
                'source_count': len(SOURCES), 'test': str(TEST), 'modes': MODES,
                'host_cases': CASES, 'host_cases_separate_processes': True,
                'synthetic_metadata': True, 'complete_wire_bytes': 1024,
                'independent_gold': 'literal C++ ABI fields and fixed physical NORM constants',
                'generic_output_is_gold': False, 'short_shapes_rejected': [1, 16],
                'hls_commands': [], 'launcher': rec(attempt / 'launcher.json'),
                'profile': {'cpu_ids': [0, 1, 2, 3], 'nice': 19, 'io_class': 'idle',
                            'minimum_mem_available_gib': 192, 'static_rss_gib': 24,
                            'static_seconds': 1800, 'semantic_stall_seconds': 120,
                            'host_rss_gib': 8, 'host_seconds': 120,
                            'one_heavy_tool_at_a_time': True}}
    manifest_path = attempt / 'input_manifest.json'

    def save():
        write_json(manifest_path, manifest)
        receipt['input_manifest'] = rec(manifest_path)
        write_json(attempt / 'receipt.json', receipt)

    save()
    if not launcher['pass']:
        receipt['status'] = 'FAIL_LAUNCHER'
        save()
        return 1
    try:
        compiler = Path(shutil.which('g++') or '/missing-g++').resolve()
        manifest['compiler'] = rec(compiler)
        frozen = attempt / 'frozen'

        def copy(source, relative, expected=None):
            source = Path(source).resolve()
            original = rec(source)
            if expected and (original['sha256'] != expected['sha256'] or
                             original['bytes'] != expected['bytes']):
                raise RuntimeError('dependency changed before freeze: ' + str(source))
            target = frozen / relative
            if target.exists():
                if rec(target)['sha256'] != original['sha256']:
                    raise RuntimeError('input changed during freeze: ' + str(source))
                return
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
            copied = rec(target)
            if copied['sha256'] != original['sha256']:
                raise RuntimeError('input changed while copied: ' + str(source))
            manifest['files'].append({'relative': str(relative),
                                      'original': original, 'frozen': copied})

        runner = Path(__file__).resolve().relative_to(ROOT)
        fixed = SOURCES + [TEST, runner,
            Path('include/laya_generated_provenance_events.h'),
            Path('config/task_lifecycle_fsm_sources.cmake'),
            Path('config/production_hls_partitions.json'),
            Path('config/full_module_registry.json'),
            MODEL / 'laya_model_layout_generated.h', MODEL / 'manifest.json',
            MODULE / 'tb/production_guard.py', Path('tools/hls_guard_helpers.py')]
        for relative in sorted(set(fixed)):
            copy(ROOT / relative, relative)
        for name in ['production_hls_partition_contract_20261012.md',
                     'executor_minimum_hardware_chain_reply_20261013.md',
                     'executor_first_hls_cost_stop_reply_20261013.md']:
            copy(PROJECT / 'results' / name, Path('external/contracts') / name)
        guard = frozen / MODULE / 'tb/production_guard.py'
        # No DUT preprocessing/build is done outside the production guard.
        live_flags = ['-std=c++17', '-I' + str(ROOT / 'include'),
                      '-I' + str(ROOT / 'hls'), '-I' + str(ROOT / 'hls/platform'),
                      '-I' + str(ROOT / MODEL), '-isystem', str(VITIS_INCLUDE)]
        dep_spec = attempt / 'dependency_spec.json'
        dep_output = attempt / 'dependencies.json'
        write_json(dep_spec, {'root': str(ROOT), 'compiler': str(compiler),
                             'units': [str(p) for p in SOURCES + [TEST]],
                             'flags': live_flags, 'modes': MODES,
                             'output': str(dep_output)})
        manifest['dependency_spec'] = rec(dep_spec)
        command = [sys.executable, str(frozen / runner), '--dependency-worker', str(dep_spec)]
        result = guarded(attempt, 'dependencies', command, ROOT, guard,
                         marker='FULL_CURRENT_NORM_PROVENANCE_DEPENDENCY_PASS')
        receipt['operations']['dependencies'] = result
        save()
        if result['status'] != 'PASS':
            receipt['status'] = result['status']
            save()
            return 1
        dependencies = json.loads(dep_output.read_text())
        for item in dependencies['files']:
            path = Path(item['path'])
            copy(path, path.relative_to(ROOT), item)
        for item in dependencies['external_files']:
            path = Path(item['path'])
            copy(path, Path('external/header_inputs') / path.relative_to('/'), item)
        manifest['dependencies'] = rec(dep_output)
        manifest['external_header_closure'] = dependencies['external_files']
        manifest['external_header_closure_frozen'] = True
        manifest['frozen_project_closure_complete'] = True
        # g++ still uses installed system/Vitis include locations. Retain their
        # complete frozen copies and reject drift; do not claim a portable
        # independent toolchain made from those archival header copies.
        verify_headers(dependencies['external_files'])
        result = guarded(attempt, 'compiler_version', [str(compiler), '--version'],
                         frozen, guard, short=True)
        receipt['operations']['compiler_version'] = result
        if result['status'] != 'PASS':
            receipt['status'] = 'FAIL_COMPILER_IDENTITY'
            save()
            return 1
        manifest['compiler_version_log'] = result['driver_log']
        includes = ['-I' + str(frozen / 'include'), '-I' + str(frozen / 'hls'),
                    '-I' + str(frozen / 'hls/platform'), '-I' + str(frozen / MODEL)]
        common_flags = ['-std=c++17', '-O1', '-Wall', '-Wextra', '-Werror',
                        '-Wno-unknown-pragmas', '-Wno-unused-parameter',
                        '-Wno-aggressive-loop-optimizations', '-fno-fast-math',
                        '-fno-associative-math', '-ffp-contract=off',
                        *includes, '-isystem', str(VITIS_INCLUDE), '-pthread']
        specs, planned = {}, {}
        for mode, definitions in MODES.items():
            binary = attempt / ('norm_provenance_' + mode + '_test')
            spec = attempt / ('host_build_' + mode + '_spec.json')
            write_json(spec, {'cwd': str(frozen), 'compiler': str(compiler),
                             'mode': mode, 'flags': common_flags + definitions,
                             'units': [str(frozen / p) for p in SOURCES + [TEST]],
                             'objects': str(attempt / ('host_objects_' + mode)),
                             'binary': str(binary)})
            specs[mode] = rec(spec)
            planned[mode] = {
                'build': [sys.executable, str(frozen / runner), '--build-worker', str(spec)],
                'host': [[str(binary), case] for case in CASES]}
        manifest['host_build_specs'] = specs
        manifest['planned_commands'] = planned
        receipt['status'] = 'PREPARED'
        save()
        if args.prepare_only:
            print('FULL_CURRENT_NORM_PROVENANCE_SPECIALIZATION_PREPARED', flush=True)
            return 0
        for mode in MODES:
            verify_headers(dependencies['external_files'])
            verify_frozen_files(manifest['files'])
            if rec(compiler)['sha256'] != manifest['compiler']['sha256']:
                raise RuntimeError('compiler changed after identity capture')
            build = guarded(attempt, 'host_build_' + mode, planned[mode]['build'],
                            attempt, guard, artifact=attempt / ('host_objects_' + mode),
                            marker='FULL_CURRENT_NORM_PROVENANCE_BUILD_PASS mode=' + mode)
            receipt['operations']['host_build_' + mode] = build
            save()
            if build['status'] != 'PASS':
                receipt['status'] = build['status']
                save()
                return 1
            binary = attempt / ('norm_provenance_' + mode + '_test')
            receipt.setdefault('executables', {})[mode] = rec(binary)
            for case, command in zip(CASES, planned[mode]['host']):
                result = guarded(attempt, 'host_' + mode + '_' + case,
                                 command, frozen, guard, short=True,
                                 marker='FULL_CURRENT_NORM_PROVENANCE_SPECIALIZATION_PASS '
                                        'case=' + case + ' mode=' + mode)
                receipt['operations']['host_' + mode + '_' + case] = result
                save()
                if result['status'] != 'PASS':
                    receipt['status'] = result['status']
                    save()
                    return 1
            verify_headers(dependencies['external_files'])
            verify_frozen_files(manifest['files'])
        receipt['status'] = 'PASS_SCOPED_HOST'
        save()
        print('FULL_CURRENT_NORM_PROVENANCE_SPECIALIZATION_PASS_SCOPED_HOST '
              'modes=2 cases=12 HLS=NOT_RUN', flush=True)
        return 0
    except Exception as error:
        receipt['status'] = 'FAIL_RUNNER'
        receipt['error'] = str(error)
        save()
        raise


if __name__ == '__main__':
    raise SystemExit(main())
