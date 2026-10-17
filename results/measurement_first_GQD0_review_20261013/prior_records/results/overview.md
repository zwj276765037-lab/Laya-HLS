# Laya-HLS 当前概览

[ATN1限定候选已保留并收束](measurement_first_ATN1_close_20261013.md)。下一阶段转入[GQD0真实G→量化→KB1 Down连续链](../mission/g_quant_down_integration_stage_20261013.md)，移除Down入口的预量化A注入，取得实际数据交接的新基线。

| 工作 | 当前结论 | 接下来的处理 |
| --- | --- | --- |
| Down KB1 | 完整数值PASS，实际消费延迟−23.30%，全冷−10.06% | 保留，联合资源/物理时序未知 |
| Down KB2 | 重复COST_STOP，无完整样本 | 停止，不扫参数或加帽 |
| CT0 32项owner | 原helper/HLS/generated RTL有限PASS | 保存，不扩控制链 |
| LN→Q LQ0 | 独立gold通过，全TB659334 | 保留冻结基线 |
| LN LQ1 | 同gold通过，全TB528307；HLS slack−48.76ns | 保留周期证据，不生产采用 |
| LN LQ1R | 两版slack−0.43/−0.41ns；RTL/F9未运行 | no-go收束，无第三版 |
| Attention ATN0 | 全部原gold通过；全TB1608896，SM287173/EXP270525 | 接纳正常完整head基线 |
| Attention ATN1 | 原gold及同DUT首错/CE/reset通过；SM−7.6919%、正常计算−3.6552%、全TB−1.3729% | 限定保留，本轮结束；物理/生产未验 |
| GQD0连续算术链 | q/scale独立期望同源；新链NOT_RUN | 真实G→量化→共享dualA→KB1 Down，Wi输出仍为外部输入 |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

G桥04与KB1四行×82组数据口径有字节身份依据；旧两段PASS/周期不拼成新链。GQD0以真实存储交接、背压、最后B、lease及实际done消费为出口；普通连接/验证连续推进，不先扩完整控制。ATN1新准备状态在pending/ready下CE保持与reset清空已验，正常排空是有界源码不变量加动态佐证，不扩大为全状态形式证明。

A002单工具owner，原资源帽、整体控制/冷INIT/恢复停排、G仅OOC余额2338.224019s、5172s不重启、无新OOC/P&R/上板保持。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
