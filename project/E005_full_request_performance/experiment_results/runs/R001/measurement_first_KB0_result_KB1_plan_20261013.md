# KB0实际算术出口及KB1选择

M004/SM005/E005/R001，AT001已实际PASS_SCOPED_KB0_DOWN_MEASUREMENT，当前KB0工具自然收束。原4distinct预量化Down/K2624/N1024，335872 lane-group PS、4096 F32与原独立gold全比；真实512AW/W/B、最后B/局部publication与一次done消费通过。

全TB48864（原48862加实际consume/deassert检查）；cfg→first done21100，cfg→actual consume21107，故意7cycle done反压保持；A填充666、W加载27064且都在cfg前。互斥state之和21100，接口stall重叠单列。writer packet-not-ready7761、已送AW/W无B8705、PScommit-not-ready9586/nativecredit7414；held_B9217仅TB延迟decrement计数不相加成DUT延迟。有效16KiB/物理32KiB，strobe50%；W加载三路R-not-ready0。

据真实输出工作量和反压选KB1：单pack改按row的4pack，合并相邻半拍，仍一个immutable AXI tx/原验证/最后B及同响应策略、7hold。待实测512→256事务、16KiB物理，额外1923bits逻辑pack字段，物理资源/时序UNKNOWN。只读正常路径audit已交，无新owner/退休权威；继承error窗口未测，局部normal不签通用恢复。A002现在按原授权直接启动新AT002 static/pilot/full，不等控制schema，不新增候选之外工作。

P3已按主控答复收束，薄HLS优先设计/RTL备选仅排序，具体真实表更新目标未冻结。KB1结果后集中交同口径差值及取舍。原单工具/帽/G仅OOC余额、不重启5172s/无新OOC/P&R/上板不变。

证据：project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_Down_measurement_20261013.md；AT001/evidence/measurement/receipt.json及measurement_full.json；reports/KB1_rowpack_static_audit_20261013.md/.json。
