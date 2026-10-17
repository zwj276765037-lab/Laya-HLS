# Laya-HLS 当前概览

[LQ0集中审核](measurement_first_LQ0_review_20261013.md)已接纳原冻结16行LN→真实store→Q/fullA基线。工作继续聚焦一个LN流水候选的实测收益与代价，控制框架不成为算术测量的前提。

| 工作 | 当前结论 | 接下来的处理 |
| --- | --- | --- |
| Down KB1 | 同profile完整数值PASS，实际消费延迟-23.30%，全冷-10.06% | 保留，联合资源/时序未知 |
| Down KB2 | 重复COST_STOP，无完整样本，根因UNKNOWN | 本轮停止，不扫参数或加帽 |
| CT0 32项owner | 原helper对照/真实HLS/generated RTL有限PASS | 保存，不扩CT1；不代表生产owner验收 |
| LN→Q LQ0 | 16384 LN F32/16384 INT8/512 FP16通过，全TB659334 | 作为同口径基线，LN run649380含读算写 |
| LN LQ1 | AT015限定生成，实际II2，HLS时序估计slack -48.76ns | 连续完成同口径RTL与代价判断，收益待验 |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

LQ0真实65536B LN写回供Q重读，三向DDR共196608B，末B/END/发布/lease/fullA/零债务保持。只有16行诊断窗口；不外推完整S64或模型性能。LQ1源仅一行pragma，报告循环估计10249→2049不能替代动态收益，HLS时序估计也不是物理WNS/Fmax。

A002唯一实现/工具owner，原单重工具/全部帽保持。旧FullRuntime/冷INIT、CLOSE/rearm/cleanup不恢复。G2338.224019s仅OOC余额，无新OOC/P&R/上板/预算，5172s不重启。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
