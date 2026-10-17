# Laya-HLS 当前概览

[KB1集中审核](measurement_first_KB1_review_20261013.md)已完成：同四行Down冷样本、同反压策略，完整335872 PS/4096F32与末B通过。合并写保留；cfg→实际消费21107→16190cycles，减少23.30%；全冷48864→43947，减少10.06%；写事务512→256，有效16KiB保持。

| 工作 | 真实状态 | 下一出口 |
| --- | --- | --- |
| KB0/KB1算术对照 | AT001/AT002有限PASS，主控已核 | 本轮完成，保留KB1；联合资源和物理时序未知 |
| 下一算术候选KB2 | 已有据no-go退出，full/同snapshot诊断共3次COST_STOP | 未取得完整样本，不判收益或根因，不继续重跑 |
| 控制架构CT0 | schema已准备，原入队条件满足；生成/行为待交 | 32项真实RAM校验/提交有限实验，单工具原帽 |
| 完整请求/恢复/资源 | M003/M004未完成 | 生产集成最终验收依赖保留，不阻塞局部优化 |

W加载27064cycles接近该TB供数下界26239，单改读取器的乐观余量最多约825cycles；输出profile串行B服务也限制单纯加深缓存的收益。KB2分块调度候选未取得完整样本而按停止规则退出；目前转到既定CT0有限实验，不扩大控制工作范围。上述下界只适用于所述profile。

[下一合同](../mission/measurement_next_stage_20261013.md)已下达；原[测量优先重排](../mission/hardware_measurement_replan_20261013.md)继续有效。整体FullRuntime/executor HLS、冷INIT与恢复扩展不恢复。A002唯一工具owner；单重工具与全部原帽保持，无新OOC/P&R/上板，G2338.224019s仅OOC余额，5172s不重启。

局部数值和cycle不代表全模型/真实HBM/稳态吞吐或完整请求。完整证据及历史指标见[硬件指标](hardware_metrics.md)与[SM005审核历史](reviews/SM005.md)。

[KB2停止核定](measurement_first_KB2_stop_review_20261013.md)：两版52源/24fixture核查、94唯一引用、8串行guard/126policy；仅末条进展重复，根因未知。
