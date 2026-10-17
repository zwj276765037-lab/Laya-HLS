# 向量、FFN与残差

当前状态（2026-10-07，P2 F0功能验证通过）：真实GEGLU、ReLU、残差、type和bias/GELU接入28+2层与尾链，当前完整CPU/CSim逐位通过。 分阶段证据见[source/results.md](source/results.md)。

处理U/G配对、GELU/gate、ReLU、type add及residual。

- 上下游：与Q8 Linear、量化及旧hidden缓存连接，也为scorer/act提供向量操作。
- 共同设计要求：Wi/down复用Q8引擎；U/G配对、4→8速率转换和旧hidden保留条件一起评估。

规格依据：

- [12_vector_and_ffn.md](../../design_source/12_vector_and_ffn.md)
- [09_q8_linear_and_restore.md](../../design_source/09_q8_linear_and_restore.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
