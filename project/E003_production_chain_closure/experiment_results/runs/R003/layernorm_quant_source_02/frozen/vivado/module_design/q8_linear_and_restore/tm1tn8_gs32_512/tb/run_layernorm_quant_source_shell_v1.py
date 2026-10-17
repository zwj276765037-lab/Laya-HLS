#!/usr/bin/env python3
"""Freeze and run the generated LayerNorm to real QUANT/fullA RTL chain with F9 isolation."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import runpy
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
M = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
ENGINE_ATTEMPT = (PROJECT / 'project/E003_production_chain_closure/'
                  'experiment_results/runs/R003/layernorm_producer_hls_01')


def rec(path):
    path = path.resolve()
    data = path.read_bytes()
    return {'path': str(path), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def launcher_state():
    available = None
    for line in Path('/proc/meminfo').read_text().splitlines():
        if line.startswith('MemAvailable:'):
            available = int(line.split()[1])
            break
    state = {
        'pid': os.getpid(),
        'cpu_affinity': sorted(os.sched_getaffinity(0)),
        'nice': os.getpriority(os.PRIO_PROCESS, 0),
        'ionice': subprocess.run(['ionice', '-p', str(os.getpid())],
                                 check=True, text=True,
                                 capture_output=True).stdout.strip(),
        'mem_available_kib': available,
        'required_mem_available_kib': 192 * 1024 * 1024,
    }
    state['pass'] = (state['cpu_affinity'] == [0, 1, 2, 3] and
                     state['nice'] == 19 and
                     state['ionice'].startswith('idle') and
                     available is not None and
                     available > state['required_mem_available_kib'])
    return state


def copy_one(source, target, records, label=None):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    records.append({'label': label or str(source),
                    'original': rec(source), 'frozen': rec(target)})


def full_cost(pilot_cycles, pilot_seconds, pilot_rows):
    valid = (isinstance(pilot_cycles, int) and pilot_cycles > 0 and
             math.isfinite(pilot_seconds) and 0 < pilot_seconds <= 120 and
             pilot_rows in (1, 16))
    decision = {'status': 'COST_STOP', 'started': False,
                'maximum_seconds': 3600, 'maximum_cycles': 5000000,
                'safety_factor': 1.5, 'pilot_cycles': pilot_cycles,
                'pilot_elapsed_seconds': pilot_seconds,
                'pilot_rows': pilot_rows, 'full_rows': 16,
                'estimate_kind': 'current producer pilot row scaling plus explicit Q allowance, times 1.5; reference estimate, not a proven upper bound',
                'reason': 'invalid_current_pilot'}
    if valid:
        rate = pilot_cycles / pilot_seconds
        producer_reference_cycles = math.ceil(pilot_cycles * 16 / pilot_rows)
        quant_reference_cycles = 262144
        reference_cycles = producer_reference_cycles + quant_reference_cycles
        projected = math.ceil(reference_cycles * 1.5 / rate)
        decision.update({'current_cycles_per_second': rate,
                         'reference_full_cycles': reference_cycles,
                         'producer_reference_cycles': producer_reference_cycles,
                         'quant_reference_cycles': quant_reference_cycles,
                         'quant_reference_basis': '512 groups with an allowance of 512 cycles/group; budget allowance, not measured current Q rate or proven upper bound',
                         'projected_full_seconds': projected})
        allowed = projected <= 3600 and reference_cycles * 1.5 <= 5000000
        decision.update({'status': 'RUN_FULL' if allowed else 'COST_STOP',
                         'reason': 'current_pilot_projection_within_caps' if allowed
                         else 'current_pilot_projection_exceeds_caps'})
    return decision


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--pilot-rows', type=int, choices=(1, 16), default=1)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = launcher_state()
    (attempt / 'launcher.json').write_text(json.dumps(launcher, indent=2) + '\n')
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')

    frozen = attempt / 'frozen'
    registry_path = ROOT / 'config/full_module_registry.json'
    registry = json.loads(registry_path.read_text())
    rtl_sources = registry.get('rtl_shell_sources', {}).get(
        'layernorm_quant_source', [])
    expected = [str(M / 'rtl' / name) for name in (
        'laya_model_identity_13bo_generated_v1.sv',
        'laya_compute_portal_layout_v1.sv',
        'laya_generated_provenance_layout_v1.sv',
        'laya_private_fifo2_v1.sv',
        'laya_generated_provenance_v1.sv',
        'laya_generated_provenance_hub_v1.sv',
        'laya_generated_provenance_portal_v1.sv',
        'laya_generated_store_monitor_v1.sv',
        'laya_generated_provenance_axi_portal_v1.sv',
        'laya_layernorm_producer_portal_shell_v1.sv',
        'laya_gate_quant_portal_decode_v1.sv', 'laya_wi_axi_reader_v1.sv',
        'laya_gate_quant_portal_binding_v1.sv', 'laya_layernorm_quant_source_shell_v1.sv')]
    if rtl_sources != expected:
        raise RuntimeError('production registry LayerNorm portal closure mismatch')

    runner_rel = Path(__file__).resolve().relative_to(ROOT)
    local_files = [Path(name) for name in rtl_sources] + [
        M / 'tb/laya_layernorm_quant_source_shell_tb_v1.sv',
        M / 'tb/make_layernorm_producer_portal_fixture.py',
        M / 'tb/make_layernorm_quant_gold.py',
        M / 'tb/run_layernorm_quant_source_shell_v1.tcl',
        M / 'tb/run_layernorm_producer_portal_nowave_v1.tcl',
        M / 'tb/production_guard.py',
        Path('tools/hls_guard_helpers.py'),
        Path('tools/generate_laya_model_identity_sv.py'),
        MODEL / 'laya_model_layout_generated.h',
        MODEL / 'manifest.json',
        Path('config/full_module_registry.json'),
        Path('config/production_hls_partitions.json'),
        runner_rel,
    ]
    Q = Path('vivado/module_design/activation_quantizer/rtl')
    V = Path('vivado/module_design/vector_and_ffn/rtl')
    local_files += [Path('vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv')]
    local_files += [Q / (n + '.sv') for n in (
        'quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 '
        'quant16_divider_service quant16_stream_row quant_a_row_bank_v1 '
        'quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 '
        'quant_task_to_dual_a_v1 geglu_gate_tensor_ledger_v2 '
        'geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2').split()]
    local_files += [V / (n + '.sv') for n in (
        'tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter').split()]
    records = []
    for rel in local_files:
        copy_one(ROOT / rel, frozen / rel, records, str(rel))

    selected_header = frozen / MODEL / 'laya_model_layout_generated.h'
    generator = runpy.run_path(str(frozen / 'tools/generate_laya_model_identity_sv.py'))
    canonical_package = frozen / M / 'rtl/laya_model_identity_13bo_generated_v1.sv'
    if generator['generate'](selected_header) != canonical_package.read_text():
        raise RuntimeError('portal canonical package differs from selected production header')
    generation_manifest = json.loads((ENGINE_ATTEMPT / 'input_manifest.json').read_text())
    engine_header_item = next(item for item in generation_manifest['files']
                              if item['relative'] == str(MODEL / 'laya_model_layout_generated.h'))
    engine_header = Path(engine_header_item['frozen']['path'])
    if rec(engine_header)['sha256'] != engine_header_item['frozen']['sha256']:
        raise RuntimeError('generated engine model header identity changed')
    if selected_header.read_bytes() != engine_header.read_bytes():
        raise RuntimeError('selected production model header differs from generated engine build')
    copy_one(engine_header,
             frozen / 'external/layernorm_producer_generation/model_header.h',
             records, 'generation_evidence/model_header.h')

    engine_source = ENGINE_ATTEMPT / 'work/hls/syn/verilog'
    engine_frozen = frozen / 'external/layernorm_producer_rtl'
    engine_files = sorted(path for path in engine_source.iterdir()
                          if path.is_file() and
                          path.suffix in {'.v', '.dat', '.tcl'})
    if not engine_files or not any(path.name ==
                                   'laya_layernorm_producer_engine.v'
                                   for path in engine_files):
        raise RuntimeError('frozen generated LayerNorm RTL is absent')
    for source in engine_files:
        copy_one(source, engine_frozen / source.name, records,
                 'generated_engine/' + source.name)
    for name in ('input_manifest.json', 'receipt.json',
                 'work/reports/hls_compile.rpt'):
        source = ENGINE_ATTEMPT / name
        target = frozen / 'external/layernorm_producer_generation' / name
        copy_one(source, target, records, 'generation_evidence/' + name)

    old = ROOT / 'results/compute_throughput_optimization_20261010/attempts'
    for src in sorted((old / 't2_geglu_gate_quant_bridge_rtl_04/canonical_rtl').glob('*.v')):
        copy_one(src, frozen / 'external/canonical_rtl' / src.name, records)
    qip = old / 'quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog'
    for name in ('laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl',
                 'laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl'):
        copy_one(qip / name, frozen / 'external/quant_ip' / name, records)
    contracts = []
    for name in ('production_hls_partition_contract_20261012.md',
                 'generated_provenance_channel_contract_20261012.md',
                 'ordinary_linear_provenance_contract_20261012.md',
                 'quant_g_portal_contract_v2_20261011.md',
                 'model_identity_13bo_contract_20261011.md'):
        source = PROJECT / 'results' / name
        target = frozen / 'external/contracts' / name
        copy_one(source, target, records, 'contract/' + name)
        contracts.append({'original': rec(source), 'frozen': rec(target)})

    fixture = attempt / 'fixture'
    pilot_fixture = attempt / 'fixture_pilot'
    fixture_command_base = [
        sys.executable,
        str(frozen / M / 'tb/make_layernorm_producer_portal_fixture.py'),
        '--package', str(frozen / M /
                         'rtl/laya_model_identity_13bo_generated_v1.sv'),
        '--source', str(ENGINE_ATTEMPT / 'fixture/source_rows16.f32.bin'),
        '--gold', str(ENGINE_ATTEMPT / 'fixture/gold_rows16.f32.bin'),
    ]
    fixture_command = [*fixture_command_base, '--out', str(fixture), '--rows', '16']
    pilot_fixture_command = [*fixture_command_base, '--out', str(pilot_fixture),
                             '--rows', str(args.pilot_rows)]
    subprocess.run(fixture_command, check=True, cwd=ROOT)
    subprocess.run(pilot_fixture_command, check=True, cwd=ROOT)
    for dest in (fixture, pilot_fixture):
        subprocess.run([sys.executable, str(frozen / M / 'tb/make_layernorm_quant_gold.py'),
                        '--gold', str(dest / 'gold_rows16.f32.bin'), '--out', str(dest)],
                       check=True, cwd=ROOT)
    fixture_inputs = [rec(ENGINE_ATTEMPT / 'fixture/source_rows16.f32.bin'),
                      rec(ENGINE_ATTEMPT / 'fixture/gold_rows16.f32.bin')]
    fixture_files = [rec(path) for path in sorted(fixture.iterdir())]
    pilot_fixture_files = [rec(path) for path in sorted(pilot_fixture.iterdir())]

    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    xsim = tool.parent / 'xsim'
    guard = frozen / M / 'tb/production_guard.py'
    static_payload = [
        str(tool), '-mode', 'batch', '-notrace',
        '-log', str(attempt / 'static.log'),
        '-journal', str(attempt / 'static.jou'), '-source',
        str(frozen / M / 'tb/run_layernorm_quant_source_shell_v1.tcl'),
        '-tclargs', str(attempt / 'work'), str(frozen), str(fixture),
    ]
    static_command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard_static'),
        '--cwd', str(ROOT), '--rss-gib', '24', '--timeout-seconds', '1800',
        '--semantic-stall-seconds', '120', '--', *static_payload,
    ]
    run_cwd = (attempt / 'work/vivado/layernorm_quant_source.sim/'
               'sim_1/behav/xsim')
    pilot_payload = [
        str(xsim), 'laya_layernorm_quant_source_shell_tb_v1_behav',
        '-key', ('Behavioral:sim_1:Functional:'
                 'laya_layernorm_quant_source_shell_tb_v1'),
        '-tclbatch', str(frozen / M /
                         'tb/run_layernorm_producer_portal_nowave_v1.tcl'),
        '-log', str(attempt / 'pilot_sim.log'),
        '-testplusarg', 'FIXTURE=' + str(pilot_fixture),
        '-testplusarg', 'ROWS=' + str(args.pilot_rows),
    ]
    pilot_command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard_pilot'),
        '--cwd', str(run_cwd), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', *pilot_payload,
    ]
    full_payload = [*pilot_payload]
    full_payload[full_payload.index(str(attempt / 'pilot_sim.log'))] = str(attempt / 'full_sim.log')
    full_payload[full_payload.index('FIXTURE=' + str(pilot_fixture))] = 'FIXTURE=' + str(fixture)
    full_payload[full_payload.index('ROWS=' + str(args.pilot_rows))] = 'ROWS=16'
    full_command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard_full'),
        '--cwd', str(run_cwd), '--rss-gib', '8', '--timeout-seconds', '3600',
        '--semantic-stall-seconds', '120', '--', *full_payload,
    ]
    scope = (
        'one generated gamma0/D1024 LN_ATTN task, honest rows16 diagnostic owner '
        'within B1/S64 identity; full immutable BEGIN/request binding before real '
        'AXI, full completion/request binding before caller delivery; actual '
        'completion issued bytes form END; real LN stores feed persistent monitor/hub '
        'source lease and shared stage2/K1024 QUANT/fullA without reset; '
        '16384 independent F32 LN words, 16384 INT8 and 512 FP16 quant gold checks. '
        'Four request mutations and two completion mutations prove safe isolation '
        'in bounded RTL tests. No generated sequencer/adapter, full S64 tensor, '
        'complete graph, general error/cancel recovery, OOC/P&R or hardware claim.')
    manifest = {
        'schema': 'laya-layernorm-quant-source-input-v1',
        'scope': scope,
        'files': records,
        'contracts': contracts,
        'generation_attempt': {
            'receipt': rec(ENGINE_ATTEMPT / 'receipt.json'),
            'manifest': rec(ENGINE_ATTEMPT / 'input_manifest.json'),
            'rtl_files': [rec(path) for path in engine_files],
        },
        'model_identity': {
            'selected_header': rec(selected_header),
            'engine_header': rec(engine_header),
            'canonical_package': rec(canonical_package),
            'generator': rec(frozen / 'tools/generate_laya_model_identity_sv.py'),
            'exact_header_and_generated_package_match': True,
        },
        'fixture_command': fixture_command,
        'pilot_fixture_command': pilot_fixture_command,
        'fixture_inputs': fixture_inputs,
        'fixture_files': fixture_files,
        'pilot_fixture_files': pilot_fixture_files,
        'pilot_rows': args.pilot_rows,
        'full_workload': {'rows': 16, 'D': 1024, 'source_beats': 1024,
                          'store_beats': 1024, 'store_bytes': 65536,
                          'gold_elements': 16384, 'quant_groups':512, 'quant_q_bytes':16384,
                          'quant_scale_halves':512, 'quant_reference_cycles':262144,
                          'fixture': str(fixture)},
        'cost_decision': {'status': 'PENDING_CURRENT_PILOT', 'started': False},
        'runtime_dat_staging': {
            'source_directory': str(engine_frozen),
            'destination_directory': str(run_cwd),
            'files': [
                {'source': rec(path), 'destination': str(run_cwd / path.name)}
                for path in sorted(engine_frozen.glob('*.dat'))
            ],
            'policy': 'copy frozen bytes after static PASS and verify before pilot',
        },
        'launcher': rec(attempt / 'launcher.json'),
        'runner': rec(frozen / runner_rel),
        'guard': rec(guard),
        'tool': rec(tool),
        'commands': {'static': static_command, 'pilot': pilot_command,
                     'full': full_command},
        'profiles': {
            'static': {'kind': 'rtl_static', 'maximum_seconds': 1800,
                       'maximum_rss_gib': 24,
                       'semantic_stall_seconds': 120},
            'pilot': {'kind': 'rtl_pilot', 'maximum_seconds': 120,
                      'maximum_rss_gib': 8,
                      'maximum_cycles': 5000000,
                      'semantic_stall_seconds': 120},
            'full': {'kind': 'rtl_full_rows16', 'maximum_seconds': 3600,
                     'maximum_rss_gib': 8, 'maximum_cycles': 5000000,
                     'semantic_stall_seconds': 120},
        },
    }
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    receipt = {
        'schema': 'laya-layernorm-quant-source-receipt-v1',
        'scope': scope,
        'launcher': rec(attempt / 'launcher.json'),
        'input_manifest': rec(manifest_path),
        'pilot_scope': f'rows{args.pilot_rows} prefix of frozen rows16 numerical fixture and an honest rows{args.pilot_rows} diagnostic owner; rows1 measures engine/gold/END fence without current Q timing; full includes explicit conservative Q allowance',
    }
    runs = [
        ('static', static_command, ROOT,
         'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_STATIC_PASS'),
        ('pilot', pilot_command, ROOT,
         'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS'),
    ]
    if args.pilot_rows == 1:
        runs.append(('full', full_command, ROOT,
                     'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS'))
    for case in range(1, 7):
        payload = [*pilot_payload, '-testplusarg', f'REJECT_CASE={case}']
        payload[payload.index(str(attempt / 'pilot_sim.log'))] = str(attempt / f'reject_{case}_sim.log')
        command = [sys.executable, str(guard), '--out', str(attempt / f'guard_reject_{case}'),
                   '--cwd', str(run_cwd), '--rss-gib', '8', '--timeout-seconds', '120',
                   '--semantic-stall-seconds', '120', '--', *payload]
        manifest['commands'][f'reject_{case}'] = command
        manifest['profiles'][f'reject_{case}'] = dict(manifest['profiles']['pilot'])
        runs.append((f'reject_{case}', command, ROOT, 'FULL_CURRENT_LAYERNORM_QUANT_F9_REJECT_PASS'))
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    for mode, command, cwd, marker in runs:
        if mode == 'full':
            prior = receipt['pilot']
            matches = re.findall(
                r'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS rows=1 .*cycles=(\d+)',
                '\n'.join(prior['marker']))
            decision = full_cost(int(matches[0]) if len(matches) == 1 else 0,
                                 prior['guard'].get('elapsed_seconds', float('nan')),
                                 args.pilot_rows)
            decision['pilot_driver_log'] = prior['driver_log']
            manifest['cost_decision'] = decision
            manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
            receipt['input_manifest'] = rec(manifest_path)
            receipt['cost_decision'] = decision
            if decision['status'] != 'RUN_FULL':
                receipt['full'] = {'status': 'COST_STOP', 'started': False}
                (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
                print('FULL_CURRENT_LAYERNORM_QUANT_SOURCE_FULL_COST_STOP', flush=True)
                return 1
            print('FULL_CURRENT_LAYERNORM_QUANT_SOURCE_FULL_ADMITTED ' +
                  json.dumps(decision), flush=True)
        if mode == 'pilot':
            staged = []
            for item in manifest['runtime_dat_staging']['files']:
                source = Path(item['source']['path'])
                target = Path(item['destination'])
                shutil.copyfile(source, target)
                actual = rec(target)
                if actual['sha256'] != item['source']['sha256']:
                    raise RuntimeError('runtime DAT identity mismatch: ' + target.name)
                staged.append({'source': item['source'], 'staged': actual})
            if not staged:
                raise RuntimeError('no generated ROM DAT files staged')
            receipt['runtime_dat_staging'] = staged
            (attempt / 'receipt.json').write_text(
                json.dumps(receipt, indent=2) + '\n')
        result = subprocess.run(command, cwd=cwd)
        state_path = attempt / ('guard_' + mode) / 'guard_result.json'
        state = (json.loads(state_path.read_text()) if state_path.is_file()
                 else {'child_exit_code': None,
                       'trigger': 'guard_result_missing'})
        log = attempt / ('guard_' + mode) / 'driver.log'
        body = log.read_text(errors='replace') if log.is_file() else ''
        passed = (result.returncode == 0 and state.get('child_exit_code') == 0 and
                  state.get('trigger') is None and marker in body and
                  'Fatal:' not in body and 'ERROR:' not in body)
        receipt[mode] = {
            'status': 'PASS' if passed else 'FAIL',
            'runner_exit_code': result.returncode,
            'guard': state,
            'marker': [line for line in body.splitlines() if marker in line],
            'driver_log': rec(log) if log.is_file() else None,
            'started': True,
        }
        receipt['input_manifest'] = rec(manifest_path)
        receipt['native_ip'] = [rec(path) for path in
                                sorted((attempt / 'work').rglob('*.xci'))]
        (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        print('FULL_CURRENT_LAYERNORM_QUANT_SOURCE_' + mode.upper() + '_' +
              ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
