"""Read-only review of two frozen host attempts; no engineering execution."""
import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
BASE = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
EXPECTED = {
    'graph_sequencer_host_02': (
        '7821638bb603945bb122c0f0977721df3136397ef27092e7571ed784f5e183b7',
        '783ba3f6d1a81d1e14d1be45169da293d219447eddc2dcb50efff38391d1b385'),
    'controller_transaction_adapter_09': (
        '17d5adf55c2e7e1f55efc6d47fb73743d0f59aa5a5cb6ef4cee17196ae06054d',
        '6002a91c477960097a0462591f256eb8a0d979784e68db3bdb2593fec4c3cfc5'),
}


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def references(value, prefix=''):
    if isinstance(value, dict):
        if 'path' in value and 'sha256' in value:
            yield prefix, value
        for key, child in value.items():
            yield from references(child, prefix + '/' + str(key))
    elif isinstance(value, list):
        for i, child in enumerate(value):
            yield from references(child, prefix + '/' + str(i))


report = {
    'review_id': 'R-SM003-CONTROLLER-TRANSACTION-SPLIT-HOST-20261012',
    'checked_at': datetime.now(timezone.utc).isoformat(),
    'scope': 'Frozen host records and targeted static source review only; no dynamic reproduction, HLS or RTL execution',
    'attempts': {}, 'snapshots': [],
}


def snapshot(path):
    relative = path.relative_to(ROOT)
    target = OUT / 'snapshot' / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        raise RuntimeError('Do not overwrite existing snapshot: ' + str(target))
    shutil.copyfile(path, target)
    report['snapshots'].append({'source': str(relative),
        'path': str(target.relative_to(ROOT)), 'sha256': sha(target)})


for name, expected in EXPECTED.items():
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
    refs = []
    for label, data in [('manifest', manifest), ('receipt', receipt)]:
        for key, ref in references(data, label):
            path = Path(ref['path'])
            if not path.is_absolute():
                path = ROOT / path
            actual = sha(path) if path.is_file() else None
            refs.append({'field': key, 'path': str(path),
                'expected': ref['sha256'], 'actual': actual,
                'match': actual == ref['sha256']})
    raw_logs = {}
    for command in receipt['commands']:
        log = Path(command['log']['path'])
        raw_logs[log.name] = log.read_text()
    marker_matches = {marker: any(marker in text for text in raw_logs.values())
                      for marker in receipt['markers']}
    data = {
        'manifest_sha256': sha(folder / 'input_manifest.json'),
        'receipt_sha256': sha(folder / 'receipt.json'),
        'handoff_sha_match': [sha(folder / 'input_manifest.json') == expected[0],
                              sha(folder / 'receipt.json') == expected[1]],
        'receipt_status': receipt['status'],
        'pairs': pairs, 'references': refs, 'raw_logs': raw_logs,
        'marker_matches': marker_matches,
        'elapsed_seconds': sum(c['elapsed_seconds'] for c in receipt['commands']),
        'exit_codes': [c['exit_code'] for c in receipt['commands']],
        'launcher': json.loads((folder / 'launcher.json').read_text()),
        'profile': manifest['profile'],
    }
    data['summary'] = {'pairs': len(pairs),
        'current_matches': sum(p['current_match'] for p in pairs),
        'frozen_matches': sum(p['frozen_match'] for p in pairs),
        'declared_pair_matches': sum(p['declared_pair_match'] for p in pairs),
        'references': len(refs), 'reference_matches': sum(r['match'] for r in refs)}
    report['attempts'][name] = data
    for file in ['input_manifest.json', 'receipt.json', 'launcher.json', *raw_logs]:
        snapshot(folder / file)

for name, paths in {
    'graph_sequencer_host_02': [
        'hls/control/full_forward_controller.cpp',
        'hls/platform/producer_engine_client.cpp',
        'hls/platform/generated_provenance_events.cpp',
        'hls/platform/controller_transaction_dispatch.cpp',
        'hls/platform/controller_transaction_hls.cpp',
        'tests/controller_transaction_dispatch_test.cpp',
        'config/graph_sequencer_sources.cmake'],
    'controller_transaction_adapter_09': [
        'hls/platform/controller_transaction_codec.cpp',
        'hls/platform/controller_transaction_adapter.cpp',
        'tests/controller_transaction_adapter_test.cpp',
        'tests/controller_transaction_codec_test.cpp',
        'tests/controller_transaction_sequencer_codec_test.cpp',
        'tests/controller_transaction_oracle.py',
        'include/laya_controller_transaction.h'],
}.items():
    for relative in paths:
        snapshot(BASE / name / 'frozen' / relative)

for relative in ['results/overview.md', 'results/review_queue.md',
    'results/reviews/SM003.md', 'mission/current.md',
    'results/production_hls_partition_contract_20261012.md',
    'agent/A001/state.json', 'agent/A001/status.md', 'agent/A001/result.md',
    'agent/A002/state.json',
    'project/E003_production_chain_closure/experiment_source/summary.md',
    'project/E003_production_chain_closure/experiment_results/summary.md',
    'project/E003_production_chain_closure/experiment_status/summary.md']:
    snapshot(ROOT / relative)

report['summary'] = {key: sum(a['summary'][key] for a in report['attempts'].values())
    for key in ['pairs', 'current_matches', 'frozen_matches',
                'declared_pair_matches', 'references', 'reference_matches']}
report['summary']['snapshots'] = len(report['snapshots'])
(OUT / 'verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'summary': report['summary'],
    'attempts': {name: {'summary': a['summary'], 'elapsed_seconds': a['elapsed_seconds'],
        'handoff_sha_match': a['handoff_sha_match'], 'exit_codes': a['exit_codes'],
        'marker_matches': all(a['marker_matches'].values())}
        for name, a in report['attempts'].items()},
    'mismatches': [ref for a in report['attempts'].values() for ref in a['references'] if not ref['match']]},
    ensure_ascii=False))
