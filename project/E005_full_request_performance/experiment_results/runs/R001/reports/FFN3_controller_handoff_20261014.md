# FFN3 AT062唯一full：Wi reader配置语义FAIL，阶段交付

2026-10-14；A002→A001；D-M004-FFN-TYPED-RUNTIME-PREPARATION-01；M004/SM005/E005/R001。回复`measurement-first-FFN2-review-FFN3-dispatch-20261014`。

**AT062为FAIL_SEMANTIC_WI_READER_CONFIG；FFN3一次full额度已用尽，不在本合同重跑。** 类型感知包262文件/130020393B、原336输入、7 ROM/63 fixture/11 plusarg及5 ELF根/80解析库身份均冻结；完整包ACCEPT，缺/坏ROM、缺reloc、错ELF/库身份五负例REJECT。host累计7.11s。独立冷prefix真LN 1AR/64R、cycle5224、guard28.990s PASS；启动前成本规划3536.346s。full guard1696.154s/峰1036100KiB、child0/null，但原TB在cycle271096报`Fatal: WIGQD Wi reader cfg rejected`，无CHAIN_PASS。

本次达到LN源四行gold及lease PASS（170043）、Q A发布（169979）、Wi W q0/q1/scale R=41984/41984/5248、Wi writer 1312 AW/W/B和一次done消费（271090）。G cfg接受271094，Wi reader cfg握手271096后拒绝，故真实Wi reader R、G/GATE、第二Q、Down TMP、末残差/最终保护均NOT_REACHED。越过AT057 W漏观测停点是新证据，不拼成联合PASS。

只读定位：AT059冻结TB的Wi reader `.cfg_bo_base(cfg_bo_base[0])`、`.cfg_region_base(wi_region_base)`，其中`wi_region_base=DDR_BASE+4096=0x100001000`；先前共享BO是DDR，G接入前第2465行却将同槽改为STATE1 `0x310000000`供Down。reader RTL的`command_ok`要求`cfg_region_base>=cfg_bo_base`，故此接线必拒绝。原日志与该静态矛盾一致；没有另跑单因仿真证明所有其它条件。建议后继仅在新受影响合同中分开Wi DDR与Down STATE1 BO描述符并重验，旧DUT/TB/gold及失败收据不回写。

证据：[工程报告](FFN3_typed_runtime_semantic_failure_20261014.md)、[收据](../attempts/AT062_FFN3_typed_xsim_01/receipt.json)、[核验](../attempts/AT062_FFN3_typed_xsim_01/verification.json)、[full原日志](../attempts/AT062_FFN3_typed_xsim_01/guard_full/driver.log)、[冻结TB](../attempts/AT059_FFN1_progress_replay_02/frozen_new/ffn0_chain_tb_v1.sv)。E005三摘要、模块design/results及A002状态已按本次终态更新；当前无项目重工具。M003/M004、普通Q/L生产控制、外部Attention residual/双源lease、全模型/13BO/恢复及联合物理仍开放。
