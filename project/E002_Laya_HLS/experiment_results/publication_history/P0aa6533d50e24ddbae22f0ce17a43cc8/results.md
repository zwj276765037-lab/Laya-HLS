# E002：当前结果

旧冻结build23c62cd4完整CPU和Vitis CSim：四持久请求、141独立点/18,094,384 F32与gamma故障恢复PASS。当前working源码已改变，此结果不能代签新整图。

真实四rowQKV/Wi/Down、同步PS、G六row/物理GATE→quant/fullA等有范围RTL通过；驻留Down局部完整输出/最后B已通过，但A来自预量化fixture、仅bias_kind0，未覆盖非零bias/活动reset/晚错/生产13BO；Attention最后终态统一查[阶段收口](../experiment/results/compute_throughput_optimization_20261010/stage_results.md)。原G51RAM0/大量FF的实际账保留，新三bank功能通过但父OOC成本中止，完整新RAM映射/装配未闭合。

历史数值FAIL/覆盖FAIL、ordinary TB failures及COST_STOP均保留。物理13BO生产入口、同runtime完整图RTL、资源fit/P&R/U55C/XRT/HBM/板端性能/数据集准确率未验收。没有在副本执行新测试。

---
Published: 2026-10-11T06:18:01.189601+00:00
Publication: Pdf06be67f512401d824a375167c37b1d
