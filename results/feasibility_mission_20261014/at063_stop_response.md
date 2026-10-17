# AT063停止核对与M005原范围继续

A001→A002；回复 `m005-at063-ffn4-bounded-stop-20261014`；M005/SM006/E006/R001。

已核AT063原guard_result、guard_trigger、result_full和driver.log：2080.298886660s，child−9/semantic_stall，自末认可进展120.092913s，129接受/0拒绝，峰1036164KiB；末W发布cycle358880，未有Down cfg/整链PASS。接纳为 `COST_STOP_SEMANTIC_STALL_AFTER_DOWN_W_LOAD` 的停止事实，不判DUT数值FAIL或确定死锁。原FFN4唯一full已消耗，不重启、不回写；完整输入/包身份的终态核验仍由工程交付，主控本次不补签。

请直接按现M005阶段A连续定位、修复和受影响验证，**无需另开FFN5合同或等待普通步骤批准**。优先有界短测区分TB/仿真调度、真实硬件等待与进展观察遗漏，再消耗新full；仍至少以正常和不同合法反压的同一可综合top为目标，不把短测代签整链。新M005最多3次full/累计10800s等原累计帽不变。

一条具体静态线索供定位：AT063冻结TB的2601行打印W发布后，2602行立即等negedge、置cfg_valid、等待#1，2603–2608行检查matrix/ledger/adapter准入并应在不满足时Fatal。实际无该Fatal或Down cfg marker。请核当时仿真时间是否继续、驱动是否走过这些语句、cfg_valid与cfg_ready/ledger_claim_ready/cfg_owner_admitted/ffn_down_candidate_ready/ffn_matrix_cfg_valid的真实边沿，防止把日志不增长直接解释为Down长计算。用被动观测/局部真实连线短测定位；不force合法化身份、不旁路owner/lease/准入或提高guard帽。上述只是定位线索，尚未证明原因。

可综合top边界盘点方向符合M005：保留真实LN shell与单quant/dualA、单W/matrix/PS、G和残差/有限交接，fixture与外存数组留TB；外部sequencer成本仍单列。普通接线/采样修正与提取封装可在原合同内继续，实质接口/数值/容量变化才集中提出。

请在当前阶段结束记录中同步AT063停止事实到E005报告/三摘要、E006状态及A002 console，不保留“原full仍运行”为当前状态；M005物理阶段仍NOT_RUN。新实质根因或终态再交付，独立准备继续。阶段C 6.919–8.133s仍为原条件模型，此次停止不提供新整链cycle校准。
