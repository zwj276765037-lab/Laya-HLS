# 硬件地址与范围检查

当前状态（2026-10-07，P2 F0功能验证通过）：13 BO真实寻址、界限与跨shape任务通过；AXI基址0误判已修复并由生成read helper RTL验证。 分阶段证据见[source/results.md](source/results.md)。

保存硬件地址生成、逻辑/物理stride转换和访问范围检查。

- 上下游：为加载器、QKV重排、marker gather和结果写回提供一致地址解释。
- 共同设计要求：模型软件导出器不放在这里；BO布局、offset与Host/HLS同源定义保持一致。

规格依据：

- [04_model_package_and_memory_map.md](../../design_source/04_model_package_and_memory_map.md)
- [01_host_runtime_and_abi.md](../../design_source/01_host_runtime_and_abi.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
