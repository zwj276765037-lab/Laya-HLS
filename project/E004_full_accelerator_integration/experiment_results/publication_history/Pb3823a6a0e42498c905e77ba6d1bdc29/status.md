# E004：状态

execution_state: running；verdict: unassessed（完整 M004 加速器）。SM004修订6 LN首错已受影响修复、真实LN→Q单行局部功能PASS；AT121复位覆盖勘误由AT124算术在途定向PASS关闭；修订7 Q时序切分开始，联合资源已测；同版150MHz综合内部时序FAIL，关键Q槽序号→除法服务长路径需下一架构阶段集中处理。独立LN OOC额度已用，仅旧版资源；连接联合OOC一次成功后已停止，不重复。当前工具队列空闲，工程结果已交主控审核。真实final gamma、外部AXI/HBM、后继矩阵A读取、完整硬件图、P&R和板端均NOT_RUN；局部功能/面积不代签全图性能。


---
Published: 2026-10-14T17:39:34.197712+00:00
Publication: P11cb3b2497664852ac36ddcd198d9803
Execution state: running
Research verdict: unassessed
Applicability: SM004修订6单行LN→Q局部RTL功能与同版U55C合成资源/内部时序；非完整硬件图或布线频率
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_evidence_20261015.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT121_SM004_lnq_row_final_03/guard_sim/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT116_SM004_lnq_row_ooc_01/work/utilization.rpt
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT116_SM004_lnq_row_ooc_01/work/timing_summary.rpt
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT120_SM004_lnq_dcp_cell_audit_02/guard_static/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT123_SM004_lnq_reset_coverage_02/guard_sim_reset/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT122_SM004_lnq_reset_coverage_01/guard_sim_reset/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT124_SM004_lnq_arithmetic_reset_03/guard_sim_reset/driver.log
