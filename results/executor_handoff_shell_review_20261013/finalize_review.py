from pathlib import Path
import json,hashlib,shutil
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2]; OUT=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text())
verified=[]
for ident,reply,parent in [
 ('executor-handoff-shell-review-20261013','results/executor_handoff_shell_reply_20261013.md',OUT),
 ('executor-revoke-unaccepted-action-answer-20261013','results/executor_revoke_unaccepted_action_reply_20261013.md',ROOT/'results/executor_revoke_unaccepted_action_decision_20261013'),
 ('executor-handoff-shell-literal-correction-20261013','results/executor_handoff_shell_review_literal_correction_20261013.md',OUT/'literal_correction')]:
 p=ROOT/'.research-agent/communications'/f'{ident}.json';d=read(p)
 assert d['status']=='delivered' and d['to_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279'
 assert d['from_thread_id']=='01a129af-0395-7fd0-95ac-edd54873bd5f' and d['text']==(ROOT/reply).read_text()
 payload={k:d[k] for k in ['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']}
 assert hashlib.sha256(json.dumps(payload,ensure_ascii=False,sort_keys=True).encode()).hexdigest()==d['payload_sha256']
 parent.mkdir(exist_ok=True);q=parent/'delivery_receipt.json';shutil.copyfile(p,q)
 verified.append(dict(id=ident,status=d['status'],recipient=d['to_thread_id'],reply_to=d['in_reply_to'],reply_file=reply,reply_sha256=sha(ROOT/reply),receipt_sha256=sha(q),payload_sha256=d['payload_sha256'],delivered_at=d['delivered_at']))
check=read(OUT/'organization_check.json');assert check['ok'] and not check.get('broken_links',[])
paths=['results/executor_handoff_shell_review_literal_correction_20261013.md','results/executor_handoff_shell_reply_20261013.md','results/executor_revoke_unaccepted_action_reply_20261013.md','results/executor_revoke_unaccepted_action_contract_20261013.md','results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','.research-agent/discussions.json','communication/index.md']
post=[]
for rel in paths:
 p=ROOT/rel;q=OUT/'post_snapshot'/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);assert sha(p)==sha(q);post.append(dict(path=str(q.relative_to(ROOT)),sha256=sha(q)))
p=OUT/'verification.json';v=read(p);v['delivery_verified']=verified;v['post_snapshots']=post;v['finalized_at']=datetime.now(timezone.utc).isoformat()
for item in v['snapshots']+v['post_snapshots']:assert sha(ROOT/item['path'])==item['sha256']
for item in v['delivered']:assert sha(item['path'])==item['sha256']
assert v['byte_chain']['original_literal_sh']==[1,1] and v['byte_chain']['literal_direct_match_without_modification']
v['organization_check']=dict(path=str((OUT/'organization_check.json').relative_to(ROOT)),sha256=sha(OUT/'organization_check.json'),ok=True)
p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
# Preserve the architecture decision's own delivered message identity.
p2=ROOT/'results/executor_revoke_unaccepted_action_decision_20261013/verification.json';d=read(p2)
for item in d['snapshots']:assert sha(ROOT/item['path'])==item['sha256']
d['delivery_verified']=verified[1];d['finalized_at']=v['finalized_at'];p2.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
final=dict(review_id=v['review_id'],decision=v['decision'],verification_sha256=sha(p),decision_verification_sha256=sha(p2),snapshot_count=len(v['snapshots'])+len(post),messages_verified=len(verified),organization_ok=True,no_controller_dut_run=True,finalized_at=v['finalized_at'])
(OUT/'finalization.json').write_text(json.dumps(final,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(final,ensure_ascii=False,indent=2))
