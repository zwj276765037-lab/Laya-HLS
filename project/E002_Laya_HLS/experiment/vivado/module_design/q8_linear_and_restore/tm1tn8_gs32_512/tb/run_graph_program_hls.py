#!/usr/bin/env python3
"""Freeze, host-check, and synthesize the finite graph program sequencer."""
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
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
SOURCE_LIST = Path('config/graph_program_sources.cmake')
TOP = 'laya_graph_program_sequencer'
VITIS = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++')
VITIS_INCLUDE = VITIS.parents[1] / 'include'
MEMORY_LIMIT = 24 * 1024**3
DEFINES = [
    '-DLAYA_PARTITIONED_PRODUCTION_CALLER',
    '-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER',
    '-DLAYA_TRANSACTION_SEQUENCER_CODEC',
]
BO_BUNDLES = [
    'embedding', 'io', 'w_q0', 'w_q1', 'w_scale', 'aux', 'state0',
    'state1', 'qkv0', 'qkv1', 'ff0', 'ff1', 'att_out',
]


def rec(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return {'path': str(path), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


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
        'ionice': subprocess.run(
            ['ionice', '-p', str(os.getpid())], check=True, text=True,
            capture_output=True).stdout.strip(),
        'mem_available_kib': available_kib,
        'required_mem_available_kib': 192 * 1024 * 1024,
    }
    state['pass'] = (
        state['cpu_affinity'] == [0, 1, 2, 3] and state['nice'] == 19 and
        state['ionice'].startswith('idle') and available_kib is not None and
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


def source_list(path):
    sources = [Path(value) for value in re.findall(
        r'^\s*(hls/[^\s]+\.cpp)\s*$', path.read_text(), re.M)]
    if len(sources) != 6 or len(sources) != len(set(sources)):
        raise RuntimeError('invalid graph sequencer source list')
    forbidden_names = {
        'compute_portal_codec.cpp', 'generated_provenance_codec.cpp',
        'producer_engine_codec.cpp', 'compute_portal_hls.cpp',
        'generated_provenance_hls.cpp', 'producer_engine_hls.cpp',
        'controller_transaction_adapter.cpp', 'full_forward_controller.cpp',
        'task_lifecycle_executor.cpp',
    }
    forbidden = [str(source) for source in sources
                 if source.name in forbidden_names]
    if forbidden:
        raise RuntimeError('external codec/exchange or adapter entered sequencer')
    return sources, forbidden


def freeze_closure(roots, frozen, records):
    flags = [
        '-std=c++17', *DEFINES, '-I' + str(ROOT / 'include'),
        '-I' + str(ROOT / 'hls'), '-I' + str(ROOT / 'hls/platform'),
        '-I' + str(ROOT / MODEL), '-isystem', str(VITIS_INCLUDE),
    ]
    closure = set((ROOT / rel).resolve() for rel in roots)
    for rel in roots:
        if rel.suffix not in {'.cpp', '.cc', '.cxx', '.c'}:
            continue
        deps = subprocess.check_output(
            ['g++', *flags, '-MM', str(ROOT / rel)], cwd=ROOT, text=True, timeout=1800,
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
        result = subprocess.run(
            command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT,
            timeout=1800, preexec_fn=limit_child)
    return {'command': command, 'exit_code': result.returncode,
            'elapsed_seconds': time.monotonic() - started, 'log': rec(log)}


def port_evidence(path):
    text = path.read_text(errors='replace')
    header = re.search(r'\bmodule\s+' + re.escape(TOP) +
                       r'\s*\((.*?)\);', text, re.S)
    if header is None:
        raise RuntimeError('graph sequencer top module header is absent')
    top_ports = set(re.findall(r'\b[A-Za-z_]\w*\b', header.group(1)))
    expected = {}
    for name, outgoing in [('accepted_command', False), ('request_result', True),
                           ('action_request', True), ('action_completion', False)]:
        for suffix, direction, width in ([('din', 'output', 512), ('full_n', 'input', 1), ('write', 'output', 1)] if outgoing else [('dout', 'input', 512), ('empty_n', 'input', 1), ('read', 'output', 1)]):
            port = name + '_' + suffix
            pattern = r'\b' + direction + r'\s+(?:wire\s+)?' + (r'\[511:0\]\s+' if width == 512 else '') + re.escape(port) + r'\b'
            expected[port] = port in top_ports and bool(re.search(pattern, text))
    forbidden = {name: name in top_ports for name in ('ap_start', 'ap_done', 'ap_idle', 'ap_ready')}
    return {'generated': rec(path), 'fifo_matches': expected,
            'fifo_signal_count': sum(expected.values()),
            'cancel_present': 'cancel' in top_ports,
            'result_consumed_present': 'result_consumed' in top_ports,
            'clock_present': 'ap_clk' in top_ports,
            'reset_present': 'ap_rst' in top_ports,
            'forbidden_control': forbidden,
            'declared_top_ports': sorted(top_ports)}


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

    sources, forbidden = source_list(ROOT / SOURCE_LIST)
    test = Path('tests/graph_program_top_test.cpp')
    frozen = attempt / 'frozen'
    records = []
    roots = sources + [
        test, SOURCE_LIST, Path('config/production_hls_partitions.json'),
        Path('config/full_module_registry.json'),
        MODULE / 'rtl/laya_graph_action_layout_v1.sv',
        MODULE / 'rtl/laya_graph_program_layout_v1.sv',
        MODULE / 'rtl/laya_control_consumption_gate_v1.sv',
        MODULE / 'rtl/laya_graph_program_shell_v1.sv',
        Path('tests/graph_program_protocol_oracle.py'),
        MODULE / 'tb/production_guard.py',
        Path('tools/hls_guard_helpers.py'),
        Path(__file__).resolve().relative_to(ROOT),
        MODEL / 'laya_model_layout_generated.h', MODEL / 'manifest.json',
    ]
    freeze_closure(roots, frozen, records)
    contract = PROJECT / 'results/production_hls_partition_contract_20261012.md'
    contract_copy = frozen / 'external/production_hls_partition_contract_20261012.md'
    contract_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(contract, contract_copy)

    include_flags = [
        '-I' + str(frozen / 'include'), '-I' + str(frozen / 'hls'),
        '-I' + str(frozen / 'hls/platform'), '-I' + str(frozen / MODEL),
    ]
    host_binary = attempt / 'graph_sequencer_host_test'
    host_command = [
        'g++', '-std=c++17', '-O1', '-Wall', '-Wextra', '-Werror',
        '-Wno-unknown-pragmas', '-Wno-unused-parameter',
        '-Wno-aggressive-loop-optimizations', '-fno-fast-math',
        '-fno-associative-math', '-ffp-contract=off', *DEFINES,
        *include_flags, '-isystem', str(VITIS_INCLUDE), str(frozen / test),
        *[str(frozen / source) for source in sources], '-o', str(host_binary),
    ]
    oracle_path = attempt / 'graph_program_oracle.bin'
    oracle_run = run([sys.executable, str(frozen / 'tests/graph_program_protocol_oracle.py'), '--output', str(oracle_path)], frozen, attempt / 'oracle.log')
    host_build = run(host_command, frozen, attempt / 'host_build.log')
    host_run = ({'exit_code': None} if host_build['exit_code'] else
                run([str(host_binary), str(oracle_path)], frozen, attempt / 'host_run.log'))

    cfg = attempt / 'graph_sequencer.cfg'
    cflags = ' '.join([
        *DEFINES, *include_flags, '-std=c++17', '-fno-fast-math',
        '-fno-associative-math', '-ffp-contract=off',
    ])
    lines = [
        'part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
        'flow_target=vivado', f'syn.top={TOP}',
        'syn.compile.pipeline_loops=0',
        'syn.array_partition.throughput_driven=off',
        'syn.array_partition.complete_threshold=0',
    ]
    lines += [f'syn.file={(frozen / source).resolve()}' for source in sources]
    lines.append('syn.cflags=' + cflags)
    cfg.write_text('\n'.join(lines) + '\n')

    guard = frozen / MODULE / 'tb/production_guard.py'
    command = [
        sys.executable, str(guard), '--out', str(attempt / 'guard'),
        '--cwd', str(attempt), '--rss-gib', '24',
        '--timeout-seconds', '1800', '--semantic-stall-seconds', '120',
        '--artifact-progress-root', str(attempt / 'work'), '--',
        str(VITIS), '--compile', '--mode', 'hls', '--config', str(cfg),
        '--work_dir', str(attempt / 'work'),
    ]
    scope = ('finite NORM_LAYER1_ATTN graph program static HLS generation; six-source '
             'closure excludes executor, adapter, full controller, service codecs and arithmetic. '
             'LGP1/LGR1 4/4 and LAX1/LAC1 8/4 beat FIFO pair ports, cancel and persistent '
             'consumer notification input; bounded host oracle and current top regressions. '
             'No executor/shell admission, actual depth2 RTL, production LayerNorm/hub, '
             'complete graph or 13BO request, joint resources, timing or board claim.')
    manifest = {
        'schema': 'laya-graph-program-hls-input-v1',
        'scope': scope, 'top': TOP, 'files': records,
        'source_list': rec(frozen / SOURCE_LIST),
        'contract': {'original': rec(contract), 'frozen': rec(contract_copy)},
        'oracle_run': oracle_run, 'oracle': rec(oracle_path),
        'host_build': host_build, 'host_run': host_run,
        'derived_config': rec(cfg),
        'launcher': rec(attempt / 'launcher.json'),
        'tool': {'path': str(VITIS), 'version': subprocess.check_output(
            [str(VITIS), '--version'], text=True, stderr=subprocess.STDOUT)},
        'source_count': len(sources), 'forbidden_sources': forbidden,
        'command': command,
        'profile': {'kind': 'static_hls_generation',
                    'maximum_seconds': 1800, 'maximum_rss_gib': 24,
                    'semantic_stall_seconds': 120, 'cpu_count': 4,
                    'nice': 19, 'io_class': 'idle',
                    'minimum_mem_available_gib': 192},
    }
    manifest_path = attempt / 'input_manifest.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')

    tool = subprocess.run(command, cwd=ROOT)
    guard_path = attempt / 'guard/guard_result.json'
    guard_result = (json.loads(guard_path.read_text())
                    if guard_path.is_file() else
                    {'child_exit_code': None, 'trigger': 'guard_result_missing',
                     'runner_exit_code': tool.returncode})
    candidates = sorted((attempt / 'work').glob(
        f'**/syn/verilog/{TOP}.v'))
    ports = None
    if len(candidates) == 1:
        generated = attempt / candidates[0].name
        shutil.copyfile(candidates[0], generated)
        ports = port_evidence(generated)
    host_marker = (
        (attempt / 'host_run.log').is_file() and
        'FULL_CURRENT_GRAPH_PROGRAM_TOP_PASS' in
        (attempt / 'host_run.log').read_text(errors='replace'))
    status = 'FAIL'
    if (oracle_run['exit_code'] == 0 and host_build['exit_code'] == 0 and host_run['exit_code'] == 0 and
            host_marker and tool.returncode == 0 and
            guard_result.get('child_exit_code') == 0 and
            guard_result.get('trigger') is None and ports and
            ports['fifo_signal_count'] == 12 and
            ports['cancel_present'] and ports['result_consumed_present'] and
            ports['clock_present'] and ports['reset_present'] and
            not any(ports['forbidden_control'].values())):
        status = 'PASS_SCOPED_GENERATION'
    receipt = {
        'schema': 'laya-graph-program-hls-receipt-v1',
        'status': status, 'scope': scope, 'exit_code': tool.returncode,
        'guard_result': guard_result,
        'launcher': rec(attempt / 'launcher.json'),
        'input_manifest': rec(manifest_path),
        'derived_config': rec(cfg),
        'oracle_run': oracle_run, 'oracle': rec(oracle_path),
        'host_build': host_build, 'host_run': host_run,
        'port_evidence': ports,
        'generated_candidates': [str(path) for path in candidates],
        'partial_work_files': record_tree(attempt / 'work'),
        'guard_files': record_tree(attempt / 'guard'),
    }
    (attempt / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('FULL_CURRENT_GRAPH_PROGRAM_HLS_' + status, flush=True)
    return 0 if status == 'PASS_SCOPED_GENERATION' else 1


if __name__ == '__main__':
    raise SystemExit(main())
