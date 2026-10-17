# E005当前状态

execution_state: running（E005总体继续；FFN3合同因唯一full语义FAIL已停止，当前无本项目重工具）；verdict: inconclusive（E005整体）。AT062 host运行包与真实LN prefix通过，唯一冷full在Wi完成后由冻结TB报`Fatal: WIGQD Wi reader cfg rejected`；后段G/Down/残差及联合终检未到达，FFN3不重跑。共享BO描述符由DDR重绑STATE1导致Wi reader配置范围不合法的只读定位与原始证据见[FFN3报告](../experiment_results/runs/R001/reports/FFN3_typed_runtime_semantic_failure_20261014.md)。待主控集中判断后继受影响合同；普通Q/L/整体executor仍停排，M003/M004开放。

execution_state: running（E005总体继续；FFN2合同在准备期有界停止，当前无本项目重工具）；verdict: inconclusive。AT060四项verify-only局部通过，AT061 Bash loader误用ldd退出1；一次有因准备修正已用尽，xsim未启动，真实prefix/full与新联合结果NOT_RUN，full未准入。后继需主控另立合同，不在FFN2重开。证据见[FFN2报告](../experiment_results/runs/R001/reports/FFN2_bounded_preparation_stop_20261014.md)。

execution_state: running（E005总体继续；FFN1合同有界停止，当前无本项目重工具）；verdict: inconclusive，适用于SM005/E005整体。AT059真实前缀未进xsim，full成本不准入且未启动；本合同一次有因准备修正已用尽。已通过的静态编译、观察器微测试、逻辑时间与两类短负例只签各自局部范围。工程已将停止事实和可复核的直接xsim后继入口交主控集中判断；不自行在FFN1追加pilot/full。

FFN1新同runtime四行末残差结果NOT_RUN；AT057 LN/Q/W真实前缀、AT049到Down与AT054局部残差原结论保持。证据见[停止报告](../experiment_results/runs/R001/reports/FFN1_bounded_prefix_preparation_stop_20261014.md)和[AT059收据](../experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/receipt.json)。

execution_state: running（FFN0合同有界停止，当前无本项目重工具）；verdict: inconclusive，适用于SM005/E005整体。AT057唯一四行full额度已使用，状态COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER。新同runtime FFN链未通过；主控集中判断是否另立受影响守卫修复合同。工程不在旧合同重启full。

AT057 static、定向短适配器及真实LN源AR/R前缀通过；full达到LN源阶段PASS、Q接受和Wi W真实读取，后段Down TMP/末残差及最终保护均未到达。full child−9/semantic_stall、785.690s、峰1036212KiB；权重R仍增长而冻结进展观察器停在840。原AT049到Down与AT054局部残差PASS各保留其原范围，不拼接为联合PASS。AT056短测Fatal及AT047/AT048旧失败保持原样。

普通多窗口Q/L、生产双源lease、Attention/WO上游、28+2层/122矩阵、13BO请求/恢复、联合资源/时序/上板与M003/M004继续开放；整体executor停排。原单重工具、CPU0–3/nice19/idle、所有资源帽与G OOC余额不变；无新HLS/OOC/P&R/上板。


---
Published: 2026-10-14T00:21:15.354169+00:00
Publication: P9fa647398263428ead4e1b5bfd861dc3
Execution state: running
Research verdict: inconclusive
Applicability: AT060仅隔离包及四项host preflight；AT061准备失败。FFN2无新xsim/pilot/full；E005/M004未完成
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN2_bounded_preparation_stop_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT060_FFN2_direct_xsim_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT061_FFN2_direct_xsim_02/receipt.json
