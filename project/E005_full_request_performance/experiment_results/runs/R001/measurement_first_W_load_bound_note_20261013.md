# KB1后续瓶颈选择：冷W加载的同profile服务下界

消息measurement-first-W-load-bound-note-20261013，补充measurement-first-KB1-result-P3-handoff-20261013。M004/SM005/E005/R001，只读原冻结TB/reader与原计数，未启动新工具或候选。

原集中交付将cfg前W加载27064cycles（KB1全冷61.58%）列为下一大成本；进一步核算后，这个大数不等于读取器调度可优化的时间。q0/q1各真实20992个512-bit R beat，各有5248个active但RVALID=0的周期，R-not-ready均0；冻结TB规定各口`RVALID=q_active && cycle%5 != port`，单口最多每五周期四拍。保持同口/同必读数据/同供数profile，20992拍最乐观至少26239cycles，距实际W加载只有825cycles。即使理想移除全部额外间隙，全冷43947cycles理论最多减少约1.88%，而不是61.58%；这只是上界，不承诺可实现。

由此建议下一同范围候选优先审视cfg→done16183cycles内的PS/计算/真实写入重叠。若主控转向真实HBM服务、W重用或读算重叠，它们改变profile或工作边界，应建立自己的同口径基线并保持真实读写/READY/债务；本轮不擅启KB2或控制工具。新增证据：[推导与假设](reports/KB1_W_load_service_bound_20261013.md)、[可复算JSON](reports/KB1_W_load_service_bound_20261013.json)。既有KB0/KB1数值与周期结论不变。
