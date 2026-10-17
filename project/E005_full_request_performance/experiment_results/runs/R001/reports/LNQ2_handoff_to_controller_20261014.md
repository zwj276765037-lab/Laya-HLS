# LNQ2 AT049 工程集中交付

回复 `measurement-first-LNQ1-review-LNQ2-runtime-dispatch-20261014`；M004/SM005/E005/R001。请主控按原阶段职责集中核定 [报告](LNQ2_runtime_replay_result_20261014.md)、[收据](../attempts/AT049_LNQ2_runtime_01/receipt.json)、[原 full 日志](../attempts/AT049_LNQ2_runtime_01/guard_full/driver.log)及[独立复核](../attempts/AT049_LNQ2_runtime_01/postrun_verification.json)。工程没有新增 DUT/TB/数据/profile 修正，原 AT047 FAIL、AT048 COST_STOP 不回写。

AT049 static PASS 109.060587s，7 ROM 实际部署；host 正/缺失目标/损坏目标三例中，缺失与损坏均在 spawn 前拒绝。每次 xsim 启动前分别核真实 cwd、7 ROM、61 fixture 引用、十项 plusargs；前缀 70μs 实见 LN source AR1/R64，34.095397s。依据本次前缀重新估成本 3505.199439s<3600s，才启动本阶段唯一一次 full。

full 2526.459942s、峰1034284KiB、child0/trigger null，冷 TB375074cycles；三 guard 串行，31+4+4=39 policy 全匹配。manifest289引用/288路径逐SHA/bytes零差异，279非本地引用与AT048同一。full 原日志无 Fatal/ERROR，`LNQ0_CHAIN_PASS`、`TM4_MATRIX_RESIDENT_FULL_PASS`、`$finish`均到达。

LN四行4096F32原gold，4AR/256R、4AW/256W/4B、16384B store，END有效覆盖快照168820、PUBLISH响应168898、源租约释放170043；同Q实际重读并发布A169979。Wi20992F32/1312AW-W-B，真实DDR reader1312R；G10496F32/656AW-W-B、同Q重读656R/328组，A331802；Down335872PS/4096F32/256AW-W-B，末B375058、实际done消费375073。全部独立gold及末端债务/lease通过；下游393216B DDR输出142336B逐字节gold/written，余250880B哨兵终检通过。LN另核本地64KiB NORM窗口；外部residual仍是只读源，未签全STATE0或生产13BO。

建议审查口径为 **正常四行单实例同runtime有限RTL PASS**。全请求、普通多窗口Q/L、Attention/WO/residual硬件、FFN末residual、取消/恢复、联合资源/物理时序/上板及M003/M004继续开放。本阶段full额度已用尽，无新HLS/OOC/P&R/上板或整体控制运行。
