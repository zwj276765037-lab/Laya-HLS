

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E010 / R002 运行结果

[负责人维护的本批运行记录](run.md)

# R002 — E010 strict softmax/head continuation

Execution state: running; Verdict: local components supported, integrated softmax/head NOT_RUN. Authority SM011 D-M007-SM011-SOFTMAX-02. A007 owns attention_and_fp_engine andE010; A010 onlyreads sharedFP/storage interfaces.

Actual runs use m011_softmax_run.py under CPU0–3/nice19/idle and m007_heavy.lock; each fresh AT preserves source_manifest, command, guard_result/driver.log and receipt. Actual cost caps and all success/failure receipts: budget_ledger.json.

Independent reference: AT005 frozen full_reference.py/libm/original real fixture. Generated strict EXP dependency reuse: E002 module rtl/strict_exp_ii1_167/ORIGIN.json andoriginal E007 AT003/006 manifests. New target xcu55c-fsvh2892-2L-e/3.333333333ns. No new OOC/P&R/timing or board result.

AT001 measured63cycle sum dependency FAIL; AT002 actual phase3 return bypass56PASS. AT004 held/mixed/reset/phase1-9cycle PASS. AT006 all32847EXP1lane167/II1 PASS. AT007 firstEXP8 handshakeFAIL preserved; AT008 fix8lane168/II1 allwords+hold/invalid/reset PASS. Softmax/head/Decision/TANH remain incomplete.

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_phase3_sum_dependency_latency](attempts/AT001_phase3_sum_dependency_latency) | 未登记；查看原记录 | 未登记 |  |
| [AT002_phase3_real_head_return_bypass](attempts/AT002_phase3_real_head_return_bypass) | 未登记；查看原记录 | 未登记 |  |
| [AT003_phase3_credit_hold_mix_reset](attempts/AT003_phase3_credit_hold_mix_reset) | 未登记；查看原记录 | 未登记 |  |
| [AT004_phase3_credit_hold_mix_reset_sampling](attempts/AT004_phase3_credit_hold_mix_reset_sampling) | 未登记；查看原记录 | 未登记 |  |
| [AT005_real_softmax_reference](attempts/AT005_real_softmax_reference) | 未登记；查看原记录 | 未登记 |  |
| [AT006_strict_exp_all_real_shifts_lane](attempts/AT006_strict_exp_all_real_shifts_lane) | 未登记；查看原记录 | 未登记 |  |
| [AT007_exp8_real_stream_credit](attempts/AT007_exp8_real_stream_credit) | 未登记；查看原记录 | 未登记 |  |
| [AT008_exp8_hls_start_ready_handshake_fix](attempts/AT008_exp8_hls_start_ready_handshake_fix) | 未登记；查看原记录 | 未登记 |  |
| [AT009_shared_div8_reference](attempts/AT009_shared_div8_reference) | 未登记；查看原记录 | 未登记 |  |
| [AT010_shared_div8_real_masks_errors](attempts/AT010_shared_div8_real_masks_errors) | 未登记；查看原记录 | 未登记 |  |
| [AT011_exp8_real_head_return_sum_tail](attempts/AT011_exp8_real_head_return_sum_tail) | 未登记；查看原记录 | 未登记 |  |
| [AT012_real_bank_softmax_full_sliding](attempts/AT012_real_bank_softmax_full_sliding) | 未登记；查看原记录 | 未登记 |  |
| [AT013_real_bank_softmax_declaration_fix](attempts/AT013_real_bank_softmax_declaration_fix) | 未登记；查看原记录 | 未登记 |  |
| [AT014_real_bank_softmax_compile](attempts/AT014_real_bank_softmax_compile) | 未登记；查看原记录 | 未登记 |  |
| [AT015_real_bank_softmax_oracle_load_fix](attempts/AT015_real_bank_softmax_oracle_load_fix) | 未登记；查看原记录 | 未登记 |  |
| [AT016_head_av_intermediates_reference](attempts/AT016_head_av_intermediates_reference) | 未登记；查看原记录 | 未登记 |  |
| [AT017_autonomous_head_full_pilot](attempts/AT017_autonomous_head_full_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT018_head_initial_bank_binding_fix](attempts/AT018_head_initial_bank_binding_fix) | 未登记；查看原记录 | 未登记 |  |
| [AT019_autonomous_head_sliding](attempts/AT019_autonomous_head_sliding) | 未登记；查看原记录 | 未登记 |  |
| [AT020_softmax_legal_faults_finite_stalls](attempts/AT020_softmax_legal_faults_finite_stalls) | 未登记；查看原记录 | 未登记 |  |
| [AT021_head_softmax_inflight_abort](attempts/AT021_head_softmax_inflight_abort) | 未登记；查看原记录 | 未登记 |  |
| [AT022_head_abort_generation_counter_fix](attempts/AT022_head_abort_generation_counter_fix) | 未登记；查看原记录 | 未登记 |  |
| [AT023_head_abort_new_request_sampling_fix](attempts/AT023_head_abort_new_request_sampling_fix) | 未登记；查看原记录 | 未登记 |  |
| [AT024_head_reset_new_generation_full_recovery](attempts/AT024_head_reset_new_generation_full_recovery) | 未登记；查看原记录 | 未登记 |  |
| [AT025_softmax_late_earlier_stage_logical_rank](attempts/AT025_softmax_late_earlier_stage_logical_rank) | 未登记；查看原记录 | 未登记 |  |
| [AT026_softmax_sfu_inflight_reset_full_recovery](attempts/AT026_softmax_sfu_inflight_reset_full_recovery) | 未登记；查看原记录 | 未登记 |  |

## 本批问题与交付文件

- [final_delivery.md](final_delivery.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
