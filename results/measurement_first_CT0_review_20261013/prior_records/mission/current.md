# 当前工作：M004算术测量与优化

用户要求调转重心后，首轮KB0＋KB1＋控制架构排序已交付并经主控限定审核。当前执行[KB1之后的阶段合同](measurement_next_stage_20261013.md)，D-M004-KB1-NEXT-01；总体遵守[测量优先重排](hardware_measurement_replan_20261013.md)。

- 已有实测：四行Down KB1的cfg→实际consume21107→16190cycles（减23.30%），全冷48864→43947（减10.06%），完整PS/4096F32及最后B通过。保留四row合并写；物理资源/时序未知。
- KB2已按本轮成本/重复停止规则退出：两次full及一次同snapshot诊断COST_STOP，末条marker相同，无完整数值/周期样本，根因UNKNOWN；保留KB1，不扩大块大小搜索或重跑。
- 当前CT0：KB2有据no-go已满足原入队条件，工程按32项完整owner固定RAM的REQUIRE/ACQUIRE/RELEASE_READ合同连续推进薄HLS/有限RTL。schema已准备，实际生成/行为结果尚未交付；限定出口后集中评判，不扩完整控制链。

W加载虽占KB1全冷61.58%，当前服务profile下单改读取器的理想余量最多约825cycles/全冷1.88%；首AW固定时输出额外间隙的乐观界约319cycles。二者不能当已实现收益，下一步不只按最大stall数字扩缓存。

M003生产控制整体executor/冷INIT、CLOSE/rearm与cleanup扩展继续停排，旧证据和未完成义务保留。M003只约束最终生产集成验收。M003/M004、完整请求B0、恢复与联合资源未完成。

A002唯一实现/工具owner，复用现有helpers，不新增agent。代码E002/experiment、证据E005；原全部资源帽、单重工具、G仅OOC余额和5172s不重启保持，无新OOC/P&R/上板。详见[本轮审核](../results/measurement_first_KB1_review_20261013.md)。

最新[KB2停止核定](../results/measurement_first_KB2_stop_review_20261013.md)区分末条marker与实际停拍；旧摘要由工程同步，不作为新的运行事实。
