#!/usr/bin/env python3
"""KB0: frozen resident Down numerical regression with observed latency counters.

The caller owns the single heavy-tool slot. --prepare-only executes no AMD tool.
Each invocation requires a new evidence directory, including under an existing AT.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

E = Path(__file__).resolve().parents[5]
P = E.parents[2]
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
BASELINE = P / 'project/E003_production_chain_closure/experiment_results/runs/R003/resident_regression_02'
RESULT_ROOT = P / 'project/E005_full_request_performance/experiment_results/runs/R001'
MANIFEST_SHA = '2a8d23b82ce961f0b878b47b88823a3578d4afe43eefec468410b3db7ab6697d'
RECEIPT_SHA = '8c09b951475a542f96789d3068282c77e7713c12781ae04e356af3cd6fa72f95'
RAW_SHA = '0afa90cc4808ee83339efd7eaa78b03e3fcb2ea1bfdb2ec1c00dd0db87c8bbf4'
OLD_TB = MODULE / 'tb/tm4tn8_matrix_resident_tb_v2.sv'
NEW_TB = E / MODULE / 'tb/tm4tn8_down_measurement_tb_v1.sv'
SCOPE = ('KB0 resident Down, four distinct prequantized A rows, K2624/N1024, '
         'bias kind0, initial reset, native FP, fullA/dualW, 4096 F32 outputs '
         'and actual 512 AW/W/B plus one consumed done response. '
         'Seamless Wi/G/quant, production13BO/full request, steady state and board timing are NOT_RUN.')
STATE_NAMES = ['IDLE', 'ACQUIRE_A', 'LEASE_W', 'SETUP', 'READ_A', 'WAIT_A',
               'STREAM', 'DRAIN', 'FLUSH', 'RELEASE_A', 'RELEASE_W', 'OWNER_RETIRE', 'REPORT']


def rec(path):
    path = path.resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return dict(path=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def checked(path, expected):
    actual = rec(path)
    if any(actual[key] != expected[key] for key in ('bytes', 'sha256')):
        raise RuntimeError('input identity mismatch: ' + str(path))
    return actual


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2) + '\n')


def fields(line, marker):
    body = line.split(marker, 1)[1].strip()
    result = {}
    for token in body.split():
        key, value = token.split('=', 1)
        result[key] = int(value) if re.fullmatch(r'-?\d+', value) else value
    return result


def measurements(raw, mode, expected_output_beats):
    result = {}
    for name in ('BOUNDARIES', 'STATES', 'OVERLAP', 'FRONT', 'LOAD', 'OUTPUT'):
        marker = 'DOWN_MEASURE_' + name
        lines = [line for line in raw.splitlines() if line.startswith(marker + ' ')]
        if len(lines) != 1:
            raise RuntimeError('missing/duplicate measurement marker: ' + marker)
        row = fields(lines[0], marker)
        if row['mode'] != mode:
            raise RuntimeError('measurement mode mismatch')
        result[name.lower()] = row
    b, s, o = (result[key] for key in ('boundaries', 'states', 'output'))
    state_total = sum(s['s' + str(index)] for index in range(13))
    if s['exclusive'] != 1 or state_total != s['cycles']:
        raise RuntimeError('exclusive state accounting failed')
    result['state_cycles_exclusive'] = {name: s['s' + str(index)] for index, name in enumerate(STATE_NAMES)}
    result['latency_cycles'] = dict(
        TB_from_cycle_zero_to_finish=b['finish'],
        reset_and_idle_to_A_accept=b['A_fill_accept'],
        A_fill_accept_to_publish=b['A_publish_post_NBA'] - b['A_fill_accept'],
        gap_A_publish_to_W_accept=b['W_load_accept'] - b['A_publish_post_NBA'],
        W_load_accept_to_publish=b['W_publish_post_NBA'] - b['W_load_accept'],
        gap_W_publish_to_cfg=b['cfg_accept'] - b['W_publish_post_NBA'])
    result['definitions'] = dict(
        edge_sample='pre-NBA posedge, monitor cycle increments before sampling',
        publication_sample='post-NBA at original A/W publication assertions',
        exclusive_states='[cfg accept edge, first sampled done-valid edge); pilot is unfinished prefix',
        overlapping='overlap/front/load/output conditions are non-exclusive; do not sum them as latency',
        TB_B_delay_decrements='original held_b count: every actual negedge decrement of configured 17+(beat%3) delay; overlaps state/tx/PS stalls',
        TB_periodic_AW_W_gate='valid&&!ready while TB capture is empty; exact original periodic ready policy',
        configured_front_not_done='activity span, not proof every arithmetic lane is busy',
        post_done='seven original hold-check cycles, real ready/consume edge, then deassertion check')
    if mode == 'full':
        if state_total != b['first_done_valid'] - b['cfg_accept']:
            raise RuntimeError('state bins do not equal cfg-to-done latency')
        expected = dict(expected_output_beats=expected_output_beats,
                        actual_AW=expected_output_beats, actual_W=expected_output_beats, actual_B=expected_output_beats,
                        useful_strobe_bytes=16384, physical_W_bytes=expected_output_beats * 64,
                        actual_done_consumes=1)
        if any(o[key] != value for key, value in expected.items()):
            raise RuntimeError('actual output/consume coverage mismatch')
        result['latency_cycles'].update(
            cfg_to_first_done_valid=b['first_done_valid'] - b['cfg_accept'],
            cfg_to_actual_done_consume=b['actual_done_consume'] - b['cfg_accept'],
            first_done_valid_to_consume=b['actual_done_consume'] - b['first_done_valid'],
            last_PS_to_last_B=b['last_B'] - b['last_PS'],
            last_B_to_first_done_valid=b['first_done_valid'] - b['last_B'])
        result['strobe_utilization'] = o['useful_strobe_bytes'] / o['physical_W_bytes']
    else:
        if b['first_done_valid'] != -1 or o['actual_done_consumes'] != 0:
            raise RuntimeError('pilot incorrectly claims completion')
        result['latency_cycles']['cfg_to_pilot_finish_partial'] = b['finish'] - b['cfg_accept']
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', required=True, type=Path, help='new evidence directory, not necessarily AT root')
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--label', choices=('KB0', 'KB1', 'KB2'), default='KB0')
    parser.add_argument('--writer-source', type=Path, help='candidate source defining the same writer module')
    parser.add_argument('--expected-output-beats', type=int, choices=(512, 256), default=512)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    if not attempt.is_relative_to(RESULT_ROOT.resolve()):
        parser.error('evidence must be under E005/R001')
    if args.label == 'KB0' and (args.writer_source is not None or args.expected_output_beats != 512):
        parser.error('KB0 must retain the frozen writer and 512 actual beats')
    if args.label != 'KB0' and args.writer_source is None:
        parser.error('candidate label requires --writer-source')
    candidate = args.writer_source.resolve() if args.writer_source else None
    if candidate is not None and not candidate.is_relative_to(E):
        parser.error('candidate implementation must be under E002/experiment')
    candidate_identity = rec(candidate) if candidate else None
    writer_rel = MODULE / 'rtl/tm4tn8_axi512_writer_v1.sv'
    scope = SCOPE.replace('KB0', args.label).replace('512 AW/W/B', str(args.expected_output_beats) + ' AW/W/B')
    baseline_manifest = rec(BASELINE / 'input_manifest.json')
    baseline_receipt = rec(BASELINE / 'receipt.json')
    baseline_raw = rec(BASELINE / 'work/vivado/tm4_matrix_resident_tb_v2.sim/sim_1/behav/xsim/simulate.log')
    if [item['sha256'] for item in (baseline_manifest, baseline_receipt, baseline_raw)] != [MANIFEST_SHA, RECEIPT_SHA, RAW_SHA]:
        raise RuntimeError('trusted baseline evidence changed')
    previous = json.loads(Path(baseline_manifest['path']).read_text())
    prior_receipt = json.loads(Path(baseline_receipt['path']).read_text())
    if len(previous['files']) != 26 or len(previous['fixture_files']) != 12:
        raise RuntimeError('baseline source/fixture closure count mismatch')
    if any(prior_receipt[mode]['status'] != 'PASS' for mode in ('static', 'pilot', 'full')):
        raise RuntimeError('baseline phase was not PASS')
    # Verify everything before creating the new evidence directory.
    source_inputs = [(Path(row['frozen']['path']), checked(Path(row['frozen']['path']), row['frozen']))
                     for row in previous['files']]
    fixture_inputs = [(Path(row['current']['path']), checked(Path(row['current']['path']), row['current']))
                      for row in previous['fixture_files']]
    tool = Path(previous['tool']['path'])
    tool_identity = checked(tool, previous['tool'])
    guard = E / MODULE / 'tb/production_guard.py'
    helper = E / 'tools/hls_guard_helpers.py'
    derived_identity = rec(NEW_TB)
    attempt.mkdir(parents=True, exist_ok=False)
    frozen, work = attempt / 'frozen', attempt / 'work'
    inputs = dict(label=args.label, scope=scope, files=[], fixture_files=[],
                  expected_output_beats=args.expected_output_beats, candidate_writer=candidate_identity,
                  baseline=dict(manifest=baseline_manifest, receipt=baseline_receipt, raw=baseline_raw,
                                native_ip=prior_receipt['native_ip'],
                                inherited_full_cycles=48862,
                                inherited_boundary='old TB end after held response; no done consume'),
                  runner=rec(Path(__file__)), tool=tool_identity,
                  baseline_live_sources_used=False,
                  derived_TB=dict(original_frozen=next(row['frozen'] for row in previous['files']
                                 if Path(row['frozen']['path']).relative_to(BASELINE / 'frozen') == OLD_TB),
                                  derivative=derived_identity,
                                  changes='observation-only counters/report and real done consumption after original seven hold cycles'))
    for origin, identity in source_inputs:
        rel = origin.relative_to(BASELINE / 'frozen')
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        selected = NEW_TB if rel == OLD_TB else (candidate if candidate and rel == writer_rel else origin)
        expected = derived_identity if rel == OLD_TB else (candidate_identity if candidate and rel == writer_rel else identity)
        shutil.copyfile(selected, target)
        inputs['files'].append(dict(baseline=identity, selected=rec(selected), frozen=checked(target, expected), derived=selected != origin))
    for origin, rel, key in [(guard, MODULE / 'tb/production_guard.py', 'guard'),
                             (helper, Path('tools/hls_guard_helpers.py'), 'guard_helpers')]:
        target = frozen / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        identity = rec(origin)
        shutil.copyfile(origin, target)
        inputs[key] = dict(original=identity, frozen=checked(target, identity))
    fixture_dirs = [work / 'fixtures' / name for name in ('a', 'w', 'streams')]
    names = [set(['q.mem', 'scale.mem', 'output.mem']),
             set(['model_identity.hex', 'expected_aux_header.hex', 'aux_header.hex', 'down_config.hex',
                  'down_q0.hex', 'down_q1.hex', 'down_scale.hex']), set(['w8.mem', 'ps.mem'])]
    for origin, identity in fixture_inputs:
        groups = [index for index, group in enumerate(names) if origin.name in group]
        if len(groups) != 1:
            raise RuntimeError('fixture mapping ambiguity')
        target = fixture_dirs[groups[0]] / origin.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(origin, target)
        inputs['fixture_files'].append(dict(baseline=identity, frozen=checked(target, identity)))
    frozen_guard = Path(inputs['guard']['frozen']['path'])
    inputs['limits'] = dict(cpu_ids=[0, 1, 2, 3], nice=19, idle_io=True, minimum_available_GiB=192,
                           static_RSS_GiB=24, static_seconds=1800, RTL_RSS_GiB=8,
                           pilot_seconds=120, full_seconds=3600, semantic_stall_seconds=120,
                           cycle_cap=40000000, candidate_DUTs=int(candidate is not None))
    inputs['cost_basis'] = dict(prior_static_seconds=prior_receipt['static']['guard']['elapsed_seconds'],
                               prior_pilot_seconds=prior_receipt['pilot']['guard']['elapsed_seconds'],
                               prior_full_seconds=prior_receipt['full']['guard']['elapsed_seconds'],
                               conservative_full_estimate_seconds=633,
                               prerequisite='fresh static and bounded pilot PASS')
    static_origin = frozen / MODULE / 'tb/run_tm4_matrix_resident_tb_static_v2.tcl'
    static_entry = attempt / 'entry_static.tcl'
    original_tcl = static_origin.read_text()
    anchor = '-testplusarg STREAMS=$streams"'
    if original_tcl.count(anchor) != 1:
        raise RuntimeError('static Tcl plusarg derivation mismatch')
    static_entry.write_text(original_tcl.replace(anchor, '-testplusarg STREAMS=$streams -testplusarg EXPECTED_OUTPUT_BEATS=' + str(args.expected_output_beats) + '"'))
    inputs['static_entry'] = dict(baseline_frozen=rec(static_origin), derived=rec(static_entry),
                                  change='declared physical beat coverage plusarg only')
    for mode, rss, seconds in [('static', 24, 1800), ('pilot', 8, 120), ('full', 8, 3600)]:
        script = 'run_tm4_matrix_resident_tb_static_v2.tcl' if mode == 'static' else 'run_tm4_matrix_resident_tb_rtl_v2.tcl'
        tclargs = [str(work), str(frozen), *map(str, fixture_dirs)] if mode == 'static' else [str(work), mode]
        inputs[mode + '_command'] = [sys.executable, str(frozen_guard), '--out', str(attempt / ('guard_' + mode)),
            '--cwd', str(E), '--rss-gib', str(rss), '--timeout-seconds', str(seconds),
            '--semantic-stall-seconds', '120', '--', str(tool), '-mode', 'batch', '-notrace',
            '-log', str(attempt / (mode + '.log')), '-journal', str(attempt / (mode + '.jou')),
            '-source', str(static_entry if mode == 'static' else frozen / MODULE / 'tb' / script), '-tclargs', *tclargs]
    write_json(attempt / 'input_manifest.json', inputs)
    receipt = dict(label=args.label, status='NOT_RUN', scope=scope,
                   input_manifest=rec(attempt / 'input_manifest.json'), phases={})
    write_json(attempt / 'receipt.json', receipt)
    if args.prepare_only:
        print('DOWN_MEASUREMENT_PREPARED_NOT_RUN ' + str(attempt), flush=True)
        return
    if not {0, 1, 2, 3}.issubset(os.sched_getaffinity(0)):
        raise RuntimeError('CPU0-3 must be available to the runner')
    os.sched_setaffinity(0, {0, 1, 2, 3})
    immutable = [row['frozen'] for row in inputs['files'] + inputs['fixture_files']]
    immutable += [inputs[key]['frozen'] for key in ('guard', 'guard_helpers')]
    immutable += [inputs['runner'], inputs['tool'], inputs['static_entry']['derived']]
    for mode in ('static', 'pilot', 'full'):
        if mode == 'full' and receipt['full_cost_estimate_before_launch']['estimate_seconds'] > 3600:
            receipt['phases']['full'] = dict(status='COST_STOP', not_launched=True,
                reason='actual-pilot conservative full estimate exceeds unchanged 3600s cap')
            receipt['status'] = 'COST_STOP'
            write_json(attempt / 'receipt.json', receipt)
            print('DOWN_MEASUREMENT_FULL_COST_STOP_NOT_LAUNCHED', flush=True)
            sys.exit(1)
        for identity in immutable:
            checked(Path(identity['path']), identity)
        run = subprocess.run(inputs[mode + '_command'], cwd=E)
        driver = attempt / ('guard_' + mode) / 'driver.log'
        guard_result = driver.parent / 'guard_result.json'
        state = json.loads(guard_result.read_text()) if guard_result.exists() else dict(child_exit_code=None, trigger='missing_guard_result')
        text = driver.read_text(errors='replace') if driver.exists() else ''
        marker = 'TM4_MATRIX_RESIDENT_TB_STATIC_PASS' if mode == 'static' else 'TM4_MATRIX_RESIDENT_' + mode.upper() + '_PASS'
        markers = [line for line in text.splitlines() if line.startswith(marker)]
        passed = run.returncode == 0 and state['child_exit_code'] == 0 and state['trigger'] is None and len(markers) == 1
        phase = dict(status='PASS' if passed else ('COST_STOP' if state.get('trigger') else 'FAIL'),
                     guard=state, marker=markers, driver_log=rec(driver) if driver.exists() else None)
        if passed:
            try:
                for identity in immutable:
                    checked(Path(identity['path']), identity)
                if mode != 'static':
                    raw_path = work / 'vivado/tm4_matrix_resident_tb_v2.sim/sim_1/behav/xsim/simulate.log'
                    saved_raw = attempt / ('raw_' + mode + '.log')
                    shutil.copyfile(raw_path, saved_raw)
                    raw_text = saved_raw.read_text(errors='replace')
                    if re.search(r'(^|\n)(Fatal:|ERROR:)', raw_text):
                        raise RuntimeError('simulation has fatal/error')
                    measure = measurements(raw_text, mode, args.expected_output_beats)
                    write_json(attempt / ('measurement_' + mode + '.json'), measure)
                    phase.update(raw_log=rec(saved_raw), measurement=rec(attempt / ('measurement_' + mode + '.json')))
                    if mode == 'full':
                        gold = fields(markers[0], marker)
                        expected = dict(rows=4, K=2624, N=1024, real_stripes=10496, PS_lane_groups=335872,
                                        final_packets=512, real_output_words=4096, actual_AW=args.expected_output_beats,
                                        actual_W=args.expected_output_beats, actual_B=args.expected_output_beats)
                        if any(gold[key] != value for key, value in expected.items()):
                            raise RuntimeError('inherited numeric/output marker coverage mismatch')
            except Exception as error:
                passed = False
                phase.update(status='FAIL', validation_error=str(error))
        receipt['phases'][mode] = phase
        if passed and mode == 'pilot':
            prior_pilot = prior_receipt['pilot']['guard']['elapsed_seconds']
            prior_full = prior_receipt['full']['guard']['elapsed_seconds']
            receipt['full_cost_estimate_before_launch'] = dict(
                new_pilot_actual_seconds=state['elapsed_seconds'],
                same_frozen_prior_full_to_pilot_ratio=prior_full / prior_pilot,
                conservative_factor=1.5,
                estimate_seconds=state['elapsed_seconds'] * prior_full / prior_pilot * 1.5,
                method='same frozen DUT old full/pilot wall ratio times new actual pilot; no total-cycle linear extrapolation',
                final_output_and_numeric_compare_drain='included in old full ratio; new last-PS/last-B/done timestamps measured only by full',
                full_cap_seconds=3600)
        receipt['native_ip'] = [rec(path) for path in sorted(work.rglob('*.xci'))]
        receipt['status'] = 'PASS_SCOPED_' + args.label + '_DOWN_MEASUREMENT' if passed and mode == 'full' else ('IN_PROGRESS' if passed else phase['status'])
        write_json(attempt / 'receipt.json', receipt)
        print('DOWN_MEASUREMENT_' + mode.upper() + '_' + phase['status'], flush=True)
        if not passed:
            sys.exit(1)


if __name__ == '__main__':
    main()
