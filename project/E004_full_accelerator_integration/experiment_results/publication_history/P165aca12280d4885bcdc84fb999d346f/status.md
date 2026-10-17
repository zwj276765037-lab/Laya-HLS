# E004：状态

execution_state: running；verdict: unassessed（完整M004加速器）。SM004修订8同版Q/LN→Q功能局部PASS、AT138联合综合网表与正式资源已得到，但6.667ns综合内部WNS−1.408ns，150MHz检查FAIL；AT139 RAM写数据脚查询缺口保留。未做P&R，实际Fmax未知。AT135–137原失败/COST_STOP收据不改；AT138后不再同候选OOC。修订8已测OOC1078.301400s、static118.292583s，无本项目owned重工具运行。

现转入已授权SM004修订9真实单行LN→Q→完整Wi连接：front外部abort接口及旧调用点静态接线准备中，尚无新连接RTL PASS或冷/暖完整命令。真实final gamma、完整硬件图、G/Down后继、连续全请求、P&R、板端和整模性能仍未验证；旧P1八列数据不用于完整Wi row0验收。详细范围见[同一工程报告](../experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。


---
Published: 2026-10-14T19:02:22.087285+00:00
Publication: P3438b4f1888a4f998544f896dc2ce8f6
Execution state: running
Research verdict: unassessed
Applicability: SM004修订8同版LN→Q局部功能PASS；AT138综合网表/资源已得但6.667ns内部WNS−1.408ns FAIL；修订9真实LN→Q→完整Wi尚未运行，非完整硬件图或布线Fmax
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT134_SM004_q_error_metadata_01/guard_lnq_sim/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT138_SM004_lnq_error_metadata_ooc_tcl_tolerance_04/source_manifest.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT138_SM004_lnq_error_metadata_ooc_tcl_tolerance_04/guard_ooc/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT138_SM004_lnq_error_metadata_ooc_tcl_tolerance_04/work/timing_summary.rpt
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT139_SM004_lnq_current_dcp_target_timing_01/work/targeted_endpoints.tsv
