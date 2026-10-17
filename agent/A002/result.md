# A002：工程实验结果

## 2026-10-15 SM004修订7 Q切分与同版LN→Q OOC

[同一连接报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)与[机读证据](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_q_partition_stage_evidence_20261015.json)记录AT125–132：最终Q RTL SHA `a1fd5b03…`，114真实组/27边界及两真实P1 LN→Q行逐位通过，扫描/预约/平局/四相位reset受影响验证；gamma0/gamma1到row_valid 8597/11087cycle，比旧版+24/+23。AT131唯一同版U55C OOC 37346 LUT、12518 FF、50 DSP、16 RAMB18E2、blackbox0；WNS由AT116 −49.011改善为−1.750ns@6.667ns，仍FAIL。新最差为FMUL结果→Q首错归并→done_status，AT132最终DCP核两个关键valid输出为LUT逻辑。第一份成功网表后不重综；完整图、外存、P&R/Fmax未证，交A001下一阶段判断。

## 2026-10-14 M003 普通 Q/L 静态收尾与 M005 最终排程

按[D-M005-FINAL-ASSESSMENT-01](../../.research-agent/communications/m005-final-assessment-m003-paused-controller-decision-20261014.json)，M003 普通 Q/L 保持 paused，M004 当前串行实施线停排。已完成一次[现有接口/证据盘点](../../project/E003_production_chain_closure/experiment_status/ordinary_ql_static_interface_inventory_20261014.md)，并原生更新 E003 三摘要：定位 LN generated BEGIN/END、role6 窗口 P/owner 发布、Q 原子租约/实际读债、父 L 接点；单 rows16 NORM 真实源与四窗口 HIDDEN 受控 sideband 不合并验收。没有改 RTL/TB/gold 或运行新测试/重工具，普通多来源/多窗口生产链及 M003/M004 目标未完成。

## 2026-10-14 FFR0 四行末残差局部 RTL

[FFR0工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR0_four_row_residual_rtl_20261014.md)及[AT053收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/receipt.json)记录双外部源各256真实R、4096项单加法叶子逐bit独立gold、256 AW/W/B、最后B后发布、响应七拍保持和三个64KiB保护窗口PASS。AT052同SHA加法槽52例PASS；AT053 static/pilot/full 22.174/26.307/26.989s，full峰1376640KiB，guard无触发。14条冻结/外部身份及95条实际policy核验通过；AT051准备失败原样保留。此阶段未接AT049同runtime、生产双源lease或物理时序，M003/M004仍开放。已直接交主控集中审核，当前无本项目重工具。

## 2026-10-14 FFREF0 末FFN残差独立来源

[FFREF0工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFREF0_independent_residual_and_route_20261014.md)及[AT050收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/receipt.json)记录唯一guarded主机前缀 PASS_SCOPED_HOST_REFERENCE。原完整 B1/S128 前向图直接捕获enc0 skip/Down/最终输出：Down前四行与AT049冻结gold零/4096 bit差，最终完整输出与旧独立oracle零/131072 bit差；skip和LN观察与AT038一致。19份来源/冻结引用、8个输出及实际策略样本核验通过，guard 4.221s/峰126976KiB。已交一条有限双AXI/F32加法/另一HIDDEN bank写回接点；末ADD_RESIDUAL硬件和同runtime扩链NOT_RUN，待主控选择。M003/M004保持开放。

## 2026-10-14 LNQ2 四行单实例完整链

[LNQ2报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_runtime_replay_result_20261014.md)与[AT049收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/receipt.json)记录同DUT/两份TB/数据/profile的运行包修复：7份LN ROM实际部署，prefix/full各自启动前核验，短前缀真实AR1/R64；唯一冷full在2526.460s自然完成。LN四行真实store/发布→同一Q→Wi→DDR reader→G/GATE→同一Q→Down所有原独立gold、末B/lease/消费及393216B下游DDR终检通过，全冷375074cycles。AT047语义FAIL、AT048缺ROM COST_STOP保持。此为normal四行有限PASS，完整M003/M004、生产请求/恢复及联合资源/物理时序仍开放。当前无本项目重工具，已交主控集中审核。

## 2026-10-14 LNF0四行LN_FFN真实store→Q/fullA

[LNF0工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_four_row_rtl_result_20261014.md)及[AT040收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/receipt.json)记录static/单行pilot/四行full均限定PASS：AT038独立residual经原baseline LN生成核实际256R、256W/4B写16384B，4096 F32逐位gold；原Q真实再读256R，fullA全32组核4096 INT8/128 FP16 scale，末B、END/发布、响应保持、lease/债务和本地保护区终检闭合。全冷170031cycles，full guard195.557s。AT039因派生owner layer错配而在END协议拒绝，旧FAIL保留；AT040只修fixture。原83项生成物未变。真实LN→QAR0 Wi/G/Down同runtime、上游Attention/WO/residual硬件、全请求/恢复及物理仍未验，M003/M004开放。本阶段结果已交主控集中审核，当前无本项目重工具。

## 2026-10-14 QAR0共享量化入口有限修复

[QAR0工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md)和[AT035原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/receipt.json)记录static/pilot/full均PASS：双valid G优先、已受理外部或G任务期间另一入口等待、响应保持及拒绝后释放的定向RTL通过；原四行LN_FFN外部F32→同量化器→Wi→G→同量化器→Down的全部独立gold、末B/lease/消费和393216B最终DDR检查通过。全冷206136cycles，新增源AR为4 burst/256 beat、实际R256。只改变bridge/TB/runner三项冻结内容，106 manifest引用和45实际policy匹配；full guard1782.005508s、child0/null。一般公平性/恢复、真实LN_FFN producer、全请求及物理仍未验，M003/M004保持开放。当前无本项目重工具运行，交主控集中审核后选择后继。

[AT036补充静态收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/receipt.json)使用相同冻结bridge实际编译/展开默认`EXT_QUANT=0`顶层，53.105357s、child0/null、31条policy匹配；G-only动态未新跑。

## 2026-10-13 WI0四行真实resident Wi输出

[WI0工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WI0_resident_producer_20261013.md)及AT028原收据记录static/有界W前缀pilot/full均PASS：真实dualA/严格W/resident/KB1 writer使20,992 Wi F32及671,744 PS lane-group与独立gold一致，1,312 AW/W/B、最后B、lease、局部发布与一次完成消费闭合。全冷101,335cycles，cfg→消费46,918cycles；full guard893.130500s、child0/null。AT026 pilot FAIL及AT027 pilot COST_STOP保留。测试台逐笔验证范围外AW与WSTRB，但未做独立DDR哨兵最终读回；Wi→G同runtime和完整请求/恢复/物理仍未验。本轮无本项目重工具运行，交主控集中审核后选择下一连接。

## 2026-10-13 Attention ATN0 完整head计量

[ATN0报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN0_attention_softmax_measurement_20261013.md)：AT020沿原v10冻结DUT及独立gold，static/16行pilot/单进程128行full正常数值和计量均有限PASS。全TB1608896cycles，QK/SM/AV首次done口径250888/287173/66256；softmax四状态互斥和与命令区间相符，EXP270525cycles。四worker输入等待147456 slot-edges、core busy898680 slot-edges；四worker条件服务下界224670，与当前EXP区间相差45855，非保证收益。AT019观察断言失败原样保留。A002将仅据此做同M16/A16/D4/EXP4资源的一个ATN1调度候选，原数值/首错/CE/reset和完成消费不变。当前无本项目重工具运行；M003/M004完整目标未完成。

## 2026-10-13测量优先阶段LQ0/LQ1交付

LQ1R时序修复AT017/AT018两版均主机对照及单LN HLS生成PASS，但估计slack−0.43/−0.41ns，未达合同RTL入口；static/pilot/full及F9 case5/6均NOT_RUN。本方向按两版上界停止，详见[LQ1R停止报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1R_timing_no_go_20261013.md)。

按主控D-M004-LNQ-MEASUREMENT-01，本轮独立16行LN→真实store→Q/fullA已收束：[LQ0基线](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ0_measurement_20261013.md)与[LQ1同口径对照](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)均有限数值PASS。LQ1全TB659334→528307cycles，减少19.8726%，但HLS估计slack降到−48.76ns；保留局部周期候选，不签目标频率或生产请求。KB1保持，KB2/CT0本轮已收束，M003/M004完整目标未完成；整体executor/冷INIT/恢复扩展继续停排。

[E003/R002](../../project/E003_production_chain_closure/experiment_results/runs/R002/run.md)真实依赖与身份准备完成，准备子检查PASS；M003仍unassessed、L0 PARTIAL、L1–L5 NOT_RUN。精确命令/日志、当前闭包、新路径与保护记录可独立复核。

完整请求57项依赖（源码56＋1header），对旧47项（源码46＋1header）新增12/移除2/改变7；旧完整回归不能覆盖新源码。最终生产生成闭包、新包/build/请求身份与CPU/真实CSim/RTL验收尚待实施。

下一入口为补齐L0并实施L1 cmd16/rsp8、两个私有FIFO、单持久服务与13BO/安全AXI仲裁；随后真实Wi→G→quant→Down和恢复验证，最终稳定身份后完整回归。M003之后继续M004全模型集成和性能优化。

[主控同步项](../../project/E003_production_chain_closure/experiment_results/controller_start_notice.md)：旧A002共享绑定待同步。旧A002验收result/state/status快照在E003/R001/previous_A002_snapshot；原E002验收/handoff仍为已完成历史交付，不随实时状态重写。当前没有后台实验运行，实际模型/强度仍null。

## 2026-10-15 M004/SM004修订10阶段交付

[E004/R001既有阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)登记AT166真实同输入LN→Q→Wi→G→Q→Down完整cold/warm两命令逐位PASS_SCOPED；每命令Wi 20992 PS、G 2624、Down 10496 PS、最终1024 F32，warm零新增W/AUX AR。AT168/169分别在真实Wi行流水入口接受2/提交0与G发射2/返回0/credit2窗口共同reset，510拍隔离PASS_SCOPED；AT168的FP=2仅为TB行流水握手计数，未采真实浮点IP输入/返回。AT167守卫误判复位计数回退的COST_STOP及202.464809s保留；AT168/169相对AT167仅修守卫epoch，顶层RTL/IP/gold与AT166相同，AT167新TB负责本次复位覆盖。修订10static1113.567624s/1800s、RTL3459.293175s/3600s，余RTL140.706825s，不再原样跑长例。数值bad/poison动态映射、错误后完整warm、reset后完整cold和主动反压/读释放竞争仍开放；新顶层无OOC/P&R/完整图结果。三份E004摘要及本状态已更新，主控阶段审核不等于M004完成。

## 2026-10-15 M004/SM004修订13 flush错误出口局部交付

[AT212–214机读账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev13_guard_ledger_AT212_AT214_20261015.json)与[阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)记录旧wrapper在首段真实flush_done与core回显错误同拍后等待第二脉冲的FAIL复现；新wrapper SHA daae5611…按真实读/rsp及writer债零退出，AT213同边界与既有局部peer回归PASS，AT214真实core/IP静态展开PASS。AT204完整真实链仍只属于旧wrapper身份。修订13累计static615.5153379254043043s、RTL1498.1496843509375738s；host完整UNKNOWN，完整模型/物理未验。

主控D-M004-REV13-CLOSEOUT-01按分版证据接纳并收束修订13；AT212–214实际七笔guard（3 static＋4 RTL），先前交付文字“六笔”仅为计数笔误，原费用不变，余额封存。
