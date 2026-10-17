# E002：工程验收结果（2026-10-11）

**本轮工程评估交付完成；完整加速器NOT_ACCEPTED／证据不足。** [完整报告](engineering_acceptance_20261011.md)含证据位置、风险、后续通过标准及不应重跑范围。

| 范围 | 结论 | 关键证据与限制 |
| --- | --- | --- |
| 旧完整CPU/实际Vitis CSim | PASS_SCOPED，复用并核验 | 4持久请求、141点/18094384 F32及故障恢复；非当前working源整图硬件 |
| resident完整Down局部链 | PASS_SCOPED | 4row K2624/N1024，4096输出，512实际AW/W/B及末B/lease/localREADY；48862cycles；预量化A/kind0 bias/初始reset |
| G三bank物理GATE→quant→fullA | PASS_SCOPED | 4distinct冻结Wi checkpoint行，656写/读beat，328group；59975cycles；无上游Wi Q8/同runtime Down |
| Attention v10 | PASS_SCOPED | 正常head计算604317cycles vs 6816248，改善11.279259倍；首错/CE/reset来自同身份tile16，head128 PROTOCOL=0 |
| 当前G父/Attention OOC | COST_STOP | semantic_stall，无final资源/DCP/时序；不是数值FAIL |
| 当前完整CPU/CSim、生产13BO、连续producer链 | NOT_RUN / 证据不足 | 当前7个编译依赖变化；cmd/rsp、真实AXI owner/debt与完整生产绑定尚未验证 |
| 联合fit、完整请求性能、P&R/Fmax、上板、数据集准确率 | NOT_RUN / 未验证 | 局部cycles、条件150MHz与旧父/子资源不能合并代签 |
| 历史tanh/tiny失败 | FAIL按原身份保留 | successor canonical/精确适配各有限定PASS，不能追认旧失败 |

两主封存24条直接引用、旧CPU153条、旧CSim81条、resident8条、G桥6条均匹配。Attention manifest 185条引用中183匹配，另两处历史文档SHA缺口已记录。G累计OOC余2338.224019s不重置。150MHz及50ms不替代物理证据或唯一验收门槛。

---
Published: 2026-10-11T07:27:30.500120+00:00
Publication: P0aa6533d50e24ddbae22f0ce17a43cc8
