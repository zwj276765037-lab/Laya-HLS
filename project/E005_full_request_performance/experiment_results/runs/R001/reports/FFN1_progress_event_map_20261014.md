# FFN1 被动进展事件接线表（编译前）

2026-10-14；D-M004-FFN-PROGRESS-REPLAY-01；E002 实现 TB `ffn0_chain_tb_v1.sv`，E005/R001 证据。此表定义新观察器的实际输入。总线握手于 `posedge clk` 的 pre-NBA 采样；LN 游标监视器在同一 posedge 使用阻塞赋值，故其累计值于后续 negedge 取差，并在下一 posedge 入账，以消除 active 区竞态。每一分项从冷 reset 后只累加真实握手或一次性算术退休；跨 Wi/Down、首 Q/GATE-Q 不清零。守卫只解析固定完整 schema 的分项计数，任一分项回退/字段缺失/未知字段为非法；重复行与无新事件的状态文本不续 120s。进展计数不反馈 DUT。

| 阶段/打印分项 | 冻结联合 TB 的真实条件 | 累加和审计规则 |
| --- | --- | --- |
| `ln_ar`, `ln_r` | `ln_source.source_axi_arvalid && source_axi_arready`；`source_axi_rvalid && source_axi_rready` | 分别累计读 burst 受理和实际 R beat；不以 ready 或 pending 代替。 |
| `ln_iter` | `ln_source.semantic_progress_count` 在 negedge 的有界非负增量 | 该值仅由生成 LN 核 row/pass0/pass1 游标的已绑定真实推进更新；下降或单半拍超过 7 次立即报错，不把行号重置当新工作。 |
| `ln_write`, `ln_portal` | `destination_axi_aw/w/bvalid && ready`；原 END/PUBLISH 完成包/响应的实际消费边沿 | AW/W/B 分项事件在同拍相加；END/PUBLISH 仅各一次，不靠 `ln_published` 保持电平续命。 |
| `q_accept_release`, `q_read` | `ln_query_valid && ln_query_ready && ln_query_granted`、`ln_source_release_valid && ready && drained`；`g_m_axi_arvalid && ready`、`g_m_axi_rvalid && ready` | 第一次外部 Q 的准入/释放和其真实 NORM AR/R；读分项也覆盖后续 GATE-Q，按实际受理累计。 |
| `q_math`, `a_commit_pub` | `producer.quant_task.q_out_valid && q_out_ready`、`q_done_valid && q_done_ready`；`fa_commit_valid && fa_commit_ready`、`producer.quant_task.a_publish` | 两次 Q 都累计，fullA 物理提交/单次发布分开观察；不能以最终 ready 电平充当发布。 |
| `w0_ar/r`, `w1_ar/r`, `ws_ar/r` | 各 `wc_arvalid[pp] && wc_arready[pp]` 和 `wc_rvalid[pp] && wc_rready[pp]`，pp=0/1/2 | 六个独立分项；同拍三路都握手则六分项各自累加，不由 q0 推断 q1/scale。Wi 和 Down 复用端口，计数不清零。 |
| `aux`, `w_publish` | `wc_aux_arvalid/rvalid && 对应 ready`；`wc_load_done` 的一次上升边沿及实际 W lease/发布消费 | AUX 接受与返回各算实际事件；load_done 保持不续命。 |
| `mat_a`, `mat_w` | `a_read_valid && ready`、`a_ret_valid && ready`；`w_read_valid && ready`、`w_ret_valid && ready` | 请求和真实返回分别计入各 family；两次矩阵任务同一累计。 |
| `mat_ps`, `mat_writer`, `mat_retire` | `|(dut.commit_valid & dut.commit_ready)`、`actual_stripes` 真增量；`m_axi_aw/w/bvalid[0] && ready[0]`；`owner_retire_valid && ready`、`done_valid && done_ready` | PS/stripe 只按提交或核内真实计数正增量，不靠状态抖动；末 B、owner 和 done 消费分别是真实退休事件。 |
| `wi_read`, `wi_consume` | `wi_arvalid && wi_arready`、`wi_rvalid && wi_rready`；`g_wi_valid && g_wi_ready`、`g_wi_row_done_valid && ready` | reader 物理读和交给 G 的标量/行屏障分开；后者不从 DDR 完成文本推断。 |
| `g_issue`, `g_return`, `g_emit` | `producer.vector_row.arithmetic_accept`；`core_commit && core_return_legal`；`producer.v_valid && v_ready` | 三个长算术分项逐项退休，可覆盖无外部总线事务的 G 运算区间。 |
| `gate_write`, `gate_qread`, `gate_qmath` | `g_m_axi_aw/w/bvalid && ready`；`g_m_axi_ar/rvalid && ready`；`producer.quant_task.q_out_valid && q_out_ready`（GATE-Q） | GATE writer 的 AW/W/B 与真实重读及第二次量化提交；与首 Q 计数可交叉核对。 |
| `res_cfg`, `res_source` | `ffn_res_cfg_valid && ffn_res_cfg_ready`；两源各 `ffn_skip/down_ar/rvalid && ready` | 适配器实际受理后才可读；两源 AR/R 都计，局部源锁保持电平不续命。 |
| `res_add`, `res_writer`, `res_done` | `ffn_residual` 的 add 接受/真实 done/槽消费；残差 AW/W/B 三路实际握手；`ffn_res_rsp_valid && ready` 和目标发布首次上升 | 不从预期 22cycle 推算返回；响应仅有效且反压时不续命。 |
| 最终扫描终态 | 正常最终 DDR 与 STATE 窗口检查及边界计量完成后打印 `FFN0_CHAIN_PASS` 并 `$finish` | 这段零仿真时间的 TB 循环没有可供周期守卫累加的真实边沿；终态由原断言和最终 marker 判定，不能把循环下标或持续检查当语义进展。 |

旧 AT057 的 `MATRIX_PROGRESS` 属诊断文本，guard 不接受；其 52 条原 W 日志只用于只读对照。新观察器须有独立短 RTL 微测试及 host 逻辑时间测试，逐项校验本表到固定 schema 的实际连接。若某项冻结信号仅能证明状态而非事件，编译前改为已绑定的真实握手或有因迭代退休，并在受影响 diff 中解释。
