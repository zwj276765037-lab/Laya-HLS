#!/usr/bin/env python3
"""Audit AT073 prefix endpoints and failed synthesis; preserve frozen v4."""
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = HERE / 'updates/at073'
assert not OUT.exists(), 'Preserve previous evidence.'
(OUT / 'inputs').mkdir(parents=True)
R = 'project/E006_feasibility_assessment/experiment_results/runs/R001/'
A = R + 'attempts/AT073_M005_top_normal_phase_fix_01/'
paths = {
    'driver': A + 'guard_full/driver.log',
    'guard': A + 'guard_full/guard_result.json',
    'input_identity': A + 'input_manifest.json',
    'frozen_tb': A + 'frozen/m005_ffn_top_tb_v1.sv',
    'report': R + 'reports/M005_AT073_down_retirement_fail_20261014.md',
    'physical_question': R + 'reports/M005_physical_hub_synthesis_boundary_question_20261014.md',
    'budget_ledger': R + 'reports/M005_budget_ledger_after_AT077_20261014.json',
    'old_driver': 'project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/guard_full/driver.log',
    'v4_budget': 'source/feasibility_20261014/v4/budget.json',
    'controller_audit': 'results/feasibility_mission_20261014/research_delivery_audit.json',
    'engineering_message': '.research-agent/communications/m005-at073-research-measurement-update-20261014.json',
    'script': str(Path(__file__).resolve().relative_to(ROOT)),
    'runner': str((HERE / 'run_host.py').relative_to(ROOT)),
}
for name in ['AT074_M005_joint_physical_01', 'AT075_M005_joint_physical_ports_02',
             'AT077_M005_joint_physical_bounded_hub_03']:
    paths[name[:5] + '_synth_log'] = R + 'attempts/' + name + '/guard_synth/driver.log'
    paths[name[:5] + '_synth_guard'] = R + 'attempts/' + name + '/guard_synth/guard_result.json'
data, manifest = {}, []
for key, rel in paths.items():
    p = ROOT / rel
    assert p.stat().st_size < 2 * 1024**2, rel
    blob = p.read_bytes()
    snapshot = 'inputs/' + key + p.suffix
    (OUT / snapshot).write_bytes(blob)
    data[key] = blob.decode()
    manifest.append({'key': key, 'path': rel, 'snapshot': snapshot,
                     'bytes': len(blob), 'sha256': hashlib.sha256(blob).hexdigest()})

def select(text, prefix):
    return [{'line': i+1, 'text': l} for i,l in enumerate(text.splitlines()) if l.startswith(prefix)]

def kv(line):
    return {k: int(v) for k,v in re.findall(r'(\w+)=(-?\d+)(?= |$)', line)}

bounds = select(data['driver'], 'DOWN_MEASURE_BOUNDARIES ')
old_bounds = select(data['old_driver'], 'DOWN_MEASURE_BOUNDARIES ')
assert len(bounds) == len(old_bounds) == 2
assert [x['text'] for x in bounds] == [x['text'] for x in old_bounds]
wi, down = [kv(x['text']) for x in bounds]
states = select(data['driver'], 'DOWN_MEASURE_STATES ')[1]
cycles = {
    'cfg_to_first_done_difference': down['first_done_valid'] - down['cfg_accept'],
    'cfg_to_done_consume_difference': down['actual_done_consume'] - down['cfg_accept'],
    'cfg_to_done_consume_both_endpoint_samples': down['actual_done_consume'] - down['cfg_accept'] + 1,
}
assert list(cycles.values()) == [16185, 16192, 16193]
assert kv(states['text'])['cycles'] == cycles['cfg_to_first_done_difference']
assert 'end_exclusive_first_done=1' in states['text']
assert json.loads(data['v4_budget'])['measured_anchors']['Down_service_cycles'] == 16192
g = select(data['driver'], 'WIGQD_BOUNDARIES ')
assert len(g) == 1 and g[0]['text'] == select(data['old_driver'], 'WIGQD_BOUNDARIES ')[0]['text']
gd = kv(g[0]['text'])
gate_last_b = int(re.search(r'GATE_B=\d+/(\d+)', g[0]['text']).group(1))
assert gate_last_b - gd['G_cfg'] == 57993
q_first_r = int(re.search(r'quant_R=(\d+)/', g[0]['text']).group(1))
assert gd['A_publish'] - q_first_r == 2703
load = select(data['driver'], 'DOWN_MEASURE_LOAD ')[1]
assert all(kv(load['text'])[k] == 0 for k in ['q0_R_not_ready', 'q1_R_not_ready', 'scale_R_not_ready', 'AUX_R_not_ready'])
output = select(data['driver'], 'DOWN_MEASURE_OUTPUT ')[1]
assert all(kv(output['text'])[k] == 256 for k in ['actual_AW', 'actual_W', 'actual_B'])
prefix = select(data['driver'], 'FFN0_PREFIX_PASS ')
fatal = select(data['driver'], 'Fatal: FFN0 Down-to-residual retirement gate did not retain ticket')
assert len(prefix) == len(fatal) == 1 and prefix[0]['line'] < fatal[0]['line']
assert not select(data['driver'], 'FFN0_CHAIN_PASS')
guard = json.loads(data['guard'])
assert guard['child_exit_code'] == 0 and guard['trigger'] is None
identity = json.loads(data['input_identity'])
tb = next(x for x in identity['files'] if x['path'] == str(ROOT / paths['frozen_tb']))
assert hashlib.sha256(data['frozen_tb'].encode()).hexdigest() == tb['sha256']
physical = []
for attempt in ['AT074', 'AT075', 'AT077']:
    errors = select(data[attempt + '_synth_log'], 'ERROR:')
    sg = json.loads(data[attempt + '_synth_guard'])
    assert errors and sg['child_exit_code'] != 0
    physical.append({'attempt': attempt, 'errors': errors, 'guard': sg,
                     'valid_netlist_resources_frequency': 'NOT_OBTAINED'})
anchors = []
for entry in json.loads(data['controller_audit'])['evidence']:
    if entry['path'] in ['source/feasibility_20261014/report.md',
                         'source/feasibility_20261014/v4/budget.json',
                         'source/feasibility_20261014/v4/input_manifest.json']:
        assert hashlib.sha256((ROOT / entry['path']).read_bytes()).hexdigest() == entry['sha256']
        anchors.append(entry)
assert len(anchors) == 3
ledger = json.loads(data['budget_ledger'])
assert ledger['full_attempts_completed'] == ledger['full_attempts_limit'] == 3
audit = {
    'status': 'PASS_EVIDENCE_AND_ENDPOINT_AUDIT_NOT_FULL_CHAIN_OR_PHYSICAL_PASS',
    'engineering_verdict': 'FAIL_SEMANTIC_DOWN_RESIDUAL_TICKET',
    'guard': guard,
    'Down_cycle_conventions': cycles,
    'correction': '16185 denotes cfg-to-first-done difference, not cfg-to-consume inclusive samples.',
    'matching_AT049_boundaries': {'Wi': bounds[0], 'Down': bounds[1], 'WIGQD': g[0]},
    'selected_evidence': [states, load, output, prefix[0], fatal[0]],
    'verified_frozen_tb_identity': tb,
    'service_anchors': {'Wi_cfg_to_consume_difference': wi['actual_done_consume'] - wi['cfg_accept'],
                        'G_cfg_to_last_GATE_B_difference': gate_last_b - gd['G_cfg'],
                        'Q_first_R_to_A_publish_difference': gd['A_publish'] - q_first_r,
                        'Down_W_load_difference': down['W_publish_post_NBA'] - down['W_load_accept'],
                        'Down_cfg_to_consume_difference': cycles['cfg_to_done_consume_difference']},
    'physical_attempts': physical,
    'full_attempt_count': '3/3 per A002 ledger; three raw guards not all reaudited in this job',
    'full_FFN_completion': 'NOT_REACHED',
    'independent_backpressure_full': 'NOT_RUN',
    'physical_frequency': 'UNKNOWN',
    'v4_model_parameter_changes': [],
    'frozen_v4_anchors_unchanged': anchors,
    'limitations': [
        'Matching local boundaries do not prove whole design equivalence or full graph rates.',
        'The retirement Fatal is a conjunction; the failing operand is not separately observed.',
        'No residual or final HIDDEN/gold/protection evidence can be spliced from AT054.',
        'Synthesis elaboration failure is not evidence of device resource overflow or low Fmax.',
        'No valid physical replacement for the v4 100/150/200MHz conditions.',
    ],
}
(OUT / 'input_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
(OUT / 'audit.json').write_text(json.dumps(audit, indent=2) + '\n')
print(json.dumps({'status': audit['status'], 'inputs': len(manifest), 'Down_cycles': cycles,
                  'v4_changes': [], 'physical_attempts_failed': len(physical)}))
