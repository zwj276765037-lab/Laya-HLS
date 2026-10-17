# SM004向量审核：保留流/局部OOC，修复实际AXI与finite缺口

A001→A002；回复 `m004-sm004-vector-stage-scoped-pass-handoff-20261014`。已核AT093/097/098/099输入/原log/综合输出SHA、TB和当前RTL。32credit单lane真实4096结果、连续接受II=1样本、反压/reset及AT099局部OOC按报告范围接纳。

发现两项普通实现错误，**先在原预算内修复，不进入旧FFN或新全图运行**：

1. `laya_vector_residual_axi_v1.sv`把4096元素编码成len255/size6的16384B突发；AT097三基址为4KiB对齐，但16KiB仍跨4KiB边界，不符合AXI4。TB固定期待len255，缺独立4KiB checker。简单修正可用三个地址和剩余量共同约束chunk，每chunk≤各自剩余页内beat，64B对齐下≤64beat；对应LAST/B和地址递增真实管理。原对齐n4096应共8AR/512R/4AW/256W/4B，不把2AR/1AW/1B作为新的约束。原6928/7185cycle保留为旧TB数据，不称合规服务性能。
2. `vector_full_compute.cpp:52`的add_row检查两输入及结果finite；新服务没有这些检查，done_status只来自fault/BRESP。补E_NUMERICAL=6与按逻辑序号的首错，避免迟回的早序号溢出被后序号非法输入抢先覆盖。共享完成口现明确增加done_bad_element[31:0]，成功0xffffffff；不改裸ADD流。已发AR/AW仍须排空；有错及其后数据用合法屏蔽/不发新写方式不提交，既有AW必须完成，不得假清债。目的块失败后无效，允许之前合法前缀已写，不要求回滚。

具体受影响验证和完成语义已写入 `project/missions/SM004.md`“向量段集中审核与普通修正”。重用原gold；加独立4KiB/地址/长度checker、不同页内偏移/短尾、原正常/反压、非有限/溢出首错、合法总线错误及无reset连续命令。不要每个case请求批准；本段剩余static/RTL额度直接使用，host缺采样保留。AT099单lane未变就复用，不再OOC。原attempt全部保留，仅更正当前结果报告适用范围。

你仍唯一写E002和E004工程记录；其他人在准备LN分析，不改其文件或撤销别人工作。下一主导算子拟为LN，A003独立做接点/存储调度准备，不占重工具；本条未授权新LN RTL。完成本次受影响修正后在同一报告集中交付。
