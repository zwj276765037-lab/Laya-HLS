

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E011 · m007_weight_supply

关联：M007 / SM010

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E011 / SM010 first supply segment results

execution_state: completed
verdict: supported for byte packing, local functional/service RTL and independent small-module capacity synthesis
applicability: M007-W576-v1 final RTL closure frozen AT015/AT016; complete SM010/M007 remains open

The pure-byte [AT001 packer](experiment_results/runs/R001/attempts/AT001_four_superblock_pack/work/fixtures/packing_report.json) inverts596224B original source bytes and independently compares old TN8 q0/q1/scale BO addresses. Four complete selected superblocks contain1096 distinct544B records. Complete model/tensor SHA identities are inherited from the frozen manifest; selected source/output windows are newly hashed. This is not the complete120tensor package.

[AT016 final RTL log](experiment_results/runs/R001/attempts/AT016_public_read_rate_rtl/guard/driver.log), [receipt](experiment_results/runs/R001/attempts/AT016_public_read_rate_rtl/receipt.json), [source/fixture/version boundary](experiment_results/runs/R001/current_version_evidence.json):

| Original tensor / superblock | Read bytes | Actual cycles / cap | AR per port | R per port |
|---|---:|---:|---:|---:|
|qkv.0 / s0,K1024|73728|735 /1024|18 each|288 each|
|mlp_wi.0 / s81,K1024|73728|735 /1024|18 each|288 each|
|mlp_wo.0 / s0,K2624|188928|1633 /2224|47 each|738 each|
|head_fc2.0 / s0,K4096|294912|2456 /3328|72 each|1152 each|

All four ports reach8 real accepted unfinished bursts. Peer eligibility40+2*(7−ID) cy

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 16 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
