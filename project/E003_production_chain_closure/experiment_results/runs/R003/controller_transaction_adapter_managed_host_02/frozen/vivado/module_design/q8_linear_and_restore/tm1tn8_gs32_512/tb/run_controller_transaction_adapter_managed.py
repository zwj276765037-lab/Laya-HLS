#!/usr/bin/env python3
"""Host-only controlled managed adapter macro + one default compatibility build."""
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
VITIS_INCLUDE = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include')
MANAGED_MARKER = 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_PASS'
DEFAULT_MARKER = 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_PASS'
BUILD_MARKER = 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_BUILD_PASS'
ISOLATION_MARKER = 'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_ISOLATION_PASS'
ISOLATION_MODES = ('bad_magic', 'bad_tail')
SCOPE = (
    'Host-only actual controller_transaction_adapter.cpp compiled with the explicit '
    'LAYA_MANAGED_TRANSACTION_ADAPTER=1 macro, plus one default-macro-off compatibility '
    'build/run of the existing adapter test. Managed mode latches transaction-local '
    'cancel from the wrapper input while receiving/awaiting the old LTX and before '
    'first external presentation. Only PROVENANCE+CANCEL_CLEANUP+END/INVALIDATE may '
    'proceed under revoke; RELEASE remains legacy-only cleanup permission. Ordinary '
    'complete legal pending frames not yet presented use the real adapter '
    'reject_internal/make_local_reject/encode path, with exactly FRAME_COMPLETE|LOCAL_REJECT '
    'and no remote facts. external_presented is sticky at the first write_nb attempt, '
    'regardless of its result; an old presented frame and its real return continue '
    'without reset/FIFO deletion or a second completion. 88 independent host '
    'transactions cover first pop, cancellation during empty READ after first pop, '
    'half read, last input pop, PREPARE, SEND before first write, after first write '
    'and normal operation: 60 local rejections and 28 controlled complete remote '
    'returns. Independent fixed LTC wire-offset gold compares every byte; seven '
    'caller binding mutations per rejection must remove trust. All actual 24 LTX '
    'reads, 16 LTC writes/pops and remote 16 command/8 response transfers are bounded '
    'host calls, with response partial framing and retained caller tail2/tail1. '
    'Two additional fresh OS processes cover a bad magic COMPUTE frame and a '
    'reserved-tail END frame with CANCEL_CLEANUP. After all 24 real input pops, '
    'managed full-codec parse failure isolates the retained unknown frame; 256 '
    'calls with continuous cancel, live cancel recovery and toggling produce zero '
    'LTC/external beats and consume none of the queued next 24-beat frame or peer '
    'responses. No adapter reset or caller FIFO clearing is used. Independent '
    'fixed-byte input mutations, zero-output gold and 281 actual FIFO observations '
    'per process are checked. This proves unknown-input isolation only, not '
    'recovery of every malformed frame. '
    'Vendor host hls::stream.full() is false, so READY backpressure, an attempted '
    'but unaccepted first external write, depth2/F10 final-pop interlock, HLS/RTL '
    'generation and actual owner/pending collector integration are NOT_RUN. '
    'cancel input is a controlled peer here: immutable old A/K, persistent wrapper '
    'revoke, complete executor pending and unique hub scope/physical/retirement '
    'remain root-owned integration requirements. No new wire, owner/allocator table, '
    'C/LN full tensor, D/QUANT/CLOSE/rearm, new resources/timing or board claim.'
)


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def verify(path, expected):
    value = rec(path)
    if value['bytes'] != expected['bytes'] or value['sha256'] != expected['sha256']:
        raise RuntimeError('input identity drift: ' + str(path))
    return value


def launcher_state():
    available = next(int(line.split()[1]) for line in Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    value = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
             'nice': os.getpriority(os.PRIO_PROCESS, 0),
             'ionice': subprocess.run(['ionice', '-p', str(os.getpid())], check=True,
                                      capture_output=True, text=True).stdout.strip(),
             'mem_available_kib': available, 'required_mem_available_kib': 192*1024*1024}
    value['pass'] = (value['cpu_affinity'] == [0, 1, 2, 3] and value['nice'] == 19 and
                     value['ionice'].startswith('idle') and available > value['required_mem_available_kib'])
    return value


def source_list(root):
    source = root / 'config/controller_adapter_sources.cmake'
    values = [Path(x) for x in re.findall(r'^\s*(hls/[^\s]+\.cpp)\s*$', source.read_text(), re.M)]
    if len(values) != 7 or len(set(values)) != 7 or \
            Path('hls/platform/controller_transaction_adapter.cpp') not in values:
        raise RuntimeError('exact seven-source adapter list mismatch')
    return values


def internal_build(frozen, build):
    """Executed only by the parent's guarded static phase, never at preparation."""
    build.mkdir(exist_ok=False)
    compiler = shutil.which('g++')
    if compiler is None:
        raise RuntimeError('g++ is unavailable')
    base = ['-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror',
            '-Wno-aggressive-loop-optimizations', '-Wno-unknown-pragmas', '-Wno-unused-parameter',
            '-fno-fast-math', '-fno-associative-math', '-ffp-contract=off',
            '-I'+str(frozen/'include'), '-I'+str(frozen/'hls'),
            '-I'+str(frozen/'hls/platform'), '-I'+str(frozen/MODEL),
            '-isystem', str(VITIS_INCLUDE)]
    inputs = json.loads((frozen.parent / 'input_manifest.json').read_text())
    expected = {row['frozen']['path']: row['frozen'] for row in inputs['files']}
    variants = {
        'default': ([], Path('tests/controller_transaction_adapter_test.cpp')),
        'managed': (['-DLAYA_MANAGED_TRANSACTION_ADAPTER=1'],
                    Path('tests/controller_transaction_adapter_managed_test.cpp')),
    }
    evidence = {'compiler': rec(Path(compiler)), 'variants': {}, 'scope': SCOPE}
    version = subprocess.run([compiler, '-dumpfullversion', '-dumpversion'], check=True,
                             text=True, capture_output=True)
    evidence['compiler_version'] = version.stdout.strip()
    for name, (defines, test) in variants.items():
        sources = [test, *source_list(frozen)]
        dependencies, dep_commands = {}, []
        for relative in sources:
            command = [compiler, *base, *defines, '-M', '-MT', 'LAYA_DEP', str(frozen/relative)]
            dep_commands.append(command)
            result = subprocess.run(command, check=True, text=True, capture_output=True)
            flat = result.stdout.replace('\\\n', ' ')
            for item in shlex.split(flat.split(':', 1)[1]):
                path = Path(item).resolve()
                identity = rec(path)
                if frozen == path or frozen in path.parents:
                    if str(path) not in expected:
                        raise RuntimeError('compiler found an unfrozen project dependency: ' + str(path))
                    verify(path, expected[str(path)])
                dependencies[str(path)] = identity
        binary = build / (name + '_adapter_test')
        command = [compiler, *base, *defines, *[str(frozen/p) for p in sources], '-o', str(binary)]
        row = {'defines': defines, 'dependency_commands': dep_commands,
               'actual_all_dependencies_including_system_and_SDK': list(dependencies.values()),
               'command': command, 'status': 'BUILDING'}
        evidence['variants'][name] = row
        write_json(build/'build_inputs.json', evidence)
        result = subprocess.run(command)
        row['exit_code'] = result.returncode
        for path, identity in dependencies.items():
            verify(Path(path), identity)
        row['status'] = 'PASS' if result.returncode == 0 else 'FAIL'
        if binary.exists():
            row['binary'] = rec(binary)
        write_json(build/'build_inputs.json', evidence)
        if result.returncode:
            return 1
        print('MANAGED_ADAPTER_BUILD_TARGET_PASS target='+name, flush=True)
    print(BUILD_MARKER, flush=True)
    return 0


def guarded(command, output, cwd, rss, seconds):
    guard = cwd / MODULE / 'tb/production_guard.py'
    return [sys.executable, str(guard), '--out', str(output), '--cwd', str(cwd),
            '--rss-gib', str(rss), '--timeout-seconds', str(seconds),
            '--semantic-stall-seconds', '120', '--', *command]


def run_phase(command, output, marker):
    process = subprocess.run(command)
    gp, log = output/'guard_result.json', output/'driver.log'
    guard = json.loads(gp.read_text()) if gp.is_file() else None
    body = log.read_text(errors='replace') if log.is_file() else ''
    markers = [line for line in body.splitlines() if line == marker or line.startswith(marker+' ')]
    passed = (process.returncode == 0 and guard is not None and guard.get('child_exit_code') == 0 and
              guard.get('trigger') is None and len(markers) == 1)
    return {'status': 'PASS' if passed else 'COST_STOP' if guard and guard.get('trigger') else 'FAIL',
            'started': True, 'runner_exit_code': process.returncode, 'guard': guard,
            'markers': markers, 'raw_files': [rec(p) for p in sorted(output.rglob('*')) if p.is_file()]}, body


def packet_bytes(path, beats):
    lines = path.read_text().splitlines()
    if len(lines) != beats or any(re.fullmatch(r'[0-9a-fA-F]{128}', line) is None for line in lines):
        raise ValueError('complete fixed-width packet capture required: '+str(path))
    return b''.join(bytes.fromhex(line)[::-1] for line in lines)


def isolation_capture_checks(mode, capture, fixture, markers):
    """Contract gold uses fixed offsets/counts, never the adapter reject builder."""
    names = ('case_0_input_ltx.hex', 'case_0_input_next_ltx.hex',
             'case_0_expected_ltc.hex', 'case_0_actual_ltc.hex',
             'isolation_observations.csv')
    result = {'mode': mode, 'independent_os_process': True,
              'capture_files': [rec(capture/name) for name in names if (capture/name).is_file()],
              'passed': False, 'unknown_input_only': True, 'all_malformed_recovery': 'NOT_RUN'}
    try:
        base = bytearray(packet_bytes(fixture/('end_request.hex' if mode == 'bad_tail' else
                                               'compute_request.hex'), 24))
        if mode == 'bad_tail':
            if base[1535] != 0:
                raise ValueError('independent END fixture reserved tail was not zero')
            base[32:36] = bytes((1, 0, 0, 0))
            base[1535] = 1
        else:
            base[0] ^= 1
        result['independent_bad_frame_match'] = packet_bytes(capture/names[0], 24) == bytes(base)
        result['independent_next_frame_match'] = (packet_bytes(capture/names[1], 24) ==
                                                 packet_bytes(fixture/'producer_request.hex', 24))
        result['zero_expected_and_actual_LTC'] = ((capture/names[2]).read_bytes() == b'' and
                                                 (capture/names[3]).read_bytes() == b'')
        columns = ('phase', 'call', 'cancel', 'request_read', 'request_remaining', 'completion_beats',
                   'compute_command_beats', 'provenance_command_beats', 'producer_request_beats',
                   'compute_response_remaining', 'provenance_response_remaining',
                   'producer_completion_remaining')
        with (capture/names[4]).open(newline='') as stream:
            reader = csv.DictReader(stream)
            rows = list(reader)
            header_ok = tuple(reader.fieldnames or ()) == columns
        expected = []
        for beat in range(24):
            expected.append(dict(zip(columns, ('READ', str(beat),
                str(int(mode == 'bad_tail' or beat != 0)), '1', '0', '0', '0', '0', '0', '0', '0', '0'))))
        expected.append(dict(zip(columns, ('PREPARE', '0', '1', '0', '24', '0', '0', '0', '0', '1', '1', '1'))))
        for call in range(256):
            cancel = call < 64 or call >= 192 or (128 <= call < 192 and call % 2 != 0)
            expected.append(dict(zip(columns, ('ISOLATED', str(call), str(int(cancel)), '0', '24',
                                               '0', '0', '0', '0', '1', '1', '1'))))
        result['actual_observation_count'] = len(rows)
        result['independent_FIFO_observations_match'] = header_ok and rows == expected
        result['marker_fields_match'] = False
        if len(markers) == 1:
            fields = dict(item.split('=', 1) for item in markers[0].split()[1:] if '=' in item)
            required = {'mode': mode, 'actual_LTX_reads': '24', 'observed_calls': '281',
                        'isolated_calls': '256', 'no_external': '1', 'no_LTC': '1',
                        'next_frame_not_consumed': '1', 'next_frame_beats': '24',
                        'caller_fifo_clears': '0', 'static_reset': '0', 'host_unbounded': '1',
                        'unknown_only': '1', 'recovery_NOT_RUN': '1'}
            result['marker_fields_match'] = all(fields.get(k) == v for k, v in required.items())
        result['passed'] = all(result[k] for k in ('independent_bad_frame_match',
            'independent_next_frame_match', 'zero_expected_and_actual_LTC',
            'independent_FIFO_observations_match', 'marker_fields_match'))
    except (OSError, ValueError, csv.Error) as error:
        result['capture_error'] = {'type': type(error).__name__, 'message': str(error)}
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path)
    parser.add_argument('--adapter-rtl-attempt', type=Path)
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--internal-build', type=Path)
    parser.add_argument('--frozen-root', type=Path)
    args = parser.parse_args()
    if args.internal_build:
        if args.frozen_root is None:
            parser.error('--internal-build requires --frozen-root')
        return internal_build(args.frozen_root.resolve(), args.internal_build.resolve())
    if args.attempt is None or args.adapter_rtl_attempt is None:
        parser.error('--attempt and --adapter-rtl-attempt are required')
    old = args.adapter_rtl_attempt.resolve()
    old_receipt = json.loads((old/'receipt.json').read_text())
    if old_receipt['status'] != 'PASS_SCOPED_RTL_INDEPENDENT_PROTOCOL_CASES':
        raise RuntimeError('passed frozen actual adapter fixture source required')
    verify(old/'input_manifest.json', old_receipt['input_manifest'])
    old_manifest = json.loads((old/'input_manifest.json').read_text())
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    frozen, fixture, capture = attempt/'frozen', attempt/'fixture', attempt/'capture'
    fixture.mkdir();capture.mkdir()
    for mode in ISOLATION_MODES:
        (capture/('isolation_'+mode)).mkdir()
    records = []
    result = {'schema': 'laya-managed-transaction-adapter-host-receipt-v1',
              'status': 'PREPARING', 'scope': SCOPE, 'phases': {}, 'HLS_RTL': 'NOT_RUN'}

    def freeze(source, relative, expected=None):
        identity = verify(source, expected) if expected else rec(source)
        target = frozen/relative
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            verify(target, identity)
        else:
            shutil.copyfile(source, target)
            verify(target, identity)
        records.append({'original': identity, 'frozen': rec(target)})
        return target

    try:
        launcher = launcher_state()
        write_json(attempt/'launcher.json', launcher)
        result['launcher'] = rec(attempt/'launcher.json')
        if not launcher['pass']:
            raise RuntimeError('CPU/nice/idle-I-O/MemAvailable preflight failed')
        roots = source_list(ROOT) + [Path('config/controller_adapter_sources.cmake'),
            Path('tests/controller_transaction_adapter_test.cpp'),
            Path('tests/controller_transaction_adapter_managed_test.cpp'),
            MODULE/'tb/run_controller_transaction_adapter_managed.py',
            MODULE/'tb/production_guard.py', Path('tools/hls_guard_helpers.py')]
        # Freeze literal include closure without invoking a compiler. The actual
        # compiler then confirms every dependency (including system/SDK) under
        # the static guard, rejects unfrozen project inputs, and hashes all of it.
        search = [ROOT/'include', ROOT/'hls', ROOT/'hls/platform', ROOT/MODEL]
        pending, seen = [(ROOT/p).resolve() for p in roots], set()
        while pending:
            source = pending.pop()
            if source in seen:
                continue
            seen.add(source)
            relative = source.relative_to(ROOT)
            freeze(source, relative)
            if source.suffix not in {'.cpp', '.h', '.hpp', '.cc', '.cxx'}:
                continue
            body = source.read_text()
            for include in re.findall(r'^\s*#\s*include\s*[<"]([^>"\n]+)[>"]', body, re.M):
                possible = [source.parent/include] + [p/include for p in search]
                local = next((p.resolve() for p in possible if p.is_file() and ROOT in p.resolve().parents), None)
                if local:
                    pending.append(local)
            if re.search(r'^\s*#\s*include\s+[^<"\s]', body, re.M):
                raise RuntimeError('computed project include requires explicit freeze support: '+str(source))
        freeze(old/'receipt.json', Path('external/adapter_fixture/receipt.json'))
        freeze(old/'input_manifest.json', Path('external/adapter_fixture/input_manifest.json'))
        for row in old_manifest['fixture_files']:
            source = Path(row['path'])
            verify(source, row)
            target = fixture/source.name
            shutil.copyfile(source,target)
            records.append({'original': rec(source), 'frozen': rec(target)})
        for name in ['executor_old_ltx_cleanup_contract_20261013.md',
                     'executor_managed_lpv_owner_contract_20261013.md',
                     'production_hls_partition_contract_20261012.md']:
            freeze(PROJECT/'results'/name, Path('external/contracts')/name)
        stream_api = VITIS_INCLUDE/'hls_stream.h'
        if re.search(r'bool\s+full\s*\(\s*\)\s*const\s*\{\s*return\s+false\s*;\s*\}', stream_api.read_text()) is None:
            raise RuntimeError('host stream boundedness changed; do not claim this unbounded test profile')
        build = attempt/'build'
        commands = {
            'build': guarded([sys.executable, str(frozen/MODULE/'tb/run_controller_transaction_adapter_managed.py'),
                              '--internal-build', str(build), '--frozen-root', str(frozen)],
                             attempt/'guard_build', frozen, 24, 1800),
            'default': guarded([str(build/'default_adapter_test')], attempt/'guard_default', frozen, 8, 120),
            'managed': guarded([str(build/'managed_adapter_test'), str(fixture), str(capture)],
                               attempt/'guard_managed', frozen, 8, 120),
        }
        for mode in ISOLATION_MODES:
            phase = 'isolation_'+mode
            commands[phase] = guarded([str(build/'managed_adapter_test'), str(fixture),
                                      str(capture/phase), mode],
                                     attempt/('guard_'+phase), frozen, 8, 120)
        manifest = {'schema': 'laya-managed-transaction-adapter-host-input-v1', 'scope': SCOPE,
                    'files': records, 'launcher': rec(attempt/'launcher.json'), 'commands': commands,
                    'compiler': rec(Path(shutil.which('g++'))), 'python': rec(Path(sys.executable)),
                    'host_stream_api': rec(stream_api), 'host_stream_full_is_false': True,
                    'managed_define': 'LAYA_MANAGED_TRANSACTION_ADAPTER=1', 'default_defines': [],
                    'managed_cases': 88, 'managed_local_rejections': 60, 'managed_remote_returns': 28,
                    'managed_isolation_processes': [
                        {'phase': 'isolation_'+mode, 'mode': mode, 'independent_os_process': True,
                         'actual_LTX_reads': 24, 'observed_calls': 281, 'isolated_calls': 256,
                         'queued_next_frame_beats': 24, 'expected_LTC_beats': 0,
                         'expected_external_beats': 0, 'caller_fifo_clears': 0, 'static_reset': 0}
                        for mode in ISOLATION_MODES],
                    'all_malformed_recovery': 'NOT_RUN',
                    'binding_mutants_per_local_reject': 7,
                    'profile': {'single_tool_serial': True,
                        'static': {'rss_gib': 24, 'timeout_seconds': 1800, 'semantic_stall_seconds': 120},
                        'host_finite': {'rss_gib': 8, 'timeout_seconds': 120, 'semantic_stall_seconds': 120}},
                    'actual_A_pending_collector': 'NOT_RUN; root owns persistent immutable A/FSM pending source',
                    'attempted_unaccepted_external_write': 'NOT_RUN; requires actual bounded RTL',
                    'HLS_RTL': 'NOT_RUN'}
        write_json(attempt/'input_manifest.json', manifest)
        result['input_manifest'] = rec(attempt/'input_manifest.json')
        if args.prepare_only:
            result['status'] = 'PREPARED_NOT_RUN'
            write_json(attempt/'receipt.json', result)
            print('FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_PREPARED_NOT_RUN', flush=True)
            return 0
        result['status'] = 'RUNNING'
        write_json(attempt/'receipt.json', result)
        phases = [('build', BUILD_MARKER), ('default', DEFAULT_MARKER), ('managed', MANAGED_MARKER)]
        phases.extend(('isolation_'+mode, ISOLATION_MARKER) for mode in ISOLATION_MODES)
        for phase, marker in phases:
            value, body = run_phase(commands[phase], attempt/('guard_'+phase), marker)
            if phase == 'build' and (build/'build_inputs.json').is_file():
                value['actual_build_inputs'] = rec(build/'build_inputs.json')
            if phase == 'managed':
                cases = [line for line in body.splitlines() if line.startswith('MANAGED_ADAPTER_CASE_PASS ')]
                ids = [int(re.search(r'\bcase=(\d+)\b', line)[1]) for line in cases]
                rows, capture_complete = [], True
                for case in range(88):
                    actual = capture/('case_'+str(case)+'_actual_ltc.hex')
                    gold = capture/('case_'+str(case)+'_expected_ltc.hex')
                    okay = (actual.is_file() and gold.is_file() and actual.read_bytes()==gold.read_bytes() and
                            len(actual.read_text().splitlines())==16)
                    rows.append({'case':case, 'whole_16beat_match':okay,
                                 'actual':rec(actual) if actual.is_file() else None,
                                 'independent_gold':rec(gold) if gold.is_file() else None})
                    capture_complete &= okay
                complete = (len(cases)==88 and ids==list(range(88)) and
                            sum('local_reject=1 ' in line for line in cases)==60 and capture_complete)
                value['case_markers'], value['independent_capture_checks'] = cases, rows
                value['all_capture_files'] = [rec(p) for p in sorted(capture.glob('*.hex')) if p.is_file()]
                if value['status']=='PASS' and not complete:
                    value['status']='FAIL'
                    value['failure_kind']='INCOMPLETE_CASE_OR_INDEPENDENT_CAPTURE'
            if phase.startswith('isolation_'):
                mode = phase[len('isolation_'):]
                checks = isolation_capture_checks(mode, capture/phase, fixture, value['markers'])
                value['independent_isolation_capture_checks'] = checks
                if value['status']=='PASS' and not checks['passed']:
                    value['status']='FAIL'
                    value['failure_kind']='INCOMPLETE_ISOLATION_OR_INDEPENDENT_CAPTURE'
            result['phases'][phase] = value
            write_json(attempt/'receipt.json', result)
            if value['status']!='PASS':
                result['status']=value['status']
                write_json(attempt/'receipt.json', result)
                return 1
        result['status']='PASS_SCOPED_HOST_MANAGED_ADAPTER'
        write_json(attempt/'receipt.json',result)
        print('FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_RUN_'+result['status'],flush=True)
        return 0
    except Exception as error:
        result['status']='FAIL'
        result['error']={'type':type(error).__name__,'message':str(error)}
        result['frozen_files_at_failure']=records
        write_json(attempt/'receipt.json',result)
        raise


if __name__=='__main__':
    raise SystemExit(main())
