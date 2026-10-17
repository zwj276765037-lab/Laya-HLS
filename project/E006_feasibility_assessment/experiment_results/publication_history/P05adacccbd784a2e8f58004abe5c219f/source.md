# E006 实验依据摘要

M005/SM006同一可综合代表top验证四行B1/S128 FFN通路，目标part xcu55c-fsvh2892-2L-e、Vivado 2025.2。原GGUF、request3/generation1、独立LN/Down/末残差gold及655360B局部保护保持。真实LN shell、唯一量化/G、唯一矩阵/W/PS、Wi reader、有限handoff和残差叶子在一个top；fixture、DDR响应和外部sequencer留TB，未纳入的Attention/WO/PCIe与生产双lease另计。

D-M005-FEASIBILITY-01-A1要求桥输出真实量化任务债，top按共享Q AXI ARLEN+1/R握手持续计债，内部K固定2624。原AT065入口X为本轮受影响原因候选；AT066短测、AT069/070静态及前缀验证修正，不改算术/独立gold。正常和确定合法反压同top全链、联合综合/route按原M005累计帽顺序执行。

---
Published: 2026-10-14T03:53:00.918760+00:00
Publication: Pe846b818396a4d06989d386a78ff0397
