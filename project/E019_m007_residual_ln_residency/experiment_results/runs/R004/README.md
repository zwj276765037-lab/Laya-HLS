

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E019 / R004 运行结果

[负责人维护的本批运行记录](run.md)

# E019 R004 TYPE-RESIDENT-29 final delivery

Execution completed, scoped functional verdict supported. The actual default is475-port `laya_m007_resident_joint_v3`, body `0f4318fc16afa6173bd28023eb5feba95c7d4aecc77bd31545d19865e5554f69`, header `9e835f48836920aede1b5b6acb6acdd546ddee8f05d4f809ce656e5cd8dcd625`, with accepted TANH8v2/FORCE_CORE_CE0. All65 old v2/dependency source hashes and all six R003 receipt hashes remain unchanged. D31 is not selected. Actual current bundle: [production_bundle_checkpoint_v1.json](production_bundle_checkpoint_v1.json).

One96x32F32 type RAM adds12288B, one1024bit response holding adds128B, and only valid1/full-address12 adds13 control bits. VECTOR keeps external48 bits and uses states5/6/7, without an op shadow. Wrapper adds0FF and reuses the one existing source witness. Declared control projection before independently owned parent is32491+13=32504 bits; this is not final physical fit.

Six unit RTL cases pass. Original qtype2 uses original47 final_norm as public input, E020 type setup and original type_add as checker:4096 actual shared-FP ADD/H commits,131072 final H rescan bit comparisons and3104 type route comparisons per successful final run,4

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_type_VECTOR_v3_unit_build](attempts/AT001_type_VECTOR_v3_unit_build) | FAIL | 未登记 | [执行收据](attempts/AT001_type_VECTOR_v3_unit_build/receipt.json) |
| [AT002_declared_type_VECTOR_unit_build](attempts/AT002_declared_type_VECTOR_unit_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT002_declared_type_VECTOR_unit_build/receipt.json) |
| [AT003_original_qtype2_full128_unit](attempts/AT003_original_qtype2_full128_unit) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT003_original_qtype2_full128_unit/receipt.json) |
| [AT004_Q_type_finalH_held17_unit](attempts/AT004_Q_type_finalH_held17_unit) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT004_Q_type_finalH_held17_unit/receipt.json) |
| [AT005_type_full_address_fault_recovery_unit](attempts/AT005_type_full_address_fault_recovery_unit) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT005_type_full_address_fault_recovery_unit/receipt.json) |
| [AT006_FP_epoch_fault_recovery_unit](attempts/AT006_FP_epoch_fault_recovery_unit) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT006_FP_epoch_fault_recovery_unit/receipt.json) |
| [AT007_NaN_full_recovery_unit](attempts/AT007_NaN_full_recovery_unit) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT007_NaN_full_recovery_unit/receipt.json) |
| [AT008_original_op0_v2_cycle_regression](attempts/AT008_original_op0_v2_cycle_regression) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT008_original_op0_v2_cycle_regression/receipt.json) |
| [AT009_TANHv2_production_joint_v3_build](attempts/AT009_TANHv2_production_joint_v3_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT009_TANHv2_production_joint_v3_build/receipt.json) |
| [AT010_TANHv2_production_joint_type_full128](attempts/AT010_TANHv2_production_joint_type_full128) | FAIL | 未登记 | [执行收据](attempts/AT010_TANHv2_production_joint_type_full128/receipt.json) |
| [AT011_settled_LN_admission_TANHv2_joint_build](attempts/AT011_settled_LN_admission_TANHv2_joint_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT011_settled_LN_admission_TANHv2_joint_build/receipt.json) |
| [AT012_TANHv2_joint_type_full128_settled_admission](attempts/AT012_TANHv2_joint_type_full128_settled_admission) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT012_TANHv2_joint_type_full128_settled_admission/receipt.json) |
| [AT013_actual_joint_source_hierarchy_release_audit](attempts/AT013_actual_joint_source_hierarchy_release_audit) | INFRASTRUCTURE_FAILURE | 未登记 | [执行收据](attempts/AT013_actual_joint_source_hierarchy_release_audit/receipt.json) |
| [AT014_release_audit_same_policy_retry](attempts/AT014_release_audit_same_policy_retry) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT014_release_audit_same_policy_retry/receipt.json) |

## 本批问题与交付文件

- [final_delivery.md](final_delivery.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
