# 总体集成 测试

28层Encoder、2层Decision及scorer/act已完整连接；当前包的CPU整图与真实13口HLS CSim通过。 当前源码/模型身份与实际运行范围见[results.md](../source/results.md)。

测试入口：

- [contract_tb.cpp](contract_tb.cpp)：保留P0主机合同测试。
- [numeric_fixture_test.py](numeric_fixture_test.py)：P1真实模型切片与独立参考。
- [fixture_contract_test.py](fixture_contract_test.py)：P0真实输入格式/布局回放。

完整P2存储、owner、矩阵与整图测试统一位于项目[tests/](../../../../tests/)，避免在各模块复制第二份测试。当前命令、统计、源码身份与未完成阶段见[results.md](../source/results.md)，设计断言与实际源码映射见[design.md](../source/design.md)。

[Vivado OOC工程](../../../project/README.md)目前只完成创建与依赖检查，未运行完整顶层RTL协同仿真；本目录没有新增虚构的RTL测试台。
