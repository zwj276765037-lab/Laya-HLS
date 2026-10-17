# P0：LN→Q 有界复用盘点

2026-10-13，A005，D-M004-MEASUREMENT-FIRST-01。默认 KB0 是四行 resident Down；本页交付 LN/Q 备选证据。**本轮只读，E005 新运行 NOT_RUN**，不依赖 FullRuntime、executor、program 或 CLOSED。完整机器记录见 [JSON](ln_q_inventory_20261013.json)。

| 原冻结证据 | 实际覆盖与状态 | 实际周期 / 成本 |
| --- | --- | --- |
| layernorm_producer_hls_01 | 6源真实 LN engine，83份 .v/.dat/.tcl；PASS_SCOPED_GENERATION | HLS 99.227s，peak 3117840KiB；无需因控制对象变化重生成未变算术 |
| layernorm_quant_source_03 pilot | rows1/D1024 LN，1024 F32 bit gold；不执行 Q | 47308cycles / 57.411s |
| 03 full | rows16 LN→实际 store→source lease→QUANT/fullA；16384 F32＋16384 INT8＋512 FP16 scale 全比；PASS | **659334cycles / 753.504s**，peak 856844KiB |
| 03 F9 | 4个 request 身份/epoch 变化先于 AXI 隔离；2个真实 LN 返回 seq/origin 变化隔离 | 全 PASS；四例各约6s、两例各约55s |
| layernorm_quant_source_04 | 受影响 shell/guard 的 rows1＋6个 F9 全 PASS | 全入口约264s；rows16 为 NOT_PLANNED_COMPATIBILITY_PILOT_ONLY |

真实输入是旧 B1/S128 `encoder_00_out` checkpoint 的前16×1024个 F32，65536B；诊断请求是 B1/S64、stage2/layer1 LN_ATTN、gamma0。LN gold由独立 NumPy binary32 相邻二叉tree均值/centered variance、eps0x3727c5ac、sqrt/reciprocal/normalize产生，16384个输出词均不同。Q gold采用 F32 amax/127、reciprocal、乘积、roundf ties away，scale为 FP16 RNE；不是 DUT 输出充当 gold。

03真实 AXI：LN source AR16/R1024，destination AW16/W1024/B16，store65536B；每row4096B/64拍且不跨4KiB。Q再从实际 store 的内存读 AR16/R1024，不可读未写位置，有 read debt 时保持 source lease。三方向 DDR 共196608B。fullA 128次返回各4rows，等于512完整 row-group，16384 INT8和512 scale逐值核验；producer completion完整8拍，并由真实返回形成 END。TB有真实ready/full_n反压，实际B/完成消费、monitor WSTRB、Q response退休/lease释放/fullA acquire-read-release及最终零债务断言。

已核03/04各303项冻结/生成/fixture/raw log/IP/DAT身份，以及上游40项 source/fixture/guard身份，均一致；source与原524288B checkpoint前65536B完全相等，两次 mem/binary gold也一致。关键 SHA256：LN top `b0971fb5569ca6601061d18e04262a4004b493918a48ac3d54db6a22d8610798`；LN gold `418020d7e2cbde19d76796fbd3cf51d832480e06a338e560d006cfa18eb5464e`。其余完整身份和原命令在 JSON。

03→04算术、83份生成engine与gold/TB未变；hub、AXI portal、LN shell及bootstrap guard有受影响兼容回归。**当前live相对04又有6份 provenance layout/core/hub/portal/AXI portal/LN shell变化**，详见JSON，故当前整链不能继承旧 rows16 PASS。复用边界是原冻结算术与数值gold，当前联接只跑受影响范围。

现成入口为 E002 中 `M/tb/run_layernorm_quant_source_shell_v1.py`（M为tm1tn8_gs32_512）。原帽：static 24GiB/1800s，pilot 8GiB/120s，full 8GiB/3600s/5000000cycles，120s真实进展保护；CPU0–3/nice19/idle I/O/MemAvailable严格>192GiB、全项目单重工具。旧完整入口约1023s/17分钟，其中full约13分钟；旧pilot投影1856s只是成本参考，不是上界。父线程决定排队，本页未启动任何实验。

**缺少的KB0观测**：659334是整个冷样本TB计数，含配置/协议/LN/Q/fullA/收束；尚无加载、算术、store、Q、fullA及人为等待的互斥周期分解，不能称纯计算区间、稳态吞吐或冷暖差异。未覆盖gamma1/2、完整S64/所有B/S、Q其它K及零/错误角落、一般cancel/reset/AXI错误恢复、矩阵C、完整production图。单LN HLS资源估计有现成报告，联合物理资源/时序/上板均 UNKNOWN/NOT_RUN；不关闭M004。
