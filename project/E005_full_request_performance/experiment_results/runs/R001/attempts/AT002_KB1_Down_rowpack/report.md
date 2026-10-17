# AT002：KB1 Down四row合并写

Execution state: completed
Verdict: supported（仅所测normal有限算术样本）

static/pilot/full实际PASS；full431.227749s，peak1426732KiB，child0/trigger null。真实4096F32、335872lane-group PS及512TN8 packet全gold保持；实际256 AW/W/B、最后B/局部publication及一次done消费通过。

cfg→first done16183cycles，cfg→真实consume16190，全TB43947；对KB0分别减少23.3033%、23.2956%、10.0626%。A/W加载666/27064cycles不变；同AXI response profile及原7cycle done反压。物理W字节32768→16384，有效字节均16384。

仅writer一项源码改变，全部fixture/native IP及TB/guard身份相同。1923bits额外字段，物理资源/时序UNKNOWN；两个继承writer错误窗口未动态测量，不能代签生产恢复/完整请求。详见[集中比较](../../reports/KB0_KB1_Down_comparison_20261013.md)、[原始收据](evidence/measurement/receipt.json)。
