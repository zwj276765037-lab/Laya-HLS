#!/usr/bin/env python3
"""Freeze a strictly valid owned HLS generation and run four finite depth2 cases.

The parent controller serializes heavy tools. This runner never launches HLS or
host compilation and never repairs a rejected generation's interface.
"""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
TOP = 'laya_graph_program_owned_sequencer'
TB_TOP = 'laya_graph_program_owned_tb_v1'
VIVADO = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
XSIM = VIVADO.with_name('xsim')
GOLD_HOST = PROJECT / 'project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_host_04'
GOLD_HOST_IDENTITIES = {
    'receipt.json': '22921398fd0686e005c0e24b32cfeadabf24aa38280660025a6c52d9d47fe98e',
    'input_manifest.json': '4ede53846c14a488a2c0d17c9aaa37e1d060ec6536b46059d25731024a4d8e50',
}
CASES = ['success', 'cancel-command-prefix', 'cancel-allocated', 'stale-completion']
HOST_CASES = ['success', 'bad-owner-kind', 'bad-owner-reserved',
              'cancel-before-command', 'cancel-command-prefix', 'cancel-allocated',
              'wrong-command-identity', 'wrong-command-source', 'stale-completion']
FIFO_LAYOUT = {
    'program_owner': (False, 8192), 'program_owner_receipt': (True, 8192),
    'program_pending': (True, 8192), 'accepted_command': (False, 512),
    'request_result': (True, 512), 'action_request': (True, 512),
    'action_completion': (False, 512), 'action_completion_receipt': (True, 512),
}
SCOPE = (
    'Finite FIRST-only actual generated owned program RTL with eight real depth2 '
    'FIFOs, 3x8192 and 5x512. Complete independent GRANTED/LGP/LAP/LAX/LAC/LGR '
    'gold is derived from immutable PASS_SCOPED_HOST graph_program_owned_host_04 '
    'literal fixtures and its literal success/local-cancel field rules, without '
    'DUT encoding. Four separate reset-initialized simulation processes cover '
    'success, persistent cancellation after two accepted command beats, '
    'cancellation after actual LAP allocation, and stale completion followed by '
    'the correct canceled completion. Every complete output and actual consumer '
    'handshake is checked. LAX, LAC receipt and LGR tail2/tail1 each hold 12 real '
    'cycles, and incomplete LGP/LAC prefixes cannot emit terminal output. Two '
    'replayed owner words and two next-command beats remain in real input FIFOs '
    'through result tails and 20000 cycles after a controlled notification tied '
    'to the fourth actual result read. This result_consumed scalar is an abstract '
    'TB notification, not an owned executor consumer or unique software retirement '
    'proof; it never authorizes a second program command. The LN task LAC peer is '
    'controlled independent gold, not actual END/executor/service RTL. No reset, '
    'FIFO clear or fabricated terminal is used within a case. Receipt final write '
    'may permit LGR before its final consumer read; no invented consumer gate is '
    'claimed. No admission/source READY ownership, same-runtime executor/LN/hub, '
    'numeric payload, complete graph/13BO, CLOSE/rearm, joint resources, OOC, '
    'physical timing or board claim.')


def rec(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(data)
            size += len(data)
    return {'path': str(path), 'bytes': size, 'sha256': digest.hexdigest()}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def verify(record, within=None):
    path = Path(record['path']).resolve()
    if within is not None and not path.is_relative_to(within.resolve()):
        raise RuntimeError('evidence outside its immutable attempt: ' + str(path))
    if rec(path) != record:
        raise RuntimeError('immutable identity mismatch: ' + str(path))
    return path


def launcher_state():
    available = next(int(line.split()[1]) for line in Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    state = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
             'nice': os.getpriority(os.PRIO_PROCESS, 0),
             'ionice': subprocess.run(['ionice', '-p', str(os.getpid())], check=True,
                                      capture_output=True, text=True).stdout.strip(),
             'mem_available_kib': available, 'required_mem_available_kib': 192 * 1024 * 1024}
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and state['nice'] == 19
                     and state['ionice'].startswith('idle')
                     and available > state['required_mem_available_kib'])
    return state


def strict_ports(path):
    body = path.read_text(errors='replace')
    match = re.search(r'\bmodule\s+' + re.escape(TOP) + r'\s*\((.*?)\);', body, re.S)
    if match is None:
        raise RuntimeError('actual owned generated top module missing')
    names = set(re.findall(r'\b[A-Za-z_]\w*\b', match[1]))
    declarations = {}
    for item in re.finditer(r'\b(input|output|inout)\s+(?:(?:wire|reg|logic)\s+)?'
                            r'(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'
                            r'([A-Za-z_]\w*)\s*;', body):
        direction, high, low, name = item.groups()
        if name in names:
            declarations[name] = {'direction': direction,
                                  'width': abs(int(high)-int(low))+1 if high else 1}
    expected = {}
    mapping = {}

    def require(base, direction, width):
        aliases = {base, base + '_V'}
        signal = re.fullmatch(r'(.*)_(din|dout|full_n|empty_n|write|read)', base)
        if signal:
            aliases.add(signal[1] + '_V_' + signal[2])
        actual = sorted(names & aliases)
        okay = (len(actual) == 1 and declarations.get(actual[0]) ==
                {'direction': direction, 'width': width})
        expected[base] = {'pass': okay, 'actual': actual,
                          'direction': direction, 'width': width}
        if okay:
            mapping[base] = actual[0]

    for name, (output, width) in FIFO_LAYOUT.items():
        signals = [('din', 'output', width), ('full_n', 'input', 1), ('write', 'output', 1)] if output else [
            ('dout', 'input', width), ('empty_n', 'input', 1), ('read', 'output', 1)]
        for suffix, direction, width in signals:
            require(name + '_' + suffix, direction, width)
    require('cancel', 'input', 1)
    require('result_consumed', 'input', 1)
    require('isolated', 'output', 1)
    require('ap_clk', 'input', 1)
    resets = sorted(names & {'ap_rst', 'ap_rst_n'})
    if len(resets) == 1:
        require(resets[0], 'input', 1)
    extras = sorted(names - set(mapping.values()))
    count = sum(expected[name + '_' + suffix]['pass']
                for name, (output, _) in FIFO_LAYOUT.items()
                for suffix in (['din', 'full_n', 'write'] if output else ['dout', 'empty_n', 'read']))
    evidence = {'pass': count == 24 and len(resets) == 1 and all(v['pass'] for v in expected.values())
                       and not extras, 'fifo_signal_count': count, 'fifo_count': 8,
                'fifo_width_counts': {'8192': 3, '512': 5}, 'signals': expected,
                'mapping': mapping, 'reset_names': resets, 'unexpected_ports': extras,
                'generated': rec(path)}
    # Extra AXI/ap_start/ap_done/ap_idle/ap_ready ports are rejected by extras.
    return evidence


def verified_manifest(attempt, status):
    receipt = json.loads((attempt / 'receipt.json').read_text())
    if receipt.get('schema') != 'laya-graph-program-owned-receipt-v1' or receipt.get('status') != status:
        raise RuntimeError('required immutable owned status ' + status + ': ' + str(attempt))
    manifest_path = verify(receipt['input_manifest'], attempt)
    if manifest_path != attempt / 'input_manifest.json':
        raise RuntimeError('owned input manifest path mismatch')
    manifest = json.loads(manifest_path.read_text())
    if (manifest.get('schema') != 'laya-graph-program-owned-input-v1' or manifest.get('top') != TOP
            or manifest.get('source_count') != 14 or len(manifest.get('sources', [])) != 14
            or len(set(manifest['sources'])) != 14 or manifest.get('forbidden_sources')
            or not manifest.get('frozen_project_closure_complete')
            or not manifest.get('external_header_closure_frozen')):
        raise RuntimeError('actual fourteen-source owned freeze contract rejected')
    relatives = set()
    for item in manifest['files']:
        relative = Path(item['relative'])
        if relative.is_absolute() or '..' in relative.parts or str(relative) in relatives:
            raise RuntimeError('invalid/duplicate owned frozen relative path')
        relatives.add(str(relative))
        frozen = verify(item['frozen'], attempt / 'frozen')
        if frozen != attempt / 'frozen' / relative:
            raise RuntimeError('owned frozen path mismatch')
        if any(item['original'][k] != item['frozen'][k] for k in ['bytes', 'sha256']):
            raise RuntimeError('owned original/frozen hash mismatch')
    required = set(manifest['sources']) | {'tests/graph_program_owned_test.cpp',
                'config/graph_program_owned_sources.cmake', 'config/graph_program_sources.cmake',
                'build/model-current-production-v2-20261011/laya_model_layout_generated.h',
                'build/model-current-production-v2-20261011/manifest.json'}
    if not required.issubset(relatives):
        raise RuntimeError('actual source/model/independent host oracle closure absent')
    return receipt, manifest


def verify_generation(attempt):
    receipt, manifest = verified_manifest(attempt, 'PASS_SCOPED_GENERATION')
    hls = receipt.get('hls', {})
    if (hls.get('status') != 'PASS' or not hls.get('started') or hls.get('runner_exit_code') != 0
            or hls.get('guard', {}).get('child_exit_code') != 0 or hls.get('guard', {}).get('trigger') is not None):
        raise RuntimeError('actual guarded HLS PASS required')
    verify(hls['driver_log'], attempt)
    if json.loads((attempt / 'guard_hls/guard_result.json').read_text()) != hls['guard']:
        raise RuntimeError('HLS guard result differs from receipt')
    candidates = list((attempt / 'work').glob('**/syn/verilog/' + TOP + '.v'))
    if len(candidates) != 1:
        raise RuntimeError('actual owned generated top absent/ambiguous')
    ports = strict_ports(candidates[0])
    if not ports['pass'] or not receipt.get('port_evidence', {}).get('pass'):
        raise RuntimeError('strict 24-signal audit failed; LAP must be OUTPUT8192 din/full_n/write')
    if receipt.get('generated_candidates') != [str(candidates[0])]:
        raise RuntimeError('actual generated top candidate differs from HLS receipt')
    audited_top = verify(receipt['port_evidence']['generated'], attempt)
    if audited_top != attempt / (TOP + '.v'):
        raise RuntimeError('HLS port-audit top copy path mismatch')
    actual_top = rec(candidates[0])
    if any(actual_top[key] != receipt['port_evidence']['generated'][key]
           for key in ['bytes', 'sha256']):
        raise RuntimeError('generated top differs from HLS port receipt')
    ports['hls_receipt_generated'] = receipt['port_evidence']['generated']
    recorded = {item['path']: item for item in receipt['generated_artifacts']}
    generated = sorted(p for p in candidates[0].parent.iterdir() if p.suffix in {'.v', '.dat'})
    for path in generated:
        if str(path) not in recorded:
            raise RuntimeError('unrecorded generated module/DAT: ' + str(path))
        verify(recorded[str(path)], attempt / 'work')
    return receipt, manifest, ports, generated


def verify_gold_host():
    for name, digest in GOLD_HOST_IDENTITIES.items():
        if rec(GOLD_HOST / name)['sha256'] != digest:
            raise RuntimeError('the selected immutable host_04 gold identity changed: ' + name)
    receipt, manifest = verified_manifest(GOLD_HOST, 'PASS_SCOPED_HOST')
    if manifest.get('host_cases') != HOST_CASES or not manifest.get('host_cases_separate_processes'):
        raise RuntimeError('immutable nine-case independent gold host required')
    for name in ['oracle', 'host_build', *['host_' + case for case in HOST_CASES]]:
        operation = receipt['operations'][name]
        if (operation.get('status') != 'PASS' or not operation.get('started')
                or operation.get('runner_exit_code') != 0
                or operation['guard']['child_exit_code'] != 0 or operation['guard']['trigger'] is not None):
            raise RuntimeError('independent gold host operation failed: ' + name)
        log = verify(operation['driver_log'], GOLD_HOST)
        if json.loads((GOLD_HOST / ('guard_' + name) / 'guard_result.json').read_text()) != operation['guard']:
            raise RuntimeError('independent gold guard mismatch: ' + name)
        if name.startswith('host_') and name != 'host_build':
            if log.read_text(errors='replace').count('FULL_CURRENT_GRAPH_PROGRAM_OWNED_TOP_PASS case=' + name[5:] + ' ') != 1:
                raise RuntimeError('independent host gold case marker absent/duplicated')
    for item in receipt['fixture_files']:
        verify(item, GOLD_HOST / 'fixture')
    return receipt, manifest


def literal_gold(source):
    def load(name, size):
        data = bytearray((source / name).read_bytes())
        if len(data) != size:
            raise RuntimeError('complete independent gold length: ' + name)
        return data

    def put(packet, offset, value, count):
        packet[offset:offset+count] = value.to_bytes(count, 'little')

    owner = load('control_4.bin', 1024)
    pending = load('pending.bin', 1024)
    completion = load('cancel_completion.bin', 256)
    result = load('cancel_result.bin', 256)
    success_c = completion.copy()
    # Literal offsets/values match the independent host_04 test; no DUT encoder.
    for offset, value, count in [(16,63,4), (148,0,2), (152,0,4), (164,1,4),
                                  (168,4,4), (172,4,2), (184,1,8), (192,1,4),
                                  (204,0,2), (206,64,2), (208,1024,2)]:
        put(success_c, offset, value, count)
    for offset, value in {176:1, 196:2, 197:0, 198:0, 200:2, 201:1,
                          202:255, 203:0, 210:1}.items():
        success_c[offset] = value
    success_r = result.copy()
    success_r[9] = 1
    put(success_r,16,31,4);put(success_r,148,0,2);put(success_r,152,0,4)
    success_r[176:224] = success_c[176:224]
    local = result.copy();put(local,16,47,4);put(local,24,0,8)
    stale = completion.copy();put(stale,24,2,8)
    next_owner = owner.copy()
    put(next_owner,776,30,8);put(next_owner,784,102,8);put(next_owner,680,20,8)
    return {'owner': bytes(owner), 'next_owner': bytes(next_owner), 'pending': bytes(pending),
            'command': bytes(pending[256:512]), 'action': bytes(pending[512:1024]),
            'cancel_completion': bytes(completion), 'cancel_result': bytes(result),
            'success_completion': bytes(success_c), 'success_result': bytes(success_r),
            'local_result': bytes(local), 'stale_completion': bytes(stale)}


def emit_gold(packets, fixture):
    fixture.mkdir(exist_ok=False)
    for name, packet in packets.items():
        (fixture / (name + '.bin')).write_bytes(packet)
        width = 1024 if name in {'owner', 'next_owner', 'pending'} else 64
        (fixture / (name + '.hex')).write_text(''.join(
            packet[i:i+width][::-1].hex() + '\n' for i in range(0, len(packet), width)))


def port_macros(ports):
    lines = ['// Derived from strict widths/directions, never from a permissive alias.']
    for base, actual in sorted(ports['mapping'].items()):
        if base not in {'ap_rst', 'ap_rst_n'}:
            lines.append('`define OWN_' + base.upper() + ' ' + actual)
    reset = ports['reset_names'][0]
    lines += ['`define OWN_RESET ' + reset,
              '`define OWN_RESET_VALUE ' + ('(!rst_n)' if reset == 'ap_rst' else 'rst_n')]
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--program-hls-attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    frozen = attempt / 'frozen'
    records = []
    result = {'schema': 'laya-graph-program-owned-rtl-receipt-v1', 'status': 'RUNNING',
              'scope': SCOPE, 'operations': {}, 'host_measured_in_this_attempt': False,
              'executor_LN_END': 'NOT_RUN', 'unique_software_retirement': 'NOT_RUN',
              'result_consumed': 'CONTROLLED_ABSTRACT_AFTER_ACTUAL_FINAL_FIFO_READ'}
    receipt_path = attempt / 'receipt.json'
    write_json(receipt_path, result)

    def freeze(source, relative):
        before = rec(source)
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        captured = rec(target)
        if any(before[k] != captured[k] for k in ['bytes', 'sha256']):
            raise RuntimeError('input changed during freeze: ' + str(source))
        records.append({'relative': str(relative), 'original': before, 'frozen': captured})

    def save():
        write_json(receipt_path, result)

    try:
        # This gate precedes resource preflight or every external tool invocation.
        generation = args.program_hls_attempt.resolve()
        generation_r, generation_m, ports, generated = verify_generation(generation)
        gold_r, gold_m = verify_gold_host()
        launcher = launcher_state()
        write_json(attempt / 'launcher.json', launcher)
        if not launcher['pass']:
            raise RuntimeError('CPU0-3/nice19/idle I/O/MemAvailable>192GiB required')
        for relative in [MODULE / 'tb/laya_graph_program_owned_tb_v1.sv',
                         MODULE / 'rtl/laya_private_fifo2_v1.sv',
                         MODULE / 'tb/production_guard.py', Path('tools/hls_guard_helpers.py'),
                         Path(__file__).resolve().relative_to(ROOT)]:
            freeze(ROOT / relative, relative)
        for tag, origin, manifest, receipt in [('generation', generation, generation_m, generation_r),
                                               ('gold_host_04', GOLD_HOST, gold_m, gold_r)]:
            for name in ['receipt.json', 'input_manifest.json']:
                freeze(origin / name, Path('external') / tag / name)
            for item in manifest['files']:
                freeze(Path(item['frozen']['path']), Path('external') / tag / 'inputs' / item['relative'])
            for key in ['derived_config', 'launcher', 'tool_version_log', 'compiler_version_log',
                        'dependencies', 'dependency_spec', 'host_build_spec']:
                if key in manifest:
                    source = verify(manifest[key], origin)
                    freeze(source, Path('external') / tag / 'evidence' / key / source.name)
            if 'hls_driver' in manifest:
                source = verify(manifest['hls_driver']['frozen'], origin / 'frozen')
                freeze(source, Path('external') / tag / 'evidence/hls_driver' / source.name)
            if tag == 'gold_host_04':
                for item in receipt['fixture_files']:
                    source = Path(item['path'])
                    freeze(source, Path('external/gold_host_04/fixture') / source.relative_to(origin / 'fixture'))
            operations = receipt.get('operations', {})
            for name, operation in operations.items():
                if operation.get('started'):
                    source = Path(operation['driver_log']['path'])
                    freeze(source, Path('external') / tag / 'evidence' / name / 'driver.log')
                    guard_result = origin / ('guard_' + name) / 'guard_result.json'
                    if guard_result.is_file():
                        freeze(guard_result, Path('external') / tag / 'evidence' / name / 'guard_result.json')
        for path in generated:
            freeze(path, Path('external/program_rtl') / path.name)
        for path in sorted((generation / 'work').glob('**/syn/report/*')):
            if path.is_file():
                freeze(path, Path('external/generation/reports') / path.relative_to(generation / 'work'))

        derived = frozen / 'derived'
        derived.mkdir()
        (derived / 'owned_program_ports.vh').write_text(port_macros(ports))
        (derived / 'compile.tcl').write_text('''if {[llength $argv]!=2} {error "usage WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project owned_program_rtl [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [lsort [glob [file join $frozen external program_rtl *.v]]]
add_files -norecurse [file join $module rtl laya_private_fifo2_v1.sv]
add_files -fileset sim_1 [file join $module tb laya_graph_program_owned_tb_v1.sv]
set_property include_dirs [list [file join $frozen derived]] [get_filesets sim_1]
set_property top laya_graph_program_owned_sequencer [get_filesets sources_1]
set_property top laya_graph_program_owned_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_STATIC_PASS
close_project
''')
        (derived / 'nowave.tcl').write_text('run all\nquit\n')
        fixture = attempt / 'fixture'
        emit_gold(literal_gold(frozen / 'external/gold_host_04/fixture'), fixture)
        guard = frozen / MODULE / 'tb/production_guard.py'
        work = attempt / 'work'
        run_cwd = work / 'vivado/owned_program_rtl.sim/sim_1/behav/xsim'
        commands = {'tool_version': [str(VIVADO), '-version'],
                    'static': [str(VIVADO), '-mode', 'batch', '-notrace',
                               '-log', str(attempt / 'vivado.log'), '-journal', str(attempt / 'vivado.jou'),
                               '-source', str(derived / 'compile.tcl'), '-tclargs', str(work), str(frozen)]}
        for case in CASES:
            commands[case] = [str(XSIM), TB_TOP + '_behav', '-tclbatch', str(derived / 'nowave.tcl'),
                              '-testplusarg', 'FIXTURE=' + str(fixture), '-testplusarg', 'CASE=' + case,
                              '-testplusarg', 'MAX_CYCLES=1000000', '-log', str(attempt / (case + '_xsim.log'))]
        manifest = {'schema': 'laya-graph-program-owned-rtl-input-v1', 'scope': SCOPE,
                    'files': records, 'derived_files': [rec(p) for p in sorted(derived.iterdir())],
                    'gold_files': [rec(p) for p in sorted(fixture.iterdir())],
                    'gold_host': {'attempt': str(GOLD_HOST), 'receipt': rec(GOLD_HOST / 'receipt.json'),
                                  'input_manifest': rec(GOLD_HOST / 'input_manifest.json'),
                                  'measured_in_this_attempt': False},
                    'program_hls': {'attempt': str(generation), 'receipt': rec(generation / 'receipt.json'),
                                    'input_manifest': rec(generation / 'input_manifest.json'),
                                    'generated_verilog_and_dat': [rec(p) for p in generated]},
                    'port_evidence': ports, 'launcher': rec(attempt / 'launcher.json'),
                    'tools': {name: rec(VIVADO.with_name(name)) for name in ['vivado', 'xsim', 'xvlog', 'xelab']},
                    'python': rec(sys.executable), 'planned_commands': commands,
                    'cases_separate_simulation_processes': True, 'maximum_cycles_per_case': 1000000,
                    'pilot': {'case': 'success', 'rss_gib': 8, 'seconds': 120},
                    'remaining_cases': {'rss_gib': 8, 'seconds_per_case': 120,
                                        'decision': 'WAIT_SUCCESS_PILOT'},
                    'static': {'rss_gib': 24, 'seconds': 1800, 'semantic_stall_seconds': 120},
                    'result_notification_owner': 'controlled TB abstraction after four real result pops'}
        manifest_path = attempt / 'input_manifest.json'

        def save_manifest():
            write_json(manifest_path, manifest)
            result['input_manifest'] = rec(manifest_path)
            save()

        def run_stage(stage, marker=None):
            output = attempt / ('guard_' + stage)
            is_static = stage == 'static'
            command = [sys.executable, str(guard), '--out', str(output), '--cwd',
                       str(run_cwd if stage in CASES else attempt), '--rss-gib', '24' if is_static else '8',
                       '--timeout-seconds', '1800' if is_static else '120',
                       '--semantic-stall-seconds', '120', '--', *commands[stage]]
            process = subprocess.run(command, cwd=attempt)
            guard_path = output / 'guard_result.json'
            guarded = json.loads(guard_path.read_text()) if guard_path.is_file() else None
            log = output / 'driver.log'
            body = log.read_text(errors='replace') if log.is_file() else ''
            okay = (process.returncode == 0 and guarded is not None and guarded['child_exit_code'] == 0
                    and guarded['trigger'] is None and (marker is None or body.count(marker) == 1)
                    and not re.search(r'(?:Fatal:|FATAL:|ERROR:)', body))
            operation = {'status': 'PASS' if okay else 'COST_STOP' if guarded and guarded['trigger'] else 'FAIL',
                         'started': True, 'command': commands[stage], 'guard_command': command,
                         'runner_exit_code': process.returncode, 'guard': guarded,
                         'raw_files': [rec(p) for p in sorted(output.rglob('*')) if p.is_file()],
                         'markers': [line for line in body.splitlines() if marker and marker in line]}
            result['operations'][stage] = operation
            if not okay:
                result['status'] = operation['status']
            save()
            print('FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_STAGE stage=' + stage + ' status=' + operation['status'], flush=True)
            return okay, body

        save_manifest()
        if not run_stage('tool_version')[0]:
            return 1
        if not run_stage('static', 'FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_STATIC_PASS')[0]:
            return 1
        staged = []
        for source in sorted((frozen / 'external/program_rtl').glob('*.dat')):
            target = run_cwd / source.name
            shutil.copyfile(source, target)
            if any(rec(source)[k] != rec(target)[k] for k in ['bytes', 'sha256']):
                raise RuntimeError('ROM DAT staging mismatch')
            staged.append({'source': rec(source), 'staged': rec(target)})
        result['rom_dat_staging'] = staged
        okay, pilot_body = run_stage('success', 'FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_PASS case=success ')
        if not okay:
            return 1
        match = re.search(r'FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_PASS case=success cycles=(\d+)', pilot_body)
        cycles = int(match[1]) if match else 0
        seconds = result['operations']['success']['guard']['elapsed_seconds']
        rate = cycles / seconds if seconds > 0 else 0
        projected_cycles = math.ceil(cycles * 2 + 25000)
        projected_seconds = projected_cycles / rate if rate > 0 else math.inf
        allow = (cycles > 20000 and projected_cycles <= 1000000 and math.isfinite(rate)
                 and rate > 0 and projected_seconds <= 120)
        decision = {'status': 'RUN_BOUNDED_REMAINING' if allow else 'COST_STOP', 'started': allow,
                    'pilot_cycles': cycles, 'pilot_seconds': seconds, 'cycles_per_second': rate,
                    'maximum_cycles_per_remaining_case': projected_cycles,
                    'projected_seconds_per_case': projected_seconds if math.isfinite(projected_seconds) else None,
                    'maximum_seconds_per_case': 120, 'maximum_rss_gib': 8}
        manifest['remaining_cases']['decision'] = decision
        result['cost_decision'] = decision
        if not allow:
            result['status'] = 'COST_STOP'
            save_manifest()
            return 0
        for case in CASES[1:]:
            commands[case][commands[case].index('MAX_CYCLES=1000000')] = 'MAX_CYCLES=' + str(projected_cycles)
        save_manifest()
        for case in CASES[1:]:
            if not run_stage(case, 'FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_PASS case=' + case + ' ')[0]:
                return 1
        result['status'] = 'PASS_SCOPED_RTL_OWNED_PROGRAM_FIRST'
        result['fixture_files'] = [rec(p) for p in sorted(fixture.iterdir())]
        result['vivado_raw_files'] = [rec(p) for p in sorted(work.rglob('*.log'))]
        for path in [attempt / 'vivado.log', attempt / 'vivado.jou']:
            if path.is_file():
                result['vivado_raw_files'].append(rec(path))
        save()
        return 0
    except Exception as error:
        result['status'] = 'FAIL_INPUT' if not result['operations'] else 'FAIL'
        result['error'] = {'type': type(error).__name__, 'message': str(error)}
        result['frozen_files_at_failure'] = records
        save()
        raise


if __name__ == '__main__':
    raise SystemExit(main())
