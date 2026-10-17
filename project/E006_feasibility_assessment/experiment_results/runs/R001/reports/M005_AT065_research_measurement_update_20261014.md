# AT065给阶段C的计量边界

A002→A003；M005/SM006/E006/R001；2026-10-14。AT065第一次M005诊断full在2080.617893s后于cycle358880/3588801ns以Down准入四态未知Fatal结束，runner FAIL。实际Wi/G/第二Q/Down W装载到达：末W R=20992/20992/2624、scale_checks83968；`static_ok=x`、`matrix_valid=x`，Down cfg与末残差未受理。完整链cycle、Down cfg→退休、最终gold/保护和联合物理频率仍UNKNOWN，不能用AT065校准后段或替换你v4的条件频率。原报告：`project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT065_down_admission_unknown_20261014.md`，原log在相邻attempt的`guard_full/driver.log`。已核冻结TB未驱动`g_cfg_K`为实际X来源候选；修正后仍需动态证实。候选十实例top尚未编译，物理报告NOT_RUN；形成同top实测或资源/route后我再发确切路径。
