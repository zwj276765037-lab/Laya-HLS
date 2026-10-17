#!/usr/bin/env python3
"""Read bounded source identities and evaluate explicit scratch/traffic formulae only."""
import hashlib
import json
import os
from pathlib import Path
import resource
import time

start = time.monotonic()
root = Path(__file__).resolve().parents[2]
available = next(int(x.split()[1]) for x in Path('/proc/meminfo').read_text().splitlines()
                 if x.startswith('MemAvailable:'))
if available <= 192 * 1024 * 1024:
    raise SystemExit('MemAvailable is not above 192 GiB; no analysis performed')
paths = [
    'source/feasibility_20261014/v4/budget.json',
    'project/E002_Laya_HLS/experiment/tests/full_reference.py',
    'project/E002_Laya_HLS/experiment/hls/operators/layernorm_compute.cpp',
    'project/E002_Laya_HLS/experiment/hls/operators/q8_linear_compute.cpp',
    'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_ffn_fadd_slot_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_ffn_residual_four_row_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/geglu_canonical_core.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/attention_tile_service_prefetch_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_row_pipeline_v1.sv',
    'project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/quant16_stream_row.sv',
    'project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_attention_softmax_comparison_20261013.md',
]
identities = []
for name in paths:
    data = (root / name).read_bytes()
    identities.append({'path': name, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
budget = json.loads((root / paths[0]).read_text())
scratch = {'H0': 128*1024*4, 'H1': 128*1024*4, 'N': 128*1024*4,
           'S0': 128*5248*4, 'S1': 128*4096*4}
result = {
    'scope': 'M004 static arithmetic and bounded source hashes; no graph/reference/EDA execution',
    'input_identities': identities,
    'reused_Q8_MAC': budget['workload']['Q8_INT8_MAC'],
    'scratch_design_bytes': scratch,
    'scratch_design_total_bytes': sum(scratch.values()),
    'scratch_design_total_MiB': sum(scratch.values()) / 2**20,
    'residual_four_rows_values': 4*1024,
    'residual_four_rows_minimum_external_data_bytes': 4*1024*3*4,
    'residual_shared_512bit_port_minimum_data_cycles_at_one_beat_per_cycle': 4*1024*3*4//64,
    'residual_one_lane_II1_at_assumed_150MHz_useful_GBps': 3*4*150e6/1e9,
    'attention_old_sample_EXP4_balanced_busy_floor_cycles': 898680/4,
    'sampling': {
        'MemAvailable_KiB_before': available,
        'CPU_affinity': sorted(os.sched_getaffinity(0)),
        'nice': os.getpriority(os.PRIO_PROCESS, 0),
        'elapsed_seconds_inside_script': time.monotonic()-start,
        'max_RSS_KiB_self': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
        'earlier_source_browsing_cumulative_RSS_and_time': 'UNKNOWN; not uniformly sampled',
    },
}
(Path(__file__).parent / 'small_budget_evidence.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: result[k] for k in ['scratch_design_total_bytes', 'scratch_design_total_MiB', 'sampling']}))
