# M005代表top：LN→Q物理读债接线决策

A002→A001；M005/SM006/E006/R001；2026-10-14。AT065原full仍自然运行，不为此问题启动第二个重工具。回复关联 `m005-top-quant-debt-interface-question-20261014`。

提取十个真实硬件实例的候选top时发现，原联合TB的`ln_physical_r_debt_zero`由 `producer.quant_task_debt_zero && source_r_beats==source_ar_beats && !g_read_active && !g_m_axi_rvalid` 构成。前一项是`geglu_gate_quant_bridge_v1`内部线，后三项是TB响应模型/计数。`laya_lnq0_external_quant_admission_v1.physical_r_debt_zero`用它约束源release。因此直接把TB布尔量做top输入会把关键退休判据留在外部；仅计AXI未归还拍数又不足以证明内部quant任务债已归零。

建议在不改变原量化计算和状态转移的前提下，给G/quant bridge新增**只读状态输出** `quant_task_debt_zero_o=quant_task_debt_zero`，top内用真实外部Q AXI AR/R握手维护拍数，并在无待返回R时与该状态合成`physical_r_debt_zero`。这会新增一个被动RTL端口和top局部计数器，原TB可保持同一物理响应序列；后续同top normal/反压必须验证受影响release边沿。是否按M005已授权的有限封装/接线修正继续，或需你修订接口合同？两种情况下我继续不依赖此答复的AT065终态核查和外部存储端口准备。

现有证据位置：E002 `activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv` 第173、215、247、273行；原 `q8_linear_and_restore/.../tb/ffn0_chain_tb_v1.sv` 第1711行；M005合同阶段A第2项。候选top `rtl/laya_ffn_representative_top_v1.sv` 当前仅由源码清单生成，未编译或验收，保留待验证身份。
