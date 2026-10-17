"""Controller evidence audit only; no DUT compilation or simulation."""
from pathlib import Path
from datetime import datetime, timezone
import ast, difflib, hashlib, json, re, shutil

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUN = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001'
NEW = RUN / 'attempts/AT035_QAR0_shared_admission_01'
OLD = RUN / 'attempts/AT034_QWIGQD0_chain_02'
for name in ['mission/current.md', 'results/overview.md', 'results/hardware_metrics.md',
             'results/hardware_progress.md', 'results/review_queue.md', 'results/reviews/SM005.md',
             'project/missions/SM005.md', 'agent/A001/result.md', 'agent/A001/state.json', 'NEW_CHAT_START.md']:
    dst = OUT / 'prior_records' / name
    dst.parent.mkdir(parents=True, exist_ok=True)
    if not dst.exists():
        shutil.copy2(ROOT / name, dst)

cache = {}
def ident(path):
    p = Path(path)
    if str(p) not in cache:
        b = p.read_bytes()
        cache[str(p)] = dict(path=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
    return cache[str(p)]

checks = []
def check(expected, origin):
    actual = ident(expected['path'])
    match = all(expected[k] == actual[k] for k in ['bytes', 'sha256'])
    checks.append(dict(origin=origin, expected=expected, actual=actual, match=match))
    assert match, origin

def refs(value, origin):
    if isinstance(value, dict):
        if {'path', 'bytes', 'sha256'} <= value.keys():
            check(value, origin)
        else:
            for k, v in value.items(): refs(v, origin + '/' + k)
    elif isinstance(value, list):
        for i, v in enumerate(value): refs(v, origin + '/' + str(i))

manifest = json.loads((NEW / 'input_manifest.json').read_text())
previous = json.loads((OLD / 'input_manifest.json').read_text())
receipt = json.loads((NEW / 'receipt.json').read_text())
for i, row in enumerate(manifest['files']):
    check(row['frozen'], 'AT035/frozen/' + str(i))
refs(receipt, 'AT035/receipt')
oldmap = {str(Path(v['frozen']['path']).relative_to(OLD)):v['frozen']['sha256'] for v in previous['files']}
newmap = {str(Path(v['frozen']['path']).relative_to(NEW)):v['frozen']['sha256'] for v in manifest['files']}
assert set(oldmap) == set(newmap)
changed = [k for k in oldmap if oldmap[k] != newmap[k]]
bridge_path = 'frozen/vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv'
tb_path = 'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv'
assert set(changed) == {bridge_path, tb_path, 'frozen/tools/run_qwigqd0_chain.py'}
assert len(manifest['files']) == 106 and len(newmap) == 104
for name, path in [('bridge', bridge_path), ('TB', tb_path)]:
    old = (OLD / path).read_text(); new = (NEW / path).read_text()
    assert ident(OLD / path)['sha256'] == oldmap[path]
    (OUT / (name + '_diff.txt')).write_text(''.join(difflib.unified_diff(
        old.splitlines(True), new.splitlines(True), fromfile='AT034/' + path, tofile='AT035/' + path)))

guards = []
for phase, entry in receipt['phases'].items():
    g = NEW / ('guard_' + phase)
    plan = json.loads((g / 'guard_plan.json').read_text())
    result = json.loads((g / 'guard_result.json').read_text())
    launch = json.loads((g / 'launch.json').read_text())
    policy = json.loads((g / 'policy_checks.json').read_text())
    assert result == entry['guard'] and entry['status'] == 'PASS'
    assert result['child_exit_code'] == 0 and result['trigger'] is None
    assert plan['maximum_seconds'] == {'static':1800, 'pilot':120, 'full':3600}[phase]
    assert plan['maximum_owned_rss_kb'] == (24 if phase == 'static' else 8) * 1024**2
    assert plan['semantic_stall_seconds'] == 120
    assert plan['minimum_mem_available_kb'] == 192 * 1024**2
    assert all(p['matches'] and p['affinity'] == [0,1,2,3] and p['nice'] == 19
               and p['ionice'] == 'idle' and p['ionice_exit'] == 0 for p in policy)
    guards.append(dict(phase=phase, start=launch['at'], end=result['finished_at'], result=result,
                       policy_count=len(policy), files=[ident(g / x) for x in
                       ['launch.json', 'guard_plan.json', 'guard_result.json', 'policy_checks.json']]))
guards.sort(key=lambda x:x['start'])
assert all(datetime.fromisoformat(a['end']) <= datetime.fromisoformat(b['start'])
           for a, b in zip(guards, guards[1:]))
assert sum(x['policy_count'] for x in guards) == 45

raw = (NEW / 'raw_full.log').read_text(); tb = (NEW / tb_path).read_text()
assert raw.count('QWIGQD0_CHAIN_PASS') == 1 and 'Fatal:' not in raw
assert 'QAR0_dual_valid_G_reject=1 ext_held=1' in raw
assert all(s in tb for s in ['QAR0 dual-valid G priority', 'QAR0 G preempted active external Q',
    'QAR0 waiting G rejection after external Q retirement', 'QAR0 duplicate G rejection',
    'QAR0 external Q preempted G', 'QAR0 waiting external reject after G retirement',
    'QAR0 external rejection not released'])
markers = [l for l in raw.splitlines() if l.startswith(('DOWN_MEASURE_BOUNDARIES', 'DOWN_MEASURE_STATES',
           'QWIGQD0_CHAIN_PASS', 'QWIGQD0_G_COUNTERS', 'WIGQD_BOUNDARIES', 'WIGQD_WI_COMPLETE'))
           or 'QAR0_dual_valid' in l]
sums = [sum(map(int, re.findall(r'\bs\d+=(\d+)', l))) for l in markers if l.startswith('DOWN_MEASURE_STATES')]
assert sums == [46909, 16184]
chain = next(l for l in markers if l.startswith('QWIGQD0_CHAIN_PASS'))
counts = {k:int(v) for k,v in re.findall(r'(\w+)=(\d+)', chain)}
assert counts == dict(source_Q_accept=24, source_AR=4, source_AR_beats=256, source_R=256,
 source_first_AR=27, source_last_AR=712, source_first_R=31, source_last_R=938, source_A_publish=1103,
 gate_W=656, gate_R=656, gate_A_publish=162865, total_quant_groups=328, Down_A_reads=82,
 Down_A_returns=82, Down_AW=256, Down_W=256, Down_B=256, cycle=206136)
guard = ast.parse((NEW / 'frozen/tools/production_guard.py').read_text())
node = next(x for x in ast.walk(guard) if isinstance(x, ast.Assign)
            and any(isinstance(t, ast.Name) and t.id == 'semantic_pattern' for t in x.targets))
pattern = re.compile(ast.literal_eval(node.value.args[0]), re.I)
diags = [l for l in raw.splitlines() if l.startswith('WIGQD_DIAG')]
assert all(not pattern.search(l) for l in diags)

up = ROOT / 'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts'
capture = up / 't2_widown_av_capture_run_01/work/capture/t2_enc0_ln_ffn_source.f32.bin'
source = up / 't2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin'
assert capture.read_bytes()[:16384] == source.read_bytes()
assert ident(capture)['sha256'] == '6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863'
row = next(v for v in manifest['files'] if v['role'] == 'LN_FFN_source_bytes')
assert bytes(int(x,16) for x in Path(row['frozen']['path']).read_text().split()) == source.read_bytes()
schema = ROOT / 'project/E002_Laya_HLS/experiment/include/laya_tasks.h'
assert ident(schema)['sha256'] == '20a8a3a0a94e997c05d0f81657498f16f8d08e406a202eb8b08dde5b2ccd55bf'
result = dict(at=datetime.now(timezone.utc).isoformat(), scope='Read-only controller audit; no DUT tools',
 manifest_rows=106, distinct_frozen_paths=104, reference_count=len(checks), references=checks,
 changed_paths=changed, guard_count=3, policy_count=45, guards=guards, raw_markers=markers,
 state_sums=sums, chain_counts=counts, diagnostic_lines=len(diags), diagnostics_match_guard=False,
 timing=dict(source_Q_accept_to_publish=1079, Wi_cfg_to_consume=46916,
             Down_cfg_to_consume=16191, cold_TB=206136),
 DDR=dict(total=393216, source_read_only=16384, outputs=142336, sentinel=234496),
 scoped_verdict='Accept normal four-row chain and directed admission cases only',
 limits=['No general fairness/interleaving/cancel/recovery proof', 'No new independent EXT_QUANT=0 RTL run',
         'No real LN_FFN producer, full request, joint physical resource or timing result',
         'Cases2/3 asserted in frozen TB, individual acceptance/reject edges not printed'],
 evidence=[ident(x) for x in [NEW/'input_manifest.json', NEW/'receipt.json', NEW/'raw_full.log',
             NEW/bridge_path, NEW/tb_path, schema, capture, source]])
default = RUN / 'attempts/AT036_QAR0_default_static_01'
dm = json.loads((default / 'input_manifest.json').read_text())
dr = json.loads((default / 'receipt.json').read_text())
refs(dm, 'AT036/manifest'); refs(dr, 'AT036/receipt')
dg = default / 'guard_static'
dp = json.loads((dg / 'guard_plan.json').read_text())
dresult = json.loads((dg / 'guard_result.json').read_text())
dl = json.loads((dg / 'launch.json').read_text())
dpolicy = json.loads((dg / 'policy_checks.json').read_text())
assert dresult == dr['phases']['static']['guard'] and dresult['child_exit_code'] == 0 and dresult['trigger'] is None
assert dp['maximum_seconds'] == 1800 and dp['maximum_owned_rss_kb'] == 24 * 1024**2
assert dp['minimum_mem_available_kb'] == 192 * 1024**2 and dp['semantic_stall_seconds'] == 120
assert len(dpolicy) == 31 and all(x['matches'] and x['affinity'] == [0,1,2,3] and x['nice'] == 19
    and x['ionice'] == 'idle' and x['ionice_exit'] == 0 for x in dpolicy)
assert datetime.fromisoformat(guards[-1]['end']) <= datetime.fromisoformat(dl['at'])
dtcl = Path(dm['new_tcl']['path']).read_text(); dlog = (dg / 'driver.log').read_text()
assert 'set_property top geglu_gate_quant_bridge_v1 [get_filesets sim_1]' in dtcl
assert 'launch_simulation -mode behavioral -step elaborate' in dtcl
assert 'generic' not in dtcl.lower()
assert 'Built simulation snapshot geglu_gate_quant_bridge_v1_behav' in dlog and 'QAR0_DEFAULT_STATIC_PASS' in dlog
assert re.search(r'parameter\s+bit\s+WI_PREFILL=1\x27b0,\s*EXT_QUANT=1\x27b0', (NEW / bridge_path).read_text())
result['default_static_addendum'] = dict(status=dr['status'], inherited_rows=len(dm['inherited_files']),
    actual_top='geglu_gate_quant_bridge_v1', default_EXT_QUANT=0, dynamic_G_only_replay='NOT_RUN',
    result=dresult, policy_count=31, evidence=[ident(default / x) for x in ['input_manifest.json','receipt.json']])
result['reference_count'] = len(checks)
result['combined_guard_count'] = 4
result['combined_policy_count'] = 76
(OUT / 'verification.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k:result[k] for k in ['manifest_rows', 'distinct_frozen_paths', 'reference_count',
    'changed_paths', 'guard_count', 'policy_count', 'state_sums', 'timing', 'scoped_verdict']}, ensure_ascii=False))
