"""Read-only controller audit; no compilation, simulation or fixture generation."""
import hashlib
import json
import math
import runpy
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
ATTEMPT = BASE / 'layernorm_producer_portal_06'
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def references(value, key=''):
    if isinstance(value, dict):
        if 'path' in value and 'sha256' in value:
            yield key, value
        for k, v in value.items():
            yield from references(v, key + '/' + str(k))
    elif isinstance(value, list):
        for k, v in enumerate(value):
            yield from references(v, key + '/' + str(k))


m = json.loads((ATTEMPT / 'input_manifest.json').read_text())
r = json.loads((ATTEMPT / 'receipt.json').read_text())
d = {'review_id': 'R-SM003-LAYERNORM-PRODUCER-PORTAL-20261012',
     'checked_at': datetime.now(timezone.utc).isoformat(), 'snapshots': [],
     'pairs': [], 'references': [], 'stages': {}}


def snapshot(p):
    relative = p.relative_to(ROOT)
    target = OUT / 'snapshot' / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    assert not target.exists(), target
    shutil.copyfile(p, target)
    d['snapshots'].append({'source': str(relative),
                          'path': str(target.relative_to(ROOT)), 'sha256': sha(target)})


for pair in m['files']:
    a, b = pair['original'], pair['frozen']
    d['pairs'].append({'label': pair['label'],
        'current_match': sha(a['path']) == a['sha256'],
        'frozen_match': sha(b['path']) == b['sha256'],
        'declared_pair_match': a['sha256'] == b['sha256']})
for label, data in [('manifest', m), ('receipt', r)]:
    for key, ref in references(data, label):
        actual = sha(ref['path']) if Path(ref['path']).is_file() else None
        d['references'].append({'field': key, 'path': ref['path'],
            'expected': ref['sha256'], 'actual': actual, 'match': actual == ref['sha256']})
for stage in ['static', 'pilot', 'full']:
    folder = ATTEMPT / ('guard_' + stage)
    guard = json.loads((folder / 'guard_result.json').read_text())
    plan = json.loads((folder / 'guard_plan.json').read_text())
    policy = json.loads((folder / 'policy_checks.json').read_text())
    log = (folder / 'driver.log').read_text()
    d['stages'][stage] = {'receipt': r[stage], 'guard': guard, 'plan': plan,
        'policy_samples': len(policy), 'policy_all_match': all(x['matches'] for x in policy),
        'markers_in_raw_log': all(marker in log for marker in r[stage]['marker'])}
    for filename in ['guard_result.json', 'guard_plan.json', 'policy_checks.json', 'driver.log']:
        snapshot(folder / filename)

cost = m['cost_decision']
d['cost_check'] = {'manifest_receipt_equal': cost == r['cost_decision'],
    'reference_cycles_match': cost['reference_full_cycles'] == cost['pilot_cycles'] * 16,
    'rate_matches': cost['current_cycles_per_second'] == cost['pilot_cycles'] / cost['pilot_elapsed_seconds'],
    'projection_matches': cost['projected_full_seconds'] == math.ceil(cost['reference_full_cycles'] * 1.5 / cost['current_cycles_per_second']),
    'pilot_finished_before_full_start': r['pilot']['guard']['finished_at'] < d['stages']['full']['plan']['at'],
    'status': cost['status'], 'projected_seconds': cost['projected_full_seconds'],
    'bound_claim': 'row-scaled reference estimate only, not proven complete cycle upper bound'}
identity = m['model_identity']
generator = runpy.run_path(identity['generator']['path'])
d['canonical_identity'] = {
    'selected_engine_header_equal': Path(identity['selected_header']['path']).read_bytes() == Path(identity['engine_header']['path']).read_bytes(),
    'generated_package_equal': generator['generate'](Path(identity['selected_header']['path'])) == Path(identity['canonical_package']['path']).read_text()}
d['rom_staging'] = [{'path': x['staged']['path'],
    'match': sha(x['source']['path']) == sha(x['staged']['path']) == x['source']['sha256'] == x['staged']['sha256']}
    for x in r['runtime_dat_staging']]
gold_manifest = BASE / 'layernorm_producer_hls_01/fixture/manifest.json'
gold = json.loads(gold_manifest.read_text())
d['gold_provenance'] = {'manifest': str(gold_manifest.relative_to(ROOT)),
    'references_match': all(sha(x['path']) == x['sha256'] for _, x in references(gold)),
    'source_equals_checkpoint_first16': Path(gold['source']['path']).read_bytes() == Path(gold['input_checkpoint']['path']).read_bytes()[:16*1024*4],
    'elements': 16384, 'algorithm': gold['algorithm']}
old = json.loads((BASE / 'layernorm_producer_portal_05/input_manifest.json').read_text())
previous = {x['label']: x for x in old['files']}
current = {x['label']: x for x in m['files']}
d['delta_05_to_06'] = {'common': len(previous.keys() & current.keys()),
    'changed': [k for k in previous.keys() & current.keys() if previous[k]['frozen']['sha256'] != current[k]['frozen']['sha256']],
    'previous_frozen_matches': sum(sha(x['frozen']['path']) == x['frozen']['sha256'] for x in old['files'])}
d['historical_receipts'] = {}
for i in range(1, 6):
    p = BASE / f'layernorm_producer_portal_{i:02d}' / 'receipt.json'
    data = json.loads(p.read_text())
    d['historical_receipts'][p.parent.name] = {'sha256': sha(p),
        'stages': {key: value for key, value in data.items() if key in ['static', 'pilot', 'full']}}
    snapshot(p)

for p in [ATTEMPT/'input_manifest.json', ATTEMPT/'receipt.json', ATTEMPT/'launcher.json', gold_manifest,
    BASE/'layernorm_producer_portal_verification_20261012.json',
    BASE/'layernorm_producer_hls_01/frozen/hls/operators/layernorm_producer_engine.cpp',
    BASE/'layernorm_producer_hls_01/frozen/hls/platform/producer_engine_codec.cpp',
    BASE/'layernorm_producer_hls_01/frozen'/MODULE/'tb/make_layernorm_producer_fixture.py',
    ATTEMPT/'frozen'/MODULE/'rtl/laya_layernorm_producer_portal_shell_v1.sv',
    ATTEMPT/'frozen'/MODULE/'tb/laya_layernorm_producer_portal_shell_tb_v1.sv',
    ATTEMPT/'frozen'/MODULE/'tb/make_layernorm_producer_portal_fixture.py',
    ATTEMPT/'frozen'/MODULE/'tb/run_layernorm_producer_portal_shell_v1.py',
    ATTEMPT/'frozen/tools/generate_laya_model_identity_sv.py']:
    snapshot(p)
for name in ['results/overview.md', 'results/reviews/SM003.md', 'results/review_queue.md', 'mission/current.md',
    'agent/A001/result.md', 'agent/A001/status.md', 'agent/A001/state.json', 'agent/A002/state.json',
    'project/E003_production_chain_closure/experiment_source/summary.md',
    'project/E003_production_chain_closure/experiment_results/summary.md',
    'project/E003_production_chain_closure/experiment_status/summary.md']:
    snapshot(ROOT / name)
d['handoff_sha_matches'] = [
    sha(ATTEMPT/'input_manifest.json') == '83aa4a3446f0886dd72be6ea3b675b2346d853a96d06139f5c8a9e3a417b48d9',
    sha(ATTEMPT/'receipt.json') == '7b7347fc6f8f5e81b06ce8330430c938889318f5671d0de57672b138dd807ded',
    sha(BASE/'layernorm_producer_portal_verification_20261012.json') == 'f4baaafdd5ec9d0efd75e64b7b0056d6addce6718a28390a9e31e642d9eadca7']
d['summary'] = {'pairs': len(d['pairs']),
    'current_matches': sum(x['current_match'] for x in d['pairs']),
    'frozen_matches': sum(x['frozen_match'] for x in d['pairs']),
    'declared_pair_matches': sum(x['declared_pair_match'] for x in d['pairs']),
    'references': len(d['references']), 'reference_matches': sum(x['match'] for x in d['references']),
    'snapshots': len(d['snapshots'])}
(OUT/'verification.json').write_text(json.dumps(d, ensure_ascii=False, indent=2)+'\n')
print(json.dumps({key:d[key] for key in ['summary','handoff_sha_matches','cost_check','canonical_identity','gold_provenance','delta_05_to_06']},ensure_ascii=False))
