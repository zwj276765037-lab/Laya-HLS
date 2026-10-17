#!/usr/bin/env python3
"""Freeze and guard the FIRST-only owned graph program host/HLS candidate."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
SOURCE_LIST = Path('config/graph_program_owned_sources.cmake')
BASE_LIST = Path('config/graph_program_sources.cmake')
TEST = Path('tests/graph_program_owned_test.cpp')
TOP = 'laya_graph_program_owned_sequencer'
VITIS = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++')
VITIS_INCLUDE = VITIS.parents[1] / 'include'
DEFINES = ['-DLAYA_PARTITIONED_PRODUCTION_CALLER',
           '-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER',
           '-DLAYA_TRANSACTION_SEQUENCER_CODEC', '-DAP_INT_MAX_W=8192']
CASES = ['success', 'bad-owner-kind', 'bad-owner-reserved',
         'cancel-before-command', 'cancel-command-prefix', 'cancel-allocated',
         'wrong-command-identity', 'wrong-command-source', 'stale-completion']
FIFOS = {
    'program_owner': (False, 8192),
    'program_owner_receipt': (True, 8192),
    'program_pending': (True, 8192),
    'accepted_command': (False, 512),
    'request_result': (True, 512),
    'action_request': (True, 512),
    'action_completion': (False, 512),
    'action_completion_receipt': (True, 512),
}
SCALARS = {'cancel': ('input', 1), 'result_consumed': ('input', 1),
           'isolated': ('output', 1)}
SCOPE = ('FIRST-only owned graph program candidate. Complete literal GRANTED is '
         'installed and echoed unchanged; complete LGP1 must match that owner before '
         'the sole program allocator chooses an action. Literal LAP1 proves the actual '
         'pending action; a trusted complete bound LAC1 is echoed in four receipt beats '
         'before LGR1. Nine independent host processes exercise owner kind/reserved '
         'rejection, persistent cancel before command read or after two command beats, '
         'cancel after allocation, foreign command identity/source, stale completion, '
         'successful slot commit and no second owner/command. Tail2/tail1 waits are '
         '12 software calls with unbounded software streams, not hardware cycles or '
         'depth2 evidence. Input GRANTED/LGP/LAP and LAC terminals are controlled '
         'independent fixtures; result_consumed is a host notification, not an actual '
         'executor consumer. Fourteen-source HLS has eight FIFOs (3x8192 and 5x512), '
         'three scalar controls and no AXI. No whole production wrapper, actual '
         'RTL backpressure, real LN/Q service/numerics/cycles, CLOSE/rearm, complete '
         'graph, joint resources, physical timing or board PASS.')


def sources_from_config():
    top = (ROOT / SOURCE_LIST).read_text()
    base = (ROOT / BASE_LIST).read_text()
    include = 'include(${CMAKE_CURRENT_LIST_DIR}/graph_program_sources.cmake)'
    if top.count(include) != 1 or top.count('${LAYA_GRAPH_PROGRAM_SOURCES}') != 1:
        raise RuntimeError('owned program nested source-list contract changed')
    paths = [Path(p) for p in re.findall(r'^\s*(hls/[^\s]+\.cpp)\s*$', base, re.M)]
    paths += [Path(p) for p in re.findall(r'^\s*(hls/[^\s]+\.cpp)\s*$', top, re.M)]
    required = {
        'laya_numeric.cpp', 'laya_tasks.cpp', 'graph_action_protocol.cpp',
        'graph_program_protocol.cpp', 'program_pending_protocol.cpp',
        'graph_program_sequencer.cpp', 'graph_program_hls.cpp',
        'executor_handoff_protocol.cpp', 'executor_checkpoint_protocol.cpp',
        'bootstrap_snapshot_protocol.cpp', 'laya_memory_map.cpp',
        'compute_portal_client.cpp', 'laya_full_memory.cpp',
        'graph_program_owned.cpp',
    }
    forbidden = {'full_forward_controller.cpp', 'task_lifecycle_fsm.cpp',
        'task_lifecycle_executor.cpp', 'executor_actor.cpp', 'executor_hls.cpp',
        'controller_transaction_adapter.cpp', 'controller_transaction_dispatch.cpp',
        'controller_transaction_hls.cpp', 'compute_portal_codec.cpp',
        'generated_provenance_codec.cpp', 'producer_engine_codec.cpp'}
    names = {p.name for p in paths}
    if (len(paths) != len(required) or len(set(paths)) != len(required) or names != required or
            names & forbidden or paths[-1] != Path('hls/control/graph_program_owned.cpp')):
        raise RuntimeError('owned program actual model-binding source closure rejected')
    return paths


def rec(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    count = 0
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(data)
            count += len(data)
    return {'path': str(path), 'bytes': count, 'sha256': digest.hexdigest()}



def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')



def launcher_state():
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    state = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
             'nice': os.getpriority(os.PRIO_PROCESS, 0),
             'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                      check=True, text=True,
                                      capture_output=True).stdout.strip(),
             'mem_available_kib': available,
             'required_mem_available_kib': 192 * 1024 * 1024}
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and state['nice'] == 19
                     and state['ionice'].startswith('idle') and
                     available > state['required_mem_available_kib'])
    return state



def guarded(attempt, name, command, cwd, guard, pilot=False, artifact=None, marker=None):
    output = attempt / ('guard_' + name)
    if output.exists():
        raise RuntimeError('guard output would overwrite an earlier operation')
    args = [sys.executable, str(guard), '--out', str(output), '--cwd', str(cwd),
            '--rss-gib', '8' if pilot else '24', '--timeout-seconds',
            '120' if pilot else '1800', '--semantic-stall-seconds', '120']
    if artifact is not None:
        args += ['--artifact-progress-root', str(artifact)]
    args += ['--', *map(str, command)]
    completed = subprocess.run(args, cwd=cwd)
    result_path = output / 'guard_result.json'
    result = (json.loads(result_path.read_text()) if result_path.is_file() else
              {'child_exit_code': None, 'trigger': 'guard_result_missing'})
    log = output / 'driver.log'
    body = log.read_text(errors='replace') if log.is_file() else ''
    passed = (completed.returncode == 0 and result.get('child_exit_code') == 0
              and result.get('trigger') is None and
              (marker is None or body.count(marker) == 1))
    return {'status': 'PASS' if passed else 'COST_STOP' if result.get('trigger') else 'FAIL',
            'started': True, 'command': args, 'runner_exit_code': completed.returncode,
            'guard': result, 'driver_log': rec(log) if log.is_file() else None,
            'markers': [line for line in body.splitlines() if marker and marker in line]}



def dependency_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    root = Path(spec['root']).resolve()
    closure = set()
    external = set()
    commands = []
    for i, unit in enumerate(spec['units']):
        command = [spec['compiler'], *spec['flags'], '-M', str(root / unit)]
        commands.append(command)
        dependency = subprocess.check_output(command, cwd=root, text=True)
        # One translation unit per command means exactly one make target.
        for name in dependency.replace('\\\n', ' ').split(':', 1)[1].split():
            path = Path(name).resolve()
            if root in path.parents:
                closure.add(path)
            else:
                external.add(path)
        print(f'FULL_CURRENT_GRAPH_PROGRAM_OWNED_DEPENDENCY_PROGRESS units={i+1}', flush=True)
    write_json(Path(spec['output']), {'files': [rec(p) for p in sorted(closure)],
                                    'external_files': [rec(p) for p in sorted(external)],
                                    'commands': commands})
    print('FULL_CURRENT_GRAPH_PROGRAM_OWNED_DEPENDENCY_PASS', flush=True)



def build_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    objects = []
    output = Path(spec['objects']); output.mkdir(exist_ok=False)
    for i, unit in enumerate(spec['units']):
        obj = output / f'{i:02d}_{Path(unit).stem}.o'
        subprocess.run([spec['compiler'], *spec['flags'], '-c', unit,
                        '-o', str(obj)], cwd=spec['cwd'], check=True)
        objects.append(str(obj))
        print(f'FULL_CURRENT_GRAPH_PROGRAM_OWNED_BUILD_PROGRESS units={i+1}', flush=True)
    subprocess.run([spec['compiler'], *objects, '-pthread', '-o', spec['binary']],
                   cwd=spec['cwd'], check=True)
    print('FULL_CURRENT_GRAPH_PROGRAM_OWNED_BUILD_PASS', flush=True)



def declarations(path):
    body = path.read_text(errors='replace')
    module = re.search(r'\bmodule\s+' + re.escape(TOP) + r'\s*\((.*?)\);', body, re.S)
    if module is None:
        raise RuntimeError('generated owned program module absent')
    names = set(re.findall(r'\b[A-Za-z_]\w*\b', module.group(1)))
    result = {}
    for match in re.finditer(r'\b(input|output|inout)\s+(?:(?:wire|reg|logic)\s+)?'
                             r'(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'
                             r'([A-Za-z_]\w*)\s*;', body):
        direction, hi, lo, name = match.groups()
        if name in names:
            result[name] = {'direction': direction,
                            'width': abs(int(hi)-int(lo))+1 if hi else 1}
    return names, result



def resource_evidence(work):
    reports = []
    for path in sorted(work.glob('**/syn/report/*_csynth.xml')):
        try:
            tree = ET.parse(path)
            used = tree.find('.//AreaEstimates/Resources')
            reports.append({'file': rec(path), 'module': path.stem.replace('_csynth', ''),
                            'estimated_resources': {child.tag: child.text for child in used}
                            if used is not None else None,
                            'kind': 'module_HLS_estimate_only'})
        except ET.ParseError:
            reports.append({'file': rec(path), 'parse_error': True})
    return {'modules': reports, 'joint_resource_total': None,
            'physical_timing': 'NOT_RUN', 'board': 'NOT_RUN'}



def port_evidence(path):
    names, ports = declarations(path)
    def match(base, direction, width):
        # Vitis versions may place the ap_uint V suffix before or after
        # the FIFO signal suffix; more than one alias is an ambiguity.
        candidates = [base, base + '_V']
        signal = re.fullmatch(r'(.*)_(din|dout|full_n|empty_n|write|read)', base)
        if signal:
            candidates.append(signal[1] + '_V_' + signal[2])
        actual = [name for name in candidates if name in names]
        valid = len(actual) == 1 and ports.get(actual[0]) == {
            'direction': direction, 'width': width}
        return {'pass': valid, 'actual': actual,
                'expected_direction': direction, 'expected_width': width}
    fifos = {}
    expected_names = set()
    for name, (outgoing, width) in FIFOS.items():
        suffixes = [('din', 'output', width), ('full_n', 'input', 1),
                    ('write', 'output', 1)] if outgoing else [
                        ('dout', 'input', width), ('empty_n', 'input', 1),
                        ('read', 'output', 1)]
        fifos[name] = {}
        for suffix, direction, width in suffixes:
            evidence = match(name + '_' + suffix, direction, width)
            fifos[name][suffix] = evidence
            expected_names.update(evidence['actual'])
    scalars = {name: match(name, *expected) for name, expected in SCALARS.items()}
    forbidden = {name: name in names for name in
                 ('ap_start', 'ap_done', 'ap_idle', 'ap_ready')}
    axi = sorted(name for name in names if re.match(r'[ms]_axi_', name, re.I))
    extra = sorted(name for name in names
                   if re.search(r'_(?:din|dout|empty_n|full_n|read|write)(?:_V)?$', name)
                   and name not in expected_names)
    count = sum(item['pass'] for fifo in fifos.values() for item in fifo.values())
    clock = match('ap_clk', 'input', 1)
    resets = [name for name in ('ap_rst', 'ap_rst_n') if name in names]
    reset_ok = len(resets) == 1 and match(resets[0], 'input', 1)['pass']
    passed = (count == 24 and all(item['pass'] for item in scalars.values())
              and clock['pass'] and reset_ok
              and not any(forbidden.values()) and not axi and not extra)
    return {'pass': passed, 'generated': rec(path), 'fifo_count': 8,
            'fifo_width_counts': {'8192': 3, '512': 5},
            'fifo_signal_count': count, 'fifos': fifos, 'scalars': scalars,
            'axi_signals': axi, 'forbidden_control': forbidden,
            'clock': clock, 'reset_names': resets, 'reset_pass': reset_ok,
            'unexpected_fifo_signals': extra, 'declared_top_ports': sorted(names),
            'declarations': ports}



def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--prepare-only', action='store_true')
    mode.add_argument('--host-only', action='store_true')
    parser.add_argument('--dependency-worker', type=Path, help=argparse.SUPPRESS)
    parser.add_argument('--build-worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_worker:
        dependency_worker(args.dependency_worker); return 0
    if args.build_worker:
        build_worker(args.build_worker); return 0
    if not args.attempt:
        parser.error('--attempt is required')
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = launcher_state()
    write_json(attempt / 'launcher.json', launcher)
    receipt = {'schema': 'laya-graph-program-owned-receipt-v1', 'scope': SCOPE,
               'status': 'PREPARING', 'operations': {},
               'hls': {'status': 'NOT_RUN', 'started': False},
               'whole_production_chain': 'NOT_RUN', 'rtl_depth2': 'NOT_RUN',
               'close_rearm': 'NOT_RUN'}
    manifest = {'schema': 'laya-graph-program-owned-input-v1', 'scope': SCOPE,
                'top': TOP, 'files': [], 'launcher': rec(attempt / 'launcher.json'),
                'profile': {'cpu_ids': [0, 1, 2, 3], 'nice': 19, 'io_class': 'idle',
                            'minimum_mem_available_gib': 192,
                            'static_rss_gib': 24, 'static_seconds': 1800,
                            'semantic_stall_seconds': 120,
                            'host_rss_gib': 8, 'host_seconds': 120,
                            'one_heavy_tool_at_a_time': True},
                'defines': DEFINES, 'host_cases': CASES,
                'host_cases_separate_processes': True,
                'software_streams_bounded': False}
    manifest_path = attempt / 'input_manifest.json'
    def save():
        write_json(manifest_path, manifest)
        receipt['input_manifest'] = rec(manifest_path)
        write_json(attempt / 'receipt.json', receipt)
    save()
    if not launcher['pass']:
        receipt['status'] = 'FAIL_LAUNCHER'; save(); return 1
    try:
        sources = sources_from_config()
        compiler = Path(shutil.which('g++') or '/missing-g++').resolve()
        manifest['compiler'] = rec(compiler)
        manifest['tool'] = {'executable': rec(VITIS),
                            'external_headers': [rec(VITIS_INCLUDE / 'ap_int.h'),
                                                 rec(VITIS_INCLUDE / 'hls_stream.h')]}
        manifest['sources'] = [str(p) for p in sources]
        manifest['source_count'] = len(sources)
        manifest['forbidden_sources'] = []
        frozen = attempt / 'frozen'
        def copy(source, relative, expected=None):
            source = Path(source).resolve(); target = frozen / relative
            original = rec(source)
            if expected and original['sha256'] != expected['sha256']:
                raise RuntimeError('input changed after dependency extraction: ' + str(source))
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
        fixed = sources + [TEST, SOURCE_LIST, BASE_LIST, runner,
            Path('include/laya_graph_program_owned.h'),
            Path('config/production_hls_partitions.json'),
            Path('config/full_module_registry.json'), Path('config/graph_action_registry.json'),
            MODEL / 'laya_model_layout_generated.h', MODEL / 'manifest.json', MODEL / 'aux.bin',
            Path('tests/executor_handoff_fixture.py'), Path('tests/executor_checkpoint_fixture.py'),
            Path('tests/executor_bootstrap_fixture.py'), Path('tests/admission_owner_fixture.py'),
            Path('tests/program_pending_fixture.py'), MODULE / 'tb/production_guard.py',
            Path('tools/hls_guard_helpers.py'), MODULE / 'rtl/laya_executor_handoff_layout_v1.sv',
            MODULE / 'rtl/laya_executor_checkpoint_layout_v2.sv',
            MODULE / 'rtl/laya_model_identity_13bo_generated_v1.sv',
            MODULE / 'rtl/laya_program_pending_layout_v1.sv',
            MODULE / 'rtl/laya_graph_action_layout_v1.sv', MODULE / 'rtl/laya_graph_program_layout_v1.sv']
        for relative in sorted(set(fixed)):
            copy(ROOT / relative, relative)
        for name in ['production_hls_partition_contract_20261012.md',
                     'executor_checkpoint_import_handshake_contract_20261013.md',
                     'executor_minimum_hardware_chain_reply_20261013.md']:
            copy(PROJECT / 'results' / name, Path('external/contracts') / name)
        guard = frozen / MODULE / 'tb/production_guard.py'
        live_flags = ['-std=c++17', *DEFINES, '-I' + str(ROOT / 'include'),
                      '-I' + str(ROOT / 'hls'), '-I' + str(ROOT / 'hls/platform'),
                      '-I' + str(ROOT / MODEL), '-isystem', str(VITIS_INCLUDE)]
        dep_spec = attempt / 'dependency_spec.json'
        dep_output = attempt / 'dependencies.json'
        write_json(dep_spec, {'root': str(ROOT), 'compiler': str(compiler),
            'units': [str(p) for p in sources + [TEST]], 'flags': live_flags,
            'output': str(dep_output)})
        dependency = guarded(attempt, 'dependencies',
            [sys.executable, str(frozen / runner), '--dependency-worker', str(dep_spec)],
            ROOT, guard, marker='FULL_CURRENT_GRAPH_PROGRAM_OWNED_DEPENDENCY_PASS')
        receipt['operations']['dependencies'] = dependency
        manifest['dependency_spec'] = rec(dep_spec)
        if dependency['status'] != 'PASS':
            receipt['status'] = dependency['status']; save(); return 1
        dependencies = json.loads(dep_output.read_text())
        for item in dependencies['files']:
            path = Path(item['path']); copy(path, path.relative_to(ROOT), item)
        for item in dependencies['external_files']:
            path = Path(item['path'])
            copy(path, Path('external/header_inputs') / path.relative_to('/'), item)
        manifest['dependencies'] = rec(dep_output)
        manifest['external_header_closure'] = dependencies['external_files']
        manifest['external_header_closure_frozen'] = True
        def verify_external_headers():
            # The installed compiler still uses its native standard/Vitis
            # include paths. Retain copies and reject any identity drift.
            for item in dependencies['external_files']:
                if rec(item['path'])['sha256'] != item['sha256']:
                    raise RuntimeError('external compile header changed: ' + item['path'])
        includes = ['-I' + str(frozen / 'include'), '-I' + str(frozen / 'hls'),
                    '-I' + str(frozen / 'hls/platform'), '-I' + str(frozen / MODEL)]
        flags = ['-std=c++17', '-O1', '-Wall', '-Wextra', '-Werror',
                 '-Wno-unknown-pragmas', '-Wno-unused-parameter',
                 '-Wno-aggressive-loop-optimizations', '-fno-fast-math',
                 '-fno-associative-math', '-ffp-contract=off', *DEFINES,
                 *includes, '-isystem', str(VITIS_INCLUDE), '-pthread']
        binary = attempt / 'graph_program_owned_test'
        build_spec = attempt / 'host_build_spec.json'
        write_json(build_spec, {'cwd': str(frozen), 'compiler': str(compiler),
            'flags': flags, 'units': [str(frozen / p) for p in sources + [TEST]],
            'objects': str(attempt / 'host_objects'), 'binary': str(binary)})
        manifest['host_build_spec'] = rec(build_spec)
        config = attempt / 'graph_program_owned.cfg'
        lines = ['part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
                 'flow_target=vivado', f'syn.top={TOP}', 'syn.compile.pipeline_loops=0',
                 'syn.array_partition.throughput_driven=off',
                 'syn.array_partition.complete_threshold=0']
        lines += [f'syn.file={frozen / p}' for p in sources]
        lines.append('syn.cflags=' + ' '.join([*DEFINES, *includes, '-std=c++17',
            '-fno-fast-math', '-fno-associative-math', '-ffp-contract=off']))
        config.write_text('\n'.join(lines) + '\n')
        manifest['derived_config'] = rec(config)
        fixture = attempt / 'fixture'
        oracle = [sys.executable, str(frozen / 'tests/executor_handoff_fixture.py'),
                  '--model-header', str(frozen / MODEL / 'laya_model_layout_generated.h'),
                  '--model-aux', str(frozen / MODEL / 'aux.bin'), '--output', str(fixture)]
        build = [sys.executable, str(frozen / runner), '--build-worker', str(build_spec)]
        hls = [str(VITIS), '--compile', '--mode', 'hls', '--config', str(config),
               '--work_dir', str(attempt / 'work')]
        manifest['planned_commands'] = {'oracle': oracle, 'build': build,
            'host': [[str(binary), str(fixture), case] for case in CASES], 'hls': hls}
        manifest['frozen_project_closure_complete'] = True
        save()
        for name, command in [('tool_version', [str(VITIS), '--version']),
                              ('compiler_version', [str(compiler), '--version'])]:
            version = guarded(attempt, name, command, frozen, guard, pilot=True)
            receipt['operations'][name] = version
            if version['status'] != 'PASS':
                receipt['status'] = 'FAIL_TOOL_IDENTITY'; save(); return 1
            manifest[name + '_log'] = version['driver_log']
        receipt['status'] = 'PREPARED'; save()
        if args.prepare_only:
            print('FULL_CURRENT_GRAPH_PROGRAM_OWNED_PREPARED', flush=True); return 0
        result = guarded(attempt, 'oracle', oracle, frozen, guard, pilot=True,
                         marker='FULL_CURRENT_EXECUTOR_HANDOFF_FIXTURE_PASS')
        receipt['operations']['oracle'] = result
        receipt['fixture_files'] = [rec(p) for p in sorted(fixture.rglob('*')) if p.is_file()]
        save()
        if result['status'] != 'PASS':
            receipt['status'] = result['status']; save(); return 1
        result = guarded(attempt, 'host_build', build, attempt, guard,
                         artifact=attempt / 'host_objects',
                         marker='FULL_CURRENT_GRAPH_PROGRAM_OWNED_BUILD_PASS')
        receipt['operations']['host_build'] = result; save()
        if result['status'] != 'PASS':
            receipt['status'] = result['status']; save(); return 1
        verify_external_headers()
        receipt['executable'] = rec(binary)
        for case in CASES:
            result = guarded(attempt, 'host_' + case,
                [str(binary), str(fixture), case], frozen, guard, pilot=True,
                marker='FULL_CURRENT_GRAPH_PROGRAM_OWNED_TOP_PASS case=' + case)
            receipt['operations']['host_' + case] = result; save()
            if result['status'] != 'PASS':
                receipt['status'] = result['status']; save(); return 1
        receipt['status'] = 'PASS_SCOPED_HOST'; save()
        if args.host_only:
            print('FULL_CURRENT_GRAPH_PROGRAM_OWNED_PASS_SCOPED_HOST', flush=True); return 0
        verify_external_headers()
        receipt['hls'] = guarded(attempt, 'hls', hls, attempt, guard,
                                 artifact=attempt / 'work')
        verify_external_headers()
        candidates = sorted((attempt / 'work').glob(f'**/syn/verilog/{TOP}.v'))
        receipt['generated_candidates'] = [str(path) for path in candidates]
        ports = None
        if len(candidates) == 1:
            generated = attempt / (TOP + '.v')
            shutil.copyfile(candidates[0], generated)
            ports = port_evidence(generated)
        receipt['port_evidence'] = ports
        receipt['resource_evidence'] = resource_evidence(attempt / 'work')
        receipt['generated_artifacts'] = [rec(p) for p in sorted((attempt / 'work').rglob('*'))
                                           if p.is_file()]
        receipt['status'] = ('PASS_SCOPED_GENERATION' if receipt['hls']['status'] == 'PASS'
                            and ports and ports['pass'] else receipt['hls']['status']
                            if receipt['hls']['status'] != 'PASS' else 'FAIL_PORTS')
        save(); print('FULL_CURRENT_GRAPH_PROGRAM_OWNED_' + receipt['status'], flush=True)
        return 0 if receipt['status'] == 'PASS_SCOPED_GENERATION' else 1
    except Exception as error:
        receipt['status'] = 'FAIL_RUNNER'; receipt['error'] = str(error); save(); raise


if __name__ == '__main__':
    raise SystemExit(main())
