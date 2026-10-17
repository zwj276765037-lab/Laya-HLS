#!/usr/bin/env python3
"""Bounded unit check for the matrix runner's pre-full COST_STOP record path."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path


def rec(path):
    path = path.resolve()
    return dict(path=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    runner_path = Path(__file__).with_name('run_matrix_portal_binding.py').resolve()
    spec = importlib.util.spec_from_file_location('matrix_binding_runner', runner_path)
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    scope = ('Bounded synthetic check of the matrix runner pre-full cost rejection and '
             'manifest/receipt identity only; no Vivado, RTL, matrix function, or pilot claim.')
    inputs = dict(
        scope=scope,
        runner=rec(runner_path),
        checker=rec(Path(__file__)),
        full_cost_basis=dict(
            pilot_cycles=1,
            pilot_seconds=1.0,
            seconds_per_cycle=1.0,
            full_cycle_cap=200000,
            conservative_multiplier=1.5,
            conservative_estimate_seconds=3601,
            full_cap_seconds=3600,
            prerequisite='synthetic branch input; no hardware result',
            applicability='Exercises record consistency and launch rejection only.'))
    results = dict(scope=scope, precondition='SYNTHETIC_BRANCH_INPUT')
    if not runner.apply_full_cost_gate(attempt, inputs, results):
        raise RuntimeError('over-cap input did not stop full')
    manifest = attempt / 'input_manifest.json'
    receipt_path = attempt / 'receipt.json'
    receipt = json.loads(receipt_path.read_text())
    if receipt['full']['status'] != 'COST_STOP' or receipt['full']['started'] is not False:
        raise RuntimeError('structured COST_STOP record missing')
    if receipt['input_manifest']['sha256'] != rec(manifest)['sha256']:
        raise RuntimeError('receipt does not bind the final manifest')
    forbidden = [attempt / 'guard_full', attempt / 'full.log', attempt / 'full.jou']
    if any(path.exists() for path in forbidden):
        raise RuntimeError('full-stage artifact exists on rejected launch')
    verification = dict(
        status='PASS', scope=scope, full_started=False,
        conservative_estimate_seconds=3601, full_cap_seconds=3600,
        input_manifest=rec(manifest), receipt=rec(receipt_path),
        forbidden_full_artifacts_absent=True)
    (attempt / 'verification.json').write_text(json.dumps(verification, indent=2) + '\n')
    print('FULL_CURRENT_MATRIX_BINDING_COST_STOP_BRANCH_PASS')


if __name__ == '__main__':
    main()
