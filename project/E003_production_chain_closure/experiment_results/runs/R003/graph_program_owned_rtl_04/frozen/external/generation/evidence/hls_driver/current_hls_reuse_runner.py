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
         'wrong-command-identity', 'wrong-command-source', 'stale-completion',
         'bootstrap-purpose']
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
         'before LGR1. Ten independent host processes exercise owner kind/reserved '
         'rejection, persistent cancel before command read or after two command beats, '
         'cancel after allocation, foreign command identity/source, stale completion, '
         'successful slot commit, no second owner/command, direct and nested invalid '
         'bootstrap purposes, invalid content, all seven model-copy boundary bytes '
         'and physical-span/model rejection. Tail2/tail1 waits are '
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



def verify_external_header_records(records):
    for item in records:
        if rec(item['path']) != item:
            raise RuntimeError('external compile header changed: ' + item['path'])


def verified_host_attempt(host, sources):
    host = host.resolve()
    def verify(record, within=None):
        actual = rec(record['path'])
        if actual != record:
            raise RuntimeError('host reuse identity mismatch: ' + record['path'])
        if within is not None and not Path(actual['path']).is_relative_to(within):
            raise RuntimeError('host evidence is outside its attempt: ' + record['path'])
        return actual
    receipt = json.loads((host / 'receipt.json').read_text())
    verify(receipt['input_manifest'], host)
    if Path(receipt['input_manifest']['path']) != host / 'input_manifest.json':
        raise RuntimeError('host manifest path mismatch')
    manifest = json.loads((host / 'input_manifest.json').read_text())
    expected_ops = {'dependencies', 'tool_version', 'compiler_version', 'oracle',
                    'host_build'} | {'host_' + case for case in CASES}
    if (receipt['schema'] != 'laya-graph-program-owned-receipt-v1'
            or manifest['schema'] != 'laya-graph-program-owned-input-v1'
            or receipt['status'] != 'PASS_SCOPED_HOST'
            or set(receipt['operations']) != expected_ops
            or manifest['source_count'] != len(sources)
            or manifest['sources'] != [str(p) for p in sources]
            or manifest['defines'] != DEFINES or manifest['top'] != TOP
            or manifest['host_cases'] != CASES
            or not manifest['host_cases_separate_processes']
            or manifest['software_streams_bounded']
            or not manifest['frozen_project_closure_complete']
            or not manifest['external_header_closure_frozen']
            or manifest['forbidden_sources']
            or manifest['scope'] != SCOPE or receipt['scope'] != SCOPE
            or receipt['hls']['started'] or receipt['hls']['status'] != 'NOT_RUN'):
        raise RuntimeError('matching fourteen-source/ten-case owned host PASS required')
    for name, op in receipt['operations'].items():
        if (op['status'] != 'PASS' or op['runner_exit_code'] != 0 or not op['started']
                or op['guard']['child_exit_code'] != 0 or op['guard']['trigger'] is not None):
            raise RuntimeError('host operation failed: ' + name)
        log = verify(op['driver_log'], host)
        guard_path = host / ('guard_' + name) / 'guard_result.json'
        if json.loads(guard_path.read_text()) != op['guard']:
            raise RuntimeError('host guard receipt mismatch: ' + name)
        if name.startswith('host_') and name != 'host_build':
            marker = 'FULL_CURRENT_GRAPH_PROGRAM_OWNED_TOP_PASS case=' + name[5:]
            body = Path(log['path']).read_text(errors='replace')
            if (body.count(marker + ' ') != 1 or len(op['markers']) != 1
                    or not op['markers'][0].startswith(marker + ' ')):
                raise RuntimeError('host case marker missing/duplicated: ' + name)
    verify(receipt['executable'], host)
    if Path(receipt['executable']['path']) != host / 'graph_program_owned_test':
        raise RuntimeError('host executable path mismatch')
    for item in receipt['fixture_files']:
        verify(item, host / 'fixture')
    for key in ['dependencies', 'dependency_spec', 'host_build_spec',
                'derived_config', 'launcher', 'tool_version_log', 'compiler_version_log']:
        verify(manifest[key], host)
    launcher = json.loads(Path(manifest['launcher']['path']).read_text())
    if (not launcher['pass'] or launcher['cpu_affinity'] != [0, 1, 2, 3]
            or launcher['nice'] != 19 or not launcher['ionice'].startswith('idle')
            or launcher['mem_available_kib'] <= 192 * 1024 * 1024):
        raise RuntimeError('referenced host launcher failed')
    if rec(VITIS) != manifest['tool']['executable']:
        raise RuntimeError('current HLS tool path/SHA changed')
    compiler = Path(shutil.which('g++') or '/missing-g++').resolve()
    if rec(compiler) != manifest['compiler']:
        raise RuntimeError('current compiler path/SHA changed')
    for item in manifest['tool']['external_headers']:
        verify(item)
    metadata = {'config/full_module_registry.json', 'config/production_hls_partitions.json',
                'config/graph_action_registry.json'}
    driver = str(Path(__file__).resolve().relative_to(ROOT))
    checks = []
    relatives = set()
    for item in manifest['files']:
        relative = item['relative']
        if (relative in relatives or Path(relative).is_absolute()
                or '..' in Path(relative).parts):
            raise RuntimeError('host frozen relative path invalid/duplicated')
        relatives.add(relative)
        if Path(item['frozen']['path']) != host / 'frozen' / relative:
            raise RuntimeError('host frozen path mismatch: ' + relative)
        frozen = verify(item['frozen'], host / 'frozen')
        if any(item['original'][key] != frozen[key] for key in ['sha256', 'bytes']):
            raise RuntimeError('host original/frozen pair mismatch: ' + relative)
        current = rec(item['original']['path'])
        changed = any(current[key] != frozen[key] for key in ['sha256', 'bytes'])
        if changed and relative not in metadata and relative != driver:
            raise RuntimeError('current source/dependency identity changed: ' + relative)
        checks.append({'relative': relative, 'host_original': item['original'],
            'host_frozen': frozen, 'current_original': current, 'changed': changed,
            'exception': 'catalog_metadata' if relative in metadata else
                         'new_HLS_driver' if relative == driver else None})
    required = {str(p) for p in sources + [TEST, SOURCE_LIST, BASE_LIST]}
    if not required.issubset(relatives):
        raise RuntimeError('host frozen source/test/config closure incomplete')
    dependencies = json.loads(Path(manifest['dependencies']['path']).read_text())
    for item in dependencies['files']:
        relative = str(Path(item['path']).relative_to(ROOT))
        if relative not in relatives or rec(item['path']) != item:
            raise RuntimeError('current project -M dependency changed: ' + relative)
    if dependencies['external_files'] != manifest['external_header_closure']:
        raise RuntimeError('external header dependency list mismatch')
    verify_external_header_records(dependencies['external_files'])
    for item in dependencies['external_files']:
        relative = str(Path('external/header_inputs') / Path(item['path']).relative_to('/'))
        if relative not in relatives:
            raise RuntimeError('external header frozen copy missing: ' + relative)
    units = sources + [TEST]
    build_spec = json.loads(Path(manifest['host_build_spec']['path']).read_text())
    dependency_spec = json.loads(Path(manifest['dependency_spec']['path']).read_text())
    if (build_spec['units'] != [str(host / 'frozen' / p) for p in units]
            or build_spec['cwd'] != str(host / 'frozen')
            or build_spec['binary'] != receipt['executable']['path']
            or build_spec['compiler'] != manifest['compiler']['path']
            or not set(DEFINES).issubset(build_spec['flags'])
            or any(flag.startswith('-DNDEBUG') for flag in build_spec['flags'])
            or dependency_spec['units'] != [str(p) for p in units]
            or dependency_spec['root'] != str(ROOT)
            or dependency_spec['compiler'] != manifest['compiler']['path']
            or len(dependencies['commands']) != len(units)
            or any(command != [dependency_spec['compiler'], *dependency_spec['flags'],
                               '-M', str(ROOT / unit)]
                   for command, unit in zip(dependencies['commands'], units))):
        raise RuntimeError('host actual build/dependency closure mismatch')
    expected_host = [[str(host / 'graph_program_owned_test'), str(host / 'fixture'), case]
                     for case in CASES]
    if manifest['planned_commands']['host'] != expected_host:
        raise RuntimeError('host case invocation mismatch')
    planned = {'host_build': manifest['planned_commands']['build'],
               'oracle': manifest['planned_commands']['oracle']}
    planned.update({'host_' + case: command for case, command in zip(CASES, expected_host)})
    for name, command in planned.items():
        actual = receipt['operations'][name]['command']
        if actual[actual.index('--') + 1:] != command:
            raise RuntimeError('executed host command differs from plan: ' + name)
    return receipt, manifest, checks


def reuse_host_inputs(host, attempt, sources, manifest, receipt):
    old_receipt, old_manifest, checks = verified_host_attempt(host, sources)
    host = host.resolve(); frozen = attempt / 'frozen'
    shutil.copytree(host / 'frozen', frozen)
    for item in old_manifest['files']:
        copied = rec(frozen / item['relative'])
        if any(copied[key] != item['frozen'][key] for key in ['bytes', 'sha256']):
            raise RuntimeError('host frozen copy mismatch: ' + item['relative'])
        manifest['files'].append({**item, 'frozen': copied})
    driver_copy = frozen / 'external/current_hls_reuse_runner.py'
    shutil.copyfile(Path(__file__).resolve(), driver_copy)
    manifest['hls_driver'] = {'original': rec(__file__), 'frozen': rec(driver_copy)}
    if manifest['hls_driver']['original']['sha256'] != manifest['hls_driver']['frozen']['sha256']:
        raise RuntimeError('HLS reuse driver changed during freeze')
    old_config = Path(old_manifest['derived_config']['path']).read_text()
    new_config = old_config.replace(str(host / 'frozen'), str(frozen))
    if (new_config.replace(str(frozen), str(host / 'frozen')) != old_config
            or not all(line in new_config.splitlines() for line in
                       ['part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', f'syn.top={TOP}'])
            or [line for line in new_config.splitlines() if line.startswith('syn.file=')]
            != [f'syn.file={frozen / p}' for p in sources]):
        raise RuntimeError('reused HLS configuration differs beyond frozen paths')
    config = attempt / 'graph_program_owned.cfg'
    config.write_text(new_config)
    reference = {'host_attempt': str(host), 'receipt': rec(host / 'receipt.json'),
        'input_manifest': rec(host / 'input_manifest.json'), 'status': old_receipt['status'],
        'identity_checks': checks, 'source_identity_exact': True,
        'host_measured_in_this_attempt': False}
    manifest.update({'sources': old_manifest['sources'], 'source_count': len(sources),
        'forbidden_sources': [], 'frozen_project_closure_complete': True,
        'external_header_closure_frozen': True,
        'external_header_closure': old_manifest['external_header_closure'],
        'tool': old_manifest['tool'], 'compiler': old_manifest['compiler'],
        'host_reuse': reference, 'derived_config': rec(config)})
    receipt.update({'host_reused': True, 'host_reference': reference,
        'host_run': {'started': False, 'status': 'REUSED_PASS_SCOPED_HOST'}})
    command = [str(VITIS), '--compile', '--mode', 'hls', '--config', str(config),
               '--work_dir', str(attempt / 'work')]
    manifest['planned_commands'] = {'hls': command}
    return command, frozen / MODULE / 'tb/production_guard.py'


def finish_hls(attempt, receipt, command, guard, save, external_headers):
    verify_external_header_records(external_headers)
    receipt['hls'] = guarded(attempt, 'hls', command, attempt, guard,
                             artifact=attempt / 'work')
    verify_external_header_records(external_headers)
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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--prepare-only', action='store_true')
    mode.add_argument('--host-only', action='store_true')
    parser.add_argument('--reuse-host-attempt', type=Path,
                        help='verify a matching completed host attempt and run only HLS')
    parser.add_argument('--dependency-worker', type=Path, help=argparse.SUPPRESS)
    parser.add_argument('--build-worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_worker:
        dependency_worker(args.dependency_worker); return 0
    if args.build_worker:
        build_worker(args.build_worker); return 0
    if not args.attempt:
        parser.error('--attempt is required')
    if args.reuse_host_attempt and args.host_only:
        parser.error('--reuse-host-attempt runs HLS; it cannot be combined with --host-only')
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
        if args.reuse_host_attempt:
            command, guard = reuse_host_inputs(args.reuse_host_attempt, attempt, sources,
                                               manifest, receipt)
            receipt['status'] = 'PREPARED_REUSED_HOST'; save()
            if args.prepare_only:
                print('FULL_CURRENT_GRAPH_PROGRAM_OWNED_PREPARED_REUSED_HOST', flush=True)
                return 0
            return finish_hls(attempt, receipt, command, guard, save,
                              manifest['external_header_closure'])
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
        return finish_hls(attempt, receipt, hls, guard, save,
                          dependencies['external_files'])
    except Exception as error:
        receipt['status'] = 'FAIL_REUSE_IDENTITY' if args.reuse_host_attempt else 'FAIL_RUNNER'
        receipt['error'] = str(error); save(); raise


if __name__ == '__main__':
    raise SystemExit(main())
