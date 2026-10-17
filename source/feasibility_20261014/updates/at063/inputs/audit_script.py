#!/usr/bin/env python3
"""Bounded read-only evidence audit; never executes hardware/model or reruns v4."""
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = HERE / 'updates' / 'at063'
assert not OUT.exists(), 'Preserve previous evidence; use a new update identity.'
OUT.mkdir(parents=True)
(OUT / 'inputs').mkdir()
R = 'project/E005_full_request_performance/experiment_results/runs/R001/'
A = R + 'attempts/AT063_FFN4_wi_descriptor_01/'
paths = {
    'driver': A + 'guard_full/driver.log',
    'guard': A + 'guard_full/guard_result.json',
    'trigger': A + 'guard_full/guard_trigger.json',
    'result': A + 'result_full.json',
    'engineering_report': R + 'reports/FFN4_AT063_bounded_stop_20261014.md',
    'at049_driver': R + 'attempts/AT049_LNQ2_runtime_01/guard_full/driver.log',
    'controller_audit': 'results/feasibility_mission_20261014/research_delivery_audit.json',
    'engineering_message': '.research-agent/communications/m005-at063-stage-c-update-20261014.json',
    'audit_script': str(Path(__file__).resolve().relative_to(ROOT)),
    'host_runner': str((HERE / 'run_host.py').relative_to(ROOT)),
}
data, manifest = {}, []
for key, rel in paths.items():
    p = ROOT / rel
    assert p.stat().st_size < 2 * 1024**2, rel
    blob = p.read_bytes()
    snapshot = 'inputs/' + key + p.suffix
    (OUT / snapshot).write_bytes(blob)
    data[key] = blob.decode()
    manifest.append({'key': key, 'path': rel, 'bytes': len(blob),
                     'sha256': hashlib.sha256(blob).hexdigest(), 'snapshot': snapshot})

def kv(line):
    return {k: int(v) for k, v in re.findall(r'(\w+)=(-?\d+)(?= |$)', line)}

lines = data['driver'].splitlines()
old = data['at049_driver'].splitlines()
def select(seq, prefix):
    return [(i + 1, l) for i, l in enumerate(seq) if l.startswith(prefix)]

bounds = select(lines, 'DOWN_MEASURE_BOUNDARIES ')
assert len(bounds) == 1, 'Only Wi matrix boundaries expected in stopped run'
wi = kv(bounds[0][1])
old_wi = select(old, 'DOWN_MEASURE_BOUNDARIES ')[0][1]
assert bounds[0][1] == old_wi
assert wi['actual_done_consume'] - wi['cfg_accept'] == 46917
assert wi['first_done_valid'] - wi['cfg_accept'] == 46910
rows = select(lines, 'WIGQD_DIAG tag=wi_row_edge ')
assert len(rows) == 4
assert [kv(l)['rrow'] for _, l in rows] == [0, 1, 2, 3]
assert all(kv(l)['rbeat'] == 328 and kv(l)['rword'] == 5248 for _, l in rows)
ready = next((i + 1, l) for i, l in enumerate(lines) if 'GQD0_A_ready=1' in l)
q = kv(ready[1])
assert all(q[x] == 656 for x in ['gate_AW', 'gate_W', 'gate_B', 'gate_R'])
assert q['quant_groups'] == 328
publish = next((i + 1, l) for i, l in enumerate(lines) if 'stage=1 kind=a_publish' in l)
assert kv(publish[1])['cycle'] == 331802 and q['cycle'] == 331815
final_w = [(i + 1, l) for i, l in enumerate(lines) if 'physical_W_published=1' in l][-1]
assert 'cycle=358880 ' in final_w[1] and 'W_R=20992,20992,2624 ' in final_w[1]
last = select(lines, 'FFN1_PROGRESS ')[-1]
counts = kv(last[1])
assert counts['work'] == 282858
assert all(counts[x] == 10496 for x in ['giss', 'gret', 'gemit'])
assert all(counts[x] == 0 for x in ['rcfg', 'rsrc', 'radd', 'rwr', 'rdone'])
assert not any(l.startswith('FFN0_CHAIN_PASS') for l in lines)
guard, trigger, result = (json.loads(data[k]) for k in ['guard', 'trigger', 'result'])
assert result['verdict'] == 'FAIL' and result['guard'] == guard
assert guard['trigger'] == trigger['reason'] == 'semantic_stall'
assert guard['child_exit_code'] == -9
assert trigger['last_progress_line'] == last[1]

# Verify only the controller's frozen anchor identities; no model execution.
frozen = []
for entry in json.loads(data['controller_audit'])['evidence']:
    if entry['path'] in ['source/feasibility_20261014/report.md',
                         'source/feasibility_20261014/v4/budget.json',
                         'source/feasibility_20261014/v4/input_manifest.json']:
        blob = (ROOT / entry['path']).read_bytes()
        assert hashlib.sha256(blob).hexdigest() == entry['sha256']
        frozen.append(entry)
assert len(frozen) == 3

selected = [bounds[0], *rows, publish, ready, final_w, last]
same = []
for number, line in [bounds[0], publish, ready, final_w]:
    assert line in old
    same.append({'at063_line': number, 'at049_line': old.index(line) + 1, 'text': line})
audit = {
    'status': 'PASS_PREFIX_EVIDENCE_AUDIT_NOT_FULL_CHAIN_OR_HARDWARE_PERFORMANCE',
    'engineering_verdict': 'COST_STOP_SEMANTIC_STALL_AFTER_DOWN_W_LOAD',
    'raw_result_verdict': result['verdict'],
    'guard': guard,
    'seconds_without_recognized_progress': trigger['seconds_since_progress'],
    'last_observed_cycle_NOT_stop_or_total_cycle': 358880,
    'wi_cycles_cfg_to_done_consume': 46917,
    'wi_cycles_cfg_to_first_done': 46910,
    'wi_reader_R_from_four_row_counters': sum(kv(l)['rbeat'] for _, l in rows),
    'wi_scalar_from_four_row_counters': sum(kv(l)['rword'] for _, l in rows),
    'g_issue_return_emit_each': 10496,
    'gate_AW_W_B_each': 656,
    'second_Q_source_R': 656,
    'second_Q_scale_groups': 328,
    'A_publish_event_cycle': 331802,
    'A_ready_observation_cycle': 331815,
    'Down_W_R_q0_q1_scale': [20992, 20992, 2624],
    'matching_AT049_observation_lines': same,
    'selected_evidence': [{'line': n, 'text': l} for n, l in selected],
    'frozen_v4_anchors_unchanged': frozen,
    'full_FFN_cycles': 'UNKNOWN_NOT_REACHED',
    'full_model_measured_seconds': 'UNKNOWN',
    'new_representative_top_joint_synthesis_route': 'NOT_RUN per engineering update',
    'v4_model_parameter_changes': [],
    'limitations': [
        'Composite semantic counters are not transaction or scalar counts.',
        'Matching observations do not establish source or full-runtime equivalence.',
        'No inferred last GATE B timestamp from sparse progress samples.',
        '358880 is neither a complete chain duration nor a precise stop cycle.',
        'Guard termination does not prove a numerical error or DUT deadlock.',
        'No full chain substitution, cycle-to-frequency gain, or speedup claim.',
    ],
}
(OUT / 'input_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
(OUT / 'audit.json').write_text(json.dumps(audit, indent=2) + '\n')
print(json.dumps({'status': audit['status'], 'inputs': len(manifest),
                  'matching_AT049_observations': len(same),
                  'full_FFN_cycles': audit['full_FFN_cycles'],
                  'v4_model_parameter_changes': []}))
