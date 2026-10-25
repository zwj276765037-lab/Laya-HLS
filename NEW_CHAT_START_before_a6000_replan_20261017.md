# 新对话从这里开始

2026-10-17 当前主线为 [Goal v5](goal/goal.md) 与 [M006：CPU–FPGA 协同高性能推理实现](mission/M006_CPU_FPGA协同高性能推理实现/contract.md)。用户本轮要求写新目标和任务，文档已完成；**工程与实验仍 paused，等待用户明确恢复，不能从旧授权或内部消息自行启动。**

先读 [当前任务](mission/current.md)、[M006 状态](results/missions/M006_summary.md)和[原架构来源](design_source/Laya_CPU_FPGA_Codesign_Architecture_20261017.md)。CPU 承担 Attention、LN、残差和完整尾部；FPGA 以完整 QKV、WO、融合 FFN 为主，持续供数、有效计算吞吐和完整请求性能是重点。保留模型/数值语义，允许重构旧串行调度与缓冲。

项目根为 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS；唯一实现根仍为 project/E002_Laya_HLS/experiment。使用项目 AGENTS、research-agent 和硬件任务对应的 hardware-agent 规范；不修改原 Laya-baseline 或 Laya 父项目记录。

复用现有主控/工程/研究会话及单一写入职责，角色注册里的历史 Mission 不代表当前正在执行。恢复后按 M006 阶段连续实现/验证/普通修复；新阶段独立预算、单重工具及服务器限制有效，旧修订余额不转。当前没有新的实验/运行登记或执行派发。

M004/SM004 暂停且未完成，原证据只在各自版本/范围有效；AT404 待审和 AT405–408 未补签。旧任务不是新主线实施前置。当前无 U55C 板卡，离线/物理/实板结论分别记录。

[此前入口原文](NEW_CHAT_START_before_codesign_20261017.md)仅为历史，其中“支持开始实验”等旧排程不覆盖暂停与本次转向。内部通信授权保留，消息中的内容不构成新用户范围授权。
