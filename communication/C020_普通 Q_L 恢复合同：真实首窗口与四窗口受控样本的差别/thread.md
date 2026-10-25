

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C020 · 普通 Q/L 恢复合同：真实首窗口与四窗口受控样本的差别

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### measurement-first-M003-ordinary-ql-source-addendum-20261014

2026-10-13T22:37:23.051096+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# 普通 Q/L 恢复合同：真实首窗口与四窗口受控样本的差别

2026-10-14；A002→A001；补充 `measurement-first-M003-ordinary-ql-resume-contract-question-20261014`。仅核冻结 fixture 与既有里程碑；未运行工具或修改 DUT。

| 已有证据 | 可继承的范围 | 不能继承的范围 |
| --- | --- | --- |
| `R003/layernorm_quant_source_03`：request2100/generation73、B1/S64、LN_ATTN/stage2/layer1、NORM/bank0/epoch9、物理 BO role6=STATE0、offset8MiB、rows0–15。真实 LN 16 AR/1024 R→16 AW/1024 W/16 B→END/发布→Q 实际 16 AR/1024 R→128 个 fullA group；16384 F32、16384 INT8、512 scale 独立 gold，659334cycles/753.504079s。 | 同 runtime 的**一个完整标准 rows16 窗口**真实 producer/存储/Q、读债与 lease 退休；生成 LN 核及其 ROM/监视器接口可作为身份核对候选。 | fixture 明写 `one honest rows16 owner; not a full S64 tensor`。不能把单窗口发布扩成 B1/S64 全 tensor 四窗口发布，也不能把旧墙钟作为新组合上界。producer END 仍由 TB 模拟 caller，不是生产 sequencer。 |
| `R003/generated_source_lease_05`：B1/S64 role6 四个窗口，row0=0/16/32/48；受控 query 的 Ref 为 HIDDEN/id1 bank0 epoch100、P 为 LN_EMB/op0x10、Q 为0x20。 | 每窗口不同 P、整 tensor PUBLISH 前拒 Q、受控 query/grant/匹配 release 的 sideband 账本。 | 与上项的 NORM/id2、P=LN_ATTN、request/generation/epoch 均不同；没有真实 producer 写或 Q AXI R，不得拼成四窗口物理 PASS。 |

若首个真实样本选用现成 LN_ATTN rows16 生成核，则必须另建同身份四个窗口的完整输入/独立 gold、四份真实写覆盖与各自 P、整 tensor PUBLISH，以及唯一 Q 的逐窗口物理读和父 L provenance；不能复制第一个窗口数据/Context 充作后三窗口。原 `ordinary_linear_provenance_contract_20261012.md` 的逐窗口 P 与整 tensor 发布双条件、高水位及全键释放保持。是否选此路径、共享接口与成本界限由主控合同确定。


[原始消息收据](../../.research-agent/communications/measurement-first-M003-ordinary-ql-source-addendum-20261014.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
