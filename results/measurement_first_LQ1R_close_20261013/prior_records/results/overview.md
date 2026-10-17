# Laya-HLS 当前概览

[LQ1集中审核](measurement_first_LQ1_review_20261013.md)已接纳16行LN→真实store→Q/fullA的数值与19.8726%全测试周期下降；时序估计未通过。下一入口是[这两项浮点运算的寄存器流水修复](../mission/ln_quant_timing_repair_stage_20261013.md)，先回答周期收益能否在原时钟目标下保留。

| 工作 | 当前结论 | 接下来的处理 |
| --- | --- | --- |
| Down KB1 | 完整数值PASS，实际消费延迟−23.30%，全冷−10.06% | 保留，联合资源/物理时序未知 |
| Down KB2 | 重复COST_STOP，无完整样本，根因UNKNOWN | 本轮停止，不扫参数或加帽 |
| CT0 32项owner | 原helper/HLS/generated RTL有限PASS | 保存，不扩控制链 |
| LN→Q LQ0 | 全部独立gold通过，全TB659334 | 保留原冻结基线 |
| LN LQ1 | 同gold通过，全TB528307；HLS slack−48.76ns | 保存周期候选，不作为部署收益 |
| LN LQ1R | AT017注册映射生效，II9、slack−0.43ns，RTL未跑 | 仅剩第二版减法加一级；仍违例则按原上界停止 |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

LQ1的正常样本三向DDR196608B不变；LN run518354含读算写，Q实际消费区间3266。仅16行诊断窗口，不外推完整S64、模型或稳态。新增两个native FP IP均零内部流水，实际调度同状态串接形成53.626ns路径；这支持局部流水修复方向，不预签任何具体约束有效。

A002唯一实现/工具owner，原单重工具与分类帽保持。整体控制/冷INIT/恢复扩展继续停排；G2338.224019s仅OOC余额，无新OOC/P&R/上板/预算，5172s不重启。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
