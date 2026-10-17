# E004：状态

execution_state: running；verdict: unassessed（完整M004加速器）。SM004修订8工程段已到有界出口：同版Q/LN→Q局部功能PASS，联合OOC在第二次启动的时序优化阶段COST_STOP，未得到新DCP或资源/时序结论；两次启动上限已用。无本项目owned重工具运行。主控据此决定后续矩阵A连接或物理障碍处理。真实final gamma、外部AXI/HBM、矩阵A、完整硬件图、P&R、板端和整模性能仍NOT_RUN；本局部PASS不代签全图。

AT133已完成原AT131 DCP的有界只读查询（child0、trigger null）：错误状态三个端点组各有违例路径；q0/q1写数据RAM pin有匹配但无有效时序路径。修订7static已测累计269.456193s；细节见[AT133报告](../experiment_results/runs/R001/reports/SM004_AT133_q_return_targeted_timing_20261015.md)。此查询没有启动新OOC或更改候选身份。

AT134静态/Q及LN→Q仿真均child0/null；AT135普通构建缺IP Tcl为FAIL，AT136前置时钟已被综合解析应用但`semantic_stall`、child−9/无DCP。修订8static57.873714s、RTL30.857233s、OOC300.249388s，启动2/2。详见[同一工程报告](../experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。AT131资源/WNS仍仅属旧Q候选；新候选150MHz结论UNKNOWN。

---
Published: 2026-10-14T18:07:19.519519+00:00
Publication: Pb3823a6a0e42498c905e77ba6d1bdc29
Execution state: running
Research verdict: unassessed
Applicability: SM004修订8同版Q/LN→Q局部RTL功能；本版U55C联合物理COST_STOP；修订7旧资源/时序不可迁移；非完整硬件图或布线Fmax
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_q_partition_stage_evidence_20261015.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT130_SM004_q_partition_tie_06/guard_sim/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT130_SM004_q_partition_tie_06/guard_lnq_sim/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT130_SM004_q_partition_tie_06/guard_lnq_reset/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/work/utilization.rpt
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/work/timing_summary.rpt
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/work/blackboxes.txt
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT132_SM004_lnq_partition_dcp_audit_01/guard_static/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT134_SM004_q_error_metadata_01/guard_sim/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT134_SM004_q_error_metadata_01/guard_lnq_sim/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT135_SM004_lnq_error_metadata_ooc_01/guard_ooc/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT136_SM004_lnq_error_metadata_ooc_02/guard_ooc/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT136_SM004_lnq_error_metadata_ooc_02/work/vivado.log
