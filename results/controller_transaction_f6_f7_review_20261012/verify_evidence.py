"""Controller read-only evidence audit; does not run engineering tests."""
import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
EXPECTED = {
 'controller_transaction_adapter_10': ('fcf206a5d2a09a19b245a05c19803e7a5a092eb39c44375e1f6e7183accffc7c', 'bcf94858dab63762d2e6fde355e70b017e03260b15f4b447bdc8842ff512a5ca'),
 'controller_transaction_lifecycle_01': ('72348971d0220d72fbc0471b714fd1e392638576518b04c90d27876c24015e03', 'e960e25a8029bb7647ca6ba69759a70bc2d8a057f16a22c459d7da7dc52d9e88'),
 'graph_sequencer_host_03': ('ac4050ab5590a11fc08dea9b073e214006b2b6a0bb340def825c48f00ecb3e15', '4f832597c642753ef8c69a9f3e657d1ee28e549e68b852b8cbbb3a53dbd6800b'),
 'producer_engine_controller_11': ('0eb95d7ee8c5ec3359f3a62865562b10a92760a00762d244fd7e94c4e6674d65', 'b236e6626d2fd577793ef150ab351cbc298835733b976aa7b6f779bd985569a9'),
}


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def refs(value, prefix=''):
    if isinstance(value, dict):
        if 'path' in value and 'sha256' in value:
            yield prefix, value
        for k, v in value.items():
            yield from refs(v, prefix + '/' + str(k))
    elif isinstance(value, list):
        for i, v in enumerate(value):
            yield from refs(v, prefix + '/' + str(i))


report = {'review_id': 'R-SM003-CONTROLLER-TRANSACTION-F6-F7-20261012',
          'checked_at': datetime.now(timezone.utc).isoformat(),
          'scope': 'Frozen evidence and targeted source review only; no dynamic reproduction or tools run',
          'attempts': {}, 'snapshots': []}


def snapshot(path):
    relative = path.relative_to(ROOT)
    target = OUT / 'snapshot' / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        raise RuntimeError('Refuse to overwrite ' + str(target))
    shutil.copyfile(path, target)
    report['snapshots'].append({'source': str(relative),
        'path': str(target.relative_to(ROOT)), 'sha256': sha(target)})


for name in [*EXPECTED, 'controller_transaction_adapter_hls_01']:
    folder = BASE / name
    manifest = json.loads((folder / 'input_manifest.json').read_text())
    receipt = json.loads((folder / 'receipt.json').read_text())
    pairs = []
    for pair in manifest['files']:
        original, frozen = pair['original'], pair['frozen']
        pairs.append({'relative': pair['relative'],
            'current_match': sha(original['path']) == original['sha256'],
            'frozen_match': sha(frozen['path']) == frozen['sha256'],
            'declared_pair_match': original['sha256'] == frozen['sha256']})
    references = []
    for label, data in [('manifest', manifest), ('receipt', receipt)]:
        for key, ref in refs(data, label):
            path = Path(ref['path'])
            if not path.is_absolute():
                path = ROOT / path
            actual = sha(path) if path.is_file() else None
            references.append({'field': key, 'path': str(path),
                'expected': ref['sha256'], 'actual': actual,
                'match': actual == ref['sha256']})
    commands = receipt.get('commands', receipt.get('builds', []) +
                           [receipt[k] for k in ['link', 'execute'] if k in receipt])
    raw_logs = {Path(c['log']['path']).name: Path(c['log']['path']).read_text()
                for c in commands if 'log' in c}
    markers = receipt.get('markers', [line for text in raw_logs.values()
                                     for line in text.splitlines() if '_PASS ' in line])
    actual = [sha(folder / 'input_manifest.json'), sha(folder / 'receipt.json')]
    expected = EXPECTED.get(name, (actual[0], '04a4ff30002a55d98746afa4551a6f43c0fa752fd5f074206f0563993d4969b8'))
    record = {'status': receipt['status'], 'pairs': pairs, 'references': references,
        'manifest_sha256': actual[0], 'receipt_sha256': actual[1],
        'handoff_sha_match': [a == e for a, e in zip(actual, expected)],
        'commands': [{'exit_code': c['exit_code'], 'elapsed_seconds': c.get('elapsed_seconds')} for c in commands],
        'elapsed_seconds': receipt.get('elapsed_seconds', receipt.get('guard_result', {}).get('elapsed_seconds', sum(c.get('elapsed_seconds', 0) for c in commands))),
        'max_rss_kib': receipt.get('max_rss_kib'),
        'markers': markers,
        'marker_matches': [any(marker in text for text in raw_logs.values()) for marker in markers],
        'launcher': json.loads((folder / 'launcher.json').read_text()), 'profile': manifest['profile']}
    record['summary'] = {'pairs': len(pairs),
        'current_matches': sum(p['current_match'] for p in pairs),
        'frozen_matches': sum(p['frozen_match'] for p in pairs),
        'declared_pair_matches': sum(p['declared_pair_match'] for p in pairs),
        'references': len(references), 'reference_matches': sum(r['match'] for r in references),
        'commands': len(commands), 'exit_zero': sum(c['exit_code'] == 0 for c in commands)}
    if name not in EXPECTED:
        record['guard_result'] = receipt['guard_result']
        record['generated_candidates'] = receipt['generated_candidates']
        record['port_evidence'] = receipt['port_evidence']
        snapshot(folder / 'guard/guard_result.json')
        snapshot(folder / 'guard/guard_trigger.json')
    for file in ['input_manifest.json', 'receipt.json', 'launcher.json']:
        snapshot(folder / file)
    for command in commands:
        if 'log' in command and Path(command['log']['path']).stat().st_size:
            snapshot(Path(command['log']['path']))
    report['attempts'][name] = record

for name, paths in {
 'controller_transaction_lifecycle_01': ['hls/control/full_forward_controller.cpp',
    'hls/platform/producer_engine_client.cpp', 'hls/platform/controller_transaction_dispatch.cpp',
    'tests/controller_transaction_lifecycle_test.cpp'],
 'controller_transaction_adapter_10': ['hls/platform/controller_transaction_codec.cpp',
    'tests/controller_transaction_codec_test.cpp', 'tests/controller_transaction_sequencer_codec_test.cpp'],
 'producer_engine_controller_11': ['tests/producer_engine_controller_test.cpp'],
}.items():
    for relative in paths:
        snapshot(BASE / name / 'frozen' / relative)

aggregate = BASE / 'controller_transaction_f6_f7_verification_20261012.json'
snapshot(aggregate)
report['engineering_aggregate_sha_match'] = sha(aggregate) == '25eba1c92d28d047b6f1c0283472110c77d6b89d062ddc6fd9a05c306f66e203'
for relative in ['results/overview.md', 'results/review_queue.md', 'results/reviews/SM003.md',
    'mission/current.md', 'agent/A001/state.json', 'agent/A001/status.md', 'agent/A001/result.md',
    'agent/A002/state.json', 'project/E003_production_chain_closure/experiment_source/summary.md',
    'project/E003_production_chain_closure/experiment_results/summary.md',
    'project/E003_production_chain_closure/experiment_status/summary.md']:
    snapshot(ROOT / relative)
report['host_summary'] = {key: sum(report['attempts'][name]['summary'][key] for name in EXPECTED)
                         for key in report['attempts'][next(iter(EXPECTED))]['summary']}
(OUT / 'verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'host_summary': report['host_summary'],
    'attempts': {n: {'summary': d['summary'], 'elapsed_seconds': d['elapsed_seconds'],
        'handoff_sha_match': d['handoff_sha_match']} for n, d in report['attempts'].items()},
    'engineering_aggregate_sha_match': report['engineering_aggregate_sha_match'],
    'mismatches': [r for d in report['attempts'].values() for r in d['references'] if not r['match']],
    'snapshots': len(report['snapshots'])}, ensure_ascii=False))
