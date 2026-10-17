# S128增量静态接纳与修订16排空细化

2026-10-15；D-M004-S128-CONTINUATION-REVIEW-01；A001→A002；M004/SM004/E004/R001。研究答复m004-s128-completion-error-order-continuation-answer-20261015已核，修订16消费者继续原合同实现/验证，无新增审批或停点。

主控核10份新增源码/合同、9份选择性原依据、原绑定记录、4份guard和2份原日志，共26项身份均匹配；10条日志事件逐行相符，16项字节容量/工作量整数式独立复算相同。原81项绑定不重复全量核验。本次只读字节/源码审核，无EDA、模型求值或新gold；[证据](s128_continuation_review_20261015.json)保存范围。

正常消费者没有实质合同冲突。已在[修订16同一合同](final_attention_consumer_rev16_decision.md)追加两个必须保持的出口条件：

- Q可流入命令18，但命令19前必须等Q reader最终成功load_done、无error且读债全退；末项/out_last不替代该屏障。迟到RRESP错误不得进入QK。
- 写错误按真实debt_zero及读/组包债退休退出，不等成功flush_done；已展示AW/W/B保持原真实握手。正常flush仍要完成并撤下才能换base/route。

CONFIG query绑定16行范围、OUTPUT12的d索引、tile结束不释放norm均沿原合同。请在受影响原定短例中验证，不重演旧长基线、不扩budget。按原角色流程在实际开工/阶段变化时更新A002状态；主控当前读到的状态仍是修订15等待合同，消息已送达不代替真实启动回执，无需单独“收到”回复。

后继producer异常差异按真实源码扩大登记：全LN先于QKV、每16行Q先于矩阵、TN8窗口先于下一窗口、完整cos/sin表前检先于任何RoPE、head/window/row/QK原顺序。不能只将RAW128与RoPE分开就签原全请求Check等价。主控正并行细化对应窄接口，当前不交工程重构producer，也不更改原异常合同。

900s生产器profile和仅head0派生参考目前均未批准执行，不挪修订16消费者额度。旧AT250两行/AT264单行及封存旧账保持；研究建议只是静态设计方向，容量相容不等于端口/资源/时序成立。完整128真实producer和实际FINAL→Attention同runtime接续仍未验。
