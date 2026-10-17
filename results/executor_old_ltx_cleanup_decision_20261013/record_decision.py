from pathlib import Path
from datetime import datetime,timezone
import hashlib,json
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
def sha(b):return hashlib.sha256(b).hexdigest()
E='project/E002_Laya_HLS/experiment/'
paths=['.research-agent/communications/executor-first-transport-old-ltx-cleanup-question-20261013.json',
'.research-agent/communication.json','results/executor_managed_lpv_owner_contract_20261013.md',
'results/production_hls_partition_contract_20261012.md','results/executor_minimum_hardware_chain_reply_20261013.md',
*[E+x for x in ['hls/control/task_lifecycle_port.cpp','hls/control/task_lifecycle_fsm.cpp',
'include/laya_task_lifecycle_fsm.h','include/laya_controller_transaction.h',
'hls/platform/controller_transaction_adapter.cpp','hls/platform/controller_transaction_codec.cpp',
'hls/platform/producer_engine_client.cpp',
'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_adapter_lpv_owner_v1.sv',
'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_controller_transaction_adapter_shell_v1.sv',
'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_v1.sv']],
'agent/A006/result.md','mission/current.md','results/overview.md','results/review_queue.md','results/reviews/SM003.md','agent/A001/result.md']
items=[];contents={}
for rel in paths:
 b=(R/rel).read_bytes();contents[rel]=b
 p=D/'snapshot'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
 items.append({'source':rel,'snapshot':str(p.relative_to(R)),'sha256':sha(b),'bytes':len(b)})
msg=json.loads(contents[paths[0]]);keys=['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']
assert msg['status']=='delivered' and msg['from_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279'
assert msg['to_thread_id']=='01a129af-0395-7fd0-95ac-edd54873bd5f'
assert sha(json.dumps({k:msg[k] for k in keys},ensure_ascii=False,sort_keys=True).encode())==msg['payload_sha256']
adapter=contents[E+'hls/platform/controller_transaction_adapter.cpp'].decode()
codec=contents[E+'hls/platform/controller_transaction_codec.cpp'].decode()
side=contents[E+'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_adapter_lpv_owner_v1.sv'].decode()
assert 'if (beat == 0) cancel_at_accept = cancel;' in adapter
assert 'request.provenance.action == provenance::Action::RELEASE' in adapter
assert 'FRAME_COMPLETE | LOCAL_REJECT' in codec
assert '!protocol_error && !cancel && !owner_revoked' in side
reply='results/executor_old_ltx_cleanup_contract_20261013.md'; rb=(R/reply).read_bytes();assert len(rb)<=24000
v={'schema':1,'decision':'D-M003-EXECUTOR-OLD-LTX-CLEANUP-01','created_at':datetime.now(timezone.utc).isoformat(),
'scope':'Static interface decision only; no DUT compile/HLS/RTL and no new acceptance of reported progress PASS',
'incoming_payload_sha256':msg['payload_sha256'],'reply':reply,'reply_sha256':sha(rb),'snapshots':items,
'findings':['Machine holds immutable normalized transaction/request packet, scope/task and next-result state from send until actual completion handling.',
'Existing sidecar txn_start_ready blocks sticky cancel/revocation and therefore also prevents old not-yet-popped cleanup.',
'Existing adapter samples cancel only at first LTX pop; managed revocation must persist and cover the pre-external-presentation interval.',
'Legacy adapter cleanup_allowed includes RELEASE; managed candidate whitelist remains precise END/INVALIDATE only.',
'Existing reject_internal/make_local_reject is the transaction negative-response authority; local flags must not assert any remote drain/terminal/publication.',
'Current producer local-reject handling can derive error END, but other FSM remote_bound checks must not be globally weakened.'],
'decision_summary':'Old A/route candidate collection, actual FSM full pending record, unique hub final cleanup decision, actual adapter local rejection for verifiably unissued ordinary transactions; one pending through real 16th LTC consumption.',
'global_status':'C/D NOT_RUN; C009/C013 partial, M003/M004 incomplete; budgets/guards unchanged'}
vp=D/'verification.json';assert not vp.exists();vp.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
section="""## D-M003-EXECUTOR-OLD-LTX-CLEANUP-01：撤销后的旧cleanup首帧

核定旧A/route下单候选24拍LTX收集，实际executor持久Machine transaction/request_packet及原action/scope提供完整待发事实；旧前序route由其真实FSM供给。候选收集不授新业务，撤销下仅完整匹配END/INVALIDATE可向唯一hub尝试；CLAIM-only INVALIDATE不要求BEGIN。sidecar不复制发布/退休权威，不靠裸cleanup bool或清撤销位重开入口。

普通已持有且确实从未对外呈现的事务，由实际adapter原本地拒绝路径形成完整LOCAL_REJECT LTC1，零REMOTE标志，实际16拍消费；未知/部分外发不伪报本地未启动。当前cancel只首拍采样及legacy RELEASE白名单须在managed边界处理，不能仅取消sidecar门控。producer本地拒绝→真实错误END仍由原hub终态唯一退休，其他FSM拒绝分支不得统一冒充remote_terminal。

[补充合同](LINK)与[静态快照](AUDIT)已记录，工程按原授权连续实施，无新增逐项审批。四项工程有限结果未在本接口决定中重审；program动态FAIL不改变旧限定生成事实也不扩大为行为PASS。C旧帧/债务进展必需，完整恢复/D/Q后置；C/D周期NOT_RUN、M003/M004未完成，原帽/预算保持。

"""
def insert(rel,t):
 p=R/rel;old=p.read_text();assert 'D-M003-EXECUTOR-OLD-LTX-CLEANUP-01' not in old
 title,rest=old.split('\n',1);p.write_text(title+'\n\n'+t+rest.lstrip('\n'))
for rel,pre in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
 insert(rel,section.replace('LINK',pre+'executor_old_ltx_cleanup_contract_20261013.md').replace('AUDIT',pre+'executor_old_ltx_cleanup_decision_20261013/verification.json'))
for rel,pre in [('mission/current.md','../results/'),('results/overview.md','')]:
 insert(rel,'最新[旧cleanup首LTX决定]('+pre+'executor_old_ltx_cleanup_contract_20261013.md)（D-M003-EXECUTOR-OLD-LTX-CLEANUP-01）采用旧A/route下真实FSM完整pending候选，END/INVALIDATE最终仍归唯一hub；普通确实未外发事务归实际adapter本地拒绝，LTC实际末拍才收束传输，不伪报远端排空。修复首帧撤销死锁不等于完整恢复前置；program动态失败定位、executor区分实验及C准备继续。C/D周期NOT_RUN、M003/M004未完成，原帽/预算不变。\n\n')
(R/'agent/A001/result.md').write_text("""# 项目主控与架构评判：最新交付

execution_state: completed
stage: old_ltx_cleanup_interface_decided
scope: 撤销后旧END/INVALIDATE首LTX与未外发事务负完成核定

[补充合同](../../results/executor_old_ltx_cleanup_contract_20261013.md)采用旧A/route单候选；完整pending由实际持久FSM提供，唯一hub最终核旧cleanup，不使用裸bool。普通确实未外发事务由实际adapter产生原LOCAL_REJECT LTC1，真实16拍消费，零REMOTE终态标志；已呈现旧帧及债务继续原路径。

静态确认现sidecar撤销关闭所有首拍、adapter只首拍采样cancel且legacy白名单含RELEASE；managed路径须按完整记录收窄，不能仅去掉ready中的cancel。producer本地拒绝可沿原错误END收束，其他FSM分支不伪报远端安全。[证据](../../results/executor_old_ltx_cleanup_decision_20261013/verification.json)仅签接口依据，无新增DUT运行/实现PASS。

工程独立program/executor定位、source guard及C准备继续，不等待完整CLOSED/rearm；本次工程有限milestone没有扩大验收。C/D周期NOT_RUN，C009/C013部分实施、M003/M004未完成，原单重工具/帽/G仅OOC预算保持。
""")
report={'execution_state':'completed','current_task':'核定撤销下旧cleanup首LTX归属和adapter负完成来源','stage':'old_ltx_cleanup_interface_decided','blocker':None,'next_step':'工程按完整pending实施旧cleanup入口与实际adapter有限验证；独立生成和C准备继续','runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'snapshot_count':len(items),'reply_bytes':len(rb),'verification_sha256':sha(vp.read_bytes())},ensure_ascii=False))

