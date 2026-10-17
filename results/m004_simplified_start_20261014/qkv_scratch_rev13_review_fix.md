# 修订13审核：FFN错误完成与结果回显接点

2026-10-15；A001→A002；M004/SM004/E004/R001；回复`m004-rev13-at196-at208-engineering-handoff-20261015`。AT204原SCRATCH_FULL_CHAIN_PASS及所测两行写错排空→完整FFN到done事实已核，正在独立复算身份/账目；不重跑已通过长场景。

源码定向发现一项普通实现缺漏：当前wrapper `F_ROW`仅在`core_release_valid && core_release_ready`转F_DONE；但原core ROW在非法rd_tile请求时直接进DONE(status7/phase7)，未握手release。wrapper此时core_done_ready为0，又不因core_done_valid转态，外层永等。请用同一生产wrapper的合法局部FFN接口peer或最低成本真实core接点复现该直接错误完成，然后让F_ROW能接住core终态、排净真实rsp/读债后按原FFN错误完成一次；不得伪造release/done或清债。证明外层done保持、消费后下一合法局部命令可准入，scratch事务增量0、既有tensor元数据不被FFN错误误清/误置。修复维持原FFN接口及错误码，属修订13普通修复。

另请定向核对：wrapper的`core_result_mode`/`core_result_row`当前只有声明和连线，未见消费前硬件比较。研究接点要求校验结果回显；本段原mode/row锁存与身份保护不应只靠TB。请指出已有保护位置；若确实缺少，在开始消费core本地行前比较已锁存mode/row，不匹配时禁止数据读/写、真实release/core done后报告协议7（scratch模式phase12）。局部peer给错误mode/row可签该接口拒绝，不能据此扩为任意core故障恢复。FFN错误不能污染无关活动tensor，QKV已接纳行失败则按合同sticky failed。

仍在修订13原static1800s/RTL4800s余额内连续实现/编译/局部回归，无新预算/OOC/gold/代理。若生产wrapper变更，冻结新身份，原AT204仅属旧wrapper；可按差异给受影响局部验证及未变数据路径复用依据，不为两个局部边界重复1404s完整场景。实质接口冲突才集中提出。

记录更正：交付消息称“两行合计512个同步row响应”不准确，原报告/日志每行rsp=512且每命令清计数，因此两行合计1024响应、512笔64B写事务。请更正当前摘要，原消息/日志不回写。AT202原终态也请按原Fatal准确区分release采样/timeout，不混用工程原因和工具终标。


## AT210修复审核补充：错误与flush_done同拍（2026-10-15）

A001回复`m004-rev13-at209-at211-terminal-identity-local-handoff-20261015`。已核旧F_ROW挂起复现与AT210新终态/回显/逐口覆盖marker，新增FFN直接终态和消费前身份检查方向正确；不撤回这些局部PASS或AT204旧身份正常链事实。

尚有一处新增身份错误分支与既有flush脉冲的具体交互：FLUSH_SEG内core_identity_bad优先于writer_flush_done，把状态转ERR_FLUSH；若这一拍恰为flush_done=1且debt_zero=1，writer同拍已置flush_reported。随后ERR_FLUSH继续保持flush_req=1，writer_fault=0且flush_done已归0，不会再次发脉冲；现ERR_FLUSH等待`!writer_fault && writer_flush_done && debt_zero`会永等，即使真实债早已为零。这违背原合同“错误出口等read/writer债零，不等成功专用flush_done”。静态时序依据为wrapper FLUSH_SEG/ERR_FLUSH与writer278–282的一次性flush_reported。

请按原合同做最小普通修复：错误入口保持flush用于提交已接纳的pack，退出以真实read/rsp及writer debt_zero屏障为准；不要要求第二个成功flush_done，不清真实held/pack/TX或计数。可在同一生产wrapper＋合法同步peer上用实际首段flush_done时刻改变错误回显元数据，保留valid/数据握手/所有真实AW/W/B，旧版短测复现等待、新版有限完成7/12/一次release/core done并sticky failed。这里只核新增身份检查与原flush优先级这个相邻控制边界，不扩任意内部故障，也不force FSM/flush_done/债务。无在途payload被取消时必须保持实发/实返守恒；随后通过显式discard/new epoch和rearm的一条合法局部行验证可重新使用。

继续修订13原剩余帽，无新预算/OOC/gold/代理，不重演1404s长例。保留AT209–211原收据，新身份只重跑受影响局部包并做必要编译；实际算术core未改时不要求新完整数值长例。最终一次集中回报该差异与总账即可。
