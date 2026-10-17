# 当前工作：M004算术测量与优化

用户要求调转重心后，首轮KB0＋KB1＋控制架构排序已交付并经主控限定审核。当前执行[KB1之后的阶段合同](measurement_next_stage_20261013.md)，D-M004-KB1-NEXT-01；总体遵守[测量优先重排](hardware_measurement_replan_20261013.md)。

- 已有实测：四行Down KB1的cfg→实际consume21107→16190cycles（减23.30%），全冷48864→43947（减10.06%），完整PS/4096F32及最后B通过。保留四row合并写；物理资源/时序未知。
- 首要下一出口：一个64tile分块调度KB2，检验更早形成完整输出、与后续计算重叠；计入真实A重读82→164的预期代价，原每输出累加顺序与gold/response profile保持。此为新合同，尚未取得新运行结果。
- 次要CT0：32项完整owner固定RAM的REQUIRE/ACQUIRE/RELEASE_READ真实校验/提交，薄HLS优先；可先准备，重工具在算术出口后排队，不成为性能前置。

W加载虽占KB1全冷61.58%，当前服务profile下单改读取器的理想余量最多约825cycles/全冷1.88%；首AW固定时输出额外间隙的乐观界约319cycles。二者不能当已实现收益，下一步不只按最大stall数字扩缓存。

M003生产控制整体executor/冷INIT、CLOSE/rearm与cleanup扩展继续停排，旧证据和未完成义务保留。M003只约束最终生产集成验收。M003/M004、完整请求B0、恢复与联合资源未完成。

A002唯一实现/工具owner，复用现有helpers，不新增agent。代码E002/experiment、证据E005；原全部资源帽、单重工具、G仅OOC余额和5172s不重启保持，无新OOC/P&R/上板。详见[本轮审核](../results/measurement_first_KB1_review_20261013.md)。
