# E006 实验依据摘要

M005/SM006以同一可综合代表top评估B1/S128四行FFN通路及目标xcu55c-fsvh2892-2L-e、Vivado 2025.2的联合资源/时序。原GGUF、request3/generation1、独立LN/Down/末残差gold及655360B局部保护不改；外部DDR/fixture/sequencer留TB。R2允许功能未闭合候选的诊断性物理测量，仍要求无黑盒/关键裁剪、真实资源和有效约束。AT073功能top SHA b47f57f087cc65d6be3cb87cd43421a0d7dad6c8245c63188effd00713338f79；AT075起仅将156个输入端口显式声明为wire logic，归一化该声明后源码与AT070功能top逐字相同。AT077又以同SHA原hub的等价固定上界几何检查替代一处不可综合动态循环；该物理候选未取得完整链功能回归，仅AT076局部portal短测。


---
Published: 2026-10-14T05:01:01.974269+00:00
Publication: P3c3cecbaa5494e768d1d19f149f276cf
