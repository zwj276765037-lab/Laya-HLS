#!/usr/bin/env python3
"""Read bounded AT087 cost-stop evidence; do not run synthesis or the model."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = HERE / 'updates/at087'
assert not OUT.exists(), 'Keep previous evidence immutable.'
(OUT / 'inputs').mkdir(parents=True)
R = 'project/E006_feasibility_assessment/experiment_results/runs/R001/'
A = R + 'attempts/AT087_M005_joint_physical_synth_guard_07/'
paths = {
    'driver': A + 'guard_synth/driver.log',
    'guard': A + 'guard_synth/guard_result.json',
    'trigger': A + 'guard_synth/guard_trigger.json',
    'plan': A + 'guard_synth/guard_plan.json',
    'preflight': A + 'preflight_synth.json',
    'source_manifest': A + 'input_manifest.json',
    'top': A + 'frozen_source/laya_ffn_representative_top_v1.sv',
    'synth_script': A + 'frozen/run_m005_joint_synth_v1.tcl',
    'engineering_report': R + 'reports/M005_R3_bounded_physical_stop_20261014.md',
    'engineering_summary': 'project/E006_feasibility_assessment/experiment_results/summary.md',
    'budget_ledger': R + 'reports/M005_budget_ledger_after_AT087_20261014.json',
    'engineering_message': '.research-agent/communications/m005-at087-research-physical-boundary-20261014.json',
    'controller_audit': 'results/feasibility_mission_20261014/research_delivery_audit.json',
    'script': str(Path(__file__).resolve().relative_to(ROOT)),
    'host_runner': str((HERE / 'run_host.py').relative_to(ROOT)),
}
data, manifest = {}, []
for key, rel in paths.items():
    p = ROOT / rel
    assert p.stat().st_size < 2 * 1024**2, rel
    blob = p.read_bytes()
    target = 'inputs/' + key + p.suffix
    (OUT / target).write_bytes(blob)
    data[key] = blob.decode()
    manifest.append({'key': key, 'path': rel, 'snapshot': target, 'bytes': len(blob),
                     'sha256': hashlib.sha256(blob).hexdigest()})
guard, plan, trigger = [json.loads(data[k]) for k in ['guard', 'plan', 'trigger']]
assert guard['trigger'] == 'owned_rss_at_or_above_limit' and guard['child_exit_code'] == -9
assert plan['maximum_owned_rss_kb'] == 24 * 1024**2
assert guard['peak_owned_rss_kb'] >= plan['maximum_owned_rss_kb']
assert guard['minimum_mem_available_kb'] > plan['minimum_mem_available_kb']
assert json.loads(data['preflight'])['status'] == 'ACCEPT'
assert not any(l.startswith('ERROR:') for l in data['driver'].splitlines())
assert not any(l.strip() == 'M005_SYNTH_COMPLETE' for l in data['driver'].splitlines())
products = []
for name in ['representative_synth.dcp', 'utilization.rpt', 'utilization_hierarchy.rpt', 'timing_synth.rpt']:
    p = ROOT / A / 'work' / name
    assert not p.exists(), str(p)
    products.append({'path': str(p.relative_to(ROOT)), 'exists_at_audit': False})
verified = []
entries = json.loads(data['source_manifest'])['files']
for key in ['top', 'synth_script']:
    e = next(x for x in entries if x['path'] == str(ROOT / paths[key]))
    assert e['sha256'] == hashlib.sha256(data[key].encode()).hexdigest()
    assert e['bytes'] == len(data[key].encode())
    verified.append(e)
anchors = []
for e in json.loads(data['controller_audit'])['evidence']:
    if e['path'] in ['source/feasibility_20261014/report.md', 'source/feasibility_20261014/v4/budget.json',
                     'source/feasibility_20261014/v4/input_manifest.json']:
        assert hashlib.sha256((ROOT / e['path']).read_bytes()).hexdigest() == e['sha256']
        anchors.append(e)
assert len(anchors) == 3
audit = {
    'status': 'PASS_COST_STOP_EVIDENCE_AUDIT_NOT_PHYSICAL_RESULT',
    'engineering_verdict': 'COST_STOP_SYNTH_OWNED_RSS_24GIB',
    'guard': guard, 'rss_limit_kib': plan['maximum_owned_rss_kb'],
    'observed_peak_above_limit_kib': guard['peak_owned_rss_kb'] - plan['maximum_owned_rss_kb'],
    'limit_domain': 'host owned RSS; not FPGA BRAM/URAM or other silicon resources',
    'expected_products': products,
    'verified_source_entries': verified,
    'identity_scope': 'Top and synth Tcl verified; full inherited RTL/IP/ROM identity checks remain A002 evidence.',
    'FPGA_resources_and_Fmax': 'UNKNOWN_NO_VALID_NETLIST',
    'routed_frequency': 'UNKNOWN_ROUTE_NOT_RUN',
    'full_FFN_and_backpressure': 'NOT_PROVEN; AT073 and R3 candidate identities remain separate',
    'v4_parameter_changes': [], 'frozen_v4_anchors_unchanged': anchors,
    'limitations': ['Memory growth cause and dominant RTL hierarchy not isolated.',
                    'No inference of device overflow, impossible timing or FPGA-wide infeasibility.',
                    'Local equivalence/short-test PASS remains scoped; no new complete-chain measurement.',
                    'No new model, synthesis, route, full simulation or retry run in this audit.'],
}
(OUT / 'input_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
(OUT / 'audit.json').write_text(json.dumps(audit, indent=2) + '\n')
print(json.dumps({'status': audit['status'], 'inputs': len(manifest),
                  'rss_limit_kib': audit['rss_limit_kib'], 'products_absent': len(products),
                  'v4_changes': []}))
