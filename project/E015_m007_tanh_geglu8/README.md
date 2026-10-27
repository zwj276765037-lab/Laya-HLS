

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E015 · m007_tanh_geglu8

关联：M007 / SM011

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E015 R003 results summary

Source audit and all 6 static/RTL attempts PASS. Actual same-runtime v2/v3 each checks 6726outputs/282812 nodes;841 core152/public153/II1 and all held/reset/newgen/credit/reject/debt assertions pass. Eq and both singles have identical 2671cycles/841 actual response trace lines, SHA55827849…. Old v1/v2 unchanged.

Single-snapshot xsim total9.188027718→8.694883177s (1.056716638x),active+protocol2.899840288→2.516007214s,explicit448-cycle idle0.141459022→0.019675719s;startup/fixtureinit essentially unchanged. One sample each; local observed cost only, no joint/FPGA speedup or LN128 gate reopening. All6archives19files each and3×24originalsnapshotfiles verified;4714owned policy samples/0corrections, all cleanup empty.

Evidence:[delivery](experiment_results/runs/R003/independent_delivery_v1.json),[source manifest](experiment_results/runs/R003/production_manifest_v1.json),[cost comparison](experiment_results/runs/R003/standalone_cost_comparison_v1.json),[budget](experiment_results/runs/R003/budget_closure_v1.json),[run](experiment_results/runs/R003/run.md). Reference/OOC0;static34.596123910974711s/RTL33.019948552944698s. Prior accepted R002 CE26 remains frozen and separately applicable.

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 148 |
| R002 | [本批结果与证据](experiment_results/runs/R002/README.md) | 2 |
| R003 | [本批结果与证据](experiment_results/runs/R003/README.md) | 6 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
