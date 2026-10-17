from pathlib import Path
from datetime import datetime, timezone
import json, hashlib

R = Path(__file__).resolve().parents[2]
D = Path(__file__).resolve().parent
B = R/'project/E003_production_chain_closure/experiment_results/runs/R003'
rid = 'R-SM003-EXECUTOR-WIDE-FIFO-PROGRAM-REPAIR-20261013'
reply = 'executor_wide_fifo_program_repair_reply_20261013.md'
audit = 'executor_wide_fifo_program_repair_review_20261013/verification.json'
v = json.loads((D/'verification.json').read_text())
intervals = []
for name, item in v['attempts'].items():
    for g in item.get('guards', []):
        p = B/name/g['directory']/'launch.json'
        launch = json.loads(p.read_text())
        intervals.append({'attempt': name, 'guard': g['directory'],
                          'start': launch['at'], 'end': g['result']['finished_at']})
intervals.sort(key=lambda x:x['start'])
assert all(a['end'] <= b['start'] for a,b in zip(intervals,intervals[1:]))
p = B/'executor_wide_fifo_diagnostic_01/work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.err.log'
events = [line for line in p.read_text().splitlines() if 'Disaggregating variable' in line]
assert len(events) == 5
target = D/'snapshot'/p.relative_to(R)
target.parent.mkdir(parents=True,exist_ok=True)
target.write_bytes(p.read_bytes())
(D/'supplement.json').write_text(json.dumps({'at':datetime.now(timezone.utc).isoformat(),
    'guard_intervals':intervals,'selected_23_guards_serial':True,
    'reflow_disaggregate_events':events,'reflow_snapshot':str(target.relative_to(R)),
    'reflow_sha256':hashlib.sha256(target.read_bytes()).hexdigest(),
    'note':'verification.json read reflow.out with no remarks; actual remarks are in this reflow.err. Generation and port checks were independently verified.'},ensure_ascii=False,indent=2)+'\n')

def insert(rel, text):
    p=R/rel
    old=p.read_text()
    assert rid not in old
    title, rest=old.split('\n',1)
    out=D/'prior_records'/rel
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text(old)
    p.write_text(title+'\n\n'+text+'\n\n'+rest.lstrip('\n'))

section='''## RID：宽FIFO区分生成通过，program字段修复待RTL

接纳五宽口微top限定生成、owned_host07十process和source_guard_v2_02六例/3214cycles所测范围。788冻结/current配对及1946项非original引用一致；微top实际5FIFO/15信号，6份完整byte oracle，242产物；23guard/79policy按实测核对。12短段无child RSS，另wide oracle有RSS但无policy，资源观测不能泛称齐全。

五宽口本身不是原停止的充分解释，完整actor交互仍待定位。program旧动态FAIL及purpose低16位错误保持；新真实标量修复保留校验体，HLS05闭包与host07相同但生成/行为待验。source guard相对旧01为等价TB调用及runner异常检测加强两项变化，DUT不变。工程继续有限generated RTL正常/错误purpose检查及executor受影响host、新候选；C先交完整NORM测量，D/完整恢复后置，旧cleanup首LTX沿原合同继续。M003/M004未完成，预算不变。

[审核答复](LINK)；[核验](AUDIT)。主控未执行DUT工具。'''.replace('RID',rid)
for rel,pre in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
    insert(rel,section.replace('LINK',pre+reply).replace('AUDIT',pre+audit))
for rel,pre in [('mission/current.md','../results/'),('results/overview.md','')]:
    insert(rel,'最新[宽FIFO与program修复审核]('+pre+reply+')（'+rid+'）：五宽口微top生成通过，排除仅接口组合必然停止的解释；完整executor仍无RTL。program字段读取错误已定位，保留完整校验的标量修复通过十主机process，生成/动态验证待验；source guard六例有限PASS接纳。788冻结/current与1946引用一致。C完整NORM测量先行，D/完整恢复后置，必要旧cleanup按原合同；M003/M004未完成，原帽/预算不变。')
p=R/'agent/A001/result.md'
old=D/'prior_records/agent/A001/result.md';old.parent.mkdir(parents=True,exist_ok=True);old.write_bytes(p.read_bytes())
p.write_text('''# 项目主控与架构评判：最新交付

execution_state: completed
stage: executor_wide_fifo_program_repair_reviewed
scope: 五宽口区分实验、program完整purpose修复主机证据及source guard有限RTL

[审核答复](../../results/REPLY)接纳微top生成、十process主机及六case source guard有限范围；788冻结/current配对、1946项SHA引用、23guard及实际79policy已核。宽口本身不足以必然解释原停止，完整executor仍COST_STOP/无RTL；program字段错误修复保持完整校验，HLS05及其动态行为待验，旧RTL FAIL保留。

工程继续真实generated program正常/错误purpose、executor受影响host/结构定位及必要旧cleanup接线。C正常完整NORM测量先行，D及完整恢复后置；C/D周期NOT_RUN，M003/M004未完成，原单重工具/所有帽/G仅OOC余额保持。主控未运行DUT工具。

[核验](../../results/AUDIT)保存冻结快照与边界。
'''.replace('REPLY',reply).replace('AUDIT',audit))
report={'execution_state':'completed','current_task':'集中核定五宽FIFO区分实验与program字段修复证据',
    'stage':'executor_wide_fifo_program_repair_reviewed','blocker':None,
    'next_step':'工程继续program生成后有限RTL与executor受影响闭包，优先C完整NORM测量',
    'runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'review':rid,'selected_guards_serial':len(intervals),'reflow_events':len(events),'records_updated':5}))
