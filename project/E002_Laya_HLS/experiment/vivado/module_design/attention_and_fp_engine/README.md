# Attention与共享浮点引擎

当前状态（2026-10-07，P2 F0功能验证通过）：全部16head的QK/softmax/AV及尾层FP计算接入整图，当前CPU与标准libm CSim逐位通过。 分阶段证据见[source/results.md](source/results.md)。

组织QK、softmax、AV及scorer/act浮点例外层的计算。

- 上下游：接QKV/mask与KV缓存，输出attention结果；后期复用FP引擎执行浮点尾层。
- 共同设计要求：QK和AV共享资源，计算时间相加；score/prob与KV生命周期和数值顺序统一管理。

规格依据：

- [11_attention_and_fp_engine.md](../../design_source/11_attention_and_fp_engine.md)
- [13_decision_scorer_act.md](../../design_source/13_decision_scorer_act.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
