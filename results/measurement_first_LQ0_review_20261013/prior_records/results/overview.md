# Laya-HLS 当前概览

[CT0集中审核](measurement_first_CT0_review_20261013.md)已接纳原32项owner表的薄HLS生成与有限RTL行为，控制结构实验本轮收束。下一工作回到[16行LN→Q算术测量](../mission/ln_quant_measurement_stage_20261013.md)，不扩大生产控制链。

| 工作 | 当前结论 | 接下来的处理 |
| --- | --- | --- |
| Down KB1 | 同profile完整数值PASS，实际消费延迟-23.30%，全冷-10.06% | 保留，联合资源/时序未知 |
| Down KB2 | 重复COST_STOP，无完整样本，根因UNKNOWN | 本轮停止，不扫参数或加帽 |
| CT0 32项owner | 原helper对照/真实HLS/generated RTL有限PASS | 保存，不扩CT1；不代表生产owner验收 |
| LN→Q LQ0/LQ1 | 新阶段已下达，尚无新测量 | 原冻结rows16实际store重读，先周期分解，再一个有据候选 |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

CT0 normal131事务/73429诊断cycles、两个负例各9事务/5073cycles；周期含装载、读回、序列化和TB等待，不能当生产控制延迟。HLS估计8BRAM18/1DSP/49533FF/39937LUT/0URAM不是物理或联合资源，generated RAM逻辑容量32×5009bit不可直接换算实际映射。

LQ0保留全部16384 LN F32/16384 INT8/512 FP16独立gold与实际65536B写回、Q重读、source lease和末B；原659334只作为冻结历史全TB参考。旧FullRuntime/冷INIT、CLOSE/rearm/cleanup不恢复。

A002唯一实现/工具owner，原单重工具/全部帽保持；G2338.224019s仅OOC余额，无新OOC/P&R/上板/预算，5172s不重启。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
