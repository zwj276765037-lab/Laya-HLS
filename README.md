
历史原文已保留：[整理前原文](.research-agent/navigation_history/68d6a43af4de249b1511056ef23af166c7731eb5484a96677cb18735ef84a755.md)

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# Laya-HLS 项目首页

项目根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`

## 查看入口

| 记录 | 入口 |
| --- | --- |
| 目标与历史 | [打开](goal/goal.md) |
| 所有 mission | [打开](mission/index.md) |
| 实验与每次结果 | [打开](project/index.md) |
| agent 讨论与待办 | [打开](communication/index.md) |
| 用户技术问答 | [打开](question/index.md) |
| 四个职责会话 | [打开](agent/index.md) |
| 全项目报告与历史 | [打开](results/index.md) |

## 当前任务

[M004 · 完整Laya加速器搭建与性能优化](mission/M004_%E5%AE%8C%E6%95%B4Laya%E5%8A%A0%E9%80%9F%E5%99%A8%E6%90%AD%E5%BB%BA%E4%B8%8E%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96/README.md)

合同：[原始任务定义](mission/M004_%E5%AE%8C%E6%95%B4Laya%E5%8A%A0%E9%80%9F%E5%99%A8%E6%90%AD%E5%BB%BA%E4%B8%8E%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96.md)
唯一实现入口：[工程代码](project/E002_Laya_HLS/experiment)

## 最新执行报告

| 职责 | 当前任务 / 阶段 | 执行状态 | 上报时间 | 下一步 / 阻塞 |
| --- | --- | --- | --- | --- |
| 项目主控与架构评判 | 用户要求暂停，等待明确恢复通知 修订22工程到AT404阶段交付，AT405后续处理中；主控AT404集中审核尚未完成，全部结果维持原范围 | paused | 2026-10-15T23:17:00.779892+00:00 | 仅在用户明确通知继续后恢复；保留已有修改、原始证据和预算账，不启动新工作  |
| 工程实现与验证 | SM004 修订22唯一 matrix/首 TN8 实现与验证 用户已通知暂停；AT408 局部 PS writer 16 笔 OKAY B/一次 retire 已有原始收据，修订22整体仍未完成 | paused | 2026-10-15T23:17:03.822357+00:00 | 恢复后先整理 AT405–408 精确费用与证据，再继续原合同受影响范围 等待用户明确恢复通知 |
| 研究探索与瓶颈分析 | M004/SM004 AT368 A16_HELD到唯一MATRIX16/STEP16接口静态增量 按用户‘先暂停 等我通知’及m004-user-pause-research-20261016停止研究推进；此前MATRIX16静态增量已交付，现有源码、文档、日志和成本原样保留。A003没有未结束的owned实验或脚本；本次仅登记暂停状态并回报，不启动实现、审核或实验 | paused | 2026-10-15T23:17:21.647787+00:00 | 等待用户明确恢复通知；普通内部里程碑或旧合同继续消息不能解除暂停。AT404集中审核保持待续，修订22及M004/SM004未完成；不回滚、不升级PASS、不转预算  |
| executor入口源码核查 | 阶段A/B owned program真实consumer测试/runner 阶段D只读Q映射已交付；准备12源owned program独立gold用例 | running | 2026-10-13T01:36:28.707539+00:00 | 交父host-only/生成入口，自己不跑重工具  |
| executor真实控制consumer验证 | 阶段A真实LHC1控制transport RTL control transport RTL/TB/runner已交父；仅静态检查，DUT NOT_RUN | completed | 2026-10-13T01:41:47.287705+00:00 | 父在executor HLS后串行有限RTL  |
| executor生成入口验证与runner | 阶段C真实adapter/fence/source保护接线盘点 HLS reuse入口已交付；新只读检查实际物理端口 | running | 2026-10-13T01:41:48.660604+00:00 | 给父首次正常计算必需接线；无重工具  |

## 当前证据范围（来自负责人概览，截取）

# Laya-HLS 当前概览

## 修订21成本收束与修订22矩阵合同（2026-10-16）

2026-10-16；M004/SM004 running/unassessed。[修订21成本出口](results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at383_closeout_decision.md)已定：AT368独立真实LN128→W→首A16和受影响局部错误/恢复按原SHA/断言范围接纳，AT379补上层stage done未消费屏障。AT382当前父top实际O3展开及真实row0通过；AT383固定120s只退休两行，COST_STOP，父动态W/Q/A16和完整父同runtime仍OPEN。

905项增量核验，744冻结/7guard/46政策通过；最终60guard/398政策，static1194.49134845845400532/1800s、RTL3276.6153784599155065/3600s。余static605.50865154154599468s/RTL323.3846215400844935s封存，不转后继；host完整与AT361未观测policy/RSS仍UNKNOWN，旧FAIL/COST_STOP保持。另核父TB只是LN阶段：W响应关闭、STATE1绑零、LN128即结束；延长原TB不能验证W/Q，后继父链须补真实peer与相位checker。

[修订22正式合同](results/m004_simplified_start_20261014/a16_matrix16_rev22_decision.md)采用已审核唯一matrix服务、A16 claim/SL_MATRIX、同步A/PS单口及完整rows16/K1024/N3072 STEP16。独立真实主例从LN128→W冷载→Q16→首TN8，核128stripe/512行组/128final/16笔B及ps_retire；前4行独立gold、后12行传递/覆盖分开。首TN8不发父完成/RAW/FINAL。父完整链欠账继续保留，不作为所有矩阵推进前置。

新独立host300s/static1800s/RTL3600s预算，未知路径先≤120s；新组合真实LN16与同版W/Q16/首TN8局部完整样本支持合同2.5倍计划式≤1440s且余RTL≥1800s时，自动一次≤1800s主例。全项目单重工具/CPU0–3/nice19/idle/内存及语义停滞保护不变。普通修复连续执行，不原样续跑AT383、不启动HLS/OOC/P&R或新gold，不新建agent。修订22实现/动态结果待工程交付，完整模型/Host-HBM/联合物理未验。

以下为历史审核时点，当前范围以上段及正式合同为准。

## 修订21 AT378独立stage错误恢复限定接纳（2026-10-16）

2026-10-16；M004/SM004 running/unassessed。[AT378审核](results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at378_milestone_decision.md)接纳同AT368生产SHA的真实W错误后独立stage显式discard→无reset真实LN row0恢复。一次运行先LN128/W末q0 SLVERR、零STATE1/Q和norm保持，再以id300/source epoch2刺激恢复gamma256R/source64R/1024norm逐W握手gold/64B，生产退休1；RTL286.085076s。直接stage_release_fire不签父tensor_release/e/e+1/e+2，不签再次W加载/Q16或完整请求。row255为TB释放诊断8bit减1，不是生产行事件。

254项增量核验成立，148冻结/fixture、2guard/11政策；原51笔保持，累计53guard/352已观测政策。static1070.59817872010170202/1800s、RTL2827.7368308156728665/3600s；剩729.40182127989829798s/772.2

（摘录截断；完整记录见链接。）

[完整概览及审核来源](results/overview.md)

## 最近讨论

- [C058 · 用户暂停指令（2026-10-16）](communication/C058_%E7%94%A8%E6%88%B7%E6%9A%82%E5%81%9C%E6%8C%87%E4%BB%A4%EF%BC%882026-10-16%EF%BC%89/thread.md) — 已答复待实施
- [C057 · 用户暂停指令（2026-10-16）](communication/C057_%E7%94%A8%E6%88%B7%E6%9A%82%E5%81%9C%E6%8C%87%E4%BB%A4%EF%BC%882026-10-16%EF%BC%89/thread.md) — 已答复待实施
- [C051 · 修订17：全128行LN阶段与Q16紧密bank入口](communication/C051_%E4%BF%AE%E8%AE%A217%EF%BC%9A%E5%85%A8128%E8%A1%8CLN%E9%98%B6%E6%AE%B5%E4%B8%8EQ16%E7%B4%A7%E5%AF%86bank%E5%85%A5%E5%8F%A3/thread.md) — 已答复待实施
- [C056 · 首A16保持之后：现生产接口上的MATRIX16最小增量](communication/C056_%E9%A6%96A16%E4%BF%9D%E6%8C%81%E4%B9%8B%E5%90%8E%EF%BC%9A%E7%8E%B0%E7%94%9F%E4%BA%A7%E6%8E%A5%E5%8F%A3%E4%B8%8A%E7%9A%84MATRIX16%E6%9C%80%E5%B0%8F%E5%A2%9E%E9%87%8F/thread.md) — 已答复待实施
- [C055 · LN128后继W准备与Q16首窗口：定向静态增量](communication/C055_LN128%E5%90%8E%E7%BB%A7W%E5%87%86%E5%A4%87%E4%B8%8EQ16%E9%A6%96%E7%AA%97%E5%8F%A3%EF%BC%9A%E5%AE%9A%E5%90%91%E9%9D%99%E6%80%81%E5%A2%9E%E9%87%8F/thread.md) — 已答复待实施
- [C054 · AT349 Check 断言范围更正](communication/C054_AT349%20Check%20%E6%96%AD%E8%A8%80%E8%8C%83%E5%9B%B4%E6%9B%B4%E6%AD%A3/thread.md) — 待答复

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
