# SM004 修订18 AT301–306 工程阶段交付

回复 D-M004-LNQ-COST-OWNER-01 / D-M004-REV18-COST-STATIC-01。当前生产core SHA `a73632b8…`，wrapper/sequencer仍为`5c88716f…`/`a4c999e5…`。AT302旧版真实复现Q16部分窗口中kind01 index0覆盖已有效A row0且cover未清；AT303当前core局部拒绝不兼容prep/命令、保持原272字，合法后续行/abort/partial discard及新epoch逐位PASS。只签局部占有与生命周期，不签父图16个真实行。

AT304默认与AT305实际被xelab接受的`--O3`在同一修复SHA、TB、fixture、FP/IP闭包下固定30000cycle，38条cycle事件逐字一致，2048 norm与128笔B逐位/握手通过；全次source192R含未退休row2的64R。guard运行93.29140920005739s→89.64230179227889s，单次约3.91%改善；静态148.10003847070038s/147.29114942997694s。AT306据合同自动做120秒真实完整请求pilot，只退休row0/1，120.30851850099862s、child−9/timeout、COST_STOP；无16行窗口，未启动LN128长例，NORM_STAGE_READY未通过。AT301静态timeout及AT305首次路径child127均保留。

AT301–306共12笔原guard：static7笔742.38596129976213734/900s、RTL5笔363.27006784640254/2400s，756项manifest SHA及101条实际CPU0–3/nice19/idle政策零差异；host完整UNKNOWN。剩余157.61403870023786266s/2036.72993215359746s请按阶段审核处理，不挪旧修订余额。修订17勘误已同步：manifest1821、AT297全次source192。E004同一报告、模块design/results、三摘要和A002状态已更新；M004/SM004仍running/unassessed。

原始报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev18_q16_owner_ln128_cost_engineering_handoff_20261015.md`；机读账：同目录`SM004_rev18_guard_ledger_AT301_AT306_20261015.json`；A/B：同目录`SM004_rev18_ln128_default_vs_O3_cost_20261015.json`。下一最小可执行边界建议单列共享活跃LNQ/bank/prep/source/norm服务验证层，父top保持唯一实例，先测完整16行；本修订没有实施结构/CE/时钟/算术改动，也没有实际128行/父图PASS。请按冻结身份和局部范围集中审核并衔接下一合同。
