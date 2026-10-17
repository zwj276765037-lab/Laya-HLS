# FFN1 阶段交付：前缀封装耗尽120秒，full未准入

回复 `measurement-first-FFN0-review-FFN1-dispatch-20261014`，合并固定末目的入口澄清。A002→A001；M004/SM005/E005/R001；AT058/AT059。工程已停本合同新工具；请主控按[完整停止报告](FFN1_bounded_prefix_preparation_stop_20261014.md)集中审核。

结论建议 **COST_NOT_ADMITTED_INVALID_PREFIX_LAUNCH**：AT059 pilot guard120.435s/峰2974840KiB、child−9/timeout，ROM staging已做，但实际runtime preflight和xsim未启动，故无新LN源AR/R或迭代前缀、无新全链行为。错误是本轮runner让pilot重新冷编译/elaborate（后者95s），而旧AT057 prefix在static snapshot上直接启动xsim。新四行full `admit=false`、未启动；原一次有因准备修正已用于AT058微测试保留字`edge`→AT059 `tick`，本合同不再自行追加launcher修正/pilot/full。

保留的局部证据：AT058 static PASS；同SHA适配器合法对照及九项新增冷负例PASS，固定末HIDDEN目的等待/接受时编码一致；AT057同SHA residual wrapper的bank0与STATE0两个错目的descriptor均E_PROTOCOL7且零物理AR/AW/W，合法descriptor进入真实skip 1 AR/1 R后由故意RRESP错有界结束。AT059观察器35分项独立及三W R同拍微测PASS，实际微测打印经生产parser/逻辑时间12例PASS，旧AT057 52条W日志只读候选累计逐条增长。两manifest各336引用/334路径逐bytes/SHA一致；六guard共147条真实policy均合规。AT058微测原编译失败保留，短测退休事实由TB注入，不能代签全链。

下一合同如选直接xsim有据回放，可复用已编译snapshot，但需先冻结真实命令、cwd、7 ROM、63 fixture/11 plusarg（FIXTURE与LN_FIXTURE同源），逐次verify-only并保存缺失/坏SHA启动前拒绝，再单独≤120s冷xsim前缀。此为**建议的受影响启动路线，尚未执行**；必须先取得新前缀速率与后段保守成本，才可另判一次full是否准入。旧AT057/AT049/AT054范围不扩大；M003/M004开放、全部资源帽和生产控制停排保持。

证据：[AT059收据](../attempts/AT059_FFN1_progress_replay_02/receipt.json)、[原pilot日志](../attempts/AT059_FFN1_progress_replay_02/guard_pilot/driver.log)、[触发快照](../attempts/AT059_FFN1_progress_replay_02/guard_pilot/guard_trigger.json)、[成本不准入](../attempts/AT059_FFN1_progress_replay_02/full_cost_decision.json)、[身份/guard核对](../attempts/AT059_FFN1_progress_replay_02/verification.json)、[AT058原失败及短测](../attempts/AT058_FFN1_progress_replay_01/receipt.json)。
