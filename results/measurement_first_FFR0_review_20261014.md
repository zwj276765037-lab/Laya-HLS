# FFR0集中审核：正常局部结果接纳，错误语义与保护尚未闭合

2026-10-14；A001→A002；M004/SM005/E005/R001；R-SM005-FFR0-20261014。回复`measurement-first-FFR0-AT053-scoped-result-20261014`，合并`measurement-first-FFR0-status-progress-answer-20261014`。主控只读审核文件、冻结源码及原日志，未运行新参考或DUT。

## 审核结论

**接纳AT053正常四行数值/真实AXI/局部完成的有限结果及AT052同SHA槽52例；FFR0合同整体未闭合。** 工程原`PASS_SCOPED_NORMAL_FOUR_ROWS`收据按原样保留，不把它扩大为错误语义、停滞保护或完整计量均通过。两源仍为TB预装的AT050外部skip/Down，未与AT049同runtime，也非生产双源hub lease。

[主控核验](measurement_first_FFR0_review_20261014/verification.json)核两manifest共28项引用、74个不同证据路径；两版各14项逐bytes/SHA吻合。AT051七个部分冻结文件到AT052仅runner改变，另加入正确helper；AT052→AT053仅联合TB改变，但差异包含标签隔离、AXI保持/提前发布断言和数值拒绝探针，不能窄称只改标签。原准备修正与联合TB修正已用尽两轮，旧FFR0不再续版。

全部六段guard串行，142条实际CPU0–3/nice19/idle policy匹配；其中当前复用槽和AT053三段为95条。内存/墙钟/CPU证据合规，**语义停滞规则有静态反例，不能据无trigger就签它符合合同**。AT053 static/pilot/full为22.174020/26.307417/26.989242s，full峰1376640KiB。原单行25903cycle/26.307417s乘四再乘10的准入1036120cycle/1052.296675s已复算，成本决定先于full，属于准入估计。

## 已达到的正常边界

skip与Down分别真实256 AR/R；一个未改生成的F32叶子接受/返回4096项；另一HIDDEN bank256 AW/W/B，16384B结果逐bit同AT050独立gold。三个64KiB共196608B终扫验证源不变、目的gold/written和邻接哨兵。末W103325、末B103340、首次成功响应103341、实际消费103349，终扫打印点103350；后续错误探针仍执行至$finish，因此103350不是整个TB最终结束，也不是cfg→消费延迟。正常七拍响应保持与一次消费通过。

AT052同槽52例accepted=returned=consumed52，signed zero/抵消/次正规原fixture逐位通过、输出保持及idle reset检查成立；生成叶子和槽在AT053保持同SHA。正常数据和局部backpressure结论保留；不签全IEEE、忙时reset或生产恢复。

## 需要纠正的三项

1. 原`include/laya_types.h:8`定义E_NUMERICAL6/E_PROTOCOL7/E_INTERNAL8，无9。冻结DUT把数值错误设为8、AXI错误为9，TB跟随期待8；实际编译闭包没有转换层，工程已确认。两原NaN/有限溢出探针只证明**本地拒绝且零新增写**，不是生产错误码通过。正常status0/gold证据独立保留，AXI错误9未动态测试。
2. 联合TB每20000cycle且任一历史source R非零即打印`FFR0_PROGRESS`，guard只匹配前缀续120s watchdog。首R后所有读/加/B计数停滞而clock仍运行的反例可持续续命。原full五条计数均真实递增（R50/99/149/199/248，add790/1584/2376/3170/3964，B49/98/148/198/247），故不把该次自然PASS改判死锁；后继须修真实进展判定，状态快照不能续命。
3. 原log没有完整cfg受理、两端首末AR/R、源锁/目标有效精确边沿、逐项add延迟分布及互斥状态周期。源码可解释局部锁在末Down R后释放、目标在末B后有效，不能补写未测边沿。`cfg_context`还是不透明416bit回显，标量身份子集另校验，不签完整生产Context。

## 后继集中决定

下达 **D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01 / FFR1**，详见[受影响修正合同](../mission/ffn_residual_status_measurement_stage_20261014.md)。保持原叶子、结果槽、gold、正常搬运/响应profile和地址；数值错误改6，局部合法AXI非OK映射E_INTERNAL8，并分别做原数值拒绝及首skip R/Down R/B非OK定向回归。B错误可能已写一个拍，须保留已写事实，不能冒称零写。原五个局部描述符拒绝保留；不扩通用恢复或生产hub。

新TB/guard只让实际握手/返回计数推进续命，受控host时间序列验证重复计数/周期心跳/状态快照不能续命；模拟阶段不沿用宽泛“completed”等文本。补齐正常cfg、AXI首末边沿、局部锁/有效位、4096项加法延迟分布、互斥周期求和，正常与探针分开计量。未变52例按完整身份复用，不再跑。

一个修正方案、full前最多一次有因准备/封装修正；static/短错误回归/≤120s单行pilot和本次有据成本后，**最多一次新四行full**，失败即集中交付，不追加full。当前FFR1 NOT_RUN。普通实现与修正自主连续执行，无逐项用户审批；工程不启动LN长链。

E005三摘要/模块结果须体现上述范围和缺口；A002已按实际AT053终态更新报告，主控不代写工程状态。AT049限定链PASS、AT047 FAIL、AT048 COST_STOP与AT050主机结果保持原样。所有原帽、单重工具、无新HLS/OOC/P&R/上板、整体控制停排、G仅OOC余额2338.224019s及5172s不重启保持。真正同runtime末残差、双生产源lease、普通多窗口、全模型/13BO请求恢复、联合资源/时序与M003/M004开放。

证据入口：[工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR0_four_row_residual_rtl_20261014.md)、[AT053原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/receipt.json)、[原full日志](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/guard_full/driver.log)、[审核问答](../.research-agent/communications/measurement-first-FFR0-status-progress-answer-20261014.json)。
