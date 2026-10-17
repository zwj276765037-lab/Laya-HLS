# 公共定义

当前状态（2026-10-07，P2 F0功能验证通过）：固定任务类型、数值公共实现及身份检查已接入全部15模块，并通过当前完整CPU/CSim验证。 分阶段证据见[source/results.md](source/results.md)。

保存后续RTL共用的类型、参数、枚举和接口定义。

- 上下游：供所有RTL模块引用；与Host/HLS共享配置和生成接口保持一致。
- 共同设计要求：后续从同一配置来源生成或核对，避免各模块分别维护位宽、shape和错误编号。

规格依据：

- [15_integration_interfaces_and_pipeline.md](../../design_source/15_integration_interfaces_and_pipeline.md)
- [02_kernel_wrapper_and_platform.md](../../design_source/02_kernel_wrapper_and_platform.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
