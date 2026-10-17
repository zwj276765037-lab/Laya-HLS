# Laya-HLS 当前概览

最新[KB0审核](measurement_first_KB0_review_20261013.md)：首次新算术计量已取得，输出WSTRB利用率50%，据此验证KB1合并写。新优化收益尚未取得；现不恢复生产控制工具。

2026-10-13 P0入口已确定：resident_regression_02的26份冻结源/脚本、12份fixture及原full标记定向核验；6处live漂移隔离。AT001新数值/周期仍NOT_RUN。按[计时边界答复](measurement_first_P0_review_20261013.md)直接继续P1，KB0可用后做KB1；不等待生产控制器。

2026-10-13按用户要求已执行[工作重排](../mission/hardware_measurement_replan_20261013.md)：当前优先取得算术测量和优化对照，独立审视控制架构。M004完整目标保持；M003生产集成仍未完成，退出局部测量的前置链。

工程已确认无重工具运行，executor HLS05未启动；冷INIT、collector/exporter、managed adapter、关闭恢复工作保存后退出优先队列。既有结果和失败保留；本次不因重排追认其生产集成通过。

| 工作 | 当前状态 | 下一可见出口 |
| --- | --- | --- |
| SM005/E005/R001算术KB0 | AT001有限PASS已审核 | cfg→done21100、实际消费21107cycles；全TB48864，原全部gold与512 AW/W/B通过 |
| KB1局部优化 | 四row pack候选，结果待审核 | 目标减少半拍写事务，保持16KiB有效输出；比较命令及全TB周期，物理资源UNKNOWN |
| 控制架构重新选择 | P3只读表已交，薄HLS优先/RTL备选；尚未验证 | KB0后选择原容量关键表的真实校验/提交目标；纯传输片段不足以检验新表示 |
| 完整请求/资源/生产恢复 | 未完成 | 局部测量后按实际依赖恢复集成，不能以KB代签 |

可复用历史依据：四行resident Down 48862cycles、LN→Q rows16完整gold、Attention v10 head128 604317cycles，均只对原冻结模块范围有效；不需为规划从零复验全部历史。executor四次生成COST_STOP/无RTL，program已有有限真实RTL出口。

A002仍唯一实现/重工具owner，全部原资源帽保持；本轮不新跑OOC/P&R/上板，G2338.224019s仅原OOC余额。下一报告须给出算术数据或具体换路决定。详见[计划](../mission/hardware_measurement_replan_20261013.md)、[指标边界](hardware_metrics.md)和[旧概览存档](hardware_measurement_replan_20261013/prior_records/results/overview.md)。
