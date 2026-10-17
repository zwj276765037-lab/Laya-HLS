from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p): return json.loads(Path(p).read_text())
ident='executor-managed-query-review-20261013'
reply=ROOT/'results/executor_managed_query_reply_20261013.md'
receipt=ROOT/'.research-agent/communications'/f'{ident}.json'
d=read(receipt)
assert d['status']=='delivered' and d['to_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279'
assert d['from_thread_id']=='01a129af-0395-7fd0-95ac-edd54873bd5f'
assert d['in_reply_to']=='executor-managed-query-milestone-20261013' and d['text']==reply.read_text()
payload={k:d[k] for k in ['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']}
assert hashlib.sha256(json.dumps(payload,ensure_ascii=False,sort_keys=True).encode()).hexdigest()==d['payload_sha256']
shutil.copyfile(receipt,OUT/'delivery_receipt.json')
check=read(OUT/'organization_check.json');assert check['ok'] and not check.get('broken_links',[])
post=[]
for rel in ['results/executor_managed_query_reply_20261013.md','results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','.research-agent/discussions.json','communication/index.md']:
    p=ROOT/rel;q=OUT/'post_snapshot'/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
    assert sha(p)==sha(q);post.append(dict(path=str(q.relative_to(ROOT)),sha256=sha(q)))
p=OUT/'verification.json';v=read(p)
for item in v['snapshots']+post+v['review_files']:assert sha(ROOT/item['path'])==item['sha256']
for item in v['delivered']:assert sha(item['path'])==item['sha256']
v['delivery_verified']=dict(id=ident,status=d['status'],recipient=d['to_thread_id'],reply_to=d['in_reply_to'],reply_sha256=sha(reply),receipt_sha256=sha(OUT/'delivery_receipt.json'),payload_sha256=d['payload_sha256'],delivered_at=d['delivered_at'],recipient_turn_id=d['recipient_turn_id'])
v['post_snapshots']=post;v['finalized_at']=datetime.now(timezone.utc).isoformat()
v['organization_check']=dict(path=str((OUT/'organization_check.json').relative_to(ROOT)),sha256=sha(OUT/'organization_check.json'),ok=True,warnings=check.get('warnings',[]))
v['controller_script_identities']=[dict(path=str(q.relative_to(ROOT)),sha256=sha(q)) for q in [OUT/'verify_evidence.py',Path(__file__).resolve()]]
p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
final=dict(review_id=v['review_id'],decision=v['decision'],verification_sha256=sha(p),snapshot_count=len(v['snapshots'])+len(post),messages_verified=1,organization_ok=True,no_controller_dut_run=True,finalized_at=v['finalized_at'])
(OUT/'finalization.json').write_text(json.dumps(final,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(final,ensure_ascii=False,indent=2))
