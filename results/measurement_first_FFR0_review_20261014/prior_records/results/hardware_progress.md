# 硬件进度

2026-10-14：[FFREF0独立参考已接纳](measurement_first_FFREF0_review_20261014.md)，AT050完整图与四行skip/Down/末输出直接身份闭合，无新DUT。下一[FFR0](../mission/ffn_residual_four_row_rtl_stage_20261014.md)以声明的双外部源，复用单HLS位精确加法叶子做真实双源AXI/另一HIDDEN bank写回，先52边界例和单行pilot再有据四行full；一个实现/两轮包装修正，不重跑LN长链。新RTL NOT_RUN，M003/M004与生产/物理义务开放。以下为历史。

2026-10-14：[LNQ2四行链已接纳](measurement_first_LNQ2_review_20261014.md)，AT049保留AT048 DUT/TB，仅修启动包后取得原独立gold、LN真实发布/lease到Q/Wi/G/Q/Down及最终存储/消费PASS。原AT047/48失败不改写。下一[FFREF0](../mission/ffn_residual_reference_stage_20261014.md)独立完整图捕获末残差两源/结果并定双源AXI/另一HIDDEN bank接点，只运行host前缀；未新跑残差RTL。M003/M004开放。以下为历史。

2026-10-14：[LNQ1停止已核](measurement_first_LNQ1_review_20261014.md)，AT048新TB静态通过但缺7份ROM，full在源AR前COST_STOP，END/PUBLISH和后段未验证。下一[LNQ2](../mission/ln_qar_runtime_replay_stage_20261014.md)固定同DUT/TB，修部署并加入每次xsim前闸口；短前缀真实AR/R及有据成本后至多一次新full。旧失败不改写，M003/M004开放。以下为历史。

2026-10-14：[LNQ0有界失败核定](measurement_first_LNQ0_review_20261014.md)，AT047实际四行LN前缀/发布达到，随后TB在scope关闭后错误要求coverage_complete，语义FAIL；外部Q/Wi/G/Down未到达。下一[LNQ1](../mission/ln_qar_observation_repair_stage_20261014.md)只修TB观察时点，同DUT/数据/profile至多一次新full，旧修正额度不续开；新结果NOT_RUN，M003/M004开放。以下为历史。

2026-10-14：[LNQI0已接纳](measurement_first_LNQI0_review_20261014.md)，真实production-v2与AT035 actual-r2的Wi/Down数学载荷相同，两种身份格式不同；旧BO表未绑定实际AXI。下一[LNQ0](../mission/ln_qar_single_chain_stage_20261014.md)用无冲突地址表和完整lease适配连接原LN与唯一后段Q/矩阵引擎；static/≤120s真实前缀/有成本准入full，新RTL NOT_RUN。无新HLS/OOC，完整M003/M004开放。以下为历史。

2026-10-14：[LNF0已限定接纳](measurement_first_LNF0_review_20261014.md)，AT040真实四行LN_FFN→store→Q/fullA、全部独立gold及最后B/发布/lease通过。与QAR0仍是独立样本；主控发现两边416B身份各233B不同，下一[LNQI0](../mission/ln_qar_identity_preflight_stage_20261014.md)先做共同包/权重/布局和单Q接口准备，尚未启动新RTL。普通多窗口Q/L与全模型/请求/恢复/物理证据仍缺，M003/M004开放。以下为历史。

2026-10-14：[LNREF0已核](measurement_first_LNREF0_review_20261014.md)，独立原request3前向保留完整S128依赖，新增enc0 LN前residual及独立LN输出与四行链源吻合。下一[LNF0](../mission/ln_ffn_four_row_rtl_stage_20261014.md)原LN baseline四行LN_FFN→真实store→Q/fullA有限RTL；适配旧LN_ATTN/16行封装、完整身份/实际BO/发布与lease，新结果NOT_RUN，无新HLS或后段长链重跑。完整M003/M004和物理/生产证据仍开放。以下为历史。

2026-10-14：[QAR0已核](measurement_first_QAR0_review_20261014.md)，AT035修复G/外部Q双valid互锁，有限竞争及原四行完整存储链通过；AT036默认EXT_QUANT=0真实compile/elaborate通过，动态G-only未跑。下一[LNREF0](../mission/ln_ffn_reference_source_stage_20261014.md)独立参考生成LN_FFN前residual并闭合输出/请求身份，数学图与完整S128依赖保持，主机≤8GiB/120s。实际LN producer、FFN residual、完整生产请求/恢复及联合物理实现仍未验。以下为历史阶段。

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
