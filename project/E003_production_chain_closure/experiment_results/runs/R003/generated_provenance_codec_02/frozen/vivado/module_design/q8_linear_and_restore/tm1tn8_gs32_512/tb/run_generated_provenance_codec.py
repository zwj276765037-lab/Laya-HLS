#!/usr/bin/env python3
"""Freeze and run the bounded LPV1/LPA1 C++ codec and Python byte oracle."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
UNITS = [
    'hls/common/laya_numeric.cpp',
    'hls/common/laya_tasks.cpp',
    'hls/platform/generated_provenance_codec.cpp',
    'hls/platform/generated_provenance_client.cpp',
    'tests/generated_provenance_codec_test.cpp',
]


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def worker(output):
    output.mkdir(parents=True, exist_ok=True)
    flags = ['-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror',
             '-fno-fast-math', '-fno-associative-math', '-ffp-contract=off',
             '-I' + str(ROOT / 'include'),
             '-I' + str(ROOT / 'build/model-repair')]
    objects = []
    for index, unit in enumerate(UNITS):
        obj = output / f'{index}.o'
        subprocess.run(['/usr/bin/g++', *flags, '-c', str(ROOT / unit),
                        '-o', str(obj)], check=True, cwd=ROOT)
        objects.append(obj)
        print('FULL_CURRENT_GENERATED_PROVENANCE_COMPILED unit=' + unit,
              flush=True)
    executable = output / 'generated_provenance_codec_test'
    subprocess.run(['/usr/bin/g++', *map(str, objects), '-o', str(executable)],
                   check=True, cwd=ROOT)
    subprocess.run([str(executable), str(output)], check=True, cwd=ROOT)
    subprocess.run([sys.executable,
                    str(ROOT / 'tests/generated_provenance_wire_test.py'),
                    str(output)], check=True, cwd=ROOT)
    print('FULL_CURRENT_GENERATED_PROVENANCE_CODEC_ORACLE_PASS', flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path)
    parser.add_argument('--worker-out', type=Path)
    args = parser.parse_args()
    if args.worker_out:
        worker(args.worker_out.resolve())
        return
    if args.attempt is None:
        parser.error('--attempt is required')
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    frozen = attempt / 'frozen'
    frozen.mkdir()
    flags = ['-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror',
             '-fno-fast-math', '-fno-associative-math', '-ffp-contract=off',
             '-I' + str(ROOT / 'include'),
             '-I' + str(ROOT / 'build/model-repair')]
    closure = set()
    for unit in UNITS:
        deps = subprocess.check_output(['/usr/bin/g++', *flags, '-MM',
                                        str(ROOT / unit)], text=True, cwd=ROOT)
        for item in deps.replace('\\\n', ' ').split(':', 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path)
    runner = Path(__file__).resolve()
    guard = ROOT / MODULE / 'tb/production_guard.py'
    helper = ROOT / 'tools/hls_guard_helpers.py'
    closure.update({runner, guard, helper,
                    ROOT / 'tests/generated_provenance_wire_test.py',
                    ROOT / 'config/full_sources.cmake',
                    ROOT / 'config/full_module_registry.json'})
    files = []
    for source in sorted(closure):
        target = frozen / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        files.append({'original': rec(source), 'frozen': rec(target)})
    contract = PROJECT / 'results/generated_provenance_channel_contract_20261012.md'
    contract_target = frozen / 'external/generated_provenance_channel_contract_20261012.md'
    contract_target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_target)
    command = [sys.executable, str(frozen / guard), '--out',
               str(attempt / 'guard'), '--cwd', str(frozen),
               '--rss-gib', '24', '--timeout-seconds', '1800',
               '--semantic-stall-seconds', '120', '--', sys.executable,
               str(frozen / runner.relative_to(ROOT)), '--worker-out',
               str(attempt / 'worker')]
    manifest = {
        'schema': 'laya-generated-provenance-codec-input-v1',
        'scope': ('LPV1/LPA1 fixed byte codec, complete response binding, '
                  'reserved-field mutations and independent Python byte oracle; '
                  'no generated RTL, physical ledger, AXI coverage or task retirement claim'),
        'files': files,
        'contract': {'original': rec(contract), 'frozen': rec(contract_target)},
        'compiler': subprocess.check_output(['/usr/bin/g++', '--version'], text=True),
        'command': command,
    }
    (attempt / 'input_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    run = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    log = attempt / 'guard/driver.log'
    marker = 'FULL_CURRENT_GENERATED_PROVENANCE_CODEC_ORACLE_PASS'
    passed = (run.returncode == 0 and state['child_exit_code'] == 0 and
              state['trigger'] is None and marker in log.read_text())
    artifacts = [rec(path) for path in sorted((attempt / 'worker').iterdir())
                 if path.is_file()]
    receipt = {
        'schema': 'laya-generated-provenance-codec-receipt-v1',
        'status': 'PASS' if passed else 'FAIL',
        'scope': manifest['scope'],
        'guard': state,
        'marker': [line for line in log.read_text().splitlines()
                   if 'FULL_CURRENT_GENERATED_PROVENANCE_' in line],
        'driver_log': rec(log),
        'input_manifest': rec(attempt / 'input_manifest.json'),
        'artifacts': artifacts,
    }
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_GENERATED_PROVENANCE_CODEC_RUN_' +
          ('PASS' if passed else 'FAIL'), flush=True)
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
