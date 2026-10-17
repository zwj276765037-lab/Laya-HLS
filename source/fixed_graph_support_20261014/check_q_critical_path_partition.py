"""Static timing text partition and source identities; never invokes EDA."""
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import time

started = time.monotonic()
root = Path(__file__).resolve().parents[2]
exp = root / 'project/E002_Laya_HLS/experiment'
attempt = root / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT116_SM004_lnq_row_ooc_01'
mem = next(int(l.split()[1]) for l in Path('/proc/meminfo').read_text().splitlines()
           if l.startswith('MemAvailable:'))
assert mem > 192*1024*1024

def identity(p):
    data = p.read_bytes()
    return {'path': str(p.relative_to(root)), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}

p = attempt / 'work/timing_paths.rpt'
raw = p.read_text()
first = raw.split('Slack (VIOLATED) :')[1]
lines = first.splitlines()
data_start = next(i for i,l in enumerate(lines) if '(Prop_FDRE_C_Q)' in l)
selector_end = next(i for i,l in enumerate(lines) if 'q/divider/u_div/have_recip1264_out' in l)
hidden_start = next(i for i,l in enumerate(lines) if i > selector_end and '<hidden>' in l)
data_end = next(i for i,l in enumerate(lines) if i > hidden_start and l.strip().startswith('FDRE'))
level_re = re.compile(r'^\s*(LUT[2-6]|CARRY8|MUXF[78]) \(Prop_')
segments = []
for name,a,b,t0,t1 in (
    ('launch_clock_to_last_named_recip_selection_net',data_start,selector_end,.028,49.806),
    ('named_divider_entry_cells_to_first_hidden_net',selector_end+1,hidden_start,49.806,52.216),
    ('hidden_IP_region_to_capture_data_pin',hidden_start+1,data_end,52.216,55.689)):
    counts = {}
    for l in lines[a:b+1]:
        m = level_re.match(l)
        if m: counts[m[1]] = counts.get(m[1],0)+1
    segments.append({'name':name, 'begin_arrival_ns':t0, 'end_arrival_ns':t1,
                     'difference_ns':round(t1-t0,3), 'logic_cells':counts,
                     'logic_levels':sum(counts.values()),
                     'last_report_line':lines[b].strip()})
assert sum(s['logic_levels'] for s in segments) == 231
sources = []
for rel in (
    'vivado/module_design/activation_quantizer/rtl/quant16_stream_row.sv',
    'vivado/module_design/activation_quantizer/rtl/quant16_divider_service.sv',
    'vivado/module_design/activation_quantizer/rtl/quant16_tiny_div127.sv',
    'vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv'):
    current = exp / rel
    entry = identity(current)
    frozen = attempt / 'frozen' / current.name
    if frozen.exists():
        entry['AT116_frozen'] = identity(frozen)
        entry['matches_AT116'] = entry['sha256'] == entry['AT116_frozen']['sha256']
        assert entry['matches_AT116'], rel
    else:
        entry['AT116_frozen'] = 'NOT_FOUND at direct frozen basename; no recursive search'
    sources.append(entry)
out = {
    'scope':'First AT116 synthesized path only; grouping by visible net names, not post-route or per-function delay attribution',
    'timing_report':identity(p), 'slack_ns':-49.011,'data_path_ns':55.661,
    'logic_delay_ns':16.869,'estimated_route_delay_ns':38.792,
    'segments':segments,'sources':sources,
    'design_budget_not_measurement':{
        'snapshot_edge':0,'scan_edges':[1,2,3,4,5,6,7,8],
        'reserve_raw_edge':9,'classify_msb_edge':10,'operand_register_edge':11,
        'earliest_request_fire_edge':12,'next_snapshot_edge':13,
        'saturated_issue_interval_without_service_backpressure':13,
        'max_scale_recip_requests_per_32_group_row':64,
        'max_busy_control_cycles_without_service_backpressure':13*64,
        'two_requests_control_cycles':26,'one_group_min_pack_cycles':34},
    'sampling':{'elapsed_seconds_this_process':time.monotonic()-started,
                'peak_RSS_KiB_self':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                'MemAvailable_KiB_before':mem,'cpu_affinity':sorted(os.sched_getaffinity(0)),
                'nice':os.getpriority(os.PRIO_PROCESS,0),
                'cumulative_unsampled_interactive_cost':'UNKNOWN'}}
Path(__file__).with_name('q_critical_path_partition_20261015.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'segments':segments,'source_AT116_matches':{s['path']:s.get('matches_AT116') for s in sources},'sampling':out['sampling']},ensure_ascii=False))
