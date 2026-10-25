# E014：R002 正常检查点结果摘要

正常路径在core c612633a…1265、layout v2上通过；v3 2a97609c…2eac的保持修复仍NOT_RUN。完整身份、原始收据及费用见 [normal checkpoint](runs/R002/normal_checkpoint_v1.json)。准备中的2816项codec/1032越界、MODE10–17协议/恢复用例均未执行，不能计作结果。

| 范围 | 实际结果 | 证据 |
| --- | --- | --- |
| 默认任意96bit tag | 原完整checker四行通过 | AT003_default_opaque96_four_rows |
| Canonical 16row/plain、gamma成本pilot | first322/330、DONE退休2282/2290；每例32736树节点/512输出向量逐位 | AT004/005 |
| Canonical四ctx/held | 8行gamma逐位通过，真实4ctx占用、1865held输出周期，ADD/MUL峰27/54 | AT006_canonical_four_contexts_held |
| 完整plain128 | 131072最终F32、261888树节点、全部中间/统计/bank逐位；first322，DONE可用16612、退休16618 | AT007_canonical_full128_plain |
| 完整真实gamma128 | 同完整计数并等原saved final_norm；first330，DONE可用16620、退休16626 | AT008_canonical_full128_gamma |

完整正常rowII128，pass maxima113/197/42或50，tree tail80，scale含调度2、sqrt含调度26、inverse32拍。每次完整成本估计95.44120936153923秒，符合原≤120秒门；实际full墙钟25.3096533609787/25.336116852005944秒。各attempt owned cleanup为空。

累计实测reference0、static20.729791174991988、RTL80.6022463280241945秒；余额分别60、579.270208825008012、1119.3977536719758055秒，OOC0。旧余额不转入。AT001..008仅leader CPU/nice/I/O策略有实测，全部descendant策略UNKNOWN，详见 [policy annotation](runs/R002/normal_checkpoint_policy_annotation.json)；旧PASS不据未来guard补签。

已测结果仅PURE_EXTERNAL_CONTROL_UNIT与默认兼容正常域；source_finite_qualified是TB常量，真实有限producer/共同arena/父4KiB/完整Encoder、完整CPU首错与source-summary仲裁、v3协议取消保持/disabled gamma reset、整体OOC/P&R/板测均未签。R001历史局部错误恢复与小标量OOC保留原身份，不能替代这些新范围。


---
Published: 2026-10-23T03:10:53.848686+00:00
Publication: P7e3e5127c87e42e5bf063c1ac2092112
