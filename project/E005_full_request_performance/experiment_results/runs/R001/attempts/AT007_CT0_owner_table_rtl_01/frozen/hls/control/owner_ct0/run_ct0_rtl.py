#!/usr/bin/env python3
"""Replay original-helper-checked CT0 records on frozen generated RTL."""
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
GEN = PROJECT / ('project/E005_full_request_performance/experiment_results/'
                 'runs/R001/attempts/AT006_CT0_owner_table_hls_03')
ATTEMPT = PROJECT / ('project/E005_full_request_performance/experiment_results/'
                     'runs/R001/attempts/AT007_CT0_owner_table_rtl_01')
VITIS_INCLUDE = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include')
VIVADO = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
GUARD = Path('vivado/module_design/q8_linear_and_restore/'
             'tm1tn8_gs32_512/tb/production_guard.py')
UNITS = [MODULE / 'owner_ct0.cpp', MODULE / 'owner_ct0_host_tb.cpp',
         Path('hls/common/laya_full_owner.cpp'),
         Path('hls/common/laya_numeric.cpp'),
         Path('hls/common/laya_tasks.cpp')]


def rec(path):
    data = path.read_bytes()
    return {'path': str(path), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def save(path, obj):
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + '\n')


def guarded(name, command, frozen, cwd, *, rtl=False, env=None):
    out = ATTEMPT / ('guard_' + name)
    if out.exists():
        raise RuntimeError('refuse to overwrite guard ' + str(out))
    cmd = [sys.executable, str(frozen / GUARD), '--out', str(out),
           '--cwd', str(cwd), '--rss-gib', '8' if rtl else '24',
           '--timeout-seconds', '120' if name == 'pilot' else
           '3600' if rtl else '1800', '--semantic-stall-seconds', '120',
           '--', *map(str, command)]
    child = subprocess.run(cmd, cwd=cwd, env=env)
    guard = json.loads((out / 'guard_result.json').read_text())
    return {'runner_exit_code': child.returncode, 'command': cmd,
            'guard': guard, 'log': rec(out / 'driver.log'),
            'pass': child.returncode == 0 and
                    guard['child_exit_code'] == 0 and guard['trigger'] is None}


def main():
    if ATTEMPT.exists():
        raise RuntimeError('attempt already exists: ' + str(ATTEMPT))
    parent = json.loads((GEN / 'receipt.json').read_text())
    if parent['status'] != 'PASS_SCOPED_GENERATION':
        raise RuntimeError('generation is not a scoped pass')
    available = next(int(line.split()[1]) for line in
                     Path('/proc/meminfo').read_text().splitlines()
                     if line.startswith('MemAvailable:'))
    if available <= 192 * 1024 * 1024 or not {0, 1, 2, 3}.issubset(
            os.sched_getaffinity(0)):
        raise RuntimeError('resource preflight failed')
    ATTEMPT.mkdir(parents=True)
    frozen = ATTEMPT / 'frozen'
    shutil.copytree(GEN / 'frozen', frozen)
    # The arithmetic/owner DUT remains byte-identical to AT006. Only this
    # host tester gains trace emission, and the new finite SV bench is added.
    source = ROOT / MODULE / 'owner_ct0.cpp'
    if rec(source)['sha256'] != rec(frozen / MODULE / 'owner_ct0.cpp')['sha256']:
        raise RuntimeError('live DUT drifted from generated identity')
    changed = [MODULE / 'owner_ct0_host_tb.cpp', MODULE / 'owner_ct0_tb.sv',
               MODULE / 'run_ct0_rtl.py']
    for rel in changed:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, target)
    rtl_dir = frozen / 'generated'
    rtl_dir.mkdir()
    originals = sorted((GEN / 'work/hls/syn/verilog').iterdir())
    for source in originals:
        if source.suffix in {'.v', '.dat'}:
            shutil.copyfile(source, rtl_dir / source.name)
    rtl = sorted(rtl_dir.glob('*.v'))
    if len(rtl) != 17 or len(list(rtl_dir.glob('*.dat'))) != 2:
        raise RuntimeError('generated RTL/ROM closure changed')
    trace = ATTEMPT / 'trace'
    trace.mkdir()
    work = ATTEMPT / 'work'
    work.mkdir()
    for dat in rtl_dir.glob('*.dat'):
        shutil.copyfile(dat, work / dat.name)
    env = os.environ.copy()
    env['CT0_TRACE_DIR'] = str(trace)
    cflags = ['-std=c++17', '-DAP_INT_MAX_W=8192',
              '-I' + str(frozen / 'include'), '-I' + str(frozen / MODULE),
              '-isystem', str(VITIS_INCLUDE)]
    binary = ATTEMPT / 'owner_ct0_trace_tb'
    host_build = guarded('host_build',
        ['g++', *cflags, '-O0', '-ffunction-sections', '-fdata-sections',
         '-Wno-unknown-pragmas', *[str(frozen / p) for p in UNITS],
         '-Wl,--gc-sections', '-o', str(binary)], frozen, frozen)
    host_run = guarded('host_run', [str(binary)], frozen, frozen, env=env) if host_build['pass'] else None
    marker = (host_run and host_run['pass'] and
              'CT0_HOST_PASS checks=782 operations=16 records=32 commits=6 '
              'trace_transactions=131' in Path(host_run['log']['path']).read_text())
    if not marker or len((trace / 'commands.mem').read_text().splitlines()) != 1572 or \
       len((trace / 'responses.mem').read_text().splitlines()) != 1441:
        raise RuntimeError('original-helper-checked complete trace unavailable')
    manifest = {
        'schema': 'laya-ct0-generated-rtl-input-v1',
        'scope': '32 complete records, original helper checked 131 transactions, '
                 'generated table RAM, fixed 512-bit FIFO, deterministic output backpressure',
        'generation_receipt': rec(GEN / 'receipt.json'),
        'generation_manifest': rec(GEN / 'input_manifest.json'),
        'frozen_files': [rec(p) for p in sorted(frozen.rglob('*')) if p.is_file()],
        'trace_files': [rec(trace / name) for name in ('commands.mem','responses.mem')],
        'host_build': host_build, 'host_run': host_run,
        'tools': {name: str(VIVADO / name) for name in ('xvlog','xelab','xsim')},
        'limits': {'static_seconds': 1800, 'rtl_seconds': 3600,
                   'pilot_seconds': 120, 'rtl_rss_gib': 8,
                   'static_rss_gib': 24, 'maximum_cycles': 400000},
    }
    save(ATTEMPT / 'input_manifest.json', manifest)
    receipt = {'schema':'laya-ct0-generated-rtl-receipt-v1',
               'status':'RUNNING', 'manifest':rec(ATTEMPT/'input_manifest.json'),
               'host_build':host_build, 'host_run':host_run}
    save(ATTEMPT / 'receipt.json', receipt)
    xvlog = guarded('xvlog', [str(VIVADO / 'xvlog'), '-sv',
                    *map(str, rtl), str(frozen / MODULE / 'owner_ct0_tb.sv')],
                    frozen, work)
    receipt['xvlog'] = xvlog
    save(ATTEMPT / 'receipt.json', receipt)
    if not xvlog['pass']:
        receipt['status'] = 'STATIC_FAIL'
        save(ATTEMPT / 'receipt.json', receipt)
        return 1
    xelab = guarded('xelab', [str(VIVADO / 'xelab'), 'work.owner_ct0_tb',
                    '-s', 'owner_ct0_tb_behav'], frozen, work)
    receipt['xelab'] = xelab
    save(ATTEMPT / 'receipt.json', receipt)
    if not xelab['pass']:
        receipt['status'] = 'STATIC_FAIL'
        save(ATTEMPT / 'receipt.json', receipt)
        return 1
    script = work / 'run.tcl'
    script.write_text('run all\nquit\n')
    manifest['sim_script'] = rec(script)
    save(ATTEMPT / 'input_manifest.json', manifest)
    receipt['manifest'] = rec(ATTEMPT / 'input_manifest.json')
    for mode in ('pilot', 'full'):
        args = [str(VIVADO / 'xsim'), 'owner_ct0_tb_behav',
                '-tclbatch', str(script),
                '-testplusarg', 'COMMANDS=' + str(trace / 'commands.mem'),
                '-testplusarg', 'RESPONSES=' + str(trace / 'responses.mem'),
                '-log', str(ATTEMPT / (mode + '.log'))]
        if mode == 'pilot': args += ['-testplusarg', 'PILOT']
        step = guarded(mode, args, frozen, work, rtl=True)
        body = Path(step['log']['path']).read_text(errors='replace')
        match = re.search(r'CT0_RTL_\s*(?:PILOT|FULL)_PASS cycles=(\d+) '
                          r'transactions=(\d+) input_words=(\d+) '
                          r'output_words=(\d+) held_cycles=(\d+)', body)
        step['marker'] = match.group(0) if match else None
        step['cycles'] = int(match[1]) if match else None
        step['pass'] = step['pass'] and match is not None and (
            int(match[2]) == (2 if mode == 'pilot' else 131))
        receipt[mode] = step
        save(ATTEMPT / 'receipt.json', receipt)
        if not step['pass']:
            receipt['status'] = ('COST_STOP' if step['guard']['trigger'] else
                                 'RTL_FAIL')
            save(ATTEMPT / 'receipt.json', receipt)
            return 1
        if mode == 'pilot':
            projected = step['guard']['elapsed_seconds'] * 131 / 2 * 2
            receipt['cost_decision'] = {'projected_full_seconds': projected,
                                        'status': 'RUN_FULL' if projected <= 3600
                                        else 'COST_STOP'}
            save(ATTEMPT / 'receipt.json', receipt)
            if projected > 3600:
                receipt['status'] = 'COST_STOP'
                save(ATTEMPT / 'receipt.json', receipt)
                return 1
    receipt['status'] = 'PASS_SCOPED_RTL'
    save(ATTEMPT / 'receipt.json', receipt)
    print('CT0_RTL_PASS_SCOPED_RTL', flush=True)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
