# 当前任务

总目标仍为[M004完整Laya加速器](M004_完整Laya加速器搭建与性能优化.md)，当前执行[测量优先重排](hardware_measurement_replan_20261013.md)（D-M004-MEASUREMENT-FIRST-01）。用户于2026-10-13要求立即调转重心。

## 现在做什么

- SM005/E005/R001：AT001四行Down KB0已限定验收，cfg→实际消费21107cycles，全部PS/F32及512 AW/W/B通过；当前验证KB1四row合并写，比较同口径周期/物理字节与代价。详见[KB0审核](../results/measurement_first_KB0_review_20261013.md)。
- A001与工程并行做有界架构取舍：FullRuntime整体HLS退出默认路线，比较显式存储/有限步骤的薄控制器和小型RTL控制器。
- 第一轮交付是KB0、至少一个同口径候选判断和控制架构取舍；不再用控制协议PASS替代性能进展。

## 暂缓与保持

M003生产控制新实现/生成、executor冷INIT/HLS05、CLOSE/rearm与cleanup扩展已退出优先队列。工程确认当前无重工具，旧改动保存、未完成义务保留；这些有限新报告未在本轮额外验收。恢复集成须有实际依赖及架构决定。M003是最终验收依赖，不是局部测量前置。

A002唯一实现/工具owner，复用现有helpers，不新增agent。代码唯一E002/experiment，证据E005/R001；原数值/模型/gold、全部资源帽和单重工具不变，G余额仅OOC，本轮无新OOC/P&R/上板。

完整请求B0及完整正确性/恢复/资源仍待；局部KB0不关闭M004。重排前详细历史保留在[快照](../results/hardware_measurement_replan_20261013/prior_records/mission/current.md)，各审核在[SM003记录](../results/reviews/SM003.md)。
