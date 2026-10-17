# E006 实验依据摘要

M005/SM006同一可综合代表top验证B1/S128四行FFN通路，目标part xcu55c-fsvh2892-2L-e、Vivado 2025.2。原GGUF、request3/generation1、独立LN/Down/末残差gold及655360B局部保护不改；真实LN shell、量化/G、唯一矩阵/W/PS、Wi reader、handoff及残差在一个top，外部DDR/fixture/sequencer留TB。AT070 W边沿模型竞争后仅TB W/AUX ready/valid相位锁到negedge，功能DUT/top/gold同SHA。合同R2允许短测定位、有据最后normal full与诊断物理测量。


---
Published: 2026-10-14T04:12:55.817519+00:00
Publication: P05adacccbd784a2e8f58004abe5c219f
