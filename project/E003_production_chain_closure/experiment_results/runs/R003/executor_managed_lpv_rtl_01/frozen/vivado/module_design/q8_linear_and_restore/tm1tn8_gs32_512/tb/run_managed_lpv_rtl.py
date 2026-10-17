#!/usr/bin/env python3
"""Freeze and run the bounded managed LPV A/route and persistent cleanup RTL pilot."""
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
    parser.add_argument('--admission-host',type=Path,required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    launcher = launcher_state()
    (attempt / 'launcher.json').write_text(json.dumps(launcher, indent=2) + '\n')
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')
    source = attempt / 'frozen'

    registry_path = ROOT / 'config/full_module_registry.json'
    registry = json.loads(registry_path.read_text())
    rtl_sources = registry.get('rtl_shell_sources', {}).get(
        'generated_provenance', [])
    required = {
        str(MODULE / 'rtl/laya_model_identity_13bo_generated_v1.sv'),
        str(MODULE / 'rtl/laya_compute_portal_layout_v1.sv'),
        str(MODULE / 'rtl/laya_generated_provenance_layout_v1.sv'),
        str(MODULE / 'rtl/laya_private_fifo2_v1.sv'),
        str(MODULE / 'rtl/laya_generated_provenance_v1.sv'),
        str(MODULE / 'rtl/laya_generated_provenance_hub_v1.sv'),
        str(MODULE / 'rtl/laya_generated_provenance_portal_v1.sv'),
        str(MODULE / 'rtl/laya_generated_store_monitor_v1.sv'),
        str(MODULE / 'rtl/laya_generated_provenance_axi_portal_v1.sv'),
    }
    if set(rtl_sources) != required:
        raise RuntimeError('production registry store-monitor RTL closure mismatch')
    runner_rel = Path(__file__).resolve().relative_to(ROOT)
    files = [Path(name) for name in rtl_sources]
    files += [
        MODULE / 'tb/laya_managed_lpv_tb_v1.sv',
        MODULE / 'tb/run_managed_lpv.tcl',
        MODULE / 'tb/make_managed_lpv_fixture.py',
        MODULE / 'tb/make_generated_provenance_portal_fixture.py',
        MODULE / 'tb/production_guard.py',
        Path('tools/hls_guard_helpers.py'),
        runner_rel,
        Path('config/full_module_registry.json'),
    ]
    files += [MODULE/'rtl/laya_admission_owner_layout_v1.sv']
    records = []
    for rel in files:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})

    host=args.admission_host.resolve()
    if json.loads((host/'receipt.json').read_text())['status']!='PASS':
        raise RuntimeError('actual admission host prerequisite did not PASS')
    external=source/'external/admission_host';external.mkdir(parents=True)
    external_pairs=[]
    for name in ['receipt.json','input_manifest.json','fixture/actual_admission_owner.bin','fixture/admission_owner.bin']:
        original=host/name;target=external/name;target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(original,target);external_pairs.append({'original':rec(original),'frozen':rec(target)})
    fixture = attempt / 'fixture'
    fixture_command = [sys.executable,str(source/MODULE/'tb/make_managed_lpv_fixture.py'),
        '--base-generator',str(source/MODULE/'tb/make_generated_provenance_portal_fixture.py'),
        '--admission',str(external/'fixture/actual_admission_owner.bin'),
        '--literal',str(external/'fixture/admission_owner.bin'),'--out',str(fixture)]
    oracle_guard=source/MODULE/'tb/production_guard.py'
    oracle_command=[sys.executable,str(oracle_guard),'--out',str(attempt/'guard_oracle'),
        '--cwd',str(source),'--rss-gib','8','--timeout-seconds','120','--semantic-stall-seconds','120','--']+fixture_command
    subprocess.run(oracle_command,check=True,cwd=source)
    fixture_files = [rec(path) for path in sorted(fixture.iterdir())]

    contract = PROJECT / 'results/executor_managed_lpv_owner_contract_20261013.md'
    contract_copy = source / 'external/executor_managed_lpv_owner_contract_20261013.md'
    contract_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_copy)

    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = source / MODULE / 'tb/production_guard.py'
    command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard'),
        '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
        '-notrace', '-log', str(attempt / 'vivado.log'), '-journal',
        str(attempt / 'vivado.jou'), '-source',
        str(source / MODULE / 'tb/run_managed_lpv.tcl'),
        '-tclargs', str(attempt / 'work'), str(source), str(fixture),
    ]
    scope = ('Actual C++ admitted LAD1 A bytes installed via controlled whole-record handshake; '
        'executed complete SV codec; persistent single A, first-beat lane and tagged 16/8 depth2 LPV '
        'framing, claim-only INVALIDATE and precise A/model/descriptor hub checks, persistent cancel/base '
        'revoke with old response tail stalls, ordinary half-frame and controlled preowned full-frame '
        'negative drain, actual single STATE0 monitor END/held B/adapter fence and unique typed terminal. '
        'Four reset-separated finite cases, no reset within a case. No production ingress install, actual '
        'adapter pending handshake, global HOLD lane transfer, source AR/F9/lease, all13BO, CLOSED/rearm '
        'or generated executor. Default managed mode remains disabled in existing wrappers.')
    manifest = {
        'schema': 'laya-managed-lpv-input-v1',
        'scope': scope,
        'files': records,
        'contract': {'original': rec(contract), 'frozen': rec(contract_copy)},
        'fixture_command': fixture_command,'oracle_command':oracle_command,'admission_host':external_pairs,
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
    marker = 'FULL_CURRENT_MANAGED_LPV_PASS'
    passed = (result.returncode == 0 and guard_result['child_exit_code'] == 0 and
              guard_result['trigger'] is None and marker in driver.read_text())
    receipt = {
        'schema': 'laya-managed-lpv-receipt-v1',
        'status': 'PASS' if passed else 'FAIL',
        'scope': scope,
        'launcher': rec(attempt / 'launcher.json'),
        'guard_result': guard_result,
        'input_manifest': rec(manifest_path),
        'driver_log': rec(driver),
        'marker': [line for line in driver.read_text().splitlines()
                   if marker in line],
    }
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_MANAGED_LPV_' +
          ('PASS' if passed else 'FAIL'), flush=True)
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
