from pathlib import Path
import json
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
rid='R-SM003-PROGRAM-RTL-EXECUTOR-INPUTS-20261013';reply='executor_program_rtl_inputs_structure_reply_20261013.md'
def insert(rel,text):
 p=R/rel;old=p.read_text();assert rid not in old
 q=D/'prior_records'/rel;q.parent.mkdir(parents=True,exist_ok=True);q.write_text(old)
 title,rest=old.split('\n',1);p.write_text(title+'\n\n'+text+'\n\n'+rest.lstrip('\n'))
for rel,pre in [('mission/current.md','../results/'),('results/overview.md','')]:
 insert(rel,'最新[program真实RTL出口与executor结构审核]('+pre+reply+')（'+rid+'）：HLS06/15例nested validator及program RTL05四depth2案例限定接纳，每例实际完成416B copy/416B及1024B比较后owner echo；此前字段缺陷在此范围修复。executor03仍COST_STOP/0top，in_place去输入副本候选仅三文件、host07七process通过，新生成待验。4560冻结/13270引用核对，C完整NORM计算基线仍NOT_RUN；M003/M004未完成，原帽/预算保持。')
for rel,pre in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
 insert(rel,'## '+rid+'：program有限真实RTL接纳，executor仍待生成\n\n接纳HLS06正确端口、15个真实nested validator正负例与RTL05四depth2行为；每case17项有序执行见证和416/416/1024全量比较核实，非初值。rtl04原idle-done monitor FAIL保留，仅新monitor修复范围变更；旧字段缺陷在本冻结有限范围修复，不签同runtime executor/LN/唯一退休或C性能。\n\nexecutor03仍COST_STOP，host07及三文件in_place结构变化接纳为待生成候选；const入口caller不变而scratch允许修改。managed adapter88case/LTP11帧62拒绝仅签软件准备，post-revoke首cleanup不关闭。4560冻结/13270引用、60串行guard/478policy已核，19无RSS/21无policy如实保留。C先行，预算不变，M003/M004未完成。\n\n[答复]('+pre+reply+')；[核验]('+pre+'executor_program_rtl_inputs_structure_review_20261013/verification.json)。')
p=R/'agent/A001/result.md';q=D/'prior_records/agent/A001/result.md';q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
p.write_text('# 项目主控与架构评判：最新交付\n\nexecution_state: completed\nstage: program_rtl_inputs_structure_reviewed\n\n[审核](../../results/'+reply+')接纳owned program四有限真实depth2案例与15例nested validator，完整实际416B复制及416B/1024B比较已核。executor03仍成本停止，新in_place三文件候选通过host07、硬件生成待验；cleanup两主机准备不关闭真实首LTX缺口。\n\n4560冻结配对/13270引用与60串行guard核验完成，旧FAIL与current漂移保留。下一是executor真实生成和同runtime完整四窗NORM独立gold/退休/周期；C/D周期未取得，M003/M004未完成，原预算保持。主控未执行DUT工具。\n')
report={'execution_state':'completed','current_task':'验收program有限真实RTL并核定executor第三停止及新输入结构候选',
 'stage':'program_rtl_inputs_structure_reviewed','blocker':None,
 'next_step':'工程取得executor区别生成出口并连接C完整NORM；const兼容及必要cleanup继续',
 'runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps({'review':rid,'records_updated':5}))
