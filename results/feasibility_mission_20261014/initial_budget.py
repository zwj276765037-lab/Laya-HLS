"""Read-only dimensional budget; no reference model, DUT or EDA invocation."""
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
BASE = ROOT / 'project/E002_Laya_HLS/experiment'
OUT = ROOT / 'results/feasibility_mission_20261014'
manifest_path = BASE / 'build/model-current-production-v2-20261011/manifest.json'
prior_path = BASE / 'results/performance_estimate_20261008/model_weights_q8_work.json'
m = json.loads(manifest_path.read_text())
old = json.loads(prior_path.read_text())
by_name = {w['name']: w for w in m['weights']}
fields = ['name', 'family', 'layer', 'K', 'N', 'dtype', 'q_span', 'scale_span', 'aux_span', 'bias_span']
mismatch = [(w['name'], k) for w in old['weights'] for k in fields
            if k in w and by_name[w['name']][k] != w[k]]
assert not mismatch
rows_by_family = {1: 128, 2: 128, 3: 128, 4: 128, 5: 128,
                  6: 128, 7: 128, 8: 128, 9: 16, 12: 1}
work = []
for w in m['weights']:
    if w['dtype'] != 8:
        continue
    rows = rows_by_family[w['family']]
    work.append({'name': w['name'], 'family': w['family'], 'rows': rows,
                 'K': w['K'], 'N': w['N'], 'MAC': rows * w['K'] * w['N'],
                 'once_declared_weight_bytes': sum(w['q_span']) + w['scale_span'] + w['aux_span']})
macs = sum(w['MAC'] for w in work)
weight_bytes = sum(w['once_declared_weight_bytes'] for w in work)
assert len(work) == 122
assert macs == old['scenarios']['B1_from_b0_S128']['total']['int8_macs']
assert weight_bytes == old['scenarios']['B1_from_b0_S128']['total']['declared_load_bytes']
rates = {'Wi': 4 * 1024 * 5248 / 46917, 'Down': 4 * 2624 * 1024 / 16192}
scenarios = []
for mhz in (100, 150, 200):
    scenarios.append({'assumed_MHz': mhz,
                      'q8_seconds_if_all_matrices_have_local_rate':
                      {k: macs / (v * mhz * 1e6) for k, v in rates.items()}})
records = []
for path in (manifest_path, prior_path, ROOT / 'results/measurement_first_LNQ2_review_20261014.md'):
    b = path.read_bytes()
    records.append({'path': str(path), 'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()})
result = {'schema': 'M005_initial_dimensional_budget_v1', 'at': datetime.now(timezone.utc).isoformat(),
          'status': 'CONDITIONAL_INITIAL_ANALYSIS_NOT_FULL_MODEL_PERFORMANCE',
          'profile': 'historical B1_from_b0_S128 workload: 128 token rows, scorer family9 rows16, final family12 rows1; A003 must bind to current request graph',
          'model_sha256': m['source_model']['sha256'], 'descriptor_field_mismatches': mismatch,
          'q8_matrix_count': len(work), 'int8_MAC': macs,
          'once_declared_weight_bytes': weight_bytes,
          'MAC_per_cycle_cfg_to_consume_local_AT049': rates, 'frequency_scenarios': scenarios,
          'weight_only_seconds_by_assumed_effective_GBps':
          {str(gbps): weight_bytes / (gbps * 1e9) for gbps in (10, 25, 50)},
          'per_matrix_work': work, 'inputs': records,
          'limitations': ['Q8 alone; excludes Attention/LN/G/quant/residual/Decision FP and control.',
                         'Assumed frequency is not synthesized or routed evidence.',
                         'Wi/Down stage intervals exclude prior W load; all other shapes are not measured at these rates.',
                         'Single read per weight is an assumption; physical reads, window reloads, activation/PS/scale traffic need separate accounting.',
                         'Neither request latency nor steady-state throughput nor a performance bound is established.',
                         'Old serial Q8 loop latency was not reused.']}
(OUT / 'initial_budget.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ('status', 'q8_matrix_count', 'int8_MAC', 'once_declared_weight_bytes', 'frequency_scenarios')}, ensure_ascii=False))
