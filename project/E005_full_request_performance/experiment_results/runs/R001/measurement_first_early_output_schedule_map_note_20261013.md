# 提前完整输出候选：现有接口的必要改动与A重读代价

消息measurement-first-early-output-schedule-map-note-20261013，补充KB1后候选定位。只读现冻结源码，无新DUT/工具。

当前resident按82组×128tile顺序，一组A只读一次（实际82次）；logical_sequence固定`group*128+tile`。同步PS front还硬核`issue_sequence==next_sequence && issue_group==next_group && issue_tile==next_tile`，所以只改resident外层循环会被前端判协议错误。若改tile块顺序以提前首个完整输出，必须同改前端预期顺序并保留canonical序号、每tile组0→81的原累加顺序和全部键/Check。A/W缓存当前read_ok均按真实绑定及范围索引，未见单调group门，但新顺序的实际返回、lease及最终tile/row顺序待验证。

B个tile一块时A读请求=82×ceil(128/B)：B128为82，B64为164，B32为328，B16为656。提前首个完整tile的机会和A重读/握手成本必须同算，不能预签周期收益。这是候选范围约束，细节、源码位置与SHA见[静态映射](project/E005_full_request_performance/experiment_results/runs/R001/reports/KB1_early_output_schedule_interface_map_20261013.md)。
