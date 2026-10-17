from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re, difflib

R = Path(__file__).resolve().parents[2]
D = Path(__file__).resolve().parent
B = R / 'project/E005_full_request_performance/experiment_results/runs/R001'
def get(p): return json.loads(p.read_text())
def sha(p):
    with p.open('rb') as f: return hashlib.file_digest(f, 'sha256').hexdigest()
def check(x):
    p = Path(x['path'])
    if not p.is_absolute(): p = R / p
    assert p.is_file() and sha(p) == x['sha256'], str(p)
    if 'bytes' in x: assert p.stat().st_size == x['bytes'], str(p)
    return p

verification = get(B / 'reports/KB0_KB1_Down_verification_20261013.json')
assert len(verification['files']) == 141
for x in verification['files']: check(x)
receipts, manifests, values, dirs, intervals = [], [], [], [], []
policy_count = 0
for label, attempt, cmd_cycles, consume_cycles, finish, beats in [
    ('KB0', 'AT001_KB0_resident_Down_measurement', 21100, 21107, 48864, 512),
    ('KB1', 'AT002_KB1_Down_rowpack', 16183, 16190, 43947, 256),
]:
    p = B / 'attempts' / attempt / 'evidence/measurement'; dirs.append(p)
    receipt, manifest, v = (get(p / n) for n in ['receipt.json', 'input_manifest.json', 'measurement_full.json'])
    receipts.append(receipt); manifests.append(manifest); values.append(v)
    assert receipt['status'] == f'PASS_SCOPED_{label}_DOWN_MEASUREMENT'
    check(receipt['input_manifest'])
    assert manifest['label'] == label and not manifest['baseline_live_sources_used']
    assert len(manifest['files']) == 26 and len(manifest['fixture_files']) == 12
    for x in manifest['files']: check(x['frozen'])
    for x in manifest['fixture_files']: check(x['frozen'])
    for x in receipt['native_ip']: check(x)
    for name, phase in receipt['phases'].items():
        assert phase['status'] == 'PASS' and phase['guard']['child_exit_code'] == 0 and phase['guard']['trigger'] is None
        body = check(phase['driver_log']).read_text()
        assert all(marker in body for marker in phase['marker']) and 'Fatal:' not in body
        for k in ['raw_log', 'measurement']:
            if k in phase: check(phase[k])
    assert receipt['phases']['pilot']['guard']['elapsed_seconds'] <= 120
    assert receipt['phases']['full']['guard']['elapsed_seconds'] < receipt['full_cost_estimate_before_launch']['estimate_seconds'] < 3600
    raw = (p / 'raw_full.log').read_text()
    for name in ['boundaries', 'states', 'overlap', 'front', 'load', 'output']:
        line = next(s for s in raw.splitlines() if s.startswith('DOWN_MEASURE_' + name.upper() + ' '))
        fields = {k: int(s) if re.fullmatch(r'-?\d+', s) else s for k, s in re.findall(r'(\w+)=([^ ]+)', line)}
        assert fields == v[name], (label, name)
    bound, out = v['boundaries'], v['output']
    assert sum(v['state_cycles_exclusive'].values()) == v['states']['cycles'] == bound['first_done_valid'] - bound['cfg_accept'] == cmd_cycles
    assert bound['actual_done_consume'] - bound['cfg_accept'] == consume_cycles
    assert bound['actual_done_consume'] - bound['first_done_valid'] == out['done_not_ready_edges'] == 7
    assert bound['finish'] == finish and bound['W_publish_post_NBA'] < bound['cfg_accept']
    assert out['actual_done_consumes'] == 1 and out['actual_AW'] == out['actual_W'] == out['actual_B'] == beats
    assert out['useful_strobe_bytes'] == 16384 and out['physical_W_bytes'] == beats * 64
    for gp in p.glob('guard_*/guard_result.json'):
        g, plan, policies = (get(gp.parent / n) for n in ['guard_result.json', 'guard_plan.json', 'policy_checks.json'])
        assert g['child_exit_code'] == 0 and g['trigger'] is None
        assert g['minimum_mem_available_kb'] > 192 * 1024 * 1024 and plan['semantic_stall_seconds'] == 120
        assert all(x['matches'] and x['affinity'] == [0, 1, 2, 3] and x['nice'] == 19 and x['ionice'] == 'idle' for x in policies)
        policy_count += len(policies)
        intervals.append({'label': label, 'phase': gp.parent.name, 'start': get(gp.parent / 'launch.json')['at'], 'end': g['finished_at']})

def source_map(m): return {x['baseline']['path']: x['frozen'] for x in m['files']}
s0, s1 = map(source_map, manifests)
assert s0.keys() == s1.keys()
changed = [k for k in s0 if s0[k]['sha256'] != s1[k]['sha256']]
assert len(changed) == 1 and changed[0].endswith('/tm4tn8_axi512_writer_v1.sv')
assert [x['frozen']['sha256'] for x in manifests[0]['fixture_files']] == [x['frozen']['sha256'] for x in manifests[1]['fixture_files']]
assert [x['sha256'] for x in receipts[0]['native_ip']] == [x['sha256'] for x in receipts[1]['native_ip']]
for k in ['runner', 'derived_TB', 'guard', 'guard_helpers']:
    def hashes(x):
        if isinstance(x, dict):
            if 'sha256' in x: return [x['sha256']]
            return sum((hashes(v) for v in x.values()), [])
        return []
    assert hashes(manifests[0][k]) == hashes(manifests[1][k]), k
tb_path = next(check(x['frozen']) for x in manifests[1]['files'] if x['frozen']['path'].endswith('tm4tn8_matrix_resident_tb_v2.sv'))
tb = tb_path.read_text()
for token in ['dut.commit_ps[r*256+:256]!==vps[seq][r*256+:256]', 'output_seen[idx+lane]', 'wd_data[lane*32+:32]!==outgold[idx+lane]', 'actual_ps_commits!=41984', 'actual_final_copies!=512', 'output_words!=4096', 'ledger_parent_publications!=1', '!ledger_retire_debt_zero', 'cycle%7!=0', 'cycle%11!=0', '17+(output_beats%3)', 'cycle%5!=pp']:
    assert token in tb, token
e0, e1 = [Path(m['static_entry']['derived']['path']).read_text() for m in manifests]
diff = ''.join(difflib.unified_diff(e0.splitlines(True), e1.splitlines(True)))
assert e0.replace('EXPECTED_OUTPUT_BEATS=512', 'EXPECTED_OUTPUT_BEATS=256') == e1, diff
intervals.sort(key=lambda x: x['start'])
assert len(intervals) == 6 and policy_count == 95
assert all(a['end'] <= b['start'] for a, b in zip(intervals, intervals[1:]))
comparison = get(B / 'reports/KB0_KB1_Down_comparison_20261013.json')
for entry in comparison['latency']:
    a, b = [v['latency_cycles'][entry['metric']] for v in values]
    assert (entry['KB0'], entry['KB1'], entry['difference_KB1_minus_KB0']) == (a, b, b-a)
    assert abs(entry['reduction_percent'] - 100*(a-b)/a) < 1e-9
bound_doc = get(B / 'reports/KB1_W_load_service_bound_20261013.json')
for x in bound_doc['evidence'].values(): check(x)
n = values[1]['load']['q0_R']
assert n == values[1]['load']['q1_R'] == 20992
lower = n + (n-1)//4
assert lower == 26239 == bound_doc['derived']['q0_or_q1_optimistic_minimum_service_span_cycles']
assert 27064 - lower == 825
assert sum(values[1]['load'][k] for k in ['q0_R', 'q1_R', 'scale_R'])*64 == 2854912
output_bound = get(B / 'reports/KB1_output_service_bound_20261013.json')
for x in output_bound['evidence'].values(): check(x)
assert sum(17+i%3 for i in range(1,257)) == values[1]['output']['TB_B_delay_decrements'] == 4608
assert values[1]['boundaries']['last_B']-values[1]['boundaries']['first_AW'] == 4927
assert output_bound['derived']['measured_output_interval_above_delay_decrements'] == 4927-4608 == 319
source_paths = [R/'project/E002_Laya_HLS/experiment/include/laya_full_runtime.h', R/'project/E002_Laya_HLS/experiment/hls/common/laya_full_owner.cpp']
snapshots = []
paths = [B/'reports'/n for n in ['KB0_KB1_Down_comparison_20261013.json','KB0_KB1_Down_verification_20261013.json','KB1_W_load_service_bound_20261013.json','KB1_output_service_bound_20261013.json']] + source_paths
paths += [p/n for p in dirs for n in ['receipt.json','input_manifest.json','measurement_full.json','raw_full.log']]
for p in paths:
    q = D/'snapshot'/p.relative_to(R); q.parent.mkdir(parents=True,exist_ok=True); q.write_bytes(p.read_bytes())
    snapshots.append({'source':str(p.relative_to(R)), 'snapshot':str(q.relative_to(R)), 'sha256':sha(q)})
result = {'review':'R-SM005-KB1-20261013','at':datetime.now(timezone.utc).isoformat(),'referenced_files_rehashed':141,'source_count_each':26,'only_changed_source':changed[0],'same_fixtures':12,'same_native_IPs':3,'raw_six_groups_match_each':True,'same_TB_runner_guards':True,'static_entry_difference':diff,'serial_guard_intervals':intervals,'actual_policy_records':policy_count,'first_done_latency':[21100,16183],'actual_consume_latency':[21107,16190],'cold_TB_cycles':[48864,43947],'latency_saved_cycles':4917,'consume_reduction_percent':100*4917/21107,'cold_reduction_percent':100*4917/48864,'W_service_lower_bound':lower,'reader_only_idealized_room':825,'reader_only_max_cold_reduction_percent':100*825/43947,'snapshots':snapshots,'no_DUT_tools_run':True}
(D/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['snapshots','serial_guard_intervals','static_entry_difference']},ensure_ascii=False))
