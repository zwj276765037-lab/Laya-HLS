#!/usr/bin/env python3
"""Freeze actual RTL captures and verify them with the production C++ adapter."""
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

def rec(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return {'path': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--attempt', type=Path, required=True)
    ap.add_argument('--rtl-attempt', type=Path, required=True)
    args = ap.parse_args()
    attempt = args.attempt.resolve(); attempt.mkdir(exist_ok=False)
    available = next(int(s.split()[1]) for s in Path('/proc/meminfo').read_text().splitlines() if s.startswith('MemAvailable:'))
    launcher = {'pid': os.getpid(), 'cpu_affinity': sorted(os.sched_getaffinity(0)),
        'nice': os.getpriority(os.PRIO_PROCESS, 0),
        'ionice': subprocess.run(['ionice', '-p', str(os.getpid())], check=True, capture_output=True, text=True).stdout.strip(),
        'mem_available_kib': available, 'required_mem_available_kib': 201326592}
    launcher['pass'] = launcher['cpu_affinity'] == [0, 1, 2, 3] and launcher['nice'] == 19 and launcher['ionice'].startswith('idle') and available > 201326592
    (attempt/'launcher.json').write_text(json.dumps(launcher, indent=2)+'\n')
    if not launcher['pass']: raise RuntimeError('launcher rejected')
    rtl = args.rtl_attempt.resolve()
    rtl_receipt = json.loads((rtl/'receipt.json').read_text())
    if rtl_receipt['status'] != 'PASS': raise RuntimeError('actual RTL capture source is not PASS')
    capture_records = {Path(r['path']).name: r for r in rtl_receipt['actual_protocol_captures']}
    records = []; frozen = attempt/'frozen'
    def copy(src, rel):
        src = Path(src).resolve(); dst = frozen/rel
        dst.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(src, dst)
        records.append({'original': rec(src), 'frozen': rec(dst)})
    sources = ['hls/common/laya_numeric.cpp', 'hls/common/laya_tasks.cpp',
        'hls/platform/compute_portal_codec.cpp', 'hls/platform/generated_provenance_codec.cpp',
        'hls/platform/producer_engine_codec.cpp', 'hls/platform/controller_transaction_codec.cpp',
        'hls/platform/controller_transaction_adapter.cpp', 'tests/bootstrap_source_conflict_adapter_test.cpp']
    files = [Path(s) for s in sources] + sorted(p.relative_to(ROOT) for p in (ROOT/'include').glob('*.h')) + [
        Path(__file__).resolve().relative_to(ROOT), M/'tb/production_guard.py', Path('tools/hls_guard_helpers.py')]
    for rel in files: copy(ROOT/rel, rel)
    for name in ['source_conflict_before', 'source_conflict_live', 'wrong_end_active', 'target_end_actual']:
        for kind in ['request', 'response']:
            filename = f'actual_{name}_{kind}.hex'; src = rtl/'fixture'/filename
            if rec(src) != capture_records[filename]: raise RuntimeError('actual capture identity changed')
            copy(src, Path('actual_captures')/filename)
    for name in ['receipt.json', 'input_manifest.json', 'guard_pilot/driver.log']:
        copy(rtl/name, Path('external/rtl_evidence')/name)
    for name in ['executor_bootstrap_source_contract_20261012.md', 'production_hls_partition_contract_20261012.md']:
        copy(PROJECT/'results'/name, Path('external/contracts')/name)
    compiler = Path(shutil.which('g++'))
    build = [str(compiler), '-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror',
        '-Wno-unknown-pragmas', '-Wno-unused-parameter', '-Wno-aggressive-loop-optimizations',
        '-fno-fast-math', '-fno-associative-math', '-ffp-contract=off', '-I'+str(frozen/'include'),
        '-isystem', '/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include'] + [str(frozen/s) for s in sources] + ['-o', str(attempt/'test')]
    run = [str(attempt/'test'), str(frozen/'actual_captures')]
    guard = frozen/M/'tb/production_guard.py'
    def guarded(mode, command):
        return [sys.executable, str(guard), '--out', str(attempt/('guard_'+mode)), '--cwd', str(frozen),
            '--rss-gib', '24', '--timeout-seconds', '1800', '--semantic-stall-seconds', '120', '--'] + command
    commands = {'build': guarded('build', build), 'run': guarded('run', run)}
    scope = 'four full actual hub/portal responses: idle and active non-END conflicts, wrong END retaining old scope, actual generated LN short END terminal; production C++ decoder/adapter and original F16 negative; host only, no new adapter RTL or complete executor'
    manifest = {'schema': 'laya-bootstrap-conflict-adapter-input-v1', 'scope': scope,
        'files': records, 'commands': commands, 'tool': rec(compiler), 'launcher': rec(attempt/'launcher.json')}
    mp = attempt/'input_manifest.json'; mp.write_text(json.dumps(manifest, indent=2)+'\n')
    receipt = {'schema': 'laya-bootstrap-conflict-adapter-receipt-v1', 'scope': scope, 'input_manifest': rec(mp), 'status': 'RUNNING'}
    for mode, command in commands.items():
        result = subprocess.run(command)
        state = json.loads((attempt/('guard_'+mode)/'guard_result.json').read_text())
        log = attempt/('guard_'+mode)/'driver.log'; body = log.read_text()
        passed = result.returncode == 0 and state['child_exit_code'] == 0 and state['trigger'] is None
        if mode == 'run': passed = passed and 'FULL_CURRENT_BOOTSTRAP_SOURCE_CONFLICT_ADAPTER_PASS' in body
        receipt[mode] = {'status': 'PASS' if passed else 'FAIL', 'started': True,
            'runner_exit_code': result.returncode, 'guard': state, 'driver_log': rec(log),
            'marker': [s for s in body.splitlines() if 'FULL_CURRENT_BOOTSTRAP_SOURCE_CONFLICT_ADAPTER_PASS' in s]}
        receipt['status'] = 'PASS' if mode == 'run' and passed else 'RUNNING' if passed else 'FAIL'
        (attempt/'receipt.json').write_text(json.dumps(receipt, indent=2)+'\n')
        print('FULL_CURRENT_BOOTSTRAP_SOURCE_CONFLICT_ADAPTER_'+mode.upper()+'_'+('PASS' if passed else 'FAIL'), flush=True)
        if not passed: return 1
    return 0

if __name__ == '__main__': raise SystemExit(main())
