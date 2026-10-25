

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E021 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001 — D33 编译式RTL交叉验证

execution_state: running
verdict: unassessed

工具隔离身份见原 `isolated_tool_bootstrap.json`（root所有，只读）。实际runner：`project/E002_Laya_HLS/experiment/tools/m007_verilator/run.py`，每AT配置、源/fixture/tool SHA、原始flags、guard、warning、编译对象及数值轨迹分别归档。工具`VERILATOR_ROOT`仅每命令环境设置，无全局PATH修改。

当前ADD/MUL/DIV完整fixture和当前shared4已PASS；详细收据为每AT `receipt_translate.json`、`receipt_build.json`、`receipt_rtl.json`。原独立期望和断言原样使用。当前shared4精确同源核见 `shared4_current_identity.json`；旧E008闭包AT005单独保留。

| 尝试 | RTL结果 | RTL墙钟秒 | 原XSim完整语义行一致 |
| --- | --- | ---: | --- |
| AT001_strict_add | PASS | 6.908564353 | True |
| AT002_strict_mul | PASS | 0.507857423 | True |
| AT003_strict_div | PASS | 0.516562675 | True |
| AT005_shared4_E008_frozen | PASS | 0.176021274 | True |
| AT006_shared4_current_CE | PASS | 0.171432189 | True |

累计归档static20.395294613s、RTL8.280437914s；reference0，OOC0。新父闭包采用E016/R007/AT036 frozen原文件，正常前缀对照AT037。完整层和30层不因叶子通过而升级结论。

限制：Verilator二态，原`!==`保留但不能凭此签四态/X传播或未初始化等价。无OOC/P&R/板卡。

父AT007–009均为静态FAIL，原记录保持，原因/flags与费用见compatibility_findings.json。累计static107.921904197s、RTL8.280437914s。等待原owner的新冻结兼容TB与同版XSim QKV1。

AT011当前完整闭包真实翻译PASS47.253386187s；AT012严格身份复用证据translation_object_reuse.j

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_strict_add](attempts/AT001_strict_add) | 未登记；查看原记录 | 未登记 |  |
| [AT002_strict_mul](attempts/AT002_strict_mul) | 未登记；查看原记录 | 未登记 |  |
| [AT003_strict_div](attempts/AT003_strict_div) | 未登记；查看原记录 | 未登记 |  |
| [AT004_shared4](attempts/AT004_shared4) | 未登记；查看原记录 | 未登记 |  |
| [AT005_shared4_E008_frozen](attempts/AT005_shared4_E008_frozen) | 未登记；查看原记录 | 未登记 |  |
| [AT006_shared4_current_CE](attempts/AT006_shared4_current_CE) | 未登记；查看原记录 | 未登记 |  |
| [AT007_parent_encoder_QKV3](attempts/AT007_parent_encoder_QKV3) | 未登记；查看原记录 | 未登记 |  |
| [AT008_parent_complete_closure](attempts/AT008_parent_complete_closure) | 未登记；查看原记录 | 未登记 |  |
| [AT009_parent_unroll128](attempts/AT009_parent_unroll128) | 未登记；查看原记录 | 未登记 |  |
| [AT010_parent_1d_compat](attempts/AT010_parent_1d_compat) | 未登记；查看原记录 | 未登记 |  |
| [AT011_parent_guard_env](attempts/AT011_parent_guard_env) | 未登记；查看原记录 | 未登记 |  |
| [AT012_immutable_closure](attempts/AT012_immutable_closure) | 未登记；查看原记录 | 未登记 |  |
| [AT013_residual_gold_group32](attempts/AT013_residual_gold_group32) | 未登记；查看原记录 | 未登记 |  |
| [AT014_stack_signal_diagnosis](attempts/AT014_stack_signal_diagnosis) | 未登记；查看原记录 | 未登记 |  |
| [AT015_same_source_zero_delay](attempts/AT015_same_source_zero_delay) | 未登记；查看原记录 | 未登记 |  |
| [AT016_zero_delay_fixed_batch](attempts/AT016_zero_delay_fixed_batch) | 未登记；查看原记录 | 未登记 |  |
| [AT017_zero_delay_fixed_batch](attempts/AT017_zero_delay_fixed_batch) | 未登记；查看原记录 | 未登记 |  |
| [AT018_mixed_zero_clock_fixture](attempts/AT018_mixed_zero_clock_fixture) | 未登记；查看原记录 | 未登记 |  |
| [AT019_mixed_converge512](attempts/AT019_mixed_converge512) | 未登记；查看原记录 | 未登记 |  |
| [AT020_mixed_fixed_batch512](attempts/AT020_mixed_fixed_batch512) | 未登记；查看原记录 | 未登记 |  |
| [AT021_mixed_xsim_control](attempts/AT021_mixed_xsim_control) | 未登记；查看原记录 | 未登记 |  |
| [AT022_fixed_batch_add](attempts/AT022_fixed_batch_add) | 未登记；查看原记录 | 未登记 |  |
| [AT023_fixed_batch_mul](attempts/AT023_fixed_batch_mul) | 未登记；查看原记录 | 未登记 |  |
| [AT024_fixed_batch_div](attempts/AT024_fixed_batch_div) | 未登记；查看原记录 | 未登记 |  |
| [AT025_fixed_batch_shared4](attempts/AT025_fixed_batch_shared4) | 未登记；查看原记录 | 未登记 |  |
| [AT026_parent_converge512](attempts/AT026_parent_converge512) | 未登记；查看原记录 | 未登记 |  |
| [AT027_full_encoder_pilot](attempts/AT027_full_encoder_pilot) | 未登记；查看原记录 | 未登记 |  |
| [AT028_single_context_QKV1](attempts/AT028_single_context_QKV1) | 未登记；查看原记录 | 未登记 |  |
| [AT029_single_context_head1](attempts/AT029_single_context_head1) | 未登记；查看原记录 | 未登记 |  |
| [AT030_model4_context4_head1](attempts/AT030_model4_context4_head1) | 未登记；查看原记录 | 未登记 |  |
| [AT031_model4_fixedbatch_head1](attempts/AT031_model4_fixedbatch_head1) | 未登记；查看原记录 | 未登记 |  |
| [AT032_model4_readonly_observer](attempts/AT032_model4_readonly_observer) | 未登记；查看原记录 | 未登记 |  |
| [AT033_single_context_encoder_segments](attempts/AT033_single_context_encoder_segments) | 未登记；查看原记录 | 未登记 |  |
| [AT034_context_credit_v3](attempts/AT034_context_credit_v3) | 未登记；查看原记录 | 未登记 |  |

## 本批问题与交付文件


## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
