# Kernel与平台接口

当前状态（2026-10-07，P2 F0功能验证通过）：13参数生产核及真实XRT Host路径已实现；真实top标准libm CSim通过，XRT编译与设备阶段因本机依赖缺失未运行。 分阶段证据见[source/results.md](source/results.md)。

承接后续需要的RTL平台适配、顶层封装及连接逻辑。

- 上下游：平台AXI/时钟复位→top；完成状态经平台接口交回XRT。
- 共同设计要求：AXI-Lite控制映射仍由HLS生成并按元数据核查；端口、时钟和复位细节待平台冻结。

规格依据：

- [02_kernel_wrapper_and_platform.md](../../design_source/02_kernel_wrapper_and_platform.md)
- [01_host_runtime_and_abi.md](../../design_source/01_host_runtime_and_abi.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
