#!/usr/bin/env python3
"""Generate the real managed adapter, reusing only an identical managed host closure."""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
RUNNER = MODULE / 'tb/run_controller_transaction_adapter_managed_hls.py'
SOURCE_LIST = Path('config/controller_adapter_sources.cmake')
SOURCES = [Path(p) for p in (
    'hls/common/laya_numeric.cpp', 'hls/common/laya_tasks.cpp',
    'hls/platform/compute_portal_codec.cpp',
    'hls/platform/generated_provenance_codec.cpp',
    'hls/platform/producer_engine_codec.cpp',
    'hls/platform/controller_transaction_codec.cpp',
    'hls/platform/controller_transaction_adapter.cpp')]
TOP = 'laya_command_provenance_adapter'
VITIS = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++')
VITIS_INCLUDE = VITIS.parents[1] / 'include'
DEFINE = '-DLAYA_MANAGED_TRANSACTION_ADAPTER=1'
HOST_MARKER = 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_PASS'
ISOLATION_MARKER = 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_ISOLATION_PASS'
ISOLATION_MODES = ('bad_magic', 'bad_tail')
DEP_MARKER = 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_HLS_DEPENDENCIES_PASS'
PROFILE = {'one_heavy_tool_at_a_time': True, 'maximum_seconds': 1800,
           'maximum_rss_gib': 24, 'semantic_stall_seconds': 120,
           'cpu_affinity': [0, 1, 2, 3], 'nice': 19, 'io_class': 'idle',
           'minimum_mem_available_gib_strictly_greater_than': 192}
SCOPE = (
    'Actual seven-source controller_transaction_adapter.cpp HLS candidate with '
    'LAYA_MANAGED_TRANSACTION_ADAPTER=1. Reuse only the exact managed-host frozen '
    'source/test, complete recorded transitive dependency, compiler, fixture, '
    'capture and guarded-operation identities; host is NOT_RUN in this attempt. '
    'Managed cancel is transaction-local sticky before first external presentation; '
    'only PROVENANCE+CANCEL_CLEANUP+END/INVALIDATE can use the cleanup path. '
    'Complete ordinary unpresented frames use the real LOCAL_REJECT/LTC path. '
    'Full-codec-invalid unknown input remains isolated with no completion or next-frame '
    'consumption. Reuse requires both fresh independent bad-magic/bad-tail processes '
    'and their complete fixed-byte/zero-output/FIFO-observation evidence. '
    'Generation requires exactly eight 512-bit FIFO triplets and ap_clk/ap_rst/cancel, '
    'with directions and widths checked in this actual top module only, no AXI or '
    'top ap_ctrl_hs. Legacy HLS03 FAIL is retained and its separate corrected port '
    'audit is a reference only. No bounded RTL execution/backpressure, attempted '
    'unaccepted first write, immutable wrapper A/K/pending collector, actual caller '
    '16th LTC pop/F10, hub permission/physical closure/unique retirement, full '
    'production chain, combined resources, implementation timing or board claim.')


def rec(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
            size += len(chunk)
    return {'path': str(path), 'bytes': size, 'sha256': digest.hexdigest()}


def verify(path, expected):
    value = rec(path)
    if any(value[k] != expected[k] for k in ('bytes', 'sha256')):
        raise RuntimeError('identity drift: ' + str(path))
    return value


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def source_list(root):
    found = [Path(p) for p in re.findall(
        r'^\s*(hls/[^\s]+\.cpp)\s*$', (root / SOURCE_LIST).read_text(), re.M)]
    if found != SOURCES:
        raise RuntimeError('exact original seven-source adapter closure changed')
    return found


def launcher_state():
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    state = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
             'nice': os.getpriority(os.PRIO_PROCESS, 0),
             'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                      check=True, capture_output=True,
                                      text=True).stdout.strip(),
             'mem_available_kib': available,
             'required_mem_available_kib': 192 * 1024 * 1024}
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and state['nice'] == 19
                     and state['ionice'].startswith('idle')
                     and available > state['required_mem_available_kib'])
    return state


def expected_ports():
    ports = {name: {'direction': 'input', 'width': 1}
             for name in ('ap_clk', 'ap_rst', 'cancel')}
    for name in ('transaction_completion', 'compute_command',
                 'provenance_command', 'producer_request'):
        for suffix, direction, width in [('din', 'output', 512),
                                         ('full_n', 'input', 1),
                                         ('write', 'output', 1)]:
            ports[name + '_' + suffix] = {'direction': direction, 'width': width}
    for name in ('transaction_request', 'compute_response',
                 'provenance_response', 'producer_completion'):
        for suffix, direction, width in [('dout', 'input', 512),
                                         ('empty_n', 'input', 1),
                                         ('read', 'output', 1)]:
            ports[name + '_' + suffix] = {'direction': direction, 'width': width}
    return ports


def port_evidence(path):
    """The audited HLS03 uses these exact non-ANSI names, with no _V aliases."""
    body = re.sub(r'/\*.*?\*/|//[^\n]*', '', path.read_text(errors='replace'), flags=re.S)
    modules = list(re.finditer(r'\bmodule\s+' + re.escape(TOP) +
                               r'\s*\((.*?)\);(.*?)\bendmodule\b', body, re.S))
    if len(modules) != 1:
        raise RuntimeError('exactly one non-ANSI actual adapter top required')
    header, module_body = modules[0].groups()
    names = [p.strip() for p in header.split(',')]
    if (any(re.fullmatch(r'[A-Za-z_]\w*', p) is None for p in names)
            or len(names) != len(set(names))):
        raise RuntimeError('ambiguous or duplicate actual top ports')
    declarations = {}
    for direction, statement in re.findall(
            r'^\s*(input|output|inout)\s+([^;]+);', module_body, re.M):
        match = re.fullmatch(r'(?:(?:wire|reg|logic)\s+)?'
                             r'(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'
                             r'([A-Za-z_]\w*)\s*', statement)
        if match is None:
            raise RuntimeError('unsupported actual top port declaration: ' + statement)
        hi, lo, name = match.groups()
        if name in declarations:
            raise RuntimeError('duplicate actual top declaration: ' + name)
        declarations[name] = {'direction': direction,
                              'width': abs(int(hi) - int(lo)) + 1 if hi else 1}
    expected = expected_ports()
    mismatches = {name: {'expected': wanted, 'actual': declarations.get(name)}
                  for name, wanted in expected.items() if declarations.get(name) != wanted}
    extra = sorted(set(names) - set(expected))
    undeclared = sorted(set(names) - set(declarations))
    declaration_only = sorted(set(declarations) - set(names))
    passed = (len(names) == 27 and len(declarations) == 27 and
              set(names) == set(expected) and not mismatches and not extra and
              not undeclared and not declaration_only)
    return {'generated': rec(path), 'status': 'PASS' if passed else 'FAIL_PORTS',
            'strict_exact_top_only': True, 'declared_top_ports': declarations,
            'expected_top_ports': expected, 'mismatches': mismatches,
            'unexpected_ports_including_AXI_or_controls': extra,
            'undeclared': undeclared, 'declaration_only': declaration_only,
            'fifo_count': 8 if passed else None,
            'fifo_signal_count': 24 if passed else None,
            'external_fifo_signal_count': 18 if passed else None}


def verify_managed_host(old):
    """Read/hash only; a default-named PASS never establishes managed coverage."""
    old = old.resolve()
    frozen = old / 'frozen'
    evidence = {}

    def identity(value):
        path = Path(value['path']).resolve()
        verify(path, value)
        if path.is_relative_to(old):
            previous = evidence.setdefault(str(path), value)
            if previous != value:
                raise RuntimeError('conflicting host evidence identity: ' + str(path))
        return path

    receipt_path = old / 'receipt.json'
    receipt = json.loads(receipt_path.read_text())
    identity(rec(receipt_path))
    if (receipt.get('schema') != 'laya-managed-transaction-adapter-host-receipt-v1'
            or receipt.get('status') != 'PASS_SCOPED_HOST_MANAGED_ADAPTER'
            or set(receipt.get('phases', {})) != {'build', 'default', 'managed',
                                                'isolation_bad_magic', 'isolation_bad_tail'}):
        raise RuntimeError('fresh managed host PASS with both unknown-frame isolation phases required')
    manifest = json.loads(identity(receipt['input_manifest']).read_text())
    if (manifest.get('schema') != 'laya-managed-transaction-adapter-host-input-v1'
            or manifest.get('managed_define') != DEFINE.removeprefix('-D')
            or manifest.get('default_defines') != []
            or manifest.get('managed_cases') != 88
            or manifest.get('managed_local_rejections') != 60
            or manifest.get('managed_remote_returns') != 28
            or manifest.get('all_malformed_recovery') != 'NOT_RUN'):
        raise RuntimeError('managed host macro/case configuration mismatch')
    isolation_plan = [{'phase': 'isolation_' + mode, 'mode': mode,
        'independent_os_process': True, 'actual_LTX_reads': 24, 'observed_calls': 281,
        'isolated_calls': 256, 'queued_next_frame_beats': 24, 'expected_LTC_beats': 0,
        'expected_external_beats': 0, 'caller_fifo_clears': 0, 'static_reset': 0}
        for mode in ISOLATION_MODES]
    if manifest.get('managed_isolation_processes') != isolation_plan:
        raise RuntimeError('fresh managed host isolation process configuration mismatch')
    launch = json.loads(identity(receipt['launcher']).read_text())
    if not launch.get('pass') or launch['cpu_affinity'] != [0, 1, 2, 3]:
        raise RuntimeError('host launcher did not pass original resource policy')
    frozen_records = {}
    for row in manifest['files']:
        path = identity(row['frozen'])
        if row['original']['bytes'] != row['frozen']['bytes'] or \
                row['original']['sha256'] != row['frozen']['sha256']:
            raise RuntimeError('host original/frozen identity mismatch')
        frozen_records[str(path)] = row['frozen']
    for key in ('compiler', 'python', 'host_stream_api'):
        identity(manifest[key])
    markers = {'build': 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_BUILD_PASS',
               'default': 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_PASS',
               'managed': HOST_MARKER, 'isolation_bad_magic': ISOLATION_MARKER,
               'isolation_bad_tail': ISOLATION_MARKER}
    for name, phase in receipt['phases'].items():
        if (phase.get('status') != 'PASS' or phase.get('runner_exit_code') != 0
                or phase['guard'].get('child_exit_code') != 0
                or phase['guard'].get('trigger') is not None):
            raise RuntimeError('host guarded phase failed: ' + name)
        for row in phase['raw_files']:
            identity(row)
        output = old / ('guard_' + name)
        if json.loads((output / 'guard_result.json').read_text()) != phase['guard']:
            raise RuntimeError('host phase guard object mismatch: ' + name)
        plan = json.loads((output / 'guard_plan.json').read_text())
        rss, seconds = (24, 1800) if name == 'build' else (8, 120)
        if (plan['maximum_owned_rss_kb'] != rss * 1024 * 1024
                or plan['maximum_seconds'] != seconds
                or plan['semantic_stall_seconds'] != 120
                or plan['minimum_mem_available_kb'] != 192 * 1024 * 1024
                or plan['selected_cpu_ids'] != [0, 1, 2, 3]):
            raise RuntimeError('host original guard budget mismatch: ' + name)
        actual = [line for line in (output / 'driver.log').read_text().splitlines()
                  if line == markers[name] or line.startswith(markers[name] + ' ')]
        if len(actual) != 1 or actual != phase['markers']:
            raise RuntimeError('host exact variant marker mismatch: ' + name)
        guarded_command = manifest['commands'][name]
        child_command = guarded_command[guarded_command.index('--') + 1:]
        if plan['command'][-len(child_command):] != child_command:
            raise RuntimeError('host actual guarded command mismatch: ' + name)
    build = json.loads(identity(receipt['phases']['build']['actual_build_inputs']).read_text())
    identity(build['compiler'])
    if build['compiler'] != manifest['compiler'] or set(build['variants']) != {'default', 'managed'}:
        raise RuntimeError('host compiler or variant identities mismatch')
    if source_list(frozen) != source_list(ROOT):
        raise RuntimeError('current adapter source configuration drift')
    base = ['-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror',
            '-Wno-aggressive-loop-optimizations', '-Wno-unknown-pragmas',
            '-Wno-unused-parameter', '-fno-fast-math', '-fno-associative-math',
            '-ffp-contract=off', '-I' + str(frozen / 'include'),
            '-I' + str(frozen / 'hls'), '-I' + str(frozen / 'hls/platform'),
            '-I' + str(frozen / MODEL), '-isystem', str(VITIS_INCLUDE)]
    project_dependencies, external_dependencies = {}, {}
    for name, row in build['variants'].items():
        defines = [DEFINE] if name == 'managed' else []
        test = Path('tests/controller_transaction_adapter_' +
                    ('managed_test.cpp' if name == 'managed' else 'test.cpp'))
        units = [test, *SOURCES]
        compiler = row['command'][0]
        verify(Path(compiler), manifest['compiler'])
        wanted = [compiler, *base, *defines, *[str(frozen / p) for p in units],
                  '-o', str(old / 'build' / (name + '_adapter_test'))]
        dep_commands = [[compiler, *base, *defines, '-M', '-MT', 'LAYA_DEP',
                         str(frozen / p)] for p in units]
        if (row.get('status') != 'PASS' or row.get('exit_code') != 0
                or row.get('defines') != defines or row['command'] != wanted
                or row['dependency_commands'] != dep_commands):
            raise RuntimeError('actual host variant build/dependency configuration mismatch: ' + name)
        identity(row['binary'])
        if name == 'default':
            actual_run = [str(old / 'build/default_adapter_test')]
        else:
            actual_run = [str(old / 'build/managed_adapter_test'),
                          str(old / 'fixture'), str(old / 'capture')]
        run_command = manifest['commands'][name]
        if run_command[run_command.index('--') + 1:] != actual_run:
            raise RuntimeError('host execution is not the exact compiled variant: ' + name)
        observed = set()
        for dependency in row['actual_all_dependencies_including_system_and_SDK']:
            path = identity(dependency)
            observed.add(str(path))
            if path.is_relative_to(frozen):
                if frozen_records.get(str(path)) != dependency:
                    raise RuntimeError('compiled host dependency absent from freeze: ' + str(path))
                relative = path.relative_to(frozen)
                verify(ROOT / relative, dependency)
                project_dependencies[str(relative)] = dependency
            else:
                external_dependencies[str(path)] = dependency
        if not {str(frozen / p) for p in units}.issubset(observed):
            raise RuntimeError('host dependency evidence omits a compiled unit: ' + name)
    managed = receipt['phases']['managed']
    log_cases = [line for line in (old / 'guard_managed/driver.log').read_text().splitlines()
                 if line.startswith('MANAGED_ADAPTER_CASE_PASS ')]
    ids = [int(re.search(r'\bcase=(\d+)\b', line)[1]) for line in log_cases]
    if (log_cases != managed['case_markers'] or ids != list(range(88))
            or sum('local_reject=1 ' in line for line in log_cases) != 60
            or len(managed['independent_capture_checks']) != 88):
        raise RuntimeError('host real managed cases are incomplete')
    for case, row in enumerate(managed['independent_capture_checks']):
        actual, gold = identity(row['actual']), identity(row['independent_gold'])
        lines = actual.read_text().splitlines()
        if (row['case'] != case or not row['whole_16beat_match']
                or actual.read_bytes() != gold.read_bytes() or len(lines) != 16
                or any(re.fullmatch(r'[0-9a-fA-F]{128}', line) is None for line in lines)):
            raise RuntimeError('host independent complete LTC capture mismatch: ' + str(case))
    for row in managed['all_capture_files']:
        identity(row)
    isolation_evidence = []
    for mode in ISOLATION_MODES:
        phase = 'isolation_' + mode
        row = receipt['phases'][phase]
        capture = old / 'capture' / phase
        command = manifest['commands'][phase]
        wanted = [str(old / 'build/managed_adapter_test'), str(old / 'fixture'), str(capture), mode]
        if command[command.index('--') + 1:] != wanted:
            raise RuntimeError('isolation phase is not an independent exact managed binary invocation')
        checks = row['independent_isolation_capture_checks']
        keys = ('passed', 'independent_bad_frame_match', 'independent_next_frame_match',
                'zero_expected_and_actual_LTC', 'independent_FIFO_observations_match',
                'marker_fields_match', 'independent_os_process', 'unknown_input_only')
        if (any(checks.get(k) is not True for k in keys) or checks.get('mode') != mode
                or checks.get('actual_observation_count') != 281
                or checks.get('all_malformed_recovery') != 'NOT_RUN'):
            raise RuntimeError('fresh isolation process evidence did not pass: ' + mode)
        names = ['case_0_input_ltx.hex', 'case_0_input_next_ltx.hex',
                 'case_0_expected_ltc.hex', 'case_0_actual_ltc.hex', 'isolation_observations.csv']
        if [identity(v) for v in checks['capture_files']] != [capture / name for name in names]:
            raise RuntimeError('isolation capture closure mismatch: ' + mode)

        def packet(path):
            lines = path.read_text().splitlines()
            if len(lines) != 24 or any(re.fullmatch(r'[0-9a-fA-F]{128}', v) is None for v in lines):
                raise RuntimeError('incomplete actual/independent isolation LTX packet')
            return b''.join(bytes.fromhex(line)[::-1] for line in lines)

        fixture = old / 'fixture'
        for name in ('end_request.hex', 'compute_request.hex', 'producer_request.hex'):
            if str(fixture / name) not in frozen_records:
                raise RuntimeError('isolation independent fixture not in original host freeze')
        bad = bytearray(packet(fixture / ('end_request.hex' if mode == 'bad_tail' else 'compute_request.hex')))
        if mode == 'bad_tail':
            if bad[1535] != 0:
                raise RuntimeError('independent END reserved tail changed')
            bad[32:36] = bytes((1, 0, 0, 0)); bad[1535] = 1
        else:
            bad[0] ^= 1
        if (packet(capture / names[0]) != bytes(bad)
                or packet(capture / names[1]) != packet(fixture / 'producer_request.hex')
                or (capture / names[2]).read_bytes() != b''
                or (capture / names[3]).read_bytes() != b''):
            raise RuntimeError('independent isolation input or zero-output gold mismatch: ' + mode)
        columns = ('phase', 'call', 'cancel', 'request_read', 'request_remaining', 'completion_beats',
                   'compute_command_beats', 'provenance_command_beats', 'producer_request_beats',
                   'compute_response_remaining', 'provenance_response_remaining', 'producer_completion_remaining')
        expected_rows = [dict(zip(columns, ('READ', str(beat), str(int(mode == 'bad_tail' or beat != 0)),
                         '1', '0', '0', '0', '0', '0', '0', '0', '0'))) for beat in range(24)]
        expected_rows.append(dict(zip(columns, ('PREPARE', '0', '1', '0', '24',
                                                '0', '0', '0', '0', '1', '1', '1'))))
        for call in range(256):
            cancel = call < 64 or call >= 192 or (128 <= call < 192 and call % 2 != 0)
            expected_rows.append(dict(zip(columns, ('ISOLATED', str(call), str(int(cancel)),
                '0', '24', '0', '0', '0', '0', '1', '1', '1'))))
        with (capture / names[4]).open(newline='') as stream:
            reader = csv.DictReader(stream)
            if tuple(reader.fieldnames or ()) != columns or list(reader) != expected_rows:
                raise RuntimeError('independent actual isolation FIFO observations mismatch: ' + mode)
        fields = dict(v.split('=', 1) for v in row['markers'][0].split()[1:] if '=' in v)
        wanted_fields = {'mode': mode, 'actual_LTX_reads': '24', 'observed_calls': '281',
            'isolated_calls': '256', 'no_external': '1', 'no_LTC': '1', 'next_frame_not_consumed': '1',
            'next_frame_beats': '24', 'caller_fifo_clears': '0', 'static_reset': '0',
            'host_unbounded': '1', 'unknown_only': '1', 'recovery_NOT_RUN': '1'}
        if any(fields.get(k) != v for k, v in wanted_fields.items()):
            raise RuntimeError('exact isolation marker fields mismatch: ' + mode)
        isolation_evidence.append(checks)
    return {'status': 'REUSED_PASS_SCOPED_HOST_MANAGED_ADAPTER', 'executed_this_attempt': False,
            'receipt': rec(receipt_path), 'manifest': rec(old / 'input_manifest.json'),
            'build_inputs': rec(old / 'build/build_inputs.json'),
            'managed_marker': managed['markers'], 'cases': 88,
            'local_rejections': 60, 'remote_returns': 28,
            'unknown_frame_isolation': isolation_evidence, 'all_malformed_recovery': 'NOT_RUN',
            'project_dependencies': project_dependencies,
            'external_dependencies': list(external_dependencies.values()),
            'verified_evidence': list(evidence.values())}


def dependency_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    root = Path(spec['root'])
    expected = {row['frozen']['path']: row['frozen'] for row in spec['frozen_files']}
    output = Path(spec['raw_output']); output.mkdir(exist_ok=False)
    dependencies, commands = {}, []
    for variant, extra in [('managed_host', []), ('managed_synthesis', ['-D__SYNTHESIS__'])]:
        for index, unit in enumerate(spec['units']):
            command = [spec['compiler'], *spec['flags'], *extra, '-M', '-MT', 'LAYA_DEP',
                       str(root / unit)]
            stdout, stderr = output / f'{variant}_{index}.stdout', output / f'{variant}_{index}.stderr'
            with stdout.open('w') as out, stderr.open('w') as err:
                process = subprocess.run(command, cwd=root, stdout=out, stderr=err)
            row = {'variant': variant, 'unit': unit, 'command': command,
                   'exit_code': process.returncode, 'stdout': rec(stdout), 'stderr': rec(stderr)}
            commands.append(row)
            write_json(output / 'commands.json', commands)
            if process.returncode:
                raise RuntimeError('actual managed dependency preprocessing failed: ' + unit)
            flat = stdout.read_text().replace('\\\n', ' ')
            if not flat.startswith('LAYA_DEP:'):
                raise RuntimeError('ambiguous actual dependency output: ' + unit)
            for item in shlex.split(flat.split(':', 1)[1]):
                path = Path(item).resolve()
                value = rec(path)
                if path.is_relative_to(root):
                    if str(path) not in expected:
                        raise RuntimeError('unfrozen actual project dependency: ' + str(path))
                    verify(path, expected[str(path)])
                dependencies[str(path)] = value
            print('FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_HLS_DEPENDENCY_PROGRESS '
                  + f'variant={variant} unit={index + 1}', flush=True)
    write_json(Path(spec['output']), {'commands': commands,
        'project_files': [v for p, v in sorted(dependencies.items()) if Path(p).is_relative_to(root)],
        'external_files': [v for p, v in sorted(dependencies.items()) if not Path(p).is_relative_to(root)],
        'synthesis_dependency_scope': 'GCC -M with __SYNTHESIS__; actual HLS uses Vitis built-in headers'})
    print(DEP_MARKER, flush=True)


def guarded(attempt, name, command, frozen, artifact=None, marker=None):
    output = attempt / ('guard_' + name)
    if output.exists():
        raise RuntimeError('guard operation would overwrite prior evidence')
    args = [sys.executable, str(frozen / MODULE / 'tb/production_guard.py'),
            '--out', str(output), '--cwd', str(attempt), '--rss-gib', '24',
            '--timeout-seconds', '1800', '--semantic-stall-seconds', '120']
    if artifact is not None:
        args += ['--artifact-progress-root', str(artifact)]
    args += ['--', *map(str, command)]
    process = subprocess.run(args, cwd=attempt)
    gp, lp = output / 'guard_result.json', output / 'driver.log'
    guard = json.loads(gp.read_text()) if gp.is_file() else None
    lines = lp.read_text(errors='replace').splitlines() if lp.is_file() else []
    markers = [line for line in lines if marker and (line == marker or line.startswith(marker + ' '))]
    passed = (process.returncode == 0 and guard is not None
              and guard.get('child_exit_code') == 0 and guard.get('trigger') is None
              and (marker is None or len(markers) == 1))
    return {'status': 'PASS' if passed else 'COST_STOP' if guard and guard.get('trigger') else 'FAIL',
            'started': True, 'command': args, 'runner_exit_code': process.returncode,
            'guard': guard, 'markers': markers,
            'raw_files': [rec(p) for p in sorted(output.rglob('*')) if p.is_file()]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path)
    parser.add_argument('--reuse-host-attempt', '--managed-host-attempt',
                        dest='managed_host_attempt', type=Path)
    parser.add_argument('--legacy-hls-attempt', type=Path)
    parser.add_argument('--legacy-port-audit', type=Path)
    parser.add_argument('--dependency-worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_worker:
        dependency_worker(args.dependency_worker.resolve()); return 0
    if any(value is None for value in (args.attempt, args.managed_host_attempt,
                                       args.legacy_hls_attempt, args.legacy_port_audit)):
        parser.error('attempt, reuse-host-attempt, legacy-hls-attempt and legacy-port-audit are required')
    attempt = args.attempt.resolve(); attempt.mkdir(exist_ok=False)
    frozen, records = attempt / 'frozen', {}
    manifest = {'schema': 'laya-managed-transaction-adapter-hls-input-v1', 'scope': SCOPE,
                'top': TOP, 'managed_define': DEFINE, 'profile': PROFILE, 'files': [],
                'host_executed_this_attempt': False, 'host': None}
    receipt = {'schema': 'laya-managed-transaction-adapter-hls-receipt-v1',
               'status': 'PREPARING', 'scope': SCOPE, 'operations': {},
               'RTL_runtime': 'NOT_RUN', 'production_chain': 'NOT_RUN'}

    def freeze(source, relative, expected=None):
        value = verify(source, expected) if expected else rec(source)
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            verify(target, value)
        else:
            shutil.copyfile(source, target); verify(target, value)
        row = {'relative': str(relative), 'original': value, 'frozen': rec(target)}
        if str(relative) in records and records[str(relative)] != row:
            raise RuntimeError('conflicting candidate frozen path: ' + str(relative))
        records[str(relative)] = row
        return target

    def save():
        manifest['files'] = list(records.values())
        write_json(attempt / 'input_manifest.json', manifest)
        receipt['input_manifest'] = rec(attempt / 'input_manifest.json')
        write_json(attempt / 'receipt.json', receipt)

    try:
        launch = launcher_state(); write_json(attempt / 'launcher.json', launch)
        manifest['launcher'] = rec(attempt / 'launcher.json')
        if not launch['pass']:
            raise RuntimeError('CPU0-3/nice19/idle-I-O/MemAvailable>192GiB preflight failed')
        host = verify_managed_host(args.managed_host_attempt.resolve())
        manifest['host'] = host; receipt['host_reuse'] = host
        old = args.managed_host_attempt.resolve()
        for value in host['verified_evidence']:
            source = Path(value['path'])
            freeze(source, Path('external/reused_managed_host') / source.relative_to(old), value)
        for relative, value in host['project_dependencies'].items():
            freeze(ROOT / relative, Path(relative), value)
        for value in host['external_dependencies']:
            freeze(Path(value['path']), Path('external/dependency_snapshots') /
                   Path(value['path']).relative_to('/'), value)
        legacy, audit_path = args.legacy_hls_attempt.resolve(), args.legacy_port_audit.resolve()
        audit = json.loads(audit_path.read_text())
        legacy_receipt = json.loads((legacy / 'receipt.json').read_text())
        if (audit.get('status') != 'PASS_SCOPED_PORT_AUDIT'
                or legacy_receipt.get('status') != 'FAIL'
                or audit.get('tool_exit_code') != 0
                or audit['guard_result'].get('child_exit_code') != 0
                or audit['guard_result'].get('trigger') is not None):
            raise RuntimeError('original HLS03 FAIL plus separate successful audit required')
        verify(legacy / 'receipt.json', audit['original_receipt'])
        verify(legacy / 'input_manifest.json', audit['original_manifest'])
        old_top = legacy / (TOP + '.v'); verify(old_top, audit['port_evidence']['generated'])
        old_ports = port_evidence(old_top)
        if old_ports['status'] != 'PASS':
            raise RuntimeError('reference HLS03 actual top disagrees with strict 27-port contract')
        manifest['legacy_reference'] = {'original_status_retained': 'FAIL',
            'port_audit': rec(audit_path), 'strict_actual_top_audit': old_ports}
        for source in [audit_path, legacy / 'receipt.json', legacy / 'input_manifest.json', old_top]:
            freeze(source, Path('external/legacy_hls03') / source.name)
        roots = [*source_list(ROOT), SOURCE_LIST, RUNNER, MODULE / 'tb/production_guard.py',
                 Path('tools/hls_guard_helpers.py'), Path('config/production_hls_partitions.json'),
                 Path('config/full_module_registry.json'), MODEL / 'manifest.json',
                 MODEL / 'laya_model_layout_generated.h',
                 MODULE / 'rtl/laya_controller_transaction_layout_v1.sv']
        search = [ROOT / 'include', ROOT / 'hls', ROOT / 'hls/platform', ROOT / MODEL]
        pending, seen = [(ROOT / p).resolve() for p in roots], set()
        while pending:
            source = pending.pop()
            if source in seen:
                continue
            seen.add(source); freeze(source, source.relative_to(ROOT))
            if source.suffix not in {'.cpp', '.h', '.hpp', '.cc', '.cxx'}:
                continue
            body = source.read_text()
            for include in re.findall(r'^\s*#\s*include\s*[<"]([^>"\n]+)[>"]', body, re.M):
                options = [source.parent / include] + [p / include for p in search]
                local = next((p.resolve() for p in options if p.is_file()
                              and p.resolve().is_relative_to(ROOT)), None)
                if local:
                    pending.append(local)
            if re.search(r'^\s*#\s*include\s+[^<"\s]', body, re.M):
                raise RuntimeError('computed project include requires an explicit frozen dependency')
        for name in ['executor_old_ltx_cleanup_contract_20261013.md',
                     'executor_managed_lpv_owner_contract_20261013.md',
                     'production_hls_partition_contract_20261012.md']:
            freeze(PROJECT / 'results' / name, Path('external/contracts') / name)
        compiler = Path(shutil.which('g++') or '').resolve()
        if not compiler.is_file():
            raise RuntimeError('actual dependency compiler unavailable')
        tools = [VITIS, VITIS.parents[1] / 'bin/unwrapped/lnx64.o/v++',
                 VITIS.parents[1] / 'bin/unwrapped/lnx64.o/vitis_hls', compiler, Path(sys.executable)]
        for version in ('clang-16', 'clang-3.1', 'clang-3.9-csynth'):
            for name in ('clang', 'opt', 'llvm-link'):
                path = VITIS.parents[1] / 'lnx64/tools' / version / 'bin' / name
                if path.is_file():
                    tools.append(path)
        manifest['tools'] = list({str(p.resolve()): rec(p) for p in tools}.values())
        includes = ['-I' + str(frozen / 'include'), '-I' + str(frozen / 'hls'),
                    '-I' + str(frozen / 'hls/platform'), '-I' + str(frozen / MODEL)]
        flags = [DEFINE, *includes, '-std=c++17', '-fno-fast-math',
                 '-fno-associative-math', '-ffp-contract=off', '-isystem', str(VITIS_INCLUDE)]
        cfg = attempt / 'controller_transaction_adapter_managed.cfg'
        lines = ['part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
                 'flow_target=vivado', 'syn.top=' + TOP, 'syn.compile.pipeline_loops=0',
                 'syn.array_partition.throughput_driven=off', 'syn.array_partition.complete_threshold=0']
        lines += ['syn.file=' + str(frozen / p) for p in SOURCES]
        lines += ['syn.cflags=' + ' '.join(shlex.quote(p) for p in flags)]
        cfg.write_text('\n'.join(lines) + '\n')
        manifest['derived_config'] = rec(cfg)
        manifest['source_list'] = rec(frozen / SOURCE_LIST)
        manifest['actual_hls_sources'] = [rec(frozen / p) for p in SOURCES]
        manifest['external_dependency_snapshots_used_by_hls'] = False
        spec = attempt / 'dependency_spec.json'
        dep_output = attempt / 'dependencies.json'
        write_json(spec, {'root': str(frozen), 'compiler': str(compiler), 'flags': flags,
                          'units': [str(p) for p in SOURCES], 'frozen_files': list(records.values()),
                          'raw_output': str(attempt / 'dependency_raw'), 'output': str(dep_output)})
        manifest['dependency_spec'] = rec(spec); save()
        phases = [('dependencies', [sys.executable, str(frozen / RUNNER),
                                    '--dependency-worker', str(spec)], DEP_MARKER),
                  ('tool_version', [str(VITIS), '--version'], None),
                  ('compiler_version', [str(compiler), '-dumpfullversion', '-dumpversion'], None)]
        for name, command, marker in phases:
            value = guarded(attempt, name, command, frozen, marker=marker)
            receipt['operations'][name] = value; save()
            if value['status'] != 'PASS':
                receipt['status'] = value['status']; save(); return 1
        dependencies = json.loads(dep_output.read_text())
        manifest['dependencies'] = rec(dep_output)
        manifest['raw_dependency_files'] = [rec(p) for p in sorted((attempt / 'dependency_raw').rglob('*'))
                                            if p.is_file()]
        for value in dependencies['external_files']:
            freeze(Path(value['path']), Path('external/dependency_snapshots') /
                   Path(value['path']).relative_to('/'), value)
        manifest['actual_external_dependency_closure'] = dependencies['external_files']

        def unchanged():
            for row in records.values():
                verify(Path(row['frozen']['path']), row['frozen'])
                verify(Path(row['original']['path']), row['original'])
            for value in manifest['tools'] + dependencies['external_files']:
                verify(Path(value['path']), value)
            verify(cfg, manifest['derived_config'])
            fresh = verify_managed_host(old)
            if fresh != host:
                raise RuntimeError('managed host reuse proof changed during this attempt')

        command = [str(VITIS), '--compile', '--mode', 'hls', '--config', str(cfg),
                   '--work_dir', str(attempt / 'work')]
        manifest['hls_command'] = command; receipt['status'] = 'RUNNING'; save()
        unchanged()
        receipt['operations']['hls'] = guarded(attempt, 'hls', command, frozen,
                                              artifact=attempt / 'work')
        unchanged()
        candidates = sorted((attempt / 'work').glob('**/syn/verilog/' + TOP + '.v'))
        receipt['generated_candidates'] = [str(p) for p in candidates]
        if len(candidates) == 1:
            generated = attempt / (TOP + '.v'); shutil.copyfile(candidates[0], generated)
            verify(generated, rec(candidates[0]))
            receipt['port_evidence'] = port_evidence(generated)
        hls = receipt['operations']['hls']['status']
        receipt['status'] = ('PASS_SCOPED_GENERATION' if hls == 'PASS'
            and receipt.get('port_evidence', {}).get('status') == 'PASS'
            else hls if hls != 'PASS' else 'FAIL_PORTS')
        receipt['generated_and_partial_work_files'] = [rec(p) for p in
            sorted((attempt / 'work').rglob('*')) if p.is_file()]
        save()
        print('FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_HLS_' + receipt['status'], flush=True)
        return 0 if receipt['status'] == 'PASS_SCOPED_GENERATION' else 1
    except Exception as error:
        receipt['status'] = 'FAIL'
        receipt['error'] = {'type': type(error).__name__, 'message': str(error)}
        receipt['generated_and_partial_work_files'] = [rec(p) for p in
            sorted((attempt / 'work').rglob('*')) if p.is_file()]
        save()
        raise


if __name__ == '__main__':
    raise SystemExit(main())
