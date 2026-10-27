

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E004 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001 — E004 / SM004 首段

2026-10-14；A002。完整软件正常请求与最小复用接点首段已经实际执行；AT088–091原证据保留各目录。[结果报告](reports/SM004_software_baseline_result_20261014.md)、[接点表](reports/SM004_minimal_reuse_contacts_20261014.md)、[AT091收据](attempts/AT091_SM004_full_software_b1_04/receipt.json)。

软件限定PASS：g++ host、真实production-v2 B1/S128 id3/generation1、完整28 Encoder＋2 Decision，47独立gold项/4,523,596个F32逐字节相同。AT091单次216.712s、峰640172KiB；首段累计463.241s。当前E002软件Attention走CPU叶子，硬件完整请求/性能仍NOT_RUN。准确命令、版本、源码/输入SHA、开始/终止和故障前例见各attempt的preflight、build_manifest、guard_plan/launch/result/driver与报告；本页是索引，不代替原始证据。

SM004修订3向量段AT092–099已按原短测/static/唯一局部OOC预算收束；[结果与限制](reports/SM004_vector_stage_result_20261014.md)、[身份/守卫/成本](reports/SM004_vector_stage_evidence_20261014.json)。精确单lane4096项及薄双源AXI正常/合法反压样本限定PASS，局部OOC资源/综合内部时序已测；完整硬件模型、独立全图反压、P&R/实达频率和加速比仍NOT_RUN。

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT088_SM004_full_software_b1_01](attempts/AT088_SM004_full_software_b1_01) | 未登记；查看原记录 | 未登记 |  |
| [AT089_SM004_full_software_b1_02](attempts/AT089_SM004_full_software_b1_02) | 未登记；查看原记录 | 未登记 |  |
| [AT090_SM004_full_software_b1_03](attempts/AT090_SM004_full_software_b1_03) | 未登记；查看原记录 | 未登记 |  |
| [AT091_SM004_full_software_b1_04](attempts/AT091_SM004_full_software_b1_04) | PASS_SCOPED_FULL_SOFTWARE_NORMAL_B1 | g++ host full_execute_cpu_request; CPU Attention leaves, not Vitis CSim, RTL or accelerator | [执行收据](attempts/AT091_SM004_full_software_b1_04/receipt.json) |
| [AT092_SM004_vector_leaf_probe_01](attempts/AT092_SM004_vector_leaf_probe_01) | 未登记；查看原记录 | 未登记 |  |
| [AT093_SM004_vector_stream_01](attempts/AT093_SM004_vector_stream_01) | 未登记；查看原记录 | 未登记 |  |
| [AT094_SM004_vector_axi_01](attempts/AT094_SM004_vector_axi_01) | 未登记；查看原记录 | 未登记 |  |
| [AT095_SM004_vector_axi_02](attempts/AT095_SM004_vector_axi_02) | 未登记；查看原记录 | 未登记 |  |
| [AT096_SM004_vector_axi_03](attempts/AT096_SM004_vector_axi_03) | 未登记；查看原记录 | 未登记 |  |
| [AT097_SM004_vector_axi_backpressure_04](attempts/AT097_SM004_vector_axi_backpressure_04) | 未登记；查看原记录 | 未登记 |  |
| [AT098_SM004_vector_ce_pause_01](attempts/AT098_SM004_vector_ce_pause_01) | 未登记；查看原记录 | 未登记 |  |
| [AT099_SM004_vector_stream_ooc_01](attempts/AT099_SM004_vector_stream_ooc_01) | 未登记；查看原记录 | 未登记 |  |
| [AT100_SM004_vector_axi_4k_finite_01](attempts/AT100_SM004_vector_axi_4k_finite_01) | 未登记；查看原记录 | AT100 compile typo only | [执行收据](attempts/AT100_SM004_vector_axi_4k_finite_01/receipt.json) |
| [AT101_SM004_vector_axi_4k_finite_02](attempts/AT101_SM004_vector_axi_4k_finite_02) | 未登记；查看原记录 | Ten sequential local AXI service commands; no full graph/OOC | [执行收据](attempts/AT101_SM004_vector_axi_4k_finite_02/receipt.json) |
| [AT102_SM004_ln_leaf_probe_01](attempts/AT102_SM004_ln_leaf_probe_01) | 未登记；查看原记录 | 未登记 |  |
| [AT103_SM004_ln_leaf_probe_02](attempts/AT103_SM004_ln_leaf_probe_02) | 未登记；查看原记录 | 未登记 |  |
| [AT104_SM004_ln_leaf_probe_03](attempts/AT104_SM004_ln_leaf_probe_03) | 未登记；查看原记录 | 未登记 |  |
| [AT105_SM004_ln_row_01](attempts/AT105_SM004_ln_row_01) | 未登记；查看原记录 | 未登记 |  |
| [AT106_SM004_ln_row_02](attempts/AT106_SM004_ln_row_02) | 未登记；查看原记录 | 未登记 |  |
| [AT107_SM004_ln_row_03](attempts/AT107_SM004_ln_row_03) | 未登记；查看原记录 | 未登记 |  |
| [AT108_SM004_ln_row_ooc_01](attempts/AT108_SM004_ln_row_ooc_01) | 未登记；查看原记录 | 未登记 |  |
| [AT109_SM004_ln_first_error_old_01](attempts/AT109_SM004_ln_first_error_old_01) | 未登记；查看原记录 | 未登记 |  |
| [AT110_SM004_ln_first_error_fixed_01](attempts/AT110_SM004_ln_first_error_fixed_01) | 未登记；查看原记录 | 未登记 |  |
| [AT111_SM004_lnq_row_01](attempts/AT111_SM004_lnq_row_01) | 未登记；查看原记录 | 未登记 |  |
| [AT112_SM004_lnq_row_02](attempts/AT112_SM004_lnq_row_02) | 未登记；查看原记录 | 未登记 |  |
| [AT113_SM004_lnq_row_03](attempts/AT113_SM004_lnq_row_03) | 未登记；查看原记录 | 未登记 |  |
| [AT114_SM004_lnq_row_04](attempts/AT114_SM004_lnq_row_04) | 未登记；查看原记录 | 未登记 |  |
| [AT115_SM004_lnq_row_05](attempts/AT115_SM004_lnq_row_05) | 未登记；查看原记录 | 未登记 |  |
| [AT116_SM004_lnq_row_ooc_01](attempts/AT116_SM004_lnq_row_ooc_01) | 未登记；查看原记录 | 未登记 |  |
| [AT117_SM004_lnq_row_final_01](attempts/AT117_SM004_lnq_row_final_01) | 未登记；查看原记录 | 未登记 |  |
| [AT118_SM004_lnq_row_final_02](attempts/AT118_SM004_lnq_row_final_02) | 未登记；查看原记录 | 未登记 |  |
| [AT119_SM004_lnq_dcp_port_audit_01](attempts/AT119_SM004_lnq_dcp_port_audit_01) | 未登记；查看原记录 | 未登记 |  |
| [AT120_SM004_lnq_dcp_cell_audit_02](attempts/AT120_SM004_lnq_dcp_cell_audit_02) | 未登记；查看原记录 | 未登记 |  |
| [AT121_SM004_lnq_row_final_03](attempts/AT121_SM004_lnq_row_final_03) | 未登记；查看原记录 | 未登记 |  |
| [AT122_SM004_lnq_reset_coverage_01](attempts/AT122_SM004_lnq_reset_coverage_01) | 未登记；查看原记录 | 未登记 |  |
| [AT123_SM004_lnq_reset_coverage_02](attempts/AT123_SM004_lnq_reset_coverage_02) | 未登记；查看原记录 | 未登记 |  |
| [AT124_SM004_lnq_arithmetic_reset_03](attempts/AT124_SM004_lnq_arithmetic_reset_03) | 未登记；查看原记录 | 未登记 |  |
| [AT125_SM004_q_partition_01](attempts/AT125_SM004_q_partition_01) | 未登记；查看原记录 | 未登记 |  |
| [AT126_SM004_q_partition_independent_02](attempts/AT126_SM004_q_partition_independent_02) | 未登记；查看原记录 | 未登记 |  |
| [AT127_SM004_q_partition_independent_03](attempts/AT127_SM004_q_partition_independent_03) | 未登记；查看原记录 | 未登记 |  |
| [AT128_SM004_q_partition_phase_04](attempts/AT128_SM004_q_partition_phase_04) | 未登记；查看原记录 | 未登记 |  |
| [AT129_SM004_q_partition_select_05](attempts/AT129_SM004_q_partition_select_05) | 未登记；查看原记录 | 未登记 |  |
| [AT130_SM004_q_partition_tie_06](attempts/AT130_SM004_q_partition_tie_06) | 未登记；查看原记录 | 未登记 |  |
| [AT131_SM004_lnq_partition_ooc_01](attempts/AT131_SM004_lnq_partition_ooc_01) | 未登记；查看原记录 | 未登记 |  |
| [AT132_SM004_lnq_partition_dcp_audit_01](attempts/AT132_SM004_lnq_partition_dcp_audit_01) | 未登记；查看原记录 | 未登记 |  |
| [AT133_SM004_lnq_dcp_target_timing_01](attempts/AT133_SM004_lnq_dcp_target_timing_01) | 未登记；查看原记录 | 未登记 |  |
| [AT134_SM004_q_error_metadata_01](attempts/AT134_SM004_q_error_metadata_01) | 未登记；查看原记录 | 未登记 |  |
| [AT135_SM004_lnq_error_metadata_ooc_01](attempts/AT135_SM004_lnq_error_metadata_ooc_01) | 未登记；查看原记录 | 未登记 |  |
| [AT136_SM004_lnq_error_metadata_ooc_02](attempts/AT136_SM004_lnq_error_metadata_ooc_02) | 未登记；查看原记录 | 未登记 |  |
| [AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03](attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03) | 未登记；查看原记录 | 未登记 |  |
| [AT138_SM004_lnq_error_metadata_ooc_tcl_tolerance_04](attempts/AT138_SM004_lnq_error_metadata_ooc_tcl_tolerance_04) | 未登记；查看原记录 | 未登记 |  |
| [AT139_SM004_lnq_current_dcp_target_timing_01](attempts/AT139_SM004_lnq_current_dcp_target_timing_01) | 未登记；查看原记录 | 未登记 |  |
| [AT140_SM004_lnq_wi_static_01](attempts/AT140_SM004_lnq_wi_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT141_SM004_lnq_wi_elab_01](attempts/AT141_SM004_lnq_wi_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT142_SM004_lnq_wi_elab_resume_02](attempts/AT142_SM004_lnq_wi_elab_resume_02) | 未登记；查看原记录 | 未登记 |  |
| [AT143_SM004_lnq_wi_prefix_01](attempts/AT143_SM004_lnq_wi_prefix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT144_SM004_lnq_wi_instrumented_prefix_02](attempts/AT144_SM004_lnq_wi_instrumented_prefix_02) | 未登记；查看原记录 | 未登记 |  |
| [AT145_SM004_lnq_wi_prefix_diagnostic_03](attempts/AT145_SM004_lnq_wi_prefix_diagnostic_03) | 未登记；查看原记录 | 未登记 |  |
| [AT146_SM004_lnq_wi_prefix_guard_04](attempts/AT146_SM004_lnq_wi_prefix_guard_04) | 未登记；查看原记录 | 未登记 |  |
| [AT147_SM004_lnq_wi_identity_fix_05](attempts/AT147_SM004_lnq_wi_identity_fix_05) | 未登记；查看原记录 | 未登记 |  |
| [AT148_SM004_lnq_wi_full_cold_warm_06](attempts/AT148_SM004_lnq_wi_full_cold_warm_06) | 未登记；查看原记录 | 未登记 |  |
| [AT149_SM004_lnq_wi_tag_abort_recover_07](attempts/AT149_SM004_lnq_wi_tag_abort_recover_07) | 未登记；查看原记录 | 未登记 |  |
| [AT150_SM004_lnq_wi_tag_abort_recover_prefix_08](attempts/AT150_SM004_lnq_wi_tag_abort_recover_prefix_08) | 未登记；查看原记录 | 未登记 |  |
| [AT151_SM004_lnq_wi_cold_rresp_09](attempts/AT151_SM004_lnq_wi_cold_rresp_09) | 未登记；查看原记录 | 未登记 |  |
| [AT152_SM004_ps_front_abort_edges_10](attempts/AT152_SM004_ps_front_abort_edges_10) | 未登记；查看原记录 | 未登记 |  |
| [AT153_SM004_ln_wi_row0_stats_11](attempts/AT153_SM004_ln_wi_row0_stats_11) | 未登记；查看原记录 | 未登记 |  |
| [AT154_SM004_ln_wi_row0_stats_rtl_12](attempts/AT154_SM004_ln_wi_row0_stats_rtl_12) | 未登记；查看原记录 | 未登记 |  |
| [AT155_SM004_ps_front_abort0_regression_13](attempts/AT155_SM004_ps_front_abort0_regression_13) | 未登记；查看原记录 | 未登记 |  |
| [AT156_SM004_lnq_direct82_01](attempts/AT156_SM004_lnq_direct82_01) | 未登记；查看原记录 | 未登记 |  |
| [AT157_SM004_lnq_legacy_tb_phase_02](attempts/AT157_SM004_lnq_legacy_tb_phase_02) | 未登记；查看原记录 | 未登记 |  |
| [AT158_SM004_lnq_legacy_group_width_03](attempts/AT158_SM004_lnq_legacy_group_width_03) | 未登记；查看原记录 | 未登记 |  |
| [AT159_SM004_gqdown_top_syntax_01](attempts/AT159_SM004_gqdown_top_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT160_SM004_gqdown_elab_01](attempts/AT160_SM004_gqdown_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT161_SM004_gqdown_pilot_01](attempts/AT161_SM004_gqdown_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT162_SM004_gqdown_full_01](attempts/AT162_SM004_gqdown_full_01) | 未登记；查看原记录 | 未登记 |  |
| [AT163_SM004_gqdown_full_epoch_fix_01](attempts/AT163_SM004_gqdown_full_epoch_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT164_SM004_saved_wi_g_core_diagnostic_01](attempts/AT164_SM004_saved_wi_g_core_diagnostic_01) | 未登记；查看原记录 | 未登记 |  |
| [AT165_SM004_g_gate_addr10_full_01](attempts/AT165_SM004_g_gate_addr10_full_01) | 未登记；查看原记录 | 未登记 |  |
| [AT166_SM004_down_ret_pair_index_full_01](attempts/AT166_SM004_down_ret_pair_index_full_01) | 未登记；查看原记录 | 未登记 |  |
| [AT167_SM004_wi_fp_common_reset_01](attempts/AT167_SM004_wi_fp_common_reset_01) | 未登记；查看原记录 | 未登记 |  |
| [AT168_SM004_wi_fp_reset_guard_epoch_02](attempts/AT168_SM004_wi_fp_reset_guard_epoch_02) | 未登记；查看原记录 | 未登记 |  |
| [AT169_SM004_g_inflight_common_reset_01](attempts/AT169_SM004_g_inflight_common_reset_01) | 未登记；查看原记录 | 未登记 |  |
| [AT170_SM004_residual_connected_compile_01](attempts/AT170_SM004_residual_connected_compile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT171_SM004_residual_local_probe_01](attempts/AT171_SM004_residual_local_probe_01) | 未登记；查看原记录 | 未登记 |  |
| [AT172_SM004_residual_local_guard_counter_02](attempts/AT172_SM004_residual_local_guard_counter_02) | 未登记；查看原记录 | 未登记 |  |
| [AT173_SM004_residual_combined_recovery_01](attempts/AT173_SM004_residual_combined_recovery_01) | 未登记；查看原记录 | 未登记 |  |
| [AT174_SM004_aux_ar_stall_targeted_01](attempts/AT174_SM004_aux_ar_stall_targeted_01) | 未登记；查看原记录 | 未登记 |  |
| [AT175_SM004_axi_inflight_reset_targeted_01](attempts/AT175_SM004_axi_inflight_reset_targeted_01) | 未登记；查看原记录 | 未登记 |  |
| [AT176_SM004_wi_last_scale_bad_targeted_01](attempts/AT176_SM004_wi_last_scale_bad_targeted_01) | 未登记；查看原记录 | 未登记 |  |
| [AT177_SM004_wi_last_return_scale_bad_targeted_01](attempts/AT177_SM004_wi_last_return_scale_bad_targeted_01) | 未登记；查看原记录 | 未登记 |  |
| [AT178_SM004_wi_issue_scale_bad_targeted_01](attempts/AT178_SM004_wi_issue_scale_bad_targeted_01) | 未登记；查看原记录 | 未登记 |  |
| [AT179_SM004_rev12_qkv_syntax_01](attempts/AT179_SM004_rev12_qkv_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT180_SM004_rev12_qkv_fixture_01](attempts/AT180_SM004_rev12_qkv_fixture_01) | 未登记；查看原记录 | 未登记 |  |
| [AT181_SM004_rev12_qkv_tb_syntax_01](attempts/AT181_SM004_rev12_qkv_tb_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT182_SM004_rev12_qkv_full_compile_01](attempts/AT182_SM004_rev12_qkv_full_compile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT183_SM004_rev12_qkv_pilot_01](attempts/AT183_SM004_rev12_qkv_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT184_SM004_rev12_qkv_cold_warm_01](attempts/AT184_SM004_rev12_qkv_cold_warm_01) | 未登记；查看原记录 | 未登记 |  |
| [AT185_SM004_rev12_qkv_six_field_fixture_01](attempts/AT185_SM004_rev12_qkv_six_field_fixture_01) | 未登记；查看原记录 | 未登记 |  |
| [AT186_SM004_rev12_qkv_six_field_recompile_01](attempts/AT186_SM004_rev12_qkv_six_field_recompile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT187_SM004_rev12_six_field_pilot_01](attempts/AT187_SM004_rev12_six_field_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT188_SM004_rev12_six_field_full_01](attempts/AT188_SM004_rev12_six_field_full_01) | 未登记；查看原记录 | 未登记 |  |
| [AT189_SM004_rev12_crossmode_compile_01](attempts/AT189_SM004_rev12_crossmode_compile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT190_SM004_rev12_crossmode_progress_recompile_01](attempts/AT190_SM004_rev12_crossmode_progress_recompile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT191_SM004_rev12_qkv_ffn_switch_full_01](attempts/AT191_SM004_rev12_qkv_ffn_switch_full_01) | 未登记；查看原记录 | 未登记 |  |
| [AT192_SM004_rev12_crossmode_ready_stall_recompile_01](attempts/AT192_SM004_rev12_crossmode_ready_stall_recompile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT193_SM004_rev12_qkv_ffn_switch_full_fix_01](attempts/AT193_SM004_rev12_qkv_ffn_switch_full_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT194_SM004_rev12_crossmode_focused_recompile_01](attempts/AT194_SM004_rev12_crossmode_focused_recompile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT195_SM004_rev12_qkv_ffn_focused_full_01](attempts/AT195_SM004_rev12_qkv_ffn_focused_full_01) | 未登记；查看原记录 | 未登记 |  |
| [AT196_SM004_rev13_scratch_static_01](attempts/AT196_SM004_rev13_scratch_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT197_SM004_rev13_writer_rearm_01](attempts/AT197_SM004_rev13_writer_rearm_01) | 未登记；查看原记录 | 未登记 |  |
| [AT198_SM004_rev13_scratch_elab_01](attempts/AT198_SM004_rev13_scratch_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT199_SM004_rev13_scratch_local_peer_01](attempts/AT199_SM004_rev13_scratch_local_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT200_SM004_rev13_scratch_local_peer_tbfix_01](attempts/AT200_SM004_rev13_scratch_local_peer_tbfix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT201_SM004_rev13_scratch_local_peer_stalls_01](attempts/AT201_SM004_rev13_scratch_local_peer_stalls_01) | 未登记；查看原记录 | 未登记 |  |
| [AT202_SM004_rev13_scratch_local_peer_diag_01](attempts/AT202_SM004_rev13_scratch_local_peer_diag_01) | 未登记；查看原记录 | 未登记 |  |
| [AT203_SM004_rev13_scratch_local_peer_release_fix_01](attempts/AT203_SM004_rev13_scratch_local_peer_release_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT204_SM004_rev13_scratch_real_chain_01](attempts/AT204_SM004_rev13_scratch_real_chain_01) | 未登记；查看原记录 | 未登记 |  |
| [AT205_SM004_rev13_tensor_full128_local_peer_01](attempts/AT205_SM004_rev13_tensor_full128_local_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT206_SM004_rev13_scratch_reset_local_01](attempts/AT206_SM004_rev13_scratch_reset_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT207_SM004_rev13_scratch_reset_local_indexfix_01](attempts/AT207_SM004_rev13_scratch_reset_local_indexfix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT208_SM004_rev13_tensor_boundary_local_peer_01](attempts/AT208_SM004_rev13_tensor_boundary_local_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT209_SM004_rev13_terminal_repro_old_wrapper_01](attempts/AT209_SM004_rev13_terminal_repro_old_wrapper_01) | 未登记；查看原记录 | 未登记 |  |
| [AT210_SM004_rev13_terminal_identity_route_local_fix_01](attempts/AT210_SM004_rev13_terminal_identity_route_local_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT211_SM004_rev13_scratch_real_elab_terminal_fix_01](attempts/AT211_SM004_rev13_scratch_real_elab_terminal_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT212_SM004_rev13_flush_echo_old_repro_01](attempts/AT212_SM004_rev13_flush_echo_old_repro_01) | 未登记；查看原记录 | 未登记 |  |
| [AT213_SM004_rev13_flush_echo_debt_fix_local_01](attempts/AT213_SM004_rev13_flush_echo_debt_fix_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT214_SM004_rev13_scratch_real_elab_flush_fix_01](attempts/AT214_SM004_rev13_scratch_real_elab_flush_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT215_SM004_rev14_rope_wrapper_syntax_01](attempts/AT215_SM004_rev14_rope_wrapper_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT216_SM004_rev14_rope_full_elab_01](attempts/AT216_SM004_rev14_rope_full_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT217_SM004_rev14_rope_full_elab_02](attempts/AT217_SM004_rev14_rope_full_elab_02) | 未登记；查看原记录 | 未登记 |  |
| [AT218_SM004_rev14_rope_full_elab_caller_fix_03](attempts/AT218_SM004_rev14_rope_full_elab_caller_fix_03) | 未登记；查看原记录 | 未登记 |  |
| [AT219_SM004_rev14_rope_adapter_saved_heads_01](attempts/AT219_SM004_rev14_rope_adapter_saved_heads_01) | 未登记；查看原记录 | 未登记 |  |
| [AT220_SM004_rev14_rope_adapter_saved_heads_01](attempts/AT220_SM004_rev14_rope_adapter_saved_heads_01) | 未登记；查看原记录 | 未登记 |  |
| [AT221_SM004_rev14_rope_adapter_progress_02](attempts/AT221_SM004_rev14_rope_adapter_progress_02) | 未登记；查看原记录 | 未登记 |  |
| [AT222_SM004_rev14_rope_adapter_start_cycle_fix_03](attempts/AT222_SM004_rev14_rope_adapter_start_cycle_fix_03) | 未登记；查看原记录 | 未登记 |  |
| [AT223_SM004_rev14_rope_adapter_tb_ready_fix_04](attempts/AT223_SM004_rev14_rope_adapter_tb_ready_fix_04) | 未登记；查看原记录 | 未登记 |  |
| [AT224_SM004_rev14_rope_real_rows01_01](attempts/AT224_SM004_rev14_rope_real_rows01_01) | 未登记；查看原记录 | 未登记 |  |
| [AT225_SM004_rev14_rope_real_rows01_progress_02](attempts/AT225_SM004_rev14_rope_real_rows01_progress_02) | 未登记；查看原记录 | 未登记 |  |
| [AT226_SM004_rev14_raw_only_local_regression_01](attempts/AT226_SM004_rev14_raw_only_local_regression_01) | 未登记；查看原记录 | 未登记 |  |
| [AT227_SM004_rev14_rope_local_error_peer_01](attempts/AT227_SM004_rev14_rope_local_error_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT228_SM004_rev14_rope_order_sticky_fix_local_01](attempts/AT228_SM004_rev14_rope_order_sticky_fix_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT229_SM004_rev14_rope_aux_reentry_order_probe_01](attempts/AT229_SM004_rev14_rope_aux_reentry_order_probe_01) | 未登记；查看原记录 | 未登记 |  |
| [AT230_SM004_rev14_rope_sticky_reentry_fullcheck_01](attempts/AT230_SM004_rev14_rope_sticky_reentry_fullcheck_01) | 未登记；查看原记录 | 未登记 |  |
| [AT231_SM004_rev14_rope_old_sticky_repro_01](attempts/AT231_SM004_rev14_rope_old_sticky_repro_01) | 未登记；查看原记录 | 未登记 |  |
| [AT232_SM004_rev14_rope_order_sticky_real_core_elab_01](attempts/AT232_SM004_rev14_rope_order_sticky_real_core_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT233_SM004_rev14_rope_mul_observation_reset_01](attempts/AT233_SM004_rev14_rope_mul_observation_reset_01) | 未登记；查看原记录 | 未登记 |  |
| [AT234_SM004_rev14_rope_bus_common_reset_01](attempts/AT234_SM004_rev14_rope_bus_common_reset_01) | 未登记；查看原记录 | 未登记 |  |
| [AT235_SM004_rev14_rope_page_split_bus_hold_01](attempts/AT235_SM004_rev14_rope_page_split_bus_hold_01) | 未登记；查看原记录 | 未登记 |  |
| [AT236_SM004_rev14_rope_saved_s127_h15_leaf_01](attempts/AT236_SM004_rev14_rope_saved_s127_h15_leaf_01) | 未登记；查看原记录 | 未登记 |  |
| [AT237_SM004_rev14_rope_asymmetric_half_table_01](attempts/AT237_SM004_rev14_rope_asymmetric_half_table_01) | 未登记；查看原记录 | 未登记 |  |
| [AT238_SM004_rev14_rope_final_meta128_peer_01](attempts/AT238_SM004_rev14_rope_final_meta128_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT239_SM004_rev14_rope_final_meta128_row_address_fix_01](attempts/AT239_SM004_rev14_rope_final_meta128_row_address_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT240_SM004_rev14_rope_final_meta128_hold_fix_01](attempts/AT240_SM004_rev14_rope_final_meta128_hold_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT241_SM004_rev14_final_local_tb_original_leaf_01](attempts/AT241_SM004_rev14_final_local_tb_original_leaf_01) | 未登记；查看原记录 | 未登记 |  |
| [AT242_SM004_rev14_rope_check_error_edges_01](attempts/AT242_SM004_rev14_rope_check_error_edges_01) | 未登记；查看原记录 | 未登记 |  |
| [AT243_SM004_rev15_source_initial_elab_01](attempts/AT243_SM004_rev15_source_initial_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT244_SM004_rev15_source_elab_fix_01](attempts/AT244_SM004_rev15_source_elab_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT245_SM004_rev15_source_rows_pilot_01](attempts/AT245_SM004_rev15_source_rows_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT246_SM004_rev15_source_prepare_local_01](attempts/AT246_SM004_rev15_source_prepare_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT247_SM004_rev15_s128_sequencer_elab_01](attempts/AT247_SM004_rev15_s128_sequencer_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT248_SM004_rev15_s128_peer_01](attempts/AT248_SM004_rev15_s128_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT249_SM004_rev15_s128_peer_portfix_01](attempts/AT249_SM004_rev15_s128_peer_portfix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT250_SM004_rev15_s128_real_prefix_01](attempts/AT250_SM004_rev15_s128_real_prefix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT251_SM004_rev15_input_error_reset_local_01](attempts/AT251_SM004_rev15_input_error_reset_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT252_SM004_rev15_s128_latched_fields_peer_01](attempts/AT252_SM004_rev15_s128_latched_fields_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT253_SM004_rev15_legacy_local_peer_01](attempts/AT253_SM004_rev15_legacy_local_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT254_SM004_rev15_reset_epoch_full_recovery_01](attempts/AT254_SM004_rev15_reset_epoch_full_recovery_01) | 未登记；查看原记录 | 未登记 |  |
| [AT255_SM004_rev15_reset_guard_epoch_fix_01](attempts/AT255_SM004_rev15_reset_guard_epoch_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT256_SM004_rev15_input_abort_aux_identity_01](attempts/AT256_SM004_rev15_input_abort_aux_identity_01) | 未登记；查看原记录 | 未登记 |  |
| [AT257_SM004_rev15_early_input_fault_drain_peer_01](attempts/AT257_SM004_rev15_early_input_fault_drain_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT258_SM004_rev15_early_input_fault_declfix_01](attempts/AT258_SM004_rev15_early_input_fault_declfix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT259_SM004_rev15_early_fault_observed_peer_01](attempts/AT259_SM004_rev15_early_fault_observed_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT260_SM004_rev15_fixed_wrapper_legacy_local_01](attempts/AT260_SM004_rev15_fixed_wrapper_legacy_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT261_SM004_rev15_source_page_row127_01](attempts/AT261_SM004_rev15_source_page_row127_01) | 未登记；查看原记录 | 未登记 |  |
| [AT262_SM004_rev15_legacy_external_ln_boundary_01](attempts/AT262_SM004_rev15_legacy_external_ln_boundary_01) | 未登记；查看原记录 | 未登记 |  |
| [AT263_SM004_rev15_prepared_token_boundary_01](attempts/AT263_SM004_rev15_prepared_token_boundary_01) | 未登记；查看原记录 | 未登记 |  |
| [AT264_SM004_rev15_source_logical_sentinel_01](attempts/AT264_SM004_rev15_source_logical_sentinel_01) | 未登记；查看原记录 | 未登记 |  |
| [AT265_SM004_rev15_s128_last_row_error_peer_01](attempts/AT265_SM004_rev15_s128_last_row_error_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT266_SM004_rev16_attention_final_tile_01](attempts/AT266_SM004_rev16_attention_final_tile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT267_SM004_rev16_attention_tb_edge_fix_01](attempts/AT267_SM004_rev16_attention_tb_edge_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT268_SM004_rev16_attention_eight_tile_01](attempts/AT268_SM004_rev16_attention_eight_tile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT269_SM004_rev16_attention_error_transport_01](attempts/AT269_SM004_rev16_attention_error_transport_01) | 未登记；查看原记录 | 未登记 |  |
| [AT270_SM004_rev16_attention_drain_rearm_01](attempts/AT270_SM004_rev16_attention_drain_rearm_01) | 未登记；查看原记录 | 未登记 |  |
| [AT271_SM004_rev16_attention_aw_stall_peer_01](attempts/AT271_SM004_rev16_attention_aw_stall_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT272_SM004_rev16_attention_q_last_rerr_01](attempts/AT272_SM004_rev16_attention_q_last_rerr_01) | 未登记；查看原记录 | 未登记 |  |
| [AT273_SM004_rev17_lnq_core_syntax_01](attempts/AT273_SM004_rev17_lnq_core_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT274_SM004_rev17_current_syntax_01](attempts/AT274_SM004_rev17_current_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT275_SM004_rev17_lnq_stage_modes_01](attempts/AT275_SM004_rev17_lnq_stage_modes_01) | 未登记；查看原记录 | 未登记 |  |
| [AT276_SM004_rev17_lnq_stage_modes_deps_01](attempts/AT276_SM004_rev17_lnq_stage_modes_deps_01) | 未登记；查看原记录 | 未登记 |  |
| [AT277_SM004_rev17_lnq_stage_modes_qformat_01](attempts/AT277_SM004_rev17_lnq_stage_modes_qformat_01) | 未登记；查看原记录 | 未登记 |  |
| [AT278_SM004_rev17_lnq_direct_norm_fix_01](attempts/AT278_SM004_rev17_lnq_direct_norm_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT279_SM004_rev17_stage_wrapper_syntax_01](attempts/AT279_SM004_rev17_stage_wrapper_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT280_SM004_rev17_staged_ln_rows01_01](attempts/AT280_SM004_rev17_staged_ln_rows01_01) | 未登记；查看原记录 | 未登记 |  |
| [AT281_SM004_rev17_staged_ln_rows01_progress_01](attempts/AT281_SM004_rev17_staged_ln_rows01_progress_01) | 未登记；查看原记录 | 未登记 |  |
| [AT282_SM004_rev17_staged_ln_norm_tile_fix_01](attempts/AT282_SM004_rev17_staged_ln_norm_tile_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT283_SM004_rev17_staged_ln_seq_peer_01](attempts/AT283_SM004_rev17_staged_ln_seq_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT284_SM004_rev17_ln128_pilot_01](attempts/AT284_SM004_rev17_ln128_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT285_SM004_rev17_ln128_pilot_tb_decl_fix_01](attempts/AT285_SM004_rev17_ln128_pilot_tb_decl_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT286_SM004_rev17_ln128_pilot_port_fix_01](attempts/AT286_SM004_rev17_ln128_pilot_port_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT287_SM004_rev17_ln128_pilot_ports_complete_01](attempts/AT287_SM004_rev17_ln128_pilot_ports_complete_01) | 未登记；查看原记录 | 未登记 |  |
| [AT288_SM004_rev17_q16_bank_window_01](attempts/AT288_SM004_rev17_q16_bank_window_01) | 未登记；查看原记录 | 未登记 |  |
| [AT289_SM004_rev17_q16_guard_marker_fix_01](attempts/AT289_SM004_rev17_q16_guard_marker_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT290_SM004_rev17_q16_current_core_gate_01](attempts/AT290_SM004_rev17_q16_current_core_gate_01) | 未登记；查看原记录 | 未登记 |  |
| [AT291_SM004_rev17_staged_ln_error_recovery_01](attempts/AT291_SM004_rev17_staged_ln_error_recovery_01) | 未登记；查看原记录 | 未登记 |  |
| [AT292_SM004_rev17_staged_ln_error_gamma_reload_tb_fix_01](attempts/AT292_SM004_rev17_staged_ln_error_gamma_reload_tb_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT293_SM004_rev17_store_window_priority_peer_01](attempts/AT293_SM004_rev17_store_window_priority_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT294_SM004_rev17_store_priority_peer_sample_fix_01](attempts/AT294_SM004_rev17_store_priority_peer_sample_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT295_SM004_rev17_real_ln_store_drain_row_01](attempts/AT295_SM004_rev17_real_ln_store_drain_row_01) | 未登记；查看原记录 | 未登记 |  |
| [AT296_SM004_rev17_real_ln_discard_ack_01](attempts/AT296_SM004_rev17_real_ln_discard_ack_01) | 未登记；查看原记录 | 未登记 |  |
| [AT297_SM004_rev17_current_ln128_prefix_pilot_01](attempts/AT297_SM004_rev17_current_ln128_prefix_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT298_SM004_rev17_current_seq_norm_metadata_regression_01](attempts/AT298_SM004_rev17_current_seq_norm_metadata_regression_01) | 未登记；查看原记录 | 未登记 |  |
| [AT299_SM004_rev17_staged_ready_common_reset_peer_01](attempts/AT299_SM004_rev17_staged_ready_common_reset_peer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT300_SM004_rev17_lnq_legacy_modes_compat_01](attempts/AT300_SM004_rev17_lnq_legacy_modes_compat_01) | 未登记；查看原记录 | 未登记 |  |
| [AT301_SM004_rev18_q16_partial_old_repro_01](attempts/AT301_SM004_rev18_q16_partial_old_repro_01) | 未登记；查看原记录 | 未登记 |  |
| [AT302_SM004_rev18_q16_partial_old_incremental_build_01](attempts/AT302_SM004_rev18_q16_partial_old_incremental_build_01) | 未登记；查看原记录 | 未登记 |  |
| [AT303_SM004_rev18_q16_partial_owner_fix_01](attempts/AT303_SM004_rev18_q16_partial_owner_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT304_SM004_rev18_ln128_current_default_diag_01](attempts/AT304_SM004_rev18_ln128_current_default_diag_01) | 未登记；查看原记录 | 未登记 |  |
| [AT305_SM004_rev18_ln128_o3_diag_01](attempts/AT305_SM004_rev18_ln128_o3_diag_01) | 未登记；查看原记录 | 未登记 |  |
| [AT306_SM004_rev18_ln128_o3_16row_pilot_01](attempts/AT306_SM004_rev18_ln128_o3_16row_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT307_SM004_rev19_shared_bank_static_01](attempts/AT307_SM004_rev19_shared_bank_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT308_SM004_rev19_shared_bank_parent_elab_01](attempts/AT308_SM004_rev19_shared_bank_parent_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT309_SM004_rev19_shared_transport_parent_elab_01](attempts/AT309_SM004_rev19_shared_transport_parent_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT310_SM004_rev19_shared_prep_parent_elab_01](attempts/AT310_SM004_rev19_shared_prep_parent_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT311_SM004_rev19_shared_q16_result_parent_elab_01](attempts/AT311_SM004_rev19_shared_q16_result_parent_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT312_SM004_rev19_shared_q16_window_01](attempts/AT312_SM004_rev19_shared_q16_window_01) | 未登记；查看原记录 | 未登记 |  |
| [AT313_SM004_rev19_shared_q16_service_compile_01](attempts/AT313_SM004_rev19_shared_q16_service_compile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT314_SM004_rev19_shared_q16_service_tb_fix_01](attempts/AT314_SM004_rev19_shared_q16_service_tb_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT315_SM004_rev19_current_parent_row0_01](attempts/AT315_SM004_rev19_current_parent_row0_01) | 未登记；查看原记录 | 未登记 |  |
| [AT316_SM004_rev19_service_route_stage_ownership_01](attempts/AT316_SM004_rev19_service_route_stage_ownership_01) | 未登记；查看原记录 | 未登记 |  |
| [AT317_SM004_rev19_stage_fault_owner_regression_01](attempts/AT317_SM004_rev19_stage_fault_owner_regression_01) | 未登记；查看原记录 | 未登记 |  |
| [AT318_SM004_rev19_stage_progress_guard_fix_01](attempts/AT318_SM004_rev19_stage_progress_guard_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT319_SM004_rev19_lower_staged_lifecycle_01](attempts/AT319_SM004_rev19_lower_staged_lifecycle_01) | 未登记；查看原记录 | 未登记 |  |
| [AT320_SM004_rev19_lower_staged_declaration_fix_01](attempts/AT320_SM004_rev19_lower_staged_declaration_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT321_SM004_rev19_lower_q16_final_rescan_01](attempts/AT321_SM004_rev19_lower_q16_final_rescan_01) | 未登记；查看原记录 | 未登记 |  |
| [AT322_SM004_rev19_parent_row0_tb_port_fix_01](attempts/AT322_SM004_rev19_parent_row0_tb_port_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT323_SM004_rev19_final_lower_q16_parent_row0_01](attempts/AT323_SM004_rev19_final_lower_q16_parent_row0_01) | 未登记；查看原记录 | 未登记 |  |
| [AT324_SM004_rev19_lower_ln_view_bad_tile_01](attempts/AT324_SM004_rev19_lower_ln_view_bad_tile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT325_SM004_rev19_shared_bank_clients_01](attempts/AT325_SM004_rev19_shared_bank_clients_01) | 未登记；查看原记录 | 未登记 |  |
| [AT326_SM004_rev20_lower_full_check_01](attempts/AT326_SM004_rev20_lower_full_check_01) | 未登记；查看原记录 | 未登记 |  |
| [AT327_SM004_rev20_internal_stage_coverage_parent_row0_01](attempts/AT327_SM004_rev20_internal_stage_coverage_parent_row0_01) | 未登记；查看原记录 | 未登记 |  |
| [AT328_SM004_rev20_physical_bank_parent_elab_01](attempts/AT328_SM004_rev20_physical_bank_parent_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT329_SM004_rev20_local_reject_old_repro_01](attempts/AT329_SM004_rev20_local_reject_old_repro_01) | 未登记；查看原记录 | 未登记 |  |
| [AT330_SM004_rev20_local_reject_check_fix_01](attempts/AT330_SM004_rev20_local_reject_check_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT331_SM004_rev20_fixed_bank_parent_row0_01](attempts/AT331_SM004_rev20_fixed_bank_parent_row0_01) | 未登记；查看原记录 | 未登记 |  |
| [AT332_SM004_rev20_source_prep_owner_syntax_01](attempts/AT332_SM004_rev20_source_prep_owner_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT333_SM004_rev20_source_prep_parent_row0_01](attempts/AT333_SM004_rev20_source_prep_parent_row0_01) | 未登记；查看原记录 | 未登记 |  |
| [AT334_SM004_rev20_source_prep_parent_fullclosure_01](attempts/AT334_SM004_rev20_source_prep_parent_fullclosure_01) | 未登记；查看原记录 | 未登记 |  |
| [AT335_SM004_rev20_norm_store_owner_syntax_01](attempts/AT335_SM004_rev20_norm_store_owner_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT336_SM004_rev20_norm_store_owner_parent_row0_01](attempts/AT336_SM004_rev20_norm_store_owner_parent_row0_01) | 未登记；查看原记录 | 未登记 |  |
| [AT337_SM004_rev20_norm_store_stall_probe_01](attempts/AT337_SM004_rev20_norm_store_stall_probe_01) | 未登记；查看原记录 | 未登记 |  |
| [AT338_SM004_rev20_writer_flush_probe_01](attempts/AT338_SM004_rev20_writer_flush_probe_01) | 未登记；查看原记录 | 未登记 |  |
| [AT339_SM004_rev20_writer_flush_connection_fix_01](attempts/AT339_SM004_rev20_writer_flush_connection_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT340_SM004_rev20_single_owner_syntax_01](attempts/AT340_SM004_rev20_single_owner_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT341_SM004_rev20_single_owner_syntax_fix_01](attempts/AT341_SM004_rev20_single_owner_syntax_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT342_SM004_rev20_independent_stage_build_01](attempts/AT342_SM004_rev20_independent_stage_build_01) | 未登记；查看原记录 | 未登记 |  |
| [AT343_SM004_rev20_final_shared_stage_parent_build_01](attempts/AT343_SM004_rev20_final_shared_stage_parent_build_01) | 未登记；查看原记录 | 未登记 |  |
| [AT344_SM004_rev20_stage_error_recovery_build_01](attempts/AT344_SM004_rev20_stage_error_recovery_build_01) | 未登记；查看原记录 | 未登记 |  |
| [AT345_SM004_rev20_gamma_bus_page_build_01](attempts/AT345_SM004_rev20_gamma_bus_page_build_01) | 未登记；查看原记录 | 未登记 |  |
| [AT346_SM004_rev20_gamma_recovery_tb_fix_01](attempts/AT346_SM004_rev20_gamma_recovery_tb_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT347_SM004_rev20_stage_descriptor_reject_01](attempts/AT347_SM004_rev20_stage_descriptor_reject_01) | 未登记；查看原记录 | 未登记 |  |
| [AT348_SM004_rev20_stage_descriptor_reject_tb_fix_01](attempts/AT348_SM004_rev20_stage_descriptor_reject_tb_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT349_SM004_rev20_stage_descriptor_reject_recovery_01](attempts/AT349_SM004_rev20_stage_descriptor_reject_recovery_01) | 未登记；查看原记录 | 未登记 |  |
| [AT350_SM004_rev20_stage_prep_reset_01](attempts/AT350_SM004_rev20_stage_prep_reset_01) | 未登记；查看原记录 | 未登记 |  |
| [AT351_SM004_rev20_local_reject_consumed_recovery_01](attempts/AT351_SM004_rev20_local_reject_consumed_recovery_01) | 未登记；查看原记录 | 未登记 |  |
| [AT352_SM004_rev21_interface_syntax_01](attempts/AT352_SM004_rev21_interface_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT353_SM004_rev21_continue_q16_syntax_01](attempts/AT353_SM004_rev21_continue_q16_syntax_01) | 未登记；查看原记录 | 未登记 |  |
| [AT354_SM004_rev21_independent_stage_elab_01](attempts/AT354_SM004_rev21_independent_stage_elab_01) | 未登记；查看原记录 | 未登记 |  |
| [AT355_SM004_rev21_independent_stage_elab_fix_01](attempts/AT355_SM004_rev21_independent_stage_elab_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT356_SM004_rev21_wprep_local_build_01](attempts/AT356_SM004_rev21_wprep_local_build_01) | 未登记；查看原记录 | 未登记 |  |
| [AT357_SM004_rev21_ln16_incremental_pilot_01](attempts/AT357_SM004_rev21_ln16_incremental_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT358_SM004_rev21_chain_static_pilot_01](attempts/AT358_SM004_rev21_chain_static_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT359_SM004_rev21_q16_first16_cost_01](attempts/AT359_SM004_rev21_q16_first16_cost_01) | 未登记；查看原记录 | 未登记 |  |
| [AT360_SM004_rev21_q16_first16_fix_01](attempts/AT360_SM004_rev21_q16_first16_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT361_SM004_rev21_lower_q16_first16_01](attempts/AT361_SM004_rev21_lower_q16_first16_01) | 未登记；查看原记录 | 未登记 |  |
| [AT362_SM004_rev21_lower_q16_path_fix_01](attempts/AT362_SM004_rev21_lower_q16_path_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT363_SM004_rev21_full_chain_01](attempts/AT363_SM004_rev21_full_chain_01) | 未登记；查看原记录 | 未登记 |  |
| [AT364_SM004_rev21_chain_final_observer_fix_01](attempts/AT364_SM004_rev21_chain_final_observer_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT365_SM004_rev21_parent_row0_build_01](attempts/AT365_SM004_rev21_parent_row0_build_01) | 未登记；查看原记录 | 未登记 |  |
| [AT366_SM004_rev21_parent_enum_fix_01](attempts/AT366_SM004_rev21_parent_enum_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT367_SM004_rev21_parent_elab_mt4_01](attempts/AT367_SM004_rev21_parent_elab_mt4_01) | 未登记；查看原记录 | 未登记 |  |
| [AT368_SM004_rev21_chain_leaf_observer_01](attempts/AT368_SM004_rev21_chain_leaf_observer_01) | 未登记；查看原记录 | 未登记 |  |
| [AT369_SM004_rev21_core_reject_wprep_01](attempts/AT369_SM004_rev21_core_reject_wprep_01) | 未登记；查看原记录 | 未登记 |  |
| [AT370_SM004_rev21_core_wprep_shell_fix_01](attempts/AT370_SM004_rev21_core_wprep_shell_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT371_SM004_rev21_wprep_full_fields_01](attempts/AT371_SM004_rev21_wprep_full_fields_01) | 未登记；查看原记录 | 未登记 |  |
| [AT372_SM004_rev21_core_wprep_o3_pilot_01](attempts/AT372_SM004_rev21_core_wprep_o3_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT373_SM004_rev21_partial_a_discard_recovery_01](attempts/AT373_SM004_rev21_partial_a_discard_recovery_01) | 未登记；查看原记录 | 未登记 |  |
| [AT374_SM004_rev21_q_inflight_reset_01](attempts/AT374_SM004_rev21_q_inflight_reset_01) | 未登记；查看原记录 | 未登记 |  |
| [AT375_SM004_rev21_chain_w_bus_error_01](attempts/AT375_SM004_rev21_chain_w_bus_error_01) | 未登记；查看原记录 | 未登记 |  |
| [AT376_SM004_rev21_continue_last_b_barrier_01](attempts/AT376_SM004_rev21_continue_last_b_barrier_01) | 未登记；查看原记录 | 未登记 |  |
| [AT377_SM004_rev21_state1_last_r_hold_01](attempts/AT377_SM004_rev21_state1_last_r_hold_01) | 未登记；查看原记录 | 未登记 |  |
| [AT378_SM004_rev21_w_error_discard_recovery_01](attempts/AT378_SM004_rev21_w_error_discard_recovery_01) | 未登记；查看原记录 | 未登记 |  |
| [AT379_SM004_rev21_stage_done_hold_01](attempts/AT379_SM004_rev21_stage_done_hold_01) | 未登记；查看原记录 | 未登记 |  |
| [AT380_SM004_rev21_parent_continue_static_01](attempts/AT380_SM004_rev21_parent_continue_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT381_SM004_rev21_parent_continue_core_fix_01](attempts/AT381_SM004_rev21_parent_continue_core_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT382_SM004_rev21_parent_continue_tb_ports_01](attempts/AT382_SM004_rev21_parent_continue_tb_ports_01) | 未登记；查看原记录 | 未登记 |  |
| [AT383_SM004_rev21_parent_ln_prefix_pilot_01](attempts/AT383_SM004_rev21_parent_ln_prefix_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT384_SM004_rev22_front_step16_pilot_01](attempts/AT384_SM004_rev22_front_step16_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT385_SM004_rev22_front_tb_declaration_fix_01](attempts/AT385_SM004_rev22_front_tb_declaration_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT386_SM004_rev22_front_bank_tb_dependency_01](attempts/AT386_SM004_rev22_front_bank_tb_dependency_01) | 未登记；查看原记录 | 未登记 |  |
| [AT387_SM004_rev22_front_step16_first_tile_01](attempts/AT387_SM004_rev22_front_step16_first_tile_01) | 未登记；查看原记录 | 未登记 |  |
| [AT388_SM004_rev22_legacy_abort_diagnostic_01](attempts/AT388_SM004_rev22_legacy_abort_diagnostic_01) | 未登记；查看原记录 | 未登记 |  |
| [AT389_SM004_rev22_legacy_rows_width_fix_01](attempts/AT389_SM004_rev22_legacy_rows_width_fix_01) | 未登记；查看原记录 | 未登记 |  |
| [AT390_SM004_rev22_a_claim_q16_local_01](attempts/AT390_SM004_rev22_a_claim_q16_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT391_SM004_rev22_a_claim_tb_ports_01](attempts/AT391_SM004_rev22_a_claim_tb_ports_01) | 未登记；查看原记录 | 未登记 |  |
| [AT392_SM004_rev22_a_claim_tb_hierarchy_01](attempts/AT392_SM004_rev22_a_claim_tb_hierarchy_01) | 未登记；查看原记录 | 未登记 |  |
| [AT393_SM004_rev22_a_claim_fixture_binding_01](attempts/AT393_SM004_rev22_a_claim_fixture_binding_01) | 未登记；查看原记录 | 未登记 |  |
| [AT394_SM004_rev22_a_claim_lower_first16_01](attempts/AT394_SM004_rev22_a_claim_lower_first16_01) | 未登记；查看原记录 | 未登记 |  |
| [AT395_SM004_rev22_matrix_upper_static_01](attempts/AT395_SM004_rev22_matrix_upper_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT396_SM004_rev22_matrix_first_tn8_local_01](attempts/AT396_SM004_rev22_matrix_first_tn8_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT397_SM004_rev22_matrix_peer_tn8_pilot_01](attempts/AT397_SM004_rev22_matrix_peer_tn8_pilot_01) | 未登记；查看原记录 | 未登记 |  |
| [AT398_SM004_rev22_matrix_peer_final_gold_01](attempts/AT398_SM004_rev22_matrix_peer_final_gold_01) | 未登记；查看原记录 | 未登记 |  |
| [AT399_SM004_rev22_matrix_real_w_local_01](attempts/AT399_SM004_rev22_matrix_real_w_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT400_SM004_rev22_matrix_real_w_tb_decls_01](attempts/AT400_SM004_rev22_matrix_real_w_tb_decls_01) | 未登记；查看原记录 | 未登记 |  |
| [AT401_SM004_rev22_matrix_real_w_fixture_01](attempts/AT401_SM004_rev22_matrix_real_w_fixture_01) | 未登记；查看原记录 | 未登记 |  |
| [AT402_SM004_rev22_matrix_real_w_context_01](attempts/AT402_SM004_rev22_matrix_real_w_context_01) | 未登记；查看原记录 | 未登记 |  |
| [AT403_SM004_rev22_full_chain_matrix_static_01](attempts/AT403_SM004_rev22_full_chain_matrix_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT404_SM004_rev22_full_chain_matrix_tb_ports_01](attempts/AT404_SM004_rev22_full_chain_matrix_tb_ports_01) | 未登记；查看原记录 | 未登记 |  |
| [AT405_SM004_rev22_ps_controller_extraction_static_01](attempts/AT405_SM004_rev22_ps_controller_extraction_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT406_SM004_rev22_ps_writer_ctrl_local_01](attempts/AT406_SM004_rev22_ps_writer_ctrl_local_01) | 未登记；查看原记录 | 未登记 |  |
| [AT407_SM004_rev22_ps_writer_ctrl_trace_01](attempts/AT407_SM004_rev22_ps_writer_ctrl_trace_01) | 未登记；查看原记录 | 未登记 |  |
| [AT408_SM004_rev22_ps_writer_ctrl_row_advance_fix_01](attempts/AT408_SM004_rev22_ps_writer_ctrl_row_advance_fix_01) | 未登记；查看原记录 | 未登记 |  |

## 本批问题与交付文件


## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
