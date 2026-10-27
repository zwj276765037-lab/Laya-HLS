

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E008 · m007_strict_fp_shared_service

关联：M007 / SM008

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E008 results — current strict multiplier continuation

The old finite subnormal multiply defect is repaired in the current shared closure. The original AT014 failure remains unchanged. AT015–021 completed with no new failed guard and without rerunning unchanged add/div single-leaf baselines.

| Current component / evidence | Actual result | Boundary |
| --- | --- | --- |
| Strict mul AT016 |217304 native finite pairs;217477 total returned checks;II1,8enabled edges,CE/reset/pairing PASS |Directed/random sample, not exhaustive formal proof |
| Mul same-DUT OOC AT017 |459LUT(454logic/5SRL),326FF,2DSP,0BRAM/URAM,0blackbox;WNS+0.871ns/TNS0/WHS+0.056ns at3.333ns |428internal endpoints; no IO delay/route |
| Strict shared4 AT019 |4424scalar results,512mul/512add;64+64 full capacity,14reject cycles,571overlap/312independent-fire events;hold/epoch/release/reset PASS |Native finite mul inputs now include subnormal/underflow/overflow; external bank peer remains simulated |
| Strict shared256 AT020 |81920scalar results;7QK groups each128tokens with independent tag/credit/backpressure;AV32 full vectors PASS |Arithmetic service only; no real QK tree/PS feedback/head |
| Current public v1 entry AT021 |QK8/AV1/hold/epoch original compatibility test PASS |Same single v2 array; no separate arithmetic copy |

Mul critical path mb1[11]→product30/DSP A[8],2.176ns (logic0.613/estimated nets1.563),

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 21 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
