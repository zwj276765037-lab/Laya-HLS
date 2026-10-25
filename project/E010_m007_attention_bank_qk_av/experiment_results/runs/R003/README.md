

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E010 / R003 运行结果

[负责人维护的本批运行记录](run.md)

# E010 R003 actual state

Execution state: running
Verdict: scoped partial PASS; full16 cost stop before launch

AT021 current same-build Encoder0 two-head actual run completed with263.639841915s under264s cap. Each head11038cycles and all scoped expectations passed. Full16 was not launched because the strict measured1.2*(prep+16*max head) gate exceeds1800s. See full16_cost_gate_current.json. Further interface/fault preparation and a falsifiable runtime-cost improvement remain authorized within the same R003 budget; no timeout extension or full16 PASS is implied.

2026-10-21 CE continuation: AT022 finite reverse-QK independent reference PASS; actual layer fault RTL NOT_RUN. AT023 authorized sharedDIV8 idle-only CE actual wrapper PASS, numerical leaf/public signature unchanged and previous identities frozen. AT024 production static PASS30.640597467s; AT025 same-build Encoder prep is running. CE runtime benefit remains unmeasured; no cap or budget changed. See div8_idle_ce_change.json.

Current continuation: AT024-027 new DIV8-CE same-build static/prep/one-two-head PASS. Actual Encoder two-head203.754162015s and conservative head83.730233994s give strict full16 estimate1650.883306442

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_original_b1_three_layer_local_reference](attempts/AT001_original_b1_three_layer_local_reference) | 未登记；查看原记录 | 未登记 |  |
| [AT002_atomic_qkv_bank](attempts/AT002_atomic_qkv_bank) | 未登记；查看原记录 | 未登记 |  |
| [AT003_original_rope_coefficient_cache](attempts/AT003_original_rope_coefficient_cache) | 未登记；查看原记录 | 未登记 |  |
| [AT004_native_rope_full](attempts/AT004_native_rope_full) | 未登记；查看原记录 | 未登记 |  |
| [AT005_legacy_qkv_thin_shell](attempts/AT005_legacy_qkv_thin_shell) | 未登记；查看原记录 | 未登记 |  |
| [AT006_native_rope_sliding_artifacts](attempts/AT006_native_rope_sliding_artifacts) | 未登记；查看原记录 | 未登记 |  |
| [AT007_native_rope_finite_stalls](attempts/AT007_native_rope_finite_stalls) | 未登记；查看原记录 | 未登记 |  |
| [AT008_original_check_order_peer](attempts/AT008_original_check_order_peer) | 未登记；查看原记录 | 未登记 |  |
| [AT009_one_resource_layer_build](attempts/AT009_one_resource_layer_build) | 未登记；查看原记录 | 未登记 |  |
| [AT010_layer_declaration_fix](attempts/AT010_layer_declaration_fix) | 未登记；查看原记录 | 未登记 |  |
| [AT011_layer_same_build_one_head_pilot](attempts/AT011_layer_same_build_one_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT012_descriptor_context_binary_load](attempts/AT012_descriptor_context_binary_load) | 未登记；查看原记录 | 未登记 |  |
| [AT013_native_rope_abort_recovery](attempts/AT013_native_rope_abort_recovery) | 未登记；查看原记录 | 未登记 |  |
| [AT014_layer_binary_one_head_pilot](attempts/AT014_layer_binary_one_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT015_decision_one_head_cost_pilot](attempts/AT015_decision_one_head_cost_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT016_native_rope_common_reset](attempts/AT016_native_rope_common_reset) | 未登记；查看原记录 | 未登记 |  |
| [AT017_original_identity_stream_output](attempts/AT017_original_identity_stream_output) | 未登记；查看原记录 | 未登记 |  |
| [AT018_full_original_tag_coefficient_cache](attempts/AT018_full_original_tag_coefficient_cache) | 未登记；查看原记录 | 未登记 |  |
| [AT019_original_tag_encoder_preparation_pilot](attempts/AT019_original_tag_encoder_preparation_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT020_original_tag_decision_one_head_pilot](attempts/AT020_original_tag_decision_one_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT021_original_encoder_two_head_pilot](attempts/AT021_original_encoder_two_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT022_actual_reverse_QK_fault_reference](attempts/AT022_actual_reverse_QK_fault_reference) | 未登记；查看原记录 | 未登记 |  |
| [AT023_shared_DIV8_idle_CE_wrapper](attempts/AT023_shared_DIV8_idle_CE_wrapper) | 未登记；查看原记录 | 未登记 |  |
| [AT024_DIV8_idle_CE_production_layer_build](attempts/AT024_DIV8_idle_CE_production_layer_build) | 未登记；查看原记录 | 未登记 |  |
| [AT025_DIV8_CE_encoder_preparation_pilot](attempts/AT025_DIV8_CE_encoder_preparation_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT026_DIV8_CE_decision_one_head_pilot](attempts/AT026_DIV8_CE_decision_one_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT027_DIV8_CE_encoder_two_head_pilot](attempts/AT027_DIV8_CE_encoder_two_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT028_actual_reverse_QK_fault_layer_build](attempts/AT028_actual_reverse_QK_fault_layer_build) | 未登记；查看原记录 | 未登记 |  |
| [AT029_DIV8_CE_encoder0_complete16](attempts/AT029_DIV8_CE_encoder0_complete16) | 未登记；查看原记录 | 未登记 |  |
| [AT030_actual_reverse_QK_one_head_pilot](attempts/AT030_actual_reverse_QK_one_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT031_FP_channel_CE_strict4](attempts/AT031_FP_channel_CE_strict4) | 未登记；查看原记录 | 未登记 |  |
| [AT032_FP_channel_CE_strict256](attempts/AT032_FP_channel_CE_strict256) | 未登记；查看原记录 | 未登记 |  |
| [AT033_FP_CE_phase1_3_6_dependency](attempts/AT033_FP_CE_phase1_3_6_dependency) | 未登记；查看原记录 | 未登记 |  |
| [AT034_FP_CE_full256_credit_reset](attempts/AT034_FP_CE_full256_credit_reset) | 未登记；查看原记录 | 未登记 |  |
| [AT035_FP_channel_CE_real_progress_layer_build](attempts/AT035_FP_channel_CE_real_progress_layer_build) | 未登记；查看原记录 | 未登记 |  |
| [AT036_FP_CE_encoder_one_head_pilot](attempts/AT036_FP_CE_encoder_one_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT037_FP_CE_decision_one_head_pilot](attempts/AT037_FP_CE_decision_one_head_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT038_FP_CE_encoder_preparation_pilot](attempts/AT038_FP_CE_encoder_preparation_pilot) | 未登记；查看原记录 | 未登记 |  |

## 本批问题与交付文件

- [final_delivery.md](final_delivery.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
