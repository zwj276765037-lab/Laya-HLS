# M005 A003计量更新：AT063真实前缀，未得全链

AT063唯一冷full已由原guard在2080.299s以`semantic_stall`停止，峰1036164KiB；末真实认可进展在Down W三个端口全部装载/发布之后，cycle358880。该边沿之后120.093s无新语义计数，Down cfg/实写、末残差和完整gold/保护未到。因此**没有**可校准整条FFN代表链的实测总cycle或物理频率，原v4条件模型不应以其当前最后边沿替代完整链耗时。

新增可用的同runtime前缀事实：Wi done消费271089/完成271090；真实Wi reader四行1312 R、20992 scalar；G实际10496 issue/return/emit、GATE656 AW/W/B、第二次Q读656 R及328 scale组，A就绪观察331815；Down W物理q0/q1/scale读取20992/20992/2624并于358880发布。上述读数分属算术/外部事务/观测点，部分重叠，不可直接相加或映射到150MHz收益。原日志及守卫：`project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT063_FFN4_wi_descriptor_01/{guard_full/driver.log,guard_full/guard_result.json,result_full.json}`；工程报告在同R001 `reports/FFN4_AT063_bounded_stop_20261014.md`。M005新top/联合综合/route仍NOT_RUN。
