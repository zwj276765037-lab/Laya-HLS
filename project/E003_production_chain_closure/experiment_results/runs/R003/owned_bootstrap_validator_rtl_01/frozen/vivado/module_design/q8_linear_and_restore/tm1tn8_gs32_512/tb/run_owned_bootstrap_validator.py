#!/usr/bin/env python3
"""Prepare an immutable isolated validator experiment from actual HLS06 RTL.

Only the parent controller launches this runner, serially. It never invokes HLS
or host compilation and never modifies an earlier attempt or generated module.
"""
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

import run_graph_program_owned_rtl as owned

ROOT, PROJECT, MODULE = owned.ROOT, owned.PROJECT, owned.MODULE
RUNS = PROJECT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
GENERATION = RUNS / 'graph_program_owned_hls_06'
DIAGNOSTIC = RUNS / 'graph_program_owned_decode_diagnostic_03'
OWNER_RTL = RUNS / 'graph_program_owned_rtl_03'
LOG_SHA = '7bae65dcc20f8ca51e6e36a7c314766e2e631c1d00677f8cd779c81fd2d6ace2'
OWNER_SHA = '38e17d21551c06c3e329bb6c59f358f56dfa6b951316c4ef808d1f7f9e047e6c'
TB_TOP = 'laya_owned_bootstrap_validator_tb_v1'
PADDING_RANGES = [(1, 8), (26, 32), (148, 152), (570, 572),
                  (577, 580), (582, 584), (593, 594), (603, 608),
                  (666, 672), (684, 688), (746, 748), (761, 768)]
CASES = [('valid', 1, 1, None, True)]
CASES += [('purpose-' + str(v), v, 1, None, False) for v in [0, 2, 257]]
CASES += [('content-' + str(v), 1, v, None, False) for v in [0, 2, 255]]
CASES += [('target-region-1', 1, 1, ('set', 576, 1), False)]
CASES += [('model-byte-' + str(j), 1, 1, ('xor', 152 + j, 1), False)
          for j in range(0, 416, 64)]
SCOPE = (
    'Actual generated nested bootstrap validate_fields with two synchronous '
    '512-bit Message read ports, a 16-bit purpose input and an 8-bit content '
    'input. Fifteen separate reset-initialized processes observe actual '
    'start/done/return: legal purpose1/content1, three bad purpose scalars '
    '(0/2/0x0101), three bad content scalars (0/2/255), content1 with an '
    'independently corrupted target_region, and seven single-byte corruptions '
    'at model offsets0/64/128/192/256/320/384. The 12-word controlled Message '
    'comes from immutable diagnostic03; every semantic byte is checked against '
    'the independent literal owner, and only its 49 ABI padding bytes with '
    'unknown bits are resolved to zero, preserving all known bits and saving '
    'the unknown mask. This proves only the isolated validator interface, '
    'not an owner-installation rejection, endpoint wire behavior, caller '
    'dynamic mapping, runtime/executor/service ownership, X-padding invariance, '
    'full graph, retirement, OOC, physical timing or board behavior.')


def semantic_map():
    """ABI semantic byte -> independent LHC1 wire byte; no DUT encoding."""
    spans = [
        (0, 8, 1, 'kind'), (8, 776, 8, 'session'),
        (16, 784, 8, 'accepted_request'), (32, 16, 8, 'sequence'),
        (40, 40, 8, 'base_epoch'), (48, 48, 8, 'base_address'),
        (56, 56, 8, 'base_capacity'), (64, 64, 84, 'NumericIdentity'),
        (152, 160, 416, 'model_identity'),
        (568, 580, 1, 'target_ref.id'), (569, 581, 1, 'target_ref.bank'),
        (572, 576, 4, 'target_ref.epoch'), (576, 582, 1, 'target_region'),
        (580, 588, 1, 'old_ref.id'), (581, 589, 1, 'old_ref.bank'),
        (584, 584, 4, 'old_ref.epoch'), (588, 590, 1, 'old_region'),
        (589, 592, 1, 'stage'), (590, 593, 1, 'layer'),
        (591, 594, 1, 'batch'), (592, 595, 1, 'row_space'),
        (594, 596, 2, 'row0'), (596, 598, 2, 'rows'),
        (598, 600, 2, 'width'), (600, 602, 1, 'content'),
        (601, 603, 1, 'layout'), (602, 604, 1, 'role'),
        (608, 608, 8, 'bo_span'), (616, 616, 8, 'owner_base_offset'),
        (624, 624, 8, 'row_stride'), (632, 632, 8, 'batch_stride'),
        (640, 640, 8, 'owner_extent_span'), (648, 648, 8, 'head_stride'),
        (656, 656, 8, 'plane_stride'), (664, 672, 2, 'mode'),
        (672, 680, 8, 'handoff_epoch'), (680, 674, 4, 'target_kind'),
        (688, 688, 56, 'target_geometry'), (744, 10, 2, 'result.code'),
        (748, 24, 4, 'result.detail'), (752, 32, 8, 'result.bad_element'),
        (760, 792, 1, 'local_committed'),
    ]
    result = {}
    for memory, wire, count, label in spans:
        for i in range(count):
            if memory + i in result:
                raise RuntimeError('overlapping semantic byte audit')
            result[memory + i] = (wire + i, label)
    # LHC1 byte8 is its independent control kind, not source purpose. The
    # controlled decoded source's real purpose was observed as 0001.
    result[24] = (None, 'source.purpose.low=1')
    result[25] = (None, 'source.purpose.high=0')
    return result


def controlled_message(log_path, owner_path):
    if owned.rec(log_path)['sha256'] != LOG_SHA or owned.rec(owner_path)['sha256'] != OWNER_SHA:
        raise RuntimeError('controlled diagnostic/independent owner identity changed')
    owner = owner_path.read_bytes()
    if len(owner) != 1024:
        raise RuntimeError('complete independent owner required')
    words = {}
    observations = 0
    for line in log_path.read_text().splitlines():
        if not line.startswith('OBS '):
            continue
        observations += 1
        match = re.fullmatch(r'OBS \S+/m_U/ram\[(\d+)\] ([0-9a-fA-FxX]{128})', line)
        if match:
            index = int(match[1])
            if index in words:
                raise RuntimeError('ambiguous Message observation')
            words[index] = match[2].lower()
    if set(words) != set(range(12)) or observations != 236:
        raise RuntimeError('all twelve real Message observations required')
    padding = {i for a, b in PADDING_RANGES for i in range(a, b)}
    semantics = semantic_map()
    if set(semantics) | padding != set(range(768)) or set(semantics) & padding:
        raise RuntimeError('semantic/padding audit does not cover the full Message')
    baseline, unknown = bytearray(), bytearray()
    for index in range(12):
        raw = words[index]
        baseline.extend(bytes.fromhex(raw.replace('x', '0'))[::-1])
        unknown.extend(bytes.fromhex(''.join('f' if c == 'x' else '0' for c in raw))[::-1])
    unknown_bytes = {i for i, mask in enumerate(unknown) if mask}
    if unknown_bytes != padding:
        raise RuntimeError('unknown bits are not precisely the audited ABI padding')
    for memory, (wire, label) in semantics.items():
        expected = owner[wire] if wire is not None else (1 if memory == 24 else 0)
        if baseline[memory] != expected or unknown[memory]:
            raise RuntimeError('independent semantic mismatch byte=' + str(memory) + ' field=' + label)
    audit = {'source_observation_count': observations, 'message_words': words,
             'padding_byte_ranges_half_open': PADDING_RANGES,
             'unknown_byte_offsets': sorted(unknown_bytes), 'unknown_bit_count': 392,
             'semantic_bytes_compared': len(semantics), 'model_bytes_compared': 416,
             'known_bits_changed': 0, 'padding_resolution': 'only unknown bits to zero',
             'source_purpose': {'actual': 1, 'wire_byte8': 'independent LHC1 kind'},
             'semantic_wire_spans': {str(k): {'wire_byte': v[0], 'field': v[1]}
                                     for k, v in semantics.items()}}
    return bytes(baseline), bytes(unknown), audit


def nested_interface(generated):
    by_name = {path.name: path for path in generated}
    caller = by_name['laya_graph_program_owned_sequencer_validate_2.v']
    body = caller.read_text()
    found = list(re.finditer(r'\b(\w*validate_fields\w*)\s+(grp_\w+)\s*\((.*?)\);', body, re.S))
    if len(found) != 1:
        raise RuntimeError('unique actual nested validate_fields instance required')
    module, instance, connections = found[0].groups()
    path = by_name.get(module + '.v')
    if path is None:
        raise RuntimeError('actual nested module absent from generated receipt')
    ports = dict(re.findall(r'\.(\w+)\s*\(\s*(\w+)\s*\)', connections))
    if any(ports.get(p) != p for p in ['m_q0', 'm_q1', 'ap_clk', 'ap_rst']):
        raise RuntimeError('actual parent Message data/clock connections required')
    if any(p not in ports or not re.fullmatch(r'[A-Za-z_]\w*', ports[p]) for p in ['purpose', 'content']):
        raise RuntimeError('both actual scalar caller connections required')
    declarations = {}
    module_body = path.read_text()
    header = re.search(r'\bmodule\s+' + re.escape(module) + r'\s*\((.*?)\);', module_body, re.S)
    if header is None:
        raise RuntimeError('nested generated module declaration absent')
    names = set(re.findall(r'\b[A-Za-z_]\w*\b', header[1]))
    for declaration in re.finditer(r'\b(input|output)\s+(?:(?:wire|reg|logic)\s+)?'
                                  r'(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?(\w+)\s*;', module_body):
        direction, high, low, name = declaration.groups()
        if name in names:
            declarations[name] = (direction, abs(int(high) - int(low)) + 1 if high else 1)
    expected = {'ap_clk': ('input', 1), 'ap_rst': ('input', 1), 'ap_start': ('input', 1),
                'ap_done': ('output', 1), 'ap_idle': ('output', 1), 'ap_ready': ('output', 1),
                'm_address0': ('output', 4), 'm_ce0': ('output', 1), 'm_q0': ('input', 512),
                'm_address1': ('output', 4), 'm_ce1': ('output', 1), 'm_q1': ('input', 512),
                'purpose': ('input', 16), 'content': ('input', 8)}
    width = declarations.get('ap_return', ('', 0))[1]
    expected['ap_return'] = ('output', width)
    if names != set(expected) or declarations != expected or not 1 <= width <= 16:
        raise RuntimeError('strict dual-512/purpose16/content8 nested interface rejected')
    # Record the original caller, not a manufactured wrapper. These capture
    # expressions are static evidence; this isolated TB does not run the caller.
    captures = {}
    for scalar, high, low in [('purpose', 207, 192), ('content', 199, 192)]:
        signal = ports[scalar]
        capture = re.search(r'(?:assign\s+)?\b' + re.escape(signal) +
                            r'\s*(?:<=|=)\s*\{\{?\s*(m_q[01])\[' + str(high) +
                            ':' + str(low) + r'\]\s*\}\}?\s*;', body)
        if capture is None:
            raise RuntimeError('actual scalar field capture absent: ' + scalar)
        captures[scalar] = capture[0]
    return {'module': module, 'instance': instance, 'module_file': owned.rec(path),
            'caller_file': owned.rec(caller), 'connections': ports,
            'ports': {k: {'direction': v[0], 'width': v[1]} for k, v in declarations.items()},
            'scalar_capture_statements': captures, 'caller_dynamic_execution': 'NOT_RUN'}, width


def emit_message(path, data):
    path.write_text(''.join(data[i:i + 64][::-1].hex() + '\n' for i in range(0, 768, 64)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--program-hls-attempt', type=Path, required=True)
    args = parser.parse_args()
    generation = args.program_hls_attempt.resolve()
    if generation != GENERATION.resolve():
        raise RuntimeError('only the authorized future HLS06 freeze is accepted')
    generation_r, generation_m, top_ports, generated = owned.verify_generation(generation)
    interface, return_width = nested_interface(generated)
    source = generation / 'frozen/hls/control/bootstrap_snapshot_protocol.cpp'
    source_body = source.read_text()
    if ('Purpose purpose, Content content' not in source_body or
            'validate_fields(r, r.purpose, r.source.content)' not in source_body or
            'model.identity[i] = r.model_identity[i]' not in source_body or
            '#pragma HLS unroll off' not in source_body):
        raise RuntimeError('actual authorized scalar/copy-loop source freeze required')
    baseline, unknown, source_audit = controlled_message(
        DIAGNOSTIC / 'guard_rtl/driver.log', OWNER_RTL / 'fixture/owner.bin')
    launcher = owned.launcher_state()
    if not launcher['pass']:
        raise RuntimeError('CPU0-3/nice19/idle I/O/MemAvailable>192GiB required')
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    frozen = attempt / 'frozen'
    records = []
    result = {'schema': 'laya-owned-bootstrap-validator-rtl-receipt-v1', 'status': 'RUNNING',
              'scope': SCOPE, 'operations': {}, 'caller_dynamic_execution': 'NOT_RUN',
              'owner_installation': 'NOT_RUN', 'host_measured_in_this_attempt': False}
    receipt_path = attempt / 'receipt.json'

    def save():
        owned.write_json(receipt_path, result)

    def freeze(source_path, relative):
        before = owned.rec(source_path)
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source_path, target)
        captured = owned.rec(target)
        if any(before[k] != captured[k] for k in ['bytes', 'sha256']):
            raise RuntimeError('input changed while freezing ' + str(source_path))
        records.append({'relative': str(relative), 'original': before, 'frozen': captured})

    save()
    try:
        owned.write_json(attempt / 'launcher.json', launcher)
        for name in ['laya_owned_bootstrap_validator_tb_v1.sv', 'run_owned_bootstrap_validator.py',
                     'run_graph_program_owned_rtl.py', 'production_guard.py']:
            freeze(ROOT / MODULE / 'tb' / name, MODULE / 'tb' / name)
        freeze(ROOT / 'tools/hls_guard_helpers.py', Path('tools/hls_guard_helpers.py'))
        for name in ['receipt.json', 'input_manifest.json']:
            freeze(generation / name, Path('external/generation') / name)
            freeze(DIAGNOSTIC / name, Path('external/diagnostic03') / name)
            freeze(OWNER_RTL / name, Path('external/owner_rtl03') / name)
        for item in generation_m['files']:
            freeze(Path(item['frozen']['path']), Path('external/generation/inputs') / item['relative'])
        for name in ['driver.log', 'guard_result.json', 'policy_checks.json']:
            freeze(generation / 'guard_hls' / name, Path('external/generation/guard_hls') / name)
        freeze(DIAGNOSTIC / 'guard_rtl/driver.log', Path('external/diagnostic03/driver.log'))
        freeze(DIAGNOSTIC / 'observe.tcl', Path('external/diagnostic03/observe.tcl'))
        freeze(OWNER_RTL / 'fixture/owner.bin', Path('external/owner_rtl03/owner.bin'))
        for path in generated:
            freeze(path, Path('external/program_rtl') / path.name)
        fixture = attempt / 'fixture'
        fixture.mkdir()
        (fixture / 'message_observed.hex').write_text(''.join(source_audit['message_words'][i] + '\n'
                                                          for i in range(12)))
        (fixture / 'message_unknown_mask.bin').write_bytes(unknown)
        emit_message(fixture / 'message_unknown_mask.hex', unknown)
        (fixture / 'message_baseline.bin').write_bytes(baseline)
        emit_message(fixture / 'message_baseline.hex', baseline)
        expectations = []
        for name, purpose, content, mutation, okay in CASES:
            data = bytearray(baseline)
            if mutation:
                operation, byte, value = mutation
                if unknown[byte]:
                    raise RuntimeError('negative mutation targets padding')
                data[byte] = value if operation == 'set' else data[byte] ^ value
            (fixture / (name + '.bin')).write_bytes(data)
            emit_message(fixture / (name + '.hex'), data)
            expectations.append({'case': name, 'purpose': purpose, 'content': content,
                                 'mutation': mutation, 'expectation': 'OK' if okay else 'NON_OK',
                                 'message': owned.rec(fixture / (name + '.bin')),
                                 'hex': owned.rec(fixture / (name + '.hex'))})
        owned.write_json(fixture / 'source_audit.json', source_audit)
        owned.write_json(fixture / 'expected.json', expectations)
        derived = frozen / 'derived'
        derived.mkdir()
        (derived / 'owned_bootstrap_validator_ports.vh').write_text(
            '`define OWNED_BOOTSTRAP_VALIDATOR_MODULE ' + interface['module'] + '\n' +
            '`define OWNED_BOOTSTRAP_RETURN_WIDTH ' + str(return_width) + '\n')
        (derived / 'compile.tcl').write_text('''if {[llength $argv] != 3} {error "usage WORK FROZEN MODULE"}
lassign $argv work frozen dut_module
set_param general.maxThreads 4
create_project owned_bootstrap_validator [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set tb [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512 tb]
add_files -norecurse [lsort [glob [file join $frozen external program_rtl *.v]]]
add_files -fileset sim_1 [file join $tb laya_owned_bootstrap_validator_tb_v1.sv]
set_property include_dirs [list [file join $frozen derived]] [get_filesets sim_1]
set_property top $dut_module [get_filesets sources_1]
set_property top laya_owned_bootstrap_validator_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_STATIC_PASS
close_project
''')
        (derived / 'nowave.tcl').write_text('run all\nquit\n')
        work = attempt / 'work'
        run_cwd = work / 'vivado/owned_bootstrap_validator.sim/sim_1/behav/xsim'
        commands = {'tool_version': [str(owned.VIVADO), '-version'],
                    'static': [str(owned.VIVADO), '-mode', 'batch', '-notrace',
                               '-log', str(attempt / 'vivado.log'), '-journal', str(attempt / 'vivado.jou'),
                               '-source', str(derived / 'compile.tcl'), '-tclargs',
                               str(work), str(frozen), interface['module']]}
        for expected in expectations:
            name = expected['case']
            commands[name] = [str(owned.XSIM), TB_TOP + '_behav', '-tclbatch', str(derived / 'nowave.tcl'),
                              '-testplusarg', 'MESSAGE=' + expected['hex']['path'],
                              '-testplusarg', 'CASE=' + name,
                              '-testplusarg', 'PURPOSE=' + str(expected['purpose']),
                              '-testplusarg', 'CONTENT=' + str(expected['content']),
                              '-testplusarg', 'EXPECT_OK=' + str(int(expected['expectation'] == 'OK')),
                              '-testplusarg', 'MAX_CYCLES=1000000',
                              '-log', str(attempt / (name + '_xsim.log'))]
        manifest = {'schema': 'laya-owned-bootstrap-validator-input-v1', 'scope': SCOPE,
                    'files': records, 'derived_files': [owned.rec(p) for p in sorted(derived.iterdir())],
                    'fixture_files': [owned.rec(p) for p in sorted(fixture.iterdir())],
                    'generation': {'attempt': str(generation), 'receipt': owned.rec(generation / 'receipt.json'),
                                   'strict_top_ports': top_ports, 'measured_in_this_attempt': False},
                    'nested_interface': interface, 'source_audit': source_audit,
                    'expected': expectations, 'planned_commands': commands,
                    'launcher': owned.rec(attempt / 'launcher.json'),
                    'tools': {n: owned.rec(owned.VIVADO.with_name(n)) for n in ['vivado', 'xsim', 'xvlog', 'xelab']},
                    'python': owned.rec(sys.executable), 'cases_separate_simulation_processes': True,
                    'static': {'rss_gib': 24, 'seconds': 1800, 'semantic_stall_seconds': 120},
                    'rtl_per_case': {'rss_gib': 8, 'seconds': 120, 'semantic_stall_seconds': 120,
                                     'maximum_cycles': 1000000}}
        owned.write_json(attempt / 'input_manifest.json', manifest)
        result['input_manifest'] = owned.rec(attempt / 'input_manifest.json')
        save()
        guard = frozen / MODULE / 'tb/production_guard.py'

        def run_stage(name, marker=None):
            output = attempt / ('guard_' + name)
            static = name == 'static'
            command = [sys.executable, str(guard), '--out', str(output), '--cwd',
                       str(run_cwd if name not in ['tool_version', 'static'] else attempt),
                       '--rss-gib', '24' if static else '8',
                       '--timeout-seconds', '1800' if static else '120',
                       '--semantic-stall-seconds', '120', '--', *commands[name]]
            process = subprocess.run(command, cwd=attempt)
            gp = output / 'guard_result.json'
            guarded = json.loads(gp.read_text()) if gp.is_file() else None
            lp = output / 'driver.log'
            body = lp.read_text(errors='replace') if lp.is_file() else ''
            okay = (process.returncode == 0 and guarded is not None and guarded['child_exit_code'] == 0
                    and guarded['trigger'] is None and (marker is None or body.count(marker) == 1)
                    and not re.search(r'(?:Fatal:|FATAL:|ERROR:)', body))
            operation = {'status': 'PASS' if okay else 'COST_STOP' if guarded and guarded['trigger'] else 'FAIL',
                         'started': True, 'command': commands[name], 'guard_command': command,
                         'runner_exit_code': process.returncode, 'guard': guarded,
                         'raw_files': [owned.rec(p) for p in sorted(output.rglob('*')) if p.is_file()],
                         'driver_log': owned.rec(lp) if lp.is_file() else None}
            if name not in ['tool_version', 'static']:
                observations = [l for l in body.splitlines() if l.startswith('FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_')]
                if (len([l for l in observations if '_START ' in l]) != 1 or
                        len([l for l in observations if '_DONE ' in l]) != 1):
                    okay = False
                    operation['status'] = 'FAIL'
                operation['observations'] = observations
            result['operations'][name] = operation
            if not okay:
                result['status'] = operation['status']
            save()
            print('FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_STAGE case=' + name + ' status=' + operation['status'], flush=True)
            return okay

        if not run_stage('tool_version') or not run_stage('static', 'FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_STATIC_PASS'):
            return 1
        staged = []
        for source_path in sorted((frozen / 'external/program_rtl').glob('*.dat')):
            target = run_cwd / source_path.name
            shutil.copyfile(source_path, target)
            if any(owned.rec(source_path)[k] != owned.rec(target)[k] for k in ['bytes', 'sha256']):
                raise RuntimeError('actual generated DAT staging mismatch')
            staged.append({'source': owned.rec(source_path), 'staged': owned.rec(target)})
        result['rom_dat_staging'] = staged
        save()
        for expected in expectations:
            name = expected['case']
            if not run_stage(name, 'FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_RTL_PASS case=' + name + ' '):
                return 1
        result['status'] = 'PASS_SCOPED_RTL_OWNED_BOOTSTRAP_VALIDATOR'
        result['vivado_raw_files'] = [owned.rec(p) for p in sorted(work.rglob('*.log'))]
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
