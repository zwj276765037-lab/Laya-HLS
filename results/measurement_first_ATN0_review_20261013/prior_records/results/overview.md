# Laya-HLS 当前概览

[LQ1R两版有界修复已停止](measurement_first_LQ1R_close_20261013.md)。下一阶段转向[Attention softmax计量与一个同资源调度候选](../mission/attention_softmax_measurement_stage_20261013.md)，不再追加LN延迟参数试验。

| 工作 | 当前结论 | 接下来的处理 |
| --- | --- | --- |
| Down KB1 | 完整数值PASS，实际消费延迟−23.30%，全冷−10.06% | 保留，联合资源/物理时序未知 |
| Down KB2 | 重复COST_STOP，无完整样本 | 停止，不扫参数或加帽 |
| CT0 32项owner | 原helper/HLS/generated RTL有限PASS | 保存，不扩控制链 |
| LN→Q LQ0 | 独立gold通过，全TB659334 | 保留冻结基线 |
| LN LQ1 | 同gold通过，全TB528307；HLS slack−48.76ns | 保留周期证据，不生产采用 |
| LN LQ1R | 两版slack−0.43/−0.41ns；RTL/F9未运行 | no-go收束，无第三版 |
| Attention ATN0/ATN1 | 新阶段NOT_RUN；历史SM占正常head47.52% | 先真实计量服务/等待，仅做一个有据调度候选 |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

Attention原v10正常完整head604317cycles、SM287173，仅作选择依据。新阶段保持原M16/A16/D4/EXP4、FP/EXP寄存器与数值图、真实QK→SM→AV及完整独立gold；不把47.52%当节省潜力，不重跑算术HLS/OOC。源93/原snapshot81身份已核，实际执行由工程报告。

A002单工具owner，原资源帽、整体控制/冷INIT/恢复停排、G仅OOC余额2338.224019s、5172s不重启、无新OOC/P&R/上板保持。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
