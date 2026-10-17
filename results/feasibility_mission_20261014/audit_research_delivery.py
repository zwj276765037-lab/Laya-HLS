"""Read-only audit of M005 stage-C frozen outputs; does not execute model/EDA."""
import csv
import hashlib
import json
import math
import time
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parents[2]
base = root / 'source/feasibility_20261014'
data = base / 'v4'
started = time.monotonic()
manifest = json.loads((data / 'input_manifest.json').read_text())
source_changes = []
for item in manifest:
    raw = (data / item['snapshot']).read_bytes()
    assert len(raw) == item['bytes']
    assert hashlib.sha256(raw).hexdigest() == item['sha256']
    live = root / item['path']
    if not live.exists() or hashlib.sha256(live.read_bytes()).hexdigest() != item['sha256']:
        source_changes.append(item['path'])
replayed = []
for path in sorted(data.iterdir()):
    if path.is_file():
        assert path.read_bytes() == (base / 'v4_replay' / path.name).read_bytes(), path.name
        replayed.append(path.name)
budget = json.loads((data / 'budget.json').read_text())
ops = json.loads((data / 'operations.json').read_text())
matrix = [x for x in ops if x['kind'] == 'MATRIX']
quant = [x for x in ops if x['kind'] == 'QUANT']
independent = {
    'q8_MAC': json.loads((root / 'results/feasibility_mission_20261014/initial_budget.json').read_text())['int8_MAC'],
    'LN_rows': (1 + 27 + 28 + 1 + 4) * 128 + 16,
    'Attention_QK_MAC': 30 * 16 * 128 * 128 * 64,
    'residual_elements': 30 * 2 * 128 * 1024,
}
assert sum(x['MAC'] for x in matrix) == independent['q8_MAC'] == budget['workload']['Q8_INT8_MAC']
assert independent['LN_rows'] * 1024 == budget['workload']['LN_elements']
assert independent['Attention_QK_MAC'] == budget['workload']['Attention_QK_FP_MAC']
assert independent['residual_elements'] == budget['workload']['residual_adds']
assert len(matrix) == 3845 and len(quant) == 962
assert all(x['rows'] <= 4 for x in matrix)
assert all(x['rows'] <= 16 and x['width'] <= 4096 for x in quant)
replay = json.loads((data / 'ffn_replay.json').read_text())
assert sum(v for k, v in replay.items() if isinstance(v, int) and k != 'sum_cycles') == 375074
assert replay['G_until_last_B'] == 57993
rows = list(csv.DictReader((data / 'scenarios.csv').open()))
selected = [r for r in rows if float(r['effective_aggregate_GBps']) == 10
            and float(r['unknown_aux_cycles_per_unit']) == 8 and int(r['row_reuse']) in (4, 128)]
assert len(selected) == 6
for row in selected:
    latency = float(row['serial_warm_device_seconds_conditional'])
    assert latency == float(row['serial_II_seconds_conditional'])
    assert math.isclose(latency * float(row['serial_QPS_conditional']), 1.0)
receipts = [json.loads((base / f'host_runs/H{i:03d}.json').read_text()) for i in range(1, 7)]
assert all(r['exit_status'] == 0 and r['trigger'] is None for r in receipts)
assert all(r['elapsed_seconds'] <= 120 for r in receipts)
assert sum(r['elapsed_seconds'] for r in receipts) <= 600
samples = [s for r in receipts for s in r['samples']]
assert all(s['cpus'] == '0-3' and s['nice'] == 19 for s in samples)
evidence = []
for path in [base / 'report.md', data / 'budget.json', data / 'input_manifest.json',
             base / 'host_runs/H006.log', Path(__file__)]:
    raw = path.read_bytes()
    evidence.append({'path': str(path.relative_to(root)), 'bytes': len(raw),
                     'sha256': hashlib.sha256(raw).hexdigest()})
out = {'status': 'PASS_SCOPED_CONDITIONAL_ANALYSIS_AUDIT_NOT_HARDWARE',
       'at': datetime.now(timezone.utc).isoformat(), 'elapsed_seconds': time.monotonic() - started,
       'snapshot_inputs_verified': len(manifest), 'live_source_changes': source_changes,
       'byte_identical_replay_files': replayed, 'independent_workload_checks': independent,
       'model_operations': len(ops), 'matrix_views': len(matrix), 'quant_windows': len(quant),
       'selected_scenarios': selected, 'research_host_seconds': sum(r['elapsed_seconds'] for r in receipts),
       'research_policy_samples': len(samples), 'evidence': evidence,
       'limitations': ['No DUT/reference/EDA execution in this audit.',
                      'Transferred local rates, frequency, bandwidth and unknown operator rates remain assumptions.',
                      'No full-model measured latency/throughput, routed frequency, resource fit or matched speedup.',
                      'Research I/O policy was requested but not sampled.']}
dest = Path(__file__).with_name('research_delivery_audit.json')
dest.write_text(json.dumps(out, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: out[k] for k in ('status', 'snapshot_inputs_verified', 'live_source_changes',
                                    'model_operations', 'research_host_seconds')}, ensure_ascii=False))
