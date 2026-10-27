

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E009 · m007_host_tail_contract

关联：M007 / SM009

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# NATIVE-CPU-03 / R002 completed: native function PASS, performance FAIL

execution_state: completed
verdict: PASS_SCOPED_NATIVE_CPU_SESSION / FAIL_SAMPLED_LIMITS

Final version AT022/023 passed156 checks, including both frozen requests' complete
H0/13 tail stages/rawCLS/final18 bit equality,4 original JSON baselines,42 original
decode vectors, VNNI signed limits, full/lazy cache equality, reload, binding and
output/fenv/affinity error recovery. Counts are checks, not independent whole-model
requests. [Final evidence](experiment_results/runs/R002/release_evidence_v4.json) and
[handoff](experiment_results/runs/R002/native_cpu03_handoff.md) freeze binary/source/libm/inputs.

AT025 full-mode production wrapper:200 warm requests, plus2 first requests and32
new-word requests (234 complete calls total). Input includes internal JSON/BPE,
recipe, binding/validation, H0 allocation/copy and sync; tail includes business decode.

| Final cohort | Input median / P95 / max (ms) | Tail median / P95 / max (ms) | Violations input / tail |
| --- | --- | --- | --- |
| Full warm n200 |0.498548 /0.588732 /0.666537 |1.912646 /2.080202 /2.726395 |0/200,6/200 |
| Full new words n32, all model-token cache hits |0.476758 /0.494244 /0.495972 |1.901414 /1.925048 /1.933525 |0/32,0/32 |
| Lazy true new-token n32 (AT026) |0.542792 /0.594254 /0.601589 |1.862338 /1.900331 /1.901052 |0/32,0/32 |

Full first input1141907ns/913050ns exceeds750000ns, 

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 23 |
| R002 | [本批结果与证据](experiment_results/runs/R002/README.md) | 27 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
