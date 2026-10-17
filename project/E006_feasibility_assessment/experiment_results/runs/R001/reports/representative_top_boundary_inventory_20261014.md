# M005 代表 top 的当前边界盘点

状态：只读盘点，top 尚未实现或综合；AT063 原冷 full 已在 Down W 发布后有界停止，AT065 的受影响边界观测正在 M005 新帽下运行。基线为 `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/ffn0_chain_tb_v1.sv` 的实际单实例连线。

| 必须在可综合 top 内且只计一次 | 现有接线 | 对外保留的事务边界 |
| --- | --- | --- |
| LN_FFN 生成核/源证明 | `tb/laya_ffn0_source_stage_v1.sv` 内的 `laya_layernorm_producer_portal_shell_v1 dut` | provenance 命令/响应、producer 请求/完成、源 AXI AR/R、目标 AXI AW/W/B；固定只读 skip 的 AXI 响应由外部存储提供。 |
| LN→Q 准入与 G/Q/Wi 桥 | `laya_lnq0_external_quant_admission_v1 ln_q_admit`、`geglu_gate_quant_bridge_v1 producer`（其内同一 `quant_task`/dualA 和 G 算术） | 动态 task/context/Ref，AXI512 读写、完成及 owner/lease。 |
| W 和矩阵 | `laya_lnq0_w_binding_v1 w_binding`、`t4_dual_w_cache_v1 wcache`、`tm4tn8_matrix_owner_ledger_v2 ledger`、`tm4tn8_matrix_resident_v2 dut` | W 的三路512bit＋aux128bit AXI 读；矩阵实际 A/W lease、PS及双写口 AXI，done。Wi 与 Down 分时复用矩阵和严格 W 路径。 |
| Wi 中间结果/末残差 | `laya_wi_axi_reader_v1 wi_reader`、`laya_ffn0_down_residual_admission_v1 ffn_handoff`、`laya_ffn0_residual_four_row_v1 ffn_residual` | Wi 实写 DDR 的真实 reader AR/R；Down 成功退休后一次残差准入；残差双源 AXI512 AR/R、目的 AW/W/B 和完成。一个生成 F32 加法叶子及槽在 residual 内。 |

当前 `laya_ffn0_source_stage_v1` **不是**可综合计算顶层：第94–96行有 fixture `source_mem/gold_mem/destination_mem`、第190行起 TB tasks、第397行起 `$readmemh` 和测试初始流程。联合 TB 第562/609行还有字节 DDR/gold 数组，第2159行起加载多份 fixture；这些只属于外部仿真/存储服务，不能进入资源网表。其真正 `laya_layernorm_producer_portal_shell_v1` 以及上表其它 RTL/IP 才是 top 的候选硬件。当前数据源的物理行为是 TB AXI responder；M005 顶层应暴露这些 AXI 主口，由 TB 提供相同模型字节和独立 gold 检查。

联合 TB 的 `stage`/`initial` 序列、地址映射数组、AXI responder 与 `tick`、故意反压属于外部诊断 sequencer/存储模型。生产请求调度、HBM 平台 shell、PCIe、Attention/WO 上游不在代表 top 内；其面积、时间和可用带宽在整模预算中单列 UNKNOWN/条件值。不同反压样本必须复用冻结的同一 top/core 和 gold，而不能通过 TB 数组在阶段间注入 Wi、GATE、Down 中间结果。

待实施前检查：把 LN shell 从 TB source-stage 拆到代表 top，保持 source query/release 及实际 AXI 行为；将另九个实例接入同一 top，标定内部连接与对外 task/AXI 端口。冻结模块树、所有 RAM 容量、IP/ROM/XDC 和实例数，再编译正常与不同背压样本。此盘点不作 PASS、资源或时序结论。
