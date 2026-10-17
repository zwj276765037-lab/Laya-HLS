#!/usr/bin/env python3
"""Second bounded LQ1R repair of the measured sub-to-mul stage boundary."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys

import run_layernorm_producer_hls as base

ROOT = base.ROOT
SOURCE = ROOT.parents[2] / 'project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_producer_hls_01'
PARENT = ROOT.parents[2] / 'project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01'
CANDIDATE = ROOT / base.MODULE / 'tb/layernorm_compute_lq1r2.cpp'


def put(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--attempt', type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = base.launcher_state()
    put(attempt / 'launcher.json', launcher)
    if not launcher['pass']:
        raise RuntimeError('launcher/resource preflight failed')
    parent_receipt = json.loads((PARENT / 'receipt.json').read_text())
    if parent_receipt.get('status') != 'PASS_SCOPED_GENERATION':
        raise RuntimeError('parent LQ1R HLS generation is not scoped PASS')
    parent_manifest = json.loads((PARENT / 'input_manifest.json').read_text())
    for item in parent_manifest['frozen_files']:
        path = Path(item['path'])
        if base.record(path)['sha256'] != item['sha256']:
            raise RuntimeError('parent LQ1R frozen file changed: ' + str(path))
    frozen = attempt / 'frozen'
    shutil.copytree(PARENT / 'frozen', frozen)
    target = frozen / 'hls/operators/layernorm_compute.cpp'
    old = base.record(target)
    shutil.copyfile(CANDIDATE, target)
    expected = (PARENT / 'frozen/hls/operators/layernorm_compute.cpp').read_text()
    before = '#pragma HLS BIND_OP variable=delta op=fsub impl=fulldsp latency=4\n'
    after = '#pragma HLS BIND_OP variable=delta op=fsub impl=fulldsp latency=5\n'
    if expected.count(before) != 1 or target.read_text().count(after) != 1:
        raise RuntimeError('one expected F32 subtract binding not found')
    if target.read_text().replace(after, before, 1) != expected:
        raise RuntimeError('candidate differs beyond one subtract latency binding')
    fixture = SOURCE / 'fixture'
    include = [f'-I{(frozen / "include").resolve()}',
               f'-I{(frozen / "hls").resolve()}',
               f'-I{(frozen / "hls/platform").resolve()}',
               f'-I{(frozen / base.MODEL).resolve()}']
    csim_exe = attempt / 'layernorm_producer_csim'
    csim_cmd = ['g++', '-std=c++17', '-O2', '-Wno-comment',
                '-Wno-deprecated-copy', '-Wno-unknown-pragmas',
                *include, f'-I{base.VITIS_INCLUDE.resolve()}',
                str(frozen / base.TB),
                *[str(frozen / source) for source in base.SOURCES], '-lm',
                '-o', str(csim_exe)]
    csim_build = base.run_capture(csim_cmd, ROOT, attempt / 'csim_build.log')
    csim_run = ({'exit_code': None} if csim_build['exit_code'] else
                base.run_capture([str(csim_exe), str(fixture / 'source_rows16.f32.bin'),
                                  str(fixture / 'gold_rows16.f32.bin')],
                                 ROOT, attempt / 'csim_run.log'))
    cfg = attempt / 'layernorm_producer.cfg'
    cflags = ' '.join([*include, '-std=c++17', '-fno-fast-math',
                       '-fno-associative-math', '-ffp-contract=off'])
    lines = ['part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
             'flow_target=vivado', 'syn.top=laya_layernorm_producer_engine',
             'syn.compile.pipeline_loops=0',
             'syn.array_partition.throughput_driven=off',
             'syn.array_partition.complete_threshold=0']
    lines += [f'syn.file={(frozen / source).resolve()}' for source in base.SOURCES]
    lines.append('syn.cflags=' + cflags)
    cfg.write_text('\n'.join(lines) + '\n')
    guard = frozen / base.GUARD
    command = [sys.executable, str(guard), '--out', str(attempt / 'guard'),
               '--cwd', str(attempt), '--rss-gib', '24', '--timeout-seconds', '1800',
               '--semantic-stall-seconds', '120', '--artifact-progress-root',
               str(attempt / 'work'), '--', str(base.VITIS), '--compile',
               '--mode', 'hls', '--config', str(cfg), '--work_dir', str(attempt / 'work')]
    manifest = {'schema': 'laya-LQ1R-HLS-input-v2',
                'scope': 'AT017 frozen LQ1R LN with only final-loop F32 subtract binding latency 4 to 5',
                'parent_manifest': base.record(PARENT / 'input_manifest.json'),
                'parent_receipt': base.record(PARENT / 'receipt.json'),
                'original_source': old, 'candidate_source': base.record(CANDIDATE),
                'candidate_installed': base.record(target),
                'runner': base.record(Path(__file__)),
                'frozen_files': base.tree_records(frozen),
                'fixture_source': [base.record(fixture / 'source_rows16.f32.bin'),
                                   base.record(fixture / 'gold_rows16.f32.bin')],
                'csim_build': csim_build, 'csim_run': csim_run,
                'derived_config': base.record(cfg), 'command': command,
                'launcher': base.record(attempt / 'launcher.json')}
    put(attempt / 'input_manifest.json', manifest)
    if csim_build['exit_code'] or csim_run['exit_code']:
        put(attempt / 'receipt.json', {'status': 'FAIL_CSIM',
                                      'input_manifest': base.record(attempt / 'input_manifest.json'),
                                      'csim_build': csim_build, 'csim_run': csim_run})
        return 1
    result = subprocess.run(command, cwd=ROOT)
    guard_path = attempt / 'guard/guard_result.json'
    state = json.loads(guard_path.read_text()) if guard_path.is_file() else {'trigger': 'guard_result_missing'}
    candidates = sorted((attempt / 'work').glob('**/syn/verilog/laya_layernorm_producer_engine.v'))
    ports = base.port_evidence(candidates[0]) if len(candidates) == 1 else None
    passed = (result.returncode == 0 and state.get('child_exit_code') == 0 and
              state.get('trigger') is None and ports and
              ports['fifo_signal_count'] == 6 and all(ports['axi_complete'].values()))
    receipt = {'schema': 'laya-LQ1R-HLS-receipt-v2',
               'status': 'PASS_SCOPED_GENERATION' if passed else 'FAIL',
               'input_manifest': base.record(attempt / 'input_manifest.json'),
               'csim_build': csim_build, 'csim_run': csim_run,
               'guard': state, 'exit_code': result.returncode,
               'port_evidence': ports, 'generated_candidates': [str(p) for p in candidates],
               'generated_files': base.tree_records(attempt / 'work/hls/syn/verilog'),
               'report': base.record(attempt / 'work/reports/hls_compile.rpt') if
                         (attempt / 'work/reports/hls_compile.rpt').is_file() else None}
    put(attempt / 'receipt.json', receipt)
    print('LQ1R_HLS_' + receipt['status'], flush=True)
    return 0 if passed else 1

if __name__ == '__main__':
    raise SystemExit(main())
