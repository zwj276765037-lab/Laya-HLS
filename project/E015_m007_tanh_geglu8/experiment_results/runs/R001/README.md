

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E015 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001 — E015

Recorded: 2026-10-21T05:44:36.613223+00:00

Execution state: running
Verdict: unassessed

- Exact command and working directory: Every actual AT receipt records argv and project cwd; all compute uses vector_and_ffn/tb/m007_tanh_guard.py and the common project heavy lock through all owned descendants.
- Host, tool and platform versions: host user, Vivado2025.2/XSim. Small leaf OOC xcu55c-fsvh2892-2L-e, effective3.333ns, uncertainty0.1ns and complete0.5ns IO delays. Synthesis+opt only.
- Code identity (commit/hash), external constraints and IP identity: per-AT sources.tar.gz + source_sha256 + archive hash. The validated E014 process lifetime helper is reused read-only with explicit SHA. No shared arithmetic/storage RTL is edited.
- Input/data identity and reproducibility inputs: frozen independent E008 native SSE vectors, and AT007 original local Encoder0 all128-row WO/residual/LN/Wi/G reference. Original context and hidden, actual GGUF WO/Wi payloads and full_reference.py are hash-checked. AT007 report binds all output products.
- Start/end times: actual E015 implementation launch07:09:33 UTC; all command start/lock wait/child start/end timestamps are recorded individ

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_fast_leaf_build](attempts/AT001_fast_leaf_build) | FAIL | 未登记 | [执行收据](attempts/AT001_fast_leaf_build/receipt.json) |
| [AT002_fast_leaf_syntax_build](attempts/AT002_fast_leaf_syntax_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT002_fast_leaf_syntax_build/receipt.json) |
| [AT003_add3_original_vectors](attempts/AT003_add3_original_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT003_add3_original_vectors/receipt.json) |
| [AT004_mul4_original_vectors](attempts/AT004_mul4_original_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT004_mul4_original_vectors/receipt.json) |
| [AT005_div12_original_vectors](attempts/AT005_div12_original_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT005_div12_original_vectors/receipt.json) |
| [AT006_add3_io_ooc](attempts/AT006_add3_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT006_add3_io_ooc/receipt.json) |
| [AT007_encoder0_real_local_reference](attempts/AT007_encoder0_real_local_reference) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT007_encoder0_real_local_reference/receipt.json) |
| [AT008_original_dag_fast_retime](attempts/AT008_original_dag_fast_retime) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT008_original_dag_fast_retime/receipt.json) |
| [AT009_add3_repartition_build](attempts/AT009_add3_repartition_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT009_add3_repartition_build/receipt.json) |
| [AT010_mul4_io_ooc](attempts/AT010_mul4_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT010_mul4_io_ooc/receipt.json) |
| [AT011_div12_io_ooc](attempts/AT011_div12_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT011_div12_io_ooc/receipt.json) |
| [AT012_add3_repartition_io_ooc](attempts/AT012_add3_repartition_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT012_add3_repartition_io_ooc/receipt.json) |
| [AT013_native_node_oracle_build](attempts/AT013_native_node_oracle_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT013_native_node_oracle_build/receipt.json) |
| [AT014_add3_repartition_vectors](attempts/AT014_add3_repartition_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT014_add3_repartition_vectors/receipt.json) |
| [AT015_single_tanh_lane_build](attempts/AT015_single_tanh_lane_build) | 未登记；查看原记录 | 未登记 |  |
| [AT016_div12_radix4_build](attempts/AT016_div12_radix4_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT016_div12_radix4_build/receipt.json) |
| [AT017_add3_zero_path_build](attempts/AT017_add3_zero_path_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT017_add3_zero_path_build/receipt.json) |
| [AT018_original_tanh_native_node_reference](attempts/AT018_original_tanh_native_node_reference) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT018_original_tanh_native_node_reference/receipt.json) |
| [AT019_div12_radix4_original_vectors](attempts/AT019_div12_radix4_original_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT019_div12_radix4_original_vectors/receipt.json) |
| [AT020_add3_zero_path_original_vectors](attempts/AT020_add3_zero_path_original_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT020_add3_zero_path_original_vectors/receipt.json) |
| [AT021_div12_radix4_io_ooc](attempts/AT021_div12_radix4_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT021_div12_radix4_io_ooc/receipt.json) |
| [AT022_add3_zero_path_io_ooc](attempts/AT022_add3_zero_path_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT022_add3_zero_path_io_ooc/receipt.json) |
| [AT023_single_tanh_new_leaf_retime](attempts/AT023_single_tanh_new_leaf_retime) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT023_single_tanh_new_leaf_retime/receipt.json) |
| [AT024_single_tanh_new_leaf_build](attempts/AT024_single_tanh_new_leaf_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT024_single_tanh_new_leaf_build/receipt.json) |
| [AT025_add3_overflow_path_build](attempts/AT025_add3_overflow_path_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT025_add3_overflow_path_build/receipt.json) |
| [AT026_add_overflow_boundary_ref_build](attempts/AT026_add_overflow_boundary_ref_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT026_add_overflow_boundary_ref_build/receipt.json) |
| [AT027_single_tanh_42node_pilot](attempts/AT027_single_tanh_42node_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT027_single_tanh_42node_pilot/receipt.json) |
| [AT028_add_overflow_boundary_reference](attempts/AT028_add_overflow_boundary_reference) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT028_add_overflow_boundary_reference/receipt.json) |
| [AT029_add3_overflow_original_vectors](attempts/AT029_add3_overflow_original_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT029_add3_overflow_original_vectors/receipt.json) |
| [AT030_add3_overflow_directed_vectors](attempts/AT030_add3_overflow_directed_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT030_add3_overflow_directed_vectors/receipt.json) |
| [AT031_add3_overflow_io_ooc](attempts/AT031_add3_overflow_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT031_add3_overflow_io_ooc/receipt.json) |
| [AT032_single_tanh_16384_cost_pilot](attempts/AT032_single_tanh_16384_cost_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT032_single_tanh_16384_cost_pilot/receipt.json) |
| [AT033_single_tanh_full_cost_gate](attempts/AT033_single_tanh_full_cost_gate) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT033_single_tanh_full_cost_gate/receipt.json) |
| [AT035_frozen_cost_guard_cli](attempts/AT035_frozen_cost_guard_cli) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT035_frozen_cost_guard_cli/receipt.json) |
| [AT036_semantic_stall_guard_unit](attempts/AT036_semantic_stall_guard_unit) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT036_semantic_stall_guard_unit/receipt.json) |
| [AT037_single_tanh_semantic_observer_build](attempts/AT037_single_tanh_semantic_observer_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT037_single_tanh_semantic_observer_build/receipt.json) |
| [AT038_single_tanh_semantic_16384_pilot](attempts/AT038_single_tanh_semantic_16384_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT038_single_tanh_semantic_16384_pilot/receipt.json) |
| [AT039_single_tanh_semantic_full_cost_gate](attempts/AT039_single_tanh_semantic_full_cost_gate) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT039_single_tanh_semantic_full_cost_gate/receipt.json) |
| [AT040_single_tanh_complete_original_v3](attempts/AT040_single_tanh_complete_original_v3) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT040_single_tanh_complete_original_v3/receipt.json) |
| [AT041_add3_exponent_align_build](attempts/AT041_add3_exponent_align_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT041_add3_exponent_align_build/receipt.json) |
| [AT042_add3_exponent_align_original_vectors](attempts/AT042_add3_exponent_align_original_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT042_add3_exponent_align_original_vectors/receipt.json) |
| [AT043_add3_exponent_align_directed_vectors](attempts/AT043_add3_exponent_align_directed_vectors) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT043_add3_exponent_align_directed_vectors/receipt.json) |
| [AT044_add3_exponent_align_io_ooc](attempts/AT044_add3_exponent_align_io_ooc) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT044_add3_exponent_align_io_ooc/receipt.json) |
| [AT045_single_tanh_setup_positive_retime](attempts/AT045_single_tanh_setup_positive_retime) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT045_single_tanh_setup_positive_retime/receipt.json) |
| [AT046_single_tanh_setup_positive_build](attempts/AT046_single_tanh_setup_positive_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT046_single_tanh_setup_positive_build/receipt.json) |
| [AT047_single_tanh_setup_positive_16384_pilot](attempts/AT047_single_tanh_setup_positive_16384_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT047_single_tanh_setup_positive_16384_pilot/receipt.json) |
| [AT048_single_tanh_setup_positive_full_cost](attempts/AT048_single_tanh_setup_positive_full_cost) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT048_single_tanh_setup_positive_full_cost/receipt.json) |
| [AT049_single_tanh_setup_positive_complete](attempts/AT049_single_tanh_setup_positive_complete) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT049_single_tanh_setup_positive_complete/receipt.json) |
| [AT050_tanh8_setup_positive_build](attempts/AT050_tanh8_setup_positive_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT050_tanh8_setup_positive_build/receipt.json) |
| [AT051_tanh8_32768_original_pilot](attempts/AT051_tanh8_32768_original_pilot) | FAIL | 未登记 | [执行收据](attempts/AT051_tanh8_32768_original_pilot/receipt.json) |
| [AT052_tanh8_ready_settle_build](attempts/AT052_tanh8_ready_settle_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT052_tanh8_ready_settle_build/receipt.json) |
| [AT053_tanh8_exact_counts_32768_pilot](attempts/AT053_tanh8_exact_counts_32768_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT053_tanh8_exact_counts_32768_pilot/receipt.json) |
| [AT054_tanh8_complete_original_cost](attempts/AT054_tanh8_complete_original_cost) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT054_tanh8_complete_original_cost/receipt.json) |
| [AT055_tanh8_complete_original](attempts/AT055_tanh8_complete_original) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT055_tanh8_complete_original/receipt.json) |
| [AT056_g_pairs_native_bank_build](attempts/AT056_g_pairs_native_bank_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT056_g_pairs_native_bank_build/receipt.json) |
| [AT057_g_pairs_native_bank_protocol](attempts/AT057_g_pairs_native_bank_protocol) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT057_g_pairs_native_bank_protocol/receipt.json) |
| [AT058_g_original_product_fixture](attempts/AT058_g_original_product_fixture) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT058_g_original_product_fixture/receipt.json) |
| [AT059_g_math_real_sfu_build](attempts/AT059_g_math_real_sfu_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT059_g_math_real_sfu_build/receipt.json) |
| [AT060_g_math_three_original_groups](attempts/AT060_g_math_three_original_groups) | FAIL | 未登记 | [执行收据](attempts/AT060_g_math_three_original_groups/receipt.json) |
| [AT061_g_math_output_observer_build](attempts/AT061_g_math_output_observer_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT061_g_math_output_observer_build/receipt.json) |
| [AT062_g_math_packed_output_three_groups](attempts/AT062_g_math_packed_output_three_groups) | FAIL | 未登记 | [执行收据](attempts/AT062_g_math_packed_output_three_groups/receipt.json) |
| [AT063_g_math_direct_fixture_observer_build](attempts/AT063_g_math_direct_fixture_observer_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT063_g_math_direct_fixture_observer_build/receipt.json) |
| [AT064_g_math_direct_fixture_three_groups](attempts/AT064_g_math_direct_fixture_three_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT064_g_math_direct_fixture_three_groups/receipt.json) |
| [AT065_g_engine_sole_resources_build](attempts/AT065_g_engine_sole_resources_build) | FAIL | 未登记 | [执行收据](attempts/AT065_g_engine_sole_resources_build/receipt.json) |
| [AT066_g_engine_declaration_build](attempts/AT066_g_engine_declaration_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT066_g_engine_declaration_build/receipt.json) |
| [AT067_g_engine_three_original_groups](attempts/AT067_g_engine_three_original_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT067_g_engine_three_original_groups/receipt.json) |
| [AT068_g_engine_held_final_three_groups](attempts/AT068_g_engine_held_final_three_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT068_g_engine_held_final_three_groups/receipt.json) |
| [AT069_g_engine_eight_group_cost_pilot](attempts/AT069_g_engine_eight_group_cost_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT069_g_engine_eight_group_cost_pilot/receipt.json) |
| [AT070_g_sparse_original_error_reference](attempts/AT070_g_sparse_original_error_reference) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT070_g_sparse_original_error_reference/receipt.json) |
| [AT071_g_exact_source_state_census](attempts/AT071_g_exact_source_state_census) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT071_g_exact_source_state_census/receipt.json) |
| [AT072_g_engine_full_original_335872](attempts/AT072_g_engine_full_original_335872) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT072_g_engine_full_original_335872/receipt.json) |
| [AT073_g_error_lifecycle_build](attempts/AT073_g_error_lifecycle_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT073_g_error_lifecycle_build/receipt.json) |
| [AT074_g_error_eight_group_same_v5_pilot](attempts/AT074_g_error_eight_group_same_v5_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT074_g_error_eight_group_same_v5_pilot/receipt.json) |
| [AT075_g_error_gate_then_late_input_full](attempts/AT075_g_error_gate_then_late_input_full) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT075_g_error_gate_then_late_input_full/receipt.json) |
| [AT076_g_error_gate_then_late_v_full](attempts/AT076_g_error_gate_then_late_v_full) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT076_g_error_gate_then_late_v_full/receipt.json) |
| [AT077_g_error_gate_then_late_z_full](attempts/AT077_g_error_gate_then_late_z_full) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT077_g_error_gate_then_late_z_full/receipt.json) |
| [AT078_g_error_inverse_row_full](attempts/AT078_g_error_inverse_row_full) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT078_g_error_inverse_row_full/receipt.json) |
| [AT079_g_peer_partial_lifecycle_build](attempts/AT079_g_peer_partial_lifecycle_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT079_g_peer_partial_lifecycle_build/receipt.json) |
| [AT080_g_peer_status_partial_discard_newgen](attempts/AT080_g_peer_status_partial_discard_newgen) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT080_g_peer_status_partial_discard_newgen/receipt.json) |
| [AT081_g_stage_release_evidence_audit](attempts/AT081_g_stage_release_evidence_audit) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT081_g_stage_release_evidence_audit/receipt.json) |
| [AT082_g_compact16_production_build](attempts/AT082_g_compact16_production_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT082_g_compact16_production_build/receipt.json) |
| [AT083_g_compact16_exact_state_census](attempts/AT083_g_compact16_exact_state_census) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT083_g_compact16_exact_state_census/receipt.json) |
| [AT084_g_compact16_three_original_groups](attempts/AT084_g_compact16_three_original_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT084_g_compact16_three_original_groups/receipt.json) |
| [AT085_g_compact16_held_final_three_groups](attempts/AT085_g_compact16_held_final_three_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT085_g_compact16_held_final_three_groups/receipt.json) |
| [AT086_g_compact16_eight_group_cost_pilot](attempts/AT086_g_compact16_eight_group_cost_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT086_g_compact16_eight_group_cost_pilot/receipt.json) |
| [AT087_g_compact16_numeric_lifecycle_build](attempts/AT087_g_compact16_numeric_lifecycle_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT087_g_compact16_numeric_lifecycle_build/receipt.json) |
| [AT088_g_compact16_peer_lifecycle_build](attempts/AT088_g_compact16_peer_lifecycle_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT088_g_compact16_peer_lifecycle_build/receipt.json) |
| [AT089_g_compact16_full_tag_counterexamples_build](attempts/AT089_g_compact16_full_tag_counterexamples_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT089_g_compact16_full_tag_counterexamples_build/receipt.json) |
| [AT090_g_compact16_pool_domain_build](attempts/AT090_g_compact16_pool_domain_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT090_g_compact16_pool_domain_build/receipt.json) |
| [AT091_g_compact16_math_domain_build](attempts/AT091_g_compact16_math_domain_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT091_g_compact16_math_domain_build/receipt.json) |
| [AT092_g_compact16_seq512_vs256_real_return](attempts/AT092_g_compact16_seq512_vs256_real_return) | SEMANTIC_STALL_STOP | 未登记 | [执行收据](attempts/AT092_g_compact16_seq512_vs256_real_return/receipt.json) |
| [AT093_g_compact16_numeric_eight_group_pilot](attempts/AT093_g_compact16_numeric_eight_group_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT093_g_compact16_numeric_eight_group_pilot/receipt.json) |
| [AT094_g_compact16_matching_status_recovery](attempts/AT094_g_compact16_matching_status_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT094_g_compact16_matching_status_recovery/receipt.json) |
| [AT095_g_compact16_pool_context_domains](attempts/AT095_g_compact16_pool_context_domains) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT095_g_compact16_pool_context_domains/receipt.json) |
| [AT096_g_compact16_math_context_domains](attempts/AT096_g_compact16_math_context_domains) | FAIL | 未登记 | [执行收据](attempts/AT096_g_compact16_math_context_domains/receipt.json) |
| [AT097_g_compact16_math_domain_diagnostic_build](attempts/AT097_g_compact16_math_domain_diagnostic_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT097_g_compact16_math_domain_diagnostic_build/receipt.json) |
| [AT098_g_compact16_registered_probe_build](attempts/AT098_g_compact16_registered_probe_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT098_g_compact16_registered_probe_build/receipt.json) |
| [AT099_g_compact16_registered_seq_alias_probe](attempts/AT099_g_compact16_registered_seq_alias_probe) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT099_g_compact16_registered_seq_alias_probe/receipt.json) |
| [AT100_g_compact16_math_domain_tag_diagnostic](attempts/AT100_g_compact16_math_domain_tag_diagnostic) | FAIL | 未登记 | [执行收据](attempts/AT100_g_compact16_math_domain_tag_diagnostic/receipt.json) |
| [AT101_g_compact16_explicit_context_math_build](attempts/AT101_g_compact16_explicit_context_math_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT101_g_compact16_explicit_context_math_build/receipt.json) |
| [AT102_g_compact16_explicit_context_production_build](attempts/AT102_g_compact16_explicit_context_production_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT102_g_compact16_explicit_context_production_build/receipt.json) |
| [AT103_g_compact16_explicit_context_tag_probe_build](attempts/AT103_g_compact16_explicit_context_tag_probe_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT103_g_compact16_explicit_context_tag_probe_build/receipt.json) |
| [AT104_g_compact16_explicit_context_numeric_build](attempts/AT104_g_compact16_explicit_context_numeric_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT104_g_compact16_explicit_context_numeric_build/receipt.json) |
| [AT105_g_compact16_explicit_context_peer_build](attempts/AT105_g_compact16_explicit_context_peer_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT105_g_compact16_explicit_context_peer_build/receipt.json) |
| [AT106_g_compact16_explicit_context_state_census](attempts/AT106_g_compact16_explicit_context_state_census) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT106_g_compact16_explicit_context_state_census/receipt.json) |
| [AT107_g_compact16_explicit_context_input_domains](attempts/AT107_g_compact16_explicit_context_input_domains) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT107_g_compact16_explicit_context_input_domains/receipt.json) |
| [AT108_g_compact16_explicit_context_seq_alias](attempts/AT108_g_compact16_explicit_context_seq_alias) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT108_g_compact16_explicit_context_seq_alias/receipt.json) |
| [AT109_g_compact16_explicit_context_three_groups](attempts/AT109_g_compact16_explicit_context_three_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT109_g_compact16_explicit_context_three_groups/receipt.json) |
| [AT110_g_compact16_explicit_context_held_three](attempts/AT110_g_compact16_explicit_context_held_three) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT110_g_compact16_explicit_context_held_three/receipt.json) |
| [AT111_g_compact16_old_generation_real_return](attempts/AT111_g_compact16_old_generation_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT111_g_compact16_old_generation_real_return/receipt.json) |
| [AT112_g_compact16_wrong_epoch_real_return](attempts/AT112_g_compact16_wrong_epoch_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT112_g_compact16_wrong_epoch_real_return/receipt.json) |
| [AT113_g_compact16_reserved_field_real_return](attempts/AT113_g_compact16_reserved_field_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT113_g_compact16_reserved_field_real_return/receipt.json) |
| [AT114_g_compact16_extra_FP_before_real_return](attempts/AT114_g_compact16_extra_FP_before_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT114_g_compact16_extra_FP_before_real_return/receipt.json) |
| [AT115_g_compact16_explicit_context_status_recovery](attempts/AT115_g_compact16_explicit_context_status_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT115_g_compact16_explicit_context_status_recovery/receipt.json) |
| [AT116_g_compact16_final_normal_cost_pilot](attempts/AT116_g_compact16_final_normal_cost_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT116_g_compact16_final_normal_cost_pilot/receipt.json) |
| [AT117_g_compact16_final_numeric_cost_pilot](attempts/AT117_g_compact16_final_numeric_cost_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT117_g_compact16_final_numeric_cost_pilot/receipt.json) |
| [AT118_g_compact16_complete_original_normal](attempts/AT118_g_compact16_complete_original_normal) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT118_g_compact16_complete_original_normal/receipt.json) |
| [AT119_g_compact16_complete_rank0_recovery](attempts/AT119_g_compact16_complete_rank0_recovery) | COST_GATE_STOP | 未登记 | [执行收据](attempts/AT119_g_compact16_complete_rank0_recovery/receipt.json) |
| [AT120_g_compact16_complete_rank0_recovery_exact_command](attempts/AT120_g_compact16_complete_rank0_recovery_exact_command) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT120_g_compact16_complete_rank0_recovery_exact_command/receipt.json) |
| [AT121_g_compact16_complete_rank2_recovery](attempts/AT121_g_compact16_complete_rank2_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT121_g_compact16_complete_rank2_recovery/receipt.json) |
| [AT122_g_compact16_complete_rank5_recovery](attempts/AT122_g_compact16_complete_rank5_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT122_g_compact16_complete_rank5_recovery/receipt.json) |
| [AT123_g_compact16_complete_inverse_row_recovery](attempts/AT123_g_compact16_complete_inverse_row_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT123_g_compact16_complete_inverse_row_recovery/receipt.json) |
| [AT124_g_compact16_final_release_audit](attempts/AT124_g_compact16_final_release_audit) | FAIL | 未登记 | [执行收据](attempts/AT124_g_compact16_final_release_audit/receipt.json) |
| [AT125_g_compact16_final_release_audit_project_cwd](attempts/AT125_g_compact16_final_release_audit_project_cwd) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT125_g_compact16_final_release_audit_project_cwd/receipt.json) |
| [AT126_g_ring15_full_ring_build](attempts/AT126_g_ring15_full_ring_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT126_g_ring15_full_ring_build/receipt.json) |
| [AT127_g_ring15_math_domain_build](attempts/AT127_g_ring15_math_domain_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT127_g_ring15_math_domain_build/receipt.json) |
| [AT128_g_ring15_production_build](attempts/AT128_g_ring15_production_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT128_g_ring15_production_build/receipt.json) |
| [AT129_g_ring15_tag_probe_build](attempts/AT129_g_ring15_tag_probe_build) | FAIL | 未登记 | [执行收据](attempts/AT129_g_ring15_tag_probe_build/receipt.json) |
| [AT130_g_ring15_tag_probe_build](attempts/AT130_g_ring15_tag_probe_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT130_g_ring15_tag_probe_build/receipt.json) |
| [AT131_g_ring15_numeric_build](attempts/AT131_g_ring15_numeric_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT131_g_ring15_numeric_build/receipt.json) |
| [AT132_g_ring15_peer_build](attempts/AT132_g_ring15_peer_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT132_g_ring15_peer_build/receipt.json) |
| [AT133_g_ring15_exact_state_census](attempts/AT133_g_ring15_exact_state_census) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT133_g_ring15_exact_state_census/receipt.json) |
| [AT134_g_ring15_full256_same_address](attempts/AT134_g_ring15_full256_same_address) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT134_g_ring15_full256_same_address/receipt.json) |
| [AT135_g_ring15_clear_same_seq0_domains](attempts/AT135_g_ring15_clear_same_seq0_domains) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT135_g_ring15_clear_same_seq0_domains/receipt.json) |
| [AT136_g_ring15_three_groups](attempts/AT136_g_ring15_three_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT136_g_ring15_three_groups/receipt.json) |
| [AT137_g_ring15_held_three_groups](attempts/AT137_g_ring15_held_three_groups) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT137_g_ring15_held_three_groups/receipt.json) |
| [AT138_g_ring15_seq512_vs256_real_return](attempts/AT138_g_ring15_seq512_vs256_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT138_g_ring15_seq512_vs256_real_return/receipt.json) |
| [AT139_g_ring15_old_generation_real_return](attempts/AT139_g_ring15_old_generation_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT139_g_ring15_old_generation_real_return/receipt.json) |
| [AT140_g_ring15_wrong_epoch_real_return](attempts/AT140_g_ring15_wrong_epoch_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT140_g_ring15_wrong_epoch_real_return/receipt.json) |
| [AT141_g_ring15_reserved_field_real_return](attempts/AT141_g_ring15_reserved_field_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT141_g_ring15_reserved_field_real_return/receipt.json) |
| [AT142_g_ring15_extra_FP_before_real_return](attempts/AT142_g_ring15_extra_FP_before_real_return) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT142_g_ring15_extra_FP_before_real_return/receipt.json) |
| [AT143_g_ring15_matching_status8_recovery](attempts/AT143_g_ring15_matching_status8_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT143_g_ring15_matching_status8_recovery/receipt.json) |
| [AT144_g_ring15_normal32768_cost_pilot](attempts/AT144_g_ring15_normal32768_cost_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT144_g_ring15_normal32768_cost_pilot/receipt.json) |
| [AT145_g_ring15_error32768_cost_pilot](attempts/AT145_g_ring15_error32768_cost_pilot) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT145_g_ring15_error32768_cost_pilot/receipt.json) |
| [AT146_g_ring15_complete_original_normal](attempts/AT146_g_ring15_complete_original_normal) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT146_g_ring15_complete_original_normal/receipt.json) |
| [AT147_g_ring15_complete_rank0_recovery](attempts/AT147_g_ring15_complete_rank0_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT147_g_ring15_complete_rank0_recovery/receipt.json) |
| [AT148_g_ring15_complete_inverse_row_recovery](attempts/AT148_g_ring15_complete_inverse_row_recovery) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT148_g_ring15_complete_inverse_row_recovery/receipt.json) |
| [AT149_g_ring15_final_release_audit](attempts/AT149_g_ring15_final_release_audit) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT149_g_ring15_final_release_audit/receipt.json) |

## 本批问题与交付文件

- [cost_scope_metadata_note.md](cost_scope_metadata_note.md)
- [g_compact14_handoff_20261022.md](g_compact14_handoff_20261022.md)
- [g_ring15_handoff_20261022.md](g_ring15_handoff_20261022.md)
- [g_stage_handoff_20261022.md](g_stage_handoff_20261022.md)
- [guard_identity_boundary.md](guard_identity_boundary.md)
- [tanh8_pause_handoff.md](tanh8_pause_handoff.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
