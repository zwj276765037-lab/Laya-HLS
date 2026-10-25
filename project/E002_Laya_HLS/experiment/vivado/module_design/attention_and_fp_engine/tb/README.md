# Attention与共享浮点引擎 测试

全部16head的QK/softmax/AV及尾层FP计算接入整图，当前CPU与标准libm CSim逐位通过。 当前源码/模型身份与实际运行范围见[results.md](../source/results.md)。

测试入口：

- [contract_tb.cpp](contract_tb.cpp)：保留P0主机合同测试。
- [full_numeric_tb.cpp](full_numeric_tb.cpp)：P2纯数值直接TB。

完整P2存储、owner、矩阵与整图测试统一位于项目[tests/](../../../../tests/)，避免在各模块复制第二份测试。当前命令、统计、源码身份与未完成阶段见[results.md](../source/results.md)，设计断言与实际源码映射见[design.md](../source/design.md)。


## M007 current strict shared runner

For the current strict mul/add closure use `m007_shared_strict_run.py {reference|build|rtl} {4|256|compat} ATnnn_name`. It freezes the new mul8/add8/credit/v2/v1/TB closure and uses independent AT015/AT001 primitive expectations. New multiply single-lane flow is `m007_strict_mul_run.py {reference|build|rtl|ooc} ATnnn_name`. Always use a fresh AT; original attempt inputs/logs are immutable.

The earlier m007_shared_fp_run.py, m007_shared_fp256_run.py and m007_shared_compat_run.py document historical pre-mul-replacement procedures; reproduce them against their frozen old source closures and command records. They are not current-module entrypoints. Do not replay unchanged add/div baselines for this multiplier change.
