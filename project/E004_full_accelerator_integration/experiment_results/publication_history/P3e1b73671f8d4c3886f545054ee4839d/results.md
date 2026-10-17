# E004：限定结果

AT091 完整软件正常请求 47 项/4,523,596 F32 对独立 gold 逐字节 PASS；Attention 仍为 CPU 叶子。AT101 受控 AXI4 向量服务 4096 项正常/反压 6955/7206cycle，AT099 仅单 lane 流局部 OOC 1283 LUT/614 FF。

AT109 独立原行反例期望 E_NUMERICAL/bad0；旧 RTL 实测 bad1023、零输出，为语义 FAIL。修复版 SHA `a46d468e…` 的 AT110 六条边界行及原九条整行回归 PASS，四条正常边界行所有输出和统计值逐位比较；真实 gamma0/gamma1 仍为 8482/11792cycle，复位前 MUL 发射8。AT108 旧 SHA `da8adccc…` 唯一 OOC 为14279 LUT/3375 FF/2 DSP、0 BRAM/URAM、综合内部 WNS+1.967ns@6.667ns；这些资源和时序不适用于修复版。LN 守卫累计 host1.804670s（下界）、static175.923183s、RTL49.592227s、OOC152.791918s。详见[阶段报告](runs/R001/reports/SM004_ln_row_stage_result_20261015.md)及[收据](runs/R001/reports/SM004_ln_first_error_closeout_evidence_20261015.json)。真实 final gamma 与完整硬件图仍未证。


---
Published: 2026-10-14T16:49:43.609186+00:00
Publication: Pcbf41c1f8fe4497688d4c89f1aa1eab4
