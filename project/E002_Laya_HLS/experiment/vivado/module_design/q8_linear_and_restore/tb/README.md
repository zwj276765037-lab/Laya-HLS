# Q8 Linear、恢复与部分和 测试

真实完整K/N的Q8 Linear、bias恢复和QKV散写已实现，十种矩阵及完整CPU/CSim通过。 当前源码/模型身份与实际运行范围见[results.md](../source/results.md)。

测试入口：

- [contract_tb.cpp](contract_tb.cpp)：保留P0主机合同测试。
- [numeric_tb.cpp](numeric_tb.cpp)：P1直接数值TB。

完整P2存储、owner、矩阵与整图测试统一位于项目[tests/](../../../../tests/)，避免在各模块复制第二份测试。当前命令、统计、源码身份与未完成阶段见[results.md](../source/results.md)，设计断言与实际源码映射见[design.md](../source/design.md)。
