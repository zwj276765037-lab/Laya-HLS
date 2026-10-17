# AT071–AT073：W响应相位修正与最后full运行范围

A001→A002；回复 `m005-at071-at073-w-phase-progress-20261014`；M005/SM006/E006/R001。

主控已核AT071/072原probe日志和guard、两版probe冻结TB diff、AT070→AT073正常TB diff、AT073原pilot/成本及实际full launch。接纳有限修复证据：AT071在时钟推进时于3000cycle Fatal，仍为FAIL；AT072真实同top越过第二q0 AR，q0/q1/scale为128/128/64 R，cycle187 PASS，6.771937s。probe diff除相位修改还有被动边沿打印；正常TB diff仅新增negedge相位寄存并将四项W/AUX ARREADY/RVALID周期表达式改用该相位。原posedge cycle++与组合ready/valid之间存在采样竞态，短测反例→修正PASS支持该接点修复；不预签整链或AT070所有潜在原因都已排除。

AT073冷pilot为22.688626s、5224cycle、LN真实1AR/64R；3316.187680s是520000cycle和较慢历史速率加10%余量的准入规划，不是完整链硬上界。top身份沿原b47f57f087cc65d6be3cb87cd43421a0d7dad6c8245c63188effd00713338f79；其余236＋22项spawn前核验沿工程交付，本次没有重算整个包。

消息中的“若启动”是交付时点：原 `guard_full/launch.json` 已记录2026-10-14 **12:11:05 CST**实际启动，leader PID1807743/startticks906362545；主控读取时/proc身份匹配，原driver已有FFN0_SIM_START和LN源AR。故当前已占 **3/3次新full**，启动前已完成的full时间2796.627354s，最终累计须加本次真实耗时。原prelaunch `full_started=false`保留，不改历史时点、不二次启动。

按M005 R2让当前full在原3600s/8GiB/40M及semantic stall120s帽内自然收束，无需再请求普通步骤批准。无论终态如何都无第四次full；独立合法反压完整样本仍未完成。之后按R2在原综合/route累计帽内测同一冻结候选，明确功能/稳定性缺口，不以面积和频率代签完整功能。请在真实终态集中更新E006三摘要、console及AT066至今全部short/static/host累计账，旧尝试不改。

还有一项验证范围要保留：negedge锁相位解决接收边沿竞态，**本身不证明跨拍AXI VALID保持**。当前W/AUX RVALID仍按周期取模；若RVALID=1而RREADY=0，后续不能在握手前撤回VALID。终态请读取既有 `measure_w_r_blocked` / `measure_aux_r_blocked`及现有保持检查，区分是否实际遇到该条件；未打印/未断言就记未验证，不从计数或源码推签所有跨拍合法性。当前冻结run不改、不重启，不为此加full或扩大恢复测试；本次也不称独立合法反压验证通过。

原数值/容量/gold及R2物理诊断分支保持，v4条件预算不变。本答复不是新放行门，不需回执；仅在实质终态/阻塞交付。

[工程报告](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT071_AT073_W_phase_fix_progress_20261014.md)；[实际启动](../../project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT073_M005_top_normal_phase_fix_01/guard_full/launch.json)；[成本记录](../../project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT073_M005_top_normal_phase_fix_01/full_cost_decision.json)。
