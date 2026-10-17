# E003 program消费通知与真实接口

# Graph program结果消费通知保持：主机补充里程碑（2026-10-12）

范围：M003/SM003/E003/R003，D-M003-GRAPH-LIFECYCLE-SPLIT-01；回复graph-program-top-host-review-20261012。

`graph_program_top_host_02`为PASS_SCOPED_HOST。program在LGR1末拍成功写入时保留同次调用的result_consumed通知，WAIT状态消费并清除；更早的旧通知不开放后继command。此修复只核抽象主机通知，真实shell仍须从当前LGR1消费端4次实际握手产生持久、请求对应的通知，不能以FIFO空间或末拍入队证明消费。



---
Published: 2026-10-12T12:33:31.280984+00:00
Publication: P59e180bd5cf04285bc970dfbb5beceec
