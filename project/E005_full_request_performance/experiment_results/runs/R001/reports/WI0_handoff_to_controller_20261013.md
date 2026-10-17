# WI0 限定结果交付；M004/SM005/E005/R001

回复 measurement-first-GQD0-review-WI0-dispatch-20261013；A002 唯一实现/工具。本轮 WI0 AT028 static、W前缀pilot、四行normal full均PASS，原始[报告](WI0_resident_producer_20261013.md)、[复核](WI0_evidence_check_20261013.json)、[收据](../attempts/AT028_WI0_resident_03/receipt.json)与E005三摘要已发布；当前无本项目重工具。

四distinct预量化LN_FFN A经真实dualA/严格三W缓存/唯一resident/KB1 writer，20,992 Wi F32、671,744 PS lane-group均按原独立gold通过。W q0/q1/scale实际R为41,984/41,984/5,248；输出1,312 AW/W/B、83,968有效/物理B、末B、A/W lease、局部发布及一次done消费闭合。cfg→首次done46,911cycles，→实际消费46,918；全冷101,335。W LOAD→READY 54,124cycles。AT028 full guard893.130500s/peak1,456,184KiB，child0/null；三guard串行、45实际policy合规。28冻结源/脚本与22fixture逐SHA/bytes复核，相对KB1仅TB与两入口Tcl派生；三尝试间冻结DUT和数据fixture相同。

AT026源ref从Down GATE误继承导致A fill拒绝，pilot FAIL；AT027修成Wi NORM ref2后pilot达120.371s硬帽，记COST_STOP；AT028只补真实W进展/前缀pilot，full按启动前3,000s估计进入并完成。原失败不改写。

重要限定：TB对每笔真实AW边界、WSTRB、输出地址唯一性和F32位型逐项动态检查，因而该事务模型中未观察到范围外写；它**没有独立byte-addressed DDR哨兵数组的最终读回**，原合同“范围外哨兵保持”的字面测试未完成。请主控据此限定本次接纳范围。Wi→G同runtime、生产请求/恢复、联合资源及物理时序仍NOT_RUN；勿把WI0与GQD0周期相加。按原合同，下一步可集中选择单矩阵引擎分时复用与Wi实际存储重读→G的最小接点；不擅自恢复整体executor或增加本轮工具帽。
