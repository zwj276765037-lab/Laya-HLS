# 当前工作：WIGQD0单引擎Wi→G→量化→Down连续连接

[WI0集中审核](../results/measurement_first_WI0_review_20261013.md)限定接纳四行真实resident Wi：671744 PS/20992F32、1312 AW/W/B、末B/lease/局部发布及一次消费PASS；全TB101335，cfg→消费46918，W加载54124。独立DDR哨兵读回仍未执行，保留缺口，由新真实存储接链补充，不追认旧样本。实际诊断B字段2、batch0/row0仅四行，不能冒充B2全量。

当前按[D-M004-WIGQD-INTEGRATION-01](wi_g_quant_down_integration_stage_20261013.md)直接推进：原预量化LN_FFN A→真实Wi AXI写存储→真实Wi reader→G→GATE写读→量化→同一dualA→同一resident执行KB1 Down。统一B1/S128/batch0/row0四行窗口，单引擎/原容量A与W各唯一，slot0 epoch1→2在真实债务归零后复用，只有初始reset；必要A端口透传/外提保持原状态权威。新链NOT_RUN，旧WI0/GQD0的PASS与周期不能拼成结果。

新样本必须取得真实存储写入/重读、独立保护字节读回、全部Wi/G/quant/Down gold、每阶段实际完成和新冷基线。有限诊断driver允许，整体生产控制不是前置；A002唯一实现/工具owner，普通实现/受影响验证连续推进，阶段出口或实质阻塞再集中交付。

KB1/ATN1/GQD0/WI0限定保留，KB2/CT0/LQ1R收束，LQ1不生产采用。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup仍停排；唯一代码E002/experiment、证据E005/R001，不新增agent、不写旧baseline。原单重工具/分类帽、G2338.224019s仅OOC余额、5172s不重启，无新HLS/OOC/P&R/上板/预算。完整28+2层/122矩阵、13BO/请求/恢复/联合资源与M003/M004仍未完成。
