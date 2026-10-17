# 结果、状态与完成交接

当前状态（2026-10-07，P2 F0功能验证通过）：384B实际结果帧、首因和提交诊断、已接受故障后恢复通过当前CPU验证，成功帧final18由真实top CSim核对。 分阶段证据见[source/results.md](source/results.md)。

组织结果帧写回、请求身份、错误状态和有效计数的交接。

- 上下游：接决策logits与控制状态，经IO/平台接口交回Host。
- 共同设计要求：Host wait/sync之后再读结果；测试台放本模块tb；整网联测放top/tb；状态字段和计数语义服从共同ABI。

规格依据：

- [14_result_status_and_verification.md](../../design_source/14_result_status_and_verification.md)
- [01_host_runtime_and_abi.md](../../design_source/01_host_runtime_and_abi.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
