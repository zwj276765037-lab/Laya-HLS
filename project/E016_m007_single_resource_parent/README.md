

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E016 · m007_single_resource_parent

关联：M007 / SM012

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E016 D37 actual complete original30 PASS

A012 E021/R005 AT002 `FIXED_ORIGINAL30_ONCE_BEGIN` passed with parameter0/original initial_H in one runtime and one BEGIN: guard wall **10101.230974940 s**, **13036119 cycles**, normal rc0. Original counts passed:30 layers,120 matrices,480 heads,60 LN,61 VECTOR,28 GEGLU,544 output groups/69632 B,actual tail_commit1,held DONE consumed and real idle.

All30 actual H endpoints/unique accepted traces and final-LN/type were independently checked by the controller against original gold; full-size endpoints each contain131072 F32 words/524288 B. Tail bytes match the original expected544-group mapping, SHA `a8698e55921b0300643a01f63bb38abc52e026af7251b526f02bddfbd6d9536f`. [Authoritative RTL receipt](../E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT002_fixed_original30_kind7/receipt_rtl.json). Parent `9d877217...` and TB `2bd73c51...` are unchanged from D36.

This actual run now validates the repaired complete normal path, including the original Encoder27 retirement handoff absent from the D36 saved-H test. D35's original FAIL and D36's segmented PASS remain preserved with their old identities. Runtime belongs to E021/R005, with no A010 experiment or E016 duplicate charge. The measured time is simulator wall time; no physical timing/fit, board or exhaustive abnormal-path conclusion follows. A010 documentation is

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 24 |
| R002 | [本批结果与证据](experiment_results/runs/R002/README.md) | 5 |
| R003 | [本批结果与证据](experiment_results/runs/R003/README.md) | 9 |
| R004 | [本批结果与证据](experiment_results/runs/R004/README.md) | 3 |
| R005 | [本批结果与证据](experiment_results/runs/R005/README.md) | 29 |
| R006 | [本批结果与证据](experiment_results/runs/R006/README.md) | 17 |
| R007 | [本批结果与证据](experiment_results/runs/R007/README.md) | 55 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
