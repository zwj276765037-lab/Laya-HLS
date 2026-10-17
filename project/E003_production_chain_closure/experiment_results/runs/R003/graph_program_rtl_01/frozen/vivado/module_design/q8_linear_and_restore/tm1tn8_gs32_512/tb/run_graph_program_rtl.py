#!/usr/bin/env python3
"""Freeze the generated finite program and verify real depth2 result consumption."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import runpy
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL = Path('build/model-current-production-v2-20261011')
VIVADO = Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
XSIM = VIVADO.with_name('xsim')

def rec(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(path=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def copy(source, target, records):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    records.append(dict(original=rec(source), frozen=rec(target)))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--attempt', type=Path, required=True)
    ap.add_argument('--generation', type=Path, required=True)
    args = ap.parse_args(); attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False); generation = args.generation.resolve()
    helper_path = ROOT/MODULE/'tb/run_graph_program_hls.py'
    helper = runpy.run_path(str(helper_path)); launcher = helper['launcher_state']()
    (attempt/'launcher.json').write_text(json.dumps(launcher, indent=2)+'\n')
    if not launcher['pass']: raise RuntimeError('launcher/resource preflight failed')
    prior = json.loads((generation/'receipt.json').read_text())
    if prior['status'] != 'PASS_SCOPED_GENERATION': raise RuntimeError('generation did not pass')
    candidates = list((generation/'work').glob('**/syn/verilog/laya_graph_program_sequencer.v'))
    if len(candidates) != 1: raise RuntimeError('generated program is absent/ambiguous')
    ports = helper['port_evidence'](candidates[0])
    if ports['fifo_signal_count'] != 12 or any(ports['forbidden_control'].values()):
        raise RuntimeError('generated program interface mismatch')
    sources, forbidden = helper['source_list'](ROOT/'config/graph_program_sources.cmake')
    frozen = attempt/'frozen'; files = []
    fixture_source = Path('tests/graph_program_rtl_fixture.py')
    roots = sources + [Path('config/graph_program_sources.cmake'), fixture_source,
        MODEL/'laya_model_layout_generated.h', MODEL/'manifest.json',
        MODULE/'rtl/laya_private_fifo2_v1.sv',
        MODULE/'rtl/laya_control_consumption_gate_v1.sv',
        MODULE/'rtl/laya_graph_program_shell_v1.sv',
        MODULE/'tb/laya_graph_program_tb_v1.sv',
        MODULE/'tb/run_graph_program_rtl_v1.tcl',
        MODULE/'tb/run_layernorm_producer_portal_nowave_v1.tcl',
        MODULE/'tb/production_guard.py', Path('tools/hls_guard_helpers.py'),
        helper_path.relative_to(ROOT), Path(__file__).resolve().relative_to(ROOT)]
    helper['freeze_closure'](roots, frozen, files)
    for source in sorted(candidates[0].parent.iterdir()):
        if source.suffix in {'.v', '.dat'}:
            copy(source, frozen/'external/program_rtl'/source.name, files)
    for name in ['receipt.json', 'input_manifest.json',
                 'work/hls/syn/report/laya_graph_program_sequencer_csynth.rpt',
                 'work/hls/syn/report/csynth_design_size.rpt']:
        copy(generation/name, frozen/'external/generation'/name, files)
    copy(PROJECT/'results/production_hls_partition_contract_20261012.md',
         frozen/'external/production_hls_partition_contract_20261012.md', files)
    fixture = attempt/'fixture'
    command = [sys.executable, str(frozen/fixture_source), '--model-header',
               str(frozen/MODEL/'laya_model_layout_generated.h'), '--output', str(fixture)]
    fixture_result = helper['run'](command, ROOT, attempt/'fixture.log')
    if fixture_result['exit_code']: raise RuntimeError('independent fixture failed')
    guard = frozen/MODULE/'tb/production_guard.py'; work = attempt/'work'
    run_cwd = work/'vivado/graph_program_rtl.sim/sim_1/behav/xsim'
    snapshot = 'laya_graph_program_tb_v1_behav'
    commands = {'static': [sys.executable, str(guard), '--out', str(attempt/'guard_static'),
        '--cwd', str(ROOT), '--rss-gib', '24', '--timeout-seconds', '1800',
        '--semantic-stall-seconds', '120', '--', str(VIVADO), '-mode', 'batch',
        '-notrace', '-log', str(attempt/'vivado.log'), '-journal', str(attempt/'vivado.jou'),
        '-source', str(frozen/MODULE/'tb/run_graph_program_rtl_v1.tcl'),
        '-tclargs', str(work), str(frozen), str(fixture)]}
    for mode in ['pilot', 'full']:
        commands[mode] = [sys.executable, str(guard), '--out', str(attempt/('guard_'+mode)),
            '--cwd', str(run_cwd), '--rss-gib', '8', '--timeout-seconds',
            '120' if mode == 'pilot' else '3600', '--semantic-stall-seconds', '120',
            '--', str(XSIM), snapshot, '-tclbatch',
            str(frozen/MODULE/'tb/run_layernorm_producer_portal_nowave_v1.tcl'),
            '-testplusarg', 'FIXTURE='+str(fixture), '-log', str(attempt/(mode+'_xsim.log'))]
        if mode == 'pilot': commands[mode] += ['-testplusarg', 'PILOT']
    scope = ('actual generated finite program with four real depth2 FIFOs and a shell '
        'observing the LGR1 consumer four actual read handshakes; tail-two/tail-one '
        'backpressure with two successor words queued, persistent notification across '
        'multi-cycle HLS scheduling and clearing on the next command first real read; '
        'full run handles two controlled successful actions, one safe action error, '
        'and one zero-ordinal bad-command local rejection in one runtime, comparing '
        'all LGP1/LAX1/LAC1/LGR1 words to independent Python schema fixtures. '
        'No executor admission, physical source READY, real lifecycle/adapter/LayerNorm/hub '
        'or arithmetic, typed retirement, complete PC/13BO model, timing or board claim.')
    manifest = dict(schema='laya-graph-program-rtl-input-v1', scope=scope, files=files,
        launcher=rec(attempt/'launcher.json'), port_evidence=ports,
        fixture_run=fixture_result, fixture_files=[rec(p) for p in sorted(fixture.iterdir())],
        commands=commands, maximum_cycles=1000000,
        full_work=dict(commands=4, actions=3, command_beats=16, action_beats=24,
                       completion_beats=12, result_beats=16),
        cost_decision=dict(status='WAIT_PILOT', started=False,
                           full_reference_cycles='pilot_cycles * 4 * 1.5',
                           maximum_cycles=1000000, maximum_seconds=3600))
    mp = attempt/'input_manifest.json'; mp.write_text(json.dumps(manifest, indent=2)+'\n')
    receipt = dict(schema='laya-graph-program-rtl-receipt-v1', scope=scope,
                   input_manifest=rec(mp), status='RUNNING')
    rp = attempt/'receipt.json'
    for mode in ['static', 'pilot', 'full']:
        if mode == 'pilot':
            staged = []
            for p in sorted((frozen/'external/program_rtl').glob('*.dat')):
                target = run_cwd/p.name; shutil.copyfile(p, target)
                if rec(target)['sha256'] != rec(p)['sha256']: raise RuntimeError('DAT mismatch')
                staged.append(dict(source=rec(p), staged=rec(target)))
            receipt['rom_dat_staging'] = staged
        if mode == 'full':
            body = (attempt/'guard_pilot/driver.log').read_text(errors='replace')
            match = re.search(r'FULL_CURRENT_GRAPH_PROGRAM_RTL_PILOT_PASS cycles=(\d+)', body)
            cycles = int(match[1]) if match else 0
            seconds = receipt['pilot']['guard']['elapsed_seconds']
            rate = cycles/seconds if seconds > 0 else 0
            projected_cycles = cycles*4*1.5
            projected_seconds = projected_cycles/rate if rate > 0 else math.inf
            allow = cycles > 0 and math.isfinite(rate) and rate > 0 and seconds <= 120 and projected_cycles <= 1000000 and projected_seconds <= 3600
            decision = dict(status='RUN_BOUNDED_FULL' if allow else 'COST_STOP',
                started=allow, pilot_cycles=cycles, pilot_seconds=seconds,
                pilot_cycles_per_second=rate, projected_cycles=projected_cycles,
                projected_seconds=projected_seconds if math.isfinite(projected_seconds) else None,
                maximum_cycles=1000000, maximum_seconds=3600)
            manifest['cost_decision'] = decision
            mp.write_text(json.dumps(manifest, indent=2)+'\n')
            receipt['input_manifest'] = rec(mp); receipt['cost_decision'] = decision
            rp.write_text(json.dumps(receipt, indent=2)+'\n')
            if not allow:
                receipt['status']='COST_STOP'; rp.write_text(json.dumps(receipt,indent=2)+'\n')
                print('FULL_CURRENT_GRAPH_PROGRAM_RTL_COST_STOP',flush=True); return 0
        launched = subprocess.run(commands[mode], cwd=ROOT)
        gp = attempt/('guard_'+mode); g = json.loads((gp/'guard_result.json').read_text())
        log = gp/'driver.log'; body = log.read_text(errors='replace')
        marker = ('FULL_CURRENT_GRAPH_PROGRAM_RTL_STATIC_PASS' if mode == 'static'
                  else 'FULL_CURRENT_GRAPH_PROGRAM_RTL_PILOT_PASS' if mode == 'pilot'
                  else 'FULL_CURRENT_GRAPH_PROGRAM_RTL_PASS cycles=')
        okay = launched.returncode == 0 and g['child_exit_code'] == 0 and g['trigger'] is None and marker in body and 'Fatal:' not in body and 'ERROR:' not in body
        receipt[mode] = dict(status='PASS' if okay else 'FAIL', started=True,
            exit_code=launched.returncode, guard=g, driver_log=rec(log),
            marker=[line for line in body.splitlines() if marker in line])
        receipt['status'] = 'RUNNING' if okay else 'FAIL'
        rp.write_text(json.dumps(receipt, indent=2)+'\n')
        print('FULL_CURRENT_GRAPH_PROGRAM_RTL_'+mode.upper()+'_'+receipt[mode]['status'],flush=True)
        if not okay: return 1
    receipt['status'] = 'PASS_SCOPED_RTL_PROGRAM_CONSUMER'
    rp.write_text(json.dumps(receipt, indent=2)+'\n')
    return 0

if __name__ == '__main__': raise SystemExit(main())
