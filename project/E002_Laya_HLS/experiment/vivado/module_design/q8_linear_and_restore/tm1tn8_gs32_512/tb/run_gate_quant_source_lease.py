#!/usr/bin/env python3
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
M = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
Q = Path('vivado/module_design/activation_quantizer')
V = Path('vivado/module_design/vector_and_ffn')
R0 = Path('vivado/module_design/q8_linear_and_restore/metadata_reset_v3/'
          'r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv')
OLD = ROOT / 'results/compute_throughput_optimization_20261010/attempts'
CANONICAL = OLD / 't2_geglu_gate_quant_bridge_rtl_04/canonical_rtl'
QUANT_IP = OLD / 'quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog'
CASE_ROOT = OLD / 'quant16_stream_adapter_01/fixture'


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def launcher_state():
    available_kib = None
    for line in Path('/proc/meminfo').read_text().splitlines():
        if line.startswith('MemAvailable:'):
            available_kib = int(line.split()[1])
            break
    state = {
        'pid': os.getpid(),
        'cpu_affinity': sorted(os.sched_getaffinity(0)),
        'nice': os.getpriority(os.PRIO_PROCESS, 0),
        'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                 check=True, text=True,
                                 capture_output=True).stdout.strip(),
        'mem_available_kib': available_kib,
        'required_mem_available_kib': 192 * 1024 * 1024,
    }
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and
                     state['nice'] == 19 and state['ionice'].startswith('idle') and
                     available_kib is not None and
                     available_kib > state['required_mem_available_kib'])
    return state


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    launcher = launcher_state()
    (attempt / 'launcher.json').write_text(json.dumps(launcher, indent=2) + '\n')
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')
    frozen = attempt / 'frozen'
    files = [R0]
    files += [M / 'rtl' / (name + '.sv') for name in
              ('laya_model_identity_13bo_generated_v1 '
               'laya_compute_portal_layout_v1 '
               'laya_generated_provenance_layout_v1 laya_private_fifo2_v1 '
               'laya_generated_provenance_v1 laya_generated_provenance_hub_v1 '
               'laya_generated_provenance_portal_v1 '
               'laya_gate_quant_portal_decode_v1 laya_wi_axi_reader_v1 '
               'laya_gate_quant_portal_binding_v1').split()]
    files += [Q / 'rtl' / (name + '.sv') for name in
              ('quant16_slot_banks quant16_amax16 quant16_half_rne '
               'quant16_tiny_div127 quant16_divider_service quant16_stream_row '
               'quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 '
               'quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 '
               'geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 '
               'geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2').split()]
    files += [V / 'rtl' / (name + '.sv') for name in
              ('tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 '
               'geglu_canonical_row_adapter').split()]
    files += [
        M / 'tb/laya_gate_quant_source_lease_tb_v1.sv',
        M / 'tb/run_gate_quant_source_lease.tcl',
        M / 'tb/run_gate_quant_portal_binding_nowave_v1.tcl',
        M / 'tb/make_gate_quant_source_lease_fixture.py',
        M / 'tb/make_generated_provenance_portal_fixture.py',
    ]
    records = []
    for rel in files:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    for src in sorted(CANONICAL.glob('*.v')):
        target = frozen / 'external/canonical_rtl' / src.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, target)
        records.append({'original': rec(src), 'frozen': rec(target)})
    for name in ['laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl',
                 'laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl']:
        src = QUANT_IP / name
        target = frozen / 'external/quant_ip' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, target)
        records.append({'original': rec(src), 'frozen': rec(target)})
    fixture = attempt / 'fixture'
    fixture_command = [
        sys.executable,
        str(frozen / M / 'tb/make_gate_quant_source_lease_fixture.py'),
        '--package', str(frozen / M /
                         'rtl/laya_model_identity_13bo_generated_v1.sv'),
        '--base-generator', str(frozen / M /
                                'tb/make_generated_provenance_portal_fixture.py'),
        '--out', str(fixture),
    ]
    subprocess.run(fixture_command, check=True, cwd=frozen)
    groups = [f'case_{index:02d}' for index in range(11, 19)]
    fixture_sources = [CASE_ROOT / 'manifest.json']
    payload = {name: [] for name in ('source.mem', 'q.mem', 'scale.mem')}
    for _row in range(16):
        for _group_block in range(4):
            for group in groups:
                for name in payload:
                    src = CASE_ROOT / group / name
                    if src not in fixture_sources:
                        fixture_sources.append(src)
                    payload[name].append(src.read_text())
    for name, parts in payload.items():
        (fixture / name).write_text(''.join(parts))
    fixture_files = [rec(path) for path in sorted(fixture.iterdir())]
    contracts = []
    for name in ['generated_provenance_channel_contract_20261012.md',
                 'ordinary_linear_provenance_contract_20261012.md',
                 'quant_g_portal_contract_v2_20261011.md']:
        original = PROJECT / 'results' / name
        target = frozen / 'external/contracts' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(original, target)
        contracts.append({'original': rec(original), 'frozen': rec(target)})
    guard = ROOT / M / 'tb/production_guard.py'
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    xsim = tool.parent / 'xsim'
    static_payload = [
        str(tool), '-mode', 'batch', '-notrace', '-log', str(attempt / 'static.log'),
        '-journal', str(attempt / 'static.jou'), '-source',
        str(frozen / M / 'tb/run_gate_quant_source_lease.tcl'), '-tclargs',
        str(attempt / 'work'), str(frozen),
    ]
    static_command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard_static'),
        '--cwd', str(ROOT), '--rss-gib', '24', '--timeout-seconds', '1800',
        '--semantic-stall-seconds', '120', '--', *static_payload,
    ]
    run_cwd = attempt / 'work/vivado/gate_quant_source_lease.sim/sim_1/behav/xsim'
    pilot_payload = [
        str(xsim), 'laya_gate_quant_source_lease_tb_v1_behav', '-key',
        'Behavioral:sim_1:Functional:laya_gate_quant_source_lease_tb_v1',
        '-tclbatch', str(frozen / M / 'tb/run_gate_quant_portal_binding_nowave_v1.tcl'),
        '-log', str(attempt / 'pilot_sim.log'), '-testplusarg',
        'FIXTURE=' + str(fixture),
    ]
    pilot_command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard_pilot'),
        '--cwd', str(run_cwd), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', *pilot_payload,
    ]
    scope = (
        'same-runtime persistent provenance hub plus shared ordinary QUANT/full-A '
        'endpoint: controlled physical publication of four distinct rows16 '
        'producer windows for one B1/S64 role-6 TOKEN/F32 owner; unpublished '
        'query rejection, full L13M/NumericIdentity/P/Ref/range query, atomic '
        'source read lease held through 16 real AXI AR and 1024 R beats and '
        'response backpressure, release only after read debt and response '
        'retirement, 16384 element-wise F32/INT8 checks and 512 FP16 scale '
        'checks in real full-A; numerical data comes from eight independently '
        'frozen quantization groups repeated in four group blocks across 16 rows; '
        'generated writes/adapter causality, '
        'dispatcher reservation, LOAD/matrix/full request and hardware remain outside')
    manifest = {
        'schema': 'laya-gate-quant-source-lease-input-v1',
        'scope': scope,
        'files': records,
        'contracts': contracts,
        'fixture_command': fixture_command,
        'fixture_source_groups': groups,
        'fixture_sources': [rec(path) for path in fixture_sources],
        'fixture_files': fixture_files,
        'launcher': rec(attempt / 'launcher.json'),
        'runner': rec(Path(__file__)),
        'guard': rec(guard),
        'tool': rec(tool),
        'commands': {'static': static_command, 'pilot': pilot_command},
        'profiles': {
            'static': {'kind': 'rtl_static', 'maximum_seconds': 1800,
                       'maximum_rss_gib': 24, 'semantic_stall_seconds': 120},
            'pilot': {'kind': 'rtl_pilot', 'maximum_seconds': 120,
                      'maximum_rss_gib': 8, 'semantic_stall_seconds': 120},
        },
    }
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    receipt = {
        'schema': 'laya-gate-quant-source-lease-receipt-v1',
        'scope': scope,
        'launcher': rec(attempt / 'launcher.json'),
        'input_manifest': rec(manifest_path),
    }
    runs = [
        ('static', static_command, ROOT,
         'FULL_CURRENT_GATE_QUANT_SOURCE_LEASE_STATIC_PASS'),
        ('pilot', pilot_command, ROOT,
         'FULL_CURRENT_GATE_QUANT_SOURCE_LEASE_PASS'),
    ]
    for mode, command, cwd, marker in runs:
        result = subprocess.run(command, cwd=cwd)
        state = json.loads((attempt / ('guard_' + mode) /
                            'guard_result.json').read_text())
        log = attempt / ('guard_' + mode) / 'driver.log'
        body = log.read_text(errors='replace')
        passed = (result.returncode == 0 and state['child_exit_code'] == 0 and
                  state['trigger'] is None and marker in body and
                  'Fatal:' not in body and 'ERROR:' not in body)
        receipt[mode] = {
            'status': 'PASS' if passed else 'FAIL',
            'guard': state,
            'marker': [line for line in body.splitlines() if marker in line],
            'driver_log': rec(log),
        }
        receipt['input_manifest'] = rec(manifest_path)
        receipt['native_ip'] = [rec(path) for path in
                                (attempt / 'work').rglob('*.xci')]
        (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        print('FULL_CURRENT_GATE_QUANT_SOURCE_LEASE_' + mode.upper() + '_' +
              ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
