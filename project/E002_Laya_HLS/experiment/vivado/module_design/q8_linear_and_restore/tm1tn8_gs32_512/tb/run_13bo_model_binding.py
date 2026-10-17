#!/usr/bin/env python3
"""Freeze and run the bounded original-13BO persistent model binding test."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')


def rec(path):
    path = path.resolve()
    return {'path': str(path), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--control', type=Path, required=True)
    args = parser.parse_args()
    attempt, control = args.attempt.resolve(), args.control.resolve()
    attempt.mkdir(exist_ok=False)
    source = attempt / 'frozen'
    names = ['laya_model_identity_13bo_generated_v1', 'laya_13bo_abi_v1',
             'laya_13bo_base_mirror_v1', 'laya_13bo_model_binding_v1',
             'laya_13bo_request_gate_v1']
    files = [MODULE / 'rtl' / (name + '.sv') for name in names]
    files += [MODULE / 'tb/laya_13bo_model_binding_tb_v1.sv',
              MODULE / 'tb/run_13bo_model_binding.tcl',
              Path('tools/generate_laya_model_identity_sv.py'),
              Path('build/model-repair/laya_model_layout_generated.h')]
    records = []
    for rel in files:
        target = source / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    frozen_control = source / 'reference' / control.name
    frozen_control.parent.mkdir(parents=True)
    shutil.copyfile(control, frozen_control)
    records.append({'original': rec(control), 'frozen': rec(frozen_control)})
    generated = source / MODULE / 'rtl/laya_model_identity_13bo_generated_v1.sv'
    regenerated = attempt / 'regenerated_laya_model_identity_13bo_generated_v1.sv'
    generation_command = [sys.executable,
        str(source / 'tools/generate_laya_model_identity_sv.py'), '--header',
        str(source / 'build/model-repair/laya_model_layout_generated.h'),
        '--output', str(regenerated)]
    subprocess.run(generation_command, check=True, cwd=source)
    if regenerated.read_bytes() != generated.read_bytes():
        raise RuntimeError('frozen model header does not regenerate frozen SV identity package')
    tool = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
        '--cwd', str(ROOT), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch',
        '-notrace', '-log', str(attempt / 'vivado.log'), '-journal',
        str(attempt / 'vivado.jou'), '-source',
        str(source / MODULE / 'tb/run_13bo_model_binding.tcl'), '-tclargs',
        str(attempt / 'work'), str(source), str(frozen_control)]
    inputs = {'schema': 'laya-13bo-model-binding-input-v1', 'files': records,
        'generation_command': generation_command, 'regenerated_package': rec(regenerated),
        'runner': rec(Path(__file__)), 'guard': rec(guard), 'tool': rec(tool),
        'command': command,
        'scope': 'actual generated control-r mirror plus ap_start gate and persistent five-model-BO binding; controlled RTL wrapper, not final full-kernel integration'}
    (attempt / 'input_manifest.json').write_text(json.dumps(inputs, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    driver = (attempt / 'guard/driver.log').read_text()
    passed = result.returncode == 0 and state['child_exit_code'] == 0 and \
             state['trigger'] is None and 'FULL_CURRENT_13BO_MODEL_BINDING_PASS' in driver
    receipt = {'schema': 'laya-13bo-model-binding-receipt-v1',
        'status': 'PASS' if passed else 'FAIL', 'scope': inputs['scope'],
        'guard_result': state, 'input_manifest': rec(attempt / 'input_manifest.json'),
        'driver_log': rec(attempt / 'guard/driver.log')}
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_13BO_MODEL_BINDING_' + ('PASS' if passed else 'FAIL'), flush=True)
    return 0 if passed else 1


if __name__ == '__main__':
    sys.exit(main())
