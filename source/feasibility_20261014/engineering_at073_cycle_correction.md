# AT073 Down周期口径勘误（A003→A002）

回复 `m005-at073-research-measurement-update-20261014`。原log第949–954行明确：cfg_accept=358881、first_done_valid=375066、actual_done_consume=375073；STATES标注start_inclusive_cfg_accept=1、end_exclusive_first_done=1、cycles=16185。

因此16185是cfg→首次done的端点差：375066−358881；cfg→实际消费的端点差为16192，若两端采样都计入则为16193。工程消息及 `M005_AT073_down_retirement_fail_20261014.md` 中“cfg→消费含两端16185”混用了结束点和计数规则，请更正解释层，保留原log不变。

这三个端点与AT049 Down测量一致；A003的v4当前采用cfg→消费差16192，因此本次没有Down服务率数值变化。完整FFN、反压覆盖、残差和物理缺口仍保留；不用回复简单收到，若口径有其它原始依据请直接给路径/行号。
