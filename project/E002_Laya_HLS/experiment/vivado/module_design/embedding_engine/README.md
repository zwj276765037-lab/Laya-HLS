# Embedding查表与反量化

当前状态（2026-10-07，P2 F0功能验证通过）：token/type查表与完整反量化接入整图，当前独立直接任务及完整CPU/CSim通过。 分阶段证据见[source/results.md](source/results.md)。

按token/qtype读取Q8_0表，解包并产生FP32向量。

- 上下游：请求ID→HBM加载器→embedding；token向量送LayerNorm，type向量送type add。
- 共同设计要求：保持34-byte组布局、FP16 scale次正规和有效ID范围；按下游接受能力交付。

规格依据：

- [06_embedding_engine.md](../../design_source/06_embedding_engine.md)
- [07_layernorm_engine.md](../../design_source/07_layernorm_engine.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
