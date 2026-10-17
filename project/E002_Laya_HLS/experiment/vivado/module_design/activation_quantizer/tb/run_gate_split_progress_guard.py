#!/usr/bin/env python3
"""Freeze and check that split progress requires monotonic completed work."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[4]
Q = Path('vivado/module_design/activation_quantizer/tb')
GUARD = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py')


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    frozen = attempt / 'frozen'
    rels = [Q / 'geglu_gate_quant_split_tb_v2.sv',
            Q / 'check_gate_split_progress_guard.py', GUARD,
            Path('tools/hls_guard_helpers.py')]
    records = []
    for rel in rels:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    manifest = {'files': records, 'runner': rec(Path(__file__)),
                'scope': ('Bounded parser/control check: 1000 repeated split progress lines and '
                          'three recognized-prefix malformed/legacy lines do not refresh; two real '
                          'work increases and one unrelated legal progress line do refresh. No '
                          'Vivado or functional datapath claim.')}
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    run = subprocess.run([sys.executable, str(frozen / Q /
                          'check_gate_split_progress_guard.py')],
                         cwd=ROOT, text=True, capture_output=True)
    (attempt / 'stdout.log').write_text(run.stdout + run.stderr)
    passed = run.returncode == 0 and 'GATE_SPLIT_PROGRESS_GUARD_PASS' in run.stdout
    receipt = {'status': 'PASS' if passed else 'FAIL', 'scope': manifest['scope'],
               'input_manifest': rec(manifest_path), 'stdout': rec(attempt / 'stdout.log'),
               'returncode': run.returncode}
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('GATE_SPLIT_PROGRESS_GUARD_' + ('PASS' if passed else 'FAIL'))
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
