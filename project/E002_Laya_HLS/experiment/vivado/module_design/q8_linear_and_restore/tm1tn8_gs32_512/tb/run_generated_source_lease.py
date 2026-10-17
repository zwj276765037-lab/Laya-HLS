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
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    launcher = launcher_state()
    (attempt / 'launcher.json').write_text(json.dumps(launcher, indent=2) + '\n')
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')
    source = attempt / 'frozen'
    rtl = [
        'laya_model_identity_13bo_generated_v1',
        'laya_compute_portal_layout_v1',
        'laya_generated_provenance_layout_v1',
        'laya_private_fifo2_v1',
        'laya_generated_provenance_v1',
        'laya_generated_provenance_hub_v1',
        'laya_generated_provenance_portal_v1',
    ]
    files = [MODULE / 'rtl' / (name + '.sv') for name in rtl]
    files += [
        MODULE / 'tb/laya_generated_source_lease_tb_v1.sv',
        MODULE / 'tb/run_generated_source_lease.tcl',
        MODULE / 'tb/make_generated_source_lease_fixture.py',
        MODULE / 'tb/make_generated_provenance_portal_fixture.py',
    ]
    records = []
    for rel in files:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    fixture = attempt / 'fixture'
    fixture_command = [
        sys.executable,
        str(source / MODULE / 'tb/make_generated_source_lease_fixture.py'),
        '--package', str(source / MODULE /
                         'rtl/laya_model_identity_13bo_generated_v1.sv'),
        '--base-generator', str(source / MODULE /
                                'tb/make_generated_provenance_portal_fixture.py'),
        '--out', str(fixture),
    ]
    subprocess.run(fixture_command, check=True, cwd=source)
    fixture_files = [rec(path) for path in sorted(fixture.iterdir())]
    contracts = []
    for name in ['generated_provenance_channel_contract_20261012.md',
                 'ordinary_linear_provenance_contract_20261012.md']:
        original = PROJECT / 'results' / name
        frozen = source / 'external' / name
        frozen.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(original, frozen)
        contracts.append({'original': rec(original), 'frozen': rec(frozen)})
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard'),
        '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
        '-notrace', '-log', str(attempt / 'vivado.log'), '-journal',
        str(attempt / 'vivado.jou'), '-source',
        str(source / MODULE / 'tb/run_generated_source_lease.tcl'),
        '-tclargs', str(attempt / 'work'), str(source), str(fixture),
    ]
    scope = (
        'persistent LPV1 hub source ledger for one B1/S64 role-6 TOKEN/F32 '
        'owner: four non-tail rows1 producer attempts rejected without '
        'publication, then four distinct full rows16 producer Contexts, no early tensor '
        'publication, full NumericIdentity/L13M/P/Ref/range checks, atomic '
        'single source read lease, physical-drain-gated release, owner release '
        'exclusion, portal-generation replay rejection and greater-generation '
        'reread; controlled physical observations and direct query sideband, '
        'not real QUANT AXI reads, dispatcher reservations, full request, or hardware')
    manifest = {
        'schema': 'laya-generated-source-lease-input-v1',
        'scope': scope,
        'files': records,
        'contracts': contracts,
        'fixture_command': fixture_command,
        'fixture_files': fixture_files,
        'launcher': rec(attempt / 'launcher.json'),
        'runner': rec(Path(__file__)),
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
    marker = 'FULL_CURRENT_GENERATED_SOURCE_LEASE_PASS'
    passed = (result.returncode == 0 and guard_result['child_exit_code'] == 0 and
              guard_result['trigger'] is None and marker in driver.read_text() and
              'ERROR:' not in driver.read_text())
    receipt = {
        'schema': 'laya-generated-source-lease-receipt-v1',
        'status': 'PASS' if passed else 'FAIL',
        'scope': scope,
        'guard_result': guard_result,
        'launcher': rec(attempt / 'launcher.json'),
        'input_manifest': rec(manifest_path),
        'driver_log': rec(driver),
        'marker': [line for line in driver.read_text().splitlines()
                   if marker in line],
    }
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_GENERATED_SOURCE_LEASE_' +
          ('PASS' if passed else 'FAIL'), flush=True)
    return 0 if passed else 1


if __name__ == '__main__':
    sys.exit(main())
