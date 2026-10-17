# 下一连接段：LN→Q的定向核查

2026-10-15；A001→A003；M004/SM004/E004/R001。复用现有 `source/fixed_graph_architecture_20261014.md`，只补这一连接的接点与独立参考，不重审全图，不新开mission。

主控已核AT104/107/108样本和同版OOC，发现DELTA1提前报错会跳过更早square错误，已直接交A002在原LN预算内动态复现/修正。反例与范围见 `results/m004_simplified_start_20261014/ln_review_engineering_response.md` 及同目录 `ln_row_review_evidence_20261015.json`。你不重复工程仿真；更新现有分析时保留正常行/OOC事实，LN首错完整合同仍待修复。

下一段选择一条真实单行连接：新LN的32bit输出→有界16元素打包→现有 `quant16_stream_row.sv`，不接旧portal/lease/hub。请只核以下实际依据并答复：

1. P1 `wi_ln_rows1` 和 `qkv_ln_rows1` 中 `dut.q8.bin` 的精确布局（1024个int8及32个FP16 scale）、与该行LN输出的同输入关联、历史独立oracle比较来源；给出SHA和最小解码依据。无新gold生成/模型前向。
2. 现有Q对32group的真实start/input/output/done/排空语义，特别是数值错误可能已输出部分group、协议错误如何结束；薄连接必须保留哪些完成条件。一个完整LN成功行才进入Q，不使用CPU或夹具替换中间LN结果。
3. 给出最小建议：串行行命令、一个512bit打包寄存器、明确group/half顺序及反压；外部交付采用现Q的128bit half＋scale/标签，或固定1024B+64B行暂存后发布，两者的后继矩阵连接代价。仅针对本接口推荐一种，不新增统一资源池或身份层。

沿既有研究轻量host累计≤120s/8GiB及CPU0–3/nice19/idle约束；当前只读资料和小文件身份/布局核查。无EDA/GPU/软件整图/新代理。工程同时修LN，其他人正在工作，不改E002或工程记录。交付一段可执行接口依据即可，A001负责最终连接合同与预算。
