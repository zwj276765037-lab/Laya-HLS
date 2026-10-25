# M006：CPU–FPGA 协同高性能推理实现状态

updated: 2026-10-17
execution_state: paused
verdict: unassessed
review_state: document_ready_execution_not_started

已依据用户的新架构文档与本轮要求写成 [Goal v5](../../goal/goal.md) 和 [M006 合同](../../mission/M006_CPU_FPGA协同高性能推理实现/contract.md)，并登记为当前主 Mission。文档交付完成，工程实现尚未启动；不把立项当作性能通过。

CPU 负责 Embedding、LN、Attention、residual、桥接和尾部；FPGA 实现完整 QKV/WO/FFN。重点是持续供数、恢复/累加流水、宽中间量驻留及完整请求性能。模型和数值规则保持，旧串行调度约束不自动继承。

| 阶段 | 执行状态 | 实际结果 |
| --- | --- | --- |
| P1 CPU 后端与服务边界 | NOT_RUN | 本轮只确定范围 |
| P2 持续供数矩阵 | NOT_RUN | 不借用旧局部结果代签 |
| P3 完整 FFN | NOT_RUN | 融合收益尚未实测 |
| P4 整模与物理集成 | NOT_RUN | 当前无板卡，实板保持未验证 |

静态主线激活账为 120 MiB/90 个服务段，较四独立矩阵方案少 115.625 MiB；它不是性能实测。functional/physical/latency/throughput/board 均未验收，没有新 E/R/SM 或运行费用。

旧 M004/SM004 仍暂停且未完成，源代码、原始结果和费用不改，余额不转。恢复需要用户明确通知；之后按新合同登记首段执行预算，复用既有角色连续实施。
