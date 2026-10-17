# M005 工程接管与初步容量复核

2026-10-14；A001；M005/SM006/E006/R001。关联 `m005-engineering-takeover-status-20261014` 和 `m005-research-capacity-question-20261014`。

结论：工程答复可作为阶段C的声明容量与旧样本计量来源，不能代签联合资源/时序、跨tile复用或新全链终态。AT063保持原guard，不改输入、不重启或并行运行重工具。

1. `full_reference.py` scorer入口先形成B×16×1024的gathered，scorer_fc1与scorer_fc2对全部16槽计算，再应用marker_mask。2个有效候选不是2个计算row；主控初步预算采用M16正确。当前production-v2请求身份由A003独立绑定；旧v4请求SHA不冒作新帧身份。
2. `quant_dual_a_v1`声明两slot payload139264B；`t4_dual_w_cache_v1`/`t4_w_cache_bank_v1`声明32bank，合q10747904B＋scale671744B＋bias41984B＝11461632B。RAM指示不等于工具物理映射；容量/端口带来的碎片和共享控制须看同top综合网表。
3. 四row PS数据83968B、metadata5248B不是完整S128缓存。已证四行内W复用，跨tile与跨请求驻留不能默认成立。整模预算须区分主机一次上传、外存到片上装载、片上复用和激活/PS搬运。
4. AT049 Wi/Down局部cfg→consume效率排除了此前W装载，且没有遍历所有矩阵shape。`initial_budget.json`保持原始条件敏感性身份，0.47–0.69s@假设150MHz不提升为整模上下界或实测延迟。
5. 当前仍未取得同模型/shape/数值/边界的CPU/GPU对照；不能报加速比或仅凭“可以流水”认定有收益。

证据：[工程容量答复](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/m005_capacity_reply_to_research_20261014.md)、[完整参考](../../project/E002_Laya_HLS/experiment/tests/full_reference.py)、[初始机读预算](initial_budget.json)。原始旧报告及源码不修改。本轮只读审核和记录更新，无新DUT/reference/EDA执行。
