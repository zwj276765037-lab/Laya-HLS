# 当前工作：Attention softmax测量与一个有据调度候选

当前执行[D-M004-ATTENTION-MEASUREMENT-01](attention_softmax_measurement_stage_20261013.md)，工程A002唯一实现/整合/重工具owner。选择原Attention v10冻结93源、enc0/head0/B1/S128全部128query/K128/D64完整QK→SM→AV，先做最少观察ATN0，再仅在实测支持时做一个同资源softmax调度候选ATN1。新结果NOT_RUN。

历史正常head604317cycles中softmax287173占47.52%，只用于定位。ATN0要拆SM_MAX/EXP/TREE/DIV互斥状态、EXP4真实服务/提交及A/D/内存等待，区分wall/enabled/launch边沿；不把模式闲置和所有gap算成可消除stall。保持原M16/A16/D4/EXP4、寄存器算子、数值顺序与全部独立gold；不重生成HLS或重启Attention OOC。static/pilot/full按原帽，候选拟保留前做原tile16协议/首错/CE/reset受影响回放。

[LQ1R终态审核](../results/measurement_first_LQ1R_close_20261013.md)已核定两版no-go：AT017/AT018注册映射生效，HLS slack−0.43/−0.41ns仍未达入口，II9/10；RTL及F9均NOT_RUN。关闭该局部延迟修复排程，没有第三版。LQ0保留，LQ1原正常16行全TB−19.8726%仅为时序风险未解的周期候选，不生产采用。

KB1保留，KB2/CT0本轮收束。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup继续停排；M003仅为最终生产集成依赖。代码唯一E002/experiment，证据E005/R001，现有helper复用，不新增agent，不写旧baseline。

原单重工具/全部分类帽、G2338.224019s仅OOC余额、5172s不重启保持，无新OOC/P&R/上板/预算。Attention模块无AXI master，不代签13BO/完整请求；M003/M004完整模型/请求/恢复及联合资源最终义务未完成。
