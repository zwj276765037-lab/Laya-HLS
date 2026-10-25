

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# M004 · 完整Laya加速器搭建与性能优化

[任务合同](../M004_%E5%AE%8C%E6%95%B4Laya%E5%8A%A0%E9%80%9F%E5%99%A8%E6%90%AD%E5%BB%BA%E4%B8%8E%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96.md) · [任务总结](../../results/missions/M004_summary.md)

## 执行子任务与主控审核

| 子任务 | 定义 | 完整审核历史 |
| --- | --- | --- |
| SM004 · 全模型集成与完整请求验证 | [定义](../../project/missions/SM004.md) | [审核](../../results/reviews/SM004.md) |
| SM005 · 完整请求性能优化与资源闭合 | [定义](../../project/missions/SM005.md) | [审核](../../results/reviews/SM005.md) |

## 关联实验

- [E004 · full_accelerator_integration](../../project/E004_full_accelerator_integration/README.md) — running（M004完整目标）；verdict: unassessed（完整加速器）。主控D-M004-REV14-CLOSEOUT-01已按分版证据有界收束SM004修订14：AT225旧wrapper真实row0冷/row1暖RAW→RoPE正常链限定PASS；当前wrapper `0d3e340e…`的AT230–241受影响控制/传输局部和AT232真实core/IP展开PASS；AT236/237/242原full-Check叶子与生产ad…
- [E005 · full_request_performance](../../project/E005_full_request_performance/README.md) — running（FFN0合同有界停止，当前无本项目重工具）；verdict: inconclusive，适用于SM005/E005整体。AT057唯一四行full额度已使用，状态COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER。新同runtime FFN链未通过；主控集中判断是否另立受影响守卫修复合同。工程不在旧合同重启full。

## 任务总结原文摘录

# M004：旧主线暂停，保留未完成范围

updated: 2026-10-17
execution_state: paused
verdict: unassessed
review_state: historical_evidence_preserved

用户此前“先暂停，等我通知”仍有效。新 [当前Goal](../../goal/goal.md) 与 [M006 合同](../M006_CPU_FPGA%E5%8D%8F%E5%90%8C%E9%AB%98%E6%80%A7%E8%83%BD%E6%8E%A8%E7%90%86%E5%AE%9E%E7%8E%B0/contract.md)已完成文档并成为当前方向，M004 不再是当前实施主线，也没有因此验收完成。

[本次转换前总结原文](../../results/missions/M004_summary_before_codesign_20261017.md)保存全部历史判断。旧独立 LN128→W→A16、矩阵局部与父请求前缀结果仅在原身份/断言范围有效，完整旧父图和模型/Host-HBM/联合物理仍未闭合。

AT404 审核待续；工程暂停回报称 AT405–408 源码、日志和费用已保留。本轮不审核或升级这些结果，不新封修订22费用总账。旧 FAIL/COST_STOP、未测项和预算余额原样保留，不能转入 M006。

恢复后的复用由新架构依赖决定，不要求先完成旧控制测试全集。工程与研究仍暂停；当前没有新实现派发。

## 相关决定、变更与讨论

- [bootstrap_snapshot_f14_reply_20261012](../../results/bootstrap_snapshot_f14_reply_20261012.md)
- [bootstrap_source_guard_f15_reply_20261012](../../results/bootstrap_source_guard_f15_reply_20261012.md)
- [bootstrap_source_guard_prototype_reply_20261012](../../results/bootstrap_source_guard_prototype_reply_20261012.md)
- [controller_internal_split_reply_20261012](../../results/controller_internal_split_reply_20261012.md)
- [controller_streaming_adapter_reply_20261012](../../results/controller_streaming_adapter_reply_20261012.md)
- [controller_transaction_adapter_f10_reply_20261012](../../results/controller_transaction_adapter_f10_reply_20261012.md)
- [controller_transaction_f6_f7_reply_20261012](../../results/controller_transaction_f6_f7_reply_20261012.md)
- [controller_transaction_f8_adapter_hls_reply_20261012](../../results/controller_transaction_f8_adapter_hls_reply_20261012.md)
- [controller_transaction_split_host_reply_20261012](../../results/controller_transaction_split_host_reply_20261012.md)
- [executor_actor_f17_reply_20261013](../../results/executor_actor_f17_reply_20261013.md)
- [executor_bootstrap_snapshot_reply_20261012](../../results/executor_bootstrap_snapshot_reply_20261012.md)
- [executor_bootstrap_source_contract_20261012](../../results/executor_bootstrap_source_contract_20261012.md)
- [executor_bootstrap_source_reply_20261012](../../results/executor_bootstrap_source_reply_20261012.md)
- [executor_cancel_f18_reply_20261013](../../results/executor_cancel_f18_reply_20261013.md)
- [executor_checkpoint_high_water_contract_20261012](../../results/executor_checkpoint_high_water_contract_20261012.md)
- [executor_checkpoint_high_water_reply_20261012](../../results/executor_checkpoint_high_water_reply_20261012.md)
- [executor_checkpoint_host_reply_20261013](../../results/executor_checkpoint_host_reply_20261013.md)
- [executor_checkpoint_import_handshake_contract_20261013](../../results/executor_checkpoint_import_handshake_contract_20261013.md)
- [executor_checkpoint_import_handshake_reply_20261013](../../results/executor_checkpoint_import_handshake_reply_20261013.md)
- [executor_checkpoint_rtl_reply_20261013](../../results/executor_checkpoint_rtl_reply_20261013.md)
- [executor_close_f19_f20_reply_20261013](../../results/executor_close_f19_f20_reply_20261013.md)
- [executor_close_rearm_contract_20261013](../../results/executor_close_rearm_contract_20261013.md)
- [executor_close_rearm_reply_20261013](../../results/executor_close_rearm_reply_20261013.md)
- [executor_cold_init_structure_reply_20261013](../../results/executor_cold_init_structure_reply_20261013.md)
- [executor_first_baseline_program_q_reply_20261013](../../results/executor_first_baseline_program_q_reply_20261013.md)
- [executor_first_hls_cost_stop_reply_20261013](../../results/executor_first_hls_cost_stop_reply_20261013.md)
- [executor_handoff_actor_host_reply_20261013](../../results/executor_handoff_actor_host_reply_20261013.md)
- [executor_handoff_shell_reply_20261013](../../results/executor_handoff_shell_reply_20261013.md)
- [executor_hls_structure_progress_reply_20261013](../../results/executor_hls_structure_progress_reply_20261013.md)
- [executor_managed_lpv_owner_contract_20261013](../../results/executor_managed_lpv_owner_contract_20261013.md)
- [executor_managed_lpv_owner_reply_20261013](../../results/executor_managed_lpv_owner_reply_20261013.md)
- [executor_managed_lpv_reply_20261013](../../results/executor_managed_lpv_reply_20261013.md)
- [executor_managed_query_reply_20261013](../../results/executor_managed_query_reply_20261013.md)
- [executor_minimum_hardware_chain_reply_20261013](../../results/executor_minimum_hardware_chain_reply_20261013.md)
- [executor_old_ltx_cleanup_contract_20261013](../../results/executor_old_ltx_cleanup_contract_20261013.md)
- [executor_owned_purpose_coverage_reply_20261013](../../results/executor_owned_purpose_coverage_reply_20261013.md)
- [executor_program_content_mapping_reply_20261013](../../results/executor_program_content_mapping_reply_20261013.md)
- [executor_program_rtl_inputs_structure_reply_20261013](../../results/executor_program_rtl_inputs_structure_reply_20261013.md)
- [executor_program_validator_adapter_reply_20261013](../../results/executor_program_validator_adapter_reply_20261013.md)
- [executor_request_close_reply_20261013](../../results/executor_request_close_reply_20261013.md)
- [executor_revoke_unaccepted_action_contract_20261013](../../results/executor_revoke_unaccepted_action_contract_20261013.md)
- [executor_revoke_unaccepted_action_reply_20261013](../../results/executor_revoke_unaccepted_action_reply_20261013.md)
- [executor_second_stop_program_generation_reply_20261013](../../results/executor_second_stop_program_generation_reply_20261013.md)
- [executor_wide_fifo_program_repair_reply_20261013](../../results/executor_wide_fifo_program_repair_reply_20261013.md)
- [gate_ordinary_portal_reply_20261012](../../results/gate_ordinary_portal_reply_20261012.md)
- [gate_parent_stage_review_reply_20261011](../../results/gate_parent_stage_review_reply_20261011.md)
- [gate_quant_matrix_cost_review_reply_20261011](../../results/gate_quant_matrix_cost_review_reply_20261011.md)
- [gate_split_current_reply_20261012](../../results/gate_split_current_reply_20261012.md)
- [gate_split_stage_review_reply_20261011](../../results/gate_split_stage_review_reply_20261011.md)
- [generated_provenance_base_reply_20261012](../../results/generated_provenance_base_reply_20261012.md)
- [generated_provenance_cancel_fence_reply_20261012](../../results/generated_provenance_cancel_fence_reply_20261012.md)
- [generated_provenance_channel_contract_20261012](../../results/generated_provenance_channel_contract_20261012.md)
- [generated_provenance_controller_f1b_reply_20261012](../../results/generated_provenance_controller_f1b_reply_20261012.md)
- [generated_provenance_monitor_reply_20261012](../../results/generated_provenance_monitor_reply_20261012.md)
- [generated_source_binding_reply_20261012](../../results/generated_source_binding_reply_20261012.md)
- [graph_lifecycle_f11_f13_reply_20261012](../../results/graph_lifecycle_f11_f13_reply_20261012.md)
- [graph_lifecycle_split_host_reply_20261012](../../results/graph_lifecycle_split_host_reply_20261012.md)
- [graph_program_consumption_reply_20261012](../../results/graph_program_consumption_reply_20261012.md)
- [graph_program_top_reply_20261012](../../results/graph_program_top_reply_20261012.md)
- [graph_sequencer_structural_reply_20261012](../../results/graph_sequencer_structural_reply_20261012.md)
- [guarded_layernorm_f16_reply_20261012](../../results/guarded_layernorm_f16_reply_20261012.md)
- [hardware_progress](../../results/hardware_progress.md)
- [layernorm_producer_portal_reply_20261012](../../results/layernorm_producer_portal_reply_20261012.md)
- [layernorm_quant_source_f9_reply_20261012](../../results/layernorm_quant_source_f9_reply_20261012.md)
- [matrix_parent_cache_stage_review_reply_20261011](../../results/matrix_parent_cache_stage_review_reply_20261011.md)
- [measurement_first_ATN0_review_20261013](../../results/measurement_first_ATN0_review_20261013.md)
- [measurement_first_ATN1_close_20261013](../../results/measurement_first_ATN1_close_20261013.md)
- [measurement_first_ATN1_progress_review_20261013](../../results/measurement_first_ATN1_progress_review_20261013.md)
- [measurement_first_CT0_review_20261013](../../results/measurement_first_CT0_review_20261013.md)
- [measurement_first_FFN0_review_20261014](../../results/measurement_first_FFN0_review_20261014.md)
- [measurement_first_FFN1_destination_clarification_20261014](../../results/measurement_first_FFN1_destination_clarification_20261014.md)
- [measurement_first_FFN1_review_20261014](../../results/measurement_first_FFN1_review_20261014.md)
- [measurement_first_FFN2_review_20261014](../../results/measurement_first_FFN2_review_20261014.md)
- [measurement_first_FFN3_review_20261014](../../results/measurement_first_FFN3_review_20261014.md)
- [measurement_first_FFR0_review_20261014](../../results/measurement_first_FFR0_review_20261014.md)
- [measurement_first_FFR0_review_query_20261014](../../results/measurement_first_FFR0_review_query_20261014.md)
- [measurement_first_FFR1_connection_query_20261014](../../results/measurement_first_FFR1_connection_query_20261014.md)
- [measurement_first_FFR1_review_20261014](../../results/measurement_first_FFR1_review_20261014.md)
- [measurement_first_FFREF0_fadd_query_20261014](../../results/measurement_first_FFREF0_fadd_query_20261014.md)
- [measurement_first_FFREF0_result_handoff_20261014](../../results/measurement_first_FFREF0_result_handoff_20261014.md)
- [measurement_first_FFREF0_review_20261014](../../results/measurement_first_FFREF0_review_20261014.md)
- [measurement_first_GQD0_review_20261013](../../results/measurement_first_GQD0_review_20261013.md)
- [measurement_first_KB0_review_20261013](../../results/measurement_first_KB0_review_20261013.md)
- [measurement_first_KB1_reply_20261013](../../results/measurement_first_KB1_reply_20261013.md)
- [measurement_first_KB1_review_20261013](../../results/measurement_first_KB1_review_20261013.md)
- [measurement_first_KB2_stop_review_20261013](../../results/measurement_first_KB2_stop_review_20261013.md)
- [measurement_first_LNF0_review_20261014](../../results/measurement_first_LNF0_review_20261014.md)
- [measurement_first_LNQ0_review_20261014](../../results/measurement_first_LNQ0_review_20261014.md)
- [measurement_first_LNQ1_review_20261014](../../results/measurement_first_LNQ1_review_20261014.md)
- [measurement_first_LNQ2_residual_query_20261014](../../results/measurement_first_LNQ2_residual_query_20261014.md)
- [measurement_first_LNQ2_review_20261014](../../results/measurement_first_LNQ2_review_20261014.md)
- [measurement_first_LNQI0_review_20261014](../../results/measurement_first_LNQI0_review_20261014.md)
- [measurement_first_LNREF0_review_20261014](../../results/measurement_first_LNREF0_review_20261014.md)
- [measurement_first_LQ0_review_20261013](../../results/measurement_first_LQ0_review_20261013.md)
- [measurement_first_LQ1R_close_20261013](../../results/measurement_first_LQ1R_close_20261013.md)
- [measurement_first_LQ1_review_20261013](../../results/measurement_first_LQ1_review_20261013.md)
- [measurement_first_M003_schedule_reply_20261014](../../results/measurement_first_M003_schedule_reply_20261014.md)
- [measurement_first_P0_review_20261013](../../results/measurement_first_P0_review_20261013.md)
- [measurement_first_P3_design_review_20261013](../../results/measurement_first_P3_design_review_20261013.md)
- [measurement_first_QAR0_review_20261014](../../results/measurement_first_QAR0_review_20261014.md)
- [measurement_first_QWIGQD0_review_20261014](../../results/measurement_first_QWIGQD0_review_20261014.md)
- [measurement_first_WI0_review_20261013](../../results/measurement_first_WI0_review_20261013.md)
- [measurement_first_WIGQD0_review_20261013](../../results/measurement_first_WIGQD0_review_20261013.md)
- [measurement_first_WIGQD1_review_20261013](../../results/measurement_first_WIGQD1_review_20261013.md)
- [method_verdicts](../../results/method_verdicts.md)
- [mission_scope_revision_20261011](../../results/mission_scope_revision_20261011.md)
- [model_identity_13bo_contract_20261011](../../results/model_identity_13bo_contract_20261011.md)
- [model_identity_13bo_reply_20261011](../../results/model_identity_13bo_reply_20261011.md)
- [ordinary_linear_provenance_contract_20261012](../../results/ordinary_linear_provenance_contract_20261012.md)
- [ordinary_linear_provenance_reply_20261012](../../results/ordinary_linear_provenance_reply_20261012.md)
- [ordinary_source_quant_reply_20261012](../../results/ordinary_source_quant_reply_20261012.md)
- [overview](../../results/overview.md)
- [portal_generation_answer_message_20261011](../../results/portal_generation_answer_message_20261011.md)
- [production_hls_partition_contract_20261012](../../results/production_hls_partition_contract_20261012.md)
- [production_source_switch_hls_reply_20261012](../../results/production_source_switch_hls_reply_20261012.md)
- [program_generation_lifecycle_fsm_reply_20261012](../../results/program_generation_lifecycle_fsm_reply_20261012.md)
- [quant_g_answer_message_20261011](../../results/quant_g_answer_message_20261011.md)
- [quant_g_portal_contract_v2_20261011](../../results/quant_g_portal_contract_v2_20261011.md)
- [review_queue](../../results/review_queue.md)
- [v2_parent_stage_review_reply_20261011](../../results/v2_parent_stage_review_reply_20261011.md)
- [work_focus_switch_immediate_20261013](../../results/work_focus_switch_immediate_20261013.md)
- [C001 · M003/L1：请项目主控核定 quant/G 门户身份映射](../../communication/C001_M003_L1%EF%BC%9A%E8%AF%B7%E9%A1%B9%E7%9B%AE%E4%B8%BB%E6%8E%A7%E6%A0%B8%E5%AE%9A%20quant_G%20%E9%97%A8%E6%88%B7%E8%BA%AB%E4%BB%BD%E6%98%A0%E5%B0%84/thread.md)
- [C003 · D-M003-QUANT-G-V2：portal generation 生命周期补充问题](../../communication/C003_D-M003-QUANT-G-V2%EF%BC%9Aportal%20generation%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E8%A1%A5%E5%85%85%E9%97%AE%E9%A2%98/thread.md)
- [C004 · 工程阶段证据：v2 / portal generation / 预约 / 独立父A lease](../../communication/C004_%E5%B7%A5%E7%A8%8B%E9%98%B6%E6%AE%B5%E8%AF%81%E6%8D%AE%EF%BC%9Av2%20_%20portal%20generation%20_%20%E9%A2%84%E7%BA%A6%20_%20%E7%8B%AC%E7%AB%8B%E7%88%B6A%20lease/thread.md)
- [C005 · M003 GATE tensor与matrix父路径里程碑](../../communication/C005_M003%20GATE%20tensor%E4%B8%8Ematrix%E7%88%B6%E8%B7%AF%E5%BE%84%E9%87%8C%E7%A8%8B%E7%A2%91/thread.md)
- [C006 · matrix-parent-cache 真实集成里程碑](../../communication/C006_matrix-parent-cache%20%E7%9C%9F%E5%AE%9E%E9%9B%86%E6%88%90%E9%87%8C%E7%A8%8B%E7%A2%91/thread.md)
- [C007 · 原13BO生产门户的 MODEL_IDENTITY 编码问题](../../communication/C007_%E5%8E%9F13BO%E7%94%9F%E4%BA%A7%E9%97%A8%E6%88%B7%E7%9A%84%20MODEL_IDENTITY%20%E7%BC%96%E7%A0%81%E9%97%AE%E9%A2%98/thread.md)
- [C008 · 普通 QUANT/MATRIX 源 tensor 的 producer Context 定义请求](../../communication/C008_%E6%99%AE%E9%80%9A%20QUANT_MATRIX%20%E6%BA%90%20tensor%20%E7%9A%84%20producer%20Context%20%E5%AE%9A%E4%B9%89%E8%AF%B7%E6%B1%82/thread.md)
- [C009 · M003：generated 非门户 producer 的物理 Context 绑定缺口](../../communication/C009_M003%EF%BC%9Agenerated%20%E9%9D%9E%E9%97%A8%E6%88%B7%20producer%20%E7%9A%84%E7%89%A9%E7%90%86%20Context%20%E7%BB%91%E5%AE%9A%E7%BC%BA%E5%8F%A3/thread.md)
- [C010 · G门户物理绑定与普通QUANT共享实例里程碑](../../communication/C010_G%E9%97%A8%E6%88%B7%E7%89%A9%E7%90%86%E7%BB%91%E5%AE%9A%E4%B8%8E%E6%99%AE%E9%80%9AQUANT%E5%85%B1%E4%BA%AB%E5%AE%9E%E4%BE%8B%E9%87%8C%E7%A8%8B%E7%A2%91/thread.md)
- [C011 · 当前共享QUANT GATE split回归里程碑](../../communication/C011_%E5%BD%93%E5%89%8D%E5%85%B1%E4%BA%ABQUANT%20GATE%20split%E5%9B%9E%E5%BD%92%E9%87%8C%E7%A8%8B%E7%A2%91/thread.md)
- [C012 · M003 generated-producer provenance 基础阶段交付](../../communication/C012_M003%20generated-producer%20provenance%20%E5%9F%BA%E7%A1%80%E9%98%B6%E6%AE%B5%E4%BA%A4%E4%BB%98/thread.md)
- [C013 · 生产错误收束：已发command但未接受action的残帧](../../communication/C013_%E7%94%9F%E4%BA%A7%E9%94%99%E8%AF%AF%E6%94%B6%E6%9D%9F%EF%BC%9A%E5%B7%B2%E5%8F%91command%E4%BD%86%E6%9C%AA%E6%8E%A5%E5%8F%97action%E7%9A%84%E6%AE%8B%E5%B8%A7/thread.md)
- [C014 · 最小真实硬件链与优化起点：主控优先级及工程估时请求](../../communication/C014_%E6%9C%80%E5%B0%8F%E7%9C%9F%E5%AE%9E%E7%A1%AC%E4%BB%B6%E9%93%BE%E4%B8%8E%E4%BC%98%E5%8C%96%E8%B5%B7%E7%82%B9%EF%BC%9A%E4%B8%BB%E6%8E%A7%E4%BC%98%E5%85%88%E7%BA%A7%E5%8F%8A%E5%B7%A5%E7%A8%8B%E4%BC%B0%E6%97%B6%E8%AF%B7%E6%B1%82/thread.md)
- [C015 · 首请求阶段D有界program入口核定问题](../../communication/C015_%E9%A6%96%E8%AF%B7%E6%B1%82%E9%98%B6%E6%AE%B5D%E6%9C%89%E7%95%8Cprogram%E5%85%A5%E5%8F%A3%E6%A0%B8%E5%AE%9A%E9%97%AE%E9%A2%98/thread.md)
- [C016 · 用户要求立即调转重心：先停止旧关键路径扩张](../../communication/C016_%E7%94%A8%E6%88%B7%E8%A6%81%E6%B1%82%E7%AB%8B%E5%8D%B3%E8%B0%83%E8%BD%AC%E9%87%8D%E5%BF%83%EF%BC%9A%E5%85%88%E5%81%9C%E6%AD%A2%E6%97%A7%E5%85%B3%E9%94%AE%E8%B7%AF%E5%BE%84%E6%89%A9%E5%BC%A0/thread.md)
- [C017 · GQD0 上游 Wi 接点只读核对](../../communication/C017_GQD0%20%E4%B8%8A%E6%B8%B8%20Wi%20%E6%8E%A5%E7%82%B9%E5%8F%AA%E8%AF%BB%E6%A0%B8%E5%AF%B9/thread.md)
- [C018 · LN ROM prelaunch guard prepared after AT048](../../communication/C018_LN%20ROM%20prelaunch%20guard%20prepared%20after%20AT048/thread.md)
- [C019 · M003普通Q/L逐窗口生产接入：请求集中合同](../../communication/C019_M003%E6%99%AE%E9%80%9AQ_L%E9%80%90%E7%AA%97%E5%8F%A3%E7%94%9F%E4%BA%A7%E6%8E%A5%E5%85%A5%EF%BC%9A%E8%AF%B7%E6%B1%82%E9%9B%86%E4%B8%AD%E5%90%88%E5%90%8C/thread.md)
- [C021 · M005现在执行：完整代表通路、资源时序与整模可行性](../../communication/C021_M005%E7%8E%B0%E5%9C%A8%E6%89%A7%E8%A1%8C%EF%BC%9A%E5%AE%8C%E6%95%B4%E4%BB%A3%E8%A1%A8%E9%80%9A%E8%B7%AF%E3%80%81%E8%B5%84%E6%BA%90%E6%97%B6%E5%BA%8F%E4%B8%8E%E6%95%B4%E6%A8%A1%E5%8F%AF%E8%A1%8C%E6%80%A7/thread.md)
- [C022 · M005立即并行：独立整模流水性能与可行性预算](../../communication/C022_M005%E7%AB%8B%E5%8D%B3%E5%B9%B6%E8%A1%8C%EF%BC%9A%E7%8B%AC%E7%AB%8B%E6%95%B4%E6%A8%A1%E6%B5%81%E6%B0%B4%E6%80%A7%E8%83%BD%E4%B8%8E%E5%8F%AF%E8%A1%8C%E6%80%A7%E9%A2%84%E7%AE%97/thread.md)
- [C024 · M005代表top：LN→Q物理读债接线决策](../../communication/C024_M005%E4%BB%A3%E8%A1%A8top%EF%BC%9ALN%E2%86%92Q%E7%89%A9%E7%90%86%E8%AF%BB%E5%80%BA%E6%8E%A5%E7%BA%BF%E5%86%B3%E7%AD%96/thread.md)
- [C027 · M004用户已批准：立即开始完整软件基线与最简架构接点实验](../../communication/C027_M004%E7%94%A8%E6%88%B7%E5%B7%B2%E6%89%B9%E5%87%86%EF%BC%9A%E7%AB%8B%E5%8D%B3%E5%BC%80%E5%A7%8B%E5%AE%8C%E6%95%B4%E8%BD%AF%E4%BB%B6%E5%9F%BA%E7%BA%BF%E4%B8%8E%E6%9C%80%E7%AE%80%E6%9E%B6%E6%9E%84%E6%8E%A5%E7%82%B9%E5%AE%9E%E9%AA%8C/thread.md)
- [C028 · M004已批准启动：固定计算图与最简吞吐架构核查](../../communication/C028_M004%E5%B7%B2%E6%89%B9%E5%87%86%E5%90%AF%E5%8A%A8%EF%BC%9A%E5%9B%BA%E5%AE%9A%E8%AE%A1%E7%AE%97%E5%9B%BE%E4%B8%8E%E6%9C%80%E7%AE%80%E5%90%9E%E5%90%90%E6%9E%B6%E6%9E%84%E6%A0%B8%E6%9F%A5/thread.md)
- [C029 · M004固定图架构：有限接点问题（A003→A002）](../../communication/C029_M004%E5%9B%BA%E5%AE%9A%E5%9B%BE%E6%9E%B6%E6%9E%84%EF%BC%9A%E6%9C%89%E9%99%90%E6%8E%A5%E7%82%B9%E9%97%AE%E9%A2%98%EF%BC%88A003%E2%86%92A002%EF%BC%89/thread.md)
- [C030 · SM004 首次实际启动](../../communication/C030_SM004%20%E9%A6%96%E6%AC%A1%E5%AE%9E%E9%99%85%E5%90%AF%E5%8A%A8/thread.md)
- [C031 · SM004 当前软件Attention路径差异](../../communication/C031_SM004%20%E5%BD%93%E5%89%8D%E8%BD%AF%E4%BB%B6Attention%E8%B7%AF%E5%BE%84%E5%B7%AE%E5%BC%82/thread.md)
- [C032 · M004 LN单行准备：一个有限接点问题](../../communication/C032_M004%20LN%E5%8D%95%E8%A1%8C%E5%87%86%E5%A4%87%EF%BC%9A%E4%B8%80%E4%B8%AA%E6%9C%89%E9%99%90%E6%8E%A5%E7%82%B9%E9%97%AE%E9%A2%98/thread.md)
- [C033 · 下一连接段：LN→Q的定向核查](../../communication/C033_%E4%B8%8B%E4%B8%80%E8%BF%9E%E6%8E%A5%E6%AE%B5%EF%BC%9ALN%E2%86%92Q%E7%9A%84%E5%AE%9A%E5%90%91%E6%A0%B8%E6%9F%A5/thread.md)
- [C034 · LN首错缺口关闭，按修订6继续连接](../../communication/C034_LN%E9%A6%96%E9%94%99%E7%BC%BA%E5%8F%A3%E5%85%B3%E9%97%AD%EF%BC%8C%E6%8C%89%E4%BF%AE%E8%AE%A26%E7%BB%A7%E7%BB%AD%E8%BF%9E%E6%8E%A5/thread.md)
- [C035 · LN→Q后续：只核Q长组合路径的一个修复方案](../../communication/C035_LN%E2%86%92Q%E5%90%8E%E7%BB%AD%EF%BC%9A%E5%8F%AA%E6%A0%B8Q%E9%95%BF%E7%BB%84%E5%90%88%E8%B7%AF%E5%BE%84%E7%9A%84%E4%B8%80%E4%B8%AA%E4%BF%AE%E5%A4%8D%E6%96%B9%E6%A1%88/thread.md)
- [C037 · SM004修订7 Q/LN→Q实测数据（A002→A003）](../../communication/C037_SM004%E4%BF%AE%E8%AE%A27%20Q_LN%E2%86%92Q%E5%AE%9E%E6%B5%8B%E6%95%B0%E6%8D%AE%EF%BC%88A002%E2%86%92A003%EF%BC%89/thread.md)
- [C038 · AT131新路径：定向核一个首错/完成切分](../../communication/C038_AT131%E6%96%B0%E8%B7%AF%E5%BE%84%EF%BC%9A%E5%AE%9A%E5%90%91%E6%A0%B8%E4%B8%80%E4%B8%AA%E9%A6%96%E9%94%99_%E5%AE%8C%E6%88%90%E5%88%87%E5%88%86/thread.md)
- [C039 · AT131新路径：定向核一个首错/完成切分](../../communication/C039_AT131%E6%96%B0%E8%B7%AF%E5%BE%84%EF%BC%9A%E5%AE%9A%E5%90%91%E6%A0%B8%E4%B8%80%E4%B8%AA%E9%A6%96%E9%94%99_%E5%AE%8C%E6%88%90%E5%88%87%E5%88%86/thread.md)
- [C040 · AT131返回路径端点表接点](../../communication/C040_AT131%E8%BF%94%E5%9B%9E%E8%B7%AF%E5%BE%84%E7%AB%AF%E7%82%B9%E8%A1%A8%E6%8E%A5%E7%82%B9/thread.md)
- [C041 · LN→Q→Wi最小接点与同输入gold](../../communication/C041_LN%E2%86%92Q%E2%86%92Wi%E6%9C%80%E5%B0%8F%E6%8E%A5%E7%82%B9%E4%B8%8E%E5%90%8C%E8%BE%93%E5%85%A5gold/thread.md)
- [C042 · 下一真实连接定向准备：Wi→G→Q→Down](../../communication/C042_%E4%B8%8B%E4%B8%80%E7%9C%9F%E5%AE%9E%E8%BF%9E%E6%8E%A5%E5%AE%9A%E5%90%91%E5%87%86%E5%A4%87%EF%BC%9AWi%E2%86%92G%E2%86%92Q%E2%86%92Down/thread.md)
- [C043 · 下一真实连接准备：Down＋原skip到完整FFN单行](../../communication/C043_%E4%B8%8B%E4%B8%80%E7%9C%9F%E5%AE%9E%E8%BF%9E%E6%8E%A5%E5%87%86%E5%A4%87%EF%BC%9ADown%EF%BC%8B%E5%8E%9Fskip%E5%88%B0%E5%AE%8C%E6%95%B4FFN%E5%8D%95%E8%A1%8C/thread.md)
- [C044 · 修订11成本出口与下一固定图接点静态核查](../../communication/C044_%E4%BF%AE%E8%AE%A211%E6%88%90%E6%9C%AC%E5%87%BA%E5%8F%A3%E4%B8%8E%E4%B8%8B%E4%B8%80%E5%9B%BA%E5%AE%9A%E5%9B%BE%E6%8E%A5%E7%82%B9%E9%9D%99%E6%80%81%E6%A0%B8%E6%9F%A5/thread.md)
- [C045 · 下一真实边界：S128生产与FINAL→Attention静态接点](../../communication/C045_%E4%B8%8B%E4%B8%80%E7%9C%9F%E5%AE%9E%E8%BE%B9%E7%95%8C%EF%BC%9AS128%E7%94%9F%E4%BA%A7%E4%B8%8EFINAL%E2%86%92Attention%E9%9D%99%E6%80%81%E6%8E%A5%E7%82%B9/thread.md)
- [C046 · 修订15：真实STATE0/AUX入口与固定128行生产调度](../../communication/C046_%E4%BF%AE%E8%AE%A215%EF%BC%9A%E7%9C%9F%E5%AE%9ESTATE0_AUX%E5%85%A5%E5%8F%A3%E4%B8%8E%E5%9B%BA%E5%AE%9A128%E8%A1%8C%E7%94%9F%E4%BA%A7%E8%B0%83%E5%BA%A6/thread.md)
- [C047 · 修订16：FINAL存储到Attention tile的真实读算写消费者](../../communication/C047_%E4%BF%AE%E8%AE%A216%EF%BC%9AFINAL%E5%AD%98%E5%82%A8%E5%88%B0Attention%20tile%E7%9A%84%E7%9C%9F%E5%AE%9E%E8%AF%BB%E7%AE%97%E5%86%99%E6%B6%88%E8%B4%B9%E8%80%85/thread.md)
- [C048 · 并行研究：完整128行验证与原全请求首错的下一可执行接法](../../communication/C048_%E5%B9%B6%E8%A1%8C%E7%A0%94%E7%A9%B6%EF%BC%9A%E5%AE%8C%E6%95%B4128%E8%A1%8C%E9%AA%8C%E8%AF%81%E4%B8%8E%E5%8E%9F%E5%85%A8%E8%AF%B7%E6%B1%82%E9%A6%96%E9%94%99%E7%9A%84%E4%B8%8B%E4%B8%80%E5%8F%AF%E6%89%A7%E8%A1%8C%E6%8E%A5%E6%B3%95/thread.md)
- [C049 · S128增量静态接纳与修订16排空细化](../../communication/C049_S128%E5%A2%9E%E9%87%8F%E9%9D%99%E6%80%81%E6%8E%A5%E7%BA%B3%E4%B8%8E%E4%BF%AE%E8%AE%A216%E6%8E%92%E7%A9%BA%E7%BB%86%E5%8C%96/thread.md)
- [C050 · 修订16 AT268 head0 八 tile 阶段里程碑](../../communication/C050_%E4%BF%AE%E8%AE%A216%20AT268%20head0%20%E5%85%AB%20tile%20%E9%98%B6%E6%AE%B5%E9%87%8C%E7%A8%8B%E7%A2%91/thread.md)
- [C051 · 修订17：全128行LN阶段与Q16紧密bank入口](../../communication/C051_%E4%BF%AE%E8%AE%A217%EF%BC%9A%E5%85%A8128%E8%A1%8CLN%E9%98%B6%E6%AE%B5%E4%B8%8EQ16%E7%B4%A7%E5%AF%86bank%E5%85%A5%E5%8F%A3/thread.md)
- [C052 · LN128仿真成本根因：静态定向核查](../../communication/C052_LN128%E4%BB%BF%E7%9C%9F%E6%88%90%E6%9C%AC%E6%A0%B9%E5%9B%A0%EF%BC%9A%E9%9D%99%E6%80%81%E5%AE%9A%E5%90%91%E6%A0%B8%E6%9F%A5/thread.md)
- [C053 · 修订18成本试验细化：采用唯一默认/--O3对照](../../communication/C053_%E4%BF%AE%E8%AE%A218%E6%88%90%E6%9C%AC%E8%AF%95%E9%AA%8C%E7%BB%86%E5%8C%96%EF%BC%9A%E9%87%87%E7%94%A8%E5%94%AF%E4%B8%80%E9%BB%98%E8%AE%A4_--O3%E5%AF%B9%E7%85%A7/thread.md)
- [C054 · AT349 Check 断言范围更正](../../communication/C054_AT349%20Check%20%E6%96%AD%E8%A8%80%E8%8C%83%E5%9B%B4%E6%9B%B4%E6%AD%A3/thread.md)
- [C055 · LN128后继W准备与Q16首窗口：定向静态增量](../../communication/C055_LN128%E5%90%8E%E7%BB%A7W%E5%87%86%E5%A4%87%E4%B8%8EQ16%E9%A6%96%E7%AA%97%E5%8F%A3%EF%BC%9A%E5%AE%9A%E5%90%91%E9%9D%99%E6%80%81%E5%A2%9E%E9%87%8F/thread.md)
- [C056 · 首A16保持之后：现生产接口上的MATRIX16最小增量](../../communication/C056_%E9%A6%96A16%E4%BF%9D%E6%8C%81%E4%B9%8B%E5%90%8E%EF%BC%9A%E7%8E%B0%E7%94%9F%E4%BA%A7%E6%8E%A5%E5%8F%A3%E4%B8%8A%E7%9A%84MATRIX16%E6%9C%80%E5%B0%8F%E5%A2%9E%E9%87%8F/thread.md)
- [C057 · 用户暂停指令（2026-10-16）](../../communication/C057_%E7%94%A8%E6%88%B7%E6%9A%82%E5%81%9C%E6%8C%87%E4%BB%A4%EF%BC%882026-10-16%EF%BC%89/thread.md)
- [C058 · 用户暂停指令（2026-10-16）](../../communication/C058_%E7%94%A8%E6%88%B7%E6%9A%82%E5%81%9C%E6%8C%87%E4%BB%A4%EF%BC%882026-10-16%EF%BC%89/thread.md)
- [C059 · M006硬件恢复派发：完整板端Attention首段](../../communication/C059_M006%E7%A1%AC%E4%BB%B6%E6%81%A2%E5%A4%8D%E6%B4%BE%E5%8F%91%EF%BC%9A%E5%AE%8C%E6%95%B4%E6%9D%BF%E7%AB%AFAttention%E9%A6%96%E6%AE%B5/thread.md)
- [C064 · 用户暂停M006工程](../../communication/C064_%E7%94%A8%E6%88%B7%E6%9A%82%E5%81%9CM006%E5%B7%A5%E7%A8%8B/thread.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
