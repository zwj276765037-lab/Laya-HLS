# 激活量化

当前状态（2026-10-07，P2 F0功能验证通过）：Group32完整K量化及A8来源/epoch检查接入全网络，当前完整CPU/CSim逐位通过。 分阶段证据见[source/results.md](source/results.md)。

将FP32输入按Group32量化为A8及FP16 scale，准备阵列输入tile。

- 上下游：接LayerNorm、attention或向量输出；通过A8缓存送Q8 Linear。
- 共同设计要求：保留d_full与保存scale的区别和舍入规则；4/8-lane输入速率与重放阶段单独核算。

规格依据：

- [08_activation_quantizer.md](../../design_source/08_activation_quantizer.md)
- [09_q8_linear_and_restore.md](../../design_source/09_q8_linear_and_restore.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
