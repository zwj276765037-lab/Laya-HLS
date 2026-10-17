#!/usr/bin/env python3
"""Freeze and guard the first CT0 host/original-helper and thin HLS attempt."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT.parents[2]
MODULE = Path('hls/control/owner_ct0')
EVIDENCE = PROJECT / ('project/E005_full_request_performance/experiment_results/'
                      'runs/R001/attempts/AT006_CT0_owner_table_hls_03')
VITIS = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++')
VITIS_INCLUDE = VITIS.parents[1] / 'include'
GUARD = Path('vivado/module_design/q8_linear_and_restore/'
             'tm1tn8_gs32_512/tb/production_guard.py')
UNITS = [MODULE / 'owner_ct0.cpp', MODULE / 'owner_ct0_host_tb.cpp',
         Path('hls/common/laya_full_owner.cpp'),
         Path('hls/common/laya_numeric.cpp'),
         Path('hls/common/laya_tasks.cpp')]


def record(path):
    data = path.read_bytes()
    return {'path': str(path), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def save(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def run_guard(name, command, frozen, *, hls=False):
    out = EVIDENCE / ('guard_' + name)
    if out.exists():
        raise RuntimeError('refuse to overwrite guard: ' + str(out))
    cwd = EVIDENCE if hls else frozen
    args = [sys.executable, str(frozen / GUARD), '--out', str(out),
            '--cwd', str(cwd), '--rss-gib', '24',
            '--timeout-seconds', '1800', '--semantic-stall-seconds', '120']
    if hls:
        args += ['--artifact-progress-root', str(EVIDENCE / 'work')]
    args += ['--', *map(str, command)]
    result = subprocess.run(args, cwd=cwd)
    observed = (json.loads((out / 'guard_result.json').read_text())
                if (out / 'guard_result.json').is_file() else
                {'child_exit_code': None, 'trigger': 'guard_preflight_failed'})
    return {'runner_exit_code': result.returncode, 'guard': observed,
            'log': record(out / 'driver.log') if (out / 'driver.log').is_file()
                   else None, 'command': args,
            'pass': result.returncode == 0 and
                    observed['child_exit_code'] == 0 and
                    observed['trigger'] is None}


def main():
    if EVIDENCE.exists():
        raise RuntimeError('attempt already exists: ' + str(EVIDENCE))
    if not VITIS.is_file():
        raise RuntimeError('Vitis tool missing')
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    if available <= 192 * 1024 * 1024 or not {0, 1, 2, 3}.issubset(
            os.sched_getaffinity(0)):
        raise RuntimeError('MemAvailable / CPU preflight failed')
    EVIDENCE.mkdir(parents=True)
    frozen = EVIDENCE / 'frozen'
    flags = ['-std=c++17', '-DAP_INT_MAX_W=8192',
             '-I' + str(ROOT / 'include'), '-I' + str(ROOT / MODULE),
             '-isystem', str(VITIS_INCLUDE)]
    closure = set(UNITS) | {MODULE / 'owner_ct0.h', MODULE / 'run_ct0.py', GUARD,
                            Path('tools/hls_guard_helpers.py')}
    for unit in UNITS:
        output = subprocess.check_output(
            ['g++', *flags, '-MM', str(ROOT / unit)],
            cwd=ROOT, text=True, timeout=180)
        for item in output.replace('\\\n', ' ').split(':', 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path.relative_to(ROOT))
    copied = []
    for rel in sorted(closure):
        source = ROOT / rel
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        copied.append({'relative': str(rel), 'original': record(source),
                       'frozen': record(target)})
    design = PROJECT / ('project/E002_Laya_HLS/experiment/hls/control/'
                        'owner_ct0/source/design.md')
    contract = PROJECT / 'mission/measurement_next_stage_20261013.md'
    cflags = ['-std=c++17', '-DAP_INT_MAX_W=8192',
              '-I' + str(frozen / 'include'),
              '-I' + str(frozen / MODULE), '-isystem', str(VITIS_INCLUDE)]
    executable = EVIDENCE / 'owner_ct0_host_tb'
    host_build = run_guard('host_build',
        ['g++', *cflags, '-O0', '-ffunction-sections', '-fdata-sections',
         '-Wno-unknown-pragmas', *[str(frozen / unit) for unit in UNITS],
         '-Wl,--gc-sections', '-o', str(executable)], frozen)
    host_run = run_guard('host_run', [str(executable)], frozen) if host_build['pass'] else None
    host_marker = host_run and 'CT0_HOST_PASS' in Path(host_run['log']['path']).read_text()
    manifest = {
        'schema': 'laya-ct0-hls-input-v1',
        'scope': 'diagnostic-only 32-entry complete FullOwnerRecord table; '
                 'REQUIRE/ACQUIRE/RELEASE_READ; no production owner or retirement',
        'top': 'laya_owner_ct0', 'sources': copied,
        'contract': record(contract), 'design': record(design),
        'host_build': host_build, 'host_run': host_run,
        'host_marker': bool(host_marker),
        'tool': {'path': str(VITIS), 'version': subprocess.check_output(
            [str(VITIS), '--version'], text=True,
            stderr=subprocess.STDOUT, timeout=30)},
    }
    if not host_marker:
        save(EVIDENCE / 'input_manifest.json', manifest)
        save(EVIDENCE / 'receipt.json', {'status': 'HOST_FAIL',
                                       'manifest': record(EVIDENCE / 'input_manifest.json')})
        return 1
    cfg = EVIDENCE / 'ct0.cfg'
    cfg.write_text('\n'.join([
        'part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
        'flow_target=vivado', 'syn.top=laya_owner_ct0',
        'syn.compile.pipeline_loops=0',
        'syn.array_partition.throughput_driven=off',
        'syn.array_partition.complete_threshold=0',
        'syn.file=' + str(frozen / MODULE / 'owner_ct0.cpp'),
        'syn.cflags=' + ' '.join(cflags),
    ]) + '\n')
    manifest['config'] = record(cfg)
    save(EVIDENCE / 'input_manifest.json', manifest)
    hls = run_guard('hls', [str(VITIS), '--compile', '--mode', 'hls',
             '--config', str(cfg), '--work_dir', str(EVIDENCE / 'work')],
             frozen, hls=True)
    generated = sorted((EVIDENCE / 'work').glob('**/syn/verilog/laya_owner_ct0.v'))
    status = 'PASS_SCOPED_GENERATION' if hls['pass'] and len(generated) == 1 else (
             'COST_STOP' if hls['guard']['trigger'] else 'FAIL')
    save(EVIDENCE / 'receipt.json', {
        'schema': 'laya-ct0-hls-receipt-v1', 'status': status,
        'host_build': host_build, 'host_run': host_run,
        'hls': hls, 'generated': [record(p) for p in generated],
        'manifest': record(EVIDENCE / 'input_manifest.json'),
    })
    print('CT0_HLS_' + status, flush=True)
    return 0 if status == 'PASS_SCOPED_GENERATION' else 1


if __name__ == '__main__':
    raise SystemExit(main())
