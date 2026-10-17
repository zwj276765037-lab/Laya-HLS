# E006 实验依据摘要

权威合同为 `mission/M005_代表通路与整模性能可行性评估/contract.md`。问题是同一真实FFN代表通路能否在正常与不同合法反压下逐位算对，联合综合/布线资源与频率能否支持U55C，以及完整模型的流水性能是否值得继续投入。

代表样本为B1/S128、request3/generation1、四个不同token row的外部attention residual→LN_FFN→单Q/Wi/G/Q/Down→末F32 residual；保留原GGUF/ABI、独立gold、A/W/PS容量、真实AXI及局部655360B保护。part为`xcu55c-fsvh2892-2L-e`，Vivado 2025.2；6.667ns只是首约束。外部sequencer、DDR/HBM响应模型、PCIe shell及Attention上游单列，不能混入可综合top。

AT063是E005旧帽下的停止事实；E006新AT064短测和AT065第一次诊断full承接其Down边界。AT065只增强被动时钟/入口打印及四态断言，冻结功能DUT、正常激励、ROM和gold保留；本次只签实际受影响边界。M005累计预算与单重工具规则见合同。


---
Published: 2026-10-14T03:04:44.588058+00:00
Publication: P071897ad1cc341c88ffed07cf3601a12
