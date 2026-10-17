# WI0：四行真实 resident Wi 输出

2026-10-13；M004/SM005/E005/R001；D-M004-WI-RESIDENT-01。工程 A002 的 AT028 为四行正常冷样本的限定 RTL PASS：原预量化 LN_FFN A 经完整 dualA fill/commit/finish 与 lease，原严格三路 W AXI 加载，单套 resident TM4/PS、bias kind0 及 KB1 writer 完成实际 AXI 写回。输入是明确声明的外部预量化 A；Wi→G 同进程、完整请求、错误恢复和物理时序未运行。

## 实际数值与接口

原 enc0 Wi，B1/S128 checkpoint 的四 distinct 行，K1024/N5248、group32/tile656。原独立 fixture 的全部 20,992 个 Wi F32 在实际 W 通道数据上按地址逐位比较；20,992 个 stripe、每行 20,992 次 PS 检查，共 671,744 lane-group；2,624 个 TN8 packet、实际 A 返回 32 组、W 返回 20,992 stripe。高 tile 511/512/655 和末组 31 均在完整覆盖中。

严格 W 实际 q0/q1/scale R 分别为 41,984/41,984/5,248 个 512-bit beat；scale 检查 167,936 次，W 发布后才接受 Wi cfg。A 物理 half/scale commit 为 256/128。writer 实际 AW/W/B 各 1,312，物理和有效字节均为 83,968；每个有效 F32 地址唯一、原独立 gold 位型相等，AW 边界与 WSTRB 逐笔核验。最后 B 在 done 前退休，A/W lease 清零、局部 publication 一次、done 保持 7 拍后实际消费一次，并确认无残余有效响应和退休债务。

本 TB 以 AXI 事务地址、WSTRB、唯一覆盖和独立数据比较检查范围外无写，而未建一份独立 byte-addressed DDR 哨兵数组做最终读回；“范围外哨兵保持”的字面读回仍未执行。此限制不改变当前事务级地址及数值断言的 PASS 范围。

| 真实边沿或区间 | 周期 |
| --- | ---: |
| 初始 reset 释放 | cycle6 后的下降沿 |
| 合法 A fill 接受 / 实际发布 | 23 / 289 |
| W LOAD 接受 / W 发布 | 291 / 54415 |
| Wi cfg 接受 / 首末 issue | 54416 / 54426 / 99847 |
| 首末 PS 提交 | 54462 / 101185 |
| 首末 AW / W / B | 76062/101300；76062/101301；76080/101319 |
| 首次 done 有效 / 实际消费 / 全 TB 结束 | 101327 / 101334 / 101335 |
| cfg→done 有效 / cfg→实际消费 | 46911 / 46918 |

cfg→done 互斥状态 s0..s12 之和为 46,911；前端/接口 stall 是重叠计数，不能相加为命令时间。W LOAD 接受→W 发布为 54,124 cycles。末 B→done 8 cycles，done→实际消费 7 cycles。当前全冷数值是 WI0 新基线，不与旧独立 Wi/G/Down 周期相加为生产链时延。TB 原物理 beat 响应延迟 17+(beat%3)、AW/W 周期门及七拍完成反压保持；held_B=23,616 是 TB delay decrement，不能直接当可消除 DUT 瓶颈。

## 尝试与成本

AT026 static PASS、pilot FAIL：从 Down 继承的 GATE source ref7 与 Wi LN_FFN ref2 不符，实际 fill 被拒。AT027 只修正 source ref，static PASS；pilot 到 120.371s 硬帽时仅证明 A 已发布，W 进度未知，记 COST_STOP。AT028 只补真实 W R 每 512 拍的 guard 可识别进展和有界 W 前缀 pilot 出口；fixture 数据与算术 DUT 未改。pilot 在 cycle1611 验证 A 仍发布、q0/q1 各 1,024 R、scale 339 R；W READY、PS、输出均明确 NOT_RUN。以此及旧 Wi/KB1 full 成本形成启动前 3,000s 准入估计，再执行唯一 AT028 full。

AT028 static/pilot/full 分别 57.869275/19.839547/893.130500s，child0、trigger null；full peak 1,456,184KiB，最小 MemAvailable 414,445,780KiB。三 guard 串行，45 条实际 policy 均为 CPU0–3/nice19/idle I/O。28 份冻结源/脚本和 22 份 fixture 逐 SHA/bytes 复核；相对 KB1 只派生 WI TB 与两个入口 Tcl，原 resident/dualA/严格 W/KB1 writer 均按冻结身份复用。三尝试间只变 WI TB；数据 fixture 21 项同 SHA，唯一 streams/manifest.json 因尝试绝对路径不同而变。

原始结果：[AT028 收据](../attempts/AT028_WI0_resident_03/receipt.json)、[full 原日志](../attempts/AT028_WI0_resident_03/raw_full.log)、[准入估计](../attempts/AT028_WI0_resident_03/full_cost_estimate_before_launch.json)、[逐项复核](WI0_evidence_check_20261013.json)。AT026/AT027 的原失败与成本停止收据保持。此阶段支持下一步评估单矩阵引擎分时复用和真实 Wi 存储重读→G 的最小连接；它尚不证明这条连接已经运行，更不能关闭 M003/M004。
