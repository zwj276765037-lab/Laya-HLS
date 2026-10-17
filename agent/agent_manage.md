# 子 agent 管理

| A ID / 运行身份 | 角色 / SM | 期望模型与强度 | 实际配置 | 状态 | 结果链接 / 下一步 |
| --- | --- | --- | --- | --- | --- |

结果引用实验摘要，不复制全部结论。尚未取得运行身份时不填写已启动。

<!-- research-agent:identity-index:begin -->
## Registered identities

This index records identity and links only. Execution, conclusions and user decisions remain in the linked records.

| Agent | Title | Role | Small mission | Mission | Configuration | Status | Result |
|---|---|---|---|---|---|---|---|
| A001 | 项目主控与架构评判 | controller | SM002 | [mission](../agent/A001/mission.md) | [config](../agent/A001/config.md) | [status](../agent/A001/status.md) | [result](../agent/A001/result.md) |
| A002 | 工程实现与验证 | engineering | SM002 | [mission](../agent/A002/mission.md) | [config](../agent/A002/config.md) | [status](../agent/A002/status.md) | [result](../agent/A002/result.md) |
| A003 | 研究探索与瓶颈分析 | research | SM002 | [mission](../agent/A003/mission.md) | [config](../agent/A003/config.md) | [status](../agent/A003/status.md) | [result](../agent/A003/result.md) |
| A004 | executor入口源码核查 | engineering | SM003 | [mission](../agent/A004/mission.md) | [config](../agent/A004/config.md) | [status](../agent/A004/status.md) | [result](../agent/A004/result.md) |
| A005 | executor真实控制consumer验证 | engineering | SM003 | [mission](../agent/A005/mission.md) | [config](../agent/A005/config.md) | [status](../agent/A005/status.md) | [result](../agent/A005/result.md) |
| A006 | executor生成入口验证与runner | engineering | SM003 | [mission](../agent/A006/mission.md) | [config](../agent/A006/config.md) | [status](../agent/A006/status.md) | [result](../agent/A006/result.md) |
<!-- research-agent:identity-index:end -->

## 实际执行状态

A001–A003均planned，runtime/thread/actual_model为空。本次建立项目没有启动新代理，旧baseline代理也不自动绑定到本项目。任务/写入范围详见各A/mission.md。

## 职责对话关联

2026-10-11已建立三个核心主agent职责对话及独立技术问答入口，实际ID见[工作对话](work_chats.md)。上面的planned描述保留为工程任务状态；对话关联已建立，不代表工程实验或硬件工具在运行。后续状态由各负责人按实际工作报告。
