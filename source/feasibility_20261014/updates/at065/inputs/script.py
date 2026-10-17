#!/usr/bin/env python3
"""Audit bounded AT065 evidence without EDA, model execution, or v4 changes."""
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = HERE / 'updates/at065'
assert not OUT.exists(), 'Preserve previous audit outputs.'
(OUT / 'inputs').mkdir(parents=True)
R = 'project/E006_feasibility_assessment/experiment_results/runs/R001/'
A = R + 'attempts/AT065_M005_down_boundary_observe_01/'
paths = {
    'driver': A + 'guard_full/driver.log',
    'guard': A + 'guard_full/guard_result.json',
    'result': A + 'result_full.json',
    'frozen_tb': A + 'frozen_new/ffn0_chain_tb_v1.sv',
    'source_manifest': A + 'source_manifest.json',
    'engineering_report': R + 'reports/M005_AT065_down_admission_unknown_20261014.md',
    'message': '.research-agent/communications/m005-at065-research-measurement-update-20261014.json',
    'controller_audit': 'results/feasibility_mission_20261014/research_delivery_audit.json',
    'script': str(Path(__file__).resolve().relative_to(ROOT)),
    'runner': str((HERE / 'run_host.py').relative_to(ROOT)),
}
data, manifest = {}, []
for key, rel in paths.items():
    p = ROOT / rel
    assert p.stat().st_size < 2 * 1024**2
    blob = p.read_bytes()
    target = 'inputs/' + key + p.suffix
    (OUT / target).write_bytes(blob)
    data[key] = blob.decode()
    manifest.append({'key': key, 'path': rel, 'snapshot': target,
                     'bytes': len(blob), 'sha256': hashlib.sha256(blob).hexdigest()})
lines = data['driver'].splitlines()
selected = [{'line': i + 1, 'text': l} for i, l in enumerate(lines)
            if l.startswith(('M005_DOWN_', 'Fatal:', 'Time: 3588801 ns'))
            or 'cycle=358880 physical_W_published=1' in l]
assert len([x for x in selected if x['text'].startswith('Fatal:')]) == 1
sample = next(x for x in selected if x['text'].startswith('M005_DOWN_ENTRY_SAMPLE '))
assert 'matrix_valid=x' in sample['text'] and 'static_ok=x' in sample['text']
assert 'cfg_valid=1 cfg_ready=1' in sample['text']
assert any('W_R=20992,20992,2624 scale_checks=83968' in x['text'] for x in selected)
assert any(x['text'].startswith('Time: 3588801 ns') for x in selected)
assert not any(l.startswith('FFN0_CHAIN_PASS') for l in lines)
guard, result = (json.loads(data[k]) for k in ['guard', 'result'])
assert guard == result['guard'] and result['verdict'] == 'FAIL'
assert guard['child_exit_code'] == 0 and guard['trigger'] is None
tb_refs = [{'line': i + 1, 'text': l} for i, l in enumerate(data['frozen_tb'].splitlines())
           if re.search(r'\bg_cfg_K\b', l)]
assert len(tb_refs) == 1 and '.gate_k(g_cfg_K)' in tb_refs[0]['text']
entry = next(x for x in json.loads(data['source_manifest'])['files']
             if x['path'] == str(ROOT / paths['frozen_tb']))
tb_identity = next(x for x in manifest if x['key'] == 'frozen_tb')
assert entry['sha256'] == tb_identity['sha256'] and entry['bytes'] == tb_identity['bytes']
assert str(ROOT / paths['frozen_tb']) in data['driver']
anchors = []
for entry in json.loads(data['controller_audit'])['evidence']:
    if entry['path'] in ['source/feasibility_20261014/report.md',
                         'source/feasibility_20261014/v4/budget.json',
                         'source/feasibility_20261014/v4/input_manifest.json']:
        assert hashlib.sha256((ROOT / entry['path']).read_bytes()).hexdigest() == entry['sha256']
        anchors.append(entry)
assert len(anchors) == 3
audit = {
    'status': 'PASS_EVIDENCE_AUDIT_NOT_CHAIN_OR_PHYSICAL_PASS',
    'engineering_verdict': 'FAIL_SEMANTIC_DOWN_ADMISSION_UNKNOWN',
    'guard': guard,
    'runner_verdict': result['verdict'],
    'selected_log_evidence': selected,
    'frozen_tb_g_cfg_K_references': tb_refs,
    'frozen_tb_source_manifest_entry_verified': tb_identity,
    'identity_scope': 'Frozen TB hash checked against source manifest and path against dynamic Fatal; other runtime files not rehashed by A003.',
    'root_cause_status': 'UNDRIVEN_K_CANDIDATE_REQUIRES_DYNAMIC_CONFIRMATION',
    'full_FFN_cycles': 'UNKNOWN_NOT_REACHED',
    'Down_cfg_to_retirement': 'UNKNOWN_NOT_REACHED',
    'physical_frequency': 'UNKNOWN_NOT_RUN per engineering update',
    'v4_model_parameter_changes': [],
    'frozen_v4_anchors_unchanged': anchors,
    'limitations': [
        'AT065 Fatal cannot be retroactively attributed to AT063.',
        'Return code zero does not override Fatal and runner FAIL.',
        '358880/3588801ns are diagnostic endpoints, not complete chain service.',
        'Testbench time units do not establish routed device frequency.',
        'No unique-cause claim, complete gold, residual completion, or speedup.',
    ],
}
(OUT / 'input_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
(OUT / 'audit.json').write_text(json.dumps(audit, indent=2) + '\n')
print(json.dumps({'status': audit['status'], 'inputs': len(manifest),
                  'runner_verdict': result['verdict'], 'guard_child_exit': 0,
                  'root_cause': audit['root_cause_status'], 'v4_changes': []}))
