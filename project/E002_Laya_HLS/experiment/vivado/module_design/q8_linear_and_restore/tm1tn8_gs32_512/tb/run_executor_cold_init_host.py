#!/usr/bin/env python3
"""Guard exhaustive cold/default state checks in host and synthesis-field profiles."""
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

ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
RUNNER = MODULE / 'tb/run_executor_cold_init_host.py'
TEST = Path('tests/executor_cold_init_test.cpp')
SOURCES = [Path('hls/common/laya_tasks.cpp'), Path('hls/control/executor_cold_init.cpp')]
UNITS = [TEST, *SOURCES]
PREFIX = 'FULL_CURRENT_EXECUTOR_COLD_INIT_'
PROFILES = {'host': [], 'synthesis_metadata': ['-D__SYNTHESIS__']}
REFERENCE_HEADERS = [Path('include/' + name + '.h') for name in
    ['laya_types', 'laya_tasks', 'laya_numeric_tasks', 'laya_task_reservation', 'laya_full_runtime', 'laya_config']]
TYPES = ['NumericIdentity', 'BufferRef', 'WeightKey', 'Check', 'TaskContext',
         'FullMemory', 'FullInputs', 'FullWeightDescriptor', 'FullOwnerRecord', 'FullOwnerSpec',
         'SourceWindowProvenance', 'SourceProvenanceRecord', 'FullOwners', 'F32TileMeta', 'A8TileMeta',
         'VectorTask', 'QuantTask', 'LinearTask', 'LoadTask', 'ViewTicket', 'GDownWindow', 'GDownPlan',
         'DispatchBinding', 'GeneratedStoreTracker', 'Geometry', 'LifecycleActionTracker',
         'CheckpointBaseline', 'CpuImportDiagnostic', 'FullCache', 'FullRuntime']
PROBES = {'TaskReservation.task_floor', 'TaskReservation.committed_task_floor',
          'TaskReservation.task_capacity', 'TaskReservation.task_overflow', 'TaskReservation.first_task',
          'TaskReservation.ref_floor', 'TaskReservation.committed_ref_floor', 'TaskReservation.ref_capacity',
          'TaskReservation.first_ref_id', 'TaskReservation.first_ref_bank', 'TaskReservation.first_ref_epoch',
          'PortalReservation.high_water', 'PortalReservation.first_ticket'}
HOST_CACHE_COUNTS = {'weight_q': 5373952, 'weight_scale': 167936, 'weight_bias': 5248,
    'activation_q': 16*128*32, 'activation_scale': 16*128, 'input_tile': 16*4096,
    'ps_tile': 16*5248, 'gamma': 2*1024, 'rope_table': 2*1025*64,
    'kv': 2*2*1024*64, 'score': 2*16*1024, 'av_partial': 16*64, 'fp_act_weight': 256*1028}
SCOPE = ('Host execution of actual typed cold_init_step, ordinary constructors and complete '
         'explicit old frozen-declaration default gold. Two GCC executables separately cover host '
         'FullRuntime and __SYNTHESIS__ metadata fields; the latter is not Vitis HLS or RTL. '
         '15810 bounded calls, no early done, complete fields/arrays/nonzero sentinels, 44 legal '
         'allocator domains through public probes on small allocator copies, +0 float scalar '
         'bits, active-table copy compatibility and 17 post-done no-ops. Raw allocated storage '
         'is filled before lifetime to expose omitted initialization; no inactive table read, '
         'aggregate object-image/padding comparison or FullRuntime clone. No FIRST actor/top '
         'handshake, cold INIT HLS lowering, FIFO/AXI/whole chain, cache numerical execution, '
         'runtime resource improvement, implementation timing or board claim.')


def rec(path):
    path = Path(path).resolve(); size = 0; digest = hashlib.sha256()
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024*1024), b''):
            size += len(data); digest.update(data)
    return {'path': str(path), 'bytes': size, 'sha256': digest.hexdigest()}


def verify(path, expected):
    value = rec(path)
    if any(value[k] != expected[k] for k in ('bytes', 'sha256')):
        raise RuntimeError('immutable input drift: ' + str(path))
    return value


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def profile_text(text, synthesis):
    text = re.sub(r'/\*.*?\*/|//[^\n]*', '', text, flags=re.S)
    enabled, stack, output = True, [], []
    for line in text.splitlines():
        if re.match(r'\s*#\s*ifn?def\s+__SYNTHESIS__', line):
            stack.append(enabled)
            condition = synthesis if re.match(r'\s*#\s*ifdef', line) else not synthesis
            enabled = enabled and condition
        elif re.match(r'\s*#\s*if', line):
            stack.append(enabled)  # Other branches contain pragmas/functions, not these fields.
        elif re.match(r'\s*#\s*else', line):
            enabled = stack[-1] and not enabled
        elif re.match(r'\s*#\s*endif', line):
            enabled = stack.pop()
        elif not line.lstrip().startswith('#') and enabled:
            output.append(line)
    if stack:
        raise RuntimeError('unbalanced frozen declaration conditionals')
    return '\n'.join(output)


def field_inventory(root, synthesis):
    text = '\n'.join(profile_text((root / p).read_text(), synthesis) for p in REFERENCE_HEADERS)
    result = {}
    for name in TYPES:
        if synthesis and name == 'FullMemory':
            continue
        start = re.search(r'\bstruct\s+' + name + r'\s*\{', text)
        if start is None:
            raise RuntimeError('frozen type declaration absent: ' + name)
        depth, index = 1, start.end()
        while depth:
            if index >= len(text):
                raise RuntimeError('unclosed frozen type: ' + name)
            depth += (text[index] == '{') - (text[index] == '}'); index += 1
        body = text[start.end():index-1]
        statements, begin, depth = [], 0, 0
        for i, char in enumerate(body):
            depth += (char == '{') - (char == '}')
            if char == ';' and depth == 0:
                statements.append(body[begin:i].strip()); begin = i + 1
        fields = []
        for statement in statements:
            pointer = re.search(r'\(\s*\*\s*(\w+)\s*\)', statement)
            if pointer:
                fields.append(pointer[1]); continue
            if statement.startswith('struct '):
                statement = statement.rsplit('}', 1)[-1]
            elif '(' in statement:
                continue  # Constructors/member functions are not semantic fields.
            pieces, begin, depth = [], 0, 0
            for i, char in enumerate(statement):
                depth += (char in '<[{') - (char in '>]}')
                if char == ',' and depth == 0:
                    pieces.append(statement[begin:i]); begin = i + 1
            pieces.append(statement[begin:])
            for piece in pieces:
                declarator = piece.split('=', 1)[0].split('{', 1)[0].strip()
                match = re.search(r'(\w+)\s*(?:\[[^\]]*\]\s*)*$', declarator)
                if match:
                    fields.append(match[1])
        result[name] = sorted(fields)
    return result


def reference_evidence(old):
    receipt_path = old / 'receipt.json'; receipt = json.loads(receipt_path.read_text())
    if (receipt.get('schema') != 'laya-executor-stream-host-receipt-v1'
            or receipt.get('status') != 'PASS'
            or receipt.get('input_modes') != ['const', 'in_place']):
        raise RuntimeError('trusted passed dual-mode frozen declaration reference required')
    verify(old / 'input_manifest.json', receipt['input_manifest'])
    manifest = json.loads((old / 'input_manifest.json').read_text())
    evidence = [rec(receipt_path), rec(old / 'input_manifest.json')]
    for phase in ['dependencies', 'oracle', 'build', 'run_const', 'run_in_place']:
        value = receipt[phase]
        if (value['status'] != 'PASS' or value['runner_exit_code'] != 0
                or value['guard']['child_exit_code'] != 0 or value['guard']['trigger'] is not None):
            raise RuntimeError('reference actual guarded operation failed: ' + phase)
        for item in value['raw_files']:
            verify(Path(item['path']), item); evidence.append(item)
    originals = {row['frozen']['path']: row for row in manifest['files']}
    for relative in REFERENCE_HEADERS:
        path = old / 'frozen' / relative
        row = originals.get(str(path))
        if row is None or row['original']['sha256'] != row['frozen']['sha256']:
            raise RuntimeError('trusted declaration original/frozen identity missing: ' + str(relative))
        verify(path, row['frozen']); evidence.append(row['frozen'])
    # These definitions are untouched by the ColdTable change; pin their enum,
    # task and allocator-domain constants to the original successful header set.
    for relative in REFERENCE_HEADERS[:3] + [REFERENCE_HEADERS[-1]]:
        verify(ROOT / relative, originals[str(old / 'frozen' / relative)]['frozen'])
    inventories = {name: field_inventory(old / 'frozen', name == 'synthesis_metadata') for name in PROFILES}
    return {'receipt': rec(receipt_path), 'files': evidence, 'field_inventory': inventories,
            'expected_steps': 15810, 'row_map_words': [6144, 4096, 1024],
            'typed_cells': [32, 34, 4352, 128], 'allocator_domains': 44,
            'nonzero_literals': {'TaskContext.op': 132, 'TaskContext.layer': 255,
                'WeightKey.layer': 255, 'CacheState.INVALID': 6, 'GDownWindow.state': 4,
                'VectorTask.bias_id': 65535, 'QuantTask.input_lanes': 8, 'LoadTask.head': 255,
                'FullOwnerSpec.batch': 255, 'Geometry.role': 1,
                'Check.bad_element': str(2**64-1), 'CpuImportDiagnostic.descriptor_error_offset': 2**32-1,
                'CpuImportDiagnostic.import_bad_element': str(2**64-1)},
            'private_allocator_fields': {'TaskReservation': ['refs_[32].id', 'refs_[32].bank',
                'refs_[32].region', 'refs_[32].high_water', 'task_cursor_'],
                'verification': 'complete 44 legal physical domains, public floors and first tickets; no object bytes'},
            'gold_source': 'explicit literal field checks in test, reviewed against original frozen declarations'}


def dependency_worker(spec_path):
    spec = json.loads(spec_path.read_text()); root = Path(spec['root'])
    expected = {r['frozen']['path']: r['frozen'] for r in spec['files']}
    raw = Path(spec['raw']); raw.mkdir(exist_ok=False)
    dependencies, units = {}, []
    for name, defines in PROFILES.items():
        for index, relative in enumerate(UNITS):
            command = [spec['compiler'], *spec['flags'], *defines, '-M', '-MT', 'LAYA_DEP', str(root / relative)]
            stdout, stderr = raw / f'{name}_{index}.stdout', raw / f'{name}_{index}.stderr'
            with stdout.open('w') as out, stderr.open('w') as err:
                done = subprocess.run(command, cwd=root, stdout=out, stderr=err)
            row = {'profile': name, 'source': str(relative), 'command': command, 'exit_code': done.returncode,
                   'stdout': rec(stdout), 'stderr': rec(stderr)}
            units.append(row); write_json(raw / 'commands.json', units)
            if done.returncode:
                raise RuntimeError('actual cold-init dependency extraction failed')
            body = stdout.read_text().replace('\\\n', ' ')
            if not body.startswith('LAYA_DEP:'):
                raise RuntimeError('ambiguous dependency output')
            for item in shlex.split(body.split(':', 1)[1]):
                path = Path(item).resolve(); value = rec(path)
                if path.is_relative_to(root):
                    if str(path) not in expected:
                        raise RuntimeError('unfrozen actual project dependency: ' + str(path))
                    verify(path, expected[str(path)])
                dependencies[str(path)] = value
            print(PREFIX + f'DEPENDENCY_PROGRESS profile={name} units={index+1}', flush=True)
    write_json(Path(spec['output']), {'units': units, 'files': list(dependencies.values())})
    print(PREFIX + 'DEPENDENCIES_PASS', flush=True)


def build_worker(spec_path):
    spec = json.loads(spec_path.read_text()); root = Path(spec['root'])
    for name, defines in PROFILES.items():
        objects = Path(spec['output']) / name; objects.mkdir(parents=True, exist_ok=False)
        built, commands = [], []
        for index, unit in enumerate(UNITS):
            target = objects / f'{index:02d}_{unit.stem}.o'
            command = [spec['compiler'], *spec['flags'], *defines, '-c', str(root / unit), '-o', str(target)]
            commands.append(command); write_json(objects / 'commands.json', commands)
            subprocess.run(command, cwd=root, check=True); built.append(str(target))
            print(PREFIX + f'BUILD_PROGRESS profile={name} units={index+1}', flush=True)
        command = [spec['compiler'], *built, '-o', str(Path(spec['output']) / (name + '_test'))]
        commands.append(command); write_json(objects / 'commands.json', commands)
        subprocess.run(command, cwd=root, check=True)
    print(PREFIX + 'BUILD_PASS', flush=True)


def guarded(attempt, name, command, frozen, marker=None):
    output = attempt / ('guard_' + name)
    if output.exists():
        raise RuntimeError('guard output would overwrite existing evidence')
    args = [sys.executable, str(frozen / MODULE / 'tb/production_guard.py'), '--out', str(output),
            '--cwd', str(frozen), '--rss-gib', '24', '--timeout-seconds', '1800',
            '--semantic-stall-seconds', '120', '--', *map(str, command)]
    done = subprocess.run(args, cwd=frozen)
    gp, lp = output / 'guard_result.json', output / 'driver.log'
    guard = json.loads(gp.read_text()) if gp.is_file() else None
    lines = lp.read_text(errors='replace').splitlines() if lp.is_file() else []
    matches = [v for v in lines if marker and (v == marker or v.startswith(marker + ' '))]
    passed = (done.returncode == 0 and guard and guard.get('child_exit_code') == 0
              and guard.get('trigger') is None and (marker is None or len(matches) == 1))
    return {'status': 'PASS' if passed else 'COST_STOP' if guard and guard.get('trigger') else 'FAIL',
            'started': True, 'command': args, 'runner_exit_code': done.returncode, 'guard': guard,
            'markers': matches, 'raw_files': [rec(p) for p in sorted(output.rglob('*')) if p.is_file()]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path); parser.add_argument('--reference-attempt', type=Path)
    parser.add_argument('--dependency-worker', type=Path, help=argparse.SUPPRESS)
    parser.add_argument('--build-worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.dependency_worker:
        dependency_worker(args.dependency_worker.resolve()); return 0
    if args.build_worker:
        build_worker(args.build_worker.resolve()); return 0
    if args.attempt is None or args.reference_attempt is None:
        parser.error('--attempt and --reference-attempt are required')
    attempt = args.attempt.resolve(); attempt.mkdir(exist_ok=False)
    frozen, records = attempt / 'frozen', {}
    manifest = {'schema': 'laya-executor-cold-init-host-input-v1', 'scope': SCOPE, 'files': [],
                'profiles': PROFILES, 'compiled_units': [str(p) for p in UNITS],
                'profile': {'single_tool_serial': True, 'rss_gib': 24, 'timeout_seconds': 1800,
                    'semantic_stall_seconds': 120, 'cpu_affinity': [0, 1, 2, 3], 'nice': 19,
                    'io_class': 'idle', 'minimum_MemAvailable_GiB_strictly_greater_than': 192},
                'HLS_RTL_FIRST': 'NOT_RUN'}
    receipt = {'schema': 'laya-executor-cold-init-host-receipt-v1', 'status': 'PREPARING',
               'scope': SCOPE, 'operations': {}, 'HLS_RTL_FIRST': 'NOT_RUN'}

    def freeze(source, relative, expected=None):
        identity = verify(source, expected) if expected else rec(source)
        target = frozen / relative; target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            verify(target, identity)
        else:
            shutil.copyfile(source, target); verify(target, identity)
        records[str(relative)] = {'relative': str(relative), 'original': identity, 'frozen': rec(target)}

    def save():
        manifest['files'] = list(records.values()); write_json(attempt / 'input_manifest.json', manifest)
        receipt['input_manifest'] = rec(attempt / 'input_manifest.json'); write_json(attempt / 'receipt.json', receipt)

    try:
        available = next(int(v.split()[1]) for v in Path('/proc/meminfo').read_text().splitlines()
                         if v.startswith('MemAvailable:'))
        launch = {'cpu_affinity': sorted(os.sched_getaffinity(0)), 'nice': os.getpriority(os.PRIO_PROCESS, 0),
                  'ionice': subprocess.run(['ionice', '-p', str(os.getpid())], check=True,
                                          capture_output=True, text=True).stdout.strip(),
                  'mem_available_kib': available}
        launch['pass'] = (launch['cpu_affinity'] == [0, 1, 2, 3] and launch['nice'] == 19
                          and launch['ionice'].startswith('idle') and available > 192*1024*1024)
        write_json(attempt / 'launcher.json', launch); manifest['launcher'] = rec(attempt / 'launcher.json')
        if not launch['pass']:
            raise RuntimeError('original resource policy preflight failed')
        old = args.reference_attempt.resolve(); reference = reference_evidence(old)
        for value in reference['files']:
            source = Path(value['path']); freeze(source, Path('external/reference') / source.relative_to(old), value)
        write_json(attempt / 'default_reference.json', reference); manifest['default_reference'] = rec(attempt / 'default_reference.json')
        roots = [*UNITS, RUNNER, Path('include/laya_executor_cold_init.h'), Path('include/laya_cold_table.h'),
                 MODULE / 'tb/production_guard.py', Path('tools/hls_guard_helpers.py')]
        pending, seen = [(ROOT / p).resolve() for p in roots], set()
        while pending:
            source = pending.pop()
            if source in seen:
                continue
            seen.add(source); freeze(source, source.relative_to(ROOT))
            if source.suffix not in {'.h', '.hpp', '.cpp'}:
                continue
            text = source.read_text()
            for include in re.findall(r'^\s*#\s*include\s*[<"]([^>"\n]+)[>"]', text, re.M):
                paths = [source.parent / include, ROOT / 'include' / include, ROOT / 'hls' / include]
                match = next((p.resolve() for p in paths if p.is_file() and p.resolve().is_relative_to(ROOT)), None)
                if match:
                    pending.append(match)
            if re.search(r'^\s*#\s*include\s+[^<"\s]', text, re.M):
                raise RuntimeError('computed project include requires explicit freeze support')
        for name in PROFILES:
            if field_inventory(frozen, name == 'synthesis_metadata') != reference['field_inventory'][name]:
                raise RuntimeError('current defined semantic member set differs from trusted old declarations: ' + name)
        compiler = Path(shutil.which('g++') or '').resolve()
        if not compiler.is_file():
            raise RuntimeError('GCC unavailable')
        manifest['compiler'] = rec(compiler); manifest['python'] = rec(Path(sys.executable))
        flags = ['-std=c++17', '-O1', '-Wall', '-Wextra', '-Werror', '-Wno-unknown-pragmas',
                 '-Wno-unused-parameter', '-fno-fast-math', '-fno-associative-math', '-ffp-contract=off',
                 '-DLAYA_PARTITIONED_PRODUCTION_CALLER', '-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER',
                 '-DLAYA_EXECUTOR_FIRST_REQUEST', '-I' + str(frozen / 'include'), '-I' + str(frozen / 'hls')]
        dep, dep_output = attempt / 'dependency_spec.json', attempt / 'dependencies.json'
        build = attempt / 'build_spec.json'
        write_json(dep, {'root': str(frozen), 'compiler': str(compiler), 'flags': flags,
                         'files': list(records.values()), 'raw': str(attempt / 'dependency_raw'), 'output': str(dep_output)})
        write_json(build, {'root': str(frozen), 'compiler': str(compiler), 'flags': flags, 'output': str(attempt / 'build')})
        manifest['dependency_spec'] = rec(dep); manifest['build_spec'] = rec(build); save()
        dependency = guarded(attempt, 'dependencies', [sys.executable, str(frozen / RUNNER), '--dependency-worker', str(dep)],
                             frozen, PREFIX + 'DEPENDENCIES_PASS')
        receipt['operations']['dependencies'] = dependency; save()
        if dependency['status'] != 'PASS':
            receipt['status'] = dependency['status']; save(); return 1
        closure = json.loads(dep_output.read_text()); manifest['dependencies'] = rec(dep_output)
        external = [v for v in closure['files'] if not Path(v['path']).is_relative_to(frozen)]
        for value in external:
            freeze(Path(value['path']), Path('external/dependency_snapshots') / Path(value['path']).relative_to('/'), value)
        manifest['external_dependency_closure'] = external
        manifest['raw_dependency_files'] = [rec(p) for p in sorted((attempt / 'dependency_raw').rglob('*')) if p.is_file()]

        def immutable():
            for row in records.values():
                verify(Path(row['frozen']['path']), row['frozen'])
            for value in external + [manifest['compiler'], manifest['python'], rec(dep), rec(build)]:
                verify(Path(value['path']), value)

        immutable()
        for name, command, marker in [('compiler_version', [str(compiler), '-dumpfullversion', '-dumpversion'], None),
            ('build', [sys.executable, str(frozen / RUNNER), '--build-worker', str(build)], PREFIX + 'BUILD_PASS')]:
            value = guarded(attempt, name, command, frozen, marker); receipt['operations'][name] = value; save()
            if value['status'] != 'PASS':
                receipt['status'] = value['status']; save(); return 1
            immutable()
        reports = {}
        for name in PROFILES:
            report = attempt / (name + '_semantic.json'); binary = attempt / 'build' / (name + '_test')
            manifest.setdefault('binaries', {})[name] = rec(binary)
            value = guarded(attempt, 'run_' + name, [str(binary), str(report)], frozen, PREFIX + 'HOST_PASS')
            receipt['operations']['run_' + name] = value; immutable()
            if value['status'] != 'PASS':
                receipt['status'] = value['status']; save(); return 1
            result = json.loads(report.read_text()); fields = result['field_set']
            expected_fields = {type_name + '.' + field for type_name, members in
                reference['field_inventory'][name].items() for field in members} | PROBES
            if (set(fields) != expected_fields or result['profile'] != name or result['steps'] != 15810
                    or result['extra_noop_calls'] != 17 or result['ordinary_and_cold_gold_match'] is not True
                    or result['padding_compared'] or result['inactive_tables_read'] or result['allocator_physical_domains'] != 44):
                raise RuntimeError('incomplete actual exhaustive semantic field-set/cold evidence: ' + name)
            for key in ['FullOwners.qkv_plane_head_rows', 'FullOwners.qkv_rope_rows', 'FullOwners.att_head_rows']:
                if fields[key] != {'FullOwners.qkv_plane_head_rows': 6144, 'FullOwners.qkv_rope_rows': 4096,
                                   'FullOwners.att_head_rows': 1024}[key]:
                    raise RuntimeError('incomplete row-map scalar gold checks')
            if name == 'host' and any(fields['FullCache.' + key] != count for key, count in HOST_CACHE_COUNTS.items()):
                raise RuntimeError('incomplete host cache scalar gold checks')
            marker_fields = dict(v.split('=', 1) for v in value['markers'][0].split()[1:] if '=' in v)
            if (marker_fields.get('profile') != name or int(marker_fields.get('fields', '-1')) != len(fields)
                    or int(marker_fields.get('leaves', '-1')) != result['scalar_leaf_checks_per_complete_state']):
                raise RuntimeError('actual process marker does not match independent semantic evidence')
            value['semantic_report'] = rec(report); reports[name] = result; save()
        host, synthesis = reports['host'], reports['synthesis_metadata']
        if host['scalar_leaf_checks_per_complete_state'] - synthesis['scalar_leaf_checks_per_complete_state'] != \
                sum(HOST_CACHE_COUNTS.values()) + 28:
            raise RuntimeError('host-only pointer/capacity/cache/observer field extent mismatch')
        manifest['live_source_drift_after_freeze'] = []
        for row in records.values():
            path = Path(row['original']['path'])
            current = rec(path) if path.is_file() else None
            if current != row['original']:
                manifest['live_source_drift_after_freeze'].append({'frozen_source': row['original'], 'current': current})
        receipt['status'] = 'PASS_SCOPED_HOST_COLD_INIT'
        receipt['build_artifacts'] = [rec(p) for p in sorted((attempt / 'build').rglob('*')) if p.is_file()]
        immutable(); save(); print(PREFIX + receipt['status'], flush=True); return 0
    except Exception as error:
        receipt['status'] = 'FAIL'; receipt['error'] = {'type': type(error).__name__, 'message': str(error)}
        save(); raise


if __name__ == '__main__':
    raise SystemExit(main())
