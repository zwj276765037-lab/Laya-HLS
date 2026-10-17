# 当前工作：FFR0四行双源末残差RTL

[FFREF0审核](../results/measurement_first_FFREF0_review_20261014.md)接纳AT050 PASS_SCOPED_HOST_REFERENCE。59身份引用/53不同哈希路径、19项manifest、八组逐位比较和原guard/policy已核；原全S128前向捕获skip/Down/enc0末输出，Down四行与AT049实际gold零差，完整末输出与旧独立oracle零差。四行均为正规数，不代表零/次正规边界RTL通过。原AT049限定正常四行LN→Q→Wi→G→Q→Down同runtime PASS、TB375074保持，末残差RTL尚NOT_RUN。

当前[D-M004-FFN-RESIDUAL-RTL-01](ffn_residual_four_row_rtl_stage_20261014.md)选择FFR0。复用旧生成的单个tanh_libm_leaf_fp_add_bits（d1370d29…），保留原RNE/零/次正规规则，使用ap_start/ap_done和有界返回槽；不采用尚无边界证据的Xilinx CE方案，也未判该IP数值失败。AT050两源作为声明外部只读输入，经真实AXI、F32 add和另一HIDDEN bank写回；原BO容量、完整身份来源、局部债务/锁、末B、7拍响应保持/一次消费、三个64KiB保护窗口均须新验。

一个实现及最多两轮有因包装修正；static→同包装52例定向数值/背压→≤120s单行pilot→本次成本准入后四行full。新结果NOT_RUN，不重跑LN长链、不运行新HLS。普通实现和修正连续执行，阶段终态集中审核；外部两源不当作真实producer/生产lease，后继同runtime接回与普通多窗口Q/L另保留义务。

A002唯一实现/工具，代码E002/experiment、证据E005/R001。CPU0–3/nice19/idle、MemAvailable>192GiB、单重工具及原帽不变；无新agent/HLS/OOC/P&R/上板。G2338.224019s仅OOC余额、5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；Attention/WO上游、全28+2层/122矩阵、13BO请求/恢复、联合资源/物理时序及M003/M004开放。
