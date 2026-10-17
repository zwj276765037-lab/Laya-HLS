#!/usr/bin/env python3
"""Freeze, host-check, and synthesize the single-transaction FIFO adapter."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shutil
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[5]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
SOURCE_LIST = Path('config/controller_adapter_sources.cmake')
TOP = 'laya_command_provenance_adapter'
VITIS = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++')
VITIS_INCLUDE = VITIS.parents[1] / 'include'
MEMORY_LIMIT = 24 * 1024**3


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


def limit_child():
    resource.setrlimit(resource.RLIMIT_AS, (MEMORY_LIMIT, MEMORY_LIMIT))


def record_tree(root):
    if not root.exists():
        return []
    return [rec(path) for path in sorted(root.rglob('*')) if path.is_file()]


def copy_one(rel, frozen, records):
    source = ROOT / rel
    if not source.is_file():
        raise RuntimeError(f'missing input {rel}')
    target = frozen / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    records.append({'relative': str(rel), 'original': rec(source),
                    'frozen': rec(target)})


def freeze_closure(roots, frozen, records):
    flags = ['-std=c++17', '-I' + str(ROOT / 'include'),
             '-I' + str(ROOT / 'hls'), '-I' + str(ROOT / 'hls/platform'),
             '-I' + str(ROOT / MODEL), '-isystem', str(VITIS_INCLUDE)]
    closure = set((ROOT / rel).resolve() for rel in roots)
    for rel in roots:
        if rel.suffix not in {'.cpp', '.cc', '.cxx', '.c'}:
            continue
        deps = subprocess.check_output(
            ['g++', *flags, '-MM', str(ROOT / rel)], cwd=ROOT, text=True,
            preexec_fn=limit_child)
        for item in deps.replace('\\\n', ' ').split(':', 1)[1].split():
            path = Path(item).resolve()
            if path == ROOT or ROOT in path.parents:
                closure.add(path)
    for path in sorted(closure):
        rel = path.relative_to(ROOT)
        if not (frozen / rel).exists():
            copy_one(rel, frozen, records)


def run(command, cwd, log):
    started = time.monotonic()
    with log.open('w') as stream:
        result = subprocess.run(command, cwd=cwd, stdout=stream,
                                stderr=subprocess.STDOUT, timeout=1800,
                                preexec_fn=limit_child)
    return {'command': command, 'exit_code': result.returncode,
            'elapsed_seconds': time.monotonic() - started, 'log': rec(log)}


def source_list(path):
    sources = [Path(value) for value in re.findall(
        r'^\s*(hls/[^\s]+\.cpp)\s*$', path.read_text(), re.M)]
    if len(sources) != 7 or len(sources) != len(set(sources)):
        raise RuntimeError('invalid Controller adapter source list')
    forbidden = ('full_forward_controller.cpp', 'full_tasks.cpp',
                 'generated_provenance_events.cpp', 'compute_portal_hls.cpp',
                 'generated_provenance_hls.cpp', 'producer_engine_hls.cpp')
    if any(any(str(source).endswith(name) for name in forbidden)
           for source in sources):
        raise RuntimeError('graph, owner, or exchange implementation entered adapter')
    return sources


def port_evidence(path):
    text = path.read_text(errors='replace')
    patterns = {}
    for name in ('transaction_completion', 'compute_command',
                 'provenance_command', 'producer_request'):
        patterns[name + '_din'] = rf'output\s+(?:wire\s+)?\[511:0\]\s+{name}_din'
        patterns[name + '_full_n'] = rf'input\s+(?:wire\s+)?{name}_full_n'
        patterns[name + '_write'] = rf'output\s+(?:wire\s+)?{name}_write'
    for name in ('transaction_request', 'compute_response',
                 'provenance_response', 'producer_completion'):
        patterns[name + '_dout'] = rf'input\s+(?:wire\s+)?\[511:0\]\s+{name}_dout'
        patterns[name + '_empty_n'] = rf'input\s+(?:wire\s+)?{name}_empty_n'
        patterns[name + '_read'] = rf'output\s+(?:wire\s+)?{name}_read'
    matches = {name: bool(re.search(pattern, text))
               for name, pattern in patterns.items()}
    controls = {name: bool(re.search(rf'\b{name}\b', text))
                for name in ('ap_clk', 'ap_rst', 'cancel')}
    forbidden = {name: bool(re.search(rf'\b{name}\b', text))
                 for name in ('ap_start', 'ap_done', 'ap_idle', 'ap_ready')}
    return {'generated': rec(path), 'fifo_matches': matches,
            'fifo_signal_count': sum(matches.values()),
            'external_fifo_signal_count': sum(
                value for name, value in matches.items()
                if not name.startswith('transaction_')),
            'controls': controls, 'forbidden_control': forbidden}


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

    sources = source_list(ROOT / SOURCE_LIST)
    test = Path('tests/controller_transaction_adapter_test.cpp')
    frozen = attempt / 'frozen'
    records = []
    roots = sources + [test, SOURCE_LIST,
        Path('config/production_hls_partitions.json'),
        Path('config/full_module_registry.json'),
        MODULE / 'rtl/laya_controller_transaction_layout_v1.sv',
        MODULE / 'tb/production_guard.py',
        Path('tools/hls_guard_helpers.py'),
        Path(__file__).resolve().relative_to(ROOT)]
    freeze_closure(roots, frozen, records)
    # The generated model header is normally discovered through the host-test
    # dependency closure.  Keep the two model artifacts explicit without
    # adding a second manifest record for a file that is already frozen.
    for rel in (MODEL / 'laya_model_layout_generated.h',
                MODEL / 'manifest.json'):
        if not (frozen / rel).exists():
            copy_one(rel, frozen, records)

    include_flags = ['-I' + str(frozen / 'include'),
                     '-I' + str(frozen / 'hls'),
                     '-I' + str(frozen / 'hls/platform'),
                     '-I' + str(frozen / MODEL)]
    host_binary = attempt / 'controller_transaction_adapter_test'
    host_command = ['g++', '-std=c++17', '-O2', '-Wall', '-Wextra',
                    '-Werror', '-Wno-aggressive-loop-optimizations',
                    '-Wno-unknown-pragmas', '-Wno-unused-parameter',
                    '-fno-fast-math', '-fno-associative-math',
                    '-ffp-contract=off', *include_flags,
                    '-isystem', str(VITIS_INCLUDE), str(frozen / test),
                    *[str(frozen / source) for source in sources],
                    '-o', str(host_binary)]
    host_build = run(host_command, frozen, attempt / 'host_build.log')
    host_run = ({'exit_code': None} if host_build['exit_code'] else
                run([str(host_binary)], frozen, attempt / 'host_run.log'))

    cfg = attempt / 'controller_transaction_adapter.cfg'
    cflags = ' '.join([*include_flags, '-std=c++17', '-fno-fast-math',
                       '-fno-associative-math', '-ffp-contract=off'])
    lines = ['part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
             'flow_target=vivado', f'syn.top={TOP}',
             'syn.compile.pipeline_loops=0',
             'syn.array_partition.throughput_driven=off',
             'syn.array_partition.complete_threshold=0']
    lines += [f'syn.file={(frozen / source).resolve()}' for source in sources]
    lines.append('syn.cflags=' + cflags)
    cfg.write_text('\n'.join(lines) + '\n')

    guard = frozen / MODULE / 'tb/production_guard.py'
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
               '--cwd', str(attempt), '--rss-gib', '24',
               '--timeout-seconds', '1800', '--semantic-stall-seconds', '120',
               '--artifact-progress-root', str(attempt / 'work'), '--',
               str(VITIS), '--compile', '--mode', 'hls', '--config', str(cfg),
               '--work_dir', str(attempt / 'work')]
    scope = (
        'free-running single-inflight command/provenance adapter static HLS '
        'generation: normalized 24-beat request and 16-beat completion plus '
        'direct ownership of compute/provenance/producer FIFO pairs (18 external '
        'signals), cancel scalar, no ap_ctrl_hs, and malformed/stale response rejection with normalized completion trust '
        'fields cleared; current host transaction '
        'regression is repeated from frozen sources. No graph sequencer, LayerNorm '
        'engine/shell connection, actual depth2 RTL backpressure, physical AXI '
        'fence, full request, joint resources, timing, or board claim.')
    manifest = {
        'schema': 'laya-controller-transaction-adapter-hls-input-v1',
        'scope': scope, 'top': TOP, 'files': records,
        'source_list': rec(frozen / SOURCE_LIST),
        'host_build': host_build, 'host_run': host_run,
        'derived_config': rec(cfg),
        'launcher': rec(attempt / 'launcher.json'),
        'tool': {'path': str(VITIS), 'version': subprocess.check_output(
            [str(VITIS), '--version'], text=True, stderr=subprocess.STDOUT)},
        'command': command,
        'profile': {'kind': 'static_hls_generation', 'maximum_seconds': 1800,
                    'maximum_rss_gib': 24, 'semantic_stall_seconds': 120,
                    'cpu_count': 4, 'nice': 19, 'io_class': 'idle',
                    'minimum_mem_available_gib': 192},
    }
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')

    tool = subprocess.run(command, cwd=ROOT)
    guard_path = attempt / 'guard/guard_result.json'
    guard_result = (json.loads(guard_path.read_text()) if guard_path.is_file()
                    else {'child_exit_code': None,
                          'trigger': 'guard_result_missing',
                          'runner_exit_code': tool.returncode})
    candidates = sorted((attempt / 'work').glob(f'**/syn/verilog/{TOP}.v'))
    ports = None
    if len(candidates) == 1:
        generated = attempt / candidates[0].name
        shutil.copyfile(candidates[0], generated)
        ports = port_evidence(generated)
    host_marker = (attempt / 'host_run.log').is_file() and \
        'FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_PASS' in \
        (attempt / 'host_run.log').read_text(errors='replace')
    status = 'FAIL'
    if (host_build['exit_code'] == 0 and host_run['exit_code'] == 0 and
            host_marker and tool.returncode == 0 and
            guard_result.get('child_exit_code') == 0 and
            guard_result.get('trigger') is None and ports and
            ports['fifo_signal_count'] == 24 and
            ports['external_fifo_signal_count'] == 18 and
            all(ports['controls'].values()) and
            not any(ports['forbidden_control'].values())):
        status = 'PASS_SCOPED_GENERATION'
    receipt = {
        'schema': 'laya-controller-transaction-adapter-hls-receipt-v1',
        'status': status, 'scope': scope, 'exit_code': tool.returncode,
        'guard_result': guard_result,
        'launcher': rec(attempt / 'launcher.json'),
        'input_manifest': rec(manifest_path),
        'derived_config': rec(cfg),
        'host_build': host_build, 'host_run': host_run,
        'port_evidence': ports,
        'generated_candidates': [str(path) for path in candidates],
        'partial_work_files': record_tree(attempt / 'work'),
        'guard_files': record_tree(attempt / 'guard'),
    }
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_HLS_' + status,
          flush=True)
    return 0 if status == 'PASS_SCOPED_GENERATION' else 1


if __name__ == '__main__':
    raise SystemExit(main())
