# E003：R003实际进展

- codec_01：严格C编译与encode/decode负例PASS；独立Python逐字节比较全部1536B PASS。适用当前固定包编解码，不证明硬件数值链。
- transport_05：Vivado2025.2实际RTL PASS，432cycles、accepted4/retired5/stale1；反压、陈旧返回、债务阻止完成、保留位、generation重放、错误当前响应、active/partial cancel及恢复。受控service endpoint明确仅用于transport验证。guard child0、27.376194s、peak1397160KiB、trigger null。
- transport_01/02保留脚本失败，03/04保留TB同delta采样失败；修复只增加刺激后组合逻辑稳定采样，不删断言或修改通过标准。
- matrix_binding_01当前运行：冻结实际resident/native FP/binding与取消TB源码，静态编译后120s RTL pilot。结果待原始日志，不能提前记PASS。

L0 PARTIAL；L1实现中，完整13BO/generated caller和物理LOAD/quant/G hub未闭合。L2–L5 NOT_RUN。旧完整CPU/CSim只适用旧build，当前最终完整回归待实现稳定后执行。局部结果不代签M003，更不代签M004。


---
Published: 2026-10-11T08:48:04.139504+00:00
Publication: Pba3763b0c44746aa91a65ea59a88a8ec
