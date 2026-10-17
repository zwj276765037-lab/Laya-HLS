# LQ1R有界停止核定与下一算术入口

2026-10-13；M004/SM005/E005/R001，主控A001。回复`measurement-first-LQ1R-no-go-handoff-20261013`。

**接纳LQ1R本轮no-go，关闭这条两版局部延迟修复排程。下一阶段执行[D-M004-ATTENTION-MEASUREMENT-01](../mission/attention_softmax_measurement_stage_20261013.md)：原冻结Attention v10的softmax计量与至多一个有实测依据的同资源调度候选。** 工程A002按合同直接继续，不需用户转发或逐工具审批。

## 两版终态与结论边界

主控已核AT017/AT018各31份冻结源及完整生成引用：第一版仅最终normalize的两个BIND_OP，第二版只把减法绑定4改5，乘法和全部表达式/检查/返回保持。原g++/HLS类型模型对照及HLS生成通过。2段guard串行，116条实际policy符合原资源/CPU限制；全部439个唯一引用还包括下一Attention入口的定向身份检查，引用数不代表测试覆盖率。

| HLS估计/映射 | AT017 | AT018 |
| --- | ---: | ---: |
| 减/乘wrapper stage | 5/4 | 6/4 |
| 减/乘native core c_latency | 3/2 | 4/2 |
| 最终循环II/估计cycles | 9/9224 | 10/10249 |
| 减末级→乘首级路径 | 5.298ns | 5.277ns |
| 相对4.867ns有效预算的slack | −0.43ns | −0.41ns |
| HLS墙钟 | 101.160436s | 100.111604s |

第二版注册映射生效，State8仍为2.955+2.322=5.277ns，未满足原150MHz/1.800ns uncertainty下的估计入口。按照已定上界停止，不启动第三版、不换名继续扫描、不放宽时钟或资源帽。两版static/pilot/full/F9全部NOT_RUN，没有LQ1R动态周期、错误RTL或物理结论。

AT018循环估计10249恰与LQ0报告相同，仅说明该估计回到原数值，不能写为新实测无收益。也不能把这两版no-go外推成LayerNorm不可优化、所有HLS无效或必须手写RTL。支持的结论是本轮“仅增加两个浮点算子延迟约束”未取得符合入口的版本。

LQ0继续保留原基线；LQ1 AT016正常16行全TB−19.8726%仍仅是有时序风险的周期候选，错误/物理义务未闭合，不生产采用。KB1已核改进保持，KB2/CT0收束。

## 选择Attention的依据与下一出口

已有盘点中的v10 source_manifest及93份源、81项head snapshot、3项数值引用已定向重核，均在本项目复制树，不写旧baseline。历史正常完整head604317cycles中，QK250888、SM287173、AV66256，softmax占47.52%；它是下一瓶颈假设的依据，不是新测量或可节省比例。旧M/A wait含模式闲置，EXP实际服务有1/78/89/97 enabled-gap，须进一步拆清。

下一ATN0只新增观察，保持真实enc0/head0 B1/S128全部128query/K128/D64、原独立中间/最终gold与QK→SM→AV完整链。计量SM_MAX/EXP/TREE/DIV互斥周期、实际worker开始/完成/提交、A/D与内存/阶段等待，并区分wall/enabled/launch边沿。保持M16/A16/D4/EXP4及其原FP/EXP实现、寄存器延迟和数值顺序；不重新生成HLS算子。明确这是一次带新增问题的性能测量，不是为盘点重跑旧head。

基线形成后仅在有可消除的同资源调度空隙时做ATN1；没有支持则no-op收束。静态/pilot/完整head按原成本帽串行，候选拟保留前回放原tile16_03首错/CE/reset/ledger范围。普通修复直接继续，实质接口或数值变化不悄悄并入。本模块无AXI master，不把模块计算端点说成13BO/完整请求。

完整执行及停止边界见[阶段合同](../mission/attention_softmax_measurement_stage_20261013.md)。整体控制/冷INIT/恢复继续停排；无新OOC/P&R/上板/预算，G仅OOC余额2338.224019s、5172s组合不重启。M003/M004未完成。

证据：[只读核验](measurement_first_LQ1R_close_20261013/verification.json)、[工程no-go报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1R_timing_no_go_20261013.md)、[Attention既有盘点](../project/E005_full_request_performance/experiment_results/runs/R001/reports/attention_inventory_20261013.json)。主控本轮未执行任何DUT工具。
