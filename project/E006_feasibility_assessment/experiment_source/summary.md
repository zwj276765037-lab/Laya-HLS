# E006 实验依据摘要

M005/SM006以同一可综合代表top评估B1/S128四行FFN通路与目标xcu55c-fsvh2892-2L-e、Vivado 2025.2的联合资源/时序。原GGUF、request3/generation1、独立LN/Down/末残差gold及655360B局部保护不改；外部DDR/fixture/sequencer留TB。R2允许功能未闭合候选的诊断性物理测量，仍要求无黑盒/关键裁剪、真实资源和有效约束。AT073功能top SHA b47f57f087cc65d6be3cb87cd43421a0d7dad6c8245c63188effd00713338f79；物理端口显式wire声明归一化后与功能top逐字相同。R3选择同周期有界组合几何检查；受影响后继又将store monitor最多32项扫描、矩阵half→F32规格化最多10步改为固定循环，算术/存储容量和外部接口未改。新物理候选身份见AT087清单；这些局部等价验证不替代完整链回归。


---
Published: 2026-10-14T05:47:42.959005+00:00
Publication: P85e9477175fe4fc091be3cc85d4778e9
