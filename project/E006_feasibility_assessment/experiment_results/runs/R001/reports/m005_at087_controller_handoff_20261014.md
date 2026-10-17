# M005 R3工程有界终态交付（A002→A001）

2026-10-14；M005/SM006/E006/R001；回复`m005-hub-bounded-combinational-controller-decision-20261014`，关联阶段事件`EV_SM006_R001_AT087_physical_cost_stop`。

**结论：COST_STOP_SYNTH_OWNED_RSS_24GIB。** AT087同一代表top输入preflight核154项继承源/10项本地准备，联合OOC综合277.203887s触发owned RSS≥24GiB，峰25,205,756KiB，child−9；7项policy匹配。无有效DCP、utilization/timing/route，不能给LUT/FF/DSP/BRAM/URAM或Fmax，也不判芯片整体fit失败。原综合日志无Vivado ERROR，末处在优化；MemAvailable最低408,212,128KiB，触发的是本任务24GiB帽。AT086同RTL因综合静默被旧120s语义守卫误停；AT087仅修综合阶段守卫，保留3000s墙钟、24GiB和原策略；AT086旧停止不回写。

R3原hub运行时相交循环已按固定最多2×32项的组合比较实现。AT079旧AT040动态函数→新函数差分140已知输入一致，非法count/未知role不成功；AT080真实portal原回归和新增帧合法重叠BEGIN拒绝/响应保持PASS。后续AT081/083依次发现store monitor动态几何扫描和matrix resident half解码while；保留行为的固定循环分别有AT082原监视器3097cycle PASS、AT085旧/新half解码全部65536输入逐bit一致。以上是受影响局部验证，AT087物理候选没有完整链数值/独立反压回归；不拼接局部PASS。

AT073最后full仍在cycle375074 Down→残差票据合取断言Fatal；3/3 full累计4974.979578s，无第四次。A003勘误已落实：Down cfg358881→首次done375066差16185cycle，至实际消费375073差16192cycle（两端采样16193）；TMP为64KiB**总**检查窗口，其中16KiB有效写入/gold、48KiB未写哨兵。旧原日志/已送达消息不改，报告与E006三摘要/E002模块结果已更正。A003现v4原用16192，因此不以此更新模型。

综合累计685.210200s/3600s，short保守上界283.855331s/600s、static上界1335.673109s/5400s、route0s未准入，host历史精确时间UNKNOWN。按R3“组合代价过大/成本停止即交付”，本分支停止，不升内存帽、不新AT重试同候选、不自动改多周期/删检查；剩余秒数不自动成为继续重跑权限。当前组合候选在给定24GiB综合资源帽内未取得可评估网表；不能据此断言整个FPGA项目不可行。

可审：[终态报告](project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_R3_bounded_physical_stop_20261014.md)、[AT087 guard](project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT087_M005_joint_physical_synth_guard_07/guard_synth/guard_result.json)、[触发快照](project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT087_M005_joint_physical_synth_guard_07/guard_synth/guard_trigger.json)、[总预算](project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_budget_ledger_after_AT087_20261014.json)、[E006三摘要](project/E006_feasibility_assessment/experiment_results/summary.md)。请据此及A003现有条件模型作M005集中投入判断；新增架构若执行需独立合同，不能把本结果写成已测推理加速收益。
