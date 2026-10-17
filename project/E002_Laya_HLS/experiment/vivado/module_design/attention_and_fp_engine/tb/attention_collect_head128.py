#!/usr/bin/env python3
"""Collect a terminated full-head replay without upgrading partial evidence."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('attempt', type=Path)
args = parser.parse_args()
attempt = args.attempt.resolve()
manifest_path = attempt / 'input_manifest.json'
manifest = json.loads(manifest_path.read_text())
assert manifest['rows'] == 128 and manifest['protocol'] == 1
guard = json.loads((attempt / 'guard/guard_result.json').read_text())
log_path = attempt / 'work/simulate.log'
log = log_path.read_text(errors='replace') if log_path.exists() else ''
identity_errors = [item['path'] for item in manifest['inputs']
                   if sha256(Path(item['path'])) != item['sha256']]
fixture = Path(next(arg.split('=', 1)[1] for arg in manifest['command']
                    if arg.startswith('FIXTURE=')))
fixture_manifest_path = fixture / 'manifest.json'
fixture_manifest = json.loads(fixture_manifest_path.read_text())
for name, item in fixture_manifest['products'].items():
    if sha256(fixture / name) != item['sha256']:
        identity_errors.append(str(fixture / name))
pass_match = re.search(
    r'^ATTENTION_SERVICE_RTL_PASS rows=128 keys128 D64 cycles=(\d+) '
    r'qk=(\d+) sm=(\d+) av=(\d+) load=(\d+)\s*$', log, re.M)
fatal = bool(re.search(r'^(?:Fatal:|ERROR:)', log, re.M))
qk_rows = [int(x) for x in re.findall(
    r'^ATTENTION_SERVICE_PROGRESS phase=QK row=(\d+) ', log, re.M)]
sm_rows = [int(x) for x in re.findall(
    r'^ATTENTION_SERVICE_PROGRESS phase=SOFTMAX row=(\d+) ', log, re.M)]
row_receipts = [tuple(map(int, values)) for values in re.findall(
    r'^ATTENTION_SERVICE_PROGRESS rows=(\d+) cycles=(\d+) qk=(\d+) '
    r'sm=(\d+) av=(\d+) calls=(\d+)\s*$', log, re.M)]
markers = {
    'exp_12_directed': 'ATTENTION_EXP_RTL_DIRECTED_PASS count=12' in log,
    'binding_reject': 'ATTENTION_SERVICE_BIND_REJECT_PASS wrong_head_ref' in log,
    'ce_hold': 'ATTENTION_SERVICE_CE_HOLD_PASS' in log,
    'mul_active_reset': 'ATTENTION_SERVICE_RESET_PASS real_fp_kind=0' in log,
    'add_paused_reset_preemption':
        'ATTENTION_SERVICE_RESET_PASS real_fp_kind=1 reset_preempted_pause=1' in log,
    'last_f32_reject_no_publish':
        'ATTENTION_SERVICE_LAST_F32_REJECT_PASS element=63 no_score_publish' in log,
}
complete = (qk_rows == list(range(128)) and sm_rows == list(range(128))
            and [r[0] for r in row_receipts] == list(range(1, 129)))
passed = (guard['child_exit_code'] == 0 and guard['trigger'] is None
          and not identity_errors and pass_match and not fatal
          and complete and all(markers.values()))
if passed:
    status = 'PASS'
elif guard['trigger'] is not None:
    status = ('NOT_RUN_COST' if guard['trigger']['reason'] == 'timeout'
              else 'STOPPED_BY_GUARD')
else:
    status = 'FAIL'
formal = Path(manifest['formal_origin'])
formal_result = json.loads((formal / 'numeric_result.json').read_text())
closure_path = Path(formal_result['ce_closure_manifest'])
assert sha256(closure_path) == formal_result['ce_closure_manifest_sha256']
fp_checks = {}
for kind, checked in re.findall(
        r'^ATTENTION_BASIC_FP_PASS op=(\w+) checked=(\d+) ', log, re.M):
    fp_checks[kind] = max(fp_checks.get(kind, 0), int(checked))
result = {
    'schema': 'attention_supported_domain_rtl_result_v1',
    'status': status,
    'scope': 'B1/S128 enc0 head0 true query0..127, complete K128/D64; '
             'eight 16-row allQK-allSM-allAV batches and protocol/reset/CE checks',
    'guard': guard,
    'guard_result_sha256': sha256(attempt / 'guard/guard_result.json'),
    'collector': {'path': str(Path(__file__).resolve()),
                  'sha256': sha256(Path(__file__).resolve())},
    'source_manifest': str(manifest_path),
    'source_manifest_sha256': sha256(manifest_path),
    'identity_errors': identity_errors,
    'fixture_manifest': str(fixture_manifest_path),
    'fixture_manifest_sha256': sha256(fixture_manifest_path),
    'fixture_products_hash_checked': len(fixture_manifest['products']),
    'ce_closure_manifest': str(closure_path),
    'ce_closure_manifest_sha256': sha256(closure_path),
    'simulator_log': str(log_path),
    'simulator_log_sha256': sha256(log_path) if log_path.exists() else None,
    'state_snapshot_members': formal_result['state_snapshot_members'],
    'check_markers': markers,
    'paused_reset_preemption': markers['add_paused_reset_preemption'],
    'observed_qk_rows': qk_rows,
    'observed_softmax_rows': sm_rows,
    'observed_av_rows': [r[0] - 1 for r in row_receipts],
    'fp_checks_including_idle_repeats': fp_checks,
    'not_proven': ['other head/layer/shape', 'full production RTL unique service instance',
                   'full graph high performance', 'physical P&R/Fmax/platform/board',
                   'arbitrary IEEE subnormal/denormal cases'],
}
if passed:
    total, qk, sm, av, load = map(int, pass_match.groups())
    result['cycles'] = dict(total=total, qk=qk, softmax=sm, av=av, load=load)
    result['independent_reference_values_by_phase'] = {
        'score': 16384, 'maximum': 128, 'exp': 16384, 'sum': 128,
        'probability': 16384, 'output': 8192,
    }
    batches = []
    previous = (0, 0, 0, 0, 0, 0)
    for current in row_receipts:
        if current[0] % 16:
            continue
        # Exactly one refused cmd7 (2 cycles) occurs before loading each batch.
        # Only the first legal cmd7 includes the deliberate 8-clock CE pause.
        # These offsets agree with the frozen pilot09/formal01 observations.
        qk_delta = current[2] - previous[2]
        sm_delta = current[3] - previous[3]
        av_delta = current[4] - previous[4]
        pause = 8 if current[0] == 16 else 0
        normal_compute = qk_delta - 2 - pause + sm_delta + av_delta
        batches.append({
            'query_first': current[0] - 16, 'query_count': 16,
            'completion_interval_cycles': current[1] - previous[1],
            'qk_command_cycles': qk_delta,
            'softmax_command_cycles': sm_delta,
            'av_command_cycles': av_delta,
            'refused_qk_cycles': 2, 'deliberate_ce_pause_cycles': pause,
            'normal_compute_command_cycles': normal_compute,
            'command_calls_since_previous_completion': current[5] - previous[5],
        })
        previous = current
    normal_compute = sum(batch['normal_compute_command_cycles'] for batch in batches)
    result['batch_measurements'] = batches
    result['service_rate'] = {
        'normal_compute_command_cycles_per_full_head': normal_compute,
        'normal_compute_command_cycles_per_query': normal_compute / 128,
        'normal_compute_heads_per_cycle': 1 / normal_compute,
        'scope': 'Summed nonoverlapping cmd7/8/9 accepted-to-ap_done durations; '
                 'subtract known refused QK and deliberate CE pause; excludes external '
                 'production caller, memory transport and TB readback/protocol exercises.',
        'full_tb_cycle_scope': 'Includes exp directed cases, binding rejection, active resets, '
                              'four initial KV loads, input fault recovery, eight batches, '
                              'all numeric readbacks and chain holds; not production latency.',
        'simulated_clock_period_ns': 10,
        'conditional_150mhz_compute_seconds': normal_compute / 150000000,
        'conditional_480_identical_heads_compute_seconds': normal_compute * 480 / 150000000,
        'frequency_scope': '150 MHz is an OOC synthesis target, not routed Fmax. '
                           'The 480-head figure is same-service bookkeeping for identical '
                           'shape/mode, not a full model timing measurement.',
    }
    result['post_last_numeric_readback_cycles'] = total - row_receipts[-1][1]
target = attempt / 'numeric_result.json'
assert not target.exists(), 'Do not overwrite a prior terminal receipt'
target.write_text(json.dumps(result, indent=2) + '\n')
print('ATTENTION_HEAD128_COLLECTED', status, target)
if not passed:
    raise SystemExit(1)
