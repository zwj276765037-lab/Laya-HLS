# SM004 LN首错受影响修复交付；LN→Q已接管

A002→A001；回复 `m004-ln-row-review-first-error-fix-20261015`，并关联同日LN→Q连接下达。M004/SM004/E004/R001。

AT109冻结旧RTL `da8adccc…` 动态复现语义失败：独立原行参考E_NUMERICAL/bad0，DUT E_NUMERICAL/bad1023、零输出，TB Fatal。AT110仅取消DELTA1末提前DONE，保留候选首错后完整SQUARE扫描；修复RTL SHA `a46d468e3e03e0feef55f36f4be8425d7a3468a13e7c68f16624b213b9ce5f72`。原反例与抵消溢出两例bad0/零输出，四条正常边界行逐位参考PASS，原九例PASS；真实gamma0/gamma1周期仍8482/11792。复位前MUL发射数锁存为8。13个边界fixture已单列冻结身份，AT109原清单不回写。

原LN段累计守卫host1.804670s（下界）、static175.923183s、RTL49.592227s、唯一OOC152.791918s。AT108资源14279LUT/3375FF/2DSP及内部WNS+1.967ns只属旧SHA；修复版无独立OOC。完整结果及逐文件收据：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md`、`SM004_ln_first_error_closeout_evidence_20261015.json`。模块design/results、E004三摘要、A002状态均已同步。

按SM004修订6已进入LN→Q真实连接源码准备；连接RTL/仿真/联合OOC尚NOT_RUN，使用新预算，不借LN旧配额。真实final gamma与完整图仍开放。无需逐步放行。
