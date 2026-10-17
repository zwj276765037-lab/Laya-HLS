# ATN1：同资源 ASUB 准备与 EXP 重叠的限定结果

2026-10-13；M004/SM005/E005/R001；D-M004-ATTENTION-MEASUREMENT-01。AT021 是唯一调度候选；AT022 只扩同一候选的协议观察 TB。两份冻结 DUT 的 SHA256 都是 `11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`。原 Attention v10 的 M16/A16/D4/EXP4、FP/EXP 内部流水、Q/K/V/mask/gold、命令与响应 profile 保持。AT021 相对 AT020 只改变候选 DUT、状态快照生成器/快照和 runner；AT022 相对 AT021 只改变协议 TB 与 runner。

## 正常完整 head：AT021

完整 enc0/head0 B1/S128、128query/K128/D64、八个16row tile 连续通过原独立中间与最终逐位 gold。M/A/D 2129920/2146176/16384、EXP16384、QK products1048576/trees1032192、AV steps1048576，accepted=retired191088、cancelled0。真实 QK→SM→AV 链没有由 TB 注入被测输出。

| 同口径 cycles | ATN0 AT020 | ATN1 AT021 | 减少 |
| --- | ---: | ---: | ---: |
| QK 首次 done / 实际 consume | 250888 / 250912 | 250888 / 250912 | 0 |
| SM 首次 done / 实际 consume | 287173 / 287197 | 265084 / 265108 | 22089 / 22089 |
| AV 首次 done / 实际 consume | 66256 / 66280 | 66256 / 66280 | 0 |
| 三段首次 done 之和 | 604317 | 582228 | 22089（3.6552%） |
| 全 TB | 1608896 | 1586807 | 22089（1.3729%） |

SM 首次 done 减少7.6919%，实际消费减少7.6912%。正常全 TB 包含相同140288周期加载及诊断读回；不等于完整请求或稳定吞吐。SM 互斥 enabled 状态 ATN1 为 MAX2176+EXP248436+TREE8576+DIV5888+launch/report8=265084；ATN0 的 EXP 为270525，净差22089全部落在该区间。四 worker 的 core-busy 总和均898680 slot-edges，真实 launch/done/commit 各16384；算术工作未减少。ASUB 物理请求16000→4096，lane 工作量仍16384。worker input_wait147456→16384 的状态含义已随预取改变，commit_wait17143→27304，idle18821→51376；这些 worker-slot 计数重叠于四个 worker，不能逐项当成可加的周期收益。ATN1 的四 worker 乐观服务下界仍224670，EXP 与其差23766仅为条件余量。

AT021 static/pilot/full 原保护均 child0、trigger null，分别41.593164/66.621444/482.110123s；full peak owned RSS1108904KiB。上述是工具成本。新增持久准备状态 4×(32bit 值+11bit 完整 key)+3bit count+3bit cursor+1bit pending=179bit；包含数据寄存器，组合仲裁另计。物理 FF/LUT/时序及联合资源 UNKNOWN，不将179bit换算成部署资源。

## 同 DUT 的协议与新增状态回放：AT022

AT022 static41.199444s/peak2319456KiB；PROTOCOL=1 16行回放226.536195s/peak955724KiB，均 child0、trigger null。协议运行实际命中 `staged_pending=1, staged_count=0` 和 `staged_pending=0, staged_count=4` 两种状态，各在 CE=0 下对包含所有新增字段的完整状态快照连续8拍不变，随后 reset 抢占 CE、清空 count/cursor/pending 和四项 x/key。原 M/A/D/EXP 四类活动管线暂停与 reset、六类首错的 bad_element/前行分数、pending Q 首错 CE/reset、错 epoch/row、合法重载与 chain 继续通过。账本 accepted210966=retired210960+cancelled6。末尾同一运行的正常16行逐位 gold 与 products131072/trees129024/AV steps131072/EXP2048 通过；其总 TB1189951含额外协议和 reset 工作，不与 ATN0 normal full 比性能。

准备债务的源码守恒关系：仅在没有未返 ASUB、没有待分发值且 A 队列可接收时发新一批，发射以原 lane 数推进 `exp_key` 并置 pending；真实 A 退休一次后以原 `aq_key+lane` 填四项私有值/key、清 pending；每次按空闲 worker 分发时递减 count、复制值/key 到唯一 worker；EXP 完成后按其持有 key 唯一提交，并在提交边沿推进 `exp_written`。一行仅在第 S 项提交时从 SM_EXP 转 SM_TREE；在这条一进一出的状态转移关系成立时，`exp_written==S` 蕴含本行接受的 S 个 lane 均已提交，故 pending、未分发槽和相应 A/EXP 债务已排空，下一行/epoch 不复用旧项。AT021 完整正常 head 的全部 key 数值/最终输出和 AT022 两类在途 CE/reset 为动态佐证；本轮没有对每个内部槽位逐边沿形式证明，也没有将这些债务作为独立 RTL 完成门再次综合。

原始证据：[AT021 attempt 收据](../attempts/AT021_ATN1_attention_prefetch_01/receipt.json)、[完整数值收据](../attempts/AT021_ATN1_attention_prefetch_01/full_01/numeric_result.json)、[同口径计量](../attempts/AT021_ATN1_attention_prefetch_01/full_01/measurement.json)、[原始日志](../attempts/AT021_ATN1_attention_prefetch_01/full_01/simulate.log)、[AT022 attempt 收据](../attempts/AT022_ATN1_prefetch_protocol_01/receipt.json)、[协议数值收据](../attempts/AT022_ATN1_prefetch_protocol_01/protocol_01/numeric_result.json)、[协议日志](../attempts/AT022_ATN1_prefetch_protocol_01/protocol_01/simulate.log)、[冻结/guard定向核验](ATN1_evidence_check_20261013.json)。五段 guard 串行结束，63条实际 policy 样本均符合 CPU0–3/nice19/idle I/O；两份各93源的冻结身份和差异见核验 JSON。

保留 ATN1 作为本范围的正常 head 周期候选，交主控集中判断；生产采用、物理时序/资源、13BO/完整请求与 M003/M004 仍未完成。不新开第二调度候选，不追加 HLS/OOC/P&R/上板。
