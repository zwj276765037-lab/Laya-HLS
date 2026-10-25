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

AT011当前完整闭包真实翻译PASS47.253386187s；AT012严格身份复用证据translation_object_reuse.json，743生成对象完整构建与真实exe PASS（dispatcher260.234739097s）。首次RTL1.622120118s在原GOLD scalar→vector布局读入处FAIL，未进入数学。50数组整数布局审计只有该处，已交原owner修复。最新guard费用static445.349082028s/RTL9.902558032s，其他已知开销见budget_current.json；先前源/构建失败原样保留。

AT013完整fresh744对象构建PASS，原GOLD无损pack已修复，但fixture_end后SIGSEGV。AT014/015已定位并以同源8×168 #0小例重现stock runtime零延迟队列失效；等待隔离runtime固定batch修复，仍未父数值PASS。当前预算见budget_current.json，原失败不覆盖。

AT026当前关键更新：stock #0 SIGSEGV经精确原初始化小例重现；仅隔离fixed-batch-v1 runtime+显式converge512，混合时序与XSim13事件逐字相同、原FP/shared完整回归全同。父512只2TU常量变化，2TU+runtime新编链接2.968448403s，QKV1原8192 gold终点PASS16.559499569s、前86 XSim实际事件匹配。

AT027同exe完整Encoder pilot全STOP0，COST_STOP120.329810056s；48矩阵块/393216值、head0..3完成，checker1118273/PROB/c115428，无Fatal但完整terminal缺失。完整层/30层未验；阶段小表head_stage_wall_times.json、全分析encoder_pilot_analysis.json。预算与政策/清理集中见budget_current.json、policy_coverage_AT013_AT027.json、owned_cleanup_through_AT027.json。


## AT028–AT034 successor continuation

AT028 context1 QKV1/AT029 first-head PASS; model4 AT031/032 FAIL and closed. AT033 full kind5 run FAIL200.518451504s after all16 heads on old context observer ordering. AT034 frozen505e same-top successor translates48.465578970s/builds24.992994920s with733 verified reused objects and11 changed TUs; actual full Encoder run under unchanged800/120 contract is in progress. All detailed identities, commands, guard receipts and segment/event streams remain in respective attempts. Budget includes19.423138976s measured compatibility proof preparation; other unmeasured overhead remainsUNKNOWN.

AT034 FINAL PASS: guard323.414508077s, rc0, noFatal,25/25continuous segments, max72.772360049s; final segment includes normal exit2.648246989s. COMPLETE_PASS kind5/packed0 plus exact HARDWARE_AGENT_SIM_PASS once. Output131072 F32/524288B SHA9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b, actualaccepted trace reconstructs exactly, capture.complete=true/allresourcesretired. AT034 cleanup43 exactknownidentities no live/zombie; 1 shortreplay actualpolicy UNKNOWN preserved. R001 unusedbalance sealed, no transfer to nextfullgraph budget.
