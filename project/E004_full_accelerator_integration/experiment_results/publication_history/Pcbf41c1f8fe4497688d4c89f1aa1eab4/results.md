# E004：限定结果

AT091 完整软件正常请求 47 项/4,523,596 F32 对独立 gold 逐字节 PASS，实际 Attention 为 CPU 叶子。AT101 受控 AXI4 向量服务 4096 项正常/反压 6955/7206cycle，8AR/512R/4AW/256W/4B；AT099 仅单 lane 算术流 OOC 为 1283LUT/614FF，非搬运服务面积。

LN：AT104 固定 CE 16 组连续 MUL/DIV/SQRT 独立位模式匹配，观测 lag14/12/6、所测 II1。AT107 同版完整单行 RTL 九例 PASS：真实 gamma0 8482cycle，真实 embedding gamma1 含反压 11792cycle，mean/variance/inverse 及各 1024 个 y 对保存独立核验夹具逐位相同；gamma2 仅复用 gamma1 数据。错误首错/无输出、连续行与局部在途 reset 后新行通过。AT106 child0 但 `LN_GOLD` Fatal，为原语义 FAIL。

AT108 唯一同版 U55C OOC DCP 已生成、blackbox0；14279 LUT（8510 logic、5460 distributed RAM、309 SRL）、3375 FF、2 DSP、0 BRAM/URAM。综合内部 WNS+1.967ns@6.667ns；输入72/输出179无外部 delay且未布线，不是物理 Fmax。单条 critical warning 为同 SHA ADD 定义重复读入。OOC152.791918s/峰 owned RSS4314552KiB，无资源触发；LN 守卫累计 host0.373702s（下界）、static106.040047s、RTL29.865697s、OOC152.791918s。详见[阶段报告](runs/R001/reports/SM004_ln_row_stage_result_20261015.md)与[机读身份/guard收据](runs/R001/reports/SM004_ln_row_stage_evidence_20261015.json)。真实 final gamma、外存/联合图、连续硬件请求和 P&R 均未测。

---
Published: 2026-10-14T16:21:32.853404+00:00
Publication: P7c48b55e54284f29bbd65dec515c35a1
