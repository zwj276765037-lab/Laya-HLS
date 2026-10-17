# SM004 完整 LayerNorm 单行服务：局部功能与 OOC 结果

M004/SM004/E004/R001；A002；2026-10-15。当前结果仅覆盖固定图候选的 1024 维单行计算服务。逐项身份、原日志/报告 SHA、守卫与累计账见[机读证据](SM004_ln_row_stage_evidence_20261015.json)；冻结尝试不回写。

## 同版范围与功能

AT104 叶子探针用独立 F32 位模式 oracle 连续送入 16 组 MUL/DIV/SQRT，三者逐位匹配，观测返回延迟分别为 14/12/6 拍，所测连续输入接受间隔均为 1 拍。该探针 CE 恒为 1，不证明通用 CE 暂停或任意域数值；行服务固定 CE 持续推进、用本地有效管线屏蔽无效返回。ADD 复用未改变的 AT093 精确 CE 流身份。

AT107 冻结 RTL `laya_ln_row_v1.sv` SHA256 `da8adccc54275c7232bf43d646cd49e5b9d9c8d7204a2b20e3031f0ddd01bb40`。同一时钟域固定 FSM 复用各一个 ADD/SUB、MUL、DIV、SQRT；X/G 与两组奇偶树 bank 的逻辑 payload 为 14336B。两棵相邻二叉树各完成 10 层、每步 F32 舍入；mean、variance、inverse 及整行输出按[保存的 P1 独立核验夹具](../../../../E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture/)逐位检查。夹具文件仍名为 `dut.ln*`，其历史独立 oracle 核验身份由 P1 记录支撑，不把本次 DUT 输出当 gold。

[AT107 原仿真日志](../attempts/AT107_SM004_ln_row_03/guard_sim/driver.log)以 `LN_ROW_PASS cases=9 reset_during_mul=1` 结束，守卫 child0、无触发。真实 gamma0 正常行命令接受至 done 消费为 8482 cycle；真实 embedding gamma1 加确定性输入空拍/输出反压为 11792 cycle，其中输出阻塞 820 cycle；gamma2 以 **gamma1 数据**核同一算术模式为 10546 cycle，不能代签真实 final gamma。正常行各检查 1024 个有序输出、mean/variance/inverse 与 done 状态，gamma1 和 gamma2 各装载 1024 个 gamma。树层完成打印各 20 条；观测峰值 ADD 占用 7、MUL 发射未提交 15。上述 cycle 含本地输入流/反压和行服务，不含外部 AXI/HBM 搬运、层间调度或完整请求。

其余局部用例检查输入非有限首错 7、gamma 非有限首错 3、kind3 拒绝、相邻树有限输入溢出首错 0，以及前列 gamma 错 3 与后列 normalize 错 9 的竞争。竞争例通过 **TB 受控 force 注入**后列 MUL 非有限返回，只证明首错优先级与无错误输出，不证明该注入值由真实算术叶子生成。错误行输出数为零；done/status/bad index、保持及无 reset 连续命令在冻结 TB 中断言。活动 MUL 发射至少 8 项后执行局部 reset，再跑 gamma0 全行逐位通过；日志的 `pre_reset_mul_issued=0` 是 reset **后**读取已清零计数器，复位前条件见冻结 TB 第 120 行，不能把该打印误读为未进入 MUL。

AT105 六例局部 PASS 保留。AT102 `xelab` 库名错误、AT103 缺解析模块均在 static 阶段失败；AT106 尽管 guard child0，原日志第 144 行 `Fatal: LN_GOLD id=8`，为复位后 TB 错取 gamma1 gold 的**语义 FAIL**。AT107 改正冻结 TB 夹具映射并由 runner 核最终 PASS 标记，旧失败不改签。

## 局部综合与限制

AT108 使用与 AT107 **同一 RTL SHA**，在 Vivado 2025.2、`xcu55c-fsvh2892-2L-e`、6.667 ns 请求下完成唯一一次完整行 OOC 综合，生成[DCP](../attempts/AT108_SM004_ln_row_ooc_01/work/ln_row_v1_synth.dcp)，[blackbox 清单](../attempts/AT108_SM004_ln_row_ooc_01/work/blackboxes.txt)为 `count=0`。合成[资源报告](../attempts/AT108_SM004_ln_row_ooc_01/work/utilization.rpt)：14279 CLB LUT（8510 logic、5460 distributed RAM、309 SRL）、3375 FF、2 DSP48E2、0 BRAM/URAM、0 latch。逻辑 14 KiB 行 payload 在这次网表中未映射为 BRAM/URAM；平铺报告不能将所有 memory LUT 精确归因于某一个 bank，后续需留意 LUTRAM 成本。

[时序报告](../attempts/AT108_SM004_ln_row_ooc_01/work/timing_summary.rpt)综合内部 setup WNS +1.967 ns、hold WHS +0.036 ns；最差内部路径位于 DIV，17 级逻辑。输入 72 个、输出 179 个端口没有外部 delay，OOC 未设置 `HD.CLK_SRC`，尚未布局布线。此处只报告综合内部约束结果，**不称物理 Fmax 或完整 U55C fit**。

[原综合日志](../attempts/AT108_SM004_ln_row_ooc_01/work/vivado.log)有 1 条 critical warning `Synth 8-9873`：同一 ADD 模块定义读入两次；冻结 `ln_add.v` 与 `attention_tile_ce_tanh_libm_stream_leaf_stream_add_node_0_s.v` 字节/SHA 完全相同，工具采用后定义。本次 DCP 无 blackbox，但构建清单需在未来连接阶段去重；不消耗已用过的唯一 OOC 配额重跑同一网表。其余 warning 中有未用寄存器/端口提示，当前无因果证据称数值被裁掉；局部仿真与 OOC 是同一 RTL 身份。

AT108 守卫耗时 152.791918 s、峰 owned RSS 4314552 KiB、最低 MemAvailable 444423404 KiB，child0、无资源触发。AT102–108 守卫实测累计：host 0.373702 s、static 106.040047 s、RTL 29.865697 s、OOC 152.791918 s；所有守卫 policy 记录均匹配 CPU0–3/nice19/idle。host 冻结/准备中未纳入守卫的时间和 owned RSS 不据此补签，故 host 数仅为已测下界；没有预算停止。

结论为**限定的完整 LN 单行 RTL 功能 PASS 与同版局部 OOC 完成**。真实 final gamma 夹具、外部 AXI/HBM、完整模型硬件图、连续请求、联合资源/布线时序及板端均未验证；本结果不代签完整加速器正确性或吞吐。

## AT109–AT110：原语义首错反例与受影响修复（2026-10-15）

独立原行参考对 `gamma_kind=0`、`x[1000]=x[1022]=ff7fffff`、`x[1023]=7f7fffff`、其余正零的整行给出 E_NUMERICAL/bad=0。原冻结 RTL `da8adccc…` 的 AT109 实际返回 E_NUMERICAL/bad=1023、零输出，TB `LN_EDGE_FIRST_ERROR` Fatal；这是旧候选的真实语义 FAIL，不回改原 AT107/108 收据。原因是 DELTA1 扫描遇到后列 delta 错即提前 DONE，跳过了前列 square 错。AT109 的源清单先于 host 生成边界 fixture 写入，附加 fixture 的当前冻结身份另见下方机读收据，原清单不回写。

工作 RTL 仅取消 DELTA1 末的提前结束，保留候选错误并完成 SQUARE 扫描，在阶段排空后按最早逻辑元素索引报告。修复版 SHA `a46d468e3e03e0feef55f36f4be8425d7a3468a13e7c68f16624b213b9ce5f72` 的 AT110 六例通过：原反例与独立抵消溢出反例都返回 bad=0、零输出；常数、交替抵消、近常数和次正规四条正常整行的 mean/variance/inverse 与 1024 个输出均逐位匹配独立原行参考。后两条同时核对既有 `numeric_tb.cpp` 独立位型。原九例受影响回归全过，真实 gamma0/gamma1 仍为 8482/11792 cycle；复位前 MUL 发射计数现于复位前锁存并打印为 8。Gamma 竞争 force 用例仍只证明首错归并，不扩写为真实数值生成证据；真实 final gamma 缺口仍在。

[AT109/110 机读收据](SM004_ln_first_error_closeout_evidence_20261015.json)逐项列冻结清单、附加夹具、guard 原文件与 SHA。累计守卫实测为 host 1.804670 s（仍为下界）、static 175.923183 s、RTL 49.592227 s、唯一 OOC 152.791918 s，均未触本段预算。AT108 的 14279 LUT/3375 FF/2 DSP、0 BRAM/URAM、综合内部 WNS +1.967 ns **只属于旧 `da8adccc…`**；修复版尚无综合资源结论，待同一修复版的 LN→Q 联合候选测量。没有第二次独立 LN OOC。
