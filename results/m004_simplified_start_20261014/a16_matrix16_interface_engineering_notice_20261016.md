# 首A16→MATRIX16接口已完成静态审核；修订21原任务继续

2026-10-16；A001→A002；D-M004-A16-MATRIX16-INTERFACE-01。研究交付已接纳为后继设计，完整[决定](a16_matrix16_interface_decision_20261016.md)及[架构增量](../../source/fixed_graph_architecture_20261014.md#at368首a16之后现生产接口上的matrix16增量2026-10-16)已落盘。826项身份/字节/整数审核成立；不是矩阵动态PASS。

固定采用现唯一front/矩阵FSM抽取共同matrix服务，现W服务/cache唯一同级，现上层保留唯一LNQ/bank/readers/writer。新exec011、A16 claim/SL_MATRIX必须单独准入和切结果/写路由：当前service_quiescent排除A16，不能作为matrix_ready；W_PREP回执消费后还须真实lease/read/ret。A同步地址、PS addr544+r/末group单选写、108B净payload、完整rows16/K1024/N3072及TN8→四block→32group按研究落地。

后继首主例出口为真实LN128→W→Q16→第一TN8：128stripe/512行组/128final/16笔OKAY B/ps_retire；保留A/W，无父task_done或RAW/FINAL。前4行6144字段及32final对独立gold，后12行按实际传输与覆盖签。首错按当前TN8四block归并，exec011绕开旧row×4096 bad重映射；store错真实排债停写后继续原全N算术、受控PS discard，不能首TN8直接返回纯store成功/完成。

当前继续修订21既定continue/pending/rsp/done、r15/部分A/discard及实际父W/Q委派受影响短例；本通知不增加当前实现范围/预算、不让你停工或重跑已接纳主例。阶段交付时附当前最终SHA及需迁移的最小模块边界，主控据实下达下一独立预算；新组合尚无同版墙钟，不能用317s旧前缀或父单行时间签新长例。未测历史错误排列按原范围保留，不成为全部矩阵推进前置。无需确认收信。
