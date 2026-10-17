# LNQ2：AT049 四行单实例连续链有效重放

D-M004-LN-QAR-RUNTIME-01；SM005/E005/R001；2026-10-14。结论为 **PASS_SCOPED_NORMAL_FOUR_ROWS**。AT049 在一次初始 reset 后，实际完成 enc0 LN_FFN 四行 residual→LN 写入/发布→同一 Q 读取→Wi→DDR reader→G/GATE→同一 Q→Down；`LNQ0_CHAIN_PASS` 和 `TM4_MATRIX_RESIDENT_FULL_PASS` 均在全部测试台检查之后到达。全冷测试台结束于 cycle 375074。AT047 原语义 FAIL 和 AT048 原运行包 COST_STOP 保持各自结论，不回写为通过。

## 冻结与运行文件

[AT049 manifest](../attempts/AT049_LNQ2_runtime_01/source_manifest.json) 为 289 个引用、288 个唯一路径，逐项 bytes/SHA 零差异；相对 AT048，279 个非本地引用不变，DUT、两份 TB、LN 生成 RTL/ROM、fixture/gold、AXI 响应 profile 和容量不变。只变运行 Tcl，并新增 ROM 放置、逐次启动前 verify-only 闸口及只读短前缀 Tcl；差异见 [freeze_diff](../attempts/AT049_LNQ2_runtime_01/freeze_diff.json)。编译/elaborate 后从原 AT040 冻结源逐 SHA 部署 7 份、共 338B 的 LN ROM 到本次实际 xsim cwd，静态日志含 `LNQ0_ROM_STAGE_PASS count=7` 和 `LNQ0_STATIC_PASS`。

[主机负例](../attempts/AT049_LNQ2_runtime_01/host_checks/result.json)中，目标 ROM 缺失和目标 SHA 错误均在 spawn 前拒绝，注入的模拟器启动数为 0；这是 host 检查。真实[前缀](../attempts/AT049_LNQ2_runtime_01/preflight_prefix.json)与[full](../attempts/AT049_LNQ2_runtime_01/preflight_full.json)启动前各自重新核 7 份目标 ROM、61 份 fixture 引用、全部十项 plusargs 和实际 cwd/xsimdir，均 ACCEPT 后才启动。运行日志无必需文件读取告警。

static 109.060587s/峰 2919208KiB，短前缀 34.095397s/峰 1033096KiB，full 2526.459942s/峰 1034284KiB；三段 guard child0/trigger null，31+4+4=39 条实际 CPU0–3/nice19/idle policy 样本全部匹配，三段串行。前缀 70μs 到 `source_AR=1/source_R=64`，只签真实 LN 读事务，不代签后段。[启动前成本记录](../attempts/AT049_LNQ2_runtime_01/full_cost_decision.json)按 7000 cycles/34.095397s 的本次前缀速率、170031 LN/206136 后段结构工作量、未进阶段 2.5 倍和 5% 余量，估计 3505.199439s<3600s 后才准入一次冷 full；实耗与估计不同，均只是工具墙钟。

## 完成边界

- 原 request3/generation1/B1/S128 的 enc0 residual 四行作为外部只读源。LN 实际 4 AR/256 R、4 AW/256 W/4 B，将 4096 F32 写入 NORM；独立 LN gold 逐位检查，局部 64KiB NORM 窗口内 16KiB 目标与 48KiB 邻接哨兵检查通过。最后 B cycle167215。END 有效时点 cycle168820 的 witness 为 `scope=1/coverage=1/drained=1`、16384B 与真实计数；END 响应 168843，PUBLISH 响应 168898 后实时 scope/coverage 为 0、drained=1、owner=1/1。原 AT047 发布后误读瞬态 coverage 的 Fatal 未复现。LN source lease 经真实 Q 响应消费后释放，`LNQ0_LN_SOURCE_PASS` 在 cycle170043。
- 外部 Q cycle168901 接受，从刚发布的 NORM 实际 4 AR/256 R，产出原独立期望的 4096 INT8/128 FP16 scale，dualA epoch1 在 cycle169979 发布。Wi 使用同一 resident/dualW/dualA 容量，完整 20992 stripes、671744 PS lane-group、20992 F32、1312 AW/W/B 与原独立 gold/实际 DDR 写入通过；Wi 最后 B 271074，首次 done 271082、实际消费 271089，完成标记 271090。
- 真实 DDR Wi reader 有 1312 R、四次 row_done，并按完整身份送入 G。G/GATE 的 10496 F32、656 AW/W/B 通过，末 B 329087；同一 quant_task 从 GATE 实际重读 656 R、生成 328 组，dualA epoch2 在 331802 发布。原 G 优先/等待/拒绝、源 query/grant、W 绑定和债务断言在这次正常流中保留并通过。
- Down 完成 10496 stripes、335872 PS lane-group、512 TN8 packet、4096 F32 原独立 gold；256 AW/W/B、82 次 A 读/返、末 B 375058、首次 done 375066、保持 7 拍后实际消费 375073。末端 A/W lease、source lease、ledger 和读债归零后才输出 PASS。DDR 由真实 AW/W/WSTRB 更新；[冻结 TB](../attempts/AT049_LNQ2_runtime_01/frozen_new/lnq0_chain_tb_v1.sv)在 PASS 前逐字节终扫 393216B，其中 Wi 83968B、GATE 41984B、Down 16384B 与独立 gold/written 标记一致，其余 250880B 为未写 0xA5 哨兵。

LN source Q 接受→其 A 发布为 1078 cycles；Wi cfg224172→消费271089 为 46917；Down cfg358881→消费375073 为 16192。G cfg271094→最终消费375073 为 103979，单次全冷 TB 为 375074 cycles。它们是本冻结响应相位和诊断探针下的边界，不把旧独立 LN/Q/Wi/G/Down 周期相加作性能收益，也不把仿真工具秒数当 150MHz 部署时延。

## 证据与未覆盖范围

[原 full 日志](../attempts/AT049_LNQ2_runtime_01/guard_full/driver.log)、[收据](../attempts/AT049_LNQ2_runtime_01/receipt.json)、[复核 JSON](../attempts/AT049_LNQ2_runtime_01/postrun_verification.json)保存全部原始标记、guard/policy/启动文件身份。full child0 且无 Fatal/ERROR、最终两条 PASS 和 `$finish` 同时满足；静态或 host 检查不能替代本次动态结果。

结论限于这个正常四行窗口和冻结背压 profile。LN 输入仍是外部独立 residual；Attention/WO/residual 硬件、FFN 末 residual、普通 Q/L 多窗口、全 28+2 层与 122 矩阵、生产 13BO 请求及取消/恢复、联合资源、物理时序和上板未验证。LN 本地 64KiB 窗口检查不是 STATE0 全 16920576B 扫描，外部只读 residual 源也没有独立源 DDR 终读回。M003/M004 保持开放；不启动 HLS/OOC/P&R/上板或整体控制。
