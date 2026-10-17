# HBM加载与片上缓存

当前状态（2026-10-07，P2 F0功能验证通过）：真实模型、权重、LN/RoPE/KV加载及完整owner/lease接入整图，当前CPU/CSim与实际事件计数通过。 分阶段证据见[source/results.md](source/results.md)。

组织HBM读写、权重/激活/PS/KV/score缓存及数据交接。

- 上下游：memory_map提供地址；为embedding、Q8 Linear、attention和向量模块供应数据。
- 共同设计要求：缓存bank、端口、burst和背压需与实际消费者联合设计；独立端口数仍为候选配置。

规格依据：

- [05_hbm_loader_and_cache.md](../../design_source/05_hbm_loader_and_cache.md)
- [04_model_package_and_memory_map.md](../../design_source/04_model_package_and_memory_map.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
