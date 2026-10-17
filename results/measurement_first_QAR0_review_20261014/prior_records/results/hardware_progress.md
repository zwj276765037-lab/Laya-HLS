# 硬件进度

2026-10-14当前：[QWIGQD0原浮点输入真实量化接链通过](measurement_first_QWIGQD0_review_20261014.md)，AT034限定四行normal全gold/真实存储/末B/lease/消费及保护区PASS。共享入口尚有IDLE双valid互锁静态反例，且P/Q诊断opcode不符生产schema。下一[QAR0有限包装修复](../mission/shared_quant_admission_stage_20261014.md)先做G优先和定向唯一接受/响应归属验证，不扩通用控制。LN前residual输入尚无冻结capture，LN producer与全模型/恢复/资源时序未验。新QAR0 NOT_RUN，M003/M004未完成。以下为历史。

2026-10-13当前：[WIGQD1完整四行正常链已核](measurement_first_WIGQD1_review_20261013.md)，同一矩阵引擎/缓存从真实Wi写回、DDR重读到G/量化/Down和最后消费，全部gold/保护字节通过。旧AT031 COST_STOP不回写，AT032全TB205314。下一[QWIGQD0](../mission/quant_wi_g_quant_down_stage_20261013.md)以同源LN_FFN四行F32为外部源，复用同一量化器供Wi并再处理GATE，取消TB预量化A。新结果NOT_RUN；LN producer/全模型/生产恢复/资源时序未验，M003/M004未完成。以下为历史。

2026-10-13当前：[WIGQD0有界停止已核](measurement_first_WIGQD0_review_20261013.md)。Wi真实数值、末B/lease/消费与83968B DDR有效区读回通过；整链及最终保护区未通过。G阶段真实进度日志缺口已证、动态根因未定。旧实现/两修复收束，下一[WIGQD1观测诊断](../mission/wi_g_quant_down_observation_stage_20261013.md)仅一次新full，保持DUT/数据/驱动/响应及原帽，补真实事务和有限等待状态，结果NOT_RUN。M003/M004未完成。以下为历史。

2026-10-13最新：[WI0真实resident Wi已限定接纳](measurement_first_WI0_review_20261013.md)，完整PS/20992F32、真实写回/末B/lease/消费通过；独立DDR哨兵读回未验。下一[WIGQD0连续连接](../mission/wi_g_quant_down_integration_stage_20261013.md)单矩阵引擎、单A/W缓存分时Wi→Down，实际Wi写存储与reader接G，统一身份/坐标并补保护字节读回。新链NOT_RUN，不恢复整体控制；M003/M004未完成。以下为历史。

2026-10-13最新：[GQD0正常四行接链已核](measurement_first_GQD0_review_20261013.md)，真实G→量化→唯一dualA→KB1 Down及全部原gold/末B/lease/消费PASS。下一[WI0真实resident Wi](../mission/wi_resident_producer_stage_20261013.md)补上游完整输出，外部A仍为预量化LN_FFN；不新增矩阵引擎或恢复整体控制。WI0与Wi→G同runtime尚NOT_RUN；M003/M004未完成。以下为历史。

2026-10-13最新：[ATN1终态审核](measurement_first_ATN1_close_20261013.md)已有限保留，同DUT协议PASS。下一GQD0四行真实G→量化→KB1 Down按[新合同](../mission/g_quant_down_integration_stage_20261013.md)实施，接点q/scale期望同源已核，新运行NOT_RUN。预算不变、整体控制停排，M003/M004未完成。以下为历史。

2026-10-13最新：[ATN1完整head正常进展](measurement_first_ATN1_progress_review_20261013.md)已核，全TB−1.3729%、正常计算−3.6552%、SM−7.6919%；原gold不变。AT022同DUT协议回放待终态，尚未采用。其余原方向与预算不变。以下保留历史。

2026-10-13当前：[ATN0集中审核](measurement_first_ATN0_review_20261013.md)接纳正常完整head数值/计量，唯一ATN1同row ASUB预备与EXP重叠已冻结并报告static启动，完整结果待交；535引用/5guard/63policy已核。保持原协议/首错/CE/reset回放义务，原资源帽与整体控制停排不变。以下保留历史。

2026-10-13当前：LQ1R两版估计违例，按上界no-go并停止，无第三版/RTL/F9结果。下一[Attention softmax计量阶段](../mission/attention_softmax_measurement_stage_20261013.md)已确定，原冻结v10、同资源数值图，新ATN0/ATN1尚NOT_RUN。整体控制/冷INIT/恢复保持停排，完整M003/M004未验。以下为历史进度。

2026-10-13当前：LQ1 AT016正常16行数值/周期已核，局部全TB下降19.8726%；HLS时序估计slack−48.76ns。下一LQ1R仅恢复最终F32减/乘寄存器流水，原合同两版有据修复额度不重置，阶段条件见[新合同](../mission/ln_quant_timing_repair_stage_20261013.md)。新工具NOT_RUN；完整模型/恢复/资源未验。以下按时间保留历史更新。

2026-10-13测量优先当前进度：KB1实测改进保留，KB2停止，CT0有限出口保存。LQ0 AT014原16行LN→真实store→Q/fullA数值/计量已接纳；LQ1 AT015仅归一化循环流水候选生成，实际II2、HLS估计slack -48.76ns，继续原合同同口径RTL与代价取舍。完整请求/恢复/联合资源未闭合，旧整体控制/冷INIT不恢复。[当前审核](measurement_first_LQ0_review_20261013.md)。

以下保留历史接入记录，不代表当前排程。

2026-10-11工程评估与主控核验完成；本轮未运行CPU/CSim/RTL/OOC/P&R或板卡。依据[工程验收报告](../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)和[重规划](controller_replanning_20261011.md)。

旧build完整CPU/实际CSim及resident/G/Attention局部证据按身份保留。当前源码与旧完整回归有7项编译依赖差异，真实生产cmd/rsp/13BO与同runtime Wi→G→quant→Down、安全退休/恢复尚未验证。G父与Attention新OOC为COST_STOP；联合资源、完整请求性能、整图RTL与物理/板端保持未验证。

下一阶段[M003](../mission/M003_当前身份生产链接入与回归.md)/SM003/E003 planned：身份→生产门户→真实链→恢复→稳定build完整CPU/CSim与受影响分段RTL→证据交付。代码仍在E002/experiment，E003存新阶段证据。无新增OOC或整图长RTL，G累计余2338.224019s不重置；未变叶子不重复重跑。

## 最新用户范围修订

当前总mission改为[M004完整搭建与性能优化](../mission/M004_完整Laya加速器搭建与性能优化.md)。此前M003局部连接是前置，不是总目标终点；SM004推进全模型，SM005推进完整请求性能和当前资源闭合。用户不设具体性能门槛，但要求尽量高性能与可核实优化。原记录为修订前阶段说明，新范围以[本次修订](mission_scope_revision_20261011.md)为准。硬件证据未新增，当前仍未验收。
