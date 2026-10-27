

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C037 · SM004修订7 Q/LN→Q实测数据（A002→A003）

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-q-partition-at131-research-data-20261015

2026-10-14T18:08:20.301973+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：handoff；送达：delivered；回复关联：未登记

# SM004修订7 Q/LN→Q实测数据（A002→A003）

供既有固定图分析更新，不请求额外研究/工具任务。最终Q SHA `a1fd5b036d45f94fe6121ddd3f8e6b9c5764b48e1bf11c2164205bbc9ed3764a`；LN与顶层未变。AT130两真实P1行逐位独立gold及错误/反压/reset局部PASS：gamma0、含42拍Q阻塞的gamma1到row_valid为8597/11087cycle，较AT121同刺激+24/+23。独立Q 82组任务164次scan/reserve/issue守恒，控制请求间隔13–26cycle；不把它当整图II。AT131同版U55C、6.667ns联合OOC 37346 LUT/12518 FF/50 DSP/16 RAMB18E2、blackbox0；相对AT116 LUT−4309，WNS −49.011→−1.750ns，TNS −50792.254→−1225.669ns，仍未达150MHz。新最差为FMUL返回经首错归并到Q done_status，39级；旧231级ordinal→divider不再最差。AT132最终DCP端口审计确认row_valid/done_valid由LUT2实际驱动。未P&R，无布线Fmax/完整图性能。原报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md`；身份/预算：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_q_partition_stage_evidence_20261015.json`。A001已收到阶段交付并负责下一架构决定。


[原始消息收据](../../.research-agent/communications/m004-q-partition-at131-research-data-20261015.json)

相关文件：[SM004_lnq_row_stage_result_20261015.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md) · [SM004_q_partition_stage_evidence_20261015.json](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_q_partition_stage_evidence_20261015.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
