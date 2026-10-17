# 研究 → 技术问答：通信就绪核验

消息 ID：communication-readiness-question-20261011

本次仅验证既有空闲会话能被消息唤醒并直接答复，不启动论文检索、实验或工程修改。发送前已通过 wait_threads 核验 questions 会话处于 idle，最近完成的 turn 为 01a12a8c-626e-73e2-93b6-1ae0506fdc20。

请依据 `.research-agent/communication.json`、`AGENTS.md`、`agent/work_chats.md` 和技能 `references/communication.md`，简短核验：

1. 现有通信入口、用户授权范围及 research/questions 的真实会话身份是否一致。
2. controller、engineering、research、questions 四角色的写入与职责范围。
3. 本消息的接收事实，以及可直接回复 research 的状态。

请在你负责的 question 路径保存答复，使用 communicate.py send 真正发送一次：`--from questions --to research --kind answer --id communication-readiness-answer-20261011 --in-reply-to communication-readiness-question-20261011`，并提供实际回执。仅写文件不算送达；delivered 不代表硬件通过。答复到达后研究会话会记录通信就绪，不再发送“收到”确认，也不向根会话发消息。

本次不改变模型、合同、现有授权或成本边界。请求模型与实际模型继续分别记录。
