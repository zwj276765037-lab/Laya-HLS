# 子 agent 管理

| A ID / 运行身份 | 角色 / SM | 期望模型与强度 | 实际配置 | 状态 | 结果链接 / 下一步 |
| --- | --- | --- | --- | --- | --- |

结果引用实验摘要，不复制全部结论。尚未取得运行身份时不填写已启动。

<!-- research-agent:identity-index:begin -->
## Registered identities

This index records identity and links only. Execution, conclusions and user decisions remain in the linked records.

| Agent | Title | Role | Small mission | Mission | Configuration | Status | Result |
|---|---|---|---|---|---|---|---|
| A001 | 项目主控与架构评判 | controller | SM012 | [mission](../agent/A001/mission.md) | [config](../agent/A001/config.md) | [status](../agent/A001/status.md) | [result](../agent/A001/result.md) |
| A002 | 工程实现与验证 | engineering | SM007 | [mission](../agent/A002/mission.md) | [config](../agent/A002/config.md) | [status](../agent/A002/status.md) | [result](../agent/A002/result.md) |
| A003 | 研究探索与瓶颈分析 | research | SM004 | [mission](../agent/A003/mission.md) | [config](../agent/A003/config.md) | [status](../agent/A003/status.md) | [result](../agent/A003/result.md) |
| A004 | executor入口源码核查 | engineering | SM003 | [mission](../agent/A004/mission.md) | [config](../agent/A004/config.md) | [status](../agent/A004/status.md) | [result](../agent/A004/result.md) |
| A005 | executor真实控制consumer验证 | engineering | SM003 | [mission](../agent/A005/mission.md) | [config](../agent/A005/config.md) | [status](../agent/A005/status.md) | [result](../agent/A005/result.md) |
| A006 | executor生成入口验证与runner | engineering | SM003 | [mission](../agent/A006/mission.md) | [config](../agent/A006/config.md) | [status](../agent/A006/status.md) | [result](../agent/A006/result.md) |
| A007 | 严格浮点与共享计算实现 | engineering | SM011 | [mission](../agent/A007/mission.md) | [config](../agent/A007/config.md) | [status](../agent/A007/status.md) | [result](../agent/A007/result.md) |
| A008 | Host与CPU尾部实现 | engineering | SM011 | [mission](../agent/A008/mission.md) | [config](../agent/A008/config.md) | [status](../agent/A008/status.md) | [result](../agent/A008/result.md) |
| A009 | 矩阵供数接口核查 | research | SM010 | [mission](../agent/A009/mission.md) | [config](../agent/A009/config.md) | [status](../agent/A009/status.md) | [result](../agent/A009/result.md) |
| A010 | 高吞吐权重供数实现 | engineering | SM012 | [mission](../agent/A010/mission.md) | [config](../agent/A010/config.md) | [status](../agent/A010/status.md) | [result](../agent/A010/result.md) |
| A011 | 残差与完整模型架构核定 | research | SM012 | [mission](../agent/A011/mission.md) | [config](../agent/A011/config.md) | [status](../agent/A011/status.md) | [result](../agent/A011/result.md) |
| A012 | 编译式RTL交叉验证 | engineering | SM012 | [mission](../agent/A012/mission.md) | [config](../agent/A012/config.md) | [status](../agent/A012/status.md) | [result](../agent/A012/result.md) |
| A013 | 修复版完整30层验证 | engineering | SM012 | [mission](../agent/A013/mission.md) | [config](../agent/A013/config.md) | [status](../agent/A013/status.md) | [result](../agent/A013/result.md) |
| A014 | 完整顶层物理结果审核 | controller | SM012 | [mission](../agent/A014/mission.md) | [config](../agent/A014/config.md) | [status](../agent/A014/status.md) | [result](../agent/A014/result.md) |
<!-- research-agent:identity-index:end -->

## 实际执行状态

A001–A003均planned，runtime/thread/actual_model为空。本次建立项目没有启动新代理，旧baseline代理也不自动绑定到本项目。任务/写入范围详见各A/mission.md。

## 职责对话关联

2026-10-11已建立三个核心主agent职责对话及独立技术问答入口，实际ID见[工作对话](work_chats.md)。上面的planned描述保留为工程任务状态；对话关联已建立，不代表工程实验或硬件工具在运行。后续状态由各负责人按实际工作报告。
