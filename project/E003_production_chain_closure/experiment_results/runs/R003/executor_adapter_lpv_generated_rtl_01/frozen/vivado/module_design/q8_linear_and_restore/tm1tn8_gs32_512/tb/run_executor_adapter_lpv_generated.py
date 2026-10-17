#!/usr/bin/env python3
"""Finite actual frozen F10 + sidecar + unique portal; controlled LTX/AXI peers."""
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
VIVADO = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
TOP_SHA = '42f9056ad25de017d756f333de407925ae9f555c87f68c4b74db75a01471b558'
SIDECAR_SHA = '8151a340a19cb40911880694455546095c47e6f3a6804390a2294f5f604e1eee'
PORTAL_SHA = '095a98cdfd100e267580dc8ecbcbc73f7f62d7b3dac3795dc36775326145d332'
CASE_MARKER = 'FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_CASE_PASS'
MARKER = 'FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_PASS'
STATIC_MARKER = 'FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_STATIC_PASS'
CASE_NAMES = {
    0: ['active_claim', 'begin', 'bad_end', 'end', 'active_invalidate'],
    1: ['active_claim', 'begin', 'end'],
    2: ['claim'],
    3: ['claim', 'invalidate'],
}
RTL_NAMES = [
    'laya_model_identity_13bo_generated_v1', 'laya_compute_portal_layout_v1',
    'laya_generated_provenance_layout_v1', 'laya_private_fifo2_v1',
    'laya_generated_provenance_v1', 'laya_generated_provenance_hub_v1',
    'laya_generated_provenance_portal_v1', 'laya_generated_store_monitor_v1',
    'laya_generated_provenance_axi_portal_v1', 'laya_admission_owner_layout_v1',
    'laya_controller_transaction_adapter_shell_v1', 'laya_executor_adapter_lpv_owner_v1',
]
SCOPE = (
    'Four independently reset finite RTL cases instantiate the actual generated '
    'HLS03 adapter SHA42f9056, actual F10 caller-consumption shell, frozen PASS '
    'LPV-owner sidecar, and exactly one actual managed AXI portal/transport/monitor/hub. '
    'Actual first LTX FIFO pop starts sidecar ownership; actual final 16th LTC caller '
    'pop releases it. All candidate/pending/response complete A and route metadata '
    'come from the sidecar actual handshakes. A comes from the actual portal whole '
    'record admission handshake and remains installed after local transaction drain. '
    'Independent frozen literals verify every actual 24 LTX, 16 raw generated LPV, '
    '8 actual portal LPA and generated adapter pops, and 16 normalized LTC writes '
    'and caller pops. Actual HLS semantic state/beat/cancel_at_accept must return '
    'to zero; no ap_ctrl helper or idle signal substitutes for final caller drain. '
    'Controlled LTX, A-install, link-backpressure and AXI producer/memory peers are '
    'explicit. A producer-local finish obligation is created by actual upstream AW '
    'and clears only on its controlled valid/ready finish after actual final B; '
    'this is independent of sidecar.txn_drained. Case0 normal CLAIM/BEGIN/wrong-origin '
    'END/matching error END/INVALIDATE includes held final B, held producer fence, '
    'unique terminal task and next LTX queued during LTC tail2/tail1. Case1 cancel '
    'occurs only after the real END first LTX pop and two actual raw LPV pushes; '
    'old raw/portal partial frames, LPA tail2/tail1, actual return FIFO and LTC tails '
    'drain with old A/route and one terminal. Case2 already presented successful '
    'CLAIM return survives revoke without inventing physical or typed retirement. '
    'Case3 normal CLAIM-only/INVALIDATE cleans the owner with no BEGIN, AXI or typed task. '
    'Frozen sidecar sticky txn_revoked blocks NEW post-revoke cleanup; both cancelled '
    'cases explicitly observe that known gap with cleanup first2 physically queued. '
    'No cleanup after revoke is admitted or claimed, and D-M003-EXECUTOR-OLD-LTX-CLEANUP-01 '
    'implementation is deferred to a separately owned interface change. No generated '
    'executor/program/LN, full tensor, same-runtime C chain, source AR/F9 validator, '
    'CLOSE/rearm, joint resources, new timing, OOC/P&R or board claim. Original HLS03 '
    'FAIL receipt remains FAIL; independent top-only port inspection supplies limited '
    '8-FIFO/no-top-ap_ctrl facts, not a rewritten HLS verdict.'
)
TCL = r'''if {[llength $argv]!=2} {error "usage: WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project executor_adapter_lpv_generated [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [lsort [glob [file join $frozen external adapter_rtl *.v]]]
foreach name {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1 laya_generated_store_monitor_v1 laya_generated_provenance_axi_portal_v1 laya_admission_owner_layout_v1 laya_controller_transaction_adapter_shell_v1 laya_executor_adapter_lpv_owner_v1} {
  add_files -norecurse [file join $module rtl ${name}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_adapter_lpv_generated_tb_v1.sv]
set_property top laya_command_provenance_adapter [get_filesets sources_1]
set_property top laya_executor_adapter_lpv_generated_tb_v1 [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_STATIC_PASS
close_project
'''
NOWAVE = 'run all\nquit\n'


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def verify(path, expected):
    observed = rec(path)
    if observed['bytes'] != expected['bytes'] or observed['sha256'] != expected['sha256']:
        raise RuntimeError('frozen input identity drift: ' + str(path))
    return observed


def launcher_state():
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    value = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
             'nice': os.getpriority(os.PRIO_PROCESS, 0),
             'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                      check=True, text=True, capture_output=True).stdout.strip(),
             'mem_available_kib': available,
             'required_mem_available_kib': 192 * 1024 * 1024}
    value['pass'] = (value['cpu_affinity'] == [0, 1, 2, 3] and value['nice'] == 19 and
                     value['ionice'].startswith('idle') and
                     available > value['required_mem_available_kib'])
    return value


def top_interface(path):
    """Inspect ONLY the actual top header and its port declarations."""
    source = path.read_text()
    clean = re.sub(r'/\*.*?\*/|//[^\n]*', '', source, flags=re.S)
    match = re.search(r'\bmodule\s+laya_command_provenance_adapter\s*\((.*?)\)\s*;', clean, re.S)
    if match is None:
        raise RuntimeError('real generated adapter top header absent')
    ports = [x.strip() for x in match.group(1).split(',')]
    if any(re.fullmatch(r'[A-Za-z_]\w*', p) is None for p in ports):
        raise RuntimeError('unexpected actual top port syntax')
    body = clean[match.end():].split('endmodule', 1)[0]
    declarations = {}
    for declaration in re.finditer(
            r'^\s*(input|output)\s+(?:(?:wire|reg)\s+)?(\[\s*\d+\s*:\s*\d+\s*\])?\s*(\w+)\s*;',
            body, re.M):
        direction, size, name = declaration.groups()
        bits = [int(x) for x in re.findall(r'\d+', size or '')]
        width = abs(bits[0] - bits[1]) + 1 if bits else 1
        if name in declarations:
            raise RuntimeError('duplicate top declaration: ' + name)
        declarations[name] = {'direction': direction, 'width': width}
    expected = {n: {'direction': 'input', 'width': 1} for n in ['ap_clk', 'ap_rst', 'cancel']}
    input_fifos = ['transaction_request', 'compute_response', 'provenance_response', 'producer_completion']
    output_fifos = ['transaction_completion', 'compute_command', 'provenance_command', 'producer_request']
    for fifo in input_fifos:
        expected[fifo + '_dout'] = {'direction': 'input', 'width': 512}
        expected[fifo + '_empty_n'] = {'direction': 'input', 'width': 1}
        expected[fifo + '_read'] = {'direction': 'output', 'width': 1}
    for fifo in output_fifos:
        expected[fifo + '_din'] = {'direction': 'output', 'width': 512}
        expected[fifo + '_full_n'] = {'direction': 'input', 'width': 1}
        expected[fifo + '_write'] = {'direction': 'output', 'width': 1}
    if len(ports) != 27 or set(ports) != set(expected) or declarations != expected:
        raise RuntimeError('actual top 8FIFO/27-port direction/width mismatch')
    forbidden = [name for name in ports if name in ['ap_start', 'ap_done', 'ap_idle', 'ap_ready']]
    if forbidden:
        raise RuntimeError('actual top has ap_ctrl ports: ' + str(forbidden))
    semantic = {}
    for name, width in [('state', 3), ('beat', 32), ('cancel_at_accept', 1)]:
        matches = list(re.finditer(r'\breg\s+\[\s*(\d+)\s*:\s*(\d+)\s*\]\s+' + name + r'\s*;', body))
        if len(matches) != 1 or abs(int(matches[0][1]) - int(matches[0][2])) + 1 != width:
            raise RuntimeError('actual generated terminal-state register drift: ' + name)
        semantic[name] = {'width': width, 'terminal_value': 0,
                          'hierarchy': 'f10.adapter.' + name}
    helpers = sorted(set(re.findall(r'\bgrp_\w+_ap_(?:start|done|idle|ready)\b', body)))
    return {'generated': rec(path), 'inspection': 'top_header_and_top_port_declarations_only',
            'top': 'laya_command_provenance_adapter', 'ports': ports, 'declarations': declarations,
            'fifo_interfaces': 8, 'fifo_signals': 24, 'top_ap_ctrl_ports': forbidden,
            'internal_helper_ap_ctrl_name_count': len(helpers),
            'internal_helper_ap_ctrl_examples': helpers[:16],
            'actual_semantic_terminal': semantic,
            'consumer_terminal': 'real final 16th LTC FIFO caller pop; independent of HLS state'}


def literal_bytes(path, beats):
    lines = path.read_text().splitlines()
    if len(lines) != beats or any(len(x) != 128 or re.fullmatch('[0-9a-fA-F]{128}', x) is None for x in lines):
        raise RuntimeError('incomplete actual/independent 512-bit frame: ' + str(path))
    return b''.join(int(line, 16).to_bytes(64, 'little') for line in lines)


def hex_bytes(blob):
    if len(blob) % 64:
        raise RuntimeError('wire blob is not a whole 512-bit frame')
    return ''.join(f'{int.from_bytes(blob[i:i+64], "little"):0128x}\n' for i in range(0, len(blob), 64))


def controlled_ltx(lpv):
    """Independent wire-offset mapping; no C++ build or RTL-generated gold."""
    if len(lpv) != 1024 or struct.unpack_from('<IH', lpv, 0) != (0x3156504c, 1):
        raise RuntimeError('independent complete LPV1 required')
    action = struct.unpack_from('<H', lpv, 6)[0]
    count = lpv[576]
    if action not in [1, 2, 3, 6] or count not in [1, 2]:
        raise RuntimeError('out-of-scope controlled LPV action/count')
    out = bytearray(1536)
    struct.pack_into('<IHHHH', out, 0, 0x3158544c, 1, 24, 2, action)
    out[16:24], out[24:32] = lpv[8:16], lpv[32:40]
    # This is the original request flag, not a managed permission or hub fact.
    struct.pack_into('<I', out, 32, 1 if action in [3, 6] else 0)
    out[64:576] = lpv[64:576]
    out[576:578] = lpv[40:42]
    out[578], out[579], out[580] = lpv[42], count, lpv[578]
    out[584:588], out[588:592], out[592:600] = lpv[44:48], lpv[48:52], lpv[56:64]
    out[600:604], out[608:616] = lpv[580:584], lpv[584:592]
    if count > 1:
        out[616:624] = lpv[592:600]
    for i in range(count):
        old = lpv[608 + i * 128:736 + i * 128]
        new = bytearray(128)
        # External refs carry region at +6; LTX stores region at descriptor+16/+17.
        new[0:6], new[8:14] = old[0:6], old[8:14]
        new[16], new[17] = old[6], old[14]
        new[18:31], new[32:88] = old[16:29], old[32:88]
        out[624 + i * 128:752 + i * 128] = new
        out[880 + i * 64:944 + i * 64] = lpv[864 + i * 64:928 + i * 64]
    return bytes(out)


def independent_ltc(lpv, lpa):
    """Normalize the independent frozen LPA literal, including its actual flags."""
    if len(lpv) != 1024 or len(lpa) != 512 or struct.unpack_from('<IH', lpa) != (0x3141504c, 1):
        raise RuntimeError('independent complete LPV/LPA pair required')
    action = struct.unpack_from('<H', lpv, 6)[0]
    status = struct.unpack_from('<H', lpa, 24)[0]
    flags = lpa[26]
    count = lpv[576]
    expected_refs = bytearray(32)
    for i in range(count):
        expected_refs[16*i:16*i+16] = lpv[608+128*i:624+128*i]
    scope = bool(flags & 2)
    scope_ok = scope == (status == 0) if action == 2 else (status != 0 or not scope) if action == 3 else not scope
    binding = (lpa[6:16] == lpv[6:16] and lpa[16:24] == lpv[32:40] and
               lpa[64:160] == lpv[64:160] and lpa[45] == count and
               lpa[160:192] == expected_refs and scope_ok and
               (status != 0 or bool(flags & 1)) and
               bool(flags & 4) == (action == 5 and status == 0))
    if not binding or status > 9 or flags & ~7 or lpa[27] or lpa[46:48] != b'\0\0' or any(lpa[192:]):
        raise RuntimeError('independent frozen response is not a complete bound finite LPV result')
    # Generic successful END also supports the historical C++ cross-check.
    # The selected managed error END carries no output but has observed bytes.
    if action == 3 and status == 0:
        if lpa[40:44] != lpv[580:584] or lpa[44] != lpv[578] or lpv[40:42] != b'\0\0' or \
                lpa[48:56] != lpv[584:592] or (count > 1 and lpa[56:64] != lpv[592:600]):
            raise RuntimeError('successful independent END output/observed binding mismatch')
    elif lpa[40:45] != b'\0' * 5 or (action != 3 and any(lpa[48:64])):
        raise RuntimeError('unexpected finite output-unit/observed semantics')
    out = bytearray(1024)
    ltc_flags = 1 | 2 | (4 if flags & 1 else 0) | (8 if flags & 2 else 0) | \
        (16 if flags & 1 and not flags & 2 else 0) | (32 if flags & 4 else 0)
    struct.pack_into('<IHHHHI', out, 0, 0x3143544c, 1, 16, 2, action, ltc_flags)
    out[16:24], out[24:32] = lpa[8:16], lpa[16:24]
    out[32:34], out[34], out[35] = lpa[24:26], lpa[44], lpa[45]
    out[36:40], out[40:48], out[48:52] = lpa[28:32], lpa[32:40], lpa[40:44]
    out[56:64], out[64:72] = lpa[48:56], lpa[56:64]
    out[72:156], out[156:168] = lpa[64:148], lpa[148:160]
    for i in range(4):
        out[168+8*i:174+8*i] = lpa[160+8*i:166+8*i]
        out[200+i] = lpa[166+8*i]
    return bytes(out)


def prior(attempt, status):
    receipt_path = attempt / 'receipt.json'
    receipt = json.loads(receipt_path.read_text())
    if receipt.get('status') != status:
        raise RuntimeError('prior scoped verdict mismatch: ' + str(attempt))
    verify(attempt / 'input_manifest.json', receipt['input_manifest'])
    return receipt, json.loads((attempt / 'input_manifest.json').read_text())


def run_result(command, output, marker):
    process = subprocess.run(command)
    gp, log = output / 'guard_result.json', output / 'driver.log'
    observed = json.loads(gp.read_text()) if gp.is_file() else None
    body = log.read_text(errors='replace') if log.is_file() else ''
    marker_lines = [line for line in body.splitlines() if line.startswith(marker + ' ') or line == marker]
    exceptions = [line for line in body.splitlines() if 'FATAL_ERROR:' in line or 'exceptional condition' in line]
    passed = (process.returncode == 0 and observed is not None and
              observed.get('child_exit_code') == 0 and observed.get('trigger') is None and
              len(marker_lines) == 1 and not exceptions and
              re.search(r'(^|\n)\s*(?:Fatal:|ERROR:|FATAL_ERROR:)', body) is None)
    value = {'status': 'PASS' if passed else 'COST_STOP' if observed and observed.get('trigger') else 'FAIL',
             'started': True, 'runner_exit_code': process.returncode, 'guard': observed,
             'marker': marker_lines, 'simulator_exception_lines': exceptions,
             'failure_kind': 'SIMULATOR_INTERNAL_EXCEPTION' if exceptions else None,
             'raw_files': [rec(p) for p in sorted(output.rglob('*')) if p.is_file()]}
    return value, body


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--attempt', type=Path, required=True)
    p.add_argument('--generation', type=Path, required=True)
    p.add_argument('--adapter-rtl-attempt', type=Path, required=True)
    p.add_argument('--sidecar-attempt', type=Path, required=True)
    p.add_argument('--managed-lpv-attempt', type=Path, required=True)
    p.add_argument('--prepare-only', action='store_true')
    args = p.parse_args()
    attempt = args.attempt.resolve()
    # Prior evidence and top checks happen before allocating a new attempt.
    generation, adapter_old = args.generation.resolve(), args.adapter_rtl_attempt.resolve()
    sidecar_old, managed_old = args.sidecar_attempt.resolve(), args.managed_lpv_attempt.resolve()
    adapter_receipt, adapter_manifest = prior(adapter_old, 'PASS_SCOPED_RTL_INDEPENDENT_PROTOCOL_CASES')
    sidecar_receipt, sidecar_manifest = prior(sidecar_old, 'PASS_SCOPED_RTL_SIDECAR')
    managed_receipt, managed_manifest = prior(managed_old, 'PASS')
    original_hls = json.loads((generation / 'receipt.json').read_text())
    verify(generation / 'input_manifest.json', original_hls['input_manifest'])
    g = original_hls.get('guard_result', {})
    if original_hls.get('status') != 'FAIL' or original_hls.get('exit_code') != 0 or \
            g.get('child_exit_code') != 0 or g.get('trigger') is not None:
        raise RuntimeError('original HLS03 FAIL/tool-completed identity required; verdict is not rewritten')
    candidates = list((generation / 'work').glob('**/syn/verilog/laya_command_provenance_adapter.v'))
    if len(candidates) != 1 or rec(candidates[0])['sha256'] != TOP_SHA or \
            original_hls['port_evidence']['generated']['sha256'] != TOP_SHA:
        raise RuntimeError('actual SHA42f9056 generated candidate missing or changed')
    verify(Path(original_hls['port_evidence']['generated']['path']), original_hls['port_evidence']['generated'])
    ports = top_interface(candidates[0])
    if ports['internal_helper_ap_ctrl_name_count'] == 0 or \
            not all(original_hls['port_evidence']['forbidden_control'].values()):
        raise RuntimeError('original whole-file helper-control false-positive evidence drift')
    attempt.mkdir(exist_ok=False)
    frozen, fixture = attempt / 'frozen', attempt / 'fixture'
    fixture.mkdir()
    records = []
    result = {'schema': 'laya-executor-adapter-lpv-generated-receipt-v1',
              'status': 'PREPARING', 'scope': SCOPE, 'cases': {},
              'known_gap': 'frozen sidecar blocks new END/INVALIDATE LTX after sticky revoke',
              'original_hls_status': original_hls['status']}

    def freeze(source, relative, expected=None):
        source = source.resolve()
        identity = verify(source, expected) if expected else rec(source)
        target = frozen / relative
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
        write_json(attempt / 'launcher.json', launcher)
        result['launcher'] = rec(attempt / 'launcher.json')
        if not launcher['pass']:
            raise RuntimeError('CPU0-3/nice19/idle-I-O/MemAvailable>192GiB preflight failed')
        for label, old, manifest in [('adapter', adapter_old, adapter_manifest),
                                     ('managed', managed_old, managed_manifest),
                                     ('sidecar', sidecar_old, sidecar_manifest)]:
            freeze(old / 'receipt.json', Path('external/prior_' + label) / 'receipt.json')
            freeze(old / 'input_manifest.json', Path('external/prior_' + label) / 'input_manifest.json')
            for row in manifest['files']:
                source = Path(row['frozen']['path'])
                relative = source.relative_to(old / 'frozen')
                is_runtime = (relative.parts[:2] == ('external', 'adapter_rtl') or
                              relative == MODULE / 'tb/production_guard.py' or
                              relative == Path('tools/hls_guard_helpers.py') or
                              relative in [MODULE / ('rtl/' + name + '.sv') for name in RTL_NAMES])
                destination = relative if is_runtime else Path('external/prior_' + label + '_source') / relative
                freeze(source, destination, row['frozen'])
        # No source implementation or live shared dependency is substituted for a
        # passed frozen DUT. Generation itself is independently inspected here.
        generated = sorted((frozen / 'external/adapter_rtl').iterdir())
        original_generated = sorted(p for p in candidates[0].parent.iterdir() if p.suffix in {'.v', '.dat'})
        if {p.name for p in generated} != {p.name for p in original_generated}:
            raise RuntimeError('generated .v/.dat closure is not complete')
        for source in original_generated:
            verify(source, rec(frozen / 'external/adapter_rtl' / source.name))
        for name, sha in [('external/adapter_rtl/laya_command_provenance_adapter.v', TOP_SHA),
                          (str(MODULE / 'rtl/laya_executor_adapter_lpv_owner_v1.sv'), SIDECAR_SHA),
                          (str(MODULE / 'rtl/laya_generated_provenance_axi_portal_v1.sv'), PORTAL_SHA)]:
            if rec(frozen / name)['sha256'] != sha:
                raise RuntimeError('frozen actual DUT identity mismatch: ' + name)
        for name in ['receipt.json', 'input_manifest.json',
                     'work/hls/syn/report/laya_command_provenance_adapter_csynth.rpt',
                     'work/hls/syn/report/csynth_design_size.rpt']:
            freeze(generation / name, Path('external/generation_independent') / name)
        for name in ['production_hls_partition_contract_20261012.md',
                     'executor_managed_lpv_owner_contract_20261013.md',
                     'executor_old_ltx_cleanup_contract_20261013.md']:
            freeze(PROJECT / 'results' / name, Path('external/contracts') / name)
        for name in ['laya_executor_adapter_lpv_generated_tb_v1.sv', 'run_executor_adapter_lpv_generated.py']:
            freeze(ROOT / MODULE / 'tb' / name, MODULE / 'tb' / name)
        admission = {}
        for row in managed_manifest['admission_host']:
            name = Path(row['frozen']['path']).name
            target = freeze(Path(row['frozen']['path']), Path('external/admission_host') / name, row['frozen'])
            if name.endswith('.bin'):
                admission[name] = target.read_bytes()
        required_a = {'actual_admission_owner.bin', 'admission_owner.bin'}
        if set(admission) != required_a or admission['actual_admission_owner.bin'] != admission['admission_owner.bin']:
            raise RuntimeError('actual C++ A/independent full A provenance missing or inconsistent')
        literals = {Path(row['path']).name: row for row in managed_manifest['fixture_files']}
        fixture_records, derived = [], []
        names = sorted(set(sum(CASE_NAMES.values(), [])))
        for name in ['admission.hex'] + [n + suffix for n in names for suffix in ['.hex', '_gold.hex']]:
            source = managed_old / 'fixture' / name
            verify(source, literals[name])
            target = fixture / name
            shutil.copyfile(source, target)
            fixture_records.append({'original': rec(source), 'frozen': rec(target)})
        a = literal_bytes(fixture / 'admission.hex', 16)
        if a != admission['actual_admission_owner.bin']:
            raise RuntimeError('actual A binary and frozen 16-beat A literal differ')
        for name in names:
            lpv = literal_bytes(fixture / (name + '.hex'), 16)
            lpa = literal_bytes(fixture / (name + '_gold.hex'), 8)
            if lpv[64:148] != a[64:148] or lpv[160:576] != a[160:576]:
                raise RuntimeError('controlled LTX model/numeric identity differs from actual admitted A')
            for kind, blob in [('ltx', controlled_ltx(lpv)), ('ltc', independent_ltc(lpv, lpa))]:
                binary, hexf = fixture / (name + '_' + kind + '.bin'), fixture / (name + '_' + kind + '.hex')
                binary.write_bytes(blob)
                hexf.write_text(hex_bytes(blob))
                if literal_bytes(hexf, len(blob) // 64) != blob:
                    raise RuntimeError('independent derived binary/hex roundtrip mismatch')
                derived.append({'name': name, 'wire': kind.upper() + '1',
                                'source_lpv': rec(fixture / (name + '.hex')),
                                'source_lpa_gold': rec(fixture / (name + '_gold.hex')),
                                'binary': rec(binary), 'hex': rec(hexf),
                                'reference': 'independent fixed wire offsets; no RTL gold or C++ execution'})
        # Cross-check the independent conversion against two historical actual
        # C++ fixtures. These were frozen by the old adapter run; no rebuild.
        historical = {Path(row['path']).name: row for row in adapter_manifest['fixture_files']}
        codec_checks = []
        for name in ['begin', 'end']:
            blobs = {}
            for kind, beats in [('request', 24), ('external', 16), ('response', 8), ('completion', 16)]:
                filename = name + '_' + kind + '.hex'
                source = adapter_old / 'fixture' / filename
                target = freeze(source, Path('external/historical_adapter_literals') / filename, historical[filename])
                blobs[kind] = literal_bytes(target, beats)
            ltx = controlled_ltx(blobs['external'])
            # Historical BEGIN also uses the original optional cleanup flag.
            # The body must match exactly; request flag is independently retained.
            ltx = ltx[:32] + blobs['request'][32:36] + ltx[36:]
            if ltx != blobs['request'] or independent_ltc(blobs['external'], blobs['response']) != blobs['completion']:
                raise RuntimeError('independent LTX/LTC conversion disagrees with actual historical C++ fixture')
            codec_checks.append({'name': name, 'full_LTX1536_match': True, 'full_LTC1024_match': True,
                                 'original_request_flags': int.from_bytes(blobs['request'][32:36], 'little')})
        script = attempt / 'run_executor_adapter_lpv_generated.tcl'
        script.write_text(TCL)
        nowave = attempt / 'run_nowave.tcl'
        nowave.write_text(NOWAVE)
        work = attempt / 'work'
        run_cwd = work / 'vivado/executor_adapter_lpv_generated.sim/sim_1/behav/xsim'
        guard = frozen / MODULE / 'tb/production_guard.py'
        static_tool = [str(VIVADO), '-mode', 'batch', '-notrace', '-log', str(attempt / 'vivado.log'),
                       '-journal', str(attempt / 'vivado.jou'), '-source', str(script),
                       '-tclargs', str(work), str(frozen)]

        def guarded(output, cwd, command, rss_gib=8, timeout_seconds=120):
            return [sys.executable, str(guard), '--out', str(output), '--cwd', str(cwd),
                    '--rss-gib', str(rss_gib), '--timeout-seconds', str(timeout_seconds),
                    '--semantic-stall-seconds', '120', '--', *command]

        commands = {'static': guarded(attempt / 'guard_static', frozen, static_tool,
                                      rss_gib=24, timeout_seconds=1800)}
        for case in CASE_NAMES:
            captures = attempt / ('capture_case_' + str(case))
            captures.mkdir()
            command = [str(VIVADO.with_name('xsim')), 'laya_executor_adapter_lpv_generated_tb_v1_behav',
                       '-tclbatch', str(nowave), '-testplusarg', 'FIXTURE=' + str(fixture),
                       '-testplusarg', 'CAPTURE=' + str(captures), '-testplusarg', 'CASE=' + str(case),
                       '-log', str(attempt / ('case_' + str(case) + '_xsim.log'))]
            commands['case_' + str(case)] = guarded(attempt / ('guard_case_' + str(case)), run_cwd, command)
        manifest = {'schema': 'laya-executor-adapter-lpv-generated-input-v1', 'scope': SCOPE,
                    'files': records, 'fixture_files': fixture_records, 'derived_literals': derived,
                    'independent_codec_cross_checks': codec_checks, 'port_evidence': ports,
                    'original_hls_verdict': {'status': original_hls['status'], 'unchanged': True,
                        'reason': 'historical whole-file ap_ctrl helper search; independent top-only facts recorded separately'},
                    'derived_tcl': rec(script), 'nowave_tcl': rec(nowave),
                    'tools': {'vivado': rec(VIVADO), 'xsim': rec(VIVADO.with_name('xsim')),
                              'python': rec(Path(sys.executable)), 'python_version': sys.version},
                    'launcher': rec(attempt / 'launcher.json'), 'commands': commands,
                    'case_order': list(CASE_NAMES), 'case_transactions': CASE_NAMES,
                    'profile': {'serial_only': True,
                        'static': {'kind': 'compile_elaboration', 'rss_gib': 24,
                                   'timeout_seconds': 1800, 'semantic_stall_seconds': 120},
                        'finite_rtl': {'kind': 'independent_finite_pilot', 'rss_gib': 8,
                                       'timeout_seconds_per_case': 120, 'semantic_stall_seconds': 120,
                                       'cycle_cap_per_case': 500000},
                        'historical_adapter_static_seconds': adapter_receipt['static']['guard']['elapsed_seconds']
                            if 'guard' in adapter_receipt['static'] else adapter_receipt['static']['guard_result']['elapsed_seconds'],
                        'rationale': 'existing static classification for compile/elaboration; four serial bounded RTL pilots; no project budget increase'},
                    'pending_cleanup_gap': {'frozen_sidecar_new_cleanup_blocked': True,
                        'current_cancel_position': 'after actual old END first LTX pop and two raw LPV pushes',
                        'future_contract': 'D-M003-EXECUTOR-OLD-LTX-CLEANUP-01; not implemented in this frozen test'}}
        write_json(attempt / 'input_manifest.json', manifest)
        result['input_manifest'] = rec(attempt / 'input_manifest.json')
        if args.prepare_only:
            result['status'] = 'PREPARED_NOT_RUN'
            write_json(attempt / 'receipt.json', result)
            print('FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_PREPARED_NOT_RUN', flush=True)
            return 0
        result['status'] = 'RUNNING'
        write_json(attempt / 'receipt.json', result)
        static, _ = run_result(commands['static'], attempt / 'guard_static', STATIC_MARKER)
        result['static'] = static
        result['vivado_logs'] = [rec(p) for p in sorted(work.rglob('*.log')) if p.is_file()]
        write_json(attempt / 'receipt.json', result)
        if static['status'] != 'PASS':
            result['status'] = static['status']
            write_json(attempt / 'receipt.json', result)
            return 1
        staged = []
        for source in sorted((frozen / 'external/adapter_rtl').glob('*.dat')):
            target = run_cwd / source.name
            shutil.copyfile(source, target)
            verify(target, rec(source))
            staged.append({'source': rec(source), 'staged': rec(target)})
        result['rom_dat_staging'] = staged
        for case, names in CASE_NAMES.items():
            value, body = run_result(commands['case_' + str(case)], attempt / ('guard_case_' + str(case)),
                                     MARKER + ' case=' + str(case))
            case_markers = [line for line in body.splitlines() if line.startswith(CASE_MARKER + ' case=' + str(case) + ' ')]
            transactions = [line for line in body.splitlines() if line.startswith('GENERATED_ADAPTER_TRANSACTION_PASS ')]
            expected_count = len(names)
            actual_root = attempt / ('capture_case_' + str(case))
            capture_checks = []
            for output, suffix, beats in [('actual_ltx.hex', '_ltx.hex', 24),
                                          ('actual_generated_lpv.hex', '.hex', 16),
                                          ('actual_portal_lpa.hex', '_gold.hex', 8),
                                          ('actual_caller_ltc.hex', '_ltc.hex', 16)]:
                path = actual_root / output
                expected_blob = b''.join(literal_bytes(fixture / (name + suffix), beats) for name in names)
                capture_error = None
                try:
                    actual_blob = literal_bytes(path, len(path.read_text().splitlines())) if path.is_file() else None
                except Exception as error:
                    actual_blob = None
                    capture_error = str(error)
                capture_checks.append({'output': rec(path) if path.is_file() else None,
                                       'capture_parse_error': capture_error,
                                       'expected_bytes': len(expected_blob),
                                       'expected_sha256': hashlib.sha256(expected_blob).hexdigest(),
                                       'whole_byte_match': actual_blob == expected_blob})
            value['case_markers'], value['transaction_markers'], value['actual_capture_checks'] = case_markers, transactions, capture_checks
            gap = [line for line in body.splitlines() if line.startswith('GENERATED_ADAPTER_KNOWN_GAP case=' + str(case) + ' ')]
            value['known_gap_markers'] = gap
            complete = (len(case_markers) == 1 and len(transactions) == expected_count and
                        len(gap) == (1 if case in [1, 2] else 0) and all(x['whole_byte_match'] for x in capture_checks))
            if value['status'] == 'PASS' and not complete:
                value['status'] = 'FAIL'
                value['failure_kind'] = 'INCOMPLETE_CAUSAL_MARKERS_OR_WHOLE_BYTE_CAPTURE'
            result['cases'][str(case)] = value
            result['vivado_logs'] = [rec(p) for p in sorted(work.rglob('*.log')) if p.is_file()]
            write_json(attempt / 'receipt.json', result)
            if value['status'] != 'PASS':
                result['status'] = value['status']
                write_json(attempt / 'receipt.json', result)
                return 1
        result['status'] = 'PASS_SCOPED_RTL_ACTUAL_GENERATED_ADAPTER_PORTAL'
        result['vivado_logs'] = [rec(p) for p in sorted(work.rglob('*.log')) if p.is_file()]
        write_json(attempt / 'receipt.json', result)
        print('FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_RUN_' + result['status'], flush=True)
        return 0
    except Exception as error:
        result['status'] = 'FAIL'
        result['error'] = {'type': type(error).__name__, 'message': str(error)}
        result['frozen_files_at_failure'] = records
        write_json(attempt / 'receipt.json', result)
        raise


if __name__ == '__main__':
    raise SystemExit(main())
