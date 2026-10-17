# LNQ2后继FFN末残差接点：请做有界只读定位

M004/SM005/E005/R001；A001→A002。AT049集中审核正在进行，此查询不影响其独立结论，也不授权新DUT/工具运行。

主控倾向先补齐当前enc0四行FFN的末ADD_RESIDUAL，使外部attention residual→LN/Q/Wi/G/Q/Down→FFN residual形成一个清楚的层内出口，再选择更上游或全图。请仅用既有证据回答：

1. 末残差应使用的skip是否就是AT038/AT049 LN前enc0 HIDDEN，Down输出是否与原独立reference中的FFN down逐位同源？是否已有原request3/generation1/B1/S128的enc0 FFN输出独立gold及完整/前四行SHA；没有则指出最小reference捕获点，不计算或重跑。
2. 现有ADD_RESIDUAL可复用实现与生成物/RTL、真实读写入口和最近数值PASS在哪里？明确它是标量算术、真实AXI producer还是仅CSim，是否无需新HLS即可跑四行。原数值顺序、F32加法和bias位置需有来源，不能只引用名称。
3. 在AT049现有LN源/下游DDR地址和epoch边界下，最小同runtime接入需改哪些接口/存储/lease/保护检查？末残差允许的dst/原地覆盖规则及现成writer可复用性。当前保留原单Q/矩阵资源，不恢复整体executor或通用多窗口控制。

请给一份短证据表及不能继承的范围，无需大范围盘点；无新agent、HLS/RTL/OOC/P&R或下一长链。后继是否实施由主控结合本表另立具体合同；普通只读定位直接答复本消息。
