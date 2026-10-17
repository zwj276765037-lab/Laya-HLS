#!/usr/bin/env python3
"""Generate and freeze the exact Vitis ap_fifo port spelling/polarity probe."""
import argparse
import hashlib
import json
from pathlib import Path
import re
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
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    frozen = attempt / 'frozen'
    rels = [Path('tests/compute_portal_fifo_probe.cpp'),
            MODULE / 'tb/run_compute_portal_fifo_probe.tcl']
    records = []
    for rel in rels:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
        records.append({'original': rec(ROOT / rel), 'frozen': rec(target)})
    vitis = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run')
    guard = ROOT / MODULE / 'tb/production_guard.py'
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
        # Classic HLS stores source paths relative to the project parent and
        # resolves them from the launcher cwd during csynth.
        '--cwd', str(attempt), '--rss-gib', '8', '--timeout-seconds', '120',
        '--semantic-stall-seconds', '120', '--', '/usr/bin/env',
        # The Tcl copies the frozen source inside the classic project before
        # add_files because Vitis HLS 2025.2 mis-resolves an external absolute
        # source path when synthesis reopens the project database.
        'LAYA_PORTAL_FIFO_PROBE_WORK=' + str(attempt),
        'LAYA_PORTAL_FIFO_PROBE_SOURCE=' +
        str(frozen / 'tests/compute_portal_fifo_probe.cpp'),
        str(vitis), '--mode', 'hls',
        '--tcl', str(frozen / MODULE / 'tb/run_compute_portal_fifo_probe.tcl'),
        '--work_dir', str(attempt / 'vitis_work')]
    manifest = {'schema': 'laya-portal-fifo-probe-input-v1',
        'scope': 'tool-generated 512-bit ap_fifo port names, directions, and polarity only',
        'files': records, 'runner': rec(Path(__file__)), 'guard': rec(guard),
        'tool': {'path': str(vitis),
                 'version': subprocess.check_output([str(vitis), '--version'],
                    text=True, stderr=subprocess.STDOUT)},
        'command': command,
        'profile': {'kind': 'hls_generation_pilot', 'maximum_seconds': 120,
                    'maximum_rss_gib': 8}}
    (attempt / 'input_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT)
    state = json.loads((attempt / 'guard/guard_result.json').read_text())
    candidates = list((attempt / 'hls').glob(
        '**/syn/verilog/laya_compute_portal_fifo_probe.v'))
    port_evidence = None
    passed = result.returncode == 0 and state['child_exit_code'] == 0 and state['trigger'] is None
    if passed and len(candidates) == 1:
        generated = candidates[0]
        text = generated.read_text()
        required = {
            'compute_cmd_din': r'output\s+\[511:0\]\s+compute_cmd_din',
            'compute_cmd_full_n': r'input\s+compute_cmd_full_n',
            'compute_cmd_write': r'output\s+compute_cmd_write',
            'compute_rsp_dout': r'input\s+\[511:0\]\s+compute_rsp_dout',
            'compute_rsp_empty_n': r'input\s+compute_rsp_empty_n',
            'compute_rsp_read': r'output\s+compute_rsp_read',
        }
        matches = {name: bool(re.search(pattern, text))
                   for name, pattern in required.items()}
        passed = all(matches.values())
        frozen_generated = attempt / 'laya_compute_portal_fifo_probe.v'
        shutil.copyfile(generated, frozen_generated)
        port_evidence = {'generated': rec(frozen_generated), 'matches': matches}
    else:
        passed = False
    receipt = {'schema': 'laya-portal-fifo-probe-receipt-v1',
        'status': 'PASS' if passed else 'FAIL', 'scope': manifest['scope'],
        'guard_result': state,
        'input_manifest': rec(attempt / 'input_manifest.json'),
        'port_evidence': port_evidence}
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_PORTAL_FIFO_PROBE_' + ('PASS' if passed else 'FAIL'))
    return 0 if passed else 1


if __name__ == '__main__':
    sys.exit(main())
