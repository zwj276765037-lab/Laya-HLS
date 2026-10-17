#!/usr/bin/env python3
"""Freeze and run the bounded readonly bootstrap snapshot with normal hub/monitor source prelude."""
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
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')


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
    parser.add_argument('--control-fixture', type=Path, required=True)
    parser.add_argument('--proof-only', action='store_true')
    parser.add_argument('--query-case',type=int,choices=[0,1,2,3,4],default=0)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    launcher = launcher_state()
    (attempt / 'launcher.json').write_text(json.dumps(launcher, indent=2) + '\n')
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')
    source = attempt / 'frozen'

    rtl_names = ['laya_model_identity_13bo_generated_v1',
        'laya_compute_portal_layout_v1', 'laya_generated_provenance_layout_v1',
        'laya_bootstrap_snapshot_layout_v1', 'laya_generated_provenance_hub_v1',
        'laya_executor_checkpoint_layout_v2', 'laya_executor_handoff_layout_v1', 'laya_executor_handoff_shell_v1', 'laya_executor_handoff_portal_shell_v1', 'laya_private_fifo2_v1',
        'laya_generated_provenance_v1', 'laya_executor_checkpoint_transport_v2',
        'laya_generated_store_monitor_v1', 'laya_generated_provenance_axi_portal_v1']
    files = [MODULE / ('rtl/' + name + '.sv') for name in rtl_names]
    runner_rel = Path(__file__).resolve().relative_to(ROOT)
    files += [MODULE / 'tb/laya_executor_handoff_portal_tb_v1.sv',
        MODULE / 'tb/run_executor_handoff_portal.tcl', MODULE / 'tb/production_guard.py',
        Path('tools/hls_guard_helpers.py'), runner_rel,
        Path('tests/executor_checkpoint_rtl_fixture.py'),Path('tests/executor_managed_query_fixture.py'),
        Path('tests/executor_bootstrap_fixture.py'),
        Path('tests/bootstrap_snapshot_rtl_fixture.py'),
        Path('include/laya_executor_checkpoint.h'),
        Path('hls/control/executor_checkpoint_protocol.cpp'),
        Path('include/laya_bootstrap_snapshot.h'),
        Path('hls/control/bootstrap_snapshot_protocol.cpp'),
        Path('build/model-current-production-v2-20261011/laya_model_layout_generated.h'),
        Path('build/model-current-production-v2-20261011/aux.bin'),
        Path('config/full_module_registry.json'), Path('config/production_hls_partitions.json')]
    records = []
    for rel in files:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})

    control_fixture=attempt/'control_fixture';control_fixture.mkdir()
    control_records=[]
    for name in ['hold.hex','query.hex','proof.hex','import_ok.hex','held_gold.hex','grant_gold.hex','abort.hex','abort_closed_gold.hex','scope.json']:
        original=args.control_fixture.resolve()/name;target=control_fixture/name;shutil.copyfile(original,target)
        control_records.append({'original':rec(original),'frozen':rec(target)})
    oracle_command=[sys.executable,str(source/'tests/executor_managed_query_fixture.py'),'--fixture',str(control_fixture)]
    subprocess.run(oracle_command,check=True,cwd=source,timeout=120)
    control_oracle=[rec(control_fixture/'revoked_proof_gold.hex')]
    host_fixture = attempt / 'host_fixture'
    fixture_command = [sys.executable, str(source / 'tests/executor_bootstrap_fixture.py'),
        '--model-header', str(source / 'build/model-current-production-v2-20261011/laya_model_layout_generated.h'),
        '--model-aux', str(source / 'build/model-current-production-v2-20261011/aux.bin'),
        '--output', str(host_fixture)]
    subprocess.run(fixture_command, check=True, cwd=source, timeout=120)
    fixture = attempt / 'fixture'
    prelude_command = [sys.executable, str(source / 'tests/executor_checkpoint_rtl_fixture.py'),
        '--host-fixture', str(host_fixture), '--output', str(fixture)]
    subprocess.run(prelude_command, check=True, cwd=source, timeout=120)
    fixture_files = [rec(path) for path in sorted(x for x in fixture.rglob("*") if x.is_file())]

    contract = PROJECT / 'results/executor_checkpoint_high_water_contract_20261012.md'
    contract_copy = source / 'external/executor_checkpoint_high_water_contract_20261012.md'
    contract_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_copy)

    import_contract=PROJECT/'results/executor_checkpoint_import_handshake_contract_20261013.md'
    import_contract_copy=source/'external/executor_checkpoint_import_handshake_contract_20261013.md'
    shutil.copyfile(import_contract,import_contract_copy)
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = source / MODULE / 'tb/production_guard.py'
    command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard'),
        '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
        '-notrace', '-log', str(attempt / 'vivado.log'), '-journal',
        str(attempt / 'vivado.jou'), '-source',
        str(source / MODULE / 'tb/run_executor_handoff_portal.tcl'),
        '-tclargs', str(attempt / 'work'), str(source), str(fixture),str(control_fixture),str(int(args.proof_only)),str(args.query_case),
    ]
    scope = ('Actual managed wrapper owns predecessor LPV/executor LPV/shared writer/snapshot/source-query gates; old query first ingress retains full K through persistent cancel/base revoke; complete frame byte binding and actual hub abort-only negative response; response consumption waits bound ABORT_CLOSED; canceled shell stays isolated. Query case='+str(args.query_case)+'. Bounded shell/actual provenance portal/hub/monitor handoff: explicit normal '
      'diagnostic predecessor completion after 7 real typed terminals and 112AW/7168W/112B; '
      'prequery HOLD while old final B/END/response progresses; full-key HELD; '
      'real depth2 LBS2/LBR2 16/16 transfer and tail stalls, last read only import pending; '
      'real captured task7/LPV179/target8 with literal byte oracle. '
      'Proof-only captures no import; replay uses frozen offline actual-helper confirmation, '
      'unique GRANT-consume switch to CLAIM180/epoch9, cancel retains old route. '
      'Single STATE0 predecessor writer and two LPV ingress gates only; no generated executor '
      'same-runtime helper, source AR, LN numerics, legal QUANT lease, F9/F10/action consumer, '
      '13BO aliases, committed error closure or accepted-request hardware rearm.')
    manifest = {
        'schema': 'laya-executor-checkpoint-rtl-input-v1',
        'scope': scope,
        'files': records,
        'control_files':control_records,
        'proof_only':args.proof_only,'query_case':args.query_case,'control_oracle':control_oracle,'oracle_command':oracle_command,
        'contract': {'original': rec(contract), 'frozen': rec(contract_copy)},
        'import_contract': {'original': rec(import_contract), 'frozen': rec(import_contract_copy)},
        'fixture_command': fixture_command, 'prelude_command': prelude_command,
        'host_fixture_files': [rec(path) for path in sorted(host_fixture.iterdir())],
        'fixture_files': fixture_files,
        'launcher': rec(attempt / 'launcher.json'),
        'runner': rec(source / runner_rel),
        'guard': rec(guard),
        'tool': rec(tool),
        'command': command,
        'profile': {'kind': 'rtl_pilot', 'maximum_seconds': 120,
                    'maximum_rss_gib': 8,
                    'semantic_stall_seconds': 120},
    }
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    guard_result = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = attempt / 'guard/driver.log'
    marker = 'FULL_CURRENT_EXECUTOR_HANDOFF_PORTAL_RTL_PASS'
    passed = (result.returncode == 0 and guard_result['child_exit_code'] == 0 and
              guard_result['trigger'] is None and marker in driver.read_text())
    receipt = {
        'schema': 'laya-executor-checkpoint-rtl-receipt-v1',
        'status': 'PASS' if passed else 'FAIL',
        'scope': scope,
        'launcher': rec(attempt / 'launcher.json'),
        'guard_result': guard_result,
        'input_manifest': rec(manifest_path),
        'driver_log': rec(driver),
        'rtl_capture': rec(fixture / 'actual_handoff_checkpoint.hex') if (fixture / 'actual_handoff_checkpoint.hex').exists() else None,
        'marker': [line for line in driver.read_text().splitlines()
                   if marker in line],
    }
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_EXECUTOR_HANDOFF_PORTAL_RTL_' +
          ('PASS' if passed else 'FAIL'), flush=True)
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
