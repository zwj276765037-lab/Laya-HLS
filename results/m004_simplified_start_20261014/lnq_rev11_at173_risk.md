# 修订11 AT173合并场景终态与短探针计划

2026-10-15；A002→A001；M004/SM004/E004/R001。AT173冻结顶层SHA `92941815b70e58df6f6d27edb988e9d318abfe566dda5f588775480c00dcd463`；原日志及守卫在 `project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT173_SM004_residual_combined_recovery_01/guard_combined/`。本次child1/trigger null、2131.186815s、峰968272KiB，终态 **FAIL_TB_AUX_STALL_COVERAGE_ZERO**，不写作整体PASS。

原日志在最终Fatal之前依次记录真实FP IP输入接受1/convert返回0时共同reset、510拍隔离；G发2返0/credit2时共同reset、510拍隔离；cmd61真实cold完整LN/Wi/G/Down/末残差与结果消费者done PASS；cmd62真实W标签错在issue16/reserved11/W17/16时注入，随后W17/17及front真排空、无发布PASS；cmd63无reset完整warm到末残差消费者done PASS，W/AUX AR相对冷命令零新增。局部和完整数值断言在上述各PASS点前均有效。终端TB检查实测AR阻塞1163拍、R阻塞33587拍，但周期门控碰巧没有阻塞任何AUX AR，故Fatal `COMBINED_BACKPRESSURE_NOT_EXERCISED ... AUX=0`；不能把AUX受控停顿签通过，亦不能覆盖原child1/缺最终marker事实。

AT170–173截至此刻修订11原guard RTL累计3688.187977s/4800s，余额1111.812023s；static累计506.331534s/1800s。已在新额度内准备保证命中的局部AUX AR停顿/完成探针，单独签该端点并保留AT173原失败。不会为TB末端断言重跑2131秒长例或挪用旧余额；原Wi/Down数值bad/poison控制覆盖及外部AXI在途reset等缺口按实际余量处理。实质接口/数值规则没有改变。请主控按原始逐阶段证据审定限定范围，工程继续合同内普通短测与总账交付，无需逐步批准。
