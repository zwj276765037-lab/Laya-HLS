## E016/R004 FFN-REFERENCE-18 current stage (2026-10-23)

原fe9678e4独立CPU参考直接调用，原AT007 norm_ff/G与原权重输入；原逐次F32舍入、Q8 reciprocal/half/roundf、group顺序不变。AT001已有Down诊断row112和AT007 norm_ff→Wi row0交集逐位PASS；仅局部原G row0生成Q8/Down，完整128行严格按成本门未准入。无RTL/EDA/整模重算；唯一后继连线及20bit新增父控制设计预算单列。

证据：[R004交付](../experiment_results/runs/R004/final_delivery.md)、[协议](protocol_ffn_r004.md)。R003以下原摘要原文保留。

---

# E016/R003 完整Attention父链实现与实际输入

SM012 D-M007-SM012-FULL-PARENT-15。当前parent e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8及原FP/DIV/layer/resource closure冻结在AT004；生产RTL未改。实际完整TB保留全部原QKV/W/A/prebias/RoPE/score/prob/context/连续issue/PS反馈/8身份拒绝checker，并按head和两次matrix操作分开计数，新增每head128maximum终断言、真实公共context4096、同quant/A发布和WO131072原gold，以及首次正常父成功的独立243bit期望与保持/退休。

实际AR接受时按已注册QKV/WO地址锁存来源和base，每ID返回使用锁存字段。原out_ready合法中间/末WO反压，done_ready保持5拍；不强制内部state/ready，不用原context文件代驱动真实layer输出，不复制生产服务。所有模式使用同一完整snapshot并在初始化加载相同完整fixture。原model/numeric/table/graph/layout/build128bit source tags与kind/layer keys沿用e354校验；当前W576/RTL/compiled身份另外记录，不当作当前bitstream。

新增parent+adapter控制1561bit/196B，原保守3550B合计3746B；452实际输入源，实际唯一服务层次由最终审计核。声明和功能展开不签物理fit。原地址描述符仍来自可信fixture，未实现任意Host/HBM源注册。参考复用E010全16head与E012/R004 AT005原context/WO/packed W文件，复制冻结并逐SHA登记，未生成新gold。

---
Published: 2026-10-22T13:31:19.500493+00:00
Publication: Pfd2a618f579944179887ea44e2919cbb
