# E004：状态

execution_state: running；verdict: unassessed（完整M004加速器）。SM004修订10 AT166真实LN→Q→Wi→G→Q→Down单行cold/warm完整正常数值PASS_SCOPED；AT168 Wi行流水在途与AT169 G已发未返的共同reset后510拍隔离各PASS_SCOPED。AT167 guard误判计数回退COST_STOP及原费用保留。修订10正确累计static1113.567624s/1800s、RTL3459.293175s/3600s，余RTL140.706825s不足再跑真实cold前缀；host未全采样UNKNOWN。数值bad/poison错误映射、错误后完整warm、复位后完整cold、主动内部反压/读释放竞争及外部AXI在途reset仍NOT_RUN。末残差、Attention/完整图、外部HBM、联合物理/Fmax及整模性能仍未知；旧AT138较小LNQ的150MHz内部时序FAIL不迁移至本顶层。工程本阶段有限证据已交主控集中审核，M004继续running。


---
Published: 2026-10-14T22:17:28.254852+00:00
Publication: P7f958afab3f94a998d5d5c0044a15cfa
Execution state: running
Research verdict: unassessed
Applicability: SM004修订10真实单行LN→Q→Wi→G→Q→Down完整正常cold/warm数值PASS_SCOPED；Wi行流水/G在途共同reset后510拍隔离PASS_SCOPED；Wi浮点IP已发未返未证明；复位后完整恢复、错误后完整warm及联合物理未验
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT166_SM004_down_ret_pair_index_full_01/guard_rtl/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT167_SM004_wi_fp_common_reset_01/guard_rtl/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT168_SM004_wi_fp_reset_guard_epoch_02/guard_rtl/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT169_SM004_g_inflight_common_reset_01/guard_rtl/guard_result.json
