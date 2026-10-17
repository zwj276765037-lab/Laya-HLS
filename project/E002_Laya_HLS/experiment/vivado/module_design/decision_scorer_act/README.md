# Decision与决策输出

当前状态（2026-10-07，P2 F0功能验证通过）：两层Decision、16候选scorer及本题CLS驱动的act完整执行，当前B2/B1整图与真实top CSim通过。 分阶段证据见[source/results.md](source/results.md)。

组织两层Decision、marker gather、scorer、候选统计与act路径。

- 上下游：复用控制器、LN、矩阵、attention和向量单元；输出candidate/act logits给result_status。
- 共同设计要求：目录表示功能归属，不额外复制整套计算引擎；保持16候选、1028维例外与两次bias语义。

规格依据：

- [13_decision_scorer_act.md](../../design_source/13_decision_scorer_act.md)
- [03_forward_controller.md](../../design_source/03_forward_controller.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
