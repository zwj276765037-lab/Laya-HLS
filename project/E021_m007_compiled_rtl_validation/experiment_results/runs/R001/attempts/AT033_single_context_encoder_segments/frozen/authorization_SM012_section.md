### D33 单线程完整 Encoder 分段探索（2026-10-23，增量112后）

AT031/032四线程在相同原数据上进入softmax数值错误，保持FAIL并停用该配置推进；未证根因不改生产算术/TB/gold。回到AT028/029已验model1/context1、fixed-batch-v1/converge512的同172d TB与93生产依赖；不带入四线程诊断main，不重新构建生产模型。原AT027默认context的120s全局pilot保持COST_STOP，不改旧收据。

A012在原E021/R001预算内，直接实现同一进程的事件分段保护并运行一次kind5/packed0/allSTOP0正常Encoder探索。全局guard上限800s，所有连续阶段各≤120s，真实语义停滞120s/8GiB/40Mcycles/单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB保持，开始前RTL余额必须≥1100s以保留300s。这是已测QKV与head服务后续的有界路径探索，不声称已知完整层成本或保证800s完成，不把120s旧失败原样延帽。

连续阶段从child启动→MATRIX_END phase0；phase0结束→HEAD_END0（含RoPE/交接）；各HEAD_END前一head→下一head；HEAD_END15→ATTENTION_END；ATTENTION_END→MATRIX_END phase1（含layer idle、context4096、quant/A发布、WO全部与交接）；phase1结束→VECTOR_END phase0；VECTOR_END0→LN_END；LN_END→MATRIX_BEGIN phase3（包含Wi/G/quant重叠和全部成功屏障，不漏中间等待）；MATRIX_BEGIN3→MATRIX_END3；MATRIX_END3→VECTOR_END1；VECTOR_END1→原COMPLETE_PASS/正常进程退出。按A010 encoder_stage_route_source_review.json映射精确日志；各BEGIN仅作细分观察，不重置已定义连续段或遗漏成本。事件缺失/乱序须明确失败，不能任意进展日志重置阶段计时器；尾部capture写完及进程清理计入总费用。

driver先以原A029/AT027事件流验证状态推进/乱序拒绝，再对实际stdout monotonic逐事件记cycle/wall。普通runner修复不需新审批；static≤20s、无fresh模型编译。任意段/总帽触发即保留COST_STOP及实际前缀，无公开跳转/恢复入口，不预装中间结果。原全部数值、最大值、握手、身份、周期、最终输出、held DONE/返回idle断言保留；完整终标与实际独立gold全部成立才签完整Encoder。该次通过也不能代签原kind7一次BEGIN 30层。预算不足或新数值失败即报告确切边界，普通修复继续现授权范围。
