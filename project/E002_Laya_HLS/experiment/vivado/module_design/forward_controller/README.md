# 前向调度

当前状态（2026-10-07，P2 F0功能验证通过）：完整F0调度、owner屏障与持久故障恢复通过当前CPU整图及真实top CSim验证。 分阶段证据见[source/results.md](source/results.md)。

管理层/算子执行顺序、共享引擎互斥及缓存所有权。

- 上下游：输入请求上下文与模块完成信息；调度加载器、计算单元和结果写回。
- 共同设计要求：Q8引擎、FP引擎和向量单元按共同调度复用；数据可见与排空条件满足后再释放缓存。

规格依据：

- [03_forward_controller.md](../../design_source/03_forward_controller.md)
- [15_integration_interfaces_and_pipeline.md](../../design_source/15_integration_interfaces_and_pipeline.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
