# Laya-HLS 当前概览

[GQD0限定接链已验收](measurement_first_GQD0_review_20261013.md)，真实G/量化生成的A已由Down直接消费。下一阶段[WI0](../mission/wi_resident_producer_stage_20261013.md)补齐上游Wi的真实resident矩阵输出；完整加速器仍未验收。

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
| GQD0连续算术链 | 四行normal真实交接/原gold/完成PASS；链区间102634cycles | 限定接纳，Wi仍是外部输入；物理/完整请求未验 |
| WI0实际Wi出口 | 新阶段NOT_RUN；原模型bias0和20992词接点身份已核 | 复用resident验证完整供数/PS/真实writer，之后再接G |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

GQD0全TB102660，合法G接受→Down实际消费102634；含真实加载/交接/排空，未包含Wi计算。GATE部分精确事件时间戳缺失如实保留，不影响本次正常数值与真实交接结论，不加旧局部cycles推算整图。WI0的外部边界为原LN_FFN预量化A，完整671744 PS/20992F32及物理输出待测，不新增第二矩阵引擎。

A002单工具owner，原资源帽、整体控制/冷INIT/恢复停排、G仅OOC余额2338.224019s、5172s不重启、无新HLS/OOC/P&R/上板保持。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
