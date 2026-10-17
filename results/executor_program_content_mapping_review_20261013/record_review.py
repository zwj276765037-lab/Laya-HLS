from pathlib import Path
import json
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
rid='R-SM003-PROGRAM-CONTENT-MAPPING-20261013'
reply='executor_program_content_mapping_reply_20261013.md'
def insert(rel,text):
 p=R/rel;old=p.read_text();assert rid not in old
 q=D/'prior_records'/rel;q.parent.mkdir(parents=True,exist_ok=True);q.write_text(old)
 title,rest=old.split('\n',1);p.write_text(title+'\n\n'+text+'\n\n'+rest.lstrip('\n'))
for rel,pre in [('mission/current.md','../results/'),('results/overview.md','')]:
 insert(rel,'最新[program第二字段映射审核]('+pre+reply+')（'+rid+'）：HLS05限定生成通过，RTL03仍在合法owner安装处DUT fatal，后续三case未跑。purpose已正确，content却读取region，canonical仍未执行；工程集中检查同一validator剩余字段后修复/新冻结，不逐字段盲重跑。1884冻结及8204非original引用已核，四处live差异不影响历史身份。C完整NORM测量先行，D/完整恢复后置，M003/M004未完成，原预算保持。')
for rel,pre in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
 insert(rel,'## '+rid+'：生成通过与动态失败分列，集中核查nested字段\n\nHLS05实际8FIFO/24信号生成事实接纳；RTL03 static通过但84645ns/phase1实际fatal，child0不代签PASS，其余三caseNOT_RUN。diagnostic03 purpose1已正确，content比较读region0而真实content1，model/canonical仍NOT_MEASURED。executor_host05七process只签原冻结主机。\n\n1884冻结pair/8204非original引用核对，四处live差异明确保留。16guard/213policy按实测；六段无RSS、八段无policy。允许完整校验体内真实content标量边界修复，集中检查剩余字段再冻结；新host/生成/合法nested正对照及负例后再评行为，不新增预算或逐项审批。C基线先行，M003/M004未完成。\n\n[答复]('+pre+reply+')；[核验]('+pre+'executor_program_content_mapping_review_20261013/verification.json)。')
p=R/'agent/A001/result.md';q=D/'prior_records/agent/A001/result.md';q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
p.write_text('# 项目主控与架构评判：最新交付\n\nexecution_state: completed\nstage: program_content_mapping_reviewed\n\n[审核](../../results/'+reply+')分列HLS05限定生成与RTL03实际DUT fatal，核定purpose已通过而content比较误读region的具体证据。1884冻结配对和8204非original引用一致，四处live变化不追认旧身份。\n\n工程在原授权内集中核查完整validator剩余字段，真实值标量边界修复后受影响host/新冻结生成；C完整NORM测量优先，D/完整恢复后置。C/D周期未取得、M003/M004未完成，原预算保持；主控无DUT工具执行。\n')
report={'execution_state':'completed','current_task':'核定program第二字段映射错误与生成/动态失败边界',
 'stage':'program_content_mapping_reviewed','blocker':None,
 'next_step':'工程集中核查nested字段后真实值边界修复，继续受影响验证与首条NORM基线',
 'runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'review':rid,'records_updated':5}))
