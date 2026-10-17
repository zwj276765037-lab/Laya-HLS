"""Controller read-only audit; no compilation, simulation or fixture generation."""
import hashlib
import json
import math
import runpy
import shutil
import struct
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
NAMES = ['layernorm_quant_source_03', 'gate_split_cost_guard_01',
         'generated_store_monitor_09', 'layernorm_producer_portal_07']
MODULE = Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
D = {'review_id': 'R-SM003-LAYERNORM-QUANT-SOURCE-F9-20261012',
     'checked_at': datetime.now(timezone.utc).isoformat(), 'attempts': {}, 'snapshots': []}

def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def refs(x, key=''):
    if isinstance(x, dict):
        if 'path' in x and 'sha256' in x:
            yield key, x
        for k, v in x.items():
            yield from refs(v, key + '/' + str(k))
    elif isinstance(x, list):
        for k, v in enumerate(x):
            yield from refs(v, key + '/' + str(k))

def snapshot(p):
    rel = p.relative_to(ROOT)
    dst = OUT / 'snapshot' / rel
    if dst.exists():
        assert sha(dst) == sha(p), p
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(p, dst)
    D['snapshots'].append({'source': str(rel), 'path': str(dst.relative_to(ROOT)), 'sha256': sha(dst)})

for name in NAMES:
    folder = BASE / name
    m = json.loads((folder / 'input_manifest.json').read_text())
    r = json.loads((folder / 'receipt.json').read_text())
    a = {'manifest_sha256': sha(folder/'input_manifest.json'),
         'receipt_sha256': sha(folder/'receipt.json'), 'pairs': [], 'references': [], 'stages': {}}
    for p in m['files']:
        x, y = p['original'], p['frozen']
        a['pairs'].append({'path': x['path'], 'current_match': sha(x['path']) == x['sha256'],
            'frozen_match': sha(y['path']) == y['sha256'], 'declared_pair_match': x['sha256'] == y['sha256']})
    for label, obj in [('manifest', m), ('receipt', r)]:
        for field, ref in refs(obj, label):
            actual = sha(ref['path']) if Path(ref['path']).is_file() else None
            a['references'].append({'field': field, 'path': ref['path'], 'expected': ref['sha256'],
                                    'actual': actual, 'match': actual == ref['sha256']})
    for log in sorted(folder.glob('guard*/driver.log')):
        gdir = log.parent
        plan = json.loads((gdir/'guard_plan.json').read_text())
        guard = json.loads((gdir/'guard_result.json').read_text())
        policy = json.loads((gdir/'policy_checks.json').read_text())
        stage = gdir.name.removeprefix('guard_')
        markers = r.get(stage, r).get('marker', [])
        if isinstance(markers, str):
            markers = [markers]
        static = stage == 'static' or name == 'generated_store_monitor_09'
        a['stages'][stage] = {'plan': plan, 'guard': guard,
            'policy_count': len(policy), 'policy_all_match': bool(policy) and all(x['matches'] for x in policy),
            'markers': markers, 'markers_in_log': bool(markers) and all(x in log.read_text() for x in markers),
            'caps_ok': plan['maximum_owned_rss_kb'] <= (24 if static else 8)*1024**2
                and plan['maximum_seconds'] <= (1800 if static else 3600 if stage == 'full' else 120)
                and plan['semantic_stall_seconds'] == 120
                and plan['selected_cpu_ids'] == [0,1,2,3]
                and plan['minimum_mem_available_kb'] >= 192*1024**2,
            'result_ok': guard['child_exit_code'] == 0 and guard['trigger'] is None
                and guard['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb']
                and guard['elapsed_seconds'] <= plan['maximum_seconds']}
        for file in ['guard_result.json', 'guard_plan.json', 'policy_checks.json', 'driver.log']:
            snapshot(gdir/file)
    a['summary'] = {'pairs': len(a['pairs']),
        'current_matches': sum(x['current_match'] for x in a['pairs']),
        'frozen_matches': sum(x['frozen_match'] for x in a['pairs']),
        'declared_pair_matches': sum(x['declared_pair_match'] for x in a['pairs']),
        'references': len(a['references']), 'reference_matches': sum(x['match'] for x in a['references'])}
    D['attempts'][name] = a
    snapshot(folder/'input_manifest.json')
    snapshot(folder/'receipt.json')

folder = BASE/NAMES[0]
m = json.loads((folder/'input_manifest.json').read_text())
r = json.loads((folder/'receipt.json').read_text())
cost = m['cost_decision']
D['cost'] = {'manifest_receipt_equal': cost == r['cost_decision'],
    'row_reference_match': cost['producer_reference_cycles'] == cost['pilot_cycles']*16,
    'total_reference_match': cost['reference_full_cycles'] == cost['producer_reference_cycles']+512*512,
    'rate_match': cost['current_cycles_per_second'] == cost['pilot_cycles']/cost['pilot_elapsed_seconds'],
    'projection_match': cost['projected_full_seconds'] == math.ceil(cost['reference_full_cycles']*1.5/cost['current_cycles_per_second']),
    'pilot_before_full': r['pilot']['guard']['finished_at'] < D['attempts'][NAMES[0]]['stages']['full']['plan']['at'],
    'decision': cost, 'limit': 'reference estimate; Q allowance is not measured throughput or proven upper bound'}
identity = m['model_identity']
gen = runpy.run_path(identity['generator']['path'])
D['canonical'] = {'header_equal': Path(identity['selected_header']['path']).read_bytes() == Path(identity['engine_header']['path']).read_bytes(),
    'package_equal': gen['generate'](Path(identity['selected_header']['path'])) == Path(identity['canonical_package']['path']).read_text()}
D['rom_staging'] = [{'path': x['staged']['path'], 'match': sha(x['source']['path']) == sha(x['staged']['path']) == x['source']['sha256'] == x['staged']['sha256']} for x in r['runtime_dat_staging']]
q = json.loads((folder/'fixture/quant_gold.json').read_text())
g = json.loads((BASE/'layernorm_producer_hls_01/fixture/manifest.json').read_text())
words = struct.unpack('<16384I', (folder/'fixture/gold_rows16.f32.bin').read_bytes())
D['gold'] = {'quant_manifest': q,
    'quant_references_match': all(sha(x['path']) == x['sha256'] for _,x in refs(q)),
    'unique_f32_words': len(set(words)),
    'ln_gold_equal_frozen_oracle': (folder/'fixture/gold_rows16.f32.bin').read_bytes() == Path(g['gold']['path']).read_bytes() if 'gold' in g else None,
    'source_checkpoint_first16_equal': (folder/'fixture/source_rows16.f32.bin').read_bytes() == Path(g['input_checkpoint']['path']).read_bytes()[:65536],
    'ln_manifest_references_match': all(sha(x['path']) == x['sha256'] for _,x in refs(g))}
D['gate_cost_runner'] = {'scope': 'pure decision receipt and static caller integration only; no new real full run',
    'receipt': json.loads((BASE/NAMES[1]/'receipt.json').read_text())}
D['historical'] = {}
for name in ['layernorm_quant_source_01', 'layernorm_quant_source_02']:
    p=BASE/name/'receipt.json'
    rr=json.loads(p.read_text())
    D['historical'][name]={'sha256':sha(p), 'stages': {k:rr[k] for k in ['static','pilot','full'] if k in rr}}
    snapshot(p)
old = json.loads((BASE/'layernorm_quant_source_02/input_manifest.json').read_text())
before = {x['label']: x['frozen']['sha256'] for x in old['files']}
after = {x['label']: x['frozen']['sha256'] for x in m['files']}
D['delta_02_to_03'] = {'common':len(before.keys() & after.keys()),
    'changed':[k for k in before.keys() & after.keys() if before[k] != after[k]]}
for rel in ['results/overview.md','results/reviews/SM003.md','results/review_queue.md','mission/current.md',
    'agent/A001/result.md','agent/A001/status.md','agent/A001/state.json','agent/A002/state.json',
    'project/E003_production_chain_closure/experiment_source/summary.md',
    'project/E003_production_chain_closure/experiment_results/summary.md',
    'project/E003_production_chain_closure/experiment_status/summary.md']:
    snapshot(ROOT/rel)
for rel in ['rtl/laya_layernorm_producer_portal_shell_v1.sv','rtl/laya_layernorm_quant_source_shell_v1.sv',
    'rtl/laya_generated_provenance_axi_portal_v1.sv','tb/laya_layernorm_quant_source_shell_tb_v1.sv',
    'tb/make_layernorm_quant_gold.py','tb/run_layernorm_quant_source_shell_v1.py']:
    snapshot(folder/'frozen'/MODULE/rel)
for p in [folder/'fixture/quant_gold.json', BASE/'layernorm_producer_hls_01/fixture/manifest.json',
    BASE/'layernorm_quant_source_verification_20261012.json',BASE/'layernorm_portal_compatibility_verification_20261012.json',
    BASE/NAMES[1]/'frozen/run_geglu_gate_quant_split_v2.py']:
    snapshot(p)
D['handoff_sha_matches'] = [sha(folder/'input_manifest.json') == '5766e20da355a23c10c734613a0bf4c5233baa46d480d3a9def32d24b50dd66f',
    sha(folder/'receipt.json') == 'ad6e5d6cf65c733ccfbd3dabf1e7e5403f7ee7abfe89a6fbd2c9667e2be86dd0',
    sha(BASE/'layernorm_quant_source_verification_20261012.json') == 'c775b3739a01b1692b8b3138932e42349ebcbe7cb3a68e59154b07f7e7ef313d']
D['total'] = {k:sum(a['summary'][k] for a in D['attempts'].values()) for k in D['attempts'][NAMES[0]]['summary']}
(OUT/'verification.json').write_text(json.dumps(D,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'total':D['total'],'attempts':{n:a['summary'] for n,a in D['attempts'].items()},
    'mismatches':[x for a in D['attempts'].values() for x in a['references'] if not x['match']],
    'stage_checks':{n:{s:{k:v[k] for k in ['policy_all_match','markers_in_log','caps_ok','result_ok']} for s,v in a['stages'].items()} for n,a in D['attempts'].items()},
    'canonical':D['canonical'],'gold':{k:v for k,v in D['gold'].items() if k!='quant_manifest'},
    'handoff_sha_matches':D['handoff_sha_matches'],'delta_02_to_03':D['delta_02_to_03']},ensure_ascii=False))
