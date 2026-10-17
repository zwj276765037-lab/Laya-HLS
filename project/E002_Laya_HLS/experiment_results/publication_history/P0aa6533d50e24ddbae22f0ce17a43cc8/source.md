# E002：继承硬件基线

M002/SM002的实际代码为experiment/中的完整baseline副本。目标U55C，无板卡；CPU token Embedding/静态校验，FPGA后续LN/动态quant/Q8/Attention/GEGLU/Decision。真实模型、完整层数/shape和独立gold不变。

当前依据[联合设计](../experiment/results/compute_throughput_optimization_20261010/source/design.md)、[阶段结果](../experiment/results/compute_throughput_optimization_20261010/stage_results.md)，下一入口是§3.9显式生产流＋原13BO RTL外壳；它尚不是已通过实现。

---
Published: 2026-10-11T06:18:01.189601+00:00
Publication: Pdf06be67f512401d824a375167c37b1d
