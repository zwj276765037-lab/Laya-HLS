from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, re, difflib

R = Path(__file__).resolve().parents[2]
D = Path(__file__).resolve().parent
B = R / 'project/E003_production_chain_closure/experiment_results/runs/R003'

def sha(p):
    with p.open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()

def get(p):
    return json.loads(p.read_text())

def ok(x):
    p = Path(x['path'])
    return p.is_file() and p.stat().st_size == x['bytes'] and sha(p) == x['sha256']

def refs(x, trail=''):
    if isinstance(x, dict):
        if {'path', 'bytes', 'sha256'} <= x.keys():
            yield trail, x
        else:
            for k, v in x.items():
                yield from refs(v, trail + '/' + k)
    elif isinstance(x, list):
        for i, v in enumerate(x):
            yield from refs(v, trail + '/' + str(i))

names = ['executor_wide_fifo_diagnostic_01', 'graph_program_owned_host_07',
         'executor_source_guard_v2_rtl_02']
checks = {}
snaps = []
for name in names:
    p = B / name
    rec = get(p / 'receipt.json')
    man = get(p / 'input_manifest.json')
    pairs = []
    drift = []
    for x in man['files']:
        assert ok(x['frozen']), x['relative']
        assert x['frozen']['sha256'] == x['original']['sha256'], x['relative']
        assert x['frozen']['bytes'] == x['original']['bytes']
        pairs.append(x['relative'])
        if not ok(x['original']):
            drift.append(x['relative'])
    ref_count = 0
    ref_drift = []
    for doc in [rec, man]:
        for trail, x in refs(doc):
            if trail.endswith('/original'):
                continue
            ref_count += 1
            if not ok(x):
                ref_drift.append({'key': trail, 'record': x})
    assert not ref_drift, ref_drift
    guards = []
    for gp in sorted(p.glob('guard_*/guard_result.json')):
        gr = get(gp)
        assert gr['child_exit_code'] == 0 and gr['trigger'] is None
        plan = get(gp.parent / 'guard_plan.json')
        policy_path = gp.parent / 'policy_checks.json'
        policies = get(policy_path) if policy_path.exists() else []
        assert plan['semantic_stall_seconds'] == 120
        assert plan['maximum_owned_rss_kb'] <= 24 * 1024 * 1024
        assert plan['maximum_seconds'] <= 1800
        assert gr['minimum_mem_available_kb'] > 192 * 1024 * 1024
        assert all(x['matches'] and x['affinity'] == [0,1,2,3] and
                   x['nice'] == 19 and x['ionice'] == 'idle' for x in policies)
        guards.append({'directory': gp.parent.name, 'result': gr,
                       'policy_samples': len(policies),
                       'child_policy_observed': bool(policies), 'plan': plan})
        snaps += [gp, gp.parent / 'guard_plan.json']
        if policy_path.exists():
            snaps.append(policy_path)
    checks[name] = {'status': rec['status'], 'frozen_pairs': len(pairs),
                    'current_drift': drift, 'nonoriginal_references_verified': ref_count,
                    'guards': guards}
    snaps += [p / 'receipt.json', p / 'input_manifest.json']

w = get(B / names[0] / 'receipt.json')
assert w['status'] == 'PASS_SCOPED_GENERATION'
pe = w['port_evidence']
assert pe['pass'] and pe['fifo_count'] == 5 and pe['fifo_signal_count'] == 15
top = Path(pe['generated']['path'])
sv = top.read_text()
verified_ports = []
for name, spec in pe['declarations'].items():
    m = re.search(r'^\s*(input|output)\s*(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?' + re.escape(name) + r'\s*;', sv, re.M)
    assert m, name
    width = int(m.group(2)) - int(m.group(3)) + 1 if m.group(2) else 1
    assert m.group(1) == spec['direction'] and width == spec['width']
    verified_ports.append({'name': name, **spec})
assert len(verified_ports) == 17
for row in w['capture_byte_oracle']:
    assert row['complete_bytes_compared'] == 1024
    assert Path(row['actual']['path']).read_bytes() == Path(row['expected']['path']).read_bytes()
reflow = B / names[0] / 'work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.log'
if not reflow.exists():
    reflow = reflow.with_name('a.g.ld.0.bc.clang.reflow.out.log')
reflow_text = reflow.read_text()
events = [s for s in reflow_text.splitlines() if 'Disaggregating' in s and '8192' in s]
checks[names[0]].update({'top_ports': verified_ports, 'top': pe['generated'],
    'full_packet_oracle_pairs': len(w['capture_byte_oracle']),
    'generated_artifact_records': len(w['generated_artifacts']),
    'wide_disaggregate_lines': events,
    'generated_RTL_backpressure': 'NOT_RUN'})
snaps += [top, reflow, Path(w['host']['driver_log']['path']), Path(w['hls']['driver_log']['path'])]

h = get(B / names[1] / 'receipt.json')
assert h['status'] == 'PASS_SCOPED_HOST'
host_cases = {}
for name, op in h['operations'].items():
    if not name.startswith('host_') and not name.startswith('host-'):
        continue
    if name == 'host_build':
        continue
    raw = Path(op['driver_log']['path'])
    assert op['status'] == 'PASS'
    assert op['guard']['child_exit_code'] == 0 and op['guard']['trigger'] is None
    assert all(marker in raw.read_text() for marker in op['markers'])
    host_cases[name] = op['markers']
    snaps.append(raw)
assert len(host_cases) == 10 and 'host_bootstrap-purpose' in host_cases
old = B / 'graph_program_owned_host_05/frozen'
new = B / names[1] / 'frozen'
rel = Path('hls/control/bootstrap_snapshot_protocol.cpp')
a, c = (old / rel).read_text(), (new / rel).read_text()
def body(s, signature):
    start = s.index(signature)
    start = s.index('  const auto& d = r.source;', start)
    end = s.index('\n}', start)
    return s[start:end]
assert body(a, 'Check validate(const Request& r)').replace('r.purpose !=', 'purpose !=') == body(c, 'Check validate_fields(')
assert 'return validate_fields(r, r.purpose);' in c
handoff = Path('hls/control/executor_handoff_protocol.cpp')
assert (old / handoff).read_bytes() == (new / handoff).read_bytes()
checks[names[1]].update({'host_cases': host_cases,
    'bootstrap_validation_body_preserved_except_actual_purpose_parameter': True,
    'outer_handoff_protocol_byte_identical_to_host05': True})
snaps += [old / rel, new / rel, new / handoff, new / 'tests/graph_program_owned_test.cpp']

s = get(B / names[2] / 'receipt.json')
assert s['status'] == 'PASS_SCOPED_RTL_SOURCE_GUARD'
assert len(s['rtl']['case_markers']) == 6 and not s['rtl']['simulator_exception_lines']
assert 'cycles=3214' in s['rtl']['markers'][0]
oldm = get(B / 'executor_source_guard_v2_rtl_01/input_manifest.json')
newm = get(B / names[2] / 'input_manifest.json')
xs = {x['relative']: x for x in oldm['files']}
ys = {x['relative']: x for x in newm['files']}
changes = []
for key in sorted(xs.keys() & ys.keys()):
    if xs[key]['frozen']['sha256'] != ys[key]['frozen']['sha256']:
        aa, cc = Path(xs[key]['frozen']['path']), Path(ys[key]['frozen']['path'])
        changes.append({'relative': key, 'diff': ''.join(difflib.unified_diff(aa.read_text().splitlines(True), cc.read_text().splitlines(True)))})
        snaps += [aa, cc]
assert {Path(x['relative']).name for x in changes} == {'laya_executor_source_guard_v2_tb.sv', 'run_executor_source_guard_v2.py'}
checks[names[2]].update({'case_markers': s['rtl']['case_markers'], 'markers': s['rtl']['markers'],
    'changes_from_01': changes, 'DUT_unchanged': True,
    'full_tensor_same_runtime_LN': 'NOT_RUN'})

# Candidate HLS05 is mutable while running: record a point-in-time observation only.
p5 = B / 'graph_program_owned_hls_05'
m5 = get(p5 / 'input_manifest.json')
hostm = get(B / names[1] / 'input_manifest.json')
map5 = {f['relative']: f['frozen']['sha256'] for f in m5['files']}
maph = {f['relative']: f['frozen']['sha256'] for f in hostm['files']}
assert map5 == maph
for f in m5['files']:
    assert ok(f['frozen'])
checks['graph_program_owned_hls_05_observed'] = {
    'at': datetime.now(timezone.utc).isoformat(),
    'receipt_status': get(p5 / 'receipt.json')['status'],
    'frozen_pairs_equal_host07': len(map5),
    'generation_or_behavior_verdict': 'NOT_REVIEWED'}
snaps += [p5 / 'receipt.json', p5 / 'input_manifest.json', R/'agent/A004/result.md',
    B/'graph_program_owned_rtl_02/receipt.json',
    B/'graph_program_owned_rtl_02/frozen/external/program_rtl/laya_graph_program_owned_sequencer_validate_3.v',
    R/'.research-agent/communications/executor-first-wide-fifo-program-repair-progress-20261013.json']
items = []
for p in dict.fromkeys(snaps):
    rel = p.relative_to(R)
    out = D / 'snapshot' / rel
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(p.read_bytes())
    items.append({'source': str(rel), 'snapshot': str(out.relative_to(R)), 'sha256': sha(out)})
v = {'schema': 1, 'review': 'R-SM003-EXECUTOR-WIDE-FIFO-PROGRAM-REPAIR-20261013',
    'created_at': datetime.now(timezone.utc).isoformat(), 'attempts': checks,
    'no_DUT_tools_run': True, 'snapshots': items,
    'not_independently_recomputed': ['A004 exact AMD pass/root cause and LLVM GEP history',
      'production executor RTL or arithmetic', 'program HLS05 final generation/behavior']}
out = D / 'verification.json'
assert not out.exists()
out.write_text(json.dumps(v, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'frozen_pairs': {n: checks[n]['frozen_pairs'] for n in names},
    'current_drift': {n: checks[n]['current_drift'] for n in names},
    'reference_counts': {n: checks[n]['nonoriginal_references_verified'] for n in names},
    'guards': {n: len(checks[n]['guards']) for n in names},
    'policy_samples': sum(g['policy_samples'] for n in names for g in checks[n]['guards']),
    'snapshots': len(items), 'verification_sha256': sha(out)}, ensure_ascii=False))
