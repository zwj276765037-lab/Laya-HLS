# FFN0 四行接链有界停止：Wi W 读进展漏计

2026-10-14；D-M004-FFN-SINGLE-RUNTIME-01；SM005/E005/R001；A002。结论为 **COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER**，不是同 runtime FFN 整链 PASS，也不是已证 DUT 死锁。一个连接候选、AT055 初版及 AT056/AT057 两轮有因修正、AT057 唯一四行 full 均已用尽；本合同不追加 full。

## 已到达的真实边界

AT057 冻结 311 条文件引用、310 个不同路径；结束后全部逐 bytes/SHA 复核一致。原 AT050 `skip`/最终四行 binary 转 `.mem` 后 4096 个 F32 位型逐项相同；原生成 FADD 叶子和槽保持原 SHA。新包装将同一只初始化一次的 64KiB `source_mem` 供 LN 与残差 skip 读，Down writer 目标改 STATE1+8MiB TMP，残差目标 STATE1+0；这些接线已编译，后两处尚未动态到达。

AT057 static 113.845s、峰 2925688KiB，短适配器 24.641s、峰 1322952KiB，均 child0/trigger null。短 RTL 在真实接受边沿验证错 BO/错 Context 零 matrix 发起、ledger 未就绪不提前发起、256 次 AW/W/B 后 owner 退休且成功 done 实际消费才发残差、响应保持七拍、TMP 逻辑 bank0/epoch1 与模型 generation1 输出、重复 ticket 明确拒绝。它是定向适配器测试，由短 TB 注入退休事实，不能代签 full 的真实矩阵/ledger 交接；失败 done、旧 TMP bank1/epoch2、错目标等合同中列出的其他短负例未逐项动态覆盖。

真实 LN 前缀 pilot 25.298s、峰 1035856KiB，cycle5224 见源 1 AR/64 R，child0/trigger null。每次 xsim 前 verify-only 核 7 ROM 与 63 fixture；AT057 host 正例 ACCEPT、缺 ROM 与错 SHA 反例均 REJECT/spawned=false。guard 六个逻辑时间反例通过，重复 SIM_START、重复计数及周期心跳不会续命。静态/短/前缀/full 四段工具的 32/24/4/4 条实际 CPU0–3/nice19/idle policy 样本全部匹配；host 直接运行无 RSS/policy 样本，不补作实测。

启动前准入按本次 5224cycle/25.298s 前缀速率与旧 AT049 联合 full 更慢的 148.458cycle/s，给 500000cycle 规划工作量及 5% 时间余量，得 3536.346s<3600s；峰 RSS 投影 2071712KiB<8GiB。500000cycle 是预算估计，不是新链周期或确定上界；AT049/AT054 旧周期不相加作新性能结果。[准入记录](../attempts/AT057_FFN0_single_runtime_03/full_cost_decision.json)在唯一 full 启动前写入。

唯一 full 在真实 LN 最后 B167215、PUBLISH168898、Q 接受168901之后取得原 `LNQ0_LN_SOURCE_PASS`：四行 4096 LN F32、源 4 AR/256 R、目标 4 AW/256 W/4 B、16384B 存储与源租约释放；source A 发布169979，LN 源阶段最终 marker170043。它随后进入 Wi 权重实际读取。停止前原日志 `MATRIX_PROGRESS cycle=204365 stage=0 W_q0_R=26624 W_q1_R=26622 W_scale_R=5248`；q0/q1 从首条 512/510 持续增长。冻结 `ffn0_progress_observer` 却未计这些 W R 握手，最后 `FFN0_PROGRESS work=840` 停在 LN/Q；冻结 guard 只接受该计数增长，120s 后 `semantic_stall`。full guard 785.690s、峰 1036212KiB、child−9/trigger semantic_stall；无 Fatal、ERROR 或 `FFN0_CHAIN_PASS`。这是进展观测覆盖不足造成的有界停止，不得从旧 `MATRIX_PROGRESS` 文本反向补写守卫合规，也不能把正在增长的 W R 说成硬件停滞。

## 原失败与不能继承的范围

AT055 静态通过，尚未短测/pilot/full。AT056 静态通过；短测 tool child0/null 但在合法 Down 发起前 `Fatal: legal Down not issued`，因为适配器把门户包头 generation900 与模型 identity generation1 混淆。AT057 将两者分开，同时对 matrix 与 ledger 同边沿就绪作有限门控；短测通过。AT055→AT056 仅适配器、runner与新增短测试/Tcl变化；AT056→AT057 仅适配器、短 TB、联合 TB 被动计量及 runner尝试路径变化。旧冻结和失败均不回写。

本次新 full 未到 Wi 矩阵完成、G/Q、Down 实写 TMP、残差从同一 skip/刚写 TMP 重读、最终 HIDDEN 写回/独立 gold/655360B 总窗口终扫，新增边界与互斥周期也未到最终打印。`FFN0_CHAIN_PASS` 为 NOT_REACHED；新组合冷周期、加法延迟分布、资源/物理时序均 UNKNOWN。AT049 到 Down 的旧有限 PASS 和 AT054 双外部源局部 PASS 各自保留，不能拼成同 runtime 残差完成。

普通多窗口 Q/L、生产双源 query/lease、Attention/WO 上游、全28+2层/122矩阵、13BO请求/恢复及联合物理资源/时序/上板继续开放，M003/M004不关闭。原单重工具、资源帽、G仅OOC余额2338.224019s、5172s不重启及整体 executor/冷INIT 停排保持。是否另立受影响守卫修复与新 full 合同由主控集中选择。

原证据：[AT057 收据](../attempts/AT057_FFN0_single_runtime_03/receipt.json)、[全量原日志](../attempts/AT057_FFN0_single_runtime_03/guard_full/driver.log)、[guard 结果](../attempts/AT057_FFN0_single_runtime_03/guard_full/guard_result.json)、[文件与policy核验](../attempts/AT057_FFN0_single_runtime_03/verification.json)、[AT056 失败日志](../attempts/AT056_FFN0_single_runtime_02/guard_short/driver.log)、[AT057 短测日志](../attempts/AT057_FFN0_single_runtime_03/guard_short/driver.log)、[前缀日志](../attempts/AT057_FFN0_single_runtime_03/guard_pilot/driver.log)。
