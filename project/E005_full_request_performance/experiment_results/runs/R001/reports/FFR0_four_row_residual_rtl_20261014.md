# FFR0 四行 FFN 末残差局部 RTL

2026-10-14；D-M004-FFN-RESIDUAL-RTL-01；M004/SM005/E005/R001；工程 A002。**AT053 PASS_SCOPED_NORMAL_FOUR_ROWS**：AT050 原 enc0 四行 skip 与 Down 分别作为声明的外部只读源，单个未改生成的 `tanh_libm_leaf_fp_add_bits` 经结果槽完成 F32 加法；两个 AXI512 端口实际读入，第三端口实际写至另一 HIDDEN bank。4096 个结果 bit 对 AT050 独立 enc0 输出逐项相同。此结论是局部 RTL 仿真，不是 AT049 同 runtime 的 FFN 完整出口。

## 数值与真实事务

原参考数学是 `np.add(skip, down, dtype=np.float32)`、无 bias。skip/Down/gold 三个 16384B 文件的 SHA 由 [冻结清单](../attempts/AT053_FFR0_four_row_02/source_manifest.json) 绑定，分别为 `5ad0bec6…`、`4071d238…`、`c5b1310d…`；原生成加法叶子 SHA `d1370d29…`，未修改也未重跑 HLS。诊断任务锁定 request3/generation1、B1/S128、op `0x62`、stage2/layer0、rows4/D1024/bias65535 与共同 numeric/model/layout/build tags。源为 STATE0 `0x300000000` HIDDEN bank0 和 STATE1 `0x310000000` +8MiB TMP；目标为 STATE1+0 HIDDEN bank1，完整 BO 容量校验保留。两个外部源由 TB 按原二进制预装，不能解释成已运行上游 producer 或生产 hub 授权。

[AT053 原 full 日志](../attempts/AT053_FFR0_four_row_02/guard_full/driver.log)记录 skip/Down 各 256 次真实 AR/R，目的 256 次单拍 AW/W/B，所有 WSTRB 为满 64B；每个 AXI burst 一拍，未预签四个多拍 burst。DUT 加法接受/返回各 4096 项，TB 终检 4096 个 F32 bit 及三个 64KiB 窗口共 196608B：两源前 16KiB 等于原输入且其余哨兵未写，目的前 16KiB 等于独立 gold 且 written 全覆盖，邻接 48KiB 哨兵未写。正常任务最后 W cycle103325、真实最后 B103340，间隔 15 拍；首次成功响应103341，七拍保持后实际消费103349。`FFR0_BOUNDARIES total=103350` 是正常任务及终扫后的打印点；后续两个数值拒绝探针仍在同次模拟中执行，`$finish` 为 1034210ns。首次 AR/R 为 cycle62/67，含五个先行错误描述符拒绝探针，不能当作不含探针的计算延迟。

五种定向错误描述符由 DUT 拒绝、零新增 AXI；正常任务后首元素 NaN、两个有限最大值相加溢出各得到本地拒绝，未新增 AW/W/B 或成功发布。[审核补证](FFR0_AT053_readonly_issue_addendum_20261014.md)发现本地数值码8与生产`E_NUMERICAL=6`不符，故这些探针不证明生产错误码语义。正常响应时本地 `source_locked=0`、`dst_published=1`，所有 DUT 与 TB 的 AR/R、AW/W/B 计数闭合。源码只在末个 Down R 退休后放开本地源锁，只在末 B 成功后置本地目标有效位；原日志没有打印这两个信号的精确边沿，也没有打印逐项加法延迟分布，故不报虚构周期。响应和请求被限于本地诊断状态，不替代完整 source-query/grant、双生产 lease 或 owner 高水位。

## 冻结、尝试及工具成本

AT051 在冻结准备时找错 guard helper 路径，工具未启动，原 [准备失败](../attempts/AT051_FFR0_four_row_01/preparation_failure.json)保留。AT052 静态、同一加法槽 52 例 native binary32/RNE 定向 fixture、单行 pilot 均 PASS；单行发现 `first_done` 原观察混入先行拒绝探针。AT053 仅改联合 TB 的观察/断言，生成叶子、槽、双源 DUT、fixture、runner 和 guard 相对 AT052 的 SHA 全同；原 pilot 错标签不改写。AT052 加法槽 `accepted=returned=consumed=52`，每例结果保持 4–7 拍后唯一消费，同包装的零符号、抵消、次正规边界按原 52 例逐 bit 比较通过；不推广为全 IEEE 空间或忙时 reset 恢复。

| 实际阶段 | 结果 | guard 秒 | 峰 owned RSS KiB | 实际 policy 样本 |
| --- | --- | ---: | ---: | ---: |
| AT052 同 SHA 加法槽 | PASS | 25.495115 | 1333488 | 24 |
| AT053 static | PASS | 22.174020 | 1372920 | 20 |
| AT053 单行 pilot | PASS；1024 项、各源 64R、64 AW/W/B | 26.307417 | 1371944 | 24 |
| AT053 四行 full | PASS；4096 项、各源 256R、256 AW/W/B | 26.989242 | 1376640 | 27 |

四段 child0/trigger null、95 条实际 CPU0–3/nice19/idle policy 均合规。AT053 的 14 条冻结/外部身份逐 bytes/SHA 匹配；它对 AT052 唯一变化是联合 TB。full 前 [成本准入](../attempts/AT053_FFR0_four_row_02/full_cost_decision.json)以本次完整单行 25903 cycles/26.307s 乘四再乘 10 倍余量，估计 1036120 cycles/1052.297s，低于 40Mcycles/3600s；它是启动判断而非严格运行上界。缺文件与错 SHA 两个 host 反例均在 spawn 前拒绝。full 实测 26.989242s/峰 1376640KiB，原 8GiB/3600s、120s 停滞帽均未触发。审核补证同时发现 `FFR0_PROGRESS` 可由周期心跳重复触发，旧日志五条实际计数均递增，但现 guard 规则不能认证一般语义停滞检测。没有新增 HLS、OOC、P&R 或上板。

本结果只覆盖四行双外部源、单在途加法、确定性 AXI 读延迟与 AR/AW/W/B 反压、五种描述符拒绝及两个非有限数值拒绝。三个局部 64KiB 窗口之外的完整 STATE0/1 BO 未终扫；源 producer 发布、真实双源 lease、FFN 残差接回 AT049、普通多窗口、整体请求/恢复、联合资源和物理时序仍未验证。M003/M004 不关闭；AT049 长链局部 PASS、AT047 FAIL 和 AT048 COST_STOP 维持原范围。工程交主控集中选择后继，不自行启动新长链。

[AT053 收据](../attempts/AT053_FFR0_four_row_02/receipt.json)、[逐身份及策略核验](../attempts/AT053_FFR0_four_row_02/verification.json)、[full guard](../attempts/AT053_FFR0_four_row_02/guard_full/guard_result.json)、[AT052 槽日志](../attempts/AT052_FFR0_four_row_01/guard_slot/driver.log)提供复核入口。
