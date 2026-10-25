

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E004 · full_accelerator_integration

关联：M004 / SM004

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

## 修订21收束勘误（2026-10-16）

AT382/383的W与STATE1 peer关闭，故父W/Q/A16动态NOT_RUN；AT383 120s停止与TB能力限制分别保留。修订21最终余static605.50865154154599468s/RTL323.3846215400844935s封存，不转修订22。完整父matrix实例亦未由AT382展开证明。

## 修订21 AT379–383阶段结果（2026-10-16）

AT379真实LN128后的外部阶段done保持三拍，continue不准入；消费后真实continue握手和gamma退休PASS。AT382父top新SHA静态展开PASS、真实row0 1024norm/64B/source64R/gamma256R PASS；AT380/381闭包构建FAIL。AT383同快照120.35708910785615s timeout/-9，仅行0/1退休，父动态W/Q/A16为NOT_RUN/COST_STOP。累计60guard/398已观测政策；static1194.49134845845400532/1800s、RTL3276.6153784599155065/3600s，余605.50865154154599468s/323.3846215400844935s；host完整UNKNOWN，AT361 policy/RSS UNKNOWN。[报告](experiment_results/runs/R001/reports/SM004_rev21_AT383_parent_continue_cost_handoff_20261016.md)、[逐笔账](experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT383_20261016.json)。

## 修订21 AT378真实W错误后新epoch row0（2026-10-16）

AT378同runtime W末q0 RRESP错后，三口24576/24576/3072R及AUX8R排完，零STATE1/Q、131072norm保持；显式stage release/discard后，epoch2真实gamma256R、source64R、LN row0 1024norm逐位及64B PASS。RTL286.08507612906396s、static45.80028396472335s，child0无Fatal/Error。日志row255是TB显示变量跨release的8bit打印伪影，不是生产行。AT352–378累计53guard/352政策；static1070.59817872010170202/1800s、RTL2827.7368308156728665/3600s，host完整UNKNOWN。父层错误恢复、完整父请求W/Q/A16仍未测。[报告](experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md)、[逐guard账](experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT378_20261016.json)。

## 修订21 

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 321 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
