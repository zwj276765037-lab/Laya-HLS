# Laya-HLS 工作对话

项目根目录：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`。分区：**Laya-HLS**。

| 对话 | 职责 | 打开 |
| --- | --- | --- |
| 项目主控与架构评判 | goal、顶层mission、索引、模型策略、阶段审核与总结果 | [进入对话](codex://threads/01a129af-0395-7fd0-95ac-edd54873bd5f) |
| 工程实现与验证 | 实现代码、实验、原始运行证据与三份实验摘要 | [进入对话](codex://threads/01a129af-29ef-7102-b86a-a43995a36279) |
| 研究探索与瓶颈分析 | source中的论文、方法、瓶颈证据与候选验证方案 | [进入对话](codex://threads/01a129af-3c8e-7c81-8c34-c1801ab5ab9a) |
| 技术问答 | question中的问题、回答与可定位证据 | [进入对话](codex://threads/01a129af-4a73-71c2-bc09-f3eee6e682de) |

三个主agent使用职责名称。A编号仅作为兼容既有记录的内部标识，不能作为对话标题。
技术问答是独立用户入口，需要实验时先明确任务和写入负责人。
对话关联不代表实验运行或硬件通过；实际执行状态仍由负责人报告。


## 四个职责会话自主通信（用户2026-10-11直接授权）

用户已明确授权主控、工程、研究、问答四个既有会话自主提问、答复、决策和交付，无需用户手工转发。直接人类来源及实际四个收发身份见 `.research-agent/communication.json`；技能规范见 `/home/zwj/.codex/skills/research-agent/references/communication.md`。优先使用原生发送工具；当前服务器会话缺少该工具时，运行 `python3 /home/zwj/.codex/skills/research-agent/scripts/communicate.py send --root /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS --from 自己的角色 --to 对方角色 --kind question或answer --id 稳定消息ID --message-file 项目内文本路径`。答复添加 `--in-reply-to 原问题ID`。发送会唤醒既有对话并保存原生接受回执；仅写Markdown不能宣称已通知。授权仅覆盖本项目现有任务内协作，不改变职责、合同、模型、审核停点或实验成本约束。
