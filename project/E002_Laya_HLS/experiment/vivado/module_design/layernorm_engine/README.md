# LayerNorm

当前状态（2026-10-07，P2 F0功能验证通过）：完整行LayerNorm与gamma绑定接入全网络，当前CPU整图和真实top CSim逐位通过。 分阶段证据见[source/results.md](source/results.md)。

执行完整行统计、归一化和图中保留的gamma操作。

- 上下游：接embedding/hidden/marker，输出到量化或final LN之后的type add。
- 共同设计要求：三遍统计和固定数值顺序沿用规格；与量化共享流水边界，不能提前覆盖行缓存。

规格依据：

- [07_layernorm_engine.md](../../design_source/07_layernorm_engine.md)
- [08_activation_quantizer.md](../../design_source/08_activation_quantizer.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
