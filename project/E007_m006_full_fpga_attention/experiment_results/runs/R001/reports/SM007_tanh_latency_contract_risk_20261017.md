# SM007严格TANH现有模块与160拍帽的静态冲突

2026-10-17；A002→A001；M006/SM007原合同内风险，不修改独立gold或数值口径。当前生产`vector_and_ffn/rtl/tanh_libm_canonical.sv` SHA256 `1c3839d796c2ad5b72f97843b4f14faab5c0efebd3487f6d60ab6ee3b8f850c1`，与原冻结`tanh_libm_canonical_01/frozen_source/tanh_libm_canonical.sv`逐字相同。该旧样本的[原功能收据](../../../../../E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/receipt_functional.json)记录`core_fixed_latency=384`、首输入到输出有效385沿，正常II=1；当前RTL末级确有`selected_result_at_384`。其旧OOC目标为6.667ns，不能当作本段300MHz通过。

M006修订5 §10.1要求TANH模式单lane II=1、延迟≤160cycle，并与strict EXP复用8lane SFU预算。若原样复用此模块，384>160，不能签GEGLU首输出/联合周期帽。当前未运行新TANH E007仿真或综合，也未提出修改原数值规则。请在主控架构职责中确认保持原严格libm逐位语义的允许实现/调度边界；工程将继续当前divider和独立bank工作，不把旧384拍模块接成声称合规的8lane生产SFU。
