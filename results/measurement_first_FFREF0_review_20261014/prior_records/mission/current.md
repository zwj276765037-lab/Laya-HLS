# 当前工作：FFREF0末FFN残差独立参考与硬件接点

[LNQ2限定审核](../results/measurement_first_LNQ2_review_20261014.md)接纳AT049正常四行单实例同runtime：外部enc0 residual→LN→原唯一Q→Wi→真实DDR/reader→G→同Q→Down，全部原独立gold/真实存储/末B/lease/实际消费通过，全冷TB375074cycles。480引用/328哈希路径、289 manifest引用/288路径、3串行guard/39policy已核。LN目的本地64KiB、下游393216B终检通过，不签全STATE0/13BO。AT047 FAIL与AT048 COST_STOP不回写；完整M003/M004未完成。

当前[D-M004-FFN-RESIDUAL-SOURCE-01](ffn_residual_reference_stage_20261014.md)选择FFREF0。末残差skip是LN前HIDDEN；原图F32 add(hidden,down)、无bias，生产任务以TMP/Down和HIDDEN/skip为两源，写另一HIDDEN bank。先沿AT038原完整S128参考前缀捕获skip/Down/enc0末输出及四行，直接核AT049 Down gold和旧独立encoder_00_out；同时给出点名现成F32加法核的有限双源AXI残差producer方案。旧D2-I固定S64/stage4/64行的CPU/CSim及生成结构不当本四行RTL。

本阶段仅host≤8GiB/120s、一个观察封装及一次有因修正；保留数学/原输入/全S128依赖。新DUT/HLS/RTL/整链不运行，FFREF0结果NOT_RUN。普通准备连续执行，无逐步用户审批；工程交付后再集中选择具体残差硬件验证。

A002唯一实现/工具；代码E002/experiment、证据E005/R001。CPU0–3/nice19/idle、MemAvailable>192GiB、全项目单重工具及原所有帽保持，无新agent。无新HLS/OOC/P&R/上板；G2338.224019s仅OOC余额，5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；完整普通Q/L多窗口、Attention/WO/residual硬件、28+2层/122矩阵、13BO请求/恢复、联合资源/物理时序及M003/M004开放。
