from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, shutil

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def rec(p):
    p = Path(p)
    return dict(path=str(p.relative_to(ROOT)), sha256=sha(p))

v = json.loads((OUT / 'verification.json').read_text())
receipt_path = ROOT / '.research-agent/communications/executor-handoff-actor-host-review-20261013.json'
d = json.loads(receipt_path.read_text())
reply = ROOT / 'results/executor_handoff_actor_host_reply_20261013.md'
assert d['status'] == 'delivered'
assert d['from_thread_id'] == '01a129af-0395-7fd0-95ac-edd54873bd5f'
assert d['to_thread_id'] == '01a129af-29ef-7102-b86a-a43995a36279'
assert d['in_reply_to'] == 'executor-handoff-actor-host-milestone-20261013'
assert d['text'] == reply.read_text()
fields = ['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']
encoded = json.dumps({k:d[k] for k in fields}, sort_keys=True, ensure_ascii=False).encode('utf-8')
assert hashlib.sha256(encoded).hexdigest() == d['payload_sha256']
for p in [receipt_path, reply]:
    dst = OUT / 'snapshot' / p.relative_to(ROOT)
    if not dst.exists():
        dst.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(p, dst)
        v['snapshots'].append(rec(dst))
for p in v['snapshots']: assert sha(ROOT / p['path']) == p['sha256']
check_path = OUT / 'organization_check.json'
check = json.loads(check_path.read_text())
assert check['ok'] and not check['broken_links']
assert v['decision']['overall_acceptance'] is False
records = [reply, ROOT / 'results/reviews/SM003.md', ROOT / 'results/review_queue.md',
           ROOT / 'results/overview.md', ROOT / 'mission/current.md', ROOT / 'agent/A001/result.md',
           ROOT / 'agent/A001/state.json', ROOT / '.research-agent/discussions.json']
v['finalization'] = dict(
    at=datetime.now(timezone.utc).isoformat(), snapshot_integrity_all=True, snapshot_count=len(v['snapshots']),
    delivery={**rec(receipt_path), 'status': d['status'], 'delivered_at': d['delivered_at'],
              'payload_matches_reply': True, 'structured_payload_hash_matches': True},
    organization_check={**rec(check_path), 'ok':True, 'broken_links':[], 'warnings':check['warnings']},
    controller_records=[rec(p) for p in records],
    audit_script=rec(OUT / 'verify_evidence.py'), finalization_script=rec(Path(__file__).resolve()))
(OUT / 'verification.json').write_text(json.dumps(v, ensure_ascii=False, indent=2)+'\n')
print(json.dumps(dict(snapshots=len(v['snapshots']), integrity=True, delivery='verified',
                     organization='ok', F17='open_static_not_dynamically_reproduced',
                     verification=rec(OUT / 'verification.json')), ensure_ascii=False))
