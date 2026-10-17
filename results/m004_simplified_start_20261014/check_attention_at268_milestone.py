"""Read-only byte/log/receipt audit; no numerical oracle or EDA execution."""
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
from decimal import Decimal

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).with_name('attention_at268_milestone_review_20261015.json')
BASE = ROOT / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
AT = BASE / 'AT268_SM004_rev16_attention_eight_tile_01'
FIX = ROOT / 'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture'
checks, identities = [], []

def check(name, condition):
    checks.append({'name': name, 'pass': bool(condition)})
    if not condition:
        raise AssertionError(name)

def identity(path, expected=None):
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if expected is not None:
        check('sha256:' + str(path.relative_to(ROOT)), digest == expected)
    identities.append({'path': str(path.relative_to(ROOT)), 'sha256': digest, 'bytes': len(data)})
    return data

manifest = json.loads(identity(AT / 'source_manifest.json'))
check('manifest_count_92', len(manifest['files']) == 92)
for name, digest in manifest['files'].items():
    identity((AT if name.startswith('frozen/') else ROOT) / name, digest)

fm = json.loads((FIX / 'manifest.json').read_text())
for name in ['q', 'k', 'v', 'score', 'prob', 'out']:
    mem = (FIX / (name + '.mem')).read_text().split()
    encoded = b''.join(struct.pack('<I', int(x, 16)) for x in mem)
    original = identity(FIX / (name + '.bin'), fm['products'][name + '.bin']['sha256'])
    check('lossless_mem_bin:' + name, encoded == original)
    check('original_mem_manifest:' + name,
          hashlib.sha256((FIX / (name + '.mem')).read_bytes()).hexdigest() == fm['products'][name + '.mem']['sha256'])
    if name in ['q', 'k', 'v']:
        check('captured_producer_identity:' + name, hashlib.sha256(original).hexdigest() == fm['producer_planes'][name]['sha256'])
mask = bytes(int(x, 16) for x in (FIX / 'mask.mem').read_text().split())
request = ROOT / 'project/E002_Laya_HLS/experiment/build/current-production-requests-v2-20261011/B1_from_b0_S128.request.bin'
check('current_request_mask_offset832_length128', len(mask) == 128 and mask == request.read_bytes()[832:960])
check('mask72ones', sum(mask) == 72)

guards, policy_count = [], 0
sums = {'static': Decimal(0), 'rtl': Decimal(0)}
for attempt in sorted(BASE.glob('AT26[678]*')):
    for result_path in sorted(attempt.glob('guard*/guard_result.json')):
        guard = result_path.parent
        result = json.loads(identity(result_path), parse_float=Decimal)
        plan = json.loads(identity(guard / 'guard_plan.json'))
        policy = json.loads(identity(guard / 'policy_checks.json'))
        log = identity(guard / 'driver.log').decode()
        category = 'static' if 'static' in guard.name else 'rtl'
        sums[category] += result['elapsed_seconds']
        for row in policy:
            check('policy:' + str(guard.relative_to(BASE)) + ':' + str(row['pid']),
                  row['matches'] and row['affinity'] == [0, 1, 2, 3] and row['nice'] == 19 and row['ionice'] == 'idle' and row['ionice_exit'] == 0)
        policy_count += len(policy)
        check('guard_limit:' + str(guard.relative_to(BASE)),
              result['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb'] and
              result['minimum_mem_available_kb'] > 192 * 1024**2 and
              result['elapsed_seconds'] < Decimal(str(plan['maximum_seconds'])) and
              plan['selected_cpu_ids'] == [0, 1, 2, 3])
        fatal = re.findall(r'^Fatal:.*', log, flags=re.M)
        guards.append({'path': str(guard.relative_to(ROOT)), 'category': category,
                       'elapsed_seconds_exact': str(result['elapsed_seconds']),
                       'child_exit_code': result['child_exit_code'], 'trigger': result['trigger'],
                       'fatal_lines': fatal, 'policy_samples': len(policy),
                       'peak_owned_rss_kb': result['peak_owned_rss_kb']})
check('guard_counts_3static_5rtl', len(guards) == 8 and sum(g['category'] == 'static' for g in guards) == 3)
old_fatal = next(g for g in guards if 'AT266_' in g['path'] and g['path'].endswith('guard_pilot_02'))
check('AT266_child0_fatal_preserved_as_failure', old_fatal['child_exit_code'] == 0 and len(old_fatal['fatal_lines']) == 1)

launch = json.loads(identity(AT / 'eight_tile_launch_basis.json'), parse_float=Decimal)
profile = json.loads((AT / 'guard_profile_1tile/guard_result.json').read_text(), parse_float=Decimal)
full = json.loads((AT / 'guard_full_8tiles/guard_result.json').read_text(), parse_float=Decimal)
plan = json.loads((AT / 'guard_full_8tiles/guard_plan.json').read_text())
check('same_version_profile_receipt', launch['profile_elapsed_seconds'] == profile['elapsed_seconds'])
estimate = profile['elapsed_seconds'] * 8 * Decimal('2.5')
check('conservative_estimate_roundoff_and_cap', abs(estimate - launch['conservative_estimate_seconds']) < Decimal('0.000000001') and estimate <= 1440)
before = sums['rtl'] - full['elapsed_seconds']
launch_drift = before - launch['rtl_to_date_seconds']
check('launch_budget_using_exact_receipts', before + Decimal(1800) <= Decimal(3600))
check('launch_cumulative_static_basis', abs(sums['static'] - launch['static_to_date_seconds']) < Decimal('0.000000001'))
check('launch_budget_1800_available', Decimal(3600) - before >= 1800)
check('fixed_hard_cap1200', plan['maximum_seconds'] == launch['fixed_hard_cap_seconds'] == 1200)
check('actual_fixture_plusarg', 'fixture=' + str(FIX) in plan['command'] and 'tiles=8' in plan['command'])
check('full_child0_no_trigger', full['child_exit_code'] == 0 and full['trigger'] is None)
full_log = (AT / 'guard_full_8tiles/driver.log').read_text()
check('full_no_fatal_error', not re.search(r'(?im)^\s*(?:fatal:|error:|ERROR\s*\[)', full_log))
tiles = [dict((k, int(v)) for k, v in re.findall(r'(\w+)=(\d+)', line))
         for line in full_log.splitlines() if line.startswith('ATT_TILE_PASS ')]
check('eight_distinct_tiles', [x['tile'] for x in tiles] == list(range(8)))
for i, row in enumerate(tiles, 1):
    expected = {'R': 1088*i, 'AR': 1025*i, 'loads': 1025*i, 'B': 64*i,
                'svc': 18691*i, 'score': 2048*i, 'prob': 2048*i}
    check('tile_cumulative_counters:' + str(i-1), all(row[k] == v for k, v in expected.items()))
    check('tile_qk_sm_av_order:' + str(i-1), row['qk_at'] < row['sm_at'] < row['av_at'])
expected_final = 'ATT_FINAL_TILE_PASS tiles=8 R=8704 AR=8200 loads=8200 B=512 svc=149528 score=16384 prob=16384'
check('unique_terminal_after_eight_tiles', full_log.count(expected_final) == 1 and full_log.index(expected_final) > full_log.rindex('ATT_TILE_PASS '))
full_policy = json.loads((AT / 'guard_full_8tiles/policy_checks.json').read_text())
check('full_four_actual_policy_samples', len(full_policy) == 4)

policy = {'affinity': sorted(os.sched_getaffinity(0)), 'nice': os.getpriority(os.PRIO_PROCESS, 0),
          'ionice': subprocess.check_output(['ionice', '-p', str(os.getpid())], text=True).strip()}
check('controller_review_policy', policy == {'affinity': [0, 1, 2, 3], 'nice': 19, 'ionice': 'idle'})
report = {
    'decision': 'D-M004-REV16-AT268-01',
    'scope': 'AT268 frozen head0 eight-tile normal Attention consumer with software-captured QKV; byte/log audit only',
    'status': 'PASS_SCOPED_FROZEN_HEAD0_EIGHT_TILE_CONSUMER',
    'manifest_files': 92, 'manifest_mismatches': 0,
    'identities': identities, 'checks': checks, 'check_count': len(checks),
    'guards_AT266_AT268': guards, 'actual_policy_samples': policy_count,
    'cumulative_through_AT268_only': {k + '_seconds_exact': str(v) for k, v in sums.items()},
    'host_complete_cumulative': 'UNKNOWN',
    'launch_basis_accounting_correction': {
        'recorded_before_full_rtl_seconds': str(launch['rtl_to_date_seconds']),
        'original_guards_before_full_rtl_seconds': str(before),
        'understatement_seconds': str(launch_drift),
        'impact': 'No change to admission: original guards still leave more than1800s; original basis preserved',
        'initial_controller_audit': 'exit1 on exact accounting comparison; initial_failure.time.txt preserved; no EDA rerun',
    },
    'full_guard_seconds_exact': str(full['elapsed_seconds']), 'full_peak_owned_rss_kb': full['peak_owned_rss_kb'],
    'full_last_periodic_snapshot_is_not_terminal_totals': True,
    'tile_records': tiles, 'final_log_marker': expected_final,
    'manual_tb_review': {
        'path': str((AT / 'frozen/laya_attention_final_tile_tb.sv').relative_to(ROOT)),
        'simulated_publication_peer': True,
        'actual_production_adapter_reader_service_writer': True,
        'score_prob_checks_each': 16384, 'out_f32_checked_at_B_and_rescan': 8192,
        'all512_write_B_OKAY': True, 'last_B_hold_each_tile_cycles': 10,
        'normal_done_held_for_consumption': True,
        'caller_fields_mutated_after_acceptance': True,
        'no_AR_R_stall_or_error_coverage_in_this_normal_run': True,
        'sentinel_scope': 'compact att_mem only; eight trailing 64B slots after head0 output; no physical BO or neighbouring-head coverage',
        'tb_total_time_ns_not_command_latency': 13223450,
    },
    'limitations': [
        'No true128-row upstream producer or same-runtime producer-to-Attention handoff',
        'Captured QKV inputs are not independent QKV gold',
        'No full16head/Encoder/model or Host/HBM/physical BO/resource/Fmax acceptance',
        'Error fixes may change adapter; AT268 long PASS does not migrate to a new SHA',
        'Existing Q_DATA missing-beat error drain and writer fault rearm repairs remain in progress',
        'Whole-request first-error equivalence remains UNRESOLVED',
    ],
    'controller_process_policy': policy,
    'controller_measurement_receipt': 'attention_at268_milestone_review_20261015.time.txt',
}
OUT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'checks': len(checks), 'manifest_files': 92, 'policy_samples': policy_count,
                  'totals_through_AT268': {k: str(v) for k, v in sums.items()}, 'status': report['status']}))
