# E006 实验依据摘要

M005/SM006 的问题是：同一真实 FFN 代表通路能否在正常与合法不同反压下逐位算对，联合综合与布线后资源/关键路径是否支持目标器件，以及由真实计算和流量推算的整模性能是否值得继续投入。权威合同为 `mission/M005_代表通路与整模性能可行性评估/contract.md`。

代表范围：B1/S128、request3/generation1、四个不同 token row 的外部 attention residual→LN_FFN→同一 Q/Wi/G/Q/Down→末 F32 residual；独立 gold、真实 AXI 存储交接、末 B/债务/响应/局部 655360B 保护。完整模型预算另计28 Encoder＋2 Decision＋scorer/ACT、122个 Q8 调用、Attention/WO及平台成本。目标 part `xcu55c-fsvh2892-2L-e`，Vivado 2025.2，6.667ns 为首次约束锚点而非已达频率。

控制变量是原 GGUF/ABI/独立 gold/数值顺序、A/W/PS 容量、单 quant/单 matrix/单 residual 算术；新变量限同一可综合顶层包装、确定反压、联合物理测量。E005 原 AT063 已在原帽内停止，不并入 E006 新运行额度；M005 阶段A承接停止事实作受影响定位。外部 sequencer、HBM/PCIe shell 与 Attention 上游不在代表 top 中，整模模型会单列其成本。单重工具及 M005 各类累计/单次帽见合同。


---
Published: 2026-10-14T02:11:00.283760+00:00
Publication: Pcfd731a48c8e49f0b7feb9c7a9017f5e
