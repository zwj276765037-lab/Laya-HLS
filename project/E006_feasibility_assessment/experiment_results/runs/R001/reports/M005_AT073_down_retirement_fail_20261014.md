# AT073 同版代表 top 正常 full：Down 退休接链失败

2026-10-14；M005/SM006/E006/R001。原始尝试为 `../attempts/AT073_M005_top_normal_phase_fix_01/`；冻结输入、工具日志和守卫结果均保留原样。本次结论是 **FAIL_SEMANTIC_DOWN_RESIDUAL_TICKET**，不是完整链 PASS，也不是守卫触发的死锁。

启动前 `preflight_full.json` 为 ACCEPT，逐字节/SHA 检查继承的 236 项和本候选 22 项；实际 `guard_full/launch.json` 为 12:11:05 CST 启动。`guard_full/guard_result.json` 给出 2178.352224s、child 0、trigger null、峰值 owned RSS 1015196KiB、最低 MemAvailable 418155200KiB，136 条语义进展接纳、0 拒绝；`policy_checks.json` 的四个实际进程均为 CPU0–3/nice19/idle。进程退出码 0 不覆盖 `driver.log` 中的 Fatal。

原日志在 cycle 375074 打印 `FFN0_PREFIX_PASS`，此前 Wi 实际读 1312 beat、G 写/读 656 beat、Down 实际 256 AW/W/B；Wi/G DDR 有效字节与保护、Down TMP 64KiB 总窗口（16KiB 有效写入/独立 gold、48KiB 未写哨兵）、LN 来源/lease 以及 Down 原独立 gold/事务检查已经通过相应 TB 检查。Down cfg 在 358881 接受，末 B 为 375058，done 有效 375066、实际消费 375073；原状态计数 16185 cycle 是 cfg→首次 done 的端点差（375066−358881）；cfg→实际消费端点差为 16192 cycle，两端采样都计入则为 16193 cycle。随后同 cycle 375074 的 `FFN0 Down-to-residual retirement gate did not retain ticket` Fatal 阻断了残差任务。日志没有残差 cfg、两源实际读、4096 add、HIDDEN 写和最终 655360B 保护终扫，更没有 `FFN0_CHAIN_PASS`。触发断言为一个合取条件，现有冻结日志未逐项打印 `ffn_done_consumed/tmp_reserved/hidden_reserved/handoff_error/observed_down_aw/w/b` 的失败值，不能据 Fatal 独断具体子因。

Down 计量原日志：`DOWN_MEASURE_LOAD` 的三路 W R 不就绪计数和 AUX R 不就绪计数均为 0，故本 Down 窗口没有动态覆盖 RVALID 已拉高而 RREADY=0 的跨拍保持。该计量在 Wi→Down 切换时重置，不证明 Wi 窗口的保持性质。相位修复短测 AT072 已证明 W 第二 AR 后能继续真实接收，但独立合法反压的第二个完整样本未执行。

M005 三次新 full 已用尽：AT065 2080.617893s＋AT070 716.009461s＋本次 2178.352224s＝4974.979578s／累计 10800s 帽。没有第四次 full。按合同 R2，功能与稳定性仍未闭合；诊断物理测量可测该候选资源/时序，但不得把它写成可用加速器。原日志入口：`../attempts/AT073_M005_top_normal_phase_fix_01/guard_full/driver.log`、`guard_result.json`、`policy_checks.json`。
