#!/usr/bin/env python3
"""Freeze one five-wide-FIFO raw diagnostic; serialize guarded host and HLS."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
SOURCE = Path('hls/control/executor_wide_fifo_diagnostic.cpp')
HEADER = Path('include/laya_executor_wide_fifo_diagnostic.h')
TEST = Path('tests/executor_wide_fifo_diagnostic_test.cpp')
TOP = 'laya_executor_wide_fifo_diagnostic'
VITIS_ROOT = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis')
VITIS = VITIS_ROOT / 'bin/v++'
VITIS_INCLUDE = VITIS_ROOT / 'include'
HOST_DEFINE = '-DLAYA_WIDE_FIFO_DIAGNOSTIC_HOST_FIFO'
DEFINES = ['-DAP_INT_MAX_W=8192']
PREFIX = 'FULL_CURRENT_EXECUTOR_WIDE_FIFO_DIAGNOSTIC_'
FIFOS = {'control_response_receipt': True, 'control_response_rejection': True,
         'program_owner': True, 'program_owner_receipt': False, 'program_pending': False}
CONTRACTS = ['production_hls_partition_contract_20261012.md',
             'executor_minimum_hardware_chain_reply_20261013.md',
             'executor_first_hls_cost_stop_reply_20261013.md',
             'executor_second_stop_program_generation_reply_20261013.md']
SCOPE = ('One raw diagnostic with the executor five 8192-bit FIFO directions and actual '
         'nonblocking reads/writes, complete 1024-byte collect/repack, two consumed input '
         'pairs and three independent output lanes. Host uses an explicitly test-only '
         'bounded depth2 stream peer because installed host hls::stream is unbounded; '
         'HLS uses installed Vitis hls::stream without that define. Full byte oracle and '
         'source backpressure coverage do not prove generated RTL backpressure. No actor, '
         'FSM, Runtime, memcmp, production protocol/admission/shell acknowledgement, '
         'helper/retirement authority, whole model/graph/numerics, physical closure, '
         'joint resources, timing or board acceptance.')


def rec(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
            size += len(block)
    return {'path': str(path), 'bytes': size, 'sha256': digest.hexdigest()}


def write_json(path, value):
    Path(path).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def verify(records):
    for item in records:
        if rec(item['path']) != item:
            raise RuntimeError('input/tool identity changed: ' + item['path'])


def launcher_state():
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    io = subprocess.run(['/usr/bin/ionice', '-p', str(os.getpid())], check=True,
                        text=True, capture_output=True).stdout.strip()
    state = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
             'nice': os.getpriority(os.PRIO_PROCESS, 0), 'ionice': io,
             'mem_available_kib': available,
             'required_mem_available_kib': 192 * 1024 * 1024}
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and state['nice'] == 19
                     and io.startswith('idle') and available > 192 * 1024 * 1024)
    return state


def guarded(attempt, name, command, cwd, guard, marker=None, artifact=None):
    output = attempt / ('guard_' + name)
    if output.exists():
        raise RuntimeError('guard output would overwrite an earlier operation')
    args = [sys.executable, str(guard), '--out', str(output), '--cwd', str(cwd),
            '--rss-gib', '24', '--timeout-seconds', '1800',
            '--semantic-stall-seconds', '120']
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
              and result.get('trigger') is None
              and (marker is None or body.count(marker) == 1))
    return {'status': 'PASS' if passed else 'COST_STOP' if result.get('trigger') else 'FAIL',
            'started': True, 'command': args, 'runner_exit_code': completed.returncode,
            'guard': result, 'guard_files': [rec(p) for p in sorted(output.rglob('*'))
                                           if p.is_file()],
            'driver_log': rec(log) if log.is_file() else None,
            'markers': [line for line in body.splitlines() if marker and marker in line]}


def dependency_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    root = Path(spec['root']).resolve()
    raw = Path(spec['raw']); raw.mkdir(exist_ok=False)
    project, external, units = set(), set(), []
    for index, unit in enumerate(spec['units']):
        command = [spec['compiler'], *spec['flags'], *unit['defines'],
                   '-M', str(root / unit['source'])]
        completed = subprocess.run(command, cwd=root, capture_output=True, text=True)
        stdout, stderr = raw / f'{index:02d}.stdout', raw / f'{index:02d}.stderr'
        stdout.write_text(completed.stdout); stderr.write_text(completed.stderr)
        item = {'mode': unit['mode'], 'source': unit['source'], 'command': command,
                'exit_code': completed.returncode, 'stdout': rec(stdout), 'stderr': rec(stderr)}
        units.append(item)
        write_json(raw / f'{index:02d}.json', item)
        if completed.returncode:
            raise RuntimeError('dependency extraction failed: ' + unit['mode'])
        names = shlex.split(completed.stdout.replace('\\\n', ' ').split(':', 1)[1])
        files = sorted({Path(name).resolve() for name in names})
        item['files'] = [rec(path) for path in files]
        for path in files:
            (project if path.is_relative_to(root) else external).add(path)
        print(PREFIX + f'DEPENDENCY_PROGRESS units={index+1}', flush=True)
    for item in units:
        verify(item['files'])
    write_json(spec['output'], {'files': [rec(p) for p in sorted(project)],
                               'external_files': [rec(p) for p in sorted(external)],
                               'units': units})
    print(PREFIX + 'DEPENDENCY_PASS', flush=True)


def fixture_worker(output):
    output.mkdir(exist_ok=False)
    for frame in range(2):
        # Independent literal byte stimuli: no project codec or DUT helper.
        owner = bytes(((i * 29 + 17 + 37 * frame) ^ ((i // 64) * 11)) & 255
                      for i in range(1024))
        pending = bytes(((i * 43 + 91 + 53 * frame) ^ ((i // 7) * 9)) & 255
                        for i in range(1024))
        mixed = bytes(left ^ right for left, right in zip(owner, pending))
        for name, data in [('owner', owner), ('pending', pending), ('mixed', mixed)]:
            (output / f'{name}_{frame}.bin').write_bytes(data)
    print(PREFIX + 'FIXTURE_PASS packets=6 bytes_per_packet=1024', flush=True)


def build_worker(spec_path):
    spec = json.loads(spec_path.read_text())
    output = Path(spec['objects']); output.mkdir(exist_ok=False)
    objects = []
    for index, unit in enumerate(spec['units']):
        obj = output / f'{index:02d}_{Path(unit).stem}.o'
        command = [spec['compiler'], *spec['flags'], '-c', unit, '-o', str(obj)]
        subprocess.run(command, cwd=spec['cwd'], check=True)
        objects.append(str(obj))
        print(PREFIX + f'BUILD_PROGRESS units={index+1}', flush=True)
    subprocess.run([spec['compiler'], *objects, '-o', spec['binary']],
                   cwd=spec['cwd'], check=True)
    print(PREFIX + 'BUILD_PASS', flush=True)


def check_captures(fixture, expected):
    records = []
    for lane, source in [('receipt', 'owner'), ('rejection', 'pending'), ('owner', 'mixed')]:
        for frame in range(2):
            original = expected[f'{source}_{frame}.bin']
            verify([original])
            path = fixture / f'actual_{lane}_{frame}.bin'
            actual, oracle = path.read_bytes(), Path(original['path']).read_bytes()
            if len(actual) != 1024 or len(oracle) != 1024 or actual != oracle:
                raise RuntimeError('independent complete byte oracle mismatch: ' + str(path))
            records.append({'actual': rec(path), 'expected': original,
                            'complete_bytes_compared': 1024, 'pass': True})
    return records


def port_evidence(path):
    body = re.sub(r'/\*.*?\*/|//[^\n]*', '', path.read_text(errors='replace'), flags=re.S)
    module = re.search(r'\bmodule\s+' + re.escape(TOP) + r'\s*\((.*?)\);', body, re.S)
    if module is None:
        raise RuntimeError('generated diagnostic top absent')
    names = {part.strip() for part in module.group(1).split(',')}
    if not all(re.fullmatch(r'[A-Za-z_]\w*', name) for name in names):
        raise RuntimeError('unsupported generated top declaration form')
    ports = {}
    for match in re.finditer(r'\b(input|output|inout)\s+(?:(?:wire|reg|logic)\s+)?'
                             r'(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'
                             r'([A-Za-z_]\w*)\s*;', body):
        direction, hi, lo, name = match.groups()
        if name in names:
            if name in ports:
                raise RuntimeError('duplicate top port declaration: ' + name)
            ports[name] = {'direction': direction, 'width': abs(int(hi)-int(lo))+1 if hi else 1}

    def match(base, direction, width):
        candidates = [base, base + '_V']
        signal = re.fullmatch(r'(.*)_(din|dout|full_n|empty_n|write|read)', base)
        if signal:
            candidates.append(signal[1] + '_V_' + signal[2])
        actual = sorted(names & set(candidates))
        return {'pass': len(actual) == 1 and ports.get(actual[0]) ==
                {'direction': direction, 'width': width}, 'actual': actual,
                'expected_direction': direction, 'expected_width': width}

    fifos, expected = {}, set()
    for lane, outgoing in FIFOS.items():
        signals = [('din', 'output', 8192), ('full_n', 'input', 1), ('write', 'output', 1)] if outgoing else [
            ('dout', 'input', 8192), ('empty_n', 'input', 1), ('read', 'output', 1)]
        fifos[lane] = {}
        for suffix, direction, width in signals:
            item = match(lane + '_' + suffix, direction, width)
            fifos[lane][suffix] = item; expected.update(item['actual'])
    clock = match('ap_clk', 'input', 1)
    resets = sorted(names & {'ap_rst', 'ap_rst_n'})
    reset_ok = len(resets) == 1 and match(resets[0], 'input', 1)['pass']
    count = sum(item['pass'] for fifo in fifos.values() for item in fifo.values())
    axi = sorted(name for name in names if re.match(r'[ms]_axi_', name, re.I))
    forbidden = sorted(names & {'ap_start', 'ap_done', 'ap_idle', 'ap_ready'})
    extra = sorted(names - expected - {'ap_clk'} - set(resets))
    passed = (count == 15 and len(expected) == 15 and len(names) == 17 and clock['pass']
              and reset_ok and not axi and not forbidden and not extra and set(ports) == names)
    return {'pass': passed, 'generated': rec(path), 'fifo_count': 5,
            'fifo_width_counts': {'8192': 5}, 'fifo_signal_count': count,
            'fifos': fifos, 'clock': clock, 'reset_names': resets, 'reset_pass': reset_ok,
            'axi_signals': axi, 'forbidden_control': forbidden, 'unexpected_top_ports': extra,
            'declared_top_ports': sorted(names), 'declarations': ports}


def hls_facts(work):
    reports, logs, reflow, resources, bitcode = [], [], [], [], []
    for path in sorted(work.rglob('*')):
        if not path.is_file():
            continue
        if path.name == 'csynth_design_size.rpt':
            body = path.read_text(errors='replace')
            reports.append({'file': rec(path), 'text': body,
                            'instruction_counts_are_not_hardware_resources': True})
        if path.suffix == '.bc':
            bitcode.append({'file': rec(path), 'mtime_ns': path.stat().st_mtime_ns})
        if 'reflow' in path.name and path.name.endswith('.diag.yml'):
            lines = path.read_text(errors='replace').splitlines()
            passes = [line.strip() for line in lines
                      if re.match(r'\s*(?:Pass|Name|Function):', line)]
            reflow.append({'file': rec(path), 'last_named_pass_events': passes[-18:],
                           'last_lines': lines[-18:]})
        if path.suffix == '.log':
            lines = path.read_text(errors='replace').splitlines()
            logs.append({'file': rec(path), 'last_lines': lines[-12:]})
            if 'reflow' in path.name:
                events = [line for line in lines if re.search(
                    r'disaggregat|inline|reflow|error|fail', line, re.I)]
                reflow.append({'file': rec(path), 'last_events': events[-12:]})
        if path.name.endswith('_csynth.xml'):
            item = {'file': rec(path), 'kind': 'diagnostic_HLS_module_estimate_only'}
            try:
                area = ET.parse(path).find('.//AreaEstimates/Resources')
                item['estimated_resources'] = ({child.tag: child.text for child in area}
                                               if area is not None else None)
            except ET.ParseError:
                item['parse_error'] = True
            resources.append(item)
    return {'design_size_reports': reports, 'work_logs': logs, 'reflow_last_events': reflow,
            'last_bitcode_artifacts': sorted(bitcode, key=lambda item: item['mtime_ns'])[-10:],
            'resources': resources, 'joint_resource_total': None,
            'internal_deadlock_proven': False, 'RTL_backpressure': 'NOT_RUN',
            'physical_timing': 'NOT_RUN', 'board': 'NOT_RUN'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path)
    parser.add_argument('--host-only', action='store_true')
    parser.add_argument('--dependency-worker', type=Path, help=argparse.SUPPRESS)
    parser.add_argument('--fixture-worker', type=Path, help=argparse.SUPPRESS)
    parser.add_argument('--build-worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_worker:
        dependency_worker(args.dependency_worker); return 0
    if args.fixture_worker:
        fixture_worker(args.fixture_worker); return 0
    if args.build_worker:
        build_worker(args.build_worker); return 0
    if not args.attempt:
        parser.error('--attempt is required')
    attempt = args.attempt.resolve(); attempt.mkdir(parents=True, exist_ok=False)
    receipt = {'schema': 'laya-wide-fifo-diagnostic-receipt-v1', 'scope': SCOPE,
               'status': 'PREPARING', 'operations': {},
               'host': {'started': False, 'status': 'NOT_RUN'},
               'hls': {'started': False, 'status': 'NOT_RUN'},
               'generated_RTL_backpressure': 'NOT_RUN', 'production_executor': 'NOT_RUN',
               'shell_acceptance': 'NOT_RUN', 'helper_retirement_authority': 'NOT_RUN',
               'physical_closure': 'NOT_RUN', 'model_numerics': 'NOT_RUN',
               'timing': 'NOT_RUN', 'board': 'NOT_RUN'}
    manifest = {'schema': 'laya-wide-fifo-diagnostic-input-v1', 'scope': SCOPE,
                'top': TOP, 'source_count': 1, 'sources': [str(SOURCE)],
                'production_project_header_closure': [str(HEADER)], 'files': [],
                'host_defines': [*DEFINES, HOST_DEFINE], 'hls_defines': DEFINES,
                'host_stream_peer': {'bounded': True, 'depth': 2, 'test_only': True},
                'hls_stream': 'installed_Vitis_hls_stream', 'fifos': FIFOS,
                'profile': {'cpu_ids': [0, 1, 2, 3], 'nice': 19, 'io_class': 'idle',
                            'minimum_mem_available_gib_strictly_greater_than': 192,
                            'rss_gib': 24, 'wall_seconds_per_stage': 1800,
                            'semantic_stall_seconds': 120, 'one_heavy_tool_at_a_time': True},
                'clock': {'part': 'xcu55c-fsvh2892-2L-e', 'frequency_hz': 150000000,
                          'period_ns': 1000 / 150}, 'host_only': args.host_only}

    def save():
        write_json(attempt / 'input_manifest.json', manifest)
        receipt['input_manifest'] = rec(attempt / 'input_manifest.json')
        write_json(attempt / 'receipt.json', receipt)

    save()
    try:
        launcher = launcher_state(); write_json(attempt / 'launcher.json', launcher)
        manifest['launcher'] = rec(attempt / 'launcher.json'); save()
        if not launcher['pass']:
            receipt['status'] = 'FAIL_LAUNCHER'; save(); return 1
        frozen = attempt / 'frozen'

        def copy(source, relative, expected=None):
            original = rec(source)
            if expected is not None and original != expected:
                raise RuntimeError('source changed after dependency extraction: ' + str(source))
            target = frozen / relative
            if target.exists():
                if any(rec(target)[key] != original[key] for key in ['bytes', 'sha256']):
                    raise RuntimeError('frozen identity mismatch: ' + str(source))
                return
            target.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(source, target)
            copied = rec(target)
            if rec(source) != original or any(copied[key] != original[key] for key in ['bytes', 'sha256']):
                raise RuntimeError('source changed during freeze: ' + str(source))
            manifest['files'].append({'relative': str(relative), 'original': original, 'frozen': copied})

        runner = Path(__file__).resolve().relative_to(ROOT)
        fixed = [SOURCE, HEADER, TEST, runner, MODULE / 'tb/production_guard.py',
                 Path('tools/hls_guard_helpers.py'), Path('include/laya_executor_hls.h')]
        for relative in fixed:
            copy(ROOT / relative, relative)
        for name in CONTRACTS:
            copy(PROJECT / 'results' / name, Path('external/contracts') / name)
        guard = frozen / MODULE / 'tb/production_guard.py'
        compiler = Path(shutil.which('g++') or '/missing-g++').resolve()
        tool_paths = [VITIS, VITIS_ROOT / 'bin/setupEnv.sh', VITIS_ROOT / 'bin/loader',
                      VITIS_ROOT / 'bin/ldlibpath.sh',
                      VITIS_ROOT / 'bin/unwrapped/lnx64.o/v++',
                      VITIS_ROOT / 'bin/unwrapped/lnx64.o/vitis_hls',
                      VITIS_ROOT / 'lnx64/tools/clang-3.9-csynth/bin/clang',
                      VITIS_ROOT / 'lnx64/tools/clang-3.9-csynth/bin/opt']
        manifest['tools'] = [rec(path) for path in [compiler, Path(sys.executable), *tool_paths]]
        manifest['compiler'] = rec(compiler)
        manifest['external_header_seed'] = [rec(VITIS_INCLUDE / name)
                                            for name in ['ap_int.h', 'hls_stream.h']]
        dep_spec, dep_output = attempt / 'dependency_spec.json', attempt / 'dependencies.json'
        write_json(dep_spec, {'root': str(ROOT), 'compiler': str(compiler),
            'flags': ['-std=c++17', *DEFINES, '-I' + str(ROOT / 'include'),
                      '-isystem', str(VITIS_INCLUDE)],
            'units': [{'mode': 'host_source_bounded_peer', 'source': str(SOURCE), 'defines': [HOST_DEFINE]},
                      {'mode': 'host_test_bounded_peer', 'source': str(TEST), 'defines': [HOST_DEFINE]},
                      {'mode': 'production_installed_stream', 'source': str(SOURCE), 'defines': []},
                      {'mode': 'synthesis_installed_stream', 'source': str(SOURCE), 'defines': ['-D__SYNTHESIS__']}],
            'raw': str(attempt / 'dependency_raw'), 'output': str(dep_output)})
        manifest['dependency_spec'] = rec(dep_spec); save()
        result = guarded(attempt, 'dependencies', [sys.executable, str(frozen / runner),
            '--dependency-worker', str(dep_spec)], ROOT, guard, marker=PREFIX + 'DEPENDENCY_PASS')
        receipt['operations']['dependencies'] = result; save()
        if result['status'] != 'PASS':
            receipt['status'] = result['status']; save(); return 1
        dependencies = json.loads(dep_output.read_text())
        project_files = {str(Path(item['path']).relative_to(ROOT)) for item in dependencies['files']}
        if project_files != {str(SOURCE), str(HEADER), str(TEST)}:
            raise RuntimeError('diagnostic source closure contains unexpected project dependencies')
        for item in dependencies['files']:
            copy(item['path'], Path(item['path']).relative_to(ROOT), item)
        for item in dependencies['external_files']:
            copy(item['path'], Path('external/header_inputs') / Path(item['path']).relative_to('/'), item)
        manifest['dependencies'] = rec(dep_output)
        manifest['external_header_closure'] = dependencies['external_files']
        manifest['frozen_project_closure_complete'] = True
        manifest['external_header_closure_frozen'] = True
        # GCC -M identities include both actual Vitis stream variants. Internal
        # HLS compiler inputs are also retained as work artifacts; this is not
        # a claim that GCC and the HLS frontend have identical STL behavior.
        manifest['dependency_scope'] = 'GCC_-M_host_default_and___SYNTHESIS___variants'

        def stable_inputs():
            verify(manifest['tools']); verify(manifest['external_header_closure'])
            verify(manifest['external_header_seed'])
            for item in manifest['files']:
                verify([item['frozen']])

        for name, command in [('compiler_version', [str(compiler), '--version']),
                              ('tool_version', [str(VITIS), '--version'])]:
            stable_inputs()
            result = guarded(attempt, name, command, frozen, guard)
            receipt['operations'][name] = result; save()
            stable_inputs()
            if result['status'] != 'PASS':
                receipt['status'] = result['status']; save(); return 1
            manifest[name + '_log'] = result['driver_log']
        config = attempt / 'wide_fifo_diagnostic.cfg'
        lines = ['part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
                 'flow_target=vivado', f'syn.top={TOP}', 'syn.compile.pipeline_loops=0',
                 'syn.array_partition.throughput_driven=off', 'syn.array_partition.complete_threshold=0',
                 f'syn.file={frozen / SOURCE}',
                 'syn.cflags=' + ' '.join([*DEFINES, '-std=c++17', '-I' + str(frozen / 'include')])]
        if any(HOST_DEFINE in line for line in lines):
            raise RuntimeError('test-only host peer leaked into HLS configuration')
        config.write_text('\n'.join(lines) + '\n'); manifest['derived_config'] = rec(config)
        binary = attempt / 'wide_fifo_diagnostic_test'
        build_spec = attempt / 'host_build_spec.json'
        write_json(build_spec, {'cwd': str(frozen), 'compiler': str(compiler),
            'flags': ['-std=c++17', '-O1', '-Wall', '-Wextra', '-Werror',
                      '-Wno-unknown-pragmas', *DEFINES, HOST_DEFINE,
                      '-I' + str(frozen / 'include'), '-isystem', str(VITIS_INCLUDE)],
            'units': [str(frozen / SOURCE), str(frozen / TEST)],
            'objects': str(attempt / 'host_objects'), 'binary': str(binary)})
        manifest['host_build_spec'] = rec(build_spec)
        fixture = attempt / 'fixture'
        commands = {'oracle': [sys.executable, str(frozen / runner), '--fixture-worker', str(fixture)],
                    'host_build': [sys.executable, str(frozen / runner), '--build-worker', str(build_spec)],
                    'host': [str(binary), str(fixture)],
                    'hls': [str(VITIS), '--compile', '--mode', 'hls', '--config', str(config),
                            '--work_dir', str(attempt / 'work')]}
        manifest['planned_commands'] = commands; receipt['status'] = 'PREPARED'; save()
        stable_inputs()
        result = guarded(attempt, 'oracle', commands['oracle'], frozen, guard, marker=PREFIX + 'FIXTURE_PASS')
        receipt['operations']['oracle'] = result; save()
        if result['status'] != 'PASS':
            receipt['status'] = result['status']; save(); return 1
        expected_names = {f'{name}_{frame}.bin' for name in ['owner', 'pending', 'mixed'] for frame in range(2)}
        if {path.name for path in fixture.iterdir()} != expected_names:
            raise RuntimeError('independent fixture file set mismatch')
        expected = {path.name: rec(path) for path in sorted(fixture.iterdir())}
        if any(item['bytes'] != 1024 for item in expected.values()):
            raise RuntimeError('independent fixture packet size mismatch')
        manifest['fixture_inputs'] = list(expected.values())
        for item in expected.values():
            copy(item['path'], Path('external/fixture_inputs') / Path(item['path']).name, item)
        # The complete actual byte inputs and derived config are frozen before
        # either host compilation/execution or HLS begins.
        save(); stable_inputs(); verify(manifest['fixture_inputs'])
        result = guarded(attempt, 'host_build', commands['host_build'], attempt, guard,
                         marker=PREFIX + 'BUILD_PASS', artifact=attempt / 'host_objects')
        receipt['operations']['host_build'] = result; save(); stable_inputs()
        if result['status'] != 'PASS':
            receipt['status'] = result['status']; save(); return 1
        receipt['executable'] = rec(binary); verify(manifest['fixture_inputs'])
        result = guarded(attempt, 'host', commands['host'], frozen, guard, marker=PREFIX + 'HOST_PASS')
        receipt['operations']['host'] = result; receipt['host'] = dict(result); save()
        stable_inputs(); verify(manifest['fixture_inputs']); verify([receipt['executable']])
        if result['status'] != 'PASS':
            receipt['status'] = result['status']; save(); return 1
        receipt['capture_byte_oracle'] = check_captures(fixture, expected)
        receipt['host']['status'] = 'PASS_SCOPED_HOST'
        receipt['status'] = 'PASS_SCOPED_HOST'; save()
        if args.host_only:
            print(PREFIX + 'PASS_SCOPED_HOST', flush=True); return 0
        stable_inputs(); verify([manifest['derived_config'], manifest['host_build_spec']])
        receipt['hls'] = guarded(attempt, 'hls', commands['hls'], attempt, guard,
                                 artifact=attempt / 'work')
        save(); stable_inputs()
        work = attempt / 'work'
        candidates = sorted(work.glob(f'**/syn/verilog/{TOP}.v'))
        receipt['generated_candidates'] = [rec(path) for path in candidates]
        receipt['hls_facts'] = hls_facts(work)
        receipt['generated_artifacts'] = [rec(path) for path in sorted(work.rglob('*')) if path.is_file()]
        save()
        ports = None
        if len(candidates) == 1:
            generated = attempt / (TOP + '.v'); shutil.copyfile(candidates[0], generated)
            if any(rec(generated)[key] != rec(candidates[0])[key] for key in ['bytes', 'sha256']):
                raise RuntimeError('generated top changed during copy')
            ports = port_evidence(generated)
        receipt['port_evidence'] = ports
        receipt['status'] = ('PASS_SCOPED_GENERATION' if receipt['hls']['status'] == 'PASS' and ports and ports['pass']
                             else receipt['hls']['status'] if receipt['hls']['status'] != 'PASS' else 'FAIL_PORTS')
        receipt['interpretation'] = (
            'The same five wide directions alone are insufficient to explain the full executor stop; '
            'remaining actor/state complexity or unsupported operations are unresolved.'
            if receipt['status'] == 'PASS_SCOPED_GENERATION' else
            'Compare the recorded last completed artifacts and reflow events with executor_hls_01/02. '
            'Only an actually matching stage COST_STOP supports a separate wide lowering contribution; '
            'a different stop is inconclusive, and no internal deadlock or production acceptance is proven.')
        save(); print(PREFIX + receipt['status'], flush=True)
        return 0 if receipt['status'] == 'PASS_SCOPED_GENERATION' else 1
    except Exception as error:
        receipt['status'] = 'FAIL_RUNNER'; receipt['error'] = str(error); save(); raise


if __name__ == '__main__':
    raise SystemExit(main())
