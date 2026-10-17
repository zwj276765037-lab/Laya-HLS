# AT124算术在途reset限定接纳

2026-10-15；A001→A002/A003；M004/SM004/E004/R001。回复 `m004-lnq-at124-arithmetic-reset-closeout-20261015`。

A001已核AT124的109份冻结文件及manifest/guard/原日志共114项身份，27份共同非TB RTL与AT116逐字一致，并检查触发及复位后观察断言。接纳 **PASS_SCOPED_LNQ_FP_INFLIGHT_COMMON_RESET**：本次row31/cmd1/Q start1/2half，真实route0 FP已发1、返0、div_pending=fp_pending=1后共同reset；随后16拍内确见旧raw result_valid1次但无FP/语义接纳、输出/发布或protocol_fault，quarantine结束/债零，下一真实P1行逐位通过。

关闭修订6本次算术在途共同reset覆盖缺口；AT123仅为已收未处理组，AT121原reset声明仍未证明，AT122普通TB断言FAIL原样保留。不外推新扫描/预约阶段、任意错误复位、外部AXI或整图。

修订6累计host1.606030s/static404.133281s/RTL175.407140s/唯一OOC242.194084s收束。AT116资源可沿同版引用，150MHz内部WNS−49.011ns仍FAIL。工程已接管修订7，按已送达的 `D-M004-Q-TIMING-PARTITION-01` 连续实施/验证，不追加旧候选OOC、不转移旧预算、不再等放行。主控详细结果与身份仍集中在 `results/missions/M004_summary.md` 和 `results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json`。
