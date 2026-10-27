

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E017 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001 — E017 SFU最小测量

Execution state: completed
Verdict: inconclusive

实际范围：原32×32→50/64 helper独立RTL及完整IO OOC；原F64mul六文件finite-native RTL；底向上AT011/分阶段parent-only AT012成本出口。当前无EDA/排锁任务，AT013未创建。

复现入口：E002/experiment/vivado/module_design/attention_and_fp_engine/tb/m007_sfu_measure_run.py与m007_sfu_f64_run.py。每实际AT有frozen/source_manifest/command/guard/receipt。AT007单独prelaunch_failure，无伪造guard。

平台：Vivado2025.2，xcu55c-fsvh2892-2L-e，完整IO nominal300MHz/实际300.030MHz，OOC synth+opt，无P&R。独立整数Python与原AT005同域native binary64 RNE；拒绝FTZ/DAZ。

起止与完整命令/退出见每AT guard与command，资源费用见budget_ledger.json。结论/版本边界/未验证范围见final_delivery.md/.json；终态检查见final_evidence_audit.json。无生产修改。

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_exact_integer_reference](attempts/AT001_exact_integer_reference) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT001_exact_integer_reference/receipt.json) |
| [AT002_integer_helpers_build](attempts/AT002_integer_helpers_build) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT002_integer_helpers_build/receipt.json) · [input_manifest.json](attempts/AT002_integer_helpers_build/input_manifest.json) |
| [AT003_integer_helpers_rtl](attempts/AT003_integer_helpers_rtl) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT003_integer_helpers_rtl/receipt.json) · [input_manifest.json](attempts/AT003_integer_helpers_rtl/input_manifest.json) |
| [AT004_mul50_complete_io_ooc](attempts/AT004_mul50_complete_io_ooc) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT004_mul50_complete_io_ooc/receipt.json) |
| [AT005_mul64_complete_io_ooc](attempts/AT005_mul64_complete_io_ooc) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT005_mul64_complete_io_ooc/receipt.json) |
| [AT006_f64_native_reference_build](attempts/AT006_f64_native_reference_build) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT006_f64_native_reference_build/receipt.json) |
| [AT007_f64_native_reference](attempts/AT007_f64_native_reference) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT007_f64_native_reference/input_manifest.json) |
| [AT008_f64_native_reference](attempts/AT008_f64_native_reference) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT008_f64_native_reference/receipt.json) · [input_manifest.json](attempts/AT008_f64_native_reference/input_manifest.json) |
| [AT009_f64_original_build](attempts/AT009_f64_original_build) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT009_f64_original_build/receipt.json) · [input_manifest.json](attempts/AT009_f64_original_build/input_manifest.json) |
| [AT010_f64_original_rtl](attempts/AT010_f64_original_rtl) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT010_f64_original_rtl/receipt.json) · [input_manifest.json](attempts/AT010_f64_original_rtl/input_manifest.json) |
| [AT011_f64_bottomup_120s](attempts/AT011_f64_bottomup_120s) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT011_f64_bottomup_120s/receipt.json) |
| [AT012_f64_parent_stub_120s](attempts/AT012_f64_parent_stub_120s) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT012_f64_parent_stub_120s/receipt.json) |

## 本批问题与交付文件

- [final_delivery.md](final_delivery.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
