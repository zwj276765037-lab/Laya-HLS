# 当前工作：QWIGQD0真实量化供数接入

[WIGQD1正常四行连续链已核](../results/measurement_first_WIGQD1_review_20261013.md)：AT032同一resident/dualW/dualA，Wi→实际DDR/reader→G→量化→Down全部原独立gold、真实末B/lease/完成消费通过；最终327680B有效区及保护字节完整读回通过。全TB205314，G接受→结束103975，Down cfg→消费16191。旧AT031 COST_STOP保留，既不能判旧DUT死锁，也不回写旧full通过。

当前按[D-M004-QWIGQD-INTEGRATION-01](quant_wi_g_quant_down_stage_20261013.md)去掉Wi预量化A：原enc0 LN_FFN四行F32外部输入→真实AXI/现有量化器→同dualA epoch1→Wi，再复用同量化器处理GATE/epoch2并完成Down。四行F32与原capture、原q/scale与AT032期望逐字节同源已核；LQ0的layer1 LN_ATTN不能拼接成此上游。LN_FFN producer与FFN末residual仍不含，新QWIGQD0结果NOT_RUN。

一套量化器/矩阵引擎/原容量A与W缓存，B1/S128/batch0/row0四行，只有初始reset。有限共享命令/响应/AXI选择保持完整身份与债务排空，不新增通用控制；独立gold、输出存储和输入只读区/保护区都要实际验证。一个接入实现及最多两轮有因修复，原工具帽；同点无新证据重复停止即收束。

A002唯一实现/工具owner，A001集中审核；E002/experiment唯一实现，E005/R001保存证据，不新增agent/不写旧baseline。KB1/ATN1/WIGQD1有限保留，KB2/CT0/LQ1R收束，LQ1不生产采用。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup停排。原单重工具/分类帽、G2338.224019s仅OOC余额、5172s不重启，无新HLS/OOC/P&R/上板或预算。完整28+2层/122矩阵、13BO/请求/恢复/联合资源/物理时序及M003/M004仍未完成。
