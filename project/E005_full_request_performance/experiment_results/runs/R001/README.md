

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E005 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001：SM005首轮有限算术测量

Execution state: completed（本轮KB0/KB1及P0/P3有界交付）
Verdict: supported（局部normal冷样本）

D-M004-MEASUREMENT-FIRST-01。AT001/AT002各static→pilot→full真实完成，重工具串行，无在跑owned工具。执行命令、真实起止及exit0分别在AT001_completed_20261013.json与AT002_completed_20261013.json；工作目录为唯一E002/experiment。Vivado/xsim2025.2，项目part xcu55c-fsvh2892-2L-e；行为仿真并非实现时序或板端频率。

四distinct预量化A、K2624/N1024、bias0/冷reset。26冻结source/脚本、12独立fixture、3native IP按各input_manifest记录，A/B唯一DUT差异为writer rowpack。原全部335872 PS lane-group及4096最终F32逐位通过，真实A/W读取、输出地址去重、实际末B、局部publication及一次done消费通过。响应策略按物理beat的17+(beat%3) B延迟、AW/W周期门及7cycle完成反压保持。

| 同边界cycles | KB0 | KB1 |
| --- | ---: | ---: |
| cfg→first done | 21100 | 16183 |
| cfg→实际consume | 21107 | 16190 |
| 全冷TB | 48864 | 43947 |
| cfg前A/W加载 | 666 / 27064 | 666 / 27064 |

KB1实际AW/W/B512→256，物理字节32768→16384、有效16384不变。命令与全冷周期分别减少23.30%与10.06%，保留候选。本轮仅一个改进DUT，不追加KB2。

[完整比较与适用边界](reports/KB0_KB1_Down_comparison_20261013.md)、[数据JSON](reports/KB0_KB1_Down_comparison_20261013.json)、[原始证据核查](reports/KB0_KB1_Down_verification_20261013.json)。互斥状态和等于各自cfg→done区间，重叠接口stall另列；工具墙钟不当硬件性能。

P0盘点已收束。P3薄HLS固定RAM/有限步骤优先、同schema RTL备选；下一目标必须涵盖原容量关键表的全键校验/候选/提交，具体schema与生成目标未冻结。FullRuntime/冷INIT和生

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_KB0_resident_Down_measurement](attempts/AT001_KB0_resident_Down_measurement) | completed | KB0 resident Down four real prequantized rows K2624/N1024;no production full request | [执行收据](attempts/AT001_KB0_resident_Down_measurement/run.json) · [report.md](attempts/AT001_KB0_resident_Down_measurement/report.md) |
| [AT002_KB1_Down_rowpack](attempts/AT002_KB1_Down_rowpack) | completed | KB1 normal four-row Down rowpack compare;no full LINEAR/request or error-recovery claim | [执行收据](attempts/AT002_KB1_Down_rowpack/run.json) · [report.md](attempts/AT002_KB1_Down_rowpack/report.md) |
| [AT003_KB2_Down_two64](attempts/AT003_KB2_Down_two64) | completed | Two 64-tile resident Down blocks, KB1 rowpack and unchanged four-row normal fixture/profile | [执行收据](attempts/AT003_KB2_Down_two64/run.json) |
| [AT004_CT0_owner_table_hls_01](attempts/AT004_CT0_owner_table_hls_01) | completed | 32-entry CT0 host reference and first HLS launch | [执行收据](attempts/AT004_CT0_owner_table_hls_01/run.json) · [input_manifest.json](attempts/AT004_CT0_owner_table_hls_01/input_manifest.json) |
| [AT005_CT0_owner_table_hls_02](attempts/AT005_CT0_owner_table_hls_02) | completed | First complete thin HLS compile after host reference pass | [执行收据](attempts/AT005_CT0_owner_table_hls_02/run.json) · [input_manifest.json](attempts/AT005_CT0_owner_table_hls_02/input_manifest.json) |
| [AT006_CT0_owner_table_hls_03](attempts/AT006_CT0_owner_table_hls_03) | completed | Diagnostic-only 32-entry FullOwnerRecord REQUIRE/ACQUIRE/RELEASE_READ | [执行收据](attempts/AT006_CT0_owner_table_hls_03/run.json) · [input_manifest.json](attempts/AT006_CT0_owner_table_hls_03/input_manifest.json) |
| [AT007_CT0_owner_table_rtl_01](attempts/AT007_CT0_owner_table_rtl_01) | completed | Generated RTL fixture closure check before tool launch | [执行收据](attempts/AT007_CT0_owner_table_rtl_01/run.json) |
| [AT008_CT0_owner_table_rtl_02](attempts/AT008_CT0_owner_table_rtl_02) | completed | Diagnostic-only 32-entry FullOwnerRecord REQUIRE/ACQUIRE/RELEASE_READ | [执行收据](attempts/AT008_CT0_owner_table_rtl_02/run.json) · [input_manifest.json](attempts/AT008_CT0_owner_table_rtl_02/input_manifest.json) |
| [AT009_CT0_owner_table_rtl_03](attempts/AT009_CT0_owner_table_rtl_03) | completed | Diagnostic-only 32-entry FullOwnerRecord REQUIRE/ACQUIRE/RELEASE_READ | [执行收据](attempts/AT009_CT0_owner_table_rtl_03/run.json) · [input_manifest.json](attempts/AT009_CT0_owner_table_rtl_03/input_manifest.json) |
| [AT010_CT0_owner_table_rtl_04](attempts/AT010_CT0_owner_table_rtl_04) | completed | Additional inactive-context tests, preflight stopped after host trace because check count changed from 782 to 783 | [执行收据](attempts/AT010_CT0_owner_table_rtl_04/run.json) |
| [AT011_CT0_owner_table_rtl_05](attempts/AT011_CT0_owner_table_rtl_05) | completed | Generated 32-entry owner table, normal 131 transactions plus independent request-off and model-off nine-transaction cold cases | [执行收据](attempts/AT011_CT0_owner_table_rtl_05/run.json) · [input_manifest.json](attempts/AT011_CT0_owner_table_rtl_05/input_manifest.json) |
| [AT012_CT0_owner_table_rtl_06](attempts/AT012_CT0_owner_table_rtl_06) | completed | Generated 32-entry owner table, 131-transaction normal trace plus request-off/model-off with stale record identity and old-reader release | [执行收据](attempts/AT012_CT0_owner_table_rtl_06/run.json) · [input_manifest.json](attempts/AT012_CT0_owner_table_rtl_06/input_manifest.json) |
| [AT013_LQ0_measurement_01](attempts/AT013_LQ0_measurement_01) | static=PASS; pilot=PASS; full=PASS | original frozen layernorm_quant_source_03 normal rows16 path; only TB observer changes; no F9 rerun | [执行收据](attempts/AT013_LQ0_measurement_01/receipt.json) · [input_manifest.json](attempts/AT013_LQ0_measurement_01/input_manifest.json) |
| [AT014_LQ0_measurement_02](attempts/AT014_LQ0_measurement_02) | static=PASS; pilot=PASS; full=PASS | original frozen layernorm_quant_source_03 normal rows16 path; only TB observer changes; no F9 rerun | [执行收据](attempts/AT014_LQ0_measurement_02/receipt.json) · [input_manifest.json](attempts/AT014_LQ0_measurement_02/input_manifest.json) |
| [AT015_LQ1_LN_hls_01](attempts/AT015_LQ1_LN_hls_01) | PASS_SCOPED_GENERATION | 未登记 | [执行收据](attempts/AT015_LQ1_LN_hls_01/receipt.json) · [input_manifest.json](attempts/AT015_LQ1_LN_hls_01/input_manifest.json) |
| [AT016_LQ1_RTL_01](attempts/AT016_LQ1_RTL_01) | static=PASS; pilot=PASS; full=PASS | original frozen layernorm_quant_source_03 normal rows16 path with only LQ1 LN-generated engine and TB observer; no F9 rerun | [执行收据](attempts/AT016_LQ1_RTL_01/receipt.json) · [input_manifest.json](attempts/AT016_LQ1_RTL_01/input_manifest.json) |
| [AT017_LQ1R_LN_hls_01](attempts/AT017_LQ1R_LN_hls_01) | PASS_SCOPED_GENERATION | 未登记 | [执行收据](attempts/AT017_LQ1R_LN_hls_01/receipt.json) · [input_manifest.json](attempts/AT017_LQ1R_LN_hls_01/input_manifest.json) |
| [AT018_LQ1R_LN_hls_02](attempts/AT018_LQ1R_LN_hls_02) | PASS_SCOPED_GENERATION | 未登记 | [执行收据](attempts/AT018_LQ1R_LN_hls_02/receipt.json) · [input_manifest.json](attempts/AT018_LQ1R_LN_hls_02/input_manifest.json) |
| [AT019_ATN0_attention_measurement_01](attempts/AT019_ATN0_attention_measurement_01) | FAIL_OBSERVER_ASSERT | Original Attention v10 enc0/head0 B1/S128 finite normal sample; no AXI master or complete request | [执行收据](attempts/AT019_ATN0_attention_measurement_01/receipt.json) |
| [AT020_ATN0_attention_measurement_02](attempts/AT020_ATN0_attention_measurement_02) | PASS_SCOPED_ATN0 | Original Attention v10 enc0/head0 B1/S128 finite normal sample; no AXI master or complete request | [执行收据](attempts/AT020_ATN0_attention_measurement_02/receipt.json) |
| [AT021_ATN1_attention_prefetch_01](attempts/AT021_ATN1_attention_prefetch_01) | PASS_SCOPED | normal_128 | [执行收据](attempts/AT021_ATN1_attention_prefetch_01/receipt.json) |
| [AT022_ATN1_prefetch_protocol_01](attempts/AT022_ATN1_prefetch_protocol_01) | PASS_SCOPED | protocol_16 | [执行收据](attempts/AT022_ATN1_prefetch_protocol_01/receipt.json) |
| [AT023_GQD0_chain_01](attempts/AT023_GQD0_chain_01) | COST_STOP | 未登记 | [执行收据](attempts/AT023_GQD0_chain_01/receipt.json) · [input_manifest.json](attempts/AT023_GQD0_chain_01/input_manifest.json) |
| [AT024_GQD0_chain_02](attempts/AT024_GQD0_chain_02) | COST_STOP | 未登记 | [执行收据](attempts/AT024_GQD0_chain_02/receipt.json) · [input_manifest.json](attempts/AT024_GQD0_chain_02/input_manifest.json) |
| [AT025_GQD0_chain_03](attempts/AT025_GQD0_chain_03) | PASS_SCOPED_GQD0 | 未登记 | [执行收据](attempts/AT025_GQD0_chain_03/receipt.json) · [input_manifest.json](attempts/AT025_GQD0_chain_03/input_manifest.json) |
| [AT026_WI0_resident_01](attempts/AT026_WI0_resident_01) | FAIL | WI0 four distinct prequantized LN_FFN A rows to true strict W/cache/resident/KB1 writer output | [执行收据](attempts/AT026_WI0_resident_01/receipt.json) · [input_manifest.json](attempts/AT026_WI0_resident_01/input_manifest.json) |
| [AT027_WI0_resident_02](attempts/AT027_WI0_resident_02) | COST_STOP | WI0 four distinct prequantized LN_FFN A rows to true strict W/cache/resident/KB1 writer output | [执行收据](attempts/AT027_WI0_resident_02/receipt.json) · [input_manifest.json](attempts/AT027_WI0_resident_02/input_manifest.json) |
| [AT028_WI0_resident_03](attempts/AT028_WI0_resident_03) | PASS | WI0 four distinct prequantized LN_FFN A rows to true strict W/cache/resident/KB1 writer output | [执行收据](attempts/AT028_WI0_resident_03/receipt.json) · [input_manifest.json](attempts/AT028_WI0_resident_03/input_manifest.json) |
| [AT029_WIGQD0_chain_01](attempts/AT029_WIGQD0_chain_01) | FAIL | 未登记 | [执行收据](attempts/AT029_WIGQD0_chain_01/receipt.json) · [input_manifest.json](attempts/AT029_WIGQD0_chain_01/input_manifest.json) |
| [AT030_WIGQD0_chain_02](attempts/AT030_WIGQD0_chain_02) | COST_STOP | 未登记 | [执行收据](attempts/AT030_WIGQD0_chain_02/receipt.json) · [input_manifest.json](attempts/AT030_WIGQD0_chain_02/input_manifest.json) |
| [AT031_WIGQD0_chain_03](attempts/AT031_WIGQD0_chain_03) | COST_STOP | 未登记 | [执行收据](attempts/AT031_WIGQD0_chain_03/receipt.json) · [input_manifest.json](attempts/AT031_WIGQD0_chain_03/input_manifest.json) |
| [AT032_WIGQD1_observation_01](attempts/AT032_WIGQD1_observation_01) | PASS_SCOPED_WIGQD1 | 未登记 | [执行收据](attempts/AT032_WIGQD1_observation_01/receipt.json) · [input_manifest.json](attempts/AT032_WIGQD1_observation_01/input_manifest.json) |
| [AT033_QWIGQD0_chain_01](attempts/AT033_QWIGQD0_chain_01) | FAIL | 未登记 | [执行收据](attempts/AT033_QWIGQD0_chain_01/receipt.json) · [input_manifest.json](attempts/AT033_QWIGQD0_chain_01/input_manifest.json) |
| [AT034_QWIGQD0_chain_02](attempts/AT034_QWIGQD0_chain_02) | PASS_SCOPED_QWIGQD0 | 未登记 | [执行收据](attempts/AT034_QWIGQD0_chain_02/receipt.json) · [input_manifest.json](attempts/AT034_QWIGQD0_chain_02/input_manifest.json) |
| [AT035_QAR0_shared_admission_01](attempts/AT035_QAR0_shared_admission_01) | PASS_SCOPED_QAR0 | 未登记 | [执行收据](attempts/AT035_QAR0_shared_admission_01/receipt.json) · [input_manifest.json](attempts/AT035_QAR0_shared_admission_01/input_manifest.json) |
| [AT036_QAR0_default_static_01](attempts/AT036_QAR0_default_static_01) | PASS_SCOPED_DEFAULT_STATIC | 未登记 | [执行收据](attempts/AT036_QAR0_default_static_01/receipt.json) · [input_manifest.json](attempts/AT036_QAR0_default_static_01/input_manifest.json) |
| [AT037_LNREF0_reference_prefix_01](attempts/AT037_LNREF0_reference_prefix_01) | FAIL_WRAPPER | LNREF0 prefix not computed | [执行收据](attempts/AT037_LNREF0_reference_prefix_01/receipt.json) · [input_manifest.json](attempts/AT037_LNREF0_reference_prefix_01/input_manifest.json) |
| [AT038_LNREF0_reference_prefix_02](attempts/AT038_LNREF0_reference_prefix_02) | PASS_SCOPED_LNREF0 | request3/generation1 B1/S128 enc0 independent reference through LN_FFN only | [执行收据](attempts/AT038_LNREF0_reference_prefix_02/receipt.json) · [input_manifest.json](attempts/AT038_LNREF0_reference_prefix_02/input_manifest.json) |
| [AT039_LNF0_ffn4_01](attempts/AT039_LNF0_ffn4_01) | static=PASS; pilot=FAIL | one generated baseline gamma0/D1024 LN_FFN task for enc0 B1/S128 request3/generation1 rows4; independent residual source, actual AXI LN store and last B, provenance END/publish and source lease, same stored bytes read by real QUA… | [执行收据](attempts/AT039_LNF0_ffn4_01/receipt.json) · [input_manifest.json](attempts/AT039_LNF0_ffn4_01/input_manifest.json) |
| [AT040_LNF0_ffn4_02](attempts/AT040_LNF0_ffn4_02) | static=PASS; pilot=PASS; full=PASS | one generated baseline gamma0/D1024 LN_FFN task for enc0 B1/S128 request3/generation1 rows4; independent residual source, actual AXI LN store and last B, provenance END/publish and source lease, same stored bytes read by real QUA… | [执行收据](attempts/AT040_LNF0_ffn4_02/receipt.json) · [input_manifest.json](attempts/AT040_LNF0_ffn4_02/input_manifest.json) |
| [AT041_LNQI0_identity_preflight_01](attempts/AT041_LNQI0_identity_preflight_01) | 未登记；查看原记录 | L13M canonical package versus frozen AT035 Q8S2 Wi/Down data, bounded host preflight only | [执行收据](attempts/AT041_LNQI0_identity_preflight_01/receipt.json) · [input_manifest.json](attempts/AT041_LNQI0_identity_preflight_01/input_manifest.json) |
| [AT042_LNQ0_chain_01](attempts/AT042_LNQ0_chain_01) | 未登记；查看原记录 | 未登记 |  |
| [AT043_LNQ0_chain_02](attempts/AT043_LNQ0_chain_02) | 未登记；查看原记录 | 未登记 |  |
| [AT044_LNQ0_chain_03](attempts/AT044_LNQ0_chain_03) | 未登记；查看原记录 | 未登记 |  |
| [AT045_LNQ0_chain_04](attempts/AT045_LNQ0_chain_04) | 未登记；查看原记录 | 未登记 |  |
| [AT046_LNQ0_chain_05](attempts/AT046_LNQ0_chain_05) | 未登记；查看原记录 | 未登记 |  |
| [AT047_LNQ0_chain_06](attempts/AT047_LNQ0_chain_06) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT047_LNQ0_chain_06/receipt.json) |
| [AT048_LNQ1_observation_01](attempts/AT048_LNQ1_observation_01) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT048_LNQ1_observation_01/receipt.json) |
| [AT049_LNQ2_runtime_01](attempts/AT049_LNQ2_runtime_01) | 未登记；查看原记录 | One normal B1/S128 request3/generation1 enc0 four-row LN_FFN→same Q→Wi→DDR reader→G→same Q→Down sample; no all-model, recovery, production request, physical timing or board claim | [执行收据](attempts/AT049_LNQ2_runtime_01/receipt.json) |
| [AT050_FFREF0_reference_01](attempts/AT050_FFREF0_reference_01) | PASS_SCOPED_HOST_REFERENCE | 未登记 | [执行收据](attempts/AT050_FFREF0_reference_01/receipt.json) |
| [AT051_FFR0_four_row_01](attempts/AT051_FFR0_four_row_01) | 未登记；查看原记录 | 未登记 |  |
| [AT052_FFR0_four_row_01](attempts/AT052_FFR0_four_row_01) | 未登记；查看原记录 | 未登记 |  |
| [AT053_FFR0_four_row_02](attempts/AT053_FFR0_four_row_02) | PASS_SCOPED_NORMAL_FOUR_ROWS | external skip and Down, one generated FADD leaf, real two-source AXI reads, one destination AXI write, four rows normal plus finite-error/descriptor probes | [执行收据](attempts/AT053_FFR0_four_row_02/receipt.json) |
| [AT054_FFR1_status_measurement_01](attempts/AT054_FFR1_status_measurement_01) | PASS_SCOPED_LOCAL_FOUR_ROWS | AT050 external skip/Down four rows through one unchanged generated FADD leaf, real local AXI read/write, aligned finite numerical and AXI errors, real-progress guard and passive timing counters | [执行收据](attempts/AT054_FFR1_status_measurement_01/receipt.json) |
| [AT055_FFN0_single_runtime_01](attempts/AT055_FFN0_single_runtime_01) | 未登记；查看原记录 | 未登记 |  |
| [AT056_FFN0_single_runtime_02](attempts/AT056_FFN0_single_runtime_02) | 未登记；查看原记录 | 未登记 |  |
| [AT057_FFN0_single_runtime_03](attempts/AT057_FFN0_single_runtime_03) | COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER | 未登记 | [执行收据](attempts/AT057_FFN0_single_runtime_03/receipt.json) |
| [AT058_FFN1_progress_replay_01](attempts/AT058_FFN1_progress_replay_01) | PREPARATION_FAIL_MICRO_TB_SYNTAX | 未登记 | [执行收据](attempts/AT058_FFN1_progress_replay_01/receipt.json) |
| [AT059_FFN1_progress_replay_02](attempts/AT059_FFN1_progress_replay_02) | COST_NOT_ADMITTED_INVALID_PREFIX_LAUNCH | 未登记 | [执行收据](attempts/AT059_FFN1_progress_replay_02/receipt.json) |
| [AT060_FFN2_direct_xsim_01](attempts/AT060_FFN2_direct_xsim_01) | PREPARATION_ONLY | 未登记 | [执行收据](attempts/AT060_FFN2_direct_xsim_01/receipt.json) |
| [AT061_FFN2_direct_xsim_02](attempts/AT061_FFN2_direct_xsim_02) | COST_NOT_ADMITTED_INVALID_RUNTIME_DEPENDENCY_PREPARATION | 未登记 | [执行收据](attempts/AT061_FFN2_direct_xsim_02/receipt.json) |
| [AT062_FFN3_typed_xsim_01](attempts/AT062_FFN3_typed_xsim_01) | FAIL_SEMANTIC_WI_READER_CONFIG | 未登记 | [执行收据](attempts/AT062_FFN3_typed_xsim_01/receipt.json) |
| [AT063_FFN4_wi_descriptor_01](attempts/AT063_FFN4_wi_descriptor_01) | COST_STOP_SEMANTIC_STALL_AFTER_DOWN_W_LOAD | 未登记 | [执行收据](attempts/AT063_FFN4_wi_descriptor_01/receipt.json) |

## 本批问题与交付文件

- [LQ0_result_LQ1_execution_20261013.md](LQ0_result_LQ1_execution_20261013.md)
- [measurement_first_GQD0_result_handoff_20261013.md](measurement_first_GQD0_result_handoff_20261013.md)
- [measurement_first_KB0_result_KB1_plan_20261013.md](measurement_first_KB0_result_KB1_plan_20261013.md)
- [measurement_first_KB1_result_P3_handoff_20261013.md](measurement_first_KB1_result_P3_handoff_20261013.md)
- [measurement_first_LNREF0_AT035_fixture_addendum_20261014.md](measurement_first_LNREF0_AT035_fixture_addendum_20261014.md)
- [measurement_first_LNREF0_result_handoff_20261014.md](measurement_first_LNREF0_result_handoff_20261014.md)
- [measurement_first_P0_progress_20261013.md](measurement_first_P0_progress_20261013.md)
- [measurement_first_P3_proposal_20261013.md](measurement_first_P3_proposal_20261013.md)
- [measurement_first_W_load_bound_note_20261013.md](measurement_first_W_load_bound_note_20261013.md)
- [measurement_first_early_output_schedule_map_note_20261013.md](measurement_first_early_output_schedule_map_note_20261013.md)
- [measurement_first_output_service_bound_note_20261013.md](measurement_first_output_service_bound_note_20261013.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
