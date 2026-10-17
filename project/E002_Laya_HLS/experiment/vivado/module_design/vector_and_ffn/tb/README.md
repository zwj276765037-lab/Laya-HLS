# 向量运算、FFN与残差 测试

真实GEGLU、ReLU、残差、type和bias/GELU接入28+2层与尾链，当前完整CPU/CSim逐位通过。 当前源码/模型身份与实际运行范围见[results.md](../source/results.md)。

测试入口：

- [contract_tb.cpp](contract_tb.cpp)：保留P0主机合同测试。
- [full_numeric_tb.cpp](full_numeric_tb.cpp)：P2纯数值直接TB。

完整P2存储、owner、矩阵与整图测试统一位于项目[tests/](../../../../tests/)，避免在各模块复制第二份测试。当前命令、统计、源码身份与未完成阶段见[results.md](../source/results.md)，设计断言与实际源码映射见[design.md](../source/design.md)。
