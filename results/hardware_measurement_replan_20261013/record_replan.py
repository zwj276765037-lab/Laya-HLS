from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, sys

R = Path(__file__).resolve().parents[2]
D = Path(__file__).resolve().parent
plan = 'mission/hardware_measurement_replan_20261013.md'
decision = 'D-M004-MEASUREMENT-FIRST-01'
snapshots = []
def sha(p):
    with p.open('rb') as f: return hashlib.file_digest(f, 'sha256').hexdigest()
def save(rel):
    p = R / rel
    q = D / 'prior_records' / rel
    assert not q.exists(), str(q)
    q.parent.mkdir(parents=True, exist_ok=True)
    q.write_bytes(p.read_bytes())
    snapshots.append({'source': rel, 'snapshot': str(q.relative_to(R)), 'sha256': sha(q)})
    return p.read_text()
def prepend(rel, text):
    old = save(rel)
    first, rest = old.split('\n', 1)
    (R / rel).write_text(first + '\n\n' + text + '\n\n' + rest.lstrip('\n'))

prepend('goal/goal.md', '## 当前优先级修订：2026-10-13用户要求立即换重心\n\n' + decision + '：[当前工作计划](../' + plan + ')先做SM005/E005/R001局部算术KB0与同口径优化，独立评估控制架构。M003不再是局部性能工作的启动前置；它仍是完整生产集成的最终验收依赖。现FullRuntime/executor生成、冷INIT及恢复扩展停止新排程，原工作和未完成义务保留。下文v3完整目标、模型/数值、最终B0验收及资源约束不变；“仅计划/未派发”和“所有优化先等完整B0”的旧执行顺序不适用于本次已下达工作。')
prepend('mission/M004_完整Laya加速器搭建与性能优化.md', '## 修订2：测量优先，已向工程下达\n\n' + decision + '，来源2026-10-13用户“马上调转目前的工作重心 重新规划当前工作内容”。[生效计划](hardware_measurement_replan_20261013.md)授权SM005/E005/R001先建立局部KB0/KB1并作瓶颈优化，控制架构另行集中选择。原G0→G1/G2→G3的全串行排程不再约束局部测量；M003改为最终生产集成依赖。完整请求B0/B1和G1–G5最终验收保持，KB不能冒充完整B0。当前工程已确认旧重工具全部收束、executor HLS05未启动；本轮无新OOC/P&R/上板预算。以下修订1正文保留原最终范围与历史背景，冲突的当前排程以本节和生效计划为准。')
prepend('mission/M003_当前身份生产链接入与回归.md', '## 2026-10-13执行重排\n\n按用户最新指令和[' + decision + '](hardware_measurement_replan_20261013.md)，本任务新增生产控制实现/生成暂缓；当前已运行工具由工程确认收束，冻结与未完成项保留。先由M004/SM005取得独立算术KB0/优化结果并评估控制架构，再按实际选择恢复集成。本M仍未完成，所有生产正确性/恢复义务保留；不再阻塞局部硬件性能实验。')
for rel, replacements in [
    ('mission/M003_当前身份生产链接入与回归.md', [('execution_state: running', 'execution_state: paused')]),
    ('mission/M004_完整Laya加速器搭建与性能优化.md', [
        ('execution_state: planned', 'execution_state: running'),
        ('revision: 1 / 2026-10-11', 'revision: 2 / 2026-10-13；修订1最终验收正文保留'),
        ('small_missions: SM004/E004全模型集成；SM005/E005性能与资源；M003/SM003/E003为既有前置工作', 'small_missions: 当前SM005/E005/R001局部测量与优化；SM004/E004全模型集成待续；M003/SM003/E003为最终生产集成依赖')])
]:
    p = R / rel
    body = p.read_text()
    for old, new in replacements:
        assert body.count(old) == 1
        body = body.replace(old, new, 1)
    p.write_text(body)
save('project/missions/SM005.md')
(R / 'project/missions/SM005.md').write_text('''# SM005：算术测量先行，逐步闭合完整请求性能与资源

mission: M004
experiment: E005
execution_state: running
verdict: unassessed
owner: A002工程唯一实现/工具；A001架构取舍与集中评判
revision: 2 / 2026-10-13

当前运行的是规划落实与入口盘点，新的算术实验尚未执行。依据用户最新优先级，执行[测量优先计划](../../mission/hardware_measurement_replan_20261013.md)。原修订1完整请求验收保留在主控历史快照，当前分为两个层级：

1. 立即进行E005/R001的局部KB0/KB1：默认四行resident Down；不可复用时选已冻结LN→Q或有明确理由的已有算术核。真实独立gold、周期/停顿/AXI、同口径候选比较；最多两个不同候选后集中取舍。允许诊断driver，不依赖完整executor/CLOSED。并行只读比较薄硬件控制器与RTL控制方案。
2. 完整集成后冻结真实请求B0：同模型/shape/请求/反压/缓存/计量边界比较冷暖延迟、完成间隔、填充排空和资源；优化后由SM004重验受影响范围。KB不能替代B0，也不能代签完整加速器。

原模型/数值/独立gold、完整28+2层/122矩阵、CPU/FPGA分工和最终验收不变；不设固定速度或提升百分比。资源未知保持UNKNOWN，局部cycles不相加成全图，CPU墙钟和假定频率不算硬件实测。

代码唯一在E002/experiment；E005保存证据。原单重工具及全部帽保持，本轮不新跑OOC/P&R/上板，G2338.224019s仅原OOC余额。M003未完成项保留为最终生产集成依赖，不阻塞本局部阶段。
''')
save('mission/current.md')
(R / 'mission/current.md').write_text('''# 当前任务

总目标仍为[M004完整Laya加速器](M004_完整Laya加速器搭建与性能优化.md)，当前执行[测量优先重排](hardware_measurement_replan_20261013.md)（D-M004-MEASUREMENT-FIRST-01）。用户于2026-10-13要求立即调转重心。

## 现在做什么

- SM005/E005/R001：复用真实算术kernel，建立KB0周期/停顿/AXI/数值基线，紧接一项有证据的优化对照。默认四行resident Down；复用有具体障碍时换已冻结LN→Q。
- A001与工程并行做有界架构取舍：FullRuntime整体HLS退出默认路线，比较显式存储/有限步骤的薄控制器和小型RTL控制器。
- 第一轮交付是KB0、至少一个同口径候选判断和控制架构取舍；不再用控制协议PASS替代性能进展。

## 暂缓与保持

M003生产控制新实现/生成、executor冷INIT/HLS05、CLOSE/rearm与cleanup扩展已退出优先队列。工程确认当前无重工具，旧改动保存、未完成义务保留；这些有限新报告未在本轮额外验收。恢复集成须有实际依赖及架构决定。M003是最终验收依赖，不是局部测量前置。

A002唯一实现/工具owner，复用现有helpers，不新增agent。代码唯一E002/experiment，证据E005/R001；原数值/模型/gold、全部资源帽和单重工具不变，G余额仅OOC，本轮无新OOC/P&R/上板。

完整请求B0及完整正确性/恢复/资源仍待；局部KB0不关闭M004。重排前详细历史保留在[快照](../results/hardware_measurement_replan_20261013/prior_records/mission/current.md)，各审核在[SM003记录](../results/reviews/SM003.md)。
''')
save('results/overview.md')
(R / 'results/overview.md').write_text('''# Laya-HLS 当前概览

2026-10-13按用户要求已执行[工作重排](../mission/hardware_measurement_replan_20261013.md)：当前优先取得算术测量和优化对照，独立审视控制架构。M004完整目标保持；M003生产集成仍未完成，退出局部测量的前置链。

工程已确认无重工具运行，executor HLS05未启动；冷INIT、collector/exporter、managed adapter、关闭恢复工作保存后退出优先队列。既有结果和失败保留；本次不因重排追认其生产集成通过。

| 工作 | 当前状态 | 下一可见出口 |
| --- | --- | --- |
| SM005/E005/R001算术KB0 | 已下达盘点，新的测量NOT_RUN | 默认resident Down的数值/周期/停顿/AXI表；入口不可复用则换已有LN→Q |
| KB1局部优化 | NOT_RUN | 一个测得瓶颈的同口径改动和收益/代价；两个候选后集中取舍 |
| 控制架构重新选择 | 规划已明确、实际方案待交 | 硬件状态/存储/唯一权威与生成成本对照，优先薄控制器，保留RTL备选 |
| 完整请求/资源/生产恢复 | 未完成 | 局部测量后按实际依赖恢复集成，不能以KB代签 |

可复用历史依据：四行resident Down 48862cycles、LN→Q rows16完整gold、Attention v10 head128 604317cycles，均只对原冻结模块范围有效；不需为规划从零复验全部历史。executor四次生成COST_STOP/无RTL，program已有有限真实RTL出口。

A002仍唯一实现/重工具owner，全部原资源帽保持；本轮不新跑OOC/P&R/上板，G2338.224019s仅原OOC余额。下一报告须给出算术数据或具体换路决定。详见[计划](../mission/hardware_measurement_replan_20261013.md)、[指标边界](hardware_metrics.md)和[旧概览存档](hardware_measurement_replan_20261013/prior_records/results/overview.md)。
''')
prepend('NEW_CHAT_START.md', '## 最新工作入口：2026-10-13立即重排\n\n先读[测量优先计划](mission/hardware_measurement_replan_20261013.md)与[当前任务](mission/current.md)。当前SM005/E005/R001先做真实算术KB0/优化，M003暂停新增生产控制实现，executor HLS05未启动。旧正文的“先全部M003再优化”顺序已被用户新指令覆盖；最终完整目标与正确性/资源要求不变。')
for rel, prefix in [('results/review_queue.md', '../'), ('results/reviews/SM005.md', '../../')]:
    if not (R / rel).exists(): (R / rel).write_text('# SM005阶段决定与审核\n')
    prepend(rel, '## ' + decision + '：重排已下达，算术结果待验\n\n来源用户最新直接指令。工程已确认无在跑工具、executor HLS05未启动，旧控制方向保存退出队列。当前SM005/E005/R001先取KB0并做同口径候选对照，控制架构只读比较并集中选路；M003改为最终生产集成依赖。此为真实排程决定，不是新DUT/性能PASS。\n\n[生效计划](' + prefix + plan + ')；原目标、数值/gold、单重工具和资源帽保持。')
prepend('results/hardware_metrics.md', '当前[测量优先阶段](../mission/hardware_measurement_replan_20261013.md)启用局部KB0/KB1标签；以下继承数值只作入口依据，不是本轮新测量，也不是完整请求B0。新周期/瓶颈/资源代价由E005/R001原始证据更新。')
save('agent/A001/result.md')
(R / 'agent/A001/result.md').write_text('''# 项目主控与架构评判：最新交付

execution_state: completed
stage: measurement_first_replan_dispatched

按用户要求执行[工作重排](../../mission/hardware_measurement_replan_20261013.md)。旧控制链新生成/扩展退出队列，工程确认无重工具、HLS05未启动。新当前工作为SM005/E005/R001算术KB0与同口径优化，默认Down、备选LN→Q；控制架构按可检验生成边界重新选择。

M003只保留最终生产集成依赖，局部性能不再等待完整executor。主控已更新任务/目标解释和导航依赖，原记录保存；未运行任何DUT或宣称新性能结果。A002继续唯一整合，所有原帽保持。
''')

# Only scheduling dependencies are cleared; final acceptance remains explicit.
sys.path.insert(0, '/home/zwj/.codex/skills/research-agent/scripts')
import research
with research.project_lock(R):
    save('.research-agent/navigation.json')
    cfg = research.read_json(R / '.research-agent/navigation.json')
    cfg.setdefault('dependencies', {})['M004'] = []
    cfg.setdefault('final_acceptance_dependencies', {})['M004'] = ['M003']
    cfg['dependency_decision'] = {'id': decision, 'path': plan, 'note': 'M003 gates final production integration, not E005 local kernel measurement/optimization'}
    research.write_json(R / '.research-agent/navigation.json', cfg)

report = {'execution_state': 'completed', 'current_task': '按用户要求完成测量优先重排并向工程下达', 'stage': 'measurement_first_replan_dispatched', 'blocker': None, 'next_step': '工程交付KB0算术数据/瓶颈与KB1对照，主控集中选择硬件控制架构', 'runtime_id': None, 'thread_id': '01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D / 'controller_report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
(D / 'record_changes.json').write_text(json.dumps({'decision': decision, 'recorded_at': datetime.now(timezone.utc).isoformat(), 'user_instruction': '马上调转目前的工作重心 重新规划当前工作内容', 'prior_records': snapshots, 'plan_sha256': sha(R / plan), 'DUT_tools_run': False}, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'decision': decision, 'prior_records_preserved': len(snapshots), 'current_stage': 'SM005/E005/R001', 'new_experiments': 'NOT_RUN'}, ensure_ascii=False))
