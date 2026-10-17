# 总体集成

当前状态（2026-10-07，P2 F0功能验证通过）：28层Encoder、2层Decision及scorer/act已完整连接；当前包的CPU整图与真实13口HLS CSim通过。 分阶段证据见[source/results.md](source/results.md)。

连接控制、存储和算子模块，组织完整Laya前向的数据通路。

- 上下游：接kernel_wrapper的请求与平台接口；协调forward_controller、算子及result_status。
- 共同设计要求：顶层只负责集成；平台接口封装归kernel_wrapper，算子调度归forward_controller。

规格依据：

- [00_overall_design.md](../../design_source/00_overall_design.md)
- [15_integration_interfaces_and_pipeline.md](../../design_source/15_integration_interfaces_and_pipeline.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
