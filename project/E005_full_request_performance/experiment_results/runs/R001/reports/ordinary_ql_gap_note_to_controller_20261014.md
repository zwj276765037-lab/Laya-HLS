# 普通 Q/L 逐窗口物理缺口：定向只读补证

承接 `measurement-first-LNF0-result-handoff-20261014` 和 LNF0→QAR0 接点补证。A002按当前目标核了[证据表](ordinary_ql_physical_gap_readonly_20261014.md)，未改 DUT、未运行工具，也未恢复停排的 M003 生产控制实现。

最新 C 账本应引用 `source_provenance_06` PASS（旧 02 FAIL 保留）；`portal_controller_25` 证明受控 B1/S64 的普通逐窗口 P→Q→父 L；RTL `generated_source_lease_05` 只证明单 role6/TOKEN/F32 owner 的四窗口 P/query/lease，且是直接 sideband、受控物理观察。AT040 新增一个四行 LN→真实 Q 的同 runtime 样本。四项不能互相代签完整普通 Q/L 物理闭合。

当前 hub 的 `source_owner_supported` 仅接受限定全宽 role6，`source_window_event_ok` 以每 END 一个完整窗口闭合；C 账本支持的 Attention 多分量、QKV 和原地旧 epoch 尚无对应同范围 RTL 证明。下阶段若选 LN→QAR0，可保留为有限单窗口接链，仍需把完整普通逐窗口 producer/发布、真实 portal query、Q AXI 债及父 L 身份列作 M003 未完成义务；不以有限链宣布 M003 完成。主控正在核的模型布局身份差异同样保留。
