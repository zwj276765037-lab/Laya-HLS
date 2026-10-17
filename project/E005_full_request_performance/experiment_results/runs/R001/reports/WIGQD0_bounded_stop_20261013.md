# WIGQD0：单引擎 Wi→G→量化→Down 接链有界停止

2026-10-13；M004/SM005/E005/R001；合同 D-M004-WIGQD-INTEGRATION-01。工程仅签实际完成的四行 Wi 子段。**完整连续链未通过；AT031 full 为 COST_STOP。** 本报告是工程结果交付，待主控集中判断，不改变原始尝试的状态。

## 实施身份与尝试

一套 resident TM4/PS/KB1 writer、一套原容量 dualW、一套原容量 dualA、原 G/量化和原 Wi reader 接于单个按字节寻址的测试存储。四行 B1/S128、batch0/row0 的外部输入为原预量化 LN_FFN A、W/metadata 和命令；Wi 输出由 resident 的实际 AXI AW/W 写入存储。接线、slot/epoch、BO/region 与预定 G/Down 复用见[连接表](WIGQD0_connection_map_20261013.md)。没有为 G 预装 Wi 中间数据，也没有链间 reset。

| 尝试 | 静态 | ≤120s pilot | full | 受影响变化 |
| --- | --- | --- | --- | --- |
| [AT029](../attempts/AT029_WIGQD0_chain_01/receipt.json) | FAIL | NOT_RUN | NOT_RUN | 首版预填端口名称错误，静态 elaboration 停止。 |
| [AT030](../attempts/AT030_WIGQD0_chain_02/receipt.json) | PASS | PASS，仅真实 W 前缀 | COST_STOP，120s 无标记 | 修正预填端口；full 的长 W 读取缺可识别真实进度。 |
| [AT031](../attempts/AT031_WIGQD0_chain_03/receipt.json) | PASS | PASS，仅真实 W 前缀 | COST_STOP，120s 无新标记 | 第二次且最后一次有因修复：W fixture 容量、真实 R 进度、阶段观测。 |

三版各 102 个身份引用行、100 个不同冻结路径；相邻尝试仅测试台冻结文件变化，身份核对无不符。7 段实际 guard 串行，122 条 policy 样本符合原 CPU0–3/nice19/idle I/O 与内存门；详见[身份核对](WIGQD0_identity_audit_20261013.json)。AT031 static/pilot/full 原收据分别为 81.865201s/22.423815s/1137.182375s；full 峰值 owned RSS 1504604KiB、child −9、trigger=`semantic_stall`。wall 与 RSS 是工具成本，不是硬件延迟或资源。

## AT031 full 到达的边界

同一进程仅初始 reset。Wi A 实际物理填充/发布、严格 W 加载后，Wi resident 完成 20992 stripes、671744 PS lane-group、2624 packet 与 20992 个 F32 输出的原独立 gold 检查。实际 Wi AW/W/B 各 1312，83968 有效/物理写入字节；最后 B、局部发布、A/W lease 和读债清零、7 拍响应保持、一次真实 done 消费均在进入下一阶段前由测试台检查。按实际 AW/W 握手和 WSTRB 写入的字节存储，其 Wi 有效区 83968B 在阶段切换前逐字节与独立 fixture 比较，且要求每个字节已被写入。此项只签 Wi 有效区读回，不签全存储保护区最终扫查。

[原始 full 日志](../attempts/AT031_WIGQD0_chain_03/raw_full.log)记录 `WIGQD_WI_COMPLETE cycle=101335 Wi_AW=1312 Wi_B=1312`。Wi cfg cycle54416→首次 done101327 为46911cycles，→实际消费101334 为46918cycles；末 B101319，末 PS101185。到 Wi 完成边界的全冷样本为101335cycles，与独立 WI0 数字相同只作边界核对，不作为连续链性能收益。下一条真实进度为 `MATRIX_PROGRESS cycle=101339 GQD0_cfg_accepted=1`。这是末条**已观测**仿真周期，不是已证最终停拍。其后 120 秒没有新的语义进度标记，原保护器停止 full；未取得足以确定是 reader/G 握手死锁、仿真慢段还是观测缺口的证据。

冻结测试台的定向源码对比增加一条诊断线索：[AT025 GQD0 TB](../attempts/AT025_GQD0_chain_03/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/gqd0_chain_tb_v1.sv) 在 G 命令接受后每完成一行 Wi 就打印 `MATRIX_PROGRESS GQD0_Wi_row`，其原 full 日志在 cycle5294/19454/33617/47780 记录四行；[AT031 WIGQD0 TB](../attempts/AT031_WIGQD0_chain_03/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv) 在 G 命令接受至 `GQD0_A_ready` 之间没有对应行级进度打印，只累计 `wi_accepted`/`wi_rows_retired` 并作断言。故本次 semantic-stall 不能单凭原日志归因于 DUT 停止；该观测缺口也不能证明 reader/G 在被杀前已推进。合同修复额度耗尽，不为验证这一假设原样再跑 full。

## 未取得的出口与处理

Wi reader 的完整 AR/R 及逐行 debt、G/GATE 写入与重读、量化发布、同一 dualA/W/resident 的 Down、G/quant/Down 独立 gold、两段最终债务与 Down 完成消费均未通过本次完整验证。GATE/Down 有效区及所有保护字节最终读回、整链周期和物理资源/时序亦无结果。AT031 的 G 命令接受不代签这些出口；旧独立 GQD0 与 WI0 PASS 不拼成同 runtime PASS。完整 M003/M004、13BO/全请求/恢复保持未完成。

一个接链实现加两轮有因修复的合同额度已经用尽。本轮停排，不启动第三版或提高帽；对下一步应先由主控集中判断这个跨段停止是否值得以新任务研究。保留冻结源码、失败收据与原始日志，不把 COST_STOP 改记为数值 FAIL 或 PASS。
