

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E009 / R002 运行结果

[负责人维护的本批运行记录](run.md)

# R002 — E009

Recorded: 2026-10-21T02:41:40.500894+00:00

Execution state: planned
Verdict: unassessed

- Exact command and working directory:
- Host, tool and platform versions:
- Code identity (commit/hash), external constraints and IP identity:
- Input/data identity and reproducibility inputs:
- Start/end times:
- Exit status and infrastructure errors:
- Independent oracle, expected values and acceptance criteria:
- Evidence paths and qualified scope:
- Observations and limitations:

A run record alone does not establish PASS or a method verdict.

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_native_session_build](AT001_native_session_build) | EXIT_ZERO | 未登记 | [执行收据](AT001_native_session_build/receipt.json) |
| [AT002_native_session_clean_build](AT002_native_session_clean_build) | EXIT_ZERO | 未登记 | [执行收据](AT002_native_session_clean_build/receipt.json) |
| [AT003_native_session_frozen_and_errors](AT003_native_session_frozen_and_errors) | FAIL | 未登记 | [执行收据](AT003_native_session_frozen_and_errors/receipt.json) |
| [AT004_native_session_visibility_build](AT004_native_session_visibility_build) | EXIT_ZERO | 未登记 | [执行收据](AT004_native_session_visibility_build/receipt.json) |
| [AT005_native_session_frozen_and_errors](AT005_native_session_frozen_and_errors) | FAIL | 未登记 | [执行收据](AT005_native_session_frozen_and_errors/receipt.json) |
| [AT006_native_session_export_build](AT006_native_session_export_build) | EXIT_ZERO | 未登记 | [执行收据](AT006_native_session_export_build/receipt.json) |
| [AT007_native_session_frozen_and_errors](AT007_native_session_frozen_and_errors) | FAIL | 未登记 | [执行收据](AT007_native_session_frozen_and_errors/receipt.json) |
| [AT008_native_session_order_build](AT008_native_session_order_build) | EXIT_ZERO | 未登记 | [执行收据](AT008_native_session_order_build/receipt.json) |
| [AT009_native_session_functional](AT009_native_session_functional) | EXIT_ZERO | 未登记 | [执行收据](AT009_native_session_functional/receipt.json) |
| [AT010_native_session_profile_pilot](AT010_native_session_profile_pilot) | FAIL | 未登记 | [执行收据](AT010_native_session_profile_pilot/receipt.json) |
| [AT011_native_session_profile_pilot](AT011_native_session_profile_pilot) | EXIT_ZERO | 未登记 | [执行收据](AT011_native_session_profile_pilot/receipt.json) |
| [AT012_native_session_vnni_build](AT012_native_session_vnni_build) | EXIT_ZERO | 未登记 | [执行收据](AT012_native_session_vnni_build/receipt.json) |
| [AT013_native_session_vnni_functional](AT013_native_session_vnni_functional) | EXIT_ZERO | 未登记 | [执行收据](AT013_native_session_vnni_functional/receipt.json) |
| [AT014_native_session_vnni_profile32](AT014_native_session_vnni_profile32) | EXIT_ZERO | 未登记 | [执行收据](AT014_native_session_vnni_profile32/receipt.json) |
| [AT015_native_session_vnni_profile200](AT015_native_session_vnni_profile200) | EXIT_ZERO | 未登记 | [执行收据](AT015_native_session_vnni_profile200/receipt.json) |
| [AT016_native_session_ln_act_simd_build](AT016_native_session_ln_act_simd_build) | EXIT_ZERO | 未登记 | [执行收据](AT016_native_session_ln_act_simd_build/receipt.json) |
| [AT017_native_session_ln_act_functional](AT017_native_session_ln_act_functional) | EXIT_ZERO | 未登记 | [执行收据](AT017_native_session_ln_act_functional/receipt.json) |
| [AT018_native_session_ln_act_profile200](AT018_native_session_ln_act_profile200) | EXIT_ZERO | 未登记 | [执行收据](AT018_native_session_ln_act_profile200/receipt.json) |
| [AT019_native_session_prefill_affinity_build](AT019_native_session_prefill_affinity_build) | EXIT_ZERO | 未登记 | [执行收据](AT019_native_session_prefill_affinity_build/receipt.json) |
| [AT020_native_session_prefill_functional](AT020_native_session_prefill_functional) | EXIT_ZERO | 未登记 | [执行收据](AT020_native_session_prefill_functional/receipt.json) |
| [AT021_native_session_prefill_pilot](AT021_native_session_prefill_pilot) | EXIT_ZERO | 未登记 | [执行收据](AT021_native_session_prefill_pilot/receipt.json) |
| [AT022_native_session_regex_init_build](AT022_native_session_regex_init_build) | EXIT_ZERO | 未登记 | [执行收据](AT022_native_session_regex_init_build/receipt.json) |
| [AT023_native_session_final_functional](AT023_native_session_final_functional) | EXIT_ZERO | 未登记 | [执行收据](AT023_native_session_final_functional/receipt.json) |
| [AT024_native_session_final_pilot](AT024_native_session_final_pilot) | EXIT_ZERO | 未登记 | [执行收据](AT024_native_session_final_pilot/receipt.json) |
| [AT025_native_session_final_profile200](AT025_native_session_final_profile200) | EXIT_ZERO | 未登记 | [执行收据](AT025_native_session_final_profile200/receipt.json) |
| [AT026_native_session_final_lazy32](AT026_native_session_final_lazy32) | EXIT_ZERO | 未登记 | [执行收据](AT026_native_session_final_lazy32/receipt.json) |
| [AT027_native_cpu03_final_audit](AT027_native_cpu03_final_audit) | EXIT_ZERO | 未登记 | [执行收据](AT027_native_cpu03_final_audit/receipt.json) |

## 本批问题与交付文件

- [native_cpu03_handoff.md](native_cpu03_handoff.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
