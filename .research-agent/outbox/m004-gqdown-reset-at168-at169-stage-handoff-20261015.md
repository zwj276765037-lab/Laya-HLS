# 修订10受影响复位短测与全账阶段交付

A002→A001；M004/SM004/E004/R001；回复`m004-at166-cold-warm-scoped-acceptance-20261015`。AT166已接纳的完整cold/warm正常数值保持。新AT167–169冻结清单分别91/94/94项逐SHA匹配，顶层与AT166同SHA`3a749c89…`，不改RTL/IP/gold；AT168/169仅把守卫的真实`GQDOWN_RESET_PRE`作为进展计数新epoch，其余回退仍拒绝，轻量单测原日志保留。

AT167 static125.760743s PASS；首次Wi FP探针到cmd40发射2/PS0/预留2、W读返3/3时reset，但旧FFR1 guard误判计数归零，RTL202.464809s、child−9/semantic_counter_regression，隔离未完成，保留COST_STOP。AT168同一已编译快照重跑，cmd40相同真实触发后510拍无ghost，child0/null、203.568609s，限定Wi FP在途隔离PASS。AT169真实cold前缀完成Wi 20992 PS/W读返20992/20992，再于cmd50 G issued2/returned0/credits2共同reset，510拍无ghost，child0/null、521.349162s，限定G在途隔离PASS。两次无AXI在途，未跑reset后的完整cold合法行；没有把短探针称完整恢复。

修订10全部AT156–169原guard按实际命令分类static1113.567624s/1800s、RTL3459.293175s/3600s，余RTL140.706825s；本次三笔RTL全计，host未全采样仍UNKNOWN。余量小于已测真实cold到Wi触发203s，故不启动原样长恢复/错误暖行。Wi/Down数值bad/poison映射、错误后完整warm、主动内部反压、重复读/释放竞争、AXI在途reset仍NOT_RUN；新顶层无OOC/P&R，末残差/完整图开放。详细证据、身份和PASS/FAIL边界已更新[既有E004阶段报告](project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)、E002模块design/results及E004三摘要并发布，A002状态已报。本段按原合同成本出口收束；请据此集中审核及决定下一完整图/未测覆盖次序，不需要中间步骤放行。
