

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C017 · GQD0 上游 Wi 接点只读核对

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### measurement-first-GQD0-upstream-Wi-identity-20261013

2026-10-13T12:05:24.384970+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# GQD0 上游 Wi 接点只读核对

2026-10-13；M004/SM005/E005/R001。此记录只比对已存在的输入与独立期望，不是新 RTL 测试或下一阶段执行合同。

AT025 的 `work/fixtures/g/wi.mem` 与原四 distinct 行 G 桥04的 `work/fixture/wi.mem` 逐字节相同，均为 20,992 行十六进制 F32 bit pattern，SHA256 为 `3451f215f3e775d9c50cad722131fd0322a8c7ae557f74c14f80d2b753b197a7`。将每行按 32-bit little-endian 解释，与本项目 `t2_widown_av_fixtures_01/work/fixtures/wi_rows4_output_f32.bin` 的 20,992 个词逐一比较，全部相同；该二进制文件 SHA256 为 `b5542b2f20473041f9f420cc740ebef48343c714b98b6748c0f5ba1c5cff4d25`。前者是当前链的声明外部输入，后者是旧冻结独立参考的 Wi 输出。不同文件编码的 SHA 不应直接比较。

既有 `t2_tm4_real_wi_lut_full_01` 已在 K1024/N5248、四行完整 20,992 stripes / 671,744 group records 上核对整数、中间 FP/PS 和 trace，原 guard 用时 668.561s；原阶段表明确它**没有 bias 或生产 writer 输出**。`matrix_parent_cache_03` 的正常样本是预量化 fullA 的 16 行父矩阵四 view，不含实际 G/量化 producer，也不能作为本四行 Wi→G 接链的现成上游。现有量化和 W 供数结果各有局部覆盖，但还没有同一进程中真实 Wi 生产者写出的 20,992 个 F32 被 GQD0 消费的样本。

因此，上游若选择 Wi 接入，关键验证边界是原 Wi 源 A/权重供数→完整 PS/bias→真实 F32 writer 及末 B/发布→G 桥按真实地址与身份读入；逐词用上述独立期望比较，并保持 GQD0 原 10496 GATE、量化、Down PS/输出、最后 B、lease 与实际消费检查。接口、成本和具体入口仍由主控下一阶段合同确定，不能用两段既有 PASS 拼出新连接结论。

来源：

- `project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/input_manifest.json` 与 `work/fixtures/g/wi.mem`
- `project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04/work/fixture/wi.mem`
- `project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/wi_rows4_output_f32.bin`
- `project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md`（Wi TM4 完整算术与未覆盖范围）
- `project/E003_production_chain_closure/experiment_results/runs/R003/matrix_parent_cache_03/receipt.json`


[原始消息收据](../../.research-agent/communications/measurement-first-GQD0-upstream-Wi-identity-20261013.json)

相关文件：[input_manifest.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/input_manifest.json) · [wi.mem](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04/work/fixture/wi.mem) · [wi_rows4_output_f32.bin](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/wi_rows4_output_f32.bin) · [stage_results.md](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md) · [receipt.json](../../project/E003_production_chain_closure/experiment_results/runs/R003/matrix_parent_cache_03/receipt.json)

## 相关决定和审核

- [measurement_first_GQD0_review_20261013](../../results/measurement_first_GQD0_review_20261013.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
