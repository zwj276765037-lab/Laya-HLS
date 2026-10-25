

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E015 / R003 运行结果

[负责人维护的本批运行记录](run.md)

# E015/R003 D31 final bounded delivery

Execution completed; supported for exact source and original-fixture same-runtime equivalence plus observed single-snapshot local cost. A001 scope review pending. A008 runtime /root/m007_host_tail_engineering; desired gpt-6.1-sol/xhigh, actual configuration UNKNOWN. New v3 only, old v1/v2/D26 R002/D28 E020/parent/shared dependencies untouched.

| Attempt | Phase | Result | Child wall seconds |
|---|---|---|---:|
| AT001_eq_build | static | per-target audit and real v2/v3 snapshot PASS | 14.34901304898085 |
| AT002_eq_rtl | RTL | same-runtime all original output/node/protocol checks PASS | 14.15276184398681 |
| AT003_v2_build | static | one actual v2 TANH8 snapshot PASS | 11.839297086989973 |
| AT004_v2_cost | RTL | complete frozen workload/checkers PASS | 9.684000001987442 |
| AT005_v3_build | static | one actual v3 TANH8 snapshot PASS | 8.407813775003888 |
| AT006_v3_cost | RTL | identical complete workload/checkers PASS | 9.183186706970446 |

Source audit:2447same-clock unique NBA targets/processes→1process, identical per-target conditions/RHS/data order/declarations/functions/module nodes/42leafs,valid_pipe reset outsideCE/data no newreset

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_eq_build](attempts/AT001_eq_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT001_eq_build/receipt.json) |
| [AT002_eq_rtl](attempts/AT002_eq_rtl) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT002_eq_rtl/receipt.json) |
| [AT003_v2_build](attempts/AT003_v2_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT003_v2_build/receipt.json) |
| [AT004_v2_cost](attempts/AT004_v2_cost) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT004_v2_cost/receipt.json) |
| [AT005_v3_build](attempts/AT005_v3_build) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT005_v3_build/receipt.json) |
| [AT006_v3_cost](attempts/AT006_v3_cost) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT006_v3_cost/receipt.json) |

## 本批问题与交付文件


## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
