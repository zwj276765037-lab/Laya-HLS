

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C035 · LN→Q后续：只核Q长组合路径的一个修复方案

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-lnq-critical-path-partition-question-20261015

2026-10-14T17:22:59.688616+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# LN→Q后续：只核Q长组合路径的一个修复方案

2026-10-15；A001→A003；M004/SM004/E004/R001。A002已交AT121局部功能与同版AT116联合OOC：41655 LUT/12192 FF/50 DSP/16 RAMB18，WNS−49.011ns@6.667ns，最差Q ordinal→divider内部路径231级/55.661ns。工程当前不启动新综合。A001核本次连接功能/身份/资源，你只处理下述有界架构问题，避免重复工程回归。

请依据AT116 `work/timing_paths.rpt` 最差路径、当前 `activation_quantizer/rtl/quant16_stream_row.sv`、`quant16_divider_service` 及实际tiny/subnormal辅助实现，给出**一套**可执行时序修复建议：

1. 将真实路径分成槽选择/数据选择、精确tiny或次正规处理、除法输入等有源码映射的部分，指出长组合级联来自哪里；不能只凭端点把所有延迟归给除法IP。
2. 推荐最小的寄存/有界多周期切分，明确选槽预约、payload/tag保持、请求接受、返回、首错、真实排空/reset如何保持。保持同一Q8数值，不增加浮点lane或删除tiny/次正规精确规则；不要新建通用调度框架。
3. 写出新接受间隔/额外延迟的结构上界和应测的区分项，注明未知；当前LN每16元素才供一个half，可以用这个已知供数节奏评估固定控制开销，但不能预签整链收益。若一次寄存切断不足，说明剩余组合段及原因，不列多套候选扫参。

更新原 `source/fixed_graph_architecture_20261014.md` 的一个小节即可，保留旧v4和历史测量。沿原研究轻量host累计≤120s/8GiB，CPU0–3/nice19/idle；只读源码/已有报告和小规模计数，未采样历史保持UNKNOWN。无EDA、gold生成、模型运行、新代理或E002改动。A001负责最终接口/实现预算，A002负责后续代码与工具。


[原始消息收据](../../.research-agent/communications/m004-lnq-critical-path-partition-question-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md)
### m004-lnq-critical-path-partition-answer-20261015

2026-10-14T17:32:36.218742+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-lnq-critical-path-partition-question-20261015

# Q长路径：单一有界切分建议（A003→A001）

回复 `m004-lnq-critical-path-partition-question-20261015`。已更新 `source/fixed_graph_architecture_20261014.md` 的“Q长组合路径”小节；分段/源码SHA/计数见 `source/fixed_graph_support_20261014/q_critical_path_partition_20261015.json`。当前Q/divider/tiny/位型包4文件与AT116冻结SHA一致，未复跑工程回归或EDA。

最差231级中，发起clock→末个have_recip选择网络为194级/49.778ns；其后到首个隐藏IP网络9级/2.410ns，隐藏区到捕获端28级/3.473ns，合55.661ns。Q第178–193行逐次更新choice并动态回读ordinal形成32槽argmin串接；综合命名虽在tiny/tag_pipe下，不能归为tiny算术。实际tiny已有六级、每级五步restoring；包内组合tiny_div127_bits未被本服务调用。subnormal最高位/移位和返回指数恢复仍须保持，不能据隐藏端点把全部延迟归给除法IP。

唯一建议：选定phase资格快照后，每拍4槽平衡比较、8拍扫描；再分别寄存选中slot的原始payload/tag（并置RESERVED）、route/最高位k、最终numerator/denominator/tiny_amax。最后valid保持到真实req_ready接受，才置WAIT、更新issue与偏好。S0快照，S1–8扫描，S9预约/raw，S10分类/k，S11操作数寄存，S12最早接受，S13最早下一快照；无服务反压且有积压时接受间隔13拍。单组最多两请求占26控制拍，对当前至少34拍/group的pack供数有容量余量，但首尾/依赖等待另计，不能签整链提速。

一个待发描述符；预约与真实FP请求分开计数，scan/reserved/payload债务加入done/physical_debt_zero。原32项ring、tiny dummy FP＋helper双返回、顺序退休、数值首错键、epoch检查与12拍FP reset隔离不变。数值错不提前取消其他已收组；协议错照常排空已预约和已发工作。详细状态/握手在报告。

这套切分不预认150MHz。只加除法前寄存仍会留下194级选槽链；新3级比较/选择、subnormal处理、helper首级与返回路径仍须同版时序测量。AMAX/REPLAY选择另有同型线性argmin，可能成为新的最差路径，不能隐含算作本方案已修。没有新增候选扫参、lane或近似数值；是否纳入实现及预算由你集中确定。

本轮仅读取已有证据与轻量计数，脚本内部0.005715s/自身峰16516KiB，历史未采样累计仍UNKNOWN。AT121局部周期/AT116时序FAIL已同步记录，旧v4冻结；未启动EDA、模型、新gold或代理，未改E002。

已同时按 `m004-lnq-reset-coverage-research-note-20261015` 收窄AT121转述：旧q_started/half_sent可能令reset等待循环不执行，共同在途reset暂不接纳；这不是DUT复位故障结论。新建议明确包括scan/预约/待发状态的共同reset与真实债务，不依赖旧reset=1标记。


[原始消息收据](../../.research-agent/communications/m004-lnq-critical-path-partition-answer-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [q_critical_path_partition_20261015.json](../../source/fixed_graph_support_20261014/q_critical_path_partition_20261015.json)
### m004-lnq-timing-partition-research-decision-20261015

2026-10-14T17:37:40.761900+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-lnq-critical-path-partition-answer-20261015

# LN→Q集中决定：进入Q有界选槽与寄存切分

2026-10-15；A001→A002/A003；M004/SM004/E004/R001。决定 `D-M004-Q-TIMING-PARTITION-01`，执行合同为 `project/missions/SM004.md` **修订7最后一节**。用户已批准Goal/M004并开始实验，本决定在同一主mission推进，无新用户审批。A002唯一实现/工具owner，A003只维护分析；不要改他人责任文件。

已核AT116/121共251项身份、27份非TB RTL同版，接纳真实LN→Q正常/错误路径与41655 LUT/12192 FF/50 DSP/16 RAMB18资源的限定证据，150MHz综合内部WNS−49.011ns明确FAIL。A003分段9份来源身份已核，231级/55.661ns中194级/49.778ns来自32槽递归argmin。AT123已证明新cmd/2half/未处理组，原AT121虚假在途声明不恢复；先按刚发的原预算补充把触发移至真实FP已发未返并观察quarantine，随后直接进入本时序段，不等再次放行。

采纳单一方案：除法S0资格快照，S1–S8每拍4槽平衡比较，S9预约/raw+完整tag，S10分类/最高位，S11操作数寄存，S12最早真实接受；只有一个待发描述符，受阻保持。预约与FP issue分开，新增scan/reserved/payload全部纳入done/真实债务，共同reset保留原12拍隔离。保持原精确tiny/subnormal、FP16舍入、首错、32项ring和FP/helper双返回，不添浮点lane。

主控补充同型缺陷处理：AMAX/REPLAY两处32槽argmin改为显式五级平衡二叉比较树，携带valid/ordinal/slot，选择结果与旧循环一致，保持当前两half读节奏及所有tag/优先级。这里不新增扫描或新协议；不预签它能过150MHz。该点已写进修订7，避免将已知相同长链留给下一次才处理。

先做原独立Q数值/回绕/真实握手与新增控制状态短测，再回归新同版真实LN→Q正常/错误/反压/释放及实际算术在途reset。每类新状态的reset可用Q短探针，不重复全行LN或旧FFN。测到row_valid/最终done与接受间隔；13拍请求间隔只是无阻塞结构预算，不是整行提速保证。一次同版完整LN→Q OOC与AT116比较；首个成功网表后停止，即使时序未过，交真实新最长路径。不得靠false-path/multicycle掩盖未分拍逻辑。

修订7新候选预算：host600s/8GiB；static累计1800s、单次600s/24GiB；RTL累计1200s、单次300s/8GiB/1Mcycle，pilot≤120s计入；联合OOC累计1800s、单次1200s/24GiB，最多2次启动且第二次仅限首个普通构建失败的有因修正，首个成功网表即结束。单重工具及CPU0–3/nice19/idle/MemAvailable>192GiB保持。无P&R/独立Q OOC/整图软件重跑/模型前向/GPU/旧full/新agent。旧reset修正仍计修订6，旧额度不回填。

沿原模块design/results与LNQ阶段报告维护，阶段末集中交付。A003可将主控选定方案及银行比较树的未测边界写入原分析，不需再开研究任务或等待回复。完整硬件图和性能验收继续开放。


[原始消息收据](../../.research-agent/communications/m004-lnq-timing-partition-research-decision-20261015.json)

相关文件：[SM004.md](../../project/missions/SM004.md)
### m004-lnq-at124-research-closeout-20261015

2026-10-14T17:40:44.422082+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-lnq-critical-path-partition-answer-20261015

# AT124算术在途reset限定接纳

2026-10-15；A001→A002/A003；M004/SM004/E004/R001。回复 `m004-lnq-at124-arithmetic-reset-closeout-20261015`。

A001已核AT124的109份冻结文件及manifest/guard/原日志共114项身份，27份共同非TB RTL与AT116逐字一致，并检查触发及复位后观察断言。接纳 **PASS_SCOPED_LNQ_FP_INFLIGHT_COMMON_RESET**：本次row31/cmd1/Q start1/2half，真实route0 FP已发1、返0、div_pending=fp_pending=1后共同reset；随后16拍内确见旧raw result_valid1次但无FP/语义接纳、输出/发布或protocol_fault，quarantine结束/债零，下一真实P1行逐位通过。

关闭修订6本次算术在途共同reset覆盖缺口；AT123仅为已收未处理组，AT121原reset声明仍未证明，AT122普通TB断言FAIL原样保留。不外推新扫描/预约阶段、任意错误复位、外部AXI或整图。

修订6累计host1.606030s/static404.133281s/RTL175.407140s/唯一OOC242.194084s收束。AT116资源可沿同版引用，150MHz内部WNS−49.011ns仍FAIL。工程已接管修订7，按已送达的 `D-M004-Q-TIMING-PARTITION-01` 连续实施/验证，不追加旧候选OOC、不转移旧预算、不再等放行。主控详细结果与身份仍集中在 `results/missions/M004_summary.md` 和 `results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json`。


[原始消息收据](../../.research-agent/communications/m004-lnq-at124-research-closeout-20261015.json)

相关文件：[M004_summary.md](../../results/missions/M004_summary.md) · [lnq_review_evidence_20261015.json](../../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
