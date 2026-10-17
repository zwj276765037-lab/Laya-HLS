from pathlib import Path
from datetime import datetime, timezone
import hashlib, json
R=Path(__file__).resolve().parents[2]
D=Path(__file__).resolve().parent
def sha(b): return hashlib.sha256(b).hexdigest()
def put(p,obj): p.parent.mkdir(parents=True,exist_ok=True); p.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n')
assert not (D/'verification.json').exists(), 'Preserve original decision snapshot'
src='project/E002_Laya_HLS/experiment/'
paths=[
'.research-agent/communication.json',
'.research-agent/communications/executor-first-baseline-program-q-question-20261013.json',
'results/executor_minimum_hardware_chain_reply_20261013.md',
'results/production_hls_partition_contract_20261012.md',
'results/executor_bootstrap_source_contract_20261012.md',
'agent/A004/result.md',
*[src+p for p in [
'include/laya_graph_program_protocol.h','include/laya_graph_action_protocol.h',
'include/laya_graph_program_sequencer.h','include/laya_task_lifecycle_fsm.h',
'hls/control/graph_program_protocol.cpp','hls/control/graph_program_sequencer.cpp',
'hls/control/graph_program_hls.cpp','hls/control/graph_action_protocol.cpp',
'hls/control/program_pending_protocol.cpp','hls/control/task_lifecycle_fsm.cpp',
'hls/control/task_lifecycle_executor.cpp','hls/control/full_forward_controller.cpp',
'hls/platform/compute_portal_commit.cpp'
]],
'mission/current.md','results/overview.md','results/review_queue.md',
'results/reviews/SM003.md','agent/A001/result.md']
items=[]
for rel in paths:
    b=(R/rel).read_bytes()
    p=D/'snapshot'/rel
    p.parent.mkdir(parents=True,exist_ok=True); p.write_bytes(b)
    assert sha(p.read_bytes())==sha(b)
    items.append({'source':rel,'snapshot':str(p.relative_to(R)),'sha256':sha(b),'bytes':len(b)})
incoming=json.loads((R/paths[1]).read_text())
keys=['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']
digest=sha(json.dumps({k:incoming[k] for k in keys},ensure_ascii=False,sort_keys=True).encode())
assert digest==incoming['payload_sha256']
assert incoming['status']=='delivered'
assert incoming['from_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279'
assert incoming['to_thread_id']=='01a129af-0395-7fd0-95ac-edd54873bd5f'
reply='results/executor_first_baseline_program_q_reply_20261013.md'
body=(R/reply).read_text()
assert len(body.encode())<=24000
put(D/'verification.json', {
'schema':1,'decision':'D-M003-FIRST-BASELINE-PROGRAM-Q-01',
'created_at':datetime.now(timezone.utc).isoformat(),
'scope':'Static interface decision; no DUT compilation, simulation or HLS; not dynamic PASS',
'incoming_payload_sha256':digest,'incoming_delivery_verified':True,
'reply':reply,'reply_sha256':sha(body.encode()),'snapshot_pairs':len(items),'files':items,
'findings':[
'LGP entrypoint 1 and current FSM only support NORM; original LINEAR loads weight before Q and MATRIX.',
'Explicit entrypoint 2 approved for complete declared NORM then original LINEAR prefix through first Q; held nonterminal boundary, no successful LINEAR or request completion.',
'No new action kind; bind capability to actual admitted A/K and echoed command, confirmed NORM output and actual LAC tail consumer.',
'Logical slot version and Ref.epoch are independent; three equality checks found in program codec, finite FSM and synchronous executor.',
'Complete confirmed slot/owner mapping plus live owner proof is required, not merely removal of equality.',
'program_pending validator is currently fixed to pc0 NORM; new pc1 pending needs complete binding and confirmed source.',
'commit_load/commit_quant already retire; real response and debt checks must precede helpers, and complete P/Q metadata retained.'
],
'engineering_host_02_claim':'Seven process scoped host PASS reported; not audited here',
'hardware_status':'Executor generation and C/D hardware proof pending per incoming message',
'global_status':'M003/M004 incomplete; C009/C013 awaiting_implementation; no scope or budget expansion'
})
review="""## D-M003-FIRST-BASELINE-PROGRAM-Q-01：实际program的首窗Q测量入口

接纳LGP1明确诊断entrypoint2，保留version1/256B布局，原入口1仍执行原NORM完成路径。新路径完成声明全B/S NORM并实际消费LAC后，由真实program选择LINEAR/LIN_QKV stage2/layer1/weight{1,1}，executor沿原LOAD→Q前序执行。首窗Q数值/lease/读债/release及真实LTC消费闭合后，保留活动LINEAR/父L/A8/W及预约，零成功LINEAR LAC/REQUEST_COMPLETE、零下一action/第二请求。普通LINEAR不因此开放，诊断能力绑定真实A/K和完整command，不靠无键bool。

逻辑slot版本和物理Ref.epoch独立；三处相等校验须以完整已确认slot→owner绑定加真实owner状态核验替换。初始seed有真实checkpoint/command来源，NORM增量与实际LAC消费后才许可后继。LAP1原固定NORM校验同步按pc1真实绑定扩展；LOAD/Q已有commit退休不得重复，真实P/Q凭据保持。接口决定尚无新增实现PASS；host_02七process仅工程所报进度。

[接口答复](LINK)及[静态身份](AUDIT)保存依据。A/B/C继续，D不成为C测量前置；C先交真实LN数值/周期，D补含Q前缀测量。原预算/单重工具/各帽保持，G2338.224019s仅G OOC余额，5172s不重启。C009/C013部分实施，C008/C010待验；M003/M004未完成。

"""
def insert_after_title(rel,text):
    p=R/rel; old=p.read_text()
    assert 'D-M003-FIRST-BASELINE-PROGRAM-Q-01' not in old
    title,rest=old.split('\n',1)
    p.write_text(title+'\n\n'+text+rest.lstrip('\n'))
for rel,prefix in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
    insert_after_title(rel,review.replace('LINK',prefix+'executor_first_baseline_program_q_reply_20261013.md').replace('AUDIT',prefix+'executor_first_baseline_program_q_decision_20261013/verification.json'))
for rel,prefix in [('mission/current.md','../results/'),('results/overview.md','')]:
    insert_after_title(rel, '最新[阶段D入口决定]('+prefix+'executor_first_baseline_program_q_reply_20261013.md)（D-M003-FIRST-BASELINE-PROGRAM-Q-01）采用真实program的完整NORM→真实LOAD→首窗Q，测完保持LINEAR活动，不报请求完成或接第二请求。逻辑slot版本与物理epoch分离，以完整已确认绑定核验；LAP1/codec受影响闭包同步。A/B生成、C正常NORM继续，D不阻塞C先交计算测量。host_02七process仅工程主机报告，尚无本轮硬件验收；C009/C013部分实施、M003/M004未完成，原预算不变。\n\n')
(R/'agent/A001/result.md').write_text("""# 项目主控与架构评判：最新交付

execution_state: completed
stage: first_baseline_program_q_interface_decided
scope: 阶段D有界program→LOAD→首窗Q及slot绑定接口核定

[接口决定](../../results/executor_first_baseline_program_q_reply_20261013.md)接纳LGP1明确entrypoint2：完整声明NORM及真实LAC消费后，program发原LINEAR/LIN_QKV，executor做真实LOAD和首窗Q。Q测量出口保持活动LINEAR与父L/A8/W，不成功完成LINEAR或request，不接下一action/第二请求。诊断权限绑定完整A/K/command及可信NORM增量；普通未支持LINEAR仍无业务副作用拒绝。

确认slot logical version与Ref.epoch独立，以已确认slot→完整owner映射及唯一owner权威核验；初始seed、后继LAP1、实际LAC尾拍与完整P/Q来源不省略，LOAD/Q唯一退休。三处相等检查的修正纳入受影响新闭包。

[静态快照](../../results/executor_first_baseline_program_q_decision_20261013/verification.json)只签接口依据，不签新增动态PASS。工程host_02七process是未集中验收的阶段报告；executor生成和C/D硬件结果仍待。A/B/C正常链继续，D不成为C周期基线前置；原单重工具/帽/G OOC余额保持，无新增OOC/P&R/上板预算，5172s不重启。

C009/C013部分实施，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。
""")
put(D/'controller_report.json',{
'execution_state':'completed',
'current_task':'核定阶段D真实program→LOAD→首窗Q入口与独立slot版本绑定',
'stage':'first_baseline_program_q_interface_decided',
'blocker':None,
'next_step':'工程继续A/B生成与C真实NORM基线；按本决定实现D前缀并交受影响证据',
'runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'})
print(json.dumps({'snapshot_pairs':len(items),'reply_bytes':len(body.encode()),'verification_sha256':sha((D/'verification.json').read_bytes())},ensure_ascii=False))

