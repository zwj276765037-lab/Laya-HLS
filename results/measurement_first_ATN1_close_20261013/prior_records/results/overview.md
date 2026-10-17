# Laya-HLS 当前概览

[ATN0完整head计量已核](measurement_first_ATN0_review_20261013.md)，[ATN1正常完整head](measurement_first_ATN1_progress_review_20261013.md)已取得同口径周期改进；同DUT协议回放待终态。原[Attention阶段合同](../mission/attention_softmax_measurement_stage_20261013.md)保持；LQ1R两版修复关闭。

| 工作 | 当前结论 | 接下来的处理 |
| --- | --- | --- |
| Down KB1 | 完整数值PASS，实际消费延迟−23.30%，全冷−10.06% | 保留，联合资源/物理时序未知 |
| Down KB2 | 重复COST_STOP，无完整样本 | 停止，不扫参数或加帽 |
| CT0 32项owner | 原helper/HLS/generated RTL有限PASS | 保存，不扩控制链 |
| LN→Q LQ0 | 独立gold通过，全TB659334 | 保留冻结基线 |
| LN LQ1 | 同gold通过，全TB528307；HLS slack−48.76ns | 保留周期证据，不生产采用 |
| LN LQ1R | 两版slack−0.43/−0.41ns；RTL/F9未运行 | no-go收束，无第三版 |
| Attention ATN0 | 全部原gold通过；全TB1608896，SM287173/EXP270525 | 接纳正常完整head基线 |
| Attention ATN1 | 全原gold通过；SM−7.6919%、正常计算−3.6552%、全TB−1.3729% | AT022同DUT首错/CE/reset回放待终态，尚未采用 |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

ATN0正常计算首次done总和604317，与原v10一致。EXP四worker服务下界224670，当前EXP差45855只是条件乐观空隙；不能当收益或叠加各worker等待。保持M16/A16/D4/EXP4、原数值图及流水；535引用/5guard/63实际policy已核，AT019失败保留。ATN1普通实施继续，不扩生产控制。

A002单工具owner，原资源帽、整体控制/冷INIT/恢复停排、G仅OOC余额2338.224019s、5172s不重启、无新OOC/P&R/上板保持。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
