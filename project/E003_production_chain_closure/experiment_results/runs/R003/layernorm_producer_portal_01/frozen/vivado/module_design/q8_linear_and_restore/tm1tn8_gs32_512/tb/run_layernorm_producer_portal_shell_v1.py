#!/usr/bin/env python3
"""Freeze and run the first generated LayerNorm producer/portal RTL chain."""
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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
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
        'layernorm_producer_portal', [])
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
        'laya_layernorm_producer_portal_shell_v1.sv')]
    if rtl_sources != expected:
        raise RuntimeError('production registry LayerNorm portal closure mismatch')

    runner_rel = Path(__file__).resolve().relative_to(ROOT)
    local_files = [Path(name) for name in rtl_sources] + [
        M / 'tb/laya_layernorm_producer_portal_shell_tb_v1.sv',
        M / 'tb/make_layernorm_producer_portal_fixture.py',
        M / 'tb/run_layernorm_producer_portal_shell_v1.tcl',
        M / 'tb/run_layernorm_producer_portal_nowave_v1.tcl',
        M / 'tb/production_guard.py',
        Path('tools/hls_guard_helpers.py'),
        Path('config/full_module_registry.json'),
        Path('config/production_hls_partitions.json'),
        runner_rel,
    ]
    records = []
    for rel in local_files:
        copy_one(ROOT / rel, frozen / rel, records, str(rel))

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

    contracts = []
    for name in ('production_hls_partition_contract_20261012.md',
                 'generated_provenance_channel_contract_20261012.md',
                 'ordinary_linear_provenance_contract_20261012.md'):
        source = PROJECT / 'results' / name
        target = frozen / 'external/contracts' / name
        copy_one(source, target, records, 'contract/' + name)
        contracts.append({'original': rec(source), 'frozen': rec(target)})

    fixture = attempt / 'fixture'
    fixture_command = [
        sys.executable,
        str(frozen / M / 'tb/make_layernorm_producer_portal_fixture.py'),
        '--package', str(frozen / M /
                         'rtl/laya_model_identity_13bo_generated_v1.sv'),
        '--source', str(ENGINE_ATTEMPT / 'fixture/source_rows16.f32.bin'),
        '--gold', str(ENGINE_ATTEMPT / 'fixture/gold_rows16.f32.bin'),
        '--out', str(fixture),
    ]
    subprocess.run(fixture_command, check=True, cwd=ROOT)
    fixture_inputs = [rec(ENGINE_ATTEMPT / 'fixture/source_rows16.f32.bin'),
                      rec(ENGINE_ATTEMPT / 'fixture/gold_rows16.f32.bin')]
    fixture_files = [rec(path) for path in sorted(fixture.iterdir())]

    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    xsim = tool.parent / 'xsim'
    guard = frozen / M / 'tb/production_guard.py'
    static_payload = [
        str(tool), '-mode', 'batch', '-notrace',
        '-log', str(attempt / 'static.log'),
        '-journal', str(attempt / 'static.jou'), '-source',
        str(frozen / M / 'tb/run_layernorm_producer_portal_shell_v1.tcl'),
        '-tclargs', str(attempt / 'work'), str(frozen), str(fixture),
    ]
    static_command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard_static'),
        '--cwd', str(ROOT), '--rss-gib', '24', '--timeout-seconds', '1800',
        '--semantic-stall-seconds', '120', '--', *static_payload,
    ]
    run_cwd = (attempt / 'work/vivado/layernorm_producer_portal.sim/'
               'sim_1/behav/xsim')
    pilot_payload = [
        str(xsim), 'laya_layernorm_producer_portal_shell_tb_v1_behav',
        '-key', ('Behavioral:sim_1:Functional:'
                 'laya_layernorm_producer_portal_shell_tb_v1'),
        '-tclbatch', str(frozen / M /
                         'tb/run_layernorm_producer_portal_nowave_v1.tcl'),
        '-log', str(attempt / 'pilot_sim.log'),
        '-testplusarg', 'FIXTURE=' + str(fixture),
    ]
    pilot_command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard_pilot'),
        '--cwd', str(run_cwd), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', *pilot_payload,
    ]
    scope = (
        'one real generated LayerNorm producer task (B1/S64 identity, rows0..15, '
        'D1024, gamma0 LN_ATTN) behind a complete successful BEGIN response; '
        'real source AXI AR/R, generated arithmetic, destination AW/W/B through '
        'the persistent role-6 WSTRB monitor, completion delivery as adapter '
        'fence, early END held through physical retirement, 16384 bitwise F32 '
        'gold comparisons, one honest rows16 owner publication, full-identity '
        'source-query lease and release.  It does not claim full S64/S128 tensor '
        'publication, generated sequencer/adapter RTL, QUANT/fullA numerical '
        'execution, cancellation/failure recovery, full graph, OOC, P&R or hardware.')
    manifest = {
        'schema': 'laya-layernorm-producer-portal-input-v1',
        'scope': scope,
        'files': records,
        'contracts': contracts,
        'generation_attempt': {
            'receipt': rec(ENGINE_ATTEMPT / 'receipt.json'),
            'manifest': rec(ENGINE_ATTEMPT / 'input_manifest.json'),
            'rtl_files': [rec(path) for path in engine_files],
        },
        'fixture_command': fixture_command,
        'fixture_inputs': fixture_inputs,
        'fixture_files': fixture_files,
        'launcher': rec(attempt / 'launcher.json'),
        'runner': rec(frozen / runner_rel),
        'guard': rec(guard),
        'tool': rec(tool),
        'commands': {'static': static_command, 'pilot': pilot_command},
        'profiles': {
            'static': {'kind': 'rtl_static', 'maximum_seconds': 1800,
                       'maximum_rss_gib': 24,
                       'semantic_stall_seconds': 120},
            'pilot': {'kind': 'rtl_pilot', 'maximum_seconds': 120,
                      'maximum_rss_gib': 8,
                      'maximum_cycles': 5000000,
                      'semantic_stall_seconds': 120},
        },
    }
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    receipt = {
        'schema': 'laya-layernorm-producer-portal-receipt-v1',
        'scope': scope,
        'launcher': rec(attempt / 'launcher.json'),
        'input_manifest': rec(manifest_path),
    }
    runs = [
        ('static', static_command, ROOT,
         'FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_STATIC_PASS'),
        ('pilot', pilot_command, ROOT,
         'FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PASS'),
    ]
    for mode, command, cwd, marker in runs:
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
        }
        receipt['input_manifest'] = rec(manifest_path)
        receipt['native_ip'] = [rec(path) for path in
                                sorted((attempt / 'work').rglob('*.xci'))]
        (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        print('FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_' + mode.upper() + '_' +
              ('PASS' if passed else 'FAIL'), flush=True)
        if not passed:
            return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
