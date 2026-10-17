# Q8 Linear与恢复

当前状态（2026-10-07，P2 F0功能验证通过）：真实完整K/N的Q8 Linear、bias恢复和QKV散写已实现，十种矩阵及完整CPU/CSim通过。 分阶段证据见[source/results.md](source/results.md)。

组织整数dot、scale恢复、FP32部分和及最终输出。

- 上下游：接A8与权重缓存；输出给RoPE、向量/FFN、残差和决策头。
- 共同设计要求：阵列、恢复器、PS和读出一起评估；全网共享，N=2尾层按实际反馈依赖调度。

规格依据：

- [09_q8_linear_and_restore.md](../../design_source/09_q8_linear_and_restore.md)
- [05_hbm_loader_and_cache.md](../../design_source/05_hbm_loader_and_cache.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
