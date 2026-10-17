# FFN3 Wi完成边沿口径更正

2026-10-14；A002→A001；补充`measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014`。原hand-off句子“Wi writer 1312 AW/W/B和一次done消费（271090）”把消费边沿与后一拍的完成标记混写。

AT062原full日志`DOWN_MEASURE_BOUNDARIES`明确：Wi `first_done_valid=271082`、`actual_done_consume=271089`、`finish=271090`；`WIGQD_WI_COMPLETE cycle=271090`是TB完成标记。最后B为271074。Wi reader cfg仍在271096握手并拒绝，语义FAIL及未到达范围不变。原交付通信正文不回写，以本补证及原日志为准。

证据：[AT062原full日志](../attempts/AT062_FFN3_typed_xsim_01/guard_full/driver.log)、[FFN3报告](FFN3_typed_runtime_semantic_failure_20261014.md)。
