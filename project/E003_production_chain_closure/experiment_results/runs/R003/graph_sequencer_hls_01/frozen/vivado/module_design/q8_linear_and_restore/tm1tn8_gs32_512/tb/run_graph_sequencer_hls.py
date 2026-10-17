#!/usr/bin/env python3
"""Freeze, host-check, and synthesize the normalized graph sequencer."""
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
SOURCE_LIST = Path('config/graph_sequencer_sources.cmake')
TOP = 'laya_typed_q8_forward_graph_sequencer'
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
    if len(sources) != 20 or len(sources) != len(set(sources)):
        raise RuntimeError('invalid graph sequencer source list')
    forbidden_names = {
        'compute_portal_codec.cpp', 'generated_provenance_codec.cpp',
        'producer_engine_codec.cpp', 'compute_portal_hls.cpp',
        'generated_provenance_hls.cpp', 'producer_engine_hls.cpp',
        'controller_transaction_adapter.cpp',
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
    patterns = {
        'transaction_request_din':
            r'output\s+(?:wire\s+)?\[511:0\]\s+transaction_request_din',
        'transaction_request_full_n':
            r'input\s+(?:wire\s+)?transaction_request_full_n',
        'transaction_request_write':
            r'output\s+(?:wire\s+)?transaction_request_write',
        'transaction_completion_dout':
            r'input\s+(?:wire\s+)?\[511:0\]\s+transaction_completion_dout',
        'transaction_completion_empty_n':
            r'input\s+(?:wire\s+)?transaction_completion_empty_n',
        'transaction_completion_read':
            r'output\s+(?:wire\s+)?transaction_completion_read',
    }
    fifo = {name: name in top_ports and bool(re.search(pattern, text))
            for name, pattern in patterns.items()}
    bundles = {
        name: any(port.startswith('m_axi_' + name + '_')
                  for port in top_ports)
        for name in BO_BUNDLES
    }
    control_ports = sorted(
        port for port in top_ports if port.startswith('s_axi_control_'))
    resets = {name: name in top_ports for name in ('ap_rst', 'ap_rst_n')}
    return {
        'generated': rec(path),
        'fifo_matches': fifo,
        'fifo_signal_count': sum(fifo.values()),
        'm_axi_bundle_matches': bundles,
        'm_axi_bundle_count': sum(bundles.values()),
        's_axi_control_port_count': len(control_ports),
        's_axi_control_ports': control_ports,
        'clock_present': 'ap_clk' in top_ports,
        'reset_ports': resets,
        'declared_top_ports': sorted(top_ports),
    }


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
    test = Path('tests/controller_transaction_dispatch_test.cpp')
    frozen = attempt / 'frozen'
    records = []
    roots = sources + [
        test, SOURCE_LIST, Path('config/production_hls_partitions.json'),
        Path('config/full_module_registry.json'),
        MODULE / 'rtl/laya_controller_transaction_layout_v1.sv',
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
    host_build = run(host_command, frozen, attempt / 'host_build.log')
    host_run = ({'exit_code': None} if host_build['exit_code'] else
                run([str(host_binary)], frozen, attempt / 'host_run.log'))

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
    scope = (
        'graph sequencer static HLS generation with the full current graph and '
        'identity/reservation/owner/retirement control closure, original 13 BO '
        'masters and control interface, and only the normalized 24-beat request/'
        '16-beat completion FIFO pair. External compute/provenance/producer '
        'codecs, exchanges, adapter and arithmetic implementations are excluded. '
        'No adapter/engine/hub RTL connection, complete hardware request, joint '
        'resources, physical timing, performance, or board claim.')
    manifest = {
        'schema': 'laya-graph-sequencer-hls-input-v1',
        'scope': scope, 'top': TOP, 'files': records,
        'source_list': rec(frozen / SOURCE_LIST),
        'contract': {'original': rec(contract), 'frozen': rec(contract_copy)},
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
        'FULL_CURRENT_CONTROLLER_TRANSACTION_DISPATCH_PASS' in
        (attempt / 'host_run.log').read_text(errors='replace'))
    status = 'FAIL'
    if (host_build['exit_code'] == 0 and host_run['exit_code'] == 0 and
            host_marker and tool.returncode == 0 and
            guard_result.get('child_exit_code') == 0 and
            guard_result.get('trigger') is None and ports and
            ports['fifo_signal_count'] == 6 and
            ports['m_axi_bundle_count'] == 13 and
            ports['s_axi_control_port_count'] > 0 and
            ports['clock_present'] and any(ports['reset_ports'].values())):
        status = 'PASS_SCOPED_GENERATION'
    receipt = {
        'schema': 'laya-graph-sequencer-hls-receipt-v1',
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
    print('FULL_CURRENT_GRAPH_SEQUENCER_HLS_' + status, flush=True)
    return 0 if status == 'PASS_SCOPED_GENERATION' else 1


if __name__ == '__main__':
    raise SystemExit(main())
