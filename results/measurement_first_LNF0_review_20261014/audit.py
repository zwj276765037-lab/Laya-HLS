"""Controller read-only LNF0 audit. No DUT, reference, or EDA execution."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re, shutil

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUN = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001'
OLD = RUN / 'attempts/AT039_LNF0_ffn4_01'
NEW = RUN / 'attempts/AT040_LNF0_ffn4_02'
QAR = RUN / 'attempts/AT035_QAR0_shared_admission_01'
for name in ['mission/current.md', 'results/overview.md', 'results/hardware_metrics.md',
             'results/hardware_progress.md', 'results/review_queue.md', 'results/reviews/SM005.md',
             'project/missions/SM005.md', 'agent/A001/result.md', 'agent/A001/state.json',
             'NEW_CHAT_START.md']:
    target = OUT / 'prior_records' / name
    target.parent.mkdir(parents=True, exist_ok=True)
    if not target.exists():
        shutil.copy2(ROOT / name, target)

cache, checks = {}, []
def identity(path):
    path = Path(path)
    if str(path) not in cache:
        h = hashlib.sha256()
        size = 0
        with path.open('rb') as f:
            while b := f.read(4 * 1024 ** 2):
                h.update(b)
                size += len(b)
        cache[str(path)] = dict(path=str(path), bytes=size, sha256=h.hexdigest())
    return cache[str(path)]

def check(entry, origin):
    actual = identity(entry['path'])
    ok = all(actual[k] == entry[k] for k in ['bytes', 'sha256'])
    checks.append(dict(origin=origin, expected=entry, actual=actual, match=ok))
    assert ok, origin

def refs(value, origin):
    if isinstance(value, dict):
        if {'path', 'bytes', 'sha256'} <= value.keys():
            check(value, origin)
        else:
            for k, v in value.items(): refs(v, origin + '/' + k)
    elif isinstance(value, list):
        for i, v in enumerate(value): refs(v, origin + '/' + str(i))

manifests, receipts = {}, {}
for attempt in [OLD, NEW]:
    m = json.loads((attempt / 'input_manifest.json').read_text())
    receipt = json.loads((attempt / 'receipt.json').read_text())
    manifests[attempt.name] = m
    receipts[attempt.name] = receipt
    for i, row in enumerate(m['files']):
        check(row['frozen'], attempt.name + '/frozen/' + str(i))
    for field in ['model_identity', 'fixture_inputs', 'fixture_files', 'pilot_fixture_files',
                  'runtime_dat_staging', 'tool']:
        refs(m[field], attempt.name + '/' + field)
    refs(receipt, attempt.name + '/receipt')

old_by_label = {x['label']: x for x in manifests[OLD.name]['files']}
new_by_label = {x['label']: x for x in manifests[NEW.name]['files']}
assert old_by_label.keys() == new_by_label.keys()
changed = [k for k in new_by_label if old_by_label[k]['frozen']['sha256'] != new_by_label[k]['frozen']['sha256']]
assert changed == ['vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/make_layernorm_ffn4_fixture.py']
generated = {k: v for k, v in new_by_label.items() if k.startswith('generated_engine/')}
assert len(generated) == 83
assert sum(k.endswith('.v') for k in generated) == 71
assert sum(k.endswith('.dat') for k in generated) == 7
assert sum(k.endswith('.tcl') for k in generated) == 5
assert generated['generated_engine/laya_layernorm_producer_engine.v']['frozen']['sha256'] == 'b0971fb5569ca6601061d18e04262a4004b493918a48ac3d54db6a22d8610798'

guards = []
for attempt, names in [(OLD, ['static', 'pilot']), (NEW, ['static', 'pilot', 'full'])]:
    for name in names:
        p = attempt / ('guard_' + name)
        plan = json.loads((p / 'guard_plan.json').read_text())
        result = json.loads((p / 'guard_result.json').read_text())
        policy = json.loads((p / 'policy_checks.json').read_text())
        assert plan['maximum_seconds'] == {'static': 1800, 'pilot': 120, 'full': 3600}[name]
        assert plan['maximum_owned_rss_kb'] == (24 if name == 'static' else 8) * 1024 ** 2
        assert plan['semantic_stall_seconds'] == 120 and plan['minimum_mem_available_kb'] == 192 * 1024 ** 2
        assert result['child_exit_code'] == 0 and result['trigger'] is None
        assert policy and all(x['matches'] and x['affinity'] == [0, 1, 2, 3] and x['nice'] == 19
                              and x['ionice'] == 'idle' and x['ionice_exit'] == 0 for x in policy)
        guards.append(dict(attempt=attempt.name, name=name, start=plan['at'], end=result['finished_at'],
                           result=result, policy_samples=len(policy), receipt_status=receipts[attempt.name][name]['status']))
assert all(datetime.fromisoformat(a['end']) < datetime.fromisoformat(b['start']) for a, b in zip(guards, guards[1:]))
assert receipts[OLD.name]['pilot']['status'] == 'FAIL'
assert 'full' not in receipts[OLD.name] and not (OLD / 'guard_full').exists()
old_raw = (OLD / 'guard_pilot/driver.log').read_text()
raw = (NEW / 'guard_full/driver.log').read_text()
assert 'Fatal: provenance response action=3 status=7' in old_raw
assert 'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS' not in old_raw
assert 'Fatal:' not in raw
lines = {k: next(x for x in raw.splitlines() if x.startswith(k)) for k in
         ['LQ0_EVENT', 'LQ0_AXI', 'LQ0_LIFECYCLE', 'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS']}
assert sum(map(int, re.findall(r'phase\d+=(\d+)', lines['LQ0_EVENT']))) == 170031
assert 'source_AR=4 source_R=256 destination_AW=4 destination_W=256 destination_B=4' in lines['FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS']
assert 'quant_AR=4 quant_R=256 fullA_groups=32 cycles=170031' in lines['FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS']
eng = json.loads((NEW / 'verification.json').read_text())
for k, raw_key in [('full_pass_line', 'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS'),
                   ('event_line', 'LQ0_EVENT'), ('axi_line', 'LQ0_AXI'), ('lifecycle_line', 'LQ0_LIFECYCLE')]:
    assert eng[k] == lines[raw_key]
assert all(receipts[NEW.name][n]['status'] == 'PASS' for n in ['static', 'pilot', 'full'])

fixture = json.loads((NEW / 'fixture/fixture.json').read_text())
refs(fixture, 'AT040/fixture')
assert fixture['identity'] == dict(request_id=3, generation=1, B=1, S=128)
assert fixture['owner']['capacity'] == 16920576 and fixture['owner']['base_offset'] == 8388608
assert Path(fixture['source']['path']).read_bytes() == (RUN / 'attempts/AT038_LNREF0_reference_prefix_02/output/enc0_residual_rows4.f32.bin').read_bytes()
assert Path(fixture['gold']['path']).read_bytes() == (QAR / 'frozen/inputs/wi_rows4_source_f32.bin').read_bytes()

# Cross-stage identity incompatibility is a new finding, not an AT040 failure.
sv_path = Path(manifests[NEW.name]['model_identity']['canonical_package']['path'])
canonical = int(re.search(r"L13M_CANONICAL=3328'h([0-9a-fA-F]+)", sv_path.read_text())[1], 16).to_bytes(416, 'little')
m35 = json.loads((QAR / 'input_manifest.json').read_text())
cross_stage = []
for folder in ['wi_w', 'w']:
    path = QAR / 'work/fixtures' / folder / 'model_identity.hex'
    entry = next(x for x in m35['files'] if x['frozen']['path'] == str(path))
    check(entry['frozen'], 'AT035/' + folder + '/model_identity')
    other = int(path.read_text(), 16).to_bytes(416, 'little')
    differences = [i for i, (a, b) in enumerate(zip(canonical, other)) if a != b]
    assert len(differences) == 233 and canonical[:32] == other[:32]
    cross_stage.append(dict(path=str(path), different_bytes=len(differences), offsets=differences,
                            canonical_tags=[canonical[i:i+16].hex() for i in range(0, 64, 16)],
                            QAR_tags=[other[i:i+16].hex() for i in range(0, 64, 16)],
                            first64_equal=canonical[:64] == other[:64],
                            post_tag_schema_equal=canonical[64:] == other[64:]))

result = dict(scope='Controller LNF0 frozen/raw audit and read-only successor identity check',
              at=datetime.now(timezone.utc).isoformat(), references=checks,
              reference_count=len(checks), unique_paths=len(cache), all_references_match=True,
              attempts_frozen_rows=[len(manifests[p.name]['files']) for p in [OLD, NEW]],
              changed_source_labels=changed, LN_generated_files=83, guards=guards,
              guard_count=len(guards), policy_samples=sum(g['policy_samples'] for g in guards),
              AT040_policy_samples=sum(g['policy_samples'] for g in guards if g['attempt'] == NEW.name),
              raw_lines=lines, fixture=fixture, cross_stage_identity=cross_stage,
              verdict='PASS_SCOPED_LNF0; LN-to-QAR0 remains NOT_RUN',
              limitations=['Diagnostic build identity, not original ABI production request',
                          'Terminal scan covers 65536B local destination, not entire STATE0 BO',
                          'Source is readonly TB storage; no independent source DDR terminal scan',
                          'No new full chain, physical timing/resources, or board proof',
                          'AT039 child0 does not override TB fatal/FAIL'])
(OUT / 'verification.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['reference_count', 'unique_paths', 'attempts_frozen_rows',
                                      'LN_generated_files', 'guard_count', 'policy_samples',
                                      'AT040_policy_samples', 'verdict']}, ensure_ascii=False))
