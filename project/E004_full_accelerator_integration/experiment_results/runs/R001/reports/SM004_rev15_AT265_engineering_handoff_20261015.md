# SM004修订15 AT265末行错误短例集中交付

回复 `m004-rev15-at264-scoped-review-last-row-error-completion-20261015`。按D-M004-REV15-AT264-01，只在AT252同一生产sequencer及合法row-wrapper完成peer上补末行错误。生产sequencer SHA `b44b5563b8d4f159917ef3772b69cc8f05066c80a7ecb1cdbb30b3181cc20154`未变，未改生产RTL、gold或原AT252证据；新冻结TB只令第127行的真实done握手返回7/phase14/bad全1且不置末行RAW/FINAL。manifest SHA `a74c147ce4c1cc5d4d0a0bd48c2e5966514ac4b79f6cae0f3fe8bf2ae00f7ee6`。

AT265唯一`S128_LAST_ROW_ERROR_PEER_PASS row_cmds=128 success_done=127 failed_done=1 error_id=208 error_row=127 status=7 phase=14`。独立实际握手计数证实128条行命令、127次成功行done及一次末行错误done；请求status/phase/bad/id/row保持至少3拍至消费。retired_rows=127，前127位RAW/FINAL全1、末位0，tensor_final_valid=0、failed=1；无第129次命令、row0回绕或成功request done。非法范围零发射原断言保留。

冻结源码和原证据：`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT265_SM004_rev15_s128_last_row_error_peer_01/source_manifest.json`，同目录`guard_static/`、`guard_rtl/`的plan/result/policy/driver.log。static child0/null、4.572500266134739s/20s、峰181504KiB；RTL child0/null、5.470804534852505s/20s、峰863040KiB；11条CPU0–3/nice19/idle政策样本均匹配，最低MemAvailable高于192GiB，原日志无Fatal/Error。

追加账`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT265_20261015.json`保留AT243–264原42笔，现44笔（static21、RTL23）、static1773.706414608284832/1800s、RTL2773.568239858373999/4800s，剩26.293585391715168s/2026.431760141626001s；413条政策零差异，host完整UNKNOWN。阶段报告`SM004_lnq_row_stage_result_20261015.md`、E002模块results及E004三摘要已同步。

仅请求对生产sequencer＋模拟完成peer的第127行错误出口作限定审核；不签真实row127输入读错、128行真实LN/QKV/RoPE、成功请求/FINAL发布或旧全请求首错等价。AT250旧wrapper两行真实前缀、当前wrapper AT264真实row0、历史FAIL/COST_STOP仍按AT264分版结论保留。修订15此次不再启动重工具，余额请由主控按合同处理；M004完整目标仍running/unassessed。
