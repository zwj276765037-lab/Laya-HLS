#!/usr/bin/env python3
"""Freeze/run the finite LTP1/old-LTX transport collector; no HLS invocation."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MARKER = 'FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_RTL_PASS'
CASE_MARKER = 'FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_CASE_PASS'
SCRIPT_MARKER = 'FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_SCRIPT_PASS'
RETRY_MARKER = 'FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_RETRY_PASS'
PENDING_HOST01_RECEIPT_SHA = '60d2d241cc5ccd1b0b293e7075cf82ded41e0b17e4385daa9a435a4146751e4a'
KINDS = ['end_cleanup', 'end_ordinary', 'invalidate_cleanup', 'invalidate_ordinary',
         'release', 'claim', 'begin', 'publish', 'compute', 'producer']
POSITIVE = {
    'end_cleanup_cancel_before_first': 'end_cleanup',
    'end_ordinary_live_changes': 'end_ordinary',
    'invalidate_cleanup': 'invalidate_cleanup', 'invalidate_ordinary': 'invalidate_ordinary',
    'release_is_transport_only': 'release', 'claim_is_transport_only': 'claim',
    'begin_is_transport_only': 'begin', 'publish_is_transport_only': 'publish',
    'compute_is_transport_only': 'compute', 'producer_is_transport_only': 'producer',
    'no_hold_controlled_route0': 'no_hold',
}
NEGATIVE = ['bad_A_reserved', 'wrong_A_session', 'wrong_K_sequence', 'wrong_K_handoff',
            'wrong_K_model', 'wrong_physical_route', 'foreign_expected_action']
NEGATIVE += [f'metadata_fault_{i}' for i in range(11)]
NEGATIVE += [f'source_full_word_fault_{i}' for i in range(3)]
NEGATIVE += ['no_hold_invented_S']
CASES = [*POSITIVE, *NEGATIVE]
RTL_NAMES = ['laya_model_identity_13bo_generated_v1', 'laya_compute_portal_layout_v1',
             'laya_generated_provenance_layout_v1', 'laya_private_fifo2_v1',
             'laya_executor_transaction_collector_v1']
SCOPE = (
    'One bounded transport candidate: 33 actual 512-bit LTP1 FIFO pops, complete '
    'LAD1/A and old held K reference checks, physical route, the complete 512B '
    'expected action, full LTX identity/model against old A, and all 1536 actual '
    'source LTX bytes against the retained original FSM snapshot. Only then '
    'are immutable original bytes offered on the existing adapter ap_fifo '
    'interface, with a separate 24 actual adapter-peer pops. Three real depth2 '
    'FIFOs provide metadata, source LTX and an opaque 16-word controlled LTC '
    'return whose actual caller pops alone release the candidate. Thirty-three '
    'reset-separated cases cover all three ordinary kinds including RELEASE, '
    'cancel before first metadata pop, persistent revocation/live changes, '
    '33/24 prefixes, adapter and LTC tail2/tail1 waits12, one matching real '
    'second candidate without reset and with persistent revoke, wrong A/K/physical '
    'route/full action/header/identity/model/source bytes and no invented HOLD. '
    'Independent LTP host01 literals and whole byte actual host codec oracles '
    'are frozen; existing owned-program host04 full GRANTED/LAP literals supply '
    'the controlled old K and expected LAX. The production expected-action '
    'export from the actual LAP consumer is not connected in this pilot. '
    'FSM exporter, A/K/LAP consumers and adapter/F10/sidecar peers are controlled. '
    'candidate_verified is transport equality only: full LTX syntax/reserved '
    'semantic/canonical parsing and exact remote cleanup authorization remain '
    'with the actual managed adapter and sole hub, neither run here. No LTC '
    'codec/LOCAL_REJECT, hub cleanup permission/terminal, publication, allocation, '
    'retirement, same-runtime C, CLOSED/rearm, resources/timing/board claim. '
    'Route0 is a controlled no-HOLD predecessor source, not a wired real '
    'predecessor FSM pending outlet. No reset or FIFO clear within a case.'
)
TCL = r'''if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project executor_transaction_collector [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach name {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_executor_transaction_collector_v1} {
  add_files -norecurse [file join $module rtl ${name}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_transaction_collector_tb_v1.sv]
set_property top laya_executor_transaction_collector_v1 [get_filesets sources_1]
set_property top laya_executor_transaction_collector_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set path [file join $work vivado executor_transaction_collector.sim sim_1 behav xsim simulate.log]
set stream [open $path r];set body [read $stream];close $stream
if {[regexp -all -line {^FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_RTL_PASS(?: |$)} $body]!=1 ||
    [regexp -nocase {(^|\n)[ \t]*(Fatal:|ERROR:)} $body]} {
  error "transaction collector assertion/marker failed: $path"
}
puts FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_SCRIPT_PASS
close_project
'''


def rec(path):
    path = Path(path).resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def write_json(path, value):
    Path(path).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def launcher_state():
    available = next(int(line.split()[1]) for line in Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    io = subprocess.run(['/usr/bin/ionice', '-p', str(os.getpid())], check=True,
                        capture_output=True, text=True).stdout.strip()
    result = {'cpu_affinity': sorted(os.sched_getaffinity(0)),
              'nice': os.getpriority(os.PRIO_PROCESS, 0), 'ionice': io,
              'mem_available_kib': available}
    result['pass'] = result['cpu_affinity'] == [0, 1, 2, 3] and result['nice'] == 19 and \
        io.startswith('idle') and available > 192 * 1024 * 1024
    return result


def read_hex(path, beats):
    lines = Path(path).read_text().splitlines()
    if len(lines) != beats or any(re.fullmatch(r'[0-9a-fA-F]{128}', x) is None for x in lines):
        raise RuntimeError('incomplete or unknown-valued 512-bit hex: ' + str(path))
    return b''.join(int(line, 16).to_bytes(64, 'little') for line in lines)


def hex_text(packet):
    if len(packet) % 64:
        raise RuntimeError('partial 512-bit frame')
    return ''.join(format(int.from_bytes(packet[i:i+64], 'little'), '0128x') + '\n'
                   for i in range(0, len(packet), 64))


def validate_literals(packets, hold, lap):
    """Byte/layout cross-check only; the prior actual full codec is the oracle."""
    owner, action = packets['owner'], packets['action']
    if len(owner) != 1024 or len(action) != 512 or len(hold) != 1024 or len(lap) != 1024:
        raise RuntimeError('complete A/K/LAP/action size required')
    if lap[512:1024] != action or lap[:8] != struct.pack('<IHH', 0x3150414c, 1, 16):
        raise RuntimeError('actual program LAP body differs from host01 action literal')
    key = struct.unpack_from('<4Q', lap, 16)
    if hold[:8] != struct.pack('<IHH', 0x3143484c, 1, 16) or hold[8] != 4 or \
            struct.unpack_from('<QQ', hold, 776) != key[:2] or \
            struct.unpack_from('<Q', hold, 16)[0] != key[2] or \
            struct.unpack_from('<Q', hold, 680)[0] != key[3] or \
            hold[64:148] != owner[64:148] or hold[160:576] != owner[160:576]:
        raise RuntimeError('full frozen GRANTED old K/LAD1/LAP association changed')
    role = hold[604]  # OwnerDescriptor wire role = 576 + 28, not Message ABI.
    if role >= 13 or not (struct.unpack_from('<I', owner, 12)[0] & (1 << role)) or \
            hold[40:64] != owner[576+role*24:600+role*24]:
        raise RuntimeError('old held B base differs from known full A physical role')
    for name in KINDS + ['no_hold']:
        meta, tx = packets[name+'_ltp'], packets[name+'_ltx']
        if len(meta) != 2112 or len(tx) != 1536 or meta[64:576] != action or meta[576:] != tx:
            raise RuntimeError('full LTP/LAX/LTX literal byte association changed: ' + name)
        expected_key = key if name != 'no_hold' else (*key[:2], 0, 0)
        if meta[:8] != struct.pack('<IHH', 0x3150544c, 1, 33) or \
                struct.unpack_from('<4Q', meta, 16) != expected_key or \
                meta[8:10] != bytes([0, 0] if name == 'no_hold' else [1, 1]) or \
                tx[64:148] != owner[64:148] or tx[160:576] != owner[160:576]:
            raise RuntimeError('literal complete A/K/route/identity/model check: ' + name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--pending-host', type=Path, required=True)
    parser.add_argument('--program-host', type=Path, required=True)
    parser.add_argument('--prepare-only', action='store_true')
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    frozen = attempt / 'frozen'
    result = {'schema': 'laya-executor-transaction-collector-rtl-receipt-v1', 'status': 'PREPARING',
              'scope': SCOPE, 'rtl': {'status': 'NOT_RUN', 'started': False},
              'actual_FSM_exporter': 'NOT_RUN', 'actual_adapter_F10_sidecar': 'NOT_RUN',
              'LTC_codec': 'NOT_RUN', 'hub_cleanup_retirement': 'NOT_RUN', 'same_runtime_C': 'NOT_RUN'}
    write_json(attempt / 'receipt.json', result)
    records, generated = [], []

    def freeze(source, relative, expected=None):
        before = rec(source)
        if expected is not None and before != expected:
            raise RuntimeError('prior frozen identity changed: ' + str(source))
        target = frozen / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        copied = rec(target)
        if rec(source) != before or (copied['bytes'], copied['sha256']) != (before['bytes'], before['sha256']):
            raise RuntimeError('input changed during freeze: ' + str(source))
        records.append({'relative': str(relative), 'original': before, 'frozen': copied})
        return target

    try:
        launcher = launcher_state()
        write_json(attempt / 'launcher.json', launcher)
        result['launcher'] = rec(attempt / 'launcher.json')
        if not launcher['pass']:
            raise RuntimeError('CPU0-3/nice19/idle I/O/MemAvailable>192GiB launcher rejected')
        host = args.pending_host.resolve()
        if host.name != 'executor_transaction_pending_host_01':
            raise RuntimeError('the frozen independent LTP host01 source is required')
        if rec(host / 'receipt.json')['sha256'] != PENDING_HOST01_RECEIPT_SHA:
            raise RuntimeError('the completed original LTP host01 receipt identity changed')
        host_receipt = json.loads((host / 'receipt.json').read_text())
        host_manifest = json.loads((host / 'input_manifest.json').read_text())
        operations = host_receipt.get('operations', {})
        if host_receipt.get('status') != 'PASS_SCOPED_HOST' or \
                any(operations.get(k, {}).get('status') != 'PASS' for k in ['host', 'oracle']) or \
                host_receipt.get('input_manifest') != rec(host / 'input_manifest.json') or \
                host_manifest.get('full_request_decoder_enabled') is not True:
            raise RuntimeError('actual full-codec LTP host01 PASS/oracle/manifest required')
        oracle = host_receipt.get('literal_byte_oracle', [])
        if len(oracle) != 11:
            raise RuntimeError('all eleven whole-byte host literal oracles required')
        for row in oracle:
            if not row.get('pass') or row.get('bytes_compared') != 2112 or \
                    rec(row['actual']['path']) != row['actual'] or rec(row['expected']['path']) != row['expected'] or \
                    Path(row['actual']['path']).read_bytes() != Path(row['expected']['path']).read_bytes():
                raise RuntimeError('host original 2112-byte literal oracle changed')
            for kind in ['actual', 'expected']:
                freeze(Path(row[kind]['path']), Path('external/pending_host') / Path(row[kind]['path']).name, row[kind])
        expected = {Path(row['path']).name: row for row in host_manifest['fixture_inputs']}
        packets = {}
        for name in ['owner', 'action'] + [n+s for n in KINDS for s in ['_ltp', '_ltx']] + ['no_hold_ltp']:
            source = host / 'fixture' / (name + '.bin')
            # LTP expected packets were already frozen from the whole-byte oracle.
            target = frozen / 'external/pending_host' / source.name
            if not target.exists():
                target = freeze(source, Path('external/pending_host') / source.name, expected[source.name])
            elif rec(source) != expected[source.name]:
                raise RuntimeError('host fixture no longer matches its input record')
            packets[name] = target.read_bytes()
        packets['no_hold_ltx'] = packets['end_cleanup_ltx']
        for name in ['receipt.json', 'input_manifest.json']:
            freeze(host / name, Path('external/pending_host_run') / name)
        # Preserve the exact independent generator and real codec test provenance.
        for rel in ['tests/executor_transaction_pending_test.cpp', str(MODULE / 'tb/run_executor_transaction_pending.py')]:
            row = next(row for row in host_manifest['files'] if row['relative'] == rel)
            freeze(Path(row['frozen']['path']), Path('external/pending_host_sources') / rel, row['frozen'])

        program = args.program_host.resolve()
        if program.name != 'graph_program_owned_host_04':
            raise RuntimeError('the existing owned-program host04 GRANTED/LAP source is required')
        pr = json.loads((program / 'receipt.json').read_text())
        if pr.get('status') != 'PASS_SCOPED_HOST' or \
                pr.get('operations', {}).get('host_success', {}).get('status') != 'PASS' or \
                pr.get('operations', {}).get('oracle', {}).get('status') != 'PASS' or \
                pr.get('input_manifest') != rec(program / 'input_manifest.json'):
            raise RuntimeError('owned-program host04 full literal PASS required')
        p_expected = {Path(row['path']).name: row for row in pr['fixture_files']}
        hold = freeze(program / 'fixture/control_4.bin', Path('external/program_host/control_4.bin'), p_expected['control_4.bin']).read_bytes()
        lap = freeze(program / 'fixture/pending.bin', Path('external/program_host/pending.bin'), p_expected['pending.bin']).read_bytes()
        for name in ['receipt.json', 'input_manifest.json']:
            freeze(program / name, Path('external/program_host_run') / name)
        validate_literals(packets, hold, lap)
        files = [MODULE / ('rtl/' + n + '.sv') for n in RTL_NAMES]
        files += [MODULE / 'tb/laya_executor_transaction_collector_tb_v1.sv',
                  MODULE / 'tb/run_executor_transaction_collector.py', MODULE / 'tb/production_guard.py',
                  Path('tools/hls_guard_helpers.py'), Path('include/laya_executor_transaction_pending.h'),
                  Path('hls/control/executor_transaction_pending.cpp')]
        for rel in files:
            freeze(ROOT / rel, rel)
        for name in ['executor_old_ltx_cleanup_contract_20261013.md', 'executor_managed_lpv_owner_contract_20261013.md',
                     'production_hls_partition_contract_20261012.md']:
            freeze(PROJECT / 'results' / name, Path('external/contracts') / name)
        fixture = attempt / 'fixture'
        fixture.mkdir()
        values = {**packets, 'hold_key': hold, 'expected_action': lap[512:1024],
                  'controlled_ltc': bytes((37+17*i) % 256 for i in range(1024))}
        for name, value in values.items():
            path = fixture / (name + '.hex')
            path.write_text(hex_text(value))
            if read_hex(path, len(value)//64) != value:
                raise RuntimeError('byte-preserving fixture conversion failed: ' + name)
            generated.append({'identity': rec(path), 'source': 'frozen independent full literal' if name != 'controlled_ltc'
                              else 'controlled opaque return peer; no LTC syntax/semantic claim'})
        tcl = attempt / 'run_executor_transaction_collector.tcl'
        tcl.write_text(TCL)
        vivado = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
        command = [str(vivado), '-mode', 'batch', '-notrace', '-log', str(attempt / 'vivado.log'),
                   '-journal', str(attempt / 'vivado.jou'), '-source', str(tcl),
                   '-tclargs', str(attempt / 'work'), str(frozen), str(fixture)]
        output = attempt / 'guard_rtl'
        guarded = [sys.executable, str(frozen / MODULE / 'tb/production_guard.py'), '--out', str(output),
                   '--cwd', str(frozen), '--rss-gib', '8', '--timeout-seconds', '120',
                   '--semantic-stall-seconds', '120', '--', *command]
        manifest = {'schema': 'laya-executor-transaction-collector-input-v1', 'scope': SCOPE,
                    'files': records, 'generated_files': generated, 'derived_tcl': rec(tcl),
                    'launcher': rec(attempt / 'launcher.json'), 'tool': rec(vivado),
                    'planned_rtl_command': command, 'planned_guard_command': guarded,
                    'case_count': len(CASES), 'case_names': CASES, 'cycle_cap': 40000,
                    'pending_literal_source': str(host), 'old_K_LAP_literal_source': str(program),
                    'profile': {'kind': 'finite_rtl_pilot', 'cpu_ids': [0, 1, 2, 3], 'nice': 19,
                                'io_class': 'idle', 'minimum_available_gib_exclusive': 192,
                                'rss_gib': 8, 'timeout_seconds': 120, 'semantic_stall_seconds': 120,
                                'one_heavy_tool_at_a_time': True}}
        write_json(attempt / 'input_manifest.json', manifest)
        result['input_manifest'] = rec(attempt / 'input_manifest.json')
        if args.prepare_only:
            result['status'] = 'PREPARED_NOT_RUN'
            write_json(attempt / 'receipt.json', result)
            print('FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_PREPARED_NOT_RUN', flush=True)
            return 0
        result['status'] = 'RUNNING'
        write_json(attempt / 'receipt.json', result)
        done = subprocess.run(guarded, cwd=frozen)
        gp = output / 'guard_result.json'
        observed_guard = json.loads(gp.read_text()) if gp.is_file() else None
        log = output / 'driver.log'
        body = log.read_text(errors='replace') if log.is_file() else ''
        markers = [x for x in body.splitlines() if x.startswith(MARKER + ' ')]
        case_markers = [x for x in body.splitlines() if x.startswith(CASE_MARKER + ' ')]
        cases_complete = len(case_markers) == len(CASES) and all(
            sum(re.match(re.escape(CASE_MARKER) + rf' id={i} case={re.escape(name)} ', x) is not None
                for x in case_markers) == 1 for i, name in enumerate(CASES, 1))
        passed = done.returncode == 0 and observed_guard is not None and \
            observed_guard.get('child_exit_code') == 0 and observed_guard.get('trigger') is None and \
            len(markers) == 1 and cases_complete and body.count(SCRIPT_MARKER) == 1 and \
            body.count(RETRY_MARKER + ' started=2 released=2 persistent_revoked=1 no_reset=1') == 1 and \
            re.search(r'(?im)^\s*(Fatal:|ERROR:)', body) is None
        result['rtl'] = {'status': 'PASS' if passed else 'FAIL', 'started': True,
                         'runner_exit_code': done.returncode, 'guard': observed_guard,
                         'markers': markers, 'case_markers': case_markers,
                         'raw_files': [rec(p) for p in sorted(output.rglob('*')) if p.is_file()]}
        comparisons = []
        if passed:
            for name, source in POSITIVE.items():
                path = fixture / ('actual_' + name + '_ltx.hex')
                actual = read_hex(path, 24)
                expected_packet = packets[source+'_ltx']
                comparisons.append({'case': name, 'actual': rec(path), 'bytes_compared': 1536,
                                    'expected_sha256': hashlib.sha256(expected_packet).hexdigest(),
                                    'pass': actual == expected_packet})
            passed = all(x['pass'] for x in comparisons) and len(comparisons) == 11
        result['actual_adapter_pop_byte_oracle'] = comparisons
        result['vivado_logs'] = [rec(p) for p in sorted((attempt / 'work').rglob('*.log')) if p.is_file()]
        for path in [attempt / 'vivado.log', attempt / 'vivado.jou']:
            if path.is_file(): result['vivado_logs'].append(rec(path))
        # Freeze verification remains mandatory after the child run.
        for row in records:
            if rec(row['frozen']['path']) != row['frozen']:
                raise RuntimeError('frozen RTL/fixture input mutated during child run')
        for row in generated:
            if rec(row['identity']['path']) != row['identity']:
                raise RuntimeError('literal fixture input mutated during child run')
        if rec(tcl) != manifest['derived_tcl']:
            raise RuntimeError('derived Tcl mutated during child run')
        result['status'] = 'PASS_SCOPED_RTL_TRANSACTION_COLLECTOR' if passed else \
            'COST_STOP' if observed_guard and observed_guard.get('trigger') is not None else 'FAIL'
        write_json(attempt / 'receipt.json', result)
        print('FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_RUN_' + result['status'], flush=True)
        return 0 if passed else 1
    except Exception as error:
        result['status'] = 'FAIL'
        result['error'] = {'type': type(error).__name__, 'message': str(error)}
        result['frozen_files_at_failure'] = records
        write_json(attempt / 'receipt.json', result)
        raise


if __name__ == '__main__':
    raise SystemExit(main())
