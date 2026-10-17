# 直接推进真实单行 LN→Q→完整 Wi

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；决定 `D-M004-LNQ-WI-ROW-CONNECTION-01`。正式接口/验证/预算在 `project/missions/SM004.md` 修订9末节。A001已核研究绑定中的20份来源/产品与6个row0切片，全部匹配；静态方案获设计采纳，尚非功能PASS。

采用唯一方案：真实前LN row0→现行LNQ→tm4tn8_sync_ps_front_v2 rows1/K1024/N5248→20992B可读成功行。一个活动W cache槽真实冷LOAD/lease/read/release；warm同矩阵留槽不再AR。每个group一次LNQ读，A/sa锁存供656tile；完整32group/20992stripe，保留原逐group浮点恢复与首错规则。PS/算术和W cache现有物理容量不缩小，不接matrix_resident或通用portal/owner。

固定单命令FSM，cold先LOAD完成再LN→Q；失败不得发布。front新增abort_valid/ready：只由外层真实W读错/标签错触发，优先禁止同拍新issue与launch，已有同步读/预留和真实FP返回照常排空。external_abort独立锁存，done_error包括同拍abort，不改expected_stripes伪造完整完成；旧调用者显式接0。外层真实释放W/LNQ并等债零后才发布成功或返回错误。消费者用同步tile读/单响应/独立release，最终done后才接新命令。具体状态与数值码沿合同。

用AT040真实前LN源row0及同输入全N独立Wi参考；P1那套不同输入/8列结果不能混入。原保存LN/Q/W流只作checker，不能冒充producer；真实W从q0/q1/scale/AUX AXI冷装入。检查全167936个提交PS及5248最终F32。冷正常＋无reset暖反压完整命令验证实际数据和warm零额外AR；受影响短例验证RRESP失败、W读错→abort、预留/FP在途排空、同拍abort优先及恢复。若缺独立LN统计，仅用原已核单行参考补三统计并与旧1024值gold逐位复核，禁止全模型前向/改原gold。

先在原修订8预算结束当前普通Tcl修复/同版物理测量，再串行跑修订9重工具；可先做源码准备。修订8普通工具修复最新决定覆盖旧3/3停点，累计1800s不重置；不要因当前时序仍未知而重新请求本连接普通实现批准。

修订9新预算：host300s/8GiB；static1800s、单次600s/24GiB；RTL含pilot1800s、单次900s/8GiB/1Mcycle，pilot≤120s且先以真实prefix估完整冷/暖成本。CPU0–3/nice19/idle、MemAvailable>192GiB、单重工具保持。普通实现/TB/脚本修复连续执行，不设逐次启动审批；真实成本停止或实质数值/接口问题再集中交付。本段不做新联合OOC/P&R/全图前向/新agent，不转移修订8成本。

A002在唯一E002现有模块目录实施，复用设计/结果记录，阶段末集中交付同版真实数据链与限制。A003本次静态设计已接纳并收束，只更新现有文档中的采纳/未测边界，不另开实验。下一目标仍是将这条真实链继续接G/Down及完整固定图，不把单行Wi当完整推理通过。
