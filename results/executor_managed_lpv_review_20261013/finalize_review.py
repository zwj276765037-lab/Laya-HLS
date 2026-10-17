from pathlib import Path
from datetime import datetime, timezone
import json
import hashlib
import shutil

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent


def read(p):
    return json.loads(Path(p).read_text())


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


check_path = OUT / 'organization_check.json'
check = read(check_path)
assert check['ok'] and not check.get('broken_links', [])
jobs = [(OUT, 'executor-managed-lpv-review-20261013',
         'executor-managed-lpv-milestone-20261013',
         'results/executor_managed_lpv_reply_20261013.md')]
priority_path = OUT / 'executor-minimum-hardware-chain-priority-20261013_receipt.json'
priority = read(priority_path)
assert priority['status']=='delivered' and priority['to_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279'
assert priority['text']==(ROOT/'results/executor_minimum_hardware_chain_priority_20261013.md').read_text()
priority_body={k:priority[k] for k in ['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']}
assert hashlib.sha256(json.dumps(priority_body,ensure_ascii=False,sort_keys=True).encode()).hexdigest()==priority['payload_sha256']
for directory, ident, parent, reply_name in jobs:
    receipt = ROOT / '.research-agent/communications' / (ident + '.json')
    d = read(receipt)
    reply = ROOT / reply_name
    assert d['status'] == 'delivered'
    assert d['to_thread_id'] == '01a129af-29ef-7102-b86a-a43995a36279'
    assert d['from_thread_id'] == '01a129af-0395-7fd0-95ac-edd54873bd5f'
    assert d['in_reply_to'] == parent and d['text'] == reply.read_text()
    payload = {k: d[k] for k in ['from_role', 'from_thread_id', 'to_role',
                               'to_thread_id', 'kind', 'text', 'in_reply_to']}
    assert hashlib.sha256(json.dumps(payload, ensure_ascii=False,
                                    sort_keys=True).encode()).hexdigest() == d['payload_sha256']
    shutil.copyfile(receipt, directory / 'delivery_receipt.json')
    verification = directory / 'verification.json'
    v = read(verification)
    for item in v['snapshots'] + v['review_files']:
        assert sha(ROOT / item['path']) == item['sha256']
    # The engineer continues to edit live sources. Validate the delivered
    # preimage against our independently captured audit snapshot, then report
    # any later live drift separately. Never promote a new live identity.
    snapshots = {item['path']: item['sha256'] for item in v['snapshots']}
    later_drift = []
    for item in v.get('delivered', []):
        original = Path(item['path'])
        suffix = str(original.relative_to(ROOT))
        candidates = [path for path, h in snapshots.items()
                      if path.endswith('/' + suffix) and h == item['sha256']]
        assert candidates
        actual = sha(original)
        if actual != item['sha256']:
            later_drift.append(dict(path=str(original), delivered=item['sha256'],
                                    current=actual, acceptance='not extended'))
    post = []
    for rel in [reply_name, 'results/reviews/SM003.md', 'results/review_queue.md',
                'results/overview.md', 'mission/current.md', 'agent/A001/result.md',
                'agent/A001/state.json', '.research-agent/discussions.json',
                'communication/index.md']:
        source = ROOT / rel
        target = directory / 'post_snapshot' / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        data = source.read_bytes()
        target.write_bytes(data)
        post.append(dict(path=str(target.relative_to(ROOT)), sha256=sha(target)))
    v['post_snapshots'] = post
    v['priority_delivery_verified'] = dict(status='delivered',receipt_sha256=sha(priority_path),payload_sha256=priority['payload_sha256'],delivered_at=priority['delivered_at'],recipient_turn_id=priority['recipient_turn_id'])
    v['delivery_verified'] = dict(id=ident, status='delivered',
        recipient=d['to_thread_id'], reply_to=parent, reply_sha256=sha(reply),
        receipt_sha256=sha(directory / 'delivery_receipt.json'),
        payload_sha256=d['payload_sha256'], delivered_at=d['delivered_at'],
        recipient_turn_id=d['recipient_turn_id'])
    v['post_delivery_live_drift'] = later_drift
    v['organization_check'] = dict(path=str(check_path.relative_to(ROOT)),
        sha256=sha(check_path), ok=True, warnings=check.get('warnings', []))
    v['finalized_at'] = datetime.now(timezone.utc).isoformat()
    v['controller_script_identities'] = [dict(path=str(p.relative_to(ROOT)), sha256=sha(p))
        for p in [OUT / 'verify_evidence.py', Path(__file__).resolve()]]
    verification.write_text(json.dumps(v, ensure_ascii=False, indent=2) + '\n')
    final = dict(review_id=v.get('review_id', v.get('decision_id')),
        decision=v.get('decision', v.get('decision_status')),
        verification_sha256=sha(verification),
        snapshot_count=len(v['snapshots']) + len(post), messages_verified=2,
        organization_ok=True, no_controller_dut_run=True,
        post_delivery_live_drift_count=len(later_drift), finalized_at=v['finalized_at'])
    (directory / 'finalization.json').write_text(json.dumps(final, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(final, ensure_ascii=False))
