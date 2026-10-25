

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C016 · 用户要求立即调转重心：先停止旧关键路径扩张

状态：**待验证**。FFN3 AT062语义失败已集中核定；FFN4仅分离Wi DDR与Down STATE1描述符合同已直接送达，待受影响新static/短测/前缀及有据full；M003/M004保持开放。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### user-work-focus-switch-immediate-20261013

2026-10-13T05:16:47.450101+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：question；送达：delivered；回复关联：未登记

# 用户要求立即调转重心：先停止旧关键路径扩张

来源：当前主控会话2026-10-13用户原话“马上调转目前的工作重心 重新规划当前工作内容”。这是用户最新优先级指令，覆盖此前将完整executor生成列为所有硬件测量前置的排程；最终完整加速器目标和真实性/数值/资源约束不变。

立即执行，无需等待后续详细计划：

1. 停止启动新的executor HLS候选，包括冷INIT的HLS05；冷INIT、LTP collector/exporter、CLOSE/rearm和新managed adapter/cleanup扩展保存当前进度后退出当前优先队列。不要删除、回退他人改动或覆盖已有冻结。已经真实启动的唯一重工具沿原guard收束，保存实际终态，不续跑后继阶段或自动重试；若无在跑工具，不为收尾启动一个。
2. A002继续唯一实现/整合/重工具owner。请让现有A004/A005/A006停止追加上述旧方向任务，在自然交付边界保存现状，转为现有真实算术生成物/runner的有界盘点；不新增agent。
3. 当前首要交付改为独立于FullRuntime/executor的真实算术测量路径。立即盘点可复用的LN、Q、Q8矩阵/G/Down/Attention实际生成模块、冻结输入与gold、有限RTL runner、原始cycle/AXI/资源报告。允许受控testbench/诊断driver只在该有限算术实验中驱动真实kernel；必须写清它不代表生产控制链/完整请求，但不要再把真实program/executor/CLOSED作为算术测量前置。不改变原算术/独立gold或在DUT中跳过必要的真实数据传输与存储规则。
4. 请集中回传：当前真正运行的工具/是否已按原guard收束；已停排项目与保存路径；最短可执行算术baseline（精确模块/输入/输出量/生成身份/runner/预计成本/缺口）；以及能最早优化的一个实际瓶颈。此为排程调整与盘点，先不启动新重工具；主控正在形成带出口/换路条件的详细合同，会直接下达。

M003生产集成暂缓新增实现，未完成项仍记未完成，不取消或伪称验收。M004完整目标保持。资源约束、G2338.224019s仅OOC余额、5172s组合不重启、无新增OOC/P&R/上板预算保持。


[原始消息收据](../../.research-agent/communications/user-work-focus-switch-immediate-20261013.json)
### work-focus-switch-immediate-ack-20261013

2026-10-13T05:19:04.080587+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：user-work-focus-switch-immediate-20261013

# 立即换路执行状态（先交收束事实，算术盘点随后集中补交）

回复 user-work-focus-switch-immediate-20261013；A002唯一整合。已落实用户最新优先级，不启动executor HLS05/冷INIT生成或任何旧方向后继。当前无在跑重工具。此前真实启动的collector RTL01已按原guard自然完成，原收据PASS_SCOPED_RTL_TRANSACTION_COLLECTOR；实际FSM exporter、adapter/F10/sidecar、hub cleanup及same-runtime C仍NOT_RUN。此有限出口不扩大生产链范围。

保存而退出优先队列：
- 冷INIT：E002/include/laya_cold_table.h、laya_executor_cold_init.h、hls/control/executor_cold_init.cpp及受影响full_runtime/task_reservation/actor/top/source清单；FIRST七case host09已PASS，host08首case因新TB把queued input sentinel套进旧no_dispatch断言FAIL保留，09仅修该检查。全定义默认值新test/runner准备由A005在自然边界保存；未跑，executor HLS05未创建/未启动。
- 真实pending exporter：include/laya_executor_transaction_export.h与hls/control/executor_transaction_export.cpp，未编译/未接top/source/端口。A004 exporter后续只读委派因agent thread limit未启动，不能记已执行。
- collector：rtl/laya_executor_transaction_collector_v1.sv、tb/laya_executor_transaction_collector_tb_v1.sv及run_executor_transaction_collector.py；RTL01有限受控输入完成后不续跑。
- managed adapter坏帧隔离：host02原88+两独立坏帧process PASS；HLS01真实guard PASS/462.750790s/peak6140864KiB，实际生成top，但脚本最后复核live原文件时因root独立冷INIT改动full_runtime/task_reservation而FAIL。原FAIL保留；另immutable_generation_audit核809 frozen pair/8676immutable引用、精确27端口（8FIFO/24信号）PASS，只签冻结生成出口，不签RTL。无重跑。
- CLOSE/rearm与撤销后首END/INVALIDATE仍未闭合，暂停新增实现，不把未完成写成验收。

A005/A006已通过实际消息收到停止旧方向、保存现状及转只读算术盘点；A004交付后已不在live agent列表，向其followup/send因agent thread limit失败，未重启或新增agent。Root承接其Attention盘点，不让消息失败阻碍换路。

现盘点LN/Q（A005）、Q8 matrix/G/Down（A006）与Attention（Root），精确核冻结kernel、原真实输入/gold与runner/cycles/AXI/资源，独立算术实验允许受控driver，但不代签production/完整请求。新重工具均NOT_RUN，待主控详细合同。M003未完成，M004目标、原资源帽、G仅OOC余额和5172s不重启保持。

证据：R003/executor_hls_host_08、executor_hls_host_09、executor_transaction_collector_rtl_01、controller_transaction_adapter_managed_host_02、controller_transaction_adapter_managed_hls_01原收据与controller_transaction_adapter_managed_hls_01_immutable_generation_audit_20261013.json；共享模块source/design.md/results.md与A004/A005/A006/result.md保存原方向工作。


[原始消息收据](../../.research-agent/communications/work-focus-switch-immediate-ack-20261013.json)
### measurement-first-plan-dispatch-20261013

2026-10-13T05:23:38.642035+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：work-focus-switch-immediate-ack-20261013

# 当前工作重排：算术测量优先，控制架构单独检验

决定：D-M004-MEASUREMENT-FIRST-01；2026-10-13。直接依据当前主控会话用户指令：“马上调转目前的工作重心 重新规划当前工作内容”。M004完整加速器目标保持，当前工作转入SM005/E005/R001的有限算术测量与优化。A002唯一实现/整合/重工具owner，A001负责架构取舍和集中验收。

## 立即生效的改变

**撤销“必须先生成完整executor，才能开始硬件性能工作”的排程。M003是最终生产集成验收的依赖，不再阻塞SM005的局部测量与优化。** 本文覆盖旧首请求A→B→C→D计划及冷INIT决定的当前执行顺序；旧协议正确性规则仍适用于生产路径。

工程已回报当前无重工具运行，executor HLS05未创建/启动；冷INIT、pending exporter/collector、managed adapter和CLOSE/rearm新实现已保存并退出优先队列。其既有PASS/FAIL/未执行范围保留；此处只确认工程收束报告，不顺带验收新交付。后续未经本计划的实际依赖证明，不恢复这些工作。

当前不新跑完整executor、program或adapter HLS，不扩展恢复矩阵，不新建通用控制协议。必要数值检查、实验内真实存储/反压/债务规则继续保留；遇到实验内错误就按现有机制停止该样本并记录，不要求实现全局请求恢复后才能测下一个独立冷启动样本。

## 第一条工作线：可运行的算术基线及优化

局部基线命名KB0，改进候选KB1/KB2；完整请求B0/B1名称留给未来真实集成。测试台可以驱动真实硬件kernel、提供该实验声明的模型输入和存储响应，不能计算并注入被测kernel的输出、伪造其完成或跳过声明边界内的真实读写。测试台控制、预量化输入和不包含的上游计算逐项列明。这条工作线不依赖生产executor、HOLD/IMPORT、CLOSED/rearm或完整13BO。

| 顺序 | 工程工作 | 必须交付的结果及出口 |
| --- | --- | --- |
| P0，立即 | 一次有界盘点已冻结算术模块及runner，选一个可复用入口，不重新审核全仓库 | 一张表列模块/身份、真实输入/gold、覆盖量、原cycles、缺少计数器、可运行入口及预计工具成本。先核所选闭包，其余只列证据路径；无需完整清理历史才能执行P1。 |
| P1，首要工具任务 | 默认从四行resident Down开始；实际不能复用时按下述规则换入口。保留原gold，增加最少的观测 | KB0的实际数值、周期和瓶颈表：输入/权重/PS反馈/计算/输出等待，实际AXI与完成消费。已充分记录且身份匹配的旧结果直接继承；只为新观测或变化依赖运行受影响范围。 |
| P2，紧接P1 | 从测得的主要等待或存储成本选一个改动，完成相同输入/边界的A/B对照 | KB0→KB1的数值检查、周期/停顿变化、资源代价或明确UNKNOWN。最多两个不同候选；有收益保留，无收益也必须给出可检验原因及下一取舍。常规实现/修复按原授权连续执行。 |
| P3，与P0/P1并行只读 | 审视生产控制架构，提出下一版硬件控制状态/接口划分 | 一页比较表和主控决定，见第二条工作线。当前不启动控制器重工具；不得挤占P1/P2。 |

### 默认入口与换路规则

第一选择是原`resident Down`四distinct行、K2624/N1024、4096最终F32、真实512 AW/W/B的有限算术链。已有48862cycles记录；输入是预量化A，bias kind0，初始reset，不能称完整LINEAR或完整请求。先核本项目内冻结RTL、真实模型数据/gold、原runner及路径映射；禁止向旧baseline写回。原记录见[工程验收P3](../../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)。

若该入口的生成身份/工具依赖确实不可复用，**直接换到已冻结LN→Q**：`layernorm_quant_source_03`的rows16/D1024、16384 F32、16384 INT8及512 FP16 gold。其真实LN stores、monitor/hub与source lease路径保留；TB发Q只签此算术实验。旧rows1 pilot不含完整Q计时，不能代签rows16；full原成本约753.5s，只在同profile pilot/原帽可承受时执行。需要更小样本时明确建立该范围的KB0，并保持候选同样范围。

已有Attention v10完整head结果可直接作为候选选择的历史依据：604317cycles，原同fixture标量6816248cycles，只有模块范围；不为补充盘点重跑整个head。若工程盘点证实另一冻结kernel明显更短、更可用且能回答同一性能问题，可以记录具体理由后自主选择，不必再次请主控逐项批准。

### 测量与改动规则

- 首先核独立数值正确性，再比较真实硬件周期。软件耗时、编译指令数、模块对象大小不作为硬件性能。统计起止握手写清楚；计算区间、加载/填充、末B/完成消费、测试台故意等待分别报告，不能静默剔除改动引入的等待。
- 多个stall条件可重叠时标明非互斥；若声称总周期分解，则每周期分类须互斥且和总周期相符。不因单请求结果报告稳态吞吐，也不因未重复测量报告冷暖差异。
- 第一候选优先选择供数/复用、PS反馈、buffer映射、流水或输出等待中有实际证据的一项；不预先扩大并行度或改数值顺序。保持冻结模型/输入/gold与算法规则。资源先用所选身份的现有报告/新HLS估计及明确的存储账，缺联合/物理结果就记UNKNOWN。
- P1没有准备完毕不得顺手修完整生产控制链。选定入口最多两轮有明确原因的受影响修复仍无有效数值样本，就标记该入口暂不可用，切换上述备选；不得通过删除断言/改gold放行。
- P2同一假设出现两次有区别候选仍无可复核收益或均因相同生成成本停止，就停止该假设并选择测量支持的下一瓶颈。原样重试、提高帽、持续堆叠先决条件均不作为进展。

P0建议一个不超过30分钟的有界盘点工作段；若有项目无法核清，记录UNKNOWN并推进已核清入口，不无限补清单。P1进入执行后，下一份实质交付应是KB0数据或具体失败/换路决定；不以新控制协议PASS代替。这里的时间是工作分配上界/复盘点，非工具必然完成承诺，亦不设置无人值守自动监控。

## 第二条工作线：重新选择控制架构

四次executor HLS停止不足以证明所有HLS方案无效，但当前“将整个软件FullRuntime及其验证/状态对象直接纳入top”的表示方式退出默认路线。冷INIT补丁保留为未生成候选，不把它作为下一次必跑实验。

P3比较三个选项：

| 选项 | 当前处置 | 要回答的问题 |
| --- | --- | --- |
| 现有FullRuntime整体HLS及冷INIT变体 | 保留证据，暂停新生成 | 哪个实际pass/对象证据支持再次投入；若只有尺寸猜测或局部host PASS，不恢复为主路线。 |
| 面向硬件的薄控制器：显式寄存器/有界表RAM/有限微步骤，软件reference独立 | 优先设计候选 | 哪些状态必须在FPGA持久存在、由谁唯一写；原容量/高水位/错误义务如何保留；哪些纯验证/编解码表示可分阶段实现，避免把整个host对象图拉入一次生成。 |
| 小型手写RTL控制状态机连接现有算术核 | 同范围备选 | 在同一功能/状态容量/接口条件下，与薄HLS实现相比的验证工作、生成成本和控制周期；不以缩小语义伪造优势。 |

这不是把FPGA任务搬回CPU。软件reference用于gold/验证，最终的算子、调度及原CPU/FPGA分工保持；如需改变真正分区/跨界接口，由主控就最小受影响合同给出明确新定义。架构文档应列字段/存储规模和唯一权威，不用C++ABI尺寸直接当LUT/BRAM预算。

恢复控制实现的条件是：P1已形成可用的算术测量路径，P3有明确的硬件状态/存储/调用边界及一个最小可证伪生成目标，由主控集中选择方案。用户不需要逐项审批。选定后先验证一个有界控制目标的生成和实际行为，未达出口不扩展全部恢复/全图；重复同点停止必须重新作架构判断。任何局部控制原型仍不能代签生产请求安全完成。

## 所有权、记录与资源

A002负责KB0入口、唯一实现与所有工具排队；现有A005负责LN/Q可复用证据及gold，A006负责Q8/G/Down入口与瓶颈计数，A002承接Attention及整合。A004已不在live列表，不为重排重启或新增agent。A001负责本计划、P3选择、阶段审核和最终目标；不执行DUT工具。

代码仍仅在E002/experiment，新增测量driver/计数器按模块目录放置；不为重排复制实现树。已有E003/R003原始attempt原样保留。新测量证据在E005/R001，采用KB0/KB1语义标签与独立AT尝试；未执行保持NOT_RUN。工程更新E003暂停/保留项和E005当前三摘要，不把主控登记当实验完成。

全项目仍单重工具、CPU0–3/nice19/idle I/O/MemAvailable>192GiB；原static/HLS24GiB/1800s、120s真实进展保护、RTL8GiB/3600s/40Mcycles及更严格入口帽、pilot≤120s保持。**本轮不安排新OOC、P&R或上板**，G2338.224019s仍仅OOC余额，5172s组合不重启。最多两个改进DUT候选是本轮复盘边界，不是新增或可转移工具预算。

当前成功出口是“可复核KB0＋至少一个同口径候选判断＋明确的控制架构取舍”。随后继续选择实测瓶颈并逐步恢复生产集成；完整M004仍必须满足全模型、真实请求、恢复、资源及性能原验收，局部KB结果不能关闭总任务。


[原始消息收据](../../.research-agent/communications/measurement-first-plan-dispatch-20261013.json)

相关文件：[engineering_acceptance_20261011.md](../../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)
### measurement-first-P0-entry-progress-20261013

2026-10-13T05:35:29.416390+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-plan-dispatch-20261013

# 测量优先P0落实与P1入口

回复 measurement-first-plan-dispatch-20261013；M004/SM005/E005/R001，A002唯一整合/工具。当前本项目无在跑重工具，executor HLS05未创建/启动，旧控制源码及终态保留，E003三摘要已标新增暂缓，E005三摘要/协议已同步。A005/A006已收到新合同并转原职责，没有新增agent。

选原冻结resident_regression_02为KB0，26源/12fixture已核，原48862cycles只继承该版本；六处live漂移不混入。A006正准备新有界计数TB和runner，新增AT001；下一工具是Down static→≤120s pilot→有依据full，补加载、互斥状态、接口停顿和真实done消费，保持全部gold/AXI/末B及7周期响应反压。新KB0数值/周期尚NOT_RUN，普通P1按新授权直接启动不等控制器。

LN/Q备选已核03/04各303项，上游40项、16384F32/INT8及512scale和真实store重读；原659334为全TB，full753.504s。Attention93源/81snapshot匹配，原604317正常cycles，其中SM287173/47.52%，不重跑head。详细一表见 reports/arithmetic_entry_inventory_20261013.md。

P3有界硬件持久状态/容量/唯一writer表由A005只读准备，随后交薄HLS/RTL/FullRuntime比较，由主控选择。P2待新KB0计数选一个实测瓶颈，不先承诺收益。原资源帽、G仅OOC余额、5172s不重启、无新OOC/P&R/上板不变。

路径：project/E005_full_request_performance/experiment_results/runs/R001/reports/arithmetic_entry_inventory_20261013.md


[原始消息收据](../../.research-agent/communications/measurement-first-P0-entry-progress-20261013.json)

相关文件：[arithmetic_entry_inventory_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/arithmetic_entry_inventory_20261013.md)
### measurement-first-P0-entry-review-20261013

2026-10-13T05:37:50.881189+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-P0-entry-progress-20261013

# P0入口确定，继续Down KB0计量

回复measurement-first-P0-entry-progress-20261013；M004/SM005/E005/R001。沿D-M004-MEASUREMENT-FIRST-01，采用resident_regression_02冻结闭包进入P1，无新增放行条件，工程按原授权继续static/pilot及有依据full。

主控定向核所选26份frozen源码/脚本、12份本项目fixture与原声明SHA，以及原full日志48862cycles/512 AW/W/B标记；不重审备选全树，不执行DUT。六处live漂移与KB0冻结隔离。P0入口盘点可以结束，AT001新数值/周期仍NOT_RUN；原结果只按旧冻结身份继承。

P1/P2计量解释明确如下，均纳入当前最少计数，不另开一轮框架工作：

- 48862是原全TB周期，不直接当kernel计算延迟。新表同时给出全TB、真实cfg接受→done有效、cfg接受→done实际消费；reset/fixture准备、A/W实际加载、输出末B及7周期故意完成反压按真实事件定位。哪些加载处于cfg前由实际波形/计数决定，不能为得到漂亮结果重划边界。
- 原held_B=9217仅作为原反压行为记录，先核其定义及与其它状态重叠，不能直接全算成可消除的DUT瓶颈。KB1保持同一AXI响应策略、7周期完成反压和全部gold；减少测试台等待不能算优化。若后来专门研究另一反压profile，给它独立同profile基线，不混入本对照。
- 互斥状态之和只应等于声明的对应测量区间；非互斥接口stall单列。P2从真实有优化空间的等待/工作量选一个原因，不从最大表项直接推断根因，收益先给实测cycles差及其适用边界。
- pilot的PS前缀检查不代签最终输出/末B。按新profile实际速率、最终数值比较及输出排空阶段保守估计full成本；沿原帽，不因表格尚缺不相关字段延迟首个有效算术样本。

P3只读表并行继续，交字段/容量/唯一writer、可综合存储表示、最小生成目标，以及薄HLS与RTL的具体取舍；不要为此恢复FullRuntime/冷INIT生成。完整生产入口/恢复仍停排，现有所有资源约束不变。

下一实质交付是KB0数值及计量表或具体失败/换路决定；KB0可用后按原计划直接做一个有证据的KB1，不等待完整控制器。局部结果不代签完整LINEAR/13BO/全请求。核验见[所选闭包记录](../../results/measurement_first_P0_review_20261013/verification.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-P0-entry-review-20261013.json)
### measurement-first-P3-control-proposal-20261013

2026-10-13T05:38:59.480893+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-plan-dispatch-20261013

# P3只读控制架构提案

沿D-M004-MEASUREMENT-FIRST-01。六群组的持久字段、原容量、逻辑存储账和唯一writer已定向整理；薄HLS/小型RTL/整体FullRuntime三项比较已交。未运行控制器工具，未恢复冷INIT或旧cleanup。

推荐薄HLS显式寄存器+固定RAM+微步骤，软件reference独立；同schema手写RTL为备选，不能凭当前四次停止宣布所有HLS无效或RTL更快。生成/资源/控制cycles仍UNKNOWN。最小目标提案限定完整A/K/route、一action、validate-before-commit、真实24LTX/16LTC及半帧/撤销保持，未扩到完整actor或请求退休；请主控在P1有样本后集中选择具体目标/schema，不把本提案作为P1等待项。

证据：project/E005_full_request_performance/experiment_results/runs/R001/reports/control_state_inventory_20261013.md；同目录control_architecture_comparison_20261013.md。P0已按答复结束；A006正在落最少计数TB/runner，随后A002直接启动Down KB0。


[原始消息收据](../../.research-agent/communications/measurement-first-P3-control-proposal-20261013.json)

相关文件：[control_state_inventory_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/control_state_inventory_20261013.md)
### measurement-first-P3-design-review-20261013

2026-10-13T05:41:22.007995+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-P3-control-proposal-20261013

# P3只读提案评判：优先薄控制器，最小目标尚不冻结

回复measurement-first-P3-control-proposal-20261013；M004/SM005/E005/R001，沿D-M004-MEASUREMENT-FIRST-01。

六群组状态/原容量/唯一writer与三方案比较已满足本轮P3的有界盘点交付。薄HLS显式寄存器/固定RAM/有限微步骤保留为优先设计方向，手写RTL保持同schema备选；整体FullRuntime及冷INIT继续停排。**这是设计候选排序，不是生成可行性、资源或控制周期的验证结论。** 当前无需补新清单、试验脚手架或控制器实现，人员与工具继续优先P1/P2 Down。

有两点影响后续架构选择，现明确保留：

1. 报告已经说明host大cache数组、observer等在`__SYNTHESIS__`闭包中原本不存在。“不再纳入这些host字段”不能作为新候选相对executor04的实质减法。需要改变的是实际可达的状态访问、构造/校验/提交及调用图表示。约179.21KiB仅为工程提供的定义字段存储账，主控本轮没有逐字段重算，也未签BRAM/LUT；原容量保持不等于能自动推导出RAM映射、端口或时序。
2. **暂不将所提24拍LTX/16拍LTC片段冻结为下一生成目标。** 若该原型只有A/K/route快照、序列化和已受控的结果接收，容易重复已有宽FIFO/adapter的可生成事实，仍无法区分导致整体executor成本停止的状态表示问题。下一目标应选一张真实、原容量的关键持久表和一条实际“读字段→完整键/条件校验→候选更新→提交或拒绝”路径，检查明确的存储访问及生成结果。完整传输/末拍保持可作为必要边界，但不能成为唯一架构证据。不要求一次实现所有表或完整actor。

待P1已有可用算术样本，再由主控集中选具体表、字段schema和最小目标：优先复用此表中source/window或owner的真实更新语义，明确初始化、同址读写、仲裁以及完整校验前不可见的提交点。保持原容量和唯一可变权威；诊断原型若使用测试自有状态，只能签该状态更新片段，不得接成第二套生产owner/退休权威。此处不给工程追加即时实验，具体选择不阻塞KB0/KB1。

P3当前只读工作可以收束。下一交付继续是Down KB0实际gold/周期/停顿及据此选择的KB1；P1/P2不等待控制schema。原资源帽、单工具、无新OOC/P&R/上板和所有生产未完成项保持。主控仅核提案逻辑及其证据范围，未运行DUT或重做全状态表审计。


[原始消息收据](../../.research-agent/communications/measurement-first-P3-design-review-20261013.json)
### measurement-first-KB0-result-KB1-plan-20261013

2026-10-13T05:57:35.428970+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-P0-entry-review-20261013

# KB0实际算术出口及KB1选择

M004/SM005/E005/R001，AT001已实际PASS_SCOPED_KB0_DOWN_MEASUREMENT，当前KB0工具自然收束。原4distinct预量化Down/K2624/N1024，335872 lane-group PS、4096 F32与原独立gold全比；真实512AW/W/B、最后B/局部publication与一次done消费通过。

全TB48864（原48862加实际consume/deassert检查）；cfg→first done21100，cfg→actual consume21107，故意7cycle done反压保持；A填充666、W加载27064且都在cfg前。互斥state之和21100，接口stall重叠单列。writer packet-not-ready7761、已送AW/W无B8705、PScommit-not-ready9586/nativecredit7414；held_B9217仅TB延迟decrement计数不相加成DUT延迟。有效16KiB/物理32KiB，strobe50%；W加载三路R-not-ready0。

据真实输出工作量和反压选KB1：单pack改按row的4pack，合并相邻半拍，仍一个immutable AXI tx/原验证/最后B及同响应策略、7hold。待实测512→256事务、16KiB物理，额外1923bits逻辑pack字段，物理资源/时序UNKNOWN。只读正常路径audit已交，无新owner/退休权威；继承error窗口未测，局部normal不签通用恢复。A002现在按原授权直接启动新AT002 static/pilot/full，不等控制schema，不新增候选之外工作。

P3已按主控答复收束，薄HLS优先设计/RTL备选仅排序，具体真实表更新目标未冻结。KB1结果后集中交同口径差值及取舍。原单工具/帽/G仅OOC余额、不重启5172s/无新OOC/P&R/上板不变。

证据：project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_Down_measurement_20261013.md；AT001/evidence/measurement/receipt.json及measurement_full.json；reports/KB1_rowpack_static_audit_20261013.md/.json。


[原始消息收据](../../.research-agent/communications/measurement-first-KB0-result-KB1-plan-20261013.json)

相关文件：[KB0_Down_measurement_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_Down_measurement_20261013.md)
### measurement-first-KB0-review-20261013

2026-10-13T06:05:14.770967+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-KB0-result-KB1-plan-20261013

# KB0有限测量接纳，KB1按同响应策略验证合并写

审核R-SM005-KB0-20261013；回复measurement-first-KB0-result-KB1-plan-20261013。M004/SM005/E005/R001，沿D-M004-MEASUREMENT-FIRST-01。**接纳AT001为有限冷样本Down KB0；KB1输出合并有实测依据，按原授权继续，不等待本审核或控制schema。**

## 已核定的基线

四distinct预量化A、K2624/N1024、bias0/冷reset；完整335872 lane-group PS、4096最终F32、独立输出地址去重及原gold断言保留并实际通过。原fullA/dualW/nativeFP、512次真实AW/W/B、最后B、局部publication及一次实际done消费按此范围接纳。

| 同口径测量 | KB0 |
| --- | ---: |
| cfg接受→首次done有效 | 21100cycles |
| cfg接受→真实done消费 | 21107cycles |
| 全TB结束 | 48864cycles |
| cfg前A填充 / W加载 | 666 / 27064cycles |
| 有效输出 / 物理W字节 | 16384 / 32768B |
| AW / W / B | 512 / 512 / 512 |

原48862与新48864的差异来自补做实际消费/deassert检查，不能作为性能退化或改善；KB1以新KB0相同边界比较。主控核实际原始六类计数行与JSON逐字段相同，互斥状态和为21100、首次done到消费7cycles，输出及PS逐项gold检查体保留。writer、PS/native及接口stall重叠，不相加；held_B9217仍只是原TB delay decrement。

26份冻结源/脚本中25份与原基线相同，唯一变化为计量TB；12fixture一致，3native IP身份已核。static/pilot/full各child0/trigger null，full437.203005s低于启动前估计626.625680s；墙钟只作成本。所选核验见[记录](../../results/measurement_first_KB0_review_20261013/verification.json)。未重跑DUT，也未将该样本称作完整LINEAR/请求、暖态或稳态吞吐。

## KB1假设与验收口径

四row pack在同一row合并相邻半拍，目标是以更少物理写事务传输相同16384B。50% WSTRB与实际writer反压支持测试此假设，但不能预签512→256或把“事务减半”当“命令延迟减半”。不同输出顺序下能否正常排空，由实际full结果核定。

保留当前一笔immutable AXI tx、原完整配置/packet/address核验、实际最后B和唯一局部退休。主控核静态报告所列四段原样逻辑与候选身份；这是源检查，不代替KB1数值和动态反压。1923bits是pack字段增量，仲裁/选择/mux及实际映射代价尚未知，不换算成已实现LUT/FF/RAM收益。

同一个TB响应策略意味着保留原按物理beat序号的17+(beat%3)延迟、AW/W周期门及7cycle done保持，**不要求合并后仍凑出512笔事务或相同总B等待**。减少事务自然减少按事务收取的等待属于这个profile下可测的收益；不能把该profile结果直接推广到真实HBM带宽/时延。

候选最终TN8 packet仍512，4096输出字及地址去重/全部PS gold保持；实际AXI事务才可降为256。比较表同时列21100/21107两个命令口径和48864全TB口径、cfg前加载、物理字节/事务及主要重叠stall变化。如果加载保持，就如实给出全冷样本被加载摊薄后的收益，不只挑最好的子区间。

继承的两个错误窗口继续记未测；本normal算术样本出现错误即失败/停止，不在本轮扩通用恢复。接入生产前仍须处理受影响错误语义，局部KB1通过不关闭这些义务。

KB1结果后集中判断收益及下一瓶颈，并合并P3架构取舍；当前优先工具和实现仍给P2。KB0已有样本，不代表薄控制器最小schema已冻结，控制器工具仍停排。原资源帽、单工具、最多两个不同候选、无新OOC/P&R/上板、G仅OOC余额及5172s不重启保持。


[原始消息收据](../../.research-agent/communications/measurement-first-KB0-review-20261013.json)
### measurement-first-KB1-result-P3-handoff-20261013

2026-10-13T06:17:27.276122+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-KB0-review-20261013

# KB1同口径实测结果与本轮取舍

消息：measurement-first-KB1-result-P3-handoff-20261013；回复measurement-first-KB0-review-20261013。M004/SM005/E005/R001，A002唯一整合。EV_SM005_KB1_DOWN_AB_20261013已登记；本消息送达才是实际通知。

**AT002 KB1实际full PASS；保留四row合并写候选。** 同四distinct预量化A、K2624/N1024、bias0/冷reset，原全部335872 PS lane-group、4096最终F32及512 TN8 packet gold通过；实际256 AW/W/B、最后B/局部publication及一次真实done消费通过。未新增第二改进候选。

| 相同边界 | KB0 | KB1 | 减少 |
| --- | ---: | ---: | ---: |
| cfg接受→首次done有效 | 21100cycles | 16183cycles | 4917 / 23.3033% |
| cfg接受→真实done消费 | 21107 | 16190 | 4917 / 23.2956% |
| 全冷TB结束 | 48864 | 43947 | 4917 / 10.0626% |
| cfg前A填充 / W加载 | 666 / 27064 | 666 / 27064 | 0 |
| AW / W / B | 512 / 512 / 512 | 256 / 256 / 256 | 各50% |
| 有效 / 物理W字节 | 16384 / 32768 | 16384 / 16384 | 有效不变，物理50% |
| 首次done→实际消费 | 7 | 7 | 原故意反压保持 |

互斥状态和分别21100/16183；STREAM17992→14453，DRAIN2792→1389，FLUSH59→84。主要重叠条件：writer packet-not-ready7761→2819、tx-valid9858→4928、AW/W已送无B8705→4352；PS commit-not-ready9586→4691、native credit/W return-not-ready7414→3875、W request-not-ready7338→3829。这些条件不能相加成总延迟；原held_B9217→4608仍仅TB decrement。

AW周期门cycle%7、W门cycle%11、每笔B延迟17+(实际物理beat序号%3)、done7cycle保持原样。512→256实际事务自然减少本profile按事务等待，与减少TB策略等待不同；本结果不直接推广到真实HBM或稳态吞吐。全冷A/W加载未减少，收益已如实摊薄，不拿旧48862作本轮分母。

26冻结source仅writer一项不同，其余25项、12fixture、3native XCI及TB/runner/guard/helper一致；entry_static仅期望实际事务覆盖512→256。六类原raw计数与JSON逐字段一致，141个唯一引用文件SHA/bytes核匹配，6guard起止串行、95个实际policy记录符合CPU0–3/nice19/idle I/O。原scope边界与gold断言保留。

KB1 static58.188809s/peak2402228KiB，pilot84.266939s/peak1424908KiB，full431.227749s/peak1426732KiB/2153实际RSS捕获，三段child0/trigger null。full低于启动前runner615.906274s和另存保守成本参考；receipt中的same frozen DUT仅继承算术/fixture旧成本参考标签，writer已变，单列KB1_cost_basis说明，不回写receipt。工具墙钟不是硬件性能。

1923bits新增pack字段仍仅语义存储账，选择/仲裁/mux及物理LUT/FF/RAM/时序、联合资源UNKNOWN。两个继承writer错误窗口未动态验，本normal样本不签恢复/生产接入；无新OOC/P&R/上板，G2338.224019s仅原OOC余额，5172s不重启。

下一有据可选成本是cfg前真实W加载/校验27064cycles，占KB1全冷61.58%；q0/q1/scale实际R20992/20992/2624拍，共2854912B。三路DUT R-not-ready0，TB active gap5248/5248/656仍受控并重叠，尚不能指认具体可消除DUT停顿。建议下一阶段先区分实际供数profile和必要加载/校验/复用成本，不减TB delay冒充DUT优化；暖态或另一profile需独立同口径基线。

P3合并取舍保持主控已核方向：薄HLS显式寄存器/固定RAM/有限微步骤优先，手写RTL同schema备选；FullRuntime整体HLS/冷INIT停排。仅24LTX/16LTC目标未冻结，下一最小目标应包含原容量source/window或owner关键表的真实全键校验→私有候选→一次commit/reject、初始化/同址访问/仲裁。当前不追加控制实现/工具，具体表schema和目标由主控集中选择。

本轮KB0＋一个同口径KB1判断＋P3有界提案交付已完成，AT002 terminal、R001报告、模块design/results、E005三摘要及A002真实状态已同步。当前没有在跑owned重工具；不凑KB2、不恢复旧控制关键路径。请集中核定本轮收益和下一瓶颈/控制目标。M003/M004、完整LINEAR/Wi-G-Q同runtime/13BO请求/恢复/联合资源最终验收仍未完成。

证据：

- [集中比较](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_comparison_20261013.md)
- [可复算JSON](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_comparison_20261013.json)
- [原始与身份核查](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_verification_20261013.json)
- [KB1实际原日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT002_KB1_Down_rowpack/evidence/measurement/raw_full.log)
- [KB1实际收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT002_KB1_Down_rowpack/evidence/measurement/receipt.json)
- [P3既有提案与主控评判](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/control_architecture_comparison_20261013.md)


[原始消息收据](../../.research-agent/communications/measurement-first-KB1-result-P3-handoff-20261013.json)
### measurement-first-W-load-bound-note-20261013

2026-10-13T06:21:33.590810+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-KB0-review-20261013

# KB1后续瓶颈选择：冷W加载的同profile服务下界

消息measurement-first-W-load-bound-note-20261013，补充measurement-first-KB1-result-P3-handoff-20261013。M004/SM005/E005/R001，只读原冻结TB/reader与原计数，未启动新工具或候选。

原集中交付将cfg前W加载27064cycles（KB1全冷61.58%）列为下一大成本；进一步核算后，这个大数不等于读取器调度可优化的时间。q0/q1各真实20992个512-bit R beat，各有5248个active但RVALID=0的周期，R-not-ready均0；冻结TB规定各口`RVALID=q_active && cycle%5 != port`，单口最多每五周期四拍。保持同口/同必读数据/同供数profile，20992拍最乐观至少26239cycles，距实际W加载只有825cycles。即使理想移除全部额外间隙，全冷43947cycles理论最多减少约1.88%，而不是61.58%；这只是上界，不承诺可实现。

由此建议下一同范围候选优先审视cfg→done16183cycles内的PS/计算/真实写入重叠。若主控转向真实HBM服务、W重用或读算重叠，它们改变profile或工作边界，应建立自己的同口径基线并保持真实读写/READY/债务；本轮不擅启KB2或控制工具。新增证据：[推导与假设](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB1_W_load_service_bound_20261013.md)、[可复算JSON](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB1_W_load_service_bound_20261013.json)。既有KB0/KB1数值与周期结论不变。


[原始消息收据](../../.research-agent/communications/measurement-first-W-load-bound-note-20261013.json)
### measurement-first-output-service-bound-note-20261013

2026-10-13T06:28:26.262605+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-KB0-review-20261013

# KB1结果提交与写回：同profile服务边界

消息measurement-first-output-service-bound-note-20261013，补充前两条KB1交付；M004/SM005/E005/R001。仅静态核当前冻结模块与原测量，无新工具/候选。

主控已指向计算期结果提交/写回等待；有一个约束会影响候选选择。KB1有效16384B已全部装进256个512-bit W beat，物理字节同为16384，固定该端口时不能继续减少写拍。当前TB在真实B消费前不再接受新AW/W，256笔17+(beat%3)延迟累计4608次negedge decrement。实测首AW→末B跨度4927cycles；如果首AW时刻不变，只消除其它写回间隙的乐观上限约319cycles，非已证可实现收益。增加DUT待发队列本身不能令这个受控peer在上一B前接收下一事务。多未决B需另一响应profile及其自身基线。

原冻结路径显示最终PS的commit_ready经adapter stored row→bias pending→writer packet_ready传播；PS_commit-not-ready4691、writer-packet-not-ready2819、tx-valid4928和已送AW/W无B4352互相重叠，不能当作各自可消除延迟。若继续同profile，建议优先定位能否更早形成/外发首个完整最终输出，或哪处真实重叠改变末B/完成边界；勿仅从2819stall选更深buffer。范围与完整源码/日志SHA见[只读推导](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB1_output_service_bound_20261013.md)及[JSON](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB1_output_service_bound_20261013.json)。现正常数值与KB1收益结论不变。


[原始消息收据](../../.research-agent/communications/measurement-first-output-service-bound-note-20261013.json)
### measurement-first-early-output-schedule-map-note-20261013

2026-10-13T06:33:29.362466+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-KB0-review-20261013

# 提前完整输出候选：现有接口的必要改动与A重读代价

消息measurement-first-early-output-schedule-map-note-20261013，补充KB1后候选定位。只读现冻结源码，无新DUT/工具。

当前resident按82组×128tile顺序，一组A只读一次（实际82次）；logical_sequence固定`group*128+tile`。同步PS front还硬核`issue_sequence==next_sequence && issue_group==next_group && issue_tile==next_tile`，所以只改resident外层循环会被前端判协议错误。若改tile块顺序以提前首个完整输出，必须同改前端预期顺序并保留canonical序号、每tile组0→81的原累加顺序和全部键/Check。A/W缓存当前read_ok均按真实绑定及范围索引，未见单调group门，但新顺序的实际返回、lease及最终tile/row顺序待验证。

B个tile一块时A读请求=82×ceil(128/B)：B128为82，B64为164，B32为328，B16为656。提前首个完整tile的机会和A重读/握手成本必须同算，不能预签周期收益。这是候选范围约束，细节、源码位置与SHA见[静态映射](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB1_early_output_schedule_interface_map_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-early-output-schedule-map-note-20261013.json)

相关文件：[KB1_early_output_schedule_interface_map_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB1_early_output_schedule_interface_map_20261013.md)
### measurement-first-KB1-review-next-stage-20261013

2026-10-13T06:34:25.357394+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-KB1-result-P3-handoff-20261013

# KB1限定接纳及下一阶段执行合同

回复measurement-first-KB1-result-P3-handoff-20261013，并合并W-load-bound、output-service-bound和early-output-schedule-map三条补充。M004/SM005/E005，A002唯一整合/重工具owner。

主控接纳AT002限定normal四行Down实测，保留KB1。独立复核141引用SHA/bytes、26源仅writer不同、12fixture/3IP相同、两版六组raw计数、6guard串行及95条实际policy。全部PS/4096F32、256 AW/W/B、末B/publication/一次consume通过。cfg→consume21107→16190减23.2956%；全冷48864→43947减10.0626%；均减4917cycles。原profile/7hold不变；物理资源/时序、继承错误窗口及生产完整链仍未验，不关闭M003/M004。主控未运行DUT。

已核W服务下界26239、理想剩余825，以及首AW固定时输出间隙乐观319的条件口径。后者256是最少W拍，不泛指任意burst也必需256 AW/B。因此下一步不优先重做W reader、不仅凭重叠stall加深写队列，也不减TB delay造收益。

本阶段合同已写：[mission/measurement_next_stage_20261013.md](../../mission/measurement_next_stage_20261013.md)，D-M004-KB1-NEXT-01。按此直接连续推进普通实现/验证，无新增逐项审批：

1. 首要一个KB2假设：同Down以两个64tile块调度，块内group0→81，每输出原浮点累加顺序不变，第一块完整结果可先写回。KB1 writer、原供数/反压/数值和真实A/W读取保持；A读取预计82→164并实测计入。resident与front同步维护分块预期游标，canonical sequence=g*T+tile不变，与发出计数分离；完整PS oracle按独立逻辑坐标核，不删顺序/重复校验或改gold。先核已有映射后实施，不用新整链作前置。首AW/末B/实际consume/全冷及重复A代价共同判收益；最多这个候选及两次有证据修复，无收益即交反例，不扫block参数。
2. P3具体目标CT0选32项完整FullOwnerRecord固定RAM，原REQUIRE/ACQUIRE/RELEASE_READ路径；全部字段、两覆盖图、原默认值和TYPE_ROWS依赖保持。完整检查→私有候选→一次commit/reject，单writer、一inflight，原软件helper作独立reference。ACQUIRE按原全键/身份/coverage/readers上限；RELEASE_READ保持原较窄的旧读者释放条件，不新增request_valid或全identity门。测试初始化、全容量、同址/别址次序、拒绝无写及响应反压，真实生成RAM/端口与有限RTL。这个独立诊断不接生产，不产生CLAIM/发布/退休权威。
3. CT0可由现有helper准备schema/reference，重工具在KB2取得结果或有据no-go后再排队。一次薄HLS候选，明确原因可修一次；再次同点成本停则集中取舍同schema RTL，不恢复FullRuntime/冷INIT。只维护原design/results，不造逐步审批包。

原单工具/全部帽/CPU0–3/nice19/idle I/O/MemAvailable门不变；G2338.224019s仅OOC余额，无新agent/OOC/P&R/上板/预算，5172s不重启。整体executor/冷INIT/CLOSE-rearm/cleanup继续停排。新KB2/CT0均NOT_RUN，交付已审核不等于后继已启动。

审核：[results/measurement_first_KB1_review_20261013.md](../../results/measurement_first_KB1_review_20261013.md)；静态核验：[results/measurement_first_KB1_review_20261013/verification.json](../../results/measurement_first_KB1_review_20261013/verification.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-KB1-review-next-stage-20261013.json)

相关文件：[measurement_next_stage_20261013.md](../../mission/measurement_next_stage_20261013.md) · [measurement_first_KB1_review_20261013.md](../../results/measurement_first_KB1_review_20261013.md) · [verification.json](../../results/measurement_first_KB1_review_20261013/verification.json)
### measurement-first-KB2-no-go-CT0-start-20261013

2026-10-13T07:11:47.326922+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-KB1-review-next-stage-20261013

# KB2有据no-go，CT0可入队

M004/SM005/E005/R001/AT003。沿D-M004-KB1-NEXT-01，two-64-tile Down 候选从KB1冻结闭包派生；保留原gold、四distinct预量化A、KB1 writer、AXI响应与7周期完成保持。`measurement_02`与`measurement_03`均static/pilot PASS，pilot实际每行256 PS比对通过；两个full均在同一cycle33397、5151 stripes、每行5120 PS、0输出处无真实进展，由原120s guard以semantic_stall/child-9收束。增加有限delta检测的同一已编译快照也在相同点停滞，无可用报错。所有运行串行、原帽不变，原始证据与判断见 `project/E005_full_request_performance/experiment_results/runs/R001/reports/KB2_two64_no_go_20261013.md`。

KB2未取得完整数值/周期样本，不能判断收益；根因仍UNKNOWN。按合同同点重复停止规则，本轮不扫块大小、不提高帽、不原样重跑；保留已审核KB1。CT0的5009bit×32 schema及真实helper REQUIRE/ACQUIRE/RELEASE_READ差异已写 `project/E002_Laya_HLS/experiment/hls/control/owner_ct0/source/design.md`，其HLS/RTL仍NOT_RUN。现在无owned重工具在跑，工程将沿合同转入CT0独立薄HLS诊断，不把CT0代签生产owner。


[原始消息收据](../../.research-agent/communications/measurement-first-KB2-no-go-CT0-start-20261013.json)

相关文件：[KB2_two64_no_go_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB2_two64_no_go_20261013.md) · [design.md](../../project/E002_Laya_HLS/experiment/hls/control/owner_ct0/source/design.md)
### measurement-first-KB2-stop-review-20261013

2026-10-13T07:16:02.965614+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-KB2-no-go-CT0-start-20261013

# KB2停止核定，按原合同进入CT0

R-SM005-KB2-STOP-20261013；回复measurement-first-KB2-no-go-CT0-start-20261013。M004/SM005/E005/R001，A002唯一整合/工具。此为主控在既有授权内的阶段判断，不是新增用户批准。

接纳KB2本轮有据no-go：停止当前two-64候选，保留已验KB1，不扫块大小、不加帽、不原样重跑。这里no-go表示该候选在本轮成本/进展边界内未取得完整样本；分块方法收益、功能正确性和停止根因均不能由此判定。

## 已独立核到的事实

主控核两份manifest各26冻结源、12fixture及收据/原log/IP，共94个唯一引用文件；相对KB1只变resident、front和TB，KB1 writer保持。measurement_02与_03之间26源仅TB增加有界停滞观测；不把_03称为另一实质DUT修复候选。8段guard含_01原static失败均串行，126条实际policy符合原CPU0–3/nice19/idle约束，实际MemAvailable及120s语义保护保持。主控未执行DUT工具。[核验](../../results/measurement_first_KB2_stop_review_20261013/verification.json)。

| 运行 | 实际结果 |
| --- | --- |
| 初始measurement | NOT_RUN保留 |
| measurement_01 | static FAIL/child1，21.565087s；原live接口漂移失败不回写 |
| measurement_02 | static/pilot PASS；pilot288 stripes、5 A reads、1024总PS比较，尚无最终输出；full COST_STOP355.083389s/peak1424912KiB |
| measurement_03 | static/pilot同有限PASS；full COST_STOP360.493669s/peak1429720KiB |
| delta_01 | 命令引用_03已编译snapshot，maxdeltaid10000；COST_STOP345.225717s/peak896020KiB |

三个停止均为semantic_stall、child-9，末条真实marker一致：`cycle=33397 stripes=5151 ps0=5120 outputs=0`，随后超过120s未见新进展。300cycle诊断未触发，有限delta运行也未提供能定位根因的新报错。

**口径修正：33397是末条观测周期，不是已证最终停拍；5120直接可见的是ps0，不把其余三行终值也写成已直接观测。** 不据此宣称确定RTL握手死锁、delta循环或仿真器缺陷。没有full完成、末B、done消费或新性能结论，不能用pilot补签。旧KB1的23.30%命令消费延迟/10.06%全冷减少仍有效。

新receipt中的“same frozen DUT old full/pilot ratio”继续只是继承成本参考；KB2的调度与TB确实改变。原receipt保留，工程在结果说明及后续runner明确其为旧入口比例参考，不用该标签声称同DUT，不为修正说明重跑实验。

## CT0按既定范围继续

KB2终态已满足[D-M004-KB1-NEXT-01](../../mission/measurement_next_stage_20261013.md)的CT0入队条件，工程可直接连续实施/验证，无需新审批。已核CT0 design的5009bit×32字段偏移与原声明一致；原非零默认layer=255、state=INVALID(6)以及完整bitmap/identity都必须保持。该文档是schema准备，不签host/HLS/RTL通过。

只做原32项表REQUIRE/ACQUIRE/RELEASE_READ：真实RAM/完整校验、私有候选和唯一提交，响应反压不重复写；RELEASE_READ保持原较窄释放条件，不新增request_valid或全identity门。软件用真实原helper作reference，有限RTL核初始化、完整读回、边界/拒绝无写及同址顺序。原容量、全部默认值和TYPE_ROWS依赖不删。不开生产CLAIM/source/window/发布/退休、完整actor或恢复链。

继续按原一个薄HLS候选、明确原因可修一次的边界；若两次同点成本停止则退出该表达并集中评判同schema RTL，不能重新变成无限控制器前置。CT0有限出口之后再集中选择算术或实际集成下一步，本消息不追加KB3/其它控制范围。

工程需随本次终态同步E005三摘要/AT003终态及A002真实状态：主控读取时仍有“未启动KB2/等待KB1审核”和“KB2 full active”的旧投影。只更新工程负责的记录，不改历史失败或原始receipt；这项记录纠正不阻塞CT0独立工作。主控当前记录已切到KB2停止/CT0执行阶段，实际工具启动由工程真实报告。

原单工具/所有分类帽、G2338.224019s仅OOC余额、5172s不重启、无新agent/OOC/P&R/上板/预算保持。M003/M004未完成，完整控制链/冷INIT/恢复扩展继续停排。


[原始消息收据](../../.research-agent/communications/measurement-first-KB2-stop-review-20261013.json)

相关文件：[measurement_next_stage_20261013.md](../../mission/measurement_next_stage_20261013.md)
### measurement-first-CT0-scoped-result-20261013

2026-10-13T07:58:41.334801+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-KB2-stop-review-20261013

# CT0有限出口交付：32项owner表薄HLS与generated RTL

回复 `measurement-first-KB2-stop-review-20261013`；M004/SM005/E005/R001，A002唯一实现/工具owner。KB2已按核定no-go保留，KB1不变。CT0原合同的有限出口已完成，本项目现无owned重工具在跑。

- 原FullRuntime三helper独立对照：normal 32项默认/完整fixture读回、16个操作及其全记录回读，6次提交；另两次冷启动分别关闭request-valid、model-header-valid并使用错live identity的旧READ记录。两者均验证REQUIRE/ACQUIRE拒绝、RELEASE_READ仅一次成功，保持原较窄释放规则。
- AT006真实HLS生成：两根512bit FIFO、32×5009bit单索引RAM模块；154.489s，peak2,914,260KiB，child0/trigger null。HLS估计BRAM18 8/DSP1/FF49,533/LUT39,937/URAM0，仅此诊断top，非物理/联合资源。
- AT012真实generated RTL：normal 131笔，1572入拍/1441出拍逐拍匹配，73429诊断cycles，617拍实际待发响应受阻；两个独立负例各9笔/5073cycles/40拍待发受阻。static/pilot/full/负例各child0/trigger null。AT005原聚合FIFO>4096bit失败由固定512bit分拍的一次有因修复解决；前置runner失败与旧RTL观测口径均原样保留。

完整证据：[阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/CT0_owner_table_scoped_20261013.md)、[静态身份核验](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/CT0_owner_table_verification_20261013.json)、[HLS原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT006_CT0_owner_table_hls_03/receipt.json)、[最终RTL原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT012_CT0_owner_table_rtl_06/receipt.json)。E005三摘要和A002真实状态已发布。CT0仍无生产CLAIM/source/window/发布/退休、整请求、错误恢复或物理时序证据；73429cycles含131次诊断往返，不是生产控制延迟。M003/M004未完成。

按D-M004-KB1-NEXT-01，本阶段CT0结束后请主控集中选择下一算术或实际集成入口。工程不自行扩CT0/整体FullRuntime/冷INIT/恢复重工具；现有单重工具/资源帽/G仅OOC余额与无新OOC/P&R/上板保持。


[原始消息收据](../../.research-agent/communications/measurement-first-CT0-scoped-result-20261013.json)
### measurement-first-CT0-review-LNQ-dispatch-20261013

2026-10-13T08:07:45.105729+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-CT0-scoped-result-20261013

# CT0有限出口接纳，下一轮返回LN→Q算术测量

R-SM005-CT0-20261013；回复measurement-first-CT0-scoped-result-20261013。M004/SM005/E005/R001，A002唯一实现/工具。主控在既有用户授权内集中核定本阶段，不登记为新的用户批准。

**接纳CT0所测原helper对照、薄HLS生成与generated RTL有限行为。CT0本轮收束，不扩控制器；下一入口为原冻结16行LN→实际store→Q/fullA。** 具体执行见[新阶段合同](../../mission/ln_quant_measurement_stage_20261013.md)。KB1保留，KB2不重开。

## 核定证据及范围

主控独立核19份HLS冻结源、39份RTL冻结输入、87个唯一引用文件；全部使用的生成`.v/.dat`与AT006对应产物匹配，top SHA保持`b06cae43b7734e123439ad3b0719c9dd1c45a18b09da54ac57882370036e874b`。13段guard串行，59条实际policy符合原要求；两个短负例host没有policy样本，如实记缺观测，不用配置补造。主控未执行DUT工具。[核验](../../results/measurement_first_CT0_review_20261013/verification.json)。

| 层级 | 接纳事实 |
| --- | --- |
| 原helper软件对照 | 原FullRuntime REQUIRE/ACQUIRE/RELEASE_READ比较状态/detail/bad_element、目标项完整5009bit、index和commit_count；normal32项默认及装载读回，16操作/6提交计数 |
| 生成 | AT006真实2根512bit FIFO、12/11拍完整诊断包，32×5009bit索引RAM读写模块；HLS154.488848s、peak2914260KiB、child0/无触发 |
| normal实际RTL | 131事务、1572输入/1441输出拍全比，73429诊断cycles；RESPOND状态下617周期被full_n阻挡 |
| inactive实际RTL | request-off与model-off各9事务/5073cycles、40周期待发响应受阻；存储identity与live不同，REQUIRE/ACQUIRE拒绝，RELEASE_READ计数仅增1并读回READY，重复释放拒绝 |

RTL期望trace来自**经原helper逐字段校核过的C执行**；不是未经独立检查的DUT自生成gold，也不声称所有raw padding都有独立literal证明。6/1为完整响应中的commit_count及后续目标记录读回事实；本TB未独立逐边沿审计RAM write-enable，亦未在每次拒绝后重新扫全表。只接纳上述有限语义/读回范围，不扩大为所有状态、所有未选记录或生产撤销的证明。

AT005真实聚合FIFO大于4096bit的综合错误与分512bit修复相符；前置runner失败和旧观测尝试保持。未新增HLS第二条恢复路线。AT012原receipt/full guard是**8.299239s**，报告中的8.59s应按原收据纠正文案；不改历史收据、不为纠正说明重跑。

HLS估计BRAM18=8、DSP1、FF49533、LUT39937、URAM0按报告引用。32×5009bit是生成RTL声明及有限读回支持的逻辑容量；`ram_style=block`与HLS估计不能证明最终物理BRAM映射或联合fit。73429包含INIT、131次诊断往返与TB等待，不换算成生产控制延迟，也不与旧整体executor成本停止直接计算加速比。

## 架构与排程判断

这个实验支持“原容量关键表可以采用显式存储、分步校验/提交和窄化流口完成生成及有限行为验证”。它没有证明整个FullRuntime均能按相同比例缩小，也没有提供生产CLAIM/source/window/发布/退休、完整请求或恢复出口。

CT0已回答本阶段的结构可行性问题，保持独立诊断版本；目前不继续CT1、不优化CT0报表资源、不接生产owner。整体executor/冷INIT/CLOSE-rearm/cleanup继续停排。下一轮优先扩充算术实测面：16×1024的LN→Q链包含真实F32生成、65536B store、合法source lease和实际重读，可在已有冻结入口上回答算术与存储成本问题，且不依赖CT0。

工程按新合同连续开展LQ0测量，再仅针对主导且可改变的DUT成本做一个同口径LQ1候选；普通修复不逐项审批。原数值规则、冻结gold、单工具、资源帽、G仅OOC余额、5172s不重启、无新OOC/P&R/上板/预算保持。M003/M004未完成。


[原始消息收据](../../.research-agent/communications/measurement-first-CT0-review-LNQ-dispatch-20261013.json)

相关文件：[ln_quant_measurement_stage_20261013.md](../../mission/ln_quant_measurement_stage_20261013.md)
### measurement-first-LQ0-result-LQ1-execution-20261013

2026-10-13T08:48:18.892484+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-CT0-review-LNQ-dispatch-20261013

# LQ0有限结果与LQ1执行

M004/SM005/E005/R001，A002。回复measurement-first-CT0-review-LNQ-dispatch-20261013。LQ0 `AT014`同原`layernorm_quant_source_03`冻结闭包仅增加观察TB；153文件逐SHA仅TB变且旧601行均保留。static/pilot/full均PASS，full735.843213s、child0/无触发；原独立gold的16384 LN F32、16384 Q INT8及512 FP16 scale、真实store重读/末B/END/lease/fullA/零债务均通过，全TB659334cycles与旧样本相同。

互斥TB阶段25+54+72+655290+3838+55=659334；LN生成run子图4441→653821含真实读算写，不能称纯计算。source首AR5035、末B653813，Q命令655498→实际消费658765；外部valid&&!ready source AR11、dest W12、Q AR6，非互斥且不包括所有内部等待。完整事件/物理拍/成本及范围见[报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ0_measurement_20261013.md)与[原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT014_LQ0_measurement_02/receipt.json)。AT013首版观察器空闲done/部分生命周期口径不足，保留历史；AT014修复后重跑。

按新合同，LQ1只试原最终1024元素归一化循环显式II1，原生产源不改，HLS候选与回放入口已准备。下一步串行跑原能力帽下的CSim/单LN HLS，再以同fixture/gold/AXI profile有限RTL比较。真实收益/资源目前NOT_RUN；不扩控制器或完整恢复。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ0-result-LQ1-execution-20261013.json)
### measurement-first-LQ0-review-20261013

2026-10-13T09:00:37.334597+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LQ0-result-LQ1-execution-20261013

# LQ0有限验收与LQ1当前取舍依据

2026-10-13；M004/SM005/E005/R001，主控A001。回复 `measurement-first-LQ0-result-LQ1-execution-20261013`，继续执行 `D-M004-LNQ-MEASUREMENT-01`，不新增源码/运行审批。工程A002继续唯一实现、整合和重工具owner。

**接纳AT014的LQ0有限数值与周期基线。LQ1继续原单候选验证；目前没有LQ1实测收益结论。** 主控只做文件、日志、源码差异与收据核对，未启动DUT工具。

## LQ0已核事实

153份冻结文件逐项与历史`layernorm_quant_source_03/frozen`对应，仅观察TB不同；原601行全部保留，插入121行观察与一致性断言。历史manifest声明152项，额外一项是历史树已存在的`tools/__pycache__/hls_guard_helpers.cpython-312.pyc`，身份一致，不误报为新DUT。83份生成物、17份full/17份pilot fixture、7个native IP与7组运行DAT均核对。两个manifest的overlay前身份应分别对照历史原文件，不能把同路径后来安装的观察TB/候选源当作原文件SHA损坏。

AT014原始标记、收据和保护记录一致；完整16384 LN F32、16384 Q INT8、512 FP16 scale沿原独立gold通过，真实LN stores供Q读取，末B、真实completion、END、发布、source lease、fullA读回和最终零债务保持。来源仍是B1/S128 checkpoint前16行，诊断身份B1/S64、stage2/layer1、gamma0；不是完整S64请求。

| 同一LQ0边界 | 实测cycles |
| --- | ---: |
| 全TB最终零债务/结束 | 659334 |
| 生成LN run start→done，4441→653821 | 649380 |
| Q命令接受→实际响应消费，655498→658765 | 3267 |
| fullA acquire→末组核对，658766→659278 | 512 |

互斥TB阶段为25+54+72+655290+3838+55=659334；LN run包含真实读、算、写，不是纯算术时间。source AR16/R1024、destination AW16/W1024/B16、Q AR16/R1024；三向DDR共196608B，fullA128次4row返回/512 row-group。source AR11、destination W12、Q AR6等valid&&!ready计数既不互斥，也没有覆盖全部供数和内部等待，不可相加或据小计数判定存储零成本。

static/pilot/full分别76.867212/56.399040/735.843213s，peak2389328/863332/863076KiB；3段guard串行、36条实际policy符合原CPU0–3/nice19/idle I/O及内存/停滞帽。全TB与旧03同为659334，工具墙钟差异不是硬件收益。AT013观察资格/生命周期缺口保留，不追认为AT014；未变F9证据仅按原冻结身份继承。

## LQ1已经可读的生成结果与下一出口

交付后主控定向核到AT015终态收据及报告。31份候选冻结文件与原LN HLS冻结树对照，仅`layernorm_compute.cpp`多一行`#pragma HLS PIPELINE II=1`，原FP表达式、归约、检查、return顺序均未改。候选仍是原合同内的一个结构变化；不能把pragma本身当作硬件达成情况。

实际HLS报告的最终归一化循环`VITIS_LOOP_107_7`为**pipelined=yes、II=2、Resource Limitation**，循环估计10249→2049cycles；2052是其生成子模块估计，二者不要混用。报告top估计BRAM29→29、DSP13→18、FF19765→19804、LUT47775→48104、URAM0；都是各自单top HLS估计，不是物理或联合预算。候选HLS报告slack为**-48.76ns**，原top为0.00ns；这项显著恶化必须随周期/资源一起交付，不能因工具生成成功就写时序通过，不能将RTL cycles按150MHz换算成可实现延迟。

原始`csim_build`实际命令为g++，其16384值PASS记为**主机C++/HLS类型模型对照**，不写成Vitis `csim_design`工具已执行。AT015收据为限定生成PASS，实际HLS guard99.684351s/peak3143944KiB、child0/trigger null；真实RTL正确性及完成周期继续由AT016等原合同入口证明，主控本轮不提前验收。

工程连续完成以下同一候选的收束即可，无需逐项回询：

1. 保持全部原fixture/gold、AXI响应策略、真实store→Q重读、最后B及实际完成消费；观察器若因生成层级名变化而适配，仅调整观察引用并保留端点含义。
2. 按LQ0同口径交全TB、LN run、末B/END、Q实际消费/fullA/最终零债务差值，以及实际流量、重叠等待；不能拿HLS循环估计替代这些动态结果，也不把LQ收益与Down局部周期相加。
3. 随交付提供上述II限制和时序估计的有界定位：明确限制对应的实际资源/操作和关键路径证据。若能在原数值与接口合同内做有证据的受影响修复，沿原至多两次边界自主继续；不为追II1扫描参数、加帽或启动OOC/P&R。若只有周期改善且时序估计未解，明确保留为局部行为/周期候选，部署收益与可实现性未证。

这不是LQ1 RTL的新增前置。LN大包围区间支持优先研究该核，但单凭它不能证明最终normalize循环解释全部成本。即使本候选无收益或因时序代价不宜保留，也可用实测完成该阶段判断。

E005三摘要已发布LQ0及LQ1阶段信息；下一次普通发布同步AT015真实生成终态和AT016实际状态即可，不为记录更新重跑。KB1保留，KB2/CT0当前轮结束；整体executor/FullRuntime、冷INIT和恢复扩展继续停排。原单重工具/分类帽、G2338.224019s仅OOC余额、5172s不重启、无新OOC/P&R/上板/预算保持，M003/M004未完成。

证据：[主控只读核验](../../results/measurement_first_LQ0_review_20261013/verification.json)、[观察差异](../../results/measurement_first_LQ0_review_20261013/observation.diff)、[LQ1唯一源差异](../../results/measurement_first_LQ0_review_20261013/LQ1_source.diff)、[HLS原报告摘录](../../results/measurement_first_LQ0_review_20261013/LQ1_HLS_selected.txt)、[工程LQ0报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ0_measurement_20261013.md)。核验555个唯一SHA/bytes引用；其中含历史及候选生成引用，不把引用数当作测试覆盖率。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ0-review-20261013.json)

相关文件：[LQ0_measurement_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ0_measurement_20261013.md)
### measurement-first-LQ1-scoped-result-timing-risk-20261013

2026-10-13T09:09:33.336677+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-LQ0-review-20261013

# LQ1同口径收束：有限数值/周期PASS，HLS时序估计违例

M004/SM005/E005/R001；A002。回复`measurement-first-LQ0-review-20261013`，沿D-M004-LNQ-MEASUREMENT-01，无新增批准请求。

AT015真实单LN HLS生成PASS；主机g++/HLS类型模型对照PASS（并非Vitis `csim_design`）。AT016同冻结16行LN→真实store→Q/fullA的static、rows1 pilot、rows16 full均guard child0/trigger null，full622.945862s、peak863272KiB。原独立gold的16384 LN F32、16384 Q INT8、512 FP16 scale、真实store/Q重读、末B、END/发布、source lease、fullA和最终零债务全部PASS。原响应策略与三向196608B传输不变。

全TB零债务659334→528307cycles，减少131027（19.8726%）；生成LN run start4441→done653821/522795，即649380→518354，减少131026（20.1771%）；Q接受→实际消费3267→3266，fullA512→512。互斥TB阶段分别和为659334/528307，主要差额位于包含LN读算写及END的phase3。首AW45430→37242，末B653813→522787；END消费655441→524415，Q消费658765→527738。接口valid&&!ready非互斥，未加总为可消除等待。此为局部16行冷样本、原TB profile周期，非完整S64/生产请求。

HLS最终循环目标II1、实际II2、报告类别`Resource Limitation`；调度警告明确F32减与F32乘不能满足目标周期/II1。同一State3关键路径row读1.200ns→F32减30.745ns→F32乘20.420ns→检查/控制，估计53.626ns；top估计slack0.00→−48.76ns。BRAM18 29→29、DSP13→18、FF19765→19804、LUT47775→48104均是单top HLS估计，物理及联合资源UNKNOWN；不能按150MHz换算部署收益。报告未唯一指明II2的存储端口/共享算子竞争项，本轮不据此盲改算术或扫参数。LQ1保留为局部周期候选，时序与继承错误窗口待后续阶段取舍；未启动OOC/P&R或另一候选。

完整[工程比较报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)、[AT015原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT015_LQ1_LN_hls_01/receipt.json)、[AT016原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT016_LQ1_RTL_01/receipt.json)、[AT016 full原log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT016_LQ1_RTL_01/full_sim.log)和E005三摘要已更新。A002已报告本阶段completed、无重工具在跑。KB1保持；KB2/CT0本轮收束；整体executor/冷INIT/恢复停排，M003/M004未完成。请主控据实测周期与时序风险集中选择下一阶段，普通新工具当前未排队。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ1-scoped-result-timing-risk-20261013.json)
### measurement-first-LQ1-timing-addendum-20261013

2026-10-13T09:19:39.797464+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-LQ0-review-20261013

# LQ1只读时序补证

补充`measurement-first-LQ1-scoped-result-timing-risk-20261013`。AT015生成IP Tcl显示最终循环所用F32减和F32乘均`CONFIG.c_latency 0`；其调度同一State3串接减30.745ns、乘20.420ns，路径估计53.626ns。原`layernorm_producer_hls_01`非显式流水算术体调度详报的最终`delta`减与`norm`乘分别为3.860ns、4.084ns，处于分开的调度状态。其它AT015浮点IP已有非零latency配置。这个对照支持把下一次结构检查限定为浮点运算寄存器流水，尚不证明任何具体约束能达成目标时序或II1；不需改数值/gold/AXI边界。

已补入[同口径报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)及原调度/IP配置链接，未启动新工具。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ1-timing-addendum-20261013.json)
### measurement-first-LQ1-review-timing-repair-dispatch-20261013

2026-10-13T09:21:42.389140+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LQ1-scoped-result-timing-risk-20261013

# LQ1限定验收与下一时序修复入口

2026-10-13；M004/SM005/E005/R001，A001主控。回复`measurement-first-LQ1-scoped-result-timing-risk-20261013`，并纳入`measurement-first-LQ1-timing-addendum-20261013`；补证所述零内部流水与主控独立核到的AT016实际XCI相符。

**接纳AT016的正常16行数值和周期结论；LQ1时序可实现性不接纳为已通过。下一阶段选择同一LN候选的有界流水修复LQ1R，按[D-M004-LNQ-TIMING-01](../../mission/ln_quant_timing_repair_stage_20261013.md)自主连续执行。** 无需新的用户或逐工具批准，不回到整体控制器路线。

## 已核比较

AT016的158冻结文件中，70个非LN生成文件与LQ0逐SHA相同，包含完整观察TB；88个LN生成文件全部对应AT015，17份full/17份pilot fixture不变。7个原native IP身份保持，新增2个FP IP；7组DAT staging一致。394个唯一引用核对，3段guard串行、39条实际policy符合原帽。主控未运行DUT。

| 同口径端点 | LQ0 | LQ1 | 减少 |
| --- | ---: | ---: | ---: |
| 全TB至最终零债务 | 659334 | 528307 | 131027 / 19.8726% |
| LN run start→done，含读算写 | 649380 | 518354 | 131026 / 20.1771% |
| Q接受→实际消费 | 3267 | 3266 | 1 |
| fullA完整回读 | 512 | 512 | 0 |

两版互斥阶段总和和raw事件一致。16384 LN F32、16384 Q INT8、512 FP16 scale原gold，以及真实LN store→Q重读、末B、END/发布、lease/fullA和零债务均保持；三向流量196608B。Q差1拍不单独称为Q优化，重叠等待/首末接口事件差额不相加。AT016 static/pilot/full为76.130073/46.903216/622.945862s，均child0/无保护触发；它们是工具成本，rows1 pilot不代签Q。范围仅原16行冷诊断样本及响应profile，不外推完整S64、稳态或全模型。

## 为什么下一步仍选这条算术路径

LQ1已证明缩短这一循环能改变实际末B和完成边界，继续研究具有实测依据。时序风险也已有具体实现线索：HLS最终II2，State3的row RAM读1.200ns→F32减30.745ns→F32乘20.420ns→检查/控制组成53.626ns路径。主控进一步核到新增fsub/fmul的生成Tcl和AT016实际XCI均为`C_Latency=0`、`Has_ACLKEN=false`，对应wrapper无时钟输入。因此可以选择“恢复这两项运算的寄存器流水”这一有界修复；这仍不能唯一解释II2的全部资源限制，也不预判修复成功。

原算子wrapper的HLS stage4/3与native core `c_latency=2/1`不同，工程应核实际工具支持的局部绑定及调度。保持原150MHz目标/1.800ns uncertainty，接受工具报告的可实现II，不强追II1，也不通过降频、删除finite/early-return或修改gold掩盖问题。

下一阶段只用原LQ合同剩余的至多两版有据受影响修复，不开启第二条优化候选或参数扫描。先核实际注册映射和HLS估计；未改善时序就保留结果并按有据停止规则收束，不重复投入完整RTL证明已知的cycle下降。估计通过后按原static/pilot/full继续同口径验证；若候选拟保留，补原F9 case5/6真实一行producer错误归属回放，未变前置拒绝继承，不扩恢复矩阵。详细边界、条件和停止规则已在新阶段合同集中说明，不要求工程逐步回询。

LQ1单topHLS估计BRAM18 29、DSP18、FF19804、LUT48104、URAM0及slack−48.76ns保留；无物理/联合资源结论。阶段结束即使HLS估计改善，也仍不称物理Fmax/板端通过。LQ1暂存为周期候选，LQ0不替换；KB1保持，KB2/CT0收束，整体executor/冷INIT/恢复停排，M003/M004未完成。原单工具/所有帽、G仅OOC余额、5172s不重启及无新OOC/P&R/上板/预算保持。

证据：[本次只读核验](../../results/measurement_first_LQ1_review_20261013/verification.json)、[工程比较](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)、[AT016原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT016_LQ1_RTL_01/receipt.json)。主机g++/HLS类型模型对照与真实HLS生成继续分别登记，不称Vitis csim_design已运行。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ1-review-timing-repair-dispatch-20261013.json)

相关文件：[ln_quant_timing_repair_stage_20261013.md](../../mission/ln_quant_timing_repair_stage_20261013.md) · [LQ1_pipeline_comparison_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT016_LQ1_RTL_01/receipt.json)
### measurement-first-LQ1R-first-timing-progress-20261013

2026-10-13T09:38:24.145730+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-LQ1-review-timing-repair-dispatch-20261013

# LQ1R第一版：注册映射成功，HLS估计仍差0.43ns

2026-10-13；M004/SM005/E005/R001；A002。AT017由AT015的31份冻结源派生，仅最终normalize循环新增`delta` F32减`BIND_OP latency=4`与`norm` F32乘`BIND_OP latency=3`，原II1 pragma及全部数值/错误/存储接口保持。主机g++/HLS类型模型原16行数值对照exit0；HLS生成PASS，guard child0/trigger null，101.160436s、peak3144228KiB。未运行RTL。

实际生成最终循环F32减wrapper为5级、native core `c_latency=3`；F32乘wrapper为4级、native core `c_latency=2`，两者均非旧零延迟组合IP。HLS最终循环pipelined=yes、实际II9、估计9224cycles；单top估计BRAM18 29、DSP18、FF20136、LUT48112、URAM0，top及受影响算术子模块slack均**−0.43ns**。这些是HLS估计，非物理时序/联合资源或实际cycle。

调度原警告`HLS 200-887`与详细State7一致：F32减末级2.976ns紧接F32乘首级2.322ns，形成5.298ns路径；当前有效预算6.667−1.800=4.867ns，故本版不准入static/pilot/full。这个具体剩余路径支持仅将F32减再加一级寄存器约束作第二版有据尝试，检查是否把末级路径压到预算内；不改乘法、数值或错误语义，也不扫其它latency。若第二版仍有估计违例，按两版上界停止本修复方向。

原始证据：[AT017 receipt](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/receipt.json)、[AT017 input manifest](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/input_manifest.json)、[HLS汇总](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/work/reports/hls_compile.rpt)、[调度明细](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/work/hls/.autopilot/db/layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7.verbose.sched.rpt)、[调度警告](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/work/hls/.autopilot/db/autopilot.flow.log)、[减法IP配置](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/work/hls/syn/verilog/laya_layernorm_producer_engine_fsub_32ns_32ns_32_5_full_dsp_1_ip.tcl)、[乘法IP配置](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/work/hls/syn/verilog/laya_layernorm_producer_engine_fmul_32ns_32ns_32_4_max_dsp_1_ip.tcl)。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ1R-first-timing-progress-20261013.json)
### measurement-first-LQ1R-first-progress-reply-20261013

2026-10-13T09:40:56.399743+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LQ1R-first-timing-progress-20261013

# LQ1R第一版核查与剩余一次修复

回复measurement-first-LQ1R-first-timing-progress-20261013；沿D-M004-LNQ-TIMING-01，不新增审批。

已定向核AT017：31文件只有normalize源增加两项BIND_OP；原表达式/检查/返回保持，主机对照及HLS生成事实接纳。生成FP减/乘core latency3/2与非零注册映射一致；实际II9/9224估计cycles、State7 2.976+2.322=5.298ns、有效预算4.867ns及slack−0.43ns核实。第一版未达到合同内RTL入口，保持NOT_RUN正确。

你提出仅把减法延迟约束再加一级的第二版有具体路径依据，按原授权直接继续，乘法、150MHz/uncertainty1.800ns、数值/finite/首错/存储边界不变。II1不是验收目标，报告真实II，不为追II再开候选。两版额度只剩这一版；仍有估计违例或同点无新证据即结束，不扫描/不加帽/不启动第三版。

即使第二版估计过关，也须重新与LQ0比较实际完成周期和资源；本版II已由2升至9，不能继承LQ1的19.87%或把9224估计当实测。按原合同满足入口后连续完成同口径static/pilot/full；拟保留者补原F9 case5/6，届时集中交取舍。普通状态发布同步真实终态即可，不阻塞下一步。

主控未运行DUT；记录已更新至mission/current.md与results/measurement_first_LQ1_review_20261013.md，定向证据在同名目录AT017_progress_check.json。单工具/原帽、整体控制停排、G仅OOC余额及无新OOC/P&R/上板保持。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ1R-first-progress-reply-20261013.json)
### measurement-first-LQ1R-no-go-handoff-20261013

2026-10-13T09:44:10.040945+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-LQ1R-first-progress-reply-20261013

# LQ1R有界时序修复停止：两版均未达RTL入口

2026-10-13；M004/SM005/E005/R001；A002。沿D-M004-LNQ-TIMING-01对同一LQ1最终1024元素循环只试两版有据局部`BIND_OP`。两版主机g++/HLS类型模型原16行gold对照与真实单LN HLS生成均PASS，guard child0/trigger null；**两版HLS估计时序均违例，因此static/pilot/rows16 full均NOT_RUN，F9 case5/6亦NOT_RUN**。没有LQ1R动态周期或正常/错误RTL结论；原LQ0及LQ1 AT016的限定结果不回写。

| 同一150MHz/6.667ns目标、1.800ns uncertainty | LQ1 AT015 | LQ1R版1 AT017 | LQ1R版2 AT018 |
| --- | ---: | ---: | ---: |
| F32减/乘绑定请求wrapper latency | 由工具自动/自动 | 4/3 | 5/3 |
| 实际wrapper stage；native FP core `c_latency` | 1/1；0/0 | 5/4；3/2 | 6/4；4/2 |
| 最终循环实际II/估计cycles | 2/2049 | 9/9224 | 10/10249 |
| 临界路径估计 | 53.626ns | 5.298ns | 5.277ns |
| top及受影响算术子模块估计slack | −48.76ns | −0.43ns | −0.41ns |
| 单top BRAM18/DSP/FF/LUT/URAM估计 | 29/18/19804/48104/0 | 29/18/20136/48112/0 | 29/18/20111/48107/0 |
| HLS guard耗时/peak owned RSS | 99.684351s/3143944KiB | 101.160436s/3144228KiB | 100.111604s/3140780KiB |

AT017仅相对AT015源码增加最终循环F32减/乘局部约束。生成的减法与乘法native IP有寄存器，原零延迟组合链已消失；但调度State7把减法末级2.976ns接乘法首级2.322ns，5.298ns仍超有效预算4.867ns。AT018仅把减法绑定请求4→5，乘法与所有源码、时钟/数值/错误/接口保持；生成core latency由3→4、wrapper5→6，证明约束生效，但同点State8仍为2.955+2.322=5.277ns，超预算0.410ns。HLS原警告两版均为`HLS 200-887` fsub→fmul并明确估计clock 5.298/5.277ns；它没有报告可证明一个简单延迟值能够消除跨IP组合段。报表类别`Resource Limitation`与实际II9/10照原记录，不能把II差额唯一归因端口或纯算术依赖。

第二版循环估计10249cycles已回到原LQ0同一循环的HLS估计数值，但这**不是**新RTL周期；第一版9224也非实测。两版均不满足合同所定“寄存器边界生效且top/子模块估计不违例”联合条件，不消耗static/pilot/full成本重复已知的LQ1数值通过。LQ1仍只保留原16行normal的局部周期候选；其目标频率部署、错误回放及完整M003/M004未证。LQ1R方向按两版上界no-go，不提高帽、不扫下一参数、不启动OOC/P&R/上板。主控后续可根据这条明确的减末级→乘首级映射和其它算术候选集中选择新阶段；本报告本身不批准第三版。

原始证据：[AT017 receipt](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/receipt.json)、[AT017 report](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/work/reports/hls_compile.rpt)、[AT017 scheduler](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/work/hls/.autopilot/db/autopilot.flow.log)、[AT018 receipt](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT018_LQ1R_LN_hls_02/receipt.json)、[AT018 manifest](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT018_LQ1R_LN_hls_02/input_manifest.json)、[AT018 report](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT018_LQ1R_LN_hls_02/work/reports/hls_compile.rpt)、[AT018 scheduler](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT018_LQ1R_LN_hls_02/work/hls/.autopilot/db/autopilot.flow.log)、[AT018 verbose schedule](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT018_LQ1R_LN_hls_02/work/hls/.autopilot/db/layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7.verbose.sched.rpt)、[LQ0/LQ1动态对照](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ1R-no-go-handoff-20261013.json)
### measurement-first-LQ1R-close-Attention-dispatch-20261013

2026-10-13T10:03:30.402979+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LQ1R-no-go-handoff-20261013

# LQ1R有界停止核定与下一算术入口

2026-10-13；M004/SM005/E005/R001，主控A001。回复`measurement-first-LQ1R-no-go-handoff-20261013`。

**接纳LQ1R本轮no-go，关闭这条两版局部延迟修复排程。下一阶段执行[D-M004-ATTENTION-MEASUREMENT-01](../../mission/attention_softmax_measurement_stage_20261013.md)：原冻结Attention v10的softmax计量与至多一个有实测依据的同资源调度候选。** 工程A002按合同直接继续，不需用户转发或逐工具审批。

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

完整执行及停止边界见[阶段合同](../../mission/attention_softmax_measurement_stage_20261013.md)。整体控制/冷INIT/恢复继续停排；无新OOC/P&R/上板/预算，G仅OOC余额2338.224019s、5172s组合不重启。M003/M004未完成。

证据：[只读核验](../../results/measurement_first_LQ1R_close_20261013/verification.json)、[工程no-go报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1R_timing_no_go_20261013.md)、[Attention既有盘点](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/attention_inventory_20261013.json)。主控本轮未执行任何DUT工具。


[原始消息收据](../../.research-agent/communications/measurement-first-LQ1R-close-Attention-dispatch-20261013.json)

相关文件：[attention_softmax_measurement_stage_20261013.md](../../mission/attention_softmax_measurement_stage_20261013.md) · [LQ1R_timing_no_go_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1R_timing_no_go_20261013.md) · [attention_inventory_20261013.json](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/attention_inventory_20261013.json)
### measurement-first-ATN0-result-ATN1-plan-20261013

2026-10-13T10:35:58.855471+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-LQ1R-close-Attention-dispatch-20261013

# ATN0完整head计量交付，继续一个ATN1调度候选

回复measurement-first-LQ1R-close-Attention-dispatch-20261013；M004/SM005/E005/R001，A002唯一实现/工具。原v10 93源、本项目复制fixture与中间gold已核；AT019观察器固定ASUB事务数断言失败保留，AT020只改该观察断言。AT020 static/16行pilot/128行连续full均child0、trigger null，完整原中间与最终逐位gold、M/A/D 2129920/2146176/16384、EXP16384及accepted=retired191088均通过。新full guard499.307597s、peak1109036KiB，没有项目重工具在跑。

全TB1608896cycles、正常QK/SM/AV首次done250888/287173/66256，与旧v10相同；三类命令各8次实际consume均比首次done累计多24cycles。SM互斥MAX2176+EXP270525+TREE8576+DIV5888+接受/报告8=287173。四EXP worker launch/done/commit配平，总core-busy898680 slot-edges、ASUB输入待算147456 slot-edges；四worker服务条件下界224670，EXP区间与下界差45855只是乐观空隙，不是保证收益。A/TREE/D credit阻塞0，ASUB实际请求/退休各16000笔，不能按固定四lane推算。

这支持一个有证据的ATN1：在同一行、同一4 EXP与原FP数值图下，将ASUB输入准备与正在运行的EXP尽量重叠，保持原bank/队列容量、首错rank、CE/reset/epoch和单次结果提交；新增小量候选状态单列逻辑账。若无法在原合同内实现则no-op收束，不扩第二个候选、HLS/OOC/P&R/上板或生产控制链。ATN1尚NOT_RUN，当前继续定向核现有队列语义。完整报告：[ATN0](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN0_attention_softmax_measurement_20261013.md)，原始[AT020 receipt](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/receipt.json)与[full计量](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/full_01/measurement.json)。M003/M004仍未完成。


[原始消息收据](../../.research-agent/communications/measurement-first-ATN0-result-ATN1-plan-20261013.json)
### measurement-first-ATN0-review-20261013

2026-10-13T10:48:46.265674+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-ATN0-result-ATN1-plan-20261013

# ATN0集中审核与ATN1继续执行

2026-10-13；R-SM005-ATN0-20261013；M004/SM005/E005/R001。回复`measurement-first-ATN0-result-ATN1-plan-20261013`，沿D-M004-ATTENTION-MEASUREMENT-01。主控本轮只读核验；A002继续唯一实现、整合与重工具owner。

**接纳AT020为限定完整head正常数值与计量基线。继续原合同内唯一ATN1：同一行ASUB输入准备与当前EXP重叠。** 工程已自主冻结AT021并报告静态构建启动；本审核不要求等待新审批，也不预签其正确性或收益。阶段范围及资源帽不变。

## 已核事实与计时口径

AT020完整enc0/head0/B1/S128、K128/D64、128query、八个16row tile连续完成。原中间和最终逐位gold、M/A/D实际2129920/2146176/16384、EXP16384、QK products1048576/trees1032192、AV steps1048576及accepted=retired191088、cancelled0均核对。正常PROTOCOL=0仅签此范围。

| 边界（8次命令之和） | 首次done | 实际consume |
| --- | ---: | ---: |
| QK cmd19 | 250888 | 250912 |
| SM cmd20 | 287173 | 287197 |
| AV cmd21 | 66256 | 66280 |

每次首次done至消费3拍，三类各累计24拍；本normal无CE暂停，wall与enabled相同。正常计算到首次done总和604317、全TB1608896、load140288是不同边界，不能互相替代。SM互斥MAX2176+EXP270525+TREE8576+DIV5888+接受/报告8=287173；EXP占SM约94.20%。

四worker各自的input/core/commit/idle之和均为270525；总input147456、core898680、commit17143、idle18821是worker-slot edges。每worker的实际launch/done/commit配平，原1/78/89/97的服务直方图加权和与core-busy一致。input147456=16384×9，支持检查准备阶段与在算EXP的重叠。四worker条件服务下界ceil(898680/4)=224670，当前EXP差45855仅为乐观空隙，不能承诺节省45855，亦不能把多worker等待直接加成延迟。保持原worker分配时才可用max-worker225172作为更紧条件；候选重分配时应重新计量。

ASUB实际16000请求/16000退休为可变lane事务数；固定工作量由原逐lane数值和EXP16384等检查保证。TREE1408/1408、D4096请求/16384返回lane已独立复核。A/TREE/D credit为0只覆盖观察器定义的阻塞资格，不等于全部供数时间为0。

## 身份、失败与工具证据

AT019/AT020各93份冻结源及本项目历史映射源已核；相对原v10仅观察TB/runner变化，DUT未变。35项fixture产品、3个Q/K/V上游plane、5项trace与历史声明一致；AT019 pilot、AT020 pilot/full各47个snapshot文件与实际静态构建副本一致，相关dat/ini亦核。共535个唯一引用SHA/bytes匹配。5段guard起止串行、63条实际policy均符合CPU0–3/nice19/idle I/O；原内存、墙钟、MemAvailable门与120s语义保护保持。

AT020 static/pilot/full分别42.483280/67.855530/499.307597s，full peak1109036KiB，child0/trigger null；这些是工具成本。AT019 pilot的观察断言失败仍为FAIL_OBSERVER_ASSERT，无full，不回写PASS。

文案精确化：AT019→AT020仅TB变化，但修改了新增观察器的整条组合断言——去除固定ASUB/TREE/D请求数假设，改为真实issue/retire配平，并新增计数输出；不宜简写成“只改ASUB比较项”。原数值/gold/覆盖断言保持，实际TREE/D总量已核正确，无需为此重跑ATN0。后续报告准确描述即可，冻结旧收据不改。

## ATN1实现与验收边界

原代码在worker空闲时才发ASUB，并持有当前worker key至EXP结果提交；测量与源码共同支持这一候选。AT021所示一批最多4项同row私有准备值可以在原阶段内继续：4×(32bit值+11bit key)+count/cursor/pending的179bit持久逻辑状态需如实列账，组合选择/仲裁另述。它包含数据寄存器，不能全称为metadata或当成物理FF估计。原32项A队列、RAM/bank容量、M16/A16/D4/EXP4与算子内部流水保持；不增加query上下文或第二批预取队列。

本候选按以下不变量集中验收，不逐项另设审批：

- 当前EXP的x/key/结果归属保持到原单次提交；准备项与当前项独立。若worker映射延后到真正launch，准备项必须保留真实A队列返回的完整key，并仅分配给可接受worker；不得按完成先后重建当前结果身份。row/epoch由原持有上下文保证且换行/换epoch前完整排空。
- 一批准备槽从ASUB真实接受起预留，到真实返回、分发和EXP提交均有唯一归属；pending、未分发值与所有原队列债务共同约束行完成。`exp_written==S`不能掩盖遗留准备项；reset清理与原错误排空/首错rank语义保持。
- 新调度下worker_state的input_wait含义已变。保留ATN0相同外部端点、EXP真实launch/done/commit和互斥SM账，同时显式观察准备pending/ready/分发/排空。不要仅把原worker等待下降称为等量节省；ASUB事务数可因4lane打包而变化，原lane工作量、完整gold和原加减/EXP/除法图必须不变。
- 拟保留前，在同一候选冻结身份上回放原tile16_03的PROTOCOL=1首错、CE/reset、合法重载、chain/ledger。新增全部持久准备字段进入真实状态快照；实际命中新pending在途及ready未分发状态下的CE保持/reset清理，原六类首错和M/A/D/EXP活动覆盖保持。normal head不能代签该回放。

上述是原候选范围的具体核验要求。若目前normal专用runner固定PROTOCOL=0，协议入口需明确绑定候选并真实传PROTOCOL=1，不能仅复制旧PASS或把normal终态改名。按原static→≤120s pilot→有据full顺序与至多两次有据受影响修复额度连续执行；无有效收益或同点无依据停止均可有据收束。

KB1保留；KB2/CT0本轮收束；LQ1仅保留限定周期证据，LQ1R两版no-go保持。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup继续停排。无新HLS/OOC/P&R/上板/预算，G2338.224019s仅OOC余额，5172s组合不重启。ATN1完整数值/周期/协议结果仍待交；Attention无AXI master，不签13BO、全模型请求或物理时序，M003/M004未完成。

证据：[主控可复算核验](../../results/measurement_first_ATN0_review_20261013/verification.json)、[只读审核程序](../../results/measurement_first_ATN0_review_20261013/audit.py)、[ATN0工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN0_attention_softmax_measurement_20261013.md)、[AT020原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/receipt.json)、[原阶段合同](../../mission/attention_softmax_measurement_stage_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-ATN0-review-20261013.json)

相关文件：[ATN0_attention_softmax_measurement_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN0_attention_softmax_measurement_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/receipt.json) · [attention_softmax_measurement_stage_20261013.md](../../mission/attention_softmax_measurement_stage_20261013.md)
### measurement-first-ATN1-full-progress-20261013

2026-10-13T10:54:50.431275+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-ATN0-review-20261013

# ATN1 完整 head 数值与周期进展

M004/SM005/E005/R001；A002。AT021 的同一冻结候选在完整 enc0/head0 B1/S128 128 行、K128/D64 下通过原逐位中间与最终 gold、全部 M/A/D/EXP 工作量检查，191088 次调用受理与退休配平，无取消。guard_full_01 child0、trigger null，482.110123s，peak owned RSS 1108904KiB。

同口径 ATN0→ATN1：SM 首次 done 287173→265084（减22089，7.6919%），SM 实际消费 287197→265108；QK 250888 不变，AV 66256 不变；三段首次完成和 604317→582228（减22089，3.6552%）；全 TB 1608896→1586807（减22089，1.3729%）。ATN1 EXP 互斥区间 270525→248436，原 ASUB 16000→4096 物理请求，16384 lane 与原独立数值检查保持。该结果只限模块仿真，物理资源/时序与完整请求仍 UNKNOWN。

原始证据：AT021/guard_full_01/guard_result.json、AT021/full_01/simulate.log、AT021/full_01/measurement.json、AT021/full_01/numeric_result.json，均位于本 R001 attempts 下。AT022 是同 DUT SHA `11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16` 的增强协议 TB 冻结；static child0，PROTOCOL=1 的 16 行有限回放正在原 guard 下运行，定向命中新增 staged_pending 与 staged_count ready 并核 CE 保持、reset 清空。AT022 不算第二优化候选。协议尚未得终态，ATN1 暂不宣布采用。


[原始消息收据](../../.research-agent/communications/measurement-first-ATN1-full-progress-20261013.json)
### measurement-first-ATN1-progress-review-20261013

2026-10-13T10:58:46.106985+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-ATN1-full-progress-20261013

# ATN1正常完整head进展审核

2026-10-13；M004/SM005/E005/R001；回复`measurement-first-ATN1-full-progress-20261013`，沿D-M004-ATTENTION-MEASUREMENT-01。**接纳AT021正常完整head的限定数值与周期进展；ATN1采用结论仍待协议回放收束。** AT022是同一DUT的受影响验证，不计第二优化候选，按原合同继续，无新审批或预算。

| 同口径边界 | ATN0 | ATN1 | 减少 |
| --- | ---: | ---: | ---: |
| SM接受→首次done | 287173 | 265084 | 22089 / 7.6919% |
| SM接受→实际consume | 287197 | 265108 | 22089 / 7.6912% |
| QK+SM+AV首次done之和 | 604317 | 582228 | 22089 / 3.6552% |
| 全TB | 1608896 | 1586807 | 22089 / 1.3729% |

原全部中间/最终逐位gold、M/A/D/EXP工作量、QK250888、AV66256、load140288及191088次受理/退休配平核对。SM互斥MAX2176+EXP248436+TREE8576+DIV5888+接受/报告8=265084；净差只在EXP区间。所有数字仍限模块仿真与原profile，不代表部署频率、物理资源或完整请求。

四worker总core-busy保持898680 slot-edges，launch/done/commit均16384；原算术服务量没有减少。ASUB请求16000→4096、lane16384不变，说明候选同时改变准备/分发与请求分组，不能把全部收益唯一归因某一项。

新的worker input_wait147456→16384已换了状态含义；commit_wait17143→27304、idle18821→51376。四worker非core总变化88356=4×22089，只是状态账闭合，不能把input_wait少131072直接当省下的硬件周期。此前45855是条件乐观空隙，实际只签22089；剩余23766亦不构成下一候选授权。新staged_pending/ready驻留尚未进入AT021计量，不据其缺失臆算细分等待，也不为完善归因单独重跑完整head。

主控核AT021/AT022各93冻结源、318唯一引用、AT021 full的47项编译snapshot与静态构建副本、原log与两个JSON一致。AT021相对ATN0仅DUT/state生成器/state快照/runner四项变化，观察TB相同；AT022相对AT021仅协议TB及runner终态检查变化，DUT SHA均`11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`。3段AT021与AT022 static的4段已结束guard串行，58实际policy符合原约束；AT021 full482.110123s、peak1108904KiB为工具成本。尚无阶段最终receipt，不把进展写成已收束采用。

AT022实际命令含`--protocol 1`；TB和runner显式要求原六类首错、四类原活动管线，以及新增pending/ready的CE保持和reset清空。已核准备值/key/控制进入候选state身份；协议运行中的部分marker不是整轮PASS。继续原guard自然收束，冻结输入不回改。最终交付把协议原终态/首错/CE/reset/重载/chain/ledger与本正常完整head身份一并关联。

最终摘要还请给出新准备槽的行完成/换epoch债务守恒依据，区分真实动态观察与源码不变量；本次normal调用ledger不是所有内部槽位的逐边沿审计。若采用已有源码论证，明确一批接受→返回→按完整key分发→EXP唯一提交与换行前排空的关系，不把reset清空替代正常排空。原179bit新增持久状态包含数据，选择/仲裁与物理代价仍UNKNOWN。

终态时一次同步三摘要及A002真实运行状态；当前state仍指AT021 full active，而已完成原guard与本消息已推进到AT022，状态纠正不阻塞在跑验证。保持一个候选及原有据修复上界，不扩队列/算子，不新增HLS/OOC/P&R/上板；整体控制、冷INIT、恢复停排，G仅OOC余额2338.224019s、5172s组合不重启，M003/M004未完成。

证据：[主控进展核验](../../results/measurement_first_ATN1_progress_review_20261013/verification.json)、[AT021 full计量](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/full_01/measurement.json)、[AT021原数值收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/full_01/numeric_result.json)、[AT022冻结身份](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT022_ATN1_prefetch_protocol_01/source_manifest.json)、[原ATN0审核](../../results/measurement_first_ATN0_review_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-ATN1-progress-review-20261013.json)

相关文件：[measurement.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/full_01/measurement.json) · [numeric_result.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/full_01/numeric_result.json) · [source_manifest.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT022_ATN1_prefetch_protocol_01/source_manifest.json)
### measurement-first-ATN1-final-handoff-20261013

2026-10-13T11:04:36.260434+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-ATN1-progress-review-20261013

# ATN1阶段交付：完整head与同DUT协议回放

M004/SM005/E005/R001；A002。阶段事件`EV_SM005_ATN1_SCOPED_RESULT_20261013`已登记，E005三摘要和A002状态已同步；当前无owned重工具。请求主控按[D-M004-ATTENTION-MEASUREMENT-01](../../mission/attention_softmax_measurement_stage_20261013.md)集中审核限定候选并选下一阶段，普通运行无需新审批。

AT021唯一同资源候选完整128行正常head逐位gold、原全部M/A/D/EXP工作量及191088受理/退休配平PASS。ATN0→ATN1：SM首次done287173→265084（−22089，7.6919%）、实际consume287197→265108；QK/AV不变；三段首次done和604317→582228（−3.6552%），全TB1608896→1586807（−1.3729%）。SM净差只在EXP互斥区间；四worker core-busy898680 slot-edges不变。AT021 static/pilot/full guard全部child0/trigger null，full482.110123s、peak1108904KiB。

AT022与AT021的DUT SHA同为`11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`，只变协议TB/runner；static及PROTOCOL=1 16行RTL均child0/trigger null。实际命中ASUB pending及四项ready未分发，新增全部状态在CE低8拍保持、reset清空；原M/A/D/EXP活动、六首错、合法重载/chain及账本210966=210960+6和末尾16行gold PASS。协议运行226.536195s、peak955724KiB，不能与正常full比性能。五段guard串行，63条实际policy样本合规。

新增179bit包含四项值/key数据；源码的一批接受→A返回→按完整key唯一分发→EXP一次提交关系支持行完成前债务排空，正常full数值和定向CE/reset是动态佐证；未作内部槽位逐边沿形式证明。物理FF/LUT/Fmax、生产请求、13BO及M003/M004仍未验。完整解释与链接见[ATN1工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_attention_softmax_comparison_20261013.md)、[定向冻结/guard核验](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_evidence_check_20261013.json)和AT021/AT022各`receipt.json`。本次不追加第二候选/HLS/OOC/P&R/上板。


[原始消息收据](../../.research-agent/communications/measurement-first-ATN1-final-handoff-20261013.json)

相关文件：[attention_softmax_measurement_stage_20261013.md](../../mission/attention_softmax_measurement_stage_20261013.md)
### measurement-next-G-quant-Down-readonly-20261013

2026-10-13T11:08:25.124038+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-ATN1-progress-review-20261013

# 下一算术连接入口的只读定位

主控正在选择下一阶段时，工程只读定位了最短现有接点，未启动新工具或修改候选。旧 `t2_geglu_gate_quant_bridge_rtl_04/receipt.json` 的限定 PASS 覆盖四distinct原enc0 Wi输出行→真实G与AXI末B→量化→dualA commit/acquire/完整身份保持读与release；实际量化/读回共328组，即4行×82组。桥的读口已显式带slot/epoch、672bit numeric identity、96bit linear context、A ref、row block及group，返回四row q/scale；原收据明确**未**覆盖下游Down。KB1的四行Down输入仍是TB预量化A，K2624=82组、N1024，4096F32/335872 PS及256 AW/W/B已验。两边组数/行数吻合，是下一有限接链的具体候选；尚未逐SHA核四行数据、scale与Down输入的同源身份，也未证明同runtime交接、背压、双槽与完整生产控制。

证据：`project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json`、`project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv`、`project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_comparison_20261013.md`。旧receipt的外部绝对路径仍指历史baseline，本项目复制树可读，但下一运行必须重新冻结并映射本项目路径，不能写回旧工程。


[原始消息收据](../../.research-agent/communications/measurement-next-G-quant-Down-readonly-20261013.json)

相关文件：[receipt.json](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json) · [geglu_gate_quant_bridge_v1.sv](../../project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv) · [KB0_KB1_Down_comparison_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_comparison_20261013.md)
### measurement-next-G-quant-Down-identity-20261013

2026-10-13T11:10:03.685176+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-ATN1-progress-review-20261013

# G量化输出与KB1预量化输入：定向字节身份

补充上一份只读定位：本项目复制树内原G桥04的 `work/fixture/q.mem` 与AT002 KB1的 `work/fixtures/a/q.mem` 均为21320B、SHA256均`7d99ba99cc3458df389add7b34483db5087f55a46cc5b29538ec363f1f4e8a76`；两份 `scale.mem` 均1640B、SHA256均`22a4b08447660550549fa4b2f509a61482e732be0dfdf0a1d43eff73989580c0`。故**冻结的独立期望输入**逐字节相同，四行×82组数据映射有直接依据。仍需由新有限DUT运行证明G真实producer经原完整身份和背压读口进入KB1 Down，而不能因fixture相同把两项旧PASS拼成实际链。


[原始消息收据](../../.research-agent/communications/measurement-next-G-quant-Down-identity-20261013.json)
### measurement-first-ATN1-close-GQD0-dispatch-20261013

2026-10-13T11:14:56.087534+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-ATN1-final-handoff-20261013

# ATN1限定保留，转GQD0真实算术连接

R-SM005-ATN1-CLOSE-20261013；2026-10-13；M004/SM005/E005/R001。回复`measurement-first-ATN1-final-handoff-20261013`，同时处理工程G→量化→Down接点与字节身份补证。

**集中核定：保留ATN1为已通过正常完整head及同DUT受影响协议验证的有限候选，本轮Attention调度阶段收束。下一阶段执行D-M004-GQD-INTEGRATION-01。** 不宣布生产采用或物理时序通过；没有第二Attention候选或新物理工具。

## ATN1核定结果

AT021原完整enc0/head0/B1/S128、128query/K128/D64及全部独立中间/最终逐位gold、M/A/D/EXP工作量保持。SM首次done287173→265084（−7.6919%）、实际consume287197→265108（−7.6912%）；正常QK+SM+AV首次done和604317→582228（−3.6552%），全TB1608896→1586807（−1.3729%）。各净少22089cycles，QK、AV、加载与done保持策略不变，四worker core-busy898680 slot-edges不变。ATN0条件空隙45855未被当成收益；新预备状态改变worker input_wait含义，按真实端点判断。

AT022 DUT与AT021同SHA `11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`，仅协议TB/runner改变。原log真实命中pending=1/ready=0和pending=0/ready=4，各对含11个新增字段的完整状态快照在CE低连续8拍保持，随后reset清空所有准备值/key/count/cursor/pending。原M/A/D/EXP活动覆盖和六首错bad_element/前行分数与原tile16_03一致，pending-Q CE/reset、错epoch/row、合法重载与chain检查保留。账本210966=210960+6；末尾同进程16行原数值、products131072/trees129024/AV131072/EXP2048通过。协议全TB1189951含额外负例与reset，不与normal full比较性能。

正常排空接受为有界源码不变量加动态佐证：一批预留后才能返回，真实A退休保存完整key，按空闲worker唯一分发，当前worker持有key到唯一EXP提交；接受lane总数不超过S，每次提交只增一次exp_written，第S项提交才能换行。该关系下正常行完成无剩余准备债务；源码没有把额外重复任务隐藏在完成条件外。独立全key数值及定向CE/reset支持本候选，**不是内部所有槽逐边沿形式证明或完整恢复证明**。新增179bit持久状态含数据，组合仲裁及物理FF/LUT/Fmax/联合资源UNKNOWN。

本轮继承已核AT021原始数值身份，只对新终态/协议及接点作定向核验。两份93冻结源、AT022 47项snapshot/实际静态副本、原log/收据一致；合并5段guard串行、63实际policy合规。AT022真实226.536195s、peak955724KiB、child0/trigger null；AT021 full482.110123s为工具成本。共435个当前文件引用核验，旧AT021 live后处理collector有一项已声明身份漂移：当时a7ee8c…已在进展审核实核，当前为协议增强f2ccd8…；它不在93份冻结DUT输入中，旧raw/numeric/measurement均未变。保留此历史live引用差异，不改旧收据、不要求重跑。

## 下一阶段决定

工程两份接点补证与主控定向核验一致：G桥04的独立q.mem/scale.mem与AT002 KB1对应期望逐字节同源，4行×82组匹配。下一任务选**GQD0四行真实G→GATE AXI写入/重读→量化→同一dualA→KB1 Down连续链**，详见[完整执行合同](../../mission/g_quant_down_integration_stage_20261013.md)。

保留原Wi输出作为明确声明的外部输入，原权重/metadata照实加载；移除Down的TB预量化A注入。GATE/q/scale/PS/结果必须全部来自真实DUT，在同进程且链间不reset；诊断driver可以发既有命令，不能伪READY/数据/退休。G与Down原算术/容量/gold/接口债务及KB1 writer保持，必要有限接线和等价适配按既有授权连续实现。

先产出新接链基线和实际交接/末B/lease/完成计量，不将旧59975与43947cycles相加当结果；不再本轮追加局部算术候选。保留原末B反压/身份拒绝检查，未变叶子按身份复用；不因这条有限接线恢复完整生产控制。GQD0新结果NOT_RUN，若在原帽内不能成立，交具体阻塞及已到达边界，不缩小目标或加帽。

A002继续唯一实现/工具，普通static/pilot/full及有据受影响修复无需新审批。请直接沿新合同推进；阶段完成或实质阻塞再集中交付。A002此次交付虽state仍running，其字段明确本阶段normal/protocol已完成、runtime=null；这与“工程会话仍可继续”一致，不以终态审核强停会话。

KB1保留；KB2/CT0收束；LQ0/LQ1限定事实保持，LQ1不生产采用、LQ1R关闭。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup仍停排。原单工具/资源帽、G2338.224019s仅OOC余额、5172s不重启及无新HLS/OOC/P&R/上板保持；M003/M004、全模型/13BO/完整请求/恢复/联合资源仍未完成。

证据：[主控终态核验](../../results/measurement_first_ATN1_close_20261013/verification.json)、[ATN1工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_attention_softmax_comparison_20261013.md)、[AT022原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT022_ATN1_prefetch_protocol_01/receipt.json)、[前次normal审核](../../results/measurement_first_ATN1_progress_review_20261013.md)、[GQD0执行合同](../../mission/g_quant_down_integration_stage_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-ATN1-close-GQD0-dispatch-20261013.json)

相关文件：[g_quant_down_integration_stage_20261013.md](../../mission/g_quant_down_integration_stage_20261013.md) · [ATN1_attention_softmax_comparison_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_attention_softmax_comparison_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT022_ATN1_prefetch_protocol_01/receipt.json)
### measurement-first-GQD0-result-handoff-20261013

2026-10-13T11:59:29.324132+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-ATN1-close-GQD0-dispatch-20261013

# GQD0四行真实接链完成，提交集中审核

回复 measurement-first-ATN1-close-GQD0-dispatch-20261013；M004/SM005/E005/R001；A002工程唯一实现/工具。AT025同一runtime原四distinct Wi F32→真实10496 GATE F32/656 AW-W-B→656拍真实AR-R重读→328量化组/桥内唯一dualA→KB1 Down 82次A返回→全部335872 PS lane-group/4096 F32/256 AW-W-B及一次实际done消费，原独立gold与末B、lease、局部publication断言通过。链间未reset；TB无预量化A或中间文件回灌，源/fixture身份详见原manifest及连接表。

全冷TB=102660cycles；G合法接受cycle25→Down实际消费102659=102634cycles。G桥响应消费/A已ready为59403；W加载59404→86468=27064；Down cfg86469→first done102652=16183，→consume102659=16190。GATE实际656 AW/W/B、15 AR/656 R；Down实际256 AW/W/B及16384B有效/物理W。AT025 static/pilot/full守卫均child0/null；成本81.608666/78.475066/747.161240s，full peak1483444KiB；80项冻结引用逐SHA/bytes复核。pilot只到首行真实GATE 164 AW/W/B，未代签量化/Down。

AT023 static PASS、pilot120.341961s timeout；AT024 static/pilot PASS、full127.533100s semantic_stall。AT024 raw已真实到第2行Wi完成，停止原因为新进展标记不被原guard识别；AT025第二轮只改标记为原MATRIX_PROGRESS，DUT/fixture/gold/响应策略不变。两次停止原receipt保留。

口径限制：继承Down观察的A_fill_accept=23实际是故意拒绝的G探针，合法G接受以cycle25标记为准；A_publish_post_NBA=59403是G响应消费后“A已ready”，不是最早A-bank发布边沿。GATE首AW和末B未逐边沿记录，报告只给真实计数形成的界限，不虚构精确时间。单次冷诊断样本不能与旧G59975/Down43947相加比较，也不签物理/联合资源、生产13BO、完整请求或恢复。无本项目重工具在跑，G仅OOC余额/5172s不重启及全部禁排保持。

证据：
- project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_integrated_chain_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_connection_map_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_evidence_check_20261013.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/receipt.json
- E005三摘要2026-10-13 11:58UTC publication P9afeffee77654d74a88def4a650a1d00

请按原合同集中核定这条有限结果并决定下一阶段；当前不自启另一算术/控制实验。


[原始消息收据](../../.research-agent/communications/measurement-first-GQD0-result-handoff-20261013.json)

相关文件：[GQD0_integrated_chain_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_integrated_chain_20261013.md) · [GQD0_connection_map_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_connection_map_20261013.md) · [GQD0_evidence_check_20261013.json](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_evidence_check_20261013.json) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/receipt.json)
### measurement-first-GQD0-review-WI0-dispatch-20261013

2026-10-13T12:13:23.062637+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-GQD0-result-handoff-20261013

# GQD0限定接链验收，转入真实Wi resident出口

R-SM005-GQD0-20261013；2026-10-13；M004/SM005/E005/R001。回复`measurement-first-GQD0-result-handoff-20261013`，合并工程`measurement-first-GQD0-upstream-Wi-identity-20261013`补证。

**核定AT025为四行normal同runtime G→量化→共享dualA→KB1 Down的限定RTL数值、数据交接和完成PASS。下一阶段执行D-M004-WI-RESIDENT-01，补齐真实Wi矩阵输出。** 完整Wi→G链、全请求和物理可部署性均未验；不关闭M003/M004。

## GQD0核定范围

初始reset后连续执行，外部仅输入原20992个Wi F32及W/metadata/配置。G真实产生10496个F32，经656 AW/W/B写入存储；量化通过15 AR/656 R真实重读并产生328组q/scale。bridge内quant_task唯一dualA直接连接Down acquire/read/return/release；82次四行A返回、335872 PS lane-group、512 TN8 packet、4096最终F32全部原独立gold通过，Down实际256 AW/W/B、16384有效/物理字节，最后B、A/W lease释放、局部publication及一次真实done消费闭合。TB不预填中间A，不文件回灌；gold仅比较。实际DUT保留原容量/数值/响应策略。

全冷TB102660cycles；合法G任务标记25→Down实际消费102659，链区间102634。桥响应消费且A已ready为59403；W严格加载59404→86468为27064；Down cfg86469→first done102652为16183、→实际消费102659为16190。Down末PS102509→末B102644为135，末B→done8，再故意保持7拍。Down计算完成边界与KB1一致，此新链是基线，不以旧独立G59975和Down43947相加比较收益。

接纳计量的明确限制：`A_fill_accept=23`为故意拒绝的G探针，不能作合法起点；59403是响应消费后的A已ready观察，不是最早发布边沿；GATE首AW/末B没有准确逐边沿时间戳，只保留实际计数形成的界限。原合同所要求的这些精确事件仍缺失，不将报告写为全事件计量完成；它们不推翻本次完整正常数值/真实交接及链区间，不为补时间戳重跑747s full，后续入口从实际握手边沿直接记录。

## 原始身份、失败与成本

主控核对三attempt各80个冻结引用项（AT025为78个唯一冻结路径，共用row-bank/dualA重复引用身份相同）、原source/frozen pair、收据与日志以及Wi8项fixture，共504引用/338路径。不可变引用零不符；AT023 live TB/runner和AT024 live TB三项变化恰为两轮已冻结的受影响修复，历史live差异单列，不回写旧receipt。实际static入口直接编译冻结源；DUT、fixture、gold在三版不变。

AT023 static PASS，pilot120.341961s timeout，无完成数值结论。AT024仅补真实首行GATE末B的pilot出口/runner标记、进展打印及batch1输出地址观察；static/pilot通过，full127.533100s semantic_stall，原raw已到第二行Wi。AT025仅把三个G进展打印改为原guard识别的MATRIX_PROGRESS；据此接纳此次有因修复，不把AT024停止认定为DUT死锁，也不删除失败。

AT025 static/pilot/full为81.608666/78.475066/747.161240s，三段child0/trigger null，full峰1483444KiB。pilot只证明首行5248 Wi词/164 GATE AW/W/B，不代签量化/Down；full有保守准入估计1117.692396s。三attempt共8段核心guard、135实际policy全部串行且策略合规。另有5段波形help/query后处理、15policy，亦串行；其中一次query child1，未取得额外精确时间戳。后处理不是新DUT回放，其失败不混记为数值FAIL，也不宣称全部guard皆0。主控未运行DUT工具。

## 下一任务：真实Wi完整输出

工程补证与主控独立解码相符：AT025 Wi mem与原桥04同SHA `3451f215f3e775d9c50cad722131fd0322a8c7ae557f74c14f80d2b753b197a7`；20992个little-endian F32词与原独立Wi binary（SHA `b5542b2f20473041f9f420cc740ebef48343c714b98b6748c0f5ba1c5cff4d25`）完全一致。不同编码不比较原文件hash来判同一。该证据证明期望数据口径一致，未证明真实Wi producer。

现resident与KB1 writer静态支持K1024/N5248/op0x32，原Wi模型记录明确bias_kind0。旧Wi full只有乘加/中间PS，没有当前resident真实W/A供数与writer出口；故下一**WI0四行真实resident Wi**先把此缺口闭合，详见[执行合同](../../mission/wi_resident_producer_stage_20261013.md)。输入边界明确为原LN_FFN预量化A；完整671744 PS lane-group及20992 F32、实际AXI/最后B/发布/lease/完成必须通过。不重复旧算术测试，不增加第二矩阵引擎、不预签Wi→G连接。

WI0使用原容量/原gold/原响应规则，按static→pilot→有据full连续推进，最多两轮有因受影响修复。普通实现无需新审批；取得出口或实质阻塞后集中交付。之后以单引擎复用、真实Wi存储重读和原A/W身份为下一连接依据；不把未知通用控制器重新放到算术关键路径。

KB1/ATN1/GQD0限定保留；KB2/CT0/LQ1R本轮收束，LQ1不生产采用。原单工具/全部资源帽、G2338.224019s仅OOC余额、5172s不重启、无新HLS/OOC/P&R/上板及整体控制/冷INIT/恢复停排保持。完整28+2层/122矩阵、13BO/完整请求/恢复/联合资源与时序均未验，M003/M004未完成。

证据：[主控核验](../../results/measurement_first_GQD0_review_20261013/verification.json)、[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_integrated_chain_20261013.md)、[连接表](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_connection_map_20261013.md)、[AT025原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/receipt.json)、[WI0执行合同](../../mission/wi_resident_producer_stage_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-GQD0-review-WI0-dispatch-20261013.json)

相关文件：[wi_resident_producer_stage_20261013.md](../../mission/wi_resident_producer_stage_20261013.md) · [GQD0_integrated_chain_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_integrated_chain_20261013.md) · [GQD0_connection_map_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/GQD0_connection_map_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/receipt.json)
### measurement-first-WI0-result-handoff-20261013

2026-10-13T12:56:22.646985+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-GQD0-review-WI0-dispatch-20261013

# WI0 限定结果交付；M004/SM005/E005/R001

回复 measurement-first-GQD0-review-WI0-dispatch-20261013；A002 唯一实现/工具。本轮 WI0 AT028 static、W前缀pilot、四行normal full均PASS，原始[报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WI0_resident_producer_20261013.md)、[复核](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WI0_evidence_check_20261013.json)、[收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT028_WI0_resident_03/receipt.json)与E005三摘要已发布；当前无本项目重工具。

四distinct预量化LN_FFN A经真实dualA/严格三W缓存/唯一resident/KB1 writer，20,992 Wi F32、671,744 PS lane-group均按原独立gold通过。W q0/q1/scale实际R为41,984/41,984/5,248；输出1,312 AW/W/B、83,968有效/物理B、末B、A/W lease、局部发布及一次done消费闭合。cfg→首次done46,911cycles，→实际消费46,918；全冷101,335。W LOAD→READY 54,124cycles。AT028 full guard893.130500s/peak1,456,184KiB，child0/null；三guard串行、45实际policy合规。28冻结源/脚本与22fixture逐SHA/bytes复核，相对KB1仅TB与两入口Tcl派生；三尝试间冻结DUT和数据fixture相同。

AT026源ref从Down GATE误继承导致A fill拒绝，pilot FAIL；AT027修成Wi NORM ref2后pilot达120.371s硬帽，记COST_STOP；AT028只补真实W进展/前缀pilot，full按启动前3,000s估计进入并完成。原失败不改写。

重要限定：TB对每笔真实AW边界、WSTRB、输出地址唯一性和F32位型逐项动态检查，因而该事务模型中未观察到范围外写；它**没有独立byte-addressed DDR哨兵数组的最终读回**，原合同“范围外哨兵保持”的字面测试未完成。请主控据此限定本次接纳范围。Wi→G同runtime、生产请求/恢复、联合资源及物理时序仍NOT_RUN；勿把WI0与GQD0周期相加。按原合同，下一步可集中选择单矩阵引擎分时复用与Wi实际存储重读→G的最小接点；不擅自恢复整体executor或增加本轮工具帽。


[原始消息收据](../../.research-agent/communications/measurement-first-WI0-result-handoff-20261013.json)
### measurement-first-WI0-connection-map-20261013

2026-10-13T13:02:46.289109+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-GQD0-review-WI0-dispatch-20261013

# WI0→GQD0：只读接点核查

2026-10-13；M004/SM005/E005/R001。此表只核当前已运行诊断与本项目现有RTL的接线条件，未生成或运行新连接。

| 接点 | 当前事实与后续验证条件 |
| --- | --- |
| Wi 写入 | AT028 writer op32、dst ref `0x0000000600000001`，在 `cfg_region_base[0]=0x100001000` 起按四行连续 20,992B/行写满 83,968B；1,312 AW/W/B 和独立 F32 gold 已过。当前配置 batch0、row0。 |
| 已有真实 Wi 读口 | `rtl/laya_wi_axi_reader_v1.sv` 当前 SHA256 `c09248fc14750a8d9fa23e2e0e2343b9bd1c047b81f44279e470105dd047c1f6` 与 E003/R003/`wi_axi_reader_03` 冻结源相同，原独立 AXI512/4KiB 切分/错误排空测试 PASS。它按 `region_base + batch*21495808 + row*20992` 发 AR，强制 source ref 类6、行步长20992B、批步长21495808B，并在真实 R 后按完整 identity/ref/row/index 提供标量及 row_done/debt。旧 PASS 未覆盖 AT028 同进程存储。 |
| 现有 GQD0 输入 | AT025 的 `gqd0_chain_tb_v1.sv` 从 `wi.mem` 直接驱动 `g_wi_valid/data/status/identity/ref/row/index`，没有实例化上述真实读口；它的 G producer context 是 batch1、row0=7，Wi ref同为类6。数值 fixture 与 Wi0 期望逐词相同，但这些坐标与 WI0 batch0/row0 不同，不能仅凭数据一致宣称生产身份衔接。 |
| 必需物理交接 | 同进程、链间无reset：Wi writer 实际 AW/W/WSTRB 修改唯一 Wi DDR 模型；实际最后 B、Wi 发布/lease 结束后由真实 `laya_wi_axi_reader_v1` 对同一地址发 AR/R；读回字节逐项与刚写数据和独立gold关联，reader 真实 valid/ready、row_done 与 debt 供 G 使用。不得用 `wi.mem` 回灌输入。 |
| 资源唯一性 | WI0 测试台和 GQD0 测试台各自包含 resident/strict W/KB1 writer；两者直接拼接会产生第二套矩阵引擎。WI0 的预填 dualA 与 GQD0 桥内量化 dualA 也各自存在；后续必须明确一个矩阵引擎分时 Wi→Down、原双槽 A/W 的唯一物理权威及 Wi 输入租约释放后 G 量化写入的顺序。 |

按原四行 fixture 的来源坐标，最小诊断身份应先统一 batch0/row0；或者主控给出有来源的实际 batch1/row7 fixture 与布局映射。改变 GQD0 现有诊断坐标会影响其身份/地址检查，需在下一阶段合同明确，不能把现有 AT025 当新坐标已通过。按当前 20992B 行大小，四行实读期望 1,312 个 AXI512 R beat；AR burst 数须由真实地址/4KiB 切分实测，不预签。

上述只是后续连接的可证伪入口。GATE、量化、Down 的原独立gold、末B/lease、发布和实际消费仍须在同一新冻结身份重验；Wi→G→Down 全冷周期也必须实际计量，不能相加 AT028 与 AT025。


[原始消息收据](../../.research-agent/communications/measurement-first-WI0-connection-map-20261013.json)
### measurement-first-WI0-review-WIGQD0-dispatch-20261013

2026-10-13T13:08:18.392850+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-WI0-result-handoff-20261013

# WI0限定接纳，转单引擎Wi→G→量化→Down连续连接

R-SM005-WI0-20261013；2026-10-13；M004/SM005/E005/R001。回复`measurement-first-WI0-result-handoff-20261013`，合并`measurement-first-WI0-connection-map-20261013`接点补证。

**集中核定AT028正常四行Wi resident的完整数值、实际AXI事务与局部完成PASS；独立DDR哨兵数组最终读回仍NOT_RUN，不把本阶段写成原合同全部条款已完成。下一执行D-M004-WIGQD-INTEGRATION-01，将真实Wi输出经存储重读接入GQD0，并复用同一矩阵引擎、同一A/W缓存。** 普通实现/验证按原授权继续，无新增审批。

## WI0已证事实与缺项

原四distinct预量化LN_FFN A经真实dualA完整fill/commit/finish，严格三口W加载/缓存，唯一resident TM4/PS及KB1 writer。完整20992 stripes、671744 PS lane-group、2624 TN8 packet和20992最终F32按原独立gold通过；A实际32组返回、W20992次返回，q0/q1/scale真实R为41984/41984/5248，scale检查167936次，输出1312 AW/W/B、83968有效/物理字节。原bias_kind0与数值规则保持。

AW范围/地址对齐、WSTRB、每个有效输出地址唯一和F32位型逐项动态检查，末B之后局部publication、A/W lease归零、7拍done保持及一次真实消费通过。这个事务模型足以支持上述限定结论；它没有一份独立按字节寻址的输出DDR和范围外哨兵最终读回。旧收据和缺口原样保留，不要求为重复已有数值再单独重跑893s WI0；下一真实存储连接必须补字节存储与保护区读回，只签新样本的对应覆盖。

原数据来自B1/S128 checkpoint；AT028实际诊断numeric identity的B字段为2、S128，batch0/row0=0、仅四行。这与真实两batch运算不同，不把该元数据配置扩大成B2全量验证。新链统一原四行坐标及B1/S128身份，不拼用AT025 batch1/row7。

全冷TB101335cycles；Wi cfg54416→首次done101327=46911，→实际消费101334=46918。W LOAD291→READY观察54415=54124；末PS101185、末AW101300、末W101301、末B101319，末B→done8、done→消费7。互斥state之和46911，重叠stall和TB held_B23616不作可消除延迟加总。它是新Wi基线，不与GQD0或旧乘加周期相加当连续链性能。

## 身份及停止记录核验

三attempt各28份冻结源/脚本、22fixture及原收据/日志/fixture身份共452引用、214路径核对，不可变引用零不符。相对KB1仅Wi TB与两入口Tcl派生，真实DUT不变；三尝试间只改TB。21项数据fixture不变，streams/manifest因绝对路径变化而变。五项旧live runner/builder/TB差异单列保留，不回写历史。原raw的全部边界、state、W供数、输出计数与工程JSON逐字段一致。

AT026源ref误用Down GATE类7，真实A fill拒绝；保留FAIL。AT027只改为Wi NORM类2，pilot120.371384s timeout，保留COST_STOP。AT028只补真实W R每512拍进展及W前缀pilot；pilot19.839547s，实际A已发布、q0/q1各1024 R、scale339 R，明确W READY/PS/output未到。启动前3000s成本估计引用了该真实前缀与既有成本，未调整原硬帽。

AT028 static/pilot/full为57.869275/19.839547/893.130500s，child0/trigger null；full峰1456184KiB。AT028三guard/45policy合规；三尝试共7guard/119policy串行且策略合规，旧失败照实计入。主控仅只读核验，未运行DUT工具。

## 下一阶段决定

工程接点表与主控所查接口一致：实际Wi dst类6、region起点0x100001000、20992B行步长；已有真实Wi reader与wi_axi_reader_03冻结SHA相同。AT028输出独立gold mem与AT025外部Wi mem仍同SHA、20992词相同；这只证明数值口径，不证明已连通。

[WIGQD0执行合同](../../mission/wi_g_quant_down_integration_stage_20261013.md)明确：原四行外部预量化A→真实Wi写存储/末B发布→真实Wi reader AR/R→G→GATE写读→量化→同一dualA→同一resident Down。统一batch0/row0及完整身份；一套矩阵引擎、一套dualW、一套dualA，原容量不变，slot0 epoch1→2在真实lease/读债归零后切换，链间不reset。必要共享A端口外提或等价透传属于本轮有限连接实现，状态更新仍归原存储，不新建通用owner/退休权威。

新链必须通过完整原Wi/G/quant/Down gold、两段真实末B/消费、物理Wi重读和独立保护字节读回，并取得新冷基线。已验证未变叶子按身份复用，新增边界在同runtime实际验证；不先恢复完整executor或错误恢复关键路径。最多一个接链实现及两轮有因修复，原static/pilot/full及资源帽保持，成本不足有据停止。

KB1/ATN1/GQD0/WI0有限事实保留；KB2/CT0/LQ1R本轮收束，LQ1不生产采用。G2338.224019s只OOC余额、5172s不重启，无新HLS/OOC/P&R/上板或预算。完整请求、全模型/122矩阵、生产13BO、恢复、联合资源/物理时序以及M003/M004仍未完成。

证据：[主控核验](../../results/measurement_first_WI0_review_20261013/verification.json)、[WI0报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WI0_resident_producer_20261013.md)、[AT028原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT028_WI0_resident_03/receipt.json)、[WIGQD0合同](../../mission/wi_g_quant_down_integration_stage_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-WI0-review-WIGQD0-dispatch-20261013.json)

相关文件：[wi_g_quant_down_integration_stage_20261013.md](../../mission/wi_g_quant_down_integration_stage_20261013.md) · [WI0_resident_producer_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WI0_resident_producer_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT028_WI0_resident_03/receipt.json)
### measurement-first-WIGQD0-bounded-stop-handoff-20261013

2026-10-13T13:59:22.757497+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-WI0-review-WIGQD0-dispatch-20261013

# WIGQD0 有界停止交付：请集中判断下一路线

回复`measurement-first-WI0-review-WIGQD0-dispatch-20261013`；M004/SM005/E005/R001，D-M004-WIGQD-INTEGRATION-01。工程A002已按“一次接链实现、两轮有因修复”上界收束WIGQD0；当前无本项目重工具运行，不启动第三版、不加帽。请主控在既有职责内审核已达边界和后续单独任务取舍；本消息不请求新的用户授权，也不声称整链通过。

AT029静态端口名错误FAIL；AT030 static/pilot PASS、full在Wi W长读取时120s无可识别进度而COST_STOP；AT031第二轮补实际W进度后static/pilot PASS，full在同runtime、无链间reset下完成四行真实Wi resident：20992 F32、671744 PS lane-group、1312 AW/W/B，末B、lease/读债及一次done消费闭合；唯一DDR的Wi有效区83968B在切换前逐字节读回并对原独立gold通过。Wi全冷至完成cycle101335；cfg→首次done46911cycles、→实际消费46918cycles。随后G命令接受，末条观测`cycle=101339 GQD0_cfg_accepted=1`；120s无新语义标记后guard使full COST_STOP（1137.182375s，峰1504604KiB，child−9）。101339不是已证最终停拍，现有证据不能判死锁或唯一根因。

Wi reader完整AR/R、G/GATE/量化/Down gold和最终消费、全存储保护字节终读回、整链周期均未取得。原WI0/GQD0独立PASS不能拼成同runtime PASS；M003/M004未完成。三attempt共306个文件身份引用均匹配、7guard串行/122实际policy合规。工程已发布E005三摘要、更新A002真实终态和模块结果；原收据/日志不回写。

主证据：[WIGQD0阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_bounded_stop_20261013.md)、[接线/身份表](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_connection_map_20261013.md)、[身份核对](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_identity_audit_20261013.json)、[AT031原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/receipt.json)、[AT031原始full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/raw_full.log)。


[原始消息收据](../../.research-agent/communications/measurement-first-WIGQD0-bounded-stop-handoff-20261013.json)
### measurement-first-WIGQD0-observation-addendum-20261013

2026-10-13T14:02:05.265971+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：risk；送达：delivered；回复关联：measurement-first-WI0-review-WIGQD0-dispatch-20261013

# WIGQD0 停止点只读补证：G 阶段缺行级进度标记

补充`measurement-first-WIGQD0-bounded-stop-handoff-20261013`，不改变AT031的COST_STOP和两轮修复上界。

AT025冻结GQD0测试台在合法G命令后每行Wi完成时打印`MATRIX_PROGRESS GQD0_Wi_row`；原full日志四行分别在cycle5294/19454/33617/47780出现。AT031冻结WIGQD0测试台没有该行级打印；其G命令接受后，下一个显式`MATRIX_PROGRESS`是全部G/量化完成后的`GQD0_A_ready`。AT031仍在代码中累计真实`wi_accepted`、`wi_rows_retired`并检查身份和债务，但COST_STOP前无计数快照。因此120秒无新标记既可能是观测空窗，也可能是真实停滞；不能从末条cycle101339确定DUT最终状态。

证据位置：[AT025冻结测试台](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/gqd0_chain_tb_v1.sv)、[AT025原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/raw_full.log)、[AT031冻结测试台](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv)、[AT031原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/raw_full.log)、[阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_bounded_stop_20261013.md)。工程不启动第三版/重跑，供主控集中判断下一有界诊断入口。


[原始消息收据](../../.research-agent/communications/measurement-first-WIGQD0-observation-addendum-20261013.json)
### measurement-first-WIGQD0-identity-correction-20261013

2026-10-13T14:10:57.324946+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：risk；送达：delivered；回复关联：measurement-first-WI0-review-WIGQD0-dispatch-20261013

# WIGQD0 派生路径计数更正

工程此前的`WIGQD0_identity_audit_20261013.json`与阶段报告误写每版“60个不同冻结路径”。从AT029/030/031各自原`input_manifest.json`的102条`files[*].frozen.path`直接去重，正确数字均为**100**。已更正两份工程派生记录；本次重新逐一读取306条冻结引用，文件bytes和SHA均与原manifest相符。历史manifest、receipt、raw和已发送消息正文保持原样，错误仅影响工程报告中的去重计数，不改变数值/COST_STOP范围。

证据：[身份核对](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_identity_audit_20261013.json)、[阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_bounded_stop_20261013.md)、[AT031原manifest](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/input_manifest.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-WIGQD0-identity-correction-20261013.json)
### measurement-first-WIGQD0-review-observation-dispatch-20261013

2026-10-13T14:13:41.293518+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-WIGQD0-bounded-stop-handoff-20261013

# WIGQD0有界停止审核：接纳Wi实存储边界，转一次观测诊断

R-SM005-WIGQD0-20261013；2026-10-13；M004/SM005/E005/R001。回复`measurement-first-WIGQD0-bounded-stop-handoff-20261013`，合并`measurement-first-WIGQD0-observation-addendum-20261013`及`measurement-first-WIGQD0-identity-correction-20261013`。

**AT031保留COST_STOP，整条Wi→G→量化→Down仍未通过。限定接纳同runtime实际Wi输出、有效区逐字节读回、末B/lease及一次消费；旧实现加两轮修复到此结束。下一执行D-M004-WIGQD-OBSERVATION-01：同DUT/数据/响应策略的一次有界观测诊断，不追加第三轮DUT修复，不提高保护阈值。** 这是主控既有职责内的阶段选择，无需新的用户批准。

## 已证边界

AT031仅初始reset，一套resident TM4/PS/KB1 writer、原容量dualW/dualA、原G/量化和真实Wi reader已接线。实际执行到Wi完整四行：20992 stripes、671744 PS lane-group、2624 packet和20992 F32原独立gold通过；1312 AW/W/B、83968有效/物理字节、最后B、局部发布、A/W lease/读债归零、7拍完成保持及一次真实消费通过。

新的字节DDR由真实AW/W/WSTRB更新。在切换前逐字节核83968B Wi有效区、written标记和独立gold，后续Wi完成marker已到达。因此本新样本的Wi有效区读回可以接纳；全存储保护字节最终扫查、GATE/Down区域读回还未执行完，不追认AT028未做的旧哨兵测试。

Wi cfg54416→first done101327=46911cycles，→消费101334=46918；W LOAD291→READY观察54415=54124。末PS101185、末AW101300、末W101301、末B101319；Wi完成marker101335。原DOWN_MEASURE标签在这段记录的是Wi，不能误称Down已完成；A_fill_accept=-1也不能补造起始边沿。末条已观测标记为cycle101339的G接受，不能认定它是最终停拍或实际死锁点。

## 原收据、身份与观测缺口

AT029 static端口名错误FAIL；AT030 static/pilot PASS、full COST_STOP；AT031 static/pilot PASS、full COST_STOP。相邻冻结差异均仅TB；第二轮具体包括W fixture容量、真实W R进度及阶段观察，并非仅加日志。两条历史live TB引用差异对应后续修复，旧冻结内容保留。

主控核638个source/frozen/receipt引用、420唯一路径，其中306个冻结manifest行全部匹配；每版102条files去重为100个冻结路径，主控独立核数与工程最新更正一致，旧报告60的错误不继承。不可变引用零差异。7段guard无重叠、122条实际policy符合原策略，收据与guard原结果一致。AT031 static/pilot/full为81.865201/22.423815/1137.182375s；full峰1504604KiB、child−9、trigger=semantic_stall。墙钟为工具成本。主控仅只读核验，未运行DUT工具。

冻结TB的1543行打印G接受，1571行才打印全部G/量化完成的A_ready；中间没有实际Wi reader AR/R、标量/row_done、G算术/GATE写回或量化进度打印。1167–1185行及1220–1233行已有真实握手计数/身份/债务断言，但本日志没有其运行时快照。原AT025每行打印的GQD0_Wi_row也未迁入。原guard识别MATRIX_PROGRESS，W/PS计数在这段通常不推进，因此存在覆盖整个G阶段的观测空窗。

这是一条足以支持新诊断的静态证据，**不能证明AT031在停止前确实继续推进，也不能判唯一根因就是日志缺失**。reader等待G输入ready、G行屏障、实际读/写债务等仍需动态证据。量化缓存的physical_half/scale计数本来在合法fill开始时归零；没有证据要求把G断言改成Wi和G累加数，不据猜测修改该断言。

## 具体下一任务

[WIGQD1观测合同](../../mission/wi_g_quant_down_observation_stage_20261013.md)已确定，工程A002直接执行：

- 从AT031派生，只补观察/诊断和必要导出；DUT、fixture、gold、驱动时序、响应profile、单实例/容量、epoch和无链间reset保持。
- 实际reader配置/AR/R/标量/row_done、G issue/return/GATE AW/W/B、量化提交/发布建立有界递增进度。另记不匹配guard任何关键词的有限状态快照，原120s无真实语义进展仍停止。
- 原static→≤120s真实前缀pilot→一次有成本依据full。无已核checkpoint，保留完整Wi前缀以验证同runtime交接；不预装中间结果。full仅一次，失败/停止即交证据集中取舍，不自行再改硬件或续跑第二full。
- 若自然跑到原结尾，必须通过完整两段PS、Wi/G/quant/Down gold、真实reader、末B/lease/消费及全存储保护区读回，才可签有限整链PASS；否则只签已到达边界。

当前新诊断结果NOT_RUN。原WI0/GQD0独立通过仍不能拼接为本链通过；全链周期、生产请求/恢复、联合资源及物理时序UNKNOWN。KB1/ATN1有限保留，KB2/CT0/LQ1R收束、LQ1不生产采用。原单工具/帽、G2338.224019s仅OOC余额、5172s不重启和整体控制/HLS/OOC/P&R/上板禁排保持，M003/M004未完成。

证据：[主控核验](../../results/measurement_first_WIGQD0_review_20261013/verification.json)、[原阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_bounded_stop_20261013.md)、[工程观测补证](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_observation_addendum_20261013.md)、[AT031原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/receipt.json)、[AT031原日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/raw_full.log)。


[原始消息收据](../../.research-agent/communications/measurement-first-WIGQD0-review-observation-dispatch-20261013.json)

相关文件：[wi_g_quant_down_observation_stage_20261013.md](../../mission/wi_g_quant_down_observation_stage_20261013.md) · [WIGQD0_bounded_stop_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_bounded_stop_20261013.md) · [WIGQD0_observation_addendum_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_observation_addendum_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/receipt.json) · [raw_full.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/raw_full.log)
### measurement-first-WIGQD1-AT032-scoped-full-result-20261013

2026-10-13T14:56:37.772761+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-WIGQD0-review-observation-dispatch-20261013

# WIGQD1 AT032有限完整链结果，供A001集中审核

回复 measurement-first-WIGQD0-review-observation-dispatch-20261013。A002按D-M004-WIGQD-OBSERVATION-01仅执行一次新full；同AT031 DUT、fixture、gold和响应策略，仅观察TB变化、另冻结runner。static/pilot/full均child0、trigger null，full1750.811857s、峰1504888KiB，原成本准入估计2871.684102s<3600s。

正常B1/S128、batch0/row0四行同runtime连续链全部原独立gold和真实交接PASS：预量化LN_FFN外部A→Wi resident 20992F32/671744PS、1312 AW/W/B→实际DDR/reader 1312R→G 10496 GATE F32、656 AW/W/B→量化656R/328组→同dualA epoch2→Down 335872PS/4096F32、256 AW/W/B。两段末B、A/W lease、7拍保持及一次实际done消费通过。最终327680B DDR全扫：83968B Wi、41984B GATE、16384B Down逐字节gold，其余185344B哨兵及written标记无破坏。全TB205314cycles；G cfg101339→结束103975，Down cfg189122→消费205313为16191。旧WI0/GQD0独立周期未相加。

旧AT031最后G接受cycle101339后的观测空窗在本次显出真实进展：reader cfg101341、首AR/R101343/101347、四次row_done、G算术、GATE首/末B110109/159328、量化R159341/161680、新A publish162045、Down完成。旧COST_STOP原样保留，不写成旧DUT死锁或旧full通过。

103行manifest/101不同冻结路径；相对AT031只有第57行TB SHA改变并新增runner，206份source/frozen bytes/SHA与tool身份全匹配。3段guard实际policy31/9/9全部合规，状态快照通过冻结正则检查而不会续命。原`WIGQD_BOUNDARIES A_publish=290`是Wi前置A发布，不能用于新量化A；应看新增真实marker162045（bridge消费后ready观察162057）。

报告与可复算证据：
- project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_observation_result_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/raw_full.log
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/verification.json

E005三摘要及A002实际状态已同步，当前无本项目重工具。请求按有限四行normal链审核并集中选择后继；完整全模型/生产13BO/请求与恢复、联合资源/物理时序及M003/M004不关闭。不另启候选或重工具。


[原始消息收据](../../.research-agent/communications/measurement-first-WIGQD1-AT032-scoped-full-result-20261013.json)

相关文件：[WIGQD1_observation_result_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_observation_result_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/receipt.json) · [raw_full.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/raw_full.log) · [verification.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/verification.json)
### measurement-first-WIGQD1-upstream-LN-identity-20261013

2026-10-13T15:00:46.995919+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-WIGQD0-review-observation-dispatch-20261013

# WIGQD1上游LN身份补证

补充刚送达的AT032 handoff：只读核AT028来源manifest与AT014 LQ0 fixture。AT032所需Wi输入是enc0 LN_FFN batch0/row0–3；16,384B源与原完整LN_FFN capture前四行逐字节相同，SHA `658b5a8d...`。AT014 LQ0则为stage2/layer1 LN_ATTN row0–15。两者前四行源/q/scale分别有14,496/3,964/238个不同字节（总16,384/4,096/256B）。因此不能将LQ0的normal数值PASS拼接为WIGQD1真实上游；需要匹配LN_FFN的producer与量化窗口及生产P/Q/L/Ref/epoch证明。只读补证未启动工具，也不恢复已暂停的M003生产控制。

完整身份与来源见 project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_upstream_LN_identity_addendum_20261013.md。


[原始消息收据](../../.research-agent/communications/measurement-first-WIGQD1-upstream-LN-identity-20261013.json)

相关文件：[WIGQD1_upstream_LN_identity_addendum_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_upstream_LN_identity_addendum_20261013.md)
### measurement-first-WIGQD1-review-QWIGQD0-dispatch-20261013

2026-10-13T15:07:40.301843+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-WIGQD1-AT032-scoped-full-result-20261013

# WIGQD1正常四行连续链接纳，转真实量化供数

R-SM005-WIGQD1-20261013；M004/SM005/E005/R001。回复`measurement-first-WIGQD1-AT032-scoped-full-result-20261013`，合并`measurement-first-WIGQD1-upstream-LN-identity-20261013`。

**限定接纳AT032同runtime正常四行Wi→真实DDR/reader→G→量化→同dualA→同resident Down整链PASS。全冷TB205314cycles，全部原独立gold、末B/lease/完成消费及有效区/保护字节终读回通过。下一D-M004-QWIGQD-INTEGRATION-01复用现有量化器处理同源LN_FFN浮点输入，去掉Wi入口预量化A；暂不接不同来源的LQ0，也不恢复整体控制。** 普通实施与验证直接沿既有授权继续。

## 数值、真实交接与存储

本次只有初始reset；一套矩阵引擎/dualW/dualA，Wi用epoch1，真实排空后G量化/Down用epoch2。Wi完整20992F32/671744 PS lane-group及1312 AW/W/B；真实DDR提供1312 R、四次row_done及20992个按完整身份核验的标量给G；G完整10496F32/656 AW/W/B；原量化真实重读656R、328组；Down完整335872 PS/4096F32和256 AW/W/B均对原独立gold通过。Wi与Down末B、lease/读债归零、局部发布、7拍响应保持及各一次真实消费保持。

最终全扫327680B：Wi83968、GATE41984、Down16384逐字节gold与written覆盖；其余185344B仍为0xA5且未写。冻结TB1724–1742的原final_ddr_readback全部执行后才到1755的CHAIN_PASS。它补齐本新样本的最终保护区覆盖；不回写旧WI0缺失项或旧AT031 COST_STOP。

## 周期口径与停止判断

Wi cfg54416→first done101327=46911、→消费101334=46918，完成marker101335。G实际接受101339；reader配置101341、首AR/R101343/101347，四row_done106944/121440/135936/150435。GATE首B110109、末B159328；量化首末R159341/161680，新A实际发布162045，bridge响应后ready观察162057。

Down cfg189122→first done205306=16184，→真实消费205313=16191；全TB205314。**G接受→全TB结束的区间为103975cycles，不能写成“结束cycle103975”或当作单独G计算时间。** G接受→最终消费为103974，→新A发布60706。相对独立KB1/GQD0的Down16190差1拍，来自不同集成边界/绝对响应相位的本次样本，不能直接判新优化或退化。

原WIGQD_BOUNDARIES的A_publish=290是Wi前初始A发布；新量化A用stage1实际marker162045，162057仅ready-by。原Down观察A_fill_accept101337是拒绝探针，不是合法G接受；held_B28225累计跨Wi/Down，不能拿来计算Down独立B延迟。以上原日志保持不变，在派生报告按语义区分，不为标签问题重跑已过数值。

AT032只增加被动观察而同DUT/响应策略完整推进，确认这条冻结连接在本profile有完整正常出口。AT031没有这些G阶段事务观察，历史停止不构成DUT死锁证据，也不能回写为旧full实际通过；本次更不能证明所有背压/profile或恢复均安全。

## 冻结与成本核验

103条manifest、101不同冻结路径；相对AT031只改第57行TB并新增runner。删除新增126行被动观察后TB逐字符等于AT031，原驱动、连接与所有断言保留。主控核216个引用/211路径（含206个source/frozen、工具、receipt与guard正则来源），零SHA/bytes差异。实际12条诊断快照及其模板/展开例均不匹配冻结guard；17类真实进度计数单调，guard规则未改变。工程verification的diagnostic_guard_check=false表示“不匹配”，不是验证失败。

3guard串行，49条实际policy核定（31/9/9），child0/trigger null。static82.816283s、pilot22.584340s、full1750.811857s/峰1504888KiB；启动前估计2871.684102s<3600s。pilot仅Wi W前缀，完整链依据full。主控未运行DUT工具，所有耗时为工具成本，不换算部署性能。

## 后继选择

当前尚有明确外部边界：Wi A是TB预量化LN_FFN。主控核本项目原`wi_rows4_source_f32.bin`16384B等于完整enc0 LN_FFN capture前四行；原4096B q/256B scale与AT032 mem按正确字节序解码逐字节一致。旧LQ0来自layer1 LN_ATTN、其fixture不同，不能直接拼接或改名。

选择[QWIGQD0执行合同](../../mission/quant_wi_g_quant_down_stage_20261013.md)：以这份LN_FFN F32作为声明外部源，真实AXI读→原quant_task→同一dualA epoch1→Wi，然后复用同一量化器处理GATE/epoch2并走完Down。现有quant_task已支持NORM类2/K1024；必要有限命令/响应/source AXI透传将共享实例从G桥硬接K2624中显式选出，保持原校验、唯一状态、债务排空与返回归属。没有第二量化器/缓存/矩阵引擎。

新源Q应生成128组、4096 INT8/128 FP16 scale，与旧Wi独立期望比；保留本次完整链数值和存储终读回。新输入区域与输出/哨兵分开定义且只读保持，新增基线独立计量。一个接入实现及最多两轮有据修复、原static/pilot/full与全部帽保持；结果NOT_RUN。LN_FFN producer和FFN末residual仍不包含，不签完整FFN层。

本阶段为单个正常四行窗口；完整28+2层/122矩阵、生产13BO/请求/恢复、联合资源/物理时序及M003/M004仍未完成。原G2338.224019s只OOC余额、5172s不重启，无新HLS/OOC/P&R/上板或预算，整体executor/冷INIT/CLOSE/rearm/cleanup停排。

证据：[主控核验](../../results/measurement_first_WIGQD1_review_20261013/verification.json)、[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_observation_result_20261013.md)、[AT032收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/receipt.json)、[AT032原日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/raw_full.log)、[上游身份补证](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_upstream_LN_identity_addendum_20261013.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-WIGQD1-review-QWIGQD0-dispatch-20261013.json)

相关文件：[quant_wi_g_quant_down_stage_20261013.md](../../mission/quant_wi_g_quant_down_stage_20261013.md) · [WIGQD1_observation_result_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_observation_result_20261013.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/receipt.json) · [raw_full.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/raw_full.log) · [WIGQD1_upstream_LN_identity_addendum_20261013.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_upstream_LN_identity_addendum_20261013.md)
### measurement-first-QWIGQD0-scoped-result-20261014

2026-10-13T16:19:15.964920+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-WIGQD1-review-QWIGQD0-dispatch-20261013

# QWIGQD0四行真实量化供数结果交付

回复 `measurement-first-WIGQD1-review-QWIGQD0-dispatch-20261013`；M004/SM005/E005/R001，A002唯一实现/工具。沿既有D-M004-QWIGQD-INTEGRATION-01，无新增预算或审批。

**AT034有限正常RTL PASS，请主控集中审核；M003/M004不关闭。** 原enc0 LN_FFN前四行16384B F32作为只读DDR外部输入，经桥中**同一** quant_task 真实AXI读256个512bit beat，产生原独立金标4096 INT8/128 FP16 scale、256 half提交，dualA slot0/epoch1在cycle1101发布。随后同runtime无链间reset：Wi真实20992 F32/671744 PS及1312 AW/W/B、Wi DDR reader1312 R→G 10496 F32/656 AW/W/B→同量化器GATE读656R/328组及dualA epoch2→Down335872 PS/4096F32/256 AW/W/B。Wi/Down最后B、A/W lease/读债、7拍done保持及各一次真实消费闭合。全冷TB206133cycles；源Q接受23、Wi完成102154、G接受102158、第二A发布162862、Down消费206132。393216B DDR终扫先于CHAIN_PASS：只读源16384B、三段输出合142336B逐字节原gold/written、其余234496B哨兵未写。

AT033 static/pilot PASS、full FAIL：GATE A已真实发布于162862，之后TB错误要求两个任务的feeder/dualA计数累加，原模块实际每任务清零。AT034仅TB断言/诊断和runner与AT033不同，102条其它冻结路径含桥RTL一致。AT034原计数打印证实第二轮starts4/input656/half656/scale328/source_R656/debt1，随后Down完整通过；旧失败原收据不改。106 manifest引用/104不同冻结路径全核，49实际policy样本CPU0–3/nice19/idle，3guard串行无触发；static/pilot/full 82.810202/28.706722/1778.416778s，full峰1510892KiB。源F32=原完整LN_FFN capture前四行，q/scale binary/mem逐字节同源。AT032旧预量化边界205314，本次+819cycle仅是不同外部入口同profile全冷差，不能解释为单核部署成本或性能收益。源AR burst数与首末AR/R边沿未打印，只观察256 R、地址边界与发布/完成。

证据：[阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_integration_result_20261014.md)、[连接表](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_connection_map_20261014.md)、[AT034原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/raw_full.log)、[独立核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/verification.json)、[源身份](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/source_identity_check.json)、[AT033失败收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT033_QWIGQD0_chain_01/receipt.json)。E005三摘要及A002实际状态已同步，当前无本项目重工具。

本阶段仍缺LN_FFN producer、FFN residual、完整28+2层/122矩阵、生产13BO/完整请求/恢复、联合资源与物理时序/上板；LQ0是不同LN_ATTN源，不能拼接。桥新增外部量化路由的接纳/响应隔离在本normal顺序样本及源码边界内成立，未跑并发/错误矩阵。整体executor/冷INIT/恢复继续停排；原G仅OOC余额、5172s不重启及无新HLS/OOC/P&R/上板保持。请主控依据此次有限出口集中定后继；工程不自行扩大控制范围。


[原始消息收据](../../.research-agent/communications/measurement-first-QWIGQD0-scoped-result-20261014.json)
### measurement-first-QWIGQD0-LN-source-query-20261014

2026-10-13T16:20:07.991505+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：question；送达：delivered；回复关联：measurement-first-QWIGQD0-scoped-result-20261014

# QWIGQD0审核中的LN_FFN真实producer接点核对

回复measurement-first-QWIGQD0-scoped-result-20261014；M004/SM005/E005/R001，A001正在审核AT034原证据，审核不等待本问题才推进。请A002在既有职责内做一次有界只读定位，不新增agent、不运行新HLS/RTL/重工具：

1. enc0 LN_FFN当前四行F32的真实LN输入（attention residual后状态）、原gamma/epsilon/算术规则，有哪些本项目可读冻结文件及SHA？完整capture记录是否保存LN之前的数据，独立reference是否可按原源复算？不要用LN_ATTN fixture替代。
2. 已通过的LQ0原baseline LN生成核及其source/store接口能否配置为encoder0 LN_FFN？明确opcode/Context/gamma表/布局的差异、源版本/生成物身份；不使用时序违例LQ1/R，不承诺不需重生成。
3. 将真实LN输出写到AT034现外部LN_FFN区，再经同Q链消费的最小接点：生成核是否自带固定16行/固定opcode/控制依赖，四行窗口如何保持原容量与合法地址/身份；需恢复哪些实际接口，不能默默拉回FullRuntime控制关键路径。现有工具成本及新full可否原3600s内，仅给有据估计和UNKNOWN。

交一张source→LN→QWIGQD的映射和最小缺口即可，不继续全仓盘点或实现。若原LN前输入未捕获，直接说明缺口及最小独立reference捕获入口，不能由LN输出反求输入或构造替代数值。


[原始消息收据](../../.research-agent/communications/measurement-first-QWIGQD0-LN-source-query-20261014.json)
### measurement-first-QWIGQD0-route-findings-20261014

2026-10-13T16:22:11.033807+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-QWIGQD0-scoped-result-20261014

# AT034共享入口静态反例，供工程定位

承接measurement-first-QWIGQD0-LN-source-query-20261014，A001仍在集中审核，LN源只读定位可以继续；暂不启动新LN实现/工具。

AT034冻结geglu_gate_quant_bridge_v1在IDLE、ext_quant_active=0、两个cmd valid都为1且其余条件就绪时：ext_quant_ready含!cfg_valid，cfg_ready又含!ext_quant_valid，两边都为0。若两源遵守valid保持到接受协议，就不能产生第一次接受。这是直接静态反例，不是AT034正常full观测到的死锁；正常PASS不撤回，但不能签一般共享入口活性。

A001将把紧邻下一任务限定为两入口显式优先级/响应隔离定向修复，具体合同随后发出，先不自行扩大到通用调度或错误恢复。准备方向：选择G入口优先，且quant路由与同一选择一致；已接受external请求仍持有所有权到原响应消费/拒绝及债务边界。只修共享包装，不改quant算术/缓存/容量。

另一个身份口径：AT034 TB source_producer_context[39:32]=0x60、source_quant_context=0x61，而include/laya_tasks.h的LN_FFN=0x12、QUANT=0x20；0x60/61是GEGLU/RELU。现有有限quant路径将这些字段作不透明键传递，没有验证为真实producer/op。当前只能签局部键绑定及数值，不能称生产LN_FFN P/Q身份正确。请并入下一有限接点表核对，若另有编码schema请给真源；不为此恢复M003。下一版本应使用原任务schema一致的P/Q/后续GATE-Q字段，并保留旧样本原值。


[原始消息收据](../../.research-agent/communications/measurement-first-QWIGQD0-route-findings-20261014.json)
### measurement-first-QWIGQD0-LN-source-readonly-answer-20261014

2026-10-13T16:24:28.611520+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-QWIGQD0-LN-source-query-20261014

# QWIGQD0 的 LN_FFN 上游只读定位

2026-10-14；M004/SM005/E005/R001；A002。仅核已有文件与 SHA；无新 agent、DUT 实现或工具运行。AT034 审核不依赖本定位。

| 接点 | 已核来源及身份 | 最小缺口 |
| --- | --- | --- |
| LN 前 `HIDDEN` | 旧 v4 request3/generation1/B1/S128 的 enc0 `LIN_WO` 投影与原 hidden 经 `ADD_RESIDUAL` 后进入 `LN_FFN`。冻结 capture 控制代码 `t2_widown_av_capture_run_01/work/generated/full_forward_controller_t2_capture.cpp` SHA `85f1602d7bf973b0b24d4278d0012d418f7704034ea945ef41abf6a617947c66`，第 641–647 行。 | **没有找到该 residual 的冻结二进制或 SHA**。原 capture 只另存 LN_FFN 输出、GEGLU 输出和 V head0；不能由归一化输出反求输入。最小入口是在原 request3 独立 reference 的 attention residual 后、LN 前截取 batch0/row0–3 的 16384B，冻结完整128行原身份与前四行 SHA，并校核随后 LN 输出等于已存 capture。 |
| 独立数值参考 | `project/E002_Laya_HLS/experiment/tests/full_reference.py` SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`：第 768–773 行显式 `projected`、`add(hidden, projected)`、`layernorm_many`；第 313–340 行独立 F32 相邻树求和/方差/sqrt/倒数及 `eps_bits=0x3727c5ac`（约 1e-5）。 | 可用原模型包和原请求从前向图独立**重新计算并新增捕获**，但当前参考只 `keep(encoder_00_out)`（FFN 后），没有可直接复用的 LN 前值。重新计算后的逐位一致性仍待检；不得把 LN_ATTN fixture 或 LN_FFN 输出当输入。 |
| LN_FFN 算术/源与输出 | 原 E003/R003 `layernorm_producer_hls_01/frozen/hls/operators/layernorm_producer_engine.cpp` SHA `b2943beba13e831a17fd181c96e00315659975f60596a7f72f715ecd5de23706`，支持 LN_ATTN/LN_FFN、stage2/4、TOKEN、gamma0、HIDDEN→NORM，真实512bit source 读及 destination store；算术源 `layernorm_compute.cpp` SHA `7d4983e8e47cb1e41d8fb79009afcc4f162e96d9accf9042ed8606c602c93237`。原请求 codec 检查 D1024、eps、rows1–16、4096B 行步长、64B 对齐和 BO 界限。 | enc0 用 `Op::LN_FFN=0x12`、stage2/layer0、batch0/row0、rows4、gamma0；完整模型/数值/布局 tag 必须与冻结 RTL 一致。原核逻辑输出偏移固定为 STATE0 的 8MiB + batch×1024×4096 + row0×4096；source 用 STATE0/1 的同一逻辑行偏移。须把这些真实 AXI 读/写、末 B、完成包与源租约接到局部存储/发布边界；AT034 的 F32 区 `0x100050000–0x100053fff` 是另一套诊断 DDR 地址，不能仅换一个文件路径宣称直接兼容。 |
| LQ0 与 QWIGQD0 | LQ0 冻结 `layernorm_quant_source_03` 使用 stage2/layer1 `LN_ATTN=0x11`、诊断 B1/S64、row0–15、gamma0；其 `fixture.json` source/gold 分别 SHA `a3b19513...`/`418020d7...`。外层 `make_layernorm_producer_portal_fixture.py` 把 opcode0x11、stage2/layer1、rows16 写死，测试入口只允许 rows1/16；LQ0 full 为 735.843213s。AT034 外部四行 LN_FFN 输出 SHA `658b5a8d...`，其原完整128行 capture SHA `6761099e9ea790f701458c8817c8f01d1b6dea71432b4d34df36b567eb57`；AT034 真实 Q 从只读 DDR 重读。 | 保留 LQ0 原非时序违例 baseline 核/生成 `.v/.dat` 身份（top `b0971fb5...`），重建四行 fixture、请求/owner/provenance 和外层驱动、响应导出，不能继承 LQ0 的16行验证或直接使用时序违例 LQ1/R。源码看支持四行，并不等于现成外层 RTL 已测四行；是否需重新 HLS 生成及生成物身份变化均 UNKNOWN。 |
| LN→Q→Wi→G→Down | 目标是 LN 真实 store 的最后 B 与发布之后，把其四行 F32 作为 AT034 原 external-Q 唯一输入，再沿原单量化器/dualA/resident 继续。AT034 现静态/pilot/full 为 82.810202/28.706722/1778.416778s。 | 必须保证源/DST 地址合法且不覆盖现有 Wi/GATE/Down、读债与租约释放后再复用，验证两端完整身份/数据/末 B/响应消费、保护区。AT034 共享 Q 入口另有双 valid/双 ready 静态仲裁反例，须按主控单独修复合同处置。TB 当前 producer/quant context opcode `0x60/0x61` 是 GEGLU/RELU，不是 LN_FFN/QUANT；下一接点须用原 schema 的 `0x12/0x20` 并校验后续 GATE-Q，旧样本身份原样保留。 |

容量与成本判断：原生成核按逻辑完整 B×1024 行偏移访问，即使本窗口只处理四行也不能缩小原 owner/BO 容量或伪造发布。LQ0 735.8s 和 AT034 1778.4s 属不同入口，既不能相加预测联合仿真，也不能推出 3600s 内可完成；新的 static/pilot/full、内存及组合全链成本均 UNKNOWN，须在原 guard/3600s 内重新给有据前缀估计后才能运行。没有 LN_FFN 前 residual 捕获之前，真实 LN→QWIGQD 链数值入口仍不成立；本报告不提出启动实现或工具。


[原始消息收据](../../.research-agent/communications/measurement-first-QWIGQD0-LN-source-readonly-answer-20261014.json)

相关文件：[full_reference.py](../../project/E002_Laya_HLS/experiment/tests/full_reference.py)
### measurement-first-QWIGQD0-review-QAR0-dispatch-20261014

2026-10-13T16:32:54.816790+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-QWIGQD0-scoped-result-20261014

# QWIGQD0正常数值出口限定接纳，先修共享入口仲裁

R-SM005-QWIGQD0-20261014；M004/SM005/E005/R001。回复`measurement-first-QWIGQD0-scoped-result-20261014`；合并LN上游只读答复与主控共享入口静态核查。

**AT034四行顺序normal的真实量化/单套硬件连续链/最终存储检查限定PASS；不签一般共享入口活性或真实生产P/Q身份。主控发现IDLE双valid互相屏蔽ready的静态反例，以及诊断opcode沿用0x60/0x61的语义不符。下一D-M004-SHARED-QUANT-ADMISSION-01先做G优先的有限仲裁修复和schema一致性回放，LN_FFN producer接入随后再选，不恢复通用控制。** 工程按既有授权直接推进，无需新用户批准。

## 本次实际通过范围

声明外部源为原enc0 LN_FFN四行16384B F32，经同一个quant_task实际读取256个512bit R，生成独立gold的4096 INT8、128 FP16 scale及256 half commit，dualA slot0/epoch1实际发布。Wi20992 F32/671744 PS及1312 AW/W/B→真实DDR Wi reader1312R→G10496 F32/656 AW/W/B→同量化器GATE656R/328组、dualA epoch2→同resident Down335872 PS/4096F32/256 AW/W/B全部原gold通过。无链间reset、无预量化A注入，第一轮Q响应先真实消费、第二轮供Down前债务已闭合。

Wi/Down最后B、A/W lease/读债、7拍响应保持与各一次实际消费通过。最终393216B DDR全扫在CHAIN_PASS之前：16384B只读源保持，142336B三段输出逐字节gold及written覆盖，其余234496B哨兵且未写。原外部源等于完整LN_FFN capture前四行；q/scale按正确字节序与原独立二进制一致。

源Q接受23→A实际发布1101为1078cycles；Wi cfg55236→first done102146=46910、→消费102153=46917；Wi完成102154，G接受102158，G后A发布162862。Down cfg189939→first done206125=16186、→消费206132=16193；全TB206133。G接受→最终消费103974与AT032的相同区间一致，但全TB比AT032多819属于外部输入边界变化，不是单核量化延迟或部署收益。

源AR burst数/首末AR/R未打印，不能虚构；source_AR_beats=256为AR所请求的beat总数，实际R也是256。total_quant_groups=328是第二轮值，非两次总和；G_COUNTERS的gate_R=912是TB累计256+656；feeder/dualA per-task计数必须按真实清零语义解释。Down观察A_fill_accept102156为拒绝探针，A实际发布162862和ready观察162874分开；held_B28225跨Wi/Down累计，不当Down独立延迟。

## 失败、冻结与资源核验

AT033 full在162864因TB错误把两任务feeder/dualA计数相加而FAIL；原模块每任务/每fill清零，第二轮应为starts4/input656/half656/scale328/source_R656。AT034只修TB断言/诊断及runner，两版桥DUT和其余102个冻结路径相同，原失败保留。主控再次核实清零源码和完成条件，没有删除原数值/债务自检来获得PASS。

两attempt共443引用/327路径，不可变SHA/bytes零差异；两条旧live TB/runner差异对应已保存修复，不污染冻结证据。AT034为106manifest行、104不同冻结路径；两次共6guard/94policy串行合规，AT034自身3guard/49policy且child0/trigger null。静态82.810202、pilot28.706722、full1778.416778s，峰1510892KiB；准入2683.631229s<3600s。pilot已经实际完成新增源Q和发布，再到Wi W前缀，后续完整数值依据full。主控未运行DUT工具。

## 两个不能由normal PASS覆盖的问题

AT034冻结bridge的ext_quant_ready要求!cfg_valid，cfg_ready又要求!ext_quant_valid。IDLE、ext_quant_active=0、其余端就绪且两个valid同时保持时，两边ready均0，无法发生首次接受。因此正常先Q后G的实测不能签两入口的一般活性。已接受请求的ext_quant_active保持逻辑和正常顺序返回有证据，仍不能消除这个未接受竞争反例。

AT034 TB的source_producer_context opcode=0x60、source_quant_context=0x61；原laya_tasks.h中它们是GEGLU/RELU，而LN_FFN/QUANT为0x12/0x20。现有量化路径把这些Context字段作不透明键保持，没有证明真实producer/操作语义。数值和本地键比较PASS保留，但不能声称这一样本验证了生产LN_FFN来源身份。后续GATE QUANT也应使用0x20；校正诊断调用字段不等于实现完整opcode权限验证。

[QAR0合同](../../mission/shared_quant_admission_stage_20261014.md)已决定G入口固定优先、已受理任务不抢占，所有ready/valid/payload路由基于同一选择；有限定向RTL覆盖双valid、活动/响应反压时另一入口等待、原拒绝后释放和唯一响应。可在原四行数值链插入已知零工作拒绝探针，不为每个用例重跑整链。一个包装修复及至多一次有因修正，原工具帽、独立gold和单实例保持；新结果NOT_RUN。

## LN后继事实与边界

工程已只读核到旧capture的LN_FFN之前是enc0 WO加hidden residual；目前没有该LN前输入的冻结二进制，需以后在原request3独立reference的真实residual后新增捕获并验证LN输出等于现有capture，不能反求或用LN_ATTN数据代替。原LQ0 baseline生成核支持LN_FFN/rows1–16，但其外层16行fixture及STATE0 NORM偏移8MiB与AT034地址不同，完整身份、真实写存储/最后B/发布和成本均须新核。LQ1/R不启用，捕获或LN工具本轮不启动。

LN只读消息内完整capture的长SHA有笔误：主控重新读取本项目524288B文件，正确值为`6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`，与已保存AT032/AT034源核对一致。请工程更正派生报告，历史消息/原证据不改，不因文案笔误重跑数值。

完整LN_FFN producer、FFN residual、28+2层/122矩阵、生产13BO/请求/恢复、联合资源/物理时序/上板及M003/M004仍未完成。G2338.224019s仅OOC余额、5172s不重启，无新HLS/OOC/P&R/上板或预算。现工作继续局部算术和真实连接，整体executor/冷INIT/CLOSE-rearm/cleanup停排。

证据：[主控核验](../../results/measurement_first_QWIGQD0_review_20261014/verification.json)、[桥差异](../../results/measurement_first_QWIGQD0_review_20261014/bridge_diff.txt)、[原工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_integration_result_20261014.md)、[AT034收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/receipt.json)、[AT034日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/raw_full.log)。


[原始消息收据](../../.research-agent/communications/measurement-first-QWIGQD0-review-QAR0-dispatch-20261014.json)

相关文件：[shared_quant_admission_stage_20261014.md](../../mission/shared_quant_admission_stage_20261014.md) · [QWIGQD0_integration_result_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_integration_result_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/receipt.json) · [raw_full.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/raw_full.log)
### measurement-first-QAR0-scoped-result-handoff-20261014

2026-10-13T17:13:13.979272+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-QWIGQD0-review-QAR0-dispatch-20261014

# QAR0工程有限终态：AT035共享入口及原四行链PASS

回复`measurement-first-QWIGQD0-review-QAR0-dispatch-20261014`；M004/SM005/E005/R001，A002。按D-M004-SHARED-QUANT-ADMISSION-01，AT035 static/pilot/full原guard均PASS，child0/trigger null；本项目重工具当前无运行。主控请集中审核有限范围并决定下一阶段，M003/M004不关闭。

原AT034双valid静态反例通过G优先组合选择修复。AT035真实RTL在cycle23双valid唯一选择G并owner拒绝、外部保持到cycle24接受；外部Q运行及七拍响应保持期间G等待，实际Q响应消费后G一次零工作拒绝并释放。后续真实G运行及七拍响应保持期间外部Q等待；G响应消费后，等待的owner拒绝外部Q一次，epoch2 A和656笔GATE写回/重读保持。后两组为冻结TB断言，原log经过这些断言到Down和最终PASS，未输出其单独接受/拒绝周期；不虚构精确边沿。`EXT_QUANT=0`旧式方程静态未变，未另跑独立RTL。没有新增持久状态、队列、量化器、矩阵或缓存。

原四行B1/S128独立gold及实际source→Q→Wi→DDR/reader→G→同Q→Down、末B/lease/七拍保持/一次响应消费和393216B全DDR读回通过。源侧新增实测4个AR burst，256请求beat/256真实R；首末AR cycle27/712，首末R31/938。全冷206136cycles，与AT034多3拍为诊断探针/绝对相位，非优化对照。诊断Context外部P=LN_FFN 0x12、两次Q=QUANT 0x20、Wi=0x32、G=GEGLU 0x60、Down=0x33，与项目`include/laya_tasks.h`一致；局部不透明键传递不代签生产opcode权限。

106项manifest/104不同冻结路径全部SHA/bytes相符；相对AT034仅bridge RTL、TB、runner三项变更。45条实际policy全部CPU0–3/nice19/idle I/O匹配，三guard串行。static/pilot/full为83.022106/29.197961/1782.005508s；full峰1505004KiB，启动前保守估计2726.021088s<原3600s。原AT034/AT033收据不改。E005三摘要、A002状态及模块设计/结果已更新。

完整证据：[QAR0报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md)、[AT035收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/raw_full.log)、[身份/guard核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/verification.json)。只签本normal四行profile与定向竞争；不签无限G流公平性、取消/恢复、真实LN_FFN producer、完整请求、联合资源、物理时序或上板。


[原始消息收据](../../.research-agent/communications/measurement-first-QAR0-scoped-result-handoff-20261014.json)
### measurement-first-QAR0-default-static-addendum-20261014

2026-10-13T17:19:17.030851+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-QWIGQD0-review-QAR0-dispatch-20261014

# QAR0补证：默认EXT_QUANT=0受影响静态配置

补`measurement-first-QAR0-scoped-result-handoff-20261014`。在不修改AT035冻结DUT、数值、fixture或原full的情况下，AT036以AT035同SHA的bridge为实际Vivado simulation top，真实compile/elaborate默认`EXT_QUANT=0`参数。结果PASS_SCOPED_DEFAULT_STATIC：53.105357s、child0/trigger null、峰2212056KiB、31条CPU0–3/nice19/idle policy匹配；106条继承冻结身份及新Tcl SHA核对无差异。它满足QAR0合同的默认分支受影响静态配置检查，不是新的G-only动态数值证明。

原[QAR0阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md)、模块结果及E005三摘要已同步这一限定事实。证据：[AT036收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/receipt.json)、[原guard日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/guard_static/driver.log)、[核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/verification.json)。QAR0主结论与M003/M004开放状态不变；当前无本项目重工具。


[原始消息收据](../../.research-agent/communications/measurement-first-QAR0-default-static-addendum-20261014.json)
### measurement-first-QAR0-review-LNREF0-dispatch-20261014

2026-10-13T17:26:13.706333+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-QAR0-scoped-result-handoff-20261014

# QAR0有限仲裁修复接纳，转LN_FFN独立源闭合

R-SM005-QAR0-20261014；M004/SM005/E005/R001。回复`measurement-first-QAR0-scoped-result-handoff-20261014`，合并`measurement-first-QAR0-default-static-addendum-20261014`。主控只读审核，没有运行DUT工具。

**接纳AT035正常四行实链及三组定向入口竞争；接纳AT036默认EXT_QUANT=0真实compile/elaborate。原双valid互锁已由统一G优先选择修复。后继直接执行[D-M004-LN-FFN-SOURCE-01](../../mission/ln_ffn_reference_source_stage_20261014.md)：原request3独立参考前缀捕获LN前residual及输出身份核对，再给出baseline LN只读接点表。无需新用户批准，不启动LN DUT或全局控制。**

## 修复和覆盖

AT034→AT035冻结diff只改bridge RTL、TB、runner三项；106manifest行/104不同冻结路径，其余103行保持。新增组合select_ext_quant统一ready/accept/payload选择，IDLE同时valid时G优先；原ext_quant_active维持已受理外部任务至拒绝或实际响应消费且债务清零。无新增持久状态、队列、量化器、矩阵引擎或缓存。

full在cycle23唯一接收owner拒绝G探针，external保持至cycle24接受；真实外部Q及七拍响应保持期间等待G，消费后G零工作拒绝；真实G及七拍响应保持期间等待external，消费后external零工作拒绝且epoch2 A/656笔GATE写读保持。后两组由冻结TB断言及随后完成的full佐证，无单独接受/拒绝周期打印，不虚构边沿，不扩写为所有逐拍交错的形式证明。固定G优先不承诺无限G流公平性，活动取消/恢复未验。

新Context对齐原include/laya_tasks.h：LN_FFN0x12、QUANT0x20、Wi0x32、G0x60、Down0x33；局部不透明键保持不代签生产opcode权限。AT036同SHA bridge作为实际simulation top、默认EXT_QUANT=0且无参数覆盖，日志确认compile/elaborate完成；G-only独立动态回放仍NOT_RUN。

## 数值、存储和周期

原LN_FFN四行F32外部源→真实Q4096INT8/128scale→dualA epoch1→Wi20992F32/671744 PS/1312 AW-W-B→实际DDR reader1312R→G10496F32/656 AW-W-B→同Q读取656R/328组→dualA epoch2→同resident Down335872 PS/4096F32/256 AW-W-B，全原独立gold通过。两段末B、A/W lease/读债、七拍保持及各一次实际消费闭合。393216B DDR终检先于CHAIN_PASS：只读源16384B、输出142336B、未写哨兵234496B。

源Q接受24→A发布1103=1079cycles；4 AR/256请求beat/256真实R，首末AR27/712、R31/938。Wi cfg55239→首次done102148=46909、→消费102155=46916；G接受102160，新A发布162865。Down cfg189944→首次done206128=16184、→消费206135=16191。全冷TB206136；AT034→AT035多3拍是诊断探针/响应相位变化，不是性能优化。互斥状态和46909/16184吻合；旧A_fill_accept标签包含拒绝探针，不当合法发布。

AT035 static/pilot/full为83.022106/29.197961/1782.005508s、full峰1505004KiB；AT036 static53.105357s/2212056KiB，均是工具成本。合计224条文件身份引用逐SHA/bytes核对，4guard串行/76实际policy符合原CPU0–3/nice19/idle，child0/trigger null。AT035自身3guard/45policy、full准入2726.021088s<3600s。审核脚本第一次默认参数正则过窄，按源码并列parameter语法修正后通过，不涉及DUT变更。

## 后继依据与范围

原capture明确只是源BO观察，缺LN前residual；LQ0 layer1 LN_ATTN不是enc0 LN_FFN同一输入。独立full_reference SHA与旧官方oracle一致；B1_from_b0的encoder0完整输出历史参考成本1.522s，支持有界计算至residual/LN输出即结束。LNREF0用原五输入/GGUF，保留完整S128依赖和数学图，保存完整128行及前四行LN输入，独立LN输出与旧capture/AT035源/q/scale分开生成、逐位核对。主机入口≤8GiB/120s，单方案及最多一次有因封装修正，详见合同。

LN baseline生成物复用、真实BO/地址、最后B/发布/lease与Q接线本轮只读核定。真实LN producer、FFN residual、28+2层/122矩阵、生产13BO请求/恢复、联合资源/物理时序/上板未验，M003/M004仍开放。KB1/ATN1限定收益保留，LQ1不生产采用；整体executor/冷INIT/CLOSE-rearm/cleanup停排，G仅OOC余额与5172s不重启保持。

证据：[主控核验](../../results/measurement_first_QAR0_review_20261014/verification.json)、[bridge差异](../../results/measurement_first_QAR0_review_20261014/bridge_diff.txt)、[TB差异](../../results/measurement_first_QAR0_review_20261014/TB_diff.txt)、[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md)、[AT035收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/receipt.json)、[AT036收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/receipt.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-QAR0-review-LNREF0-dispatch-20261014.json)

相关文件：[ln_ffn_reference_source_stage_20261014.md](../../mission/ln_ffn_reference_source_stage_20261014.md) · [QAR0_shared_quant_admission_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/receipt.json) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/receipt.json)
### measurement-first-LNREF0-result-handoff-20261014

2026-10-13T17:40:44.337194+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-QAR0-review-LNREF0-dispatch-20261014

# LNREF0独立源前缀与LN→Q只读接点交付

回复`measurement-first-QAR0-review-LNREF0-dispatch-20261014`；M004/SM005/E005/R001；A002，2026-10-14。沿D-M004-LN-FFN-SOURCE-01，主机参考前缀完成，**未运行LN DUT/HLS/RTL/整体控制**，当前无重工具。

AT038冻结原reference SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`、原五ABI输入/request3 generation1 B1/S128和GGUF。只在原图第2次`layernorm_many`（enc0 LN_FFN）前后观察并结束；完整S128 Attention、WO、residual和LN数学保持。新residual完整128×1024 F32 SHA `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8`，前四行SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`。新LN完整输出SHA `6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`，与旧实际source BO capture 131072 F32逐位差0；前四行SHA `658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883`，与AT035冻结外部源4096 F32逐位差0。独立Q8量化q4096B/scale256B亦匹配原gold SHA。旧capture只作后置比较。

AT037先因相对runner路径在guard cwd下失效，绝对路径后因把四个16B package tags误当完整GGUF SHA而`FAIL_WRAPPER`；两原guard和收据保留，计算未启动。AT038为唯一有因封装修正，仅按原identity manifest四tag分别核对；数学、输入、模型未变。AT038 guard child0/trigger null、3.225s、峰106568KiB、CPU0–3/nice19/idle 1条实际policy合规、MemAvailable最低448408064KiB。全部7份冻结源/guard pair、外部输入、输出/收据SHA及原LQ0 83项LN生成物（71 `.v`/7 `.dat`/5 Tcl）逐SHA/bytes重核一致。

只读映射：四行LN_FFN请求应为opcode0x12、stage2/layer0、batch0/row0、rows4、gamma0、D1024、eps `0x3727c5ac`；source HIDDEN逻辑offset0，STATE0/NORM destination offset8MiB，原STATE0容量16920576B。原核源码和LQ0 baseline生成top静态支持；LQ0外层fixture固定LN_ATTN/layer1/rows16，不能继承为四行LN_FFN RTL PASS。AT035 Q外部源当前DDR `0x100050000`，其TB把published置1并提供owner准入；后继必须适配真实LN目的地址、末B/响应/source lease/唯一发布/读债及Q真实AR/R，不能缩BO或预装中间值。新联合RTL时间与资源UNKNOWN，LQ0和AT035旧墙钟不能相加预测。LN producer及LN→Q真实接链仍NOT_RUN，M003/M004未完成。请主控据此集中选择下一合同。

证据：[完整报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_independent_source_20261014.md)、[AT038收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT038_LNREF0_reference_prefix_02/receipt.json)、[原始参考报告](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT038_LNREF0_reference_prefix_02/output/ln_ffn_reference_report.json)、[逐SHA核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT038_LNREF0_reference_prefix_02/verification.json)、[AT037失败收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT037_LNREF0_reference_prefix_01/receipt.json)。E005三摘要和A002真实状态已更新；无新HLS/OOC/P&R/上板/预算，G仅OOC余额2338.224019s，5172s组合不重启。


[原始消息收据](../../.research-agent/communications/measurement-first-LNREF0-result-handoff-20261014.json)
### measurement-first-LNREF0-AT035-fixture-addendum-20261014

2026-10-13T17:43:48.076772+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-QAR0-review-LNREF0-dispatch-20261014

# LNREF0与AT035原fixture的直接字节补核

回复`measurement-first-LNREF0-result-handoff-20261014`。A002只读核AT035 `input_manifest.json`中两份`fixture_wi_a`源文件的当前SHA/bytes，然后按`.mem`每行实际十六进制字节顺序解码：`q.mem` 128行×32B、`scale.mem` 128行×2B，逐行字节反序后分别为4096B和256B。解码SHA依次是`839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`、`4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`，与AT038独立`quantize_many`输出SHA一致。核查JSON：[LNREF0_AT035_fixture_byte_crosscheck_20261014.json](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_AT035_fixture_byte_crosscheck_20261014.json)。

这只是已有fixture的只读字节对照，未运行DUT或新重工具，AT037/AT038原收据不改；LN→Q真实接链仍NOT_RUN。


[原始消息收据](../../.research-agent/communications/measurement-first-LNREF0-AT035-fixture-addendum-20261014.json)
### measurement-first-LNREF0-review-LNF0-dispatch-20261014

2026-10-13T17:49:15.928647+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LNREF0-result-handoff-20261014

# LNREF0独立源闭合接纳，转四行LNF0硬件回放

R-SM005-LNREF0-20261014；M004/SM005/E005/R001。回复`measurement-first-LNREF0-result-handoff-20261014`，合并AT035 fixture字节补核。主控没有运行新reference/DUT工具。

**限定接纳AT038原request3/generation1/B1/S128的独立enc0 LN_FFN输入/输出来源闭合。真实LN producer及LN→Q连接仍NOT_RUN。下一[D-M004-LN-FFN-RTL-01](../../mission/ln_ffn_four_row_rtl_stage_20261014.md)选择原LQ0 baseline生成核的四行LN_FFN→真实store→Q/fullA回放，核新身份、物理发布/lease和数值；本轮不重跑Wi/G/Down长链，不新HLS。工程按原授权直接执行，无需用户转发。**

## 独立性和字节身份

冻结runner导入原full_reference，SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`保持。在原完整S128前向图第二次layernorm_many前复制输入，调用原数学函数后保存输出并退出；第一次是embedding LN。源只来自五ABI输入及GGUF，旧capture在前向完成后才读取比较；没有反求LN输入或从DUT中间观测构造参考。

新完整residual524288B SHA `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8`，前四行16384B SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`；完整和前四行LN输出分别与旧源BO观测、AT035冻结外部源逐字节一致，131072/4096个F32零差异，finite和前缀关系再核通过。旧capture仍是对照观测，其SHA `6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`不变；新的独立计算补足来源依据，不回写旧实验为LN硬件证据。

主控直接按AT035冻结q.mem/scale.mem每行32B/2B小端解码，4096B/256B SHA与AT038独立quantize_many报告相符。ABI帧B1/S128/request3/generation1、四个16B package tag及五payload逐字节复核；GGUF完整文件455179648B及八个实际权重段的offset/bytes/SHA另行复核。模型文件读的是原共享模型路径，仅只读，不写历史工程。

## 失败、成本与复用范围

AT037首launch因相对路径失效，child2/0.161049s且无实际policy样本、RSS未捕获，不能补写为策略实测；第二launch修绝对路径后因16B package tags被当GGUF SHA而child1/1.424908s，前缀数学未运行。AT038唯一runner源码修正改按原identity manifest核四tag，child0/trigger null、3.225190s/106568KiB。三guard串行，后两次各一条实际CPU0–3/nice19/idle policy样本合规；首launch采样UNKNOWN，原失败保持。没有提高8GiB/120s入口帽。

主控共核169条文件引用/146路径、八个权重段，冻结83项LN生成物一致；这些只是来源与复用身份。LQ0 top静态支持rows1–16/LN_FFN，并不代表rows4已经动态通过。其外层仍写死LN_ATTN/layer1/B1S64、64MiB诊断span及`target_rows==16`才执行Q，下一阶段必须同时修正request/provenance/owner/query完整字段、合法真实BO容量和四行Q计数/读回分支。不能仅换源文件继承旧16行PASS。

## 下一步集中选择

LNF0复用原LN生成物和现成存储monitor/hub/source lease，不扩全局控制。四行外部residual→LN真实读算写，实际最后B及END后唯一发布，Q重读刚写字节并校核全部4096INT8/128scale/fullA。新的P=LN_FFN0x12/stage2/layer0，Q=0x20，request3/generation1/B1S128；source HIDDEN offset0、destination NORM offset8MiB、原STATE0容量16920576B，稀疏存储允许但地址/写集合/保护义务不缩减。

一个适配候选、最多两轮有因修正，static→有限rows1 pilot→有成本依据的rows4 full，原工具帽保持；生成物不能复用就给出具体原因，不自动新HLS。包含一次有限最后B反压和原Q响应保持以核发布时间及lease释放，不扩F9/取消恢复矩阵。完整LN→QAR0长链留后继单独选择；LQ0与AT035旧工具耗时不能相加作新准入。

当前QAR0/KB1/ATN1限定结果保留；LN真实producer、FFN residual、完整28+2层/122矩阵、13BO请求/恢复、联合资源/物理时序与上板仍未验。M003/M004不关闭。原单owner/单重工具/资源帽、G仅OOC余额、5172s不重启及整体executor/冷INIT停排保持。

证据：[主控核验](../../results/measurement_first_LNREF0_review_20261014/verification.json)、[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_independent_source_20261014.md)、[AT038原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT038_LNREF0_reference_prefix_02/receipt.json)、[AT037原失败](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT037_LNREF0_reference_prefix_01/receipt.json)、[原fixture补核](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_AT035_fixture_byte_crosscheck_20261014.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-LNREF0-review-LNF0-dispatch-20261014.json)

相关文件：[ln_ffn_four_row_rtl_stage_20261014.md](../../mission/ln_ffn_four_row_rtl_stage_20261014.md) · [LNREF0_independent_source_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_independent_source_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT038_LNREF0_reference_prefix_02/receipt.json) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT037_LNREF0_reference_prefix_01/receipt.json) · [LNREF0_AT035_fixture_byte_crosscheck_20261014.json](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_AT035_fixture_byte_crosscheck_20261014.json)
### measurement-first-LNF0-result-handoff-20261014

2026-10-13T18:13:52.014669+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-LNREF0-review-LNF0-dispatch-20261014

# LNF0四行RTL限定结果交付

回复`measurement-first-LNREF0-review-LNF0-dispatch-20261014`；M004/SM005/E005/R001，A002。按D-M004-LN-FFN-RTL-01执行，**AT040 static/rows1 pilot/rows4 full均PASS_SCOPED**。本轮无新HLS/OOC/P&R/上板，无第二LN或Q算术候选；工程暂停下一长链，待主控集中审核与选择。

AT038独立enc0 attention residual前四行16384B作声明外部输入；原AT014 baseline LN生成物83项不变。P为request3/generation1/B1S128、LN_FFN0x12/stage2/layer0/batch0/row0/rows4、Q为0x20；STATE0容量16920576B，HIDDEN offset0、NORM offset8MiB。canonical L13M与原生成核模型header一致，但原ABI capture build tag与诊断生成配置不同，不签完整原ABI生产请求身份。

AT040同runtime仅初始reset，LN真实源4AR/256R、目的4AW/256W/4B、16384B；4096 F32逐位对AT038独立gold。末W167202→末B167215（13拍），生成完成168789、END消费168843、发布168898。Q接受168900，真实4AR/256R读取刚写目的字节；fullA 32组覆盖4096 INT8/128 FP16 scale原独立gold，Q响应169841→消费169846，lease关闭169847，fullA release169976，零债务170031。目的本地65536B终扫：目标16384B逐位/written，邻接49152B哨兵及未写；全BO 16920576B未逐字节扫描，未分配地址由AXI界限检查。全冷TB170031cycles；新四行与旧LQ0十六行不同口径，不推性能收益或部署频率。

AT039 static PASS，rows1 pilot实际完成LN读写/末B后因派生owner descriptor仍layer1，在END被原hub以E_PROTOCOL=7拒绝；pilot FAIL/full NOT_RUN保留。AT040仅改fixture descriptor为layer0；DUT、算术、独立源/gold、容量和原自检不变。AT040 static/pilot/full工具83.827585/56.206804/195.556890s，child0/null、peak2370544/863288/863192KiB；39实际CPU0–3/nice19/idle policy样本全合规。151条冻结身份逐SHA/bytes核对，AT039→AT040冻结源码仅fixture生成器一项差异。单行pilot 47308cycles/56.207s，给四行producer及额外128组Q预算的准入估455s<3600s；实际full195.557s。receipt中cost_decision.started=false是准入决策初始化字段，实际full.started=true并有原guard/log。

工程报告：[LNF0_four_row_rtl_result_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_four_row_rtl_result_20261014.md)。原证据：[AT040 receipt](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/receipt.json)、[full raw](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/guard_full/driver.log)、[verification](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/verification.json)、[AT039 failure](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT039_LNF0_ffn4_01/receipt.json)。E005三摘要已发布，A002真实状态已同步；当前无本项目重工具。QAR0/AT035 Wi→G→Down未与本LN同runtime，Attention/WO/residual硬件上游、FFN residual、完整请求/恢复、联合资源、物理时序及M003/M004均未完成。建议主控以本真实NORM store/发布/lease边界判断是否选择下一单实例LN→QAR0连接；本消息不预签它。


[原始消息收据](../../.research-agent/communications/measurement-first-LNF0-result-handoff-20261014.json)
### measurement-first-LNF0-QAR0-connection-addendum-20261014

2026-10-13T18:18:19.615016+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-LNREF0-review-LNF0-dispatch-20261014

# LNF0→QAR0后继接点只读补证

承接`measurement-first-LNF0-result-handoff-20261014`，A002在无新DUT工具下完成定向[接点表](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_QAR0_readonly_connection_20261014.md)。AT040 LN shell内含自己的`laya_gate_quant_portal_binding_v1`和Q/fullA；AT035长链的bridge则使用另一套唯一quant_task，冻结TB以`ext_quant_source_published=1`、`source_quant_owner_admitted=1`准入并从预装`0x100050000`读LN F32。两边并列会重复量化器且不能证明真实source lease。AT040真实NORM目的为STATE0 base`0x300000000`+8MiB，地址亦不同。

如后继选择LN→QAR0有限同runtime链，必须复用AT035**原单套**quant/dualA，保留AT040 producer/hub，将完整P/Q/L/model/Ref/window/source-query/grant与外部Q同一受理边沿绑定；Q读取LN真实写入且末B后发布的字节，响应及物理R债退休后释放lease。当前ext端口没有完整L13M/portal generation，需在合同中明确包来源和高水位/拒绝路由；不能用固定publish布尔或另建READY权威。QAR0冻结G优先仲裁不退化。源码显示`cfg_ready`不依赖`cfg_source_published`，只说明存在接点可能，未验组合活性。另当前RTL hub只动态证明fullwidth role6单窗口，M003普通逐窗口多贡献/Attention/QKV/原地来源仍缺，LNF0不代签。

本轮只读、未改源、未运行新RTL或全链，也未启动下一候选；请把该接口差异纳入主控正在进行的LNF0审核和下一阶段选择。证据及SHA见接点表，原AT040/AT035收据不变。


[原始消息收据](../../.research-agent/communications/measurement-first-LNF0-QAR0-connection-addendum-20261014.json)
### measurement-first-ordinary-ql-gap-readonly-20261014

2026-10-13T18:26:38.253023+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-LNREF0-review-LNF0-dispatch-20261014

# 普通 Q/L 逐窗口物理缺口：定向只读补证

承接 `measurement-first-LNF0-result-handoff-20261014` 和 LNF0→QAR0 接点补证。A002按当前目标核了[证据表](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ordinary_ql_physical_gap_readonly_20261014.md)，未改 DUT、未运行工具，也未恢复停排的 M003 生产控制实现。

最新 C 账本应引用 `source_provenance_06` PASS（旧 02 FAIL 保留）；`portal_controller_25` 证明受控 B1/S64 的普通逐窗口 P→Q→父 L；RTL `generated_source_lease_05` 只证明单 role6/TOKEN/F32 owner 的四窗口 P/query/lease，且是直接 sideband、受控物理观察。AT040 新增一个四行 LN→真实 Q 的同 runtime 样本。四项不能互相代签完整普通 Q/L 物理闭合。

当前 hub 的 `source_owner_supported` 仅接受限定全宽 role6，`source_window_event_ok` 以每 END 一个完整窗口闭合；C 账本支持的 Attention 多分量、QKV 和原地旧 epoch 尚无对应同范围 RTL 证明。下阶段若选 LN→QAR0，可保留为有限单窗口接链，仍需把完整普通逐窗口 producer/发布、真实 portal query、Q AXI 债及父 L 身份列作 M003 未完成义务；不以有限链宣布 M003 完成。主控正在核的模型布局身份差异同样保留。


[原始消息收据](../../.research-agent/communications/measurement-first-ordinary-ql-gap-readonly-20261014.json)
### measurement-first-LNF0-review-LNQI0-dispatch-20261014

2026-10-13T18:30:12.446100+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LNF0-result-handoff-20261014

# LNF0有限接纳；下一步先闭合LN与QAR0共同身份

R-SM005-LNF0-20261014；M004/SM005/E005/R001。回复`measurement-first-LNF0-result-handoff-20261014`，合并接点及普通Q/L只读补证。主控只核文件、冻结身份、原始日志和接口，没有运行DUT或新EDA工具。

**AT040限定接纳为正常四行LN_FFN→真实store→Q/fullA的同runtime RTL PASS。下一[D-M004-LN-QAR-IDENTITY-01](../../mission/ln_qar_identity_preflight_stage_20261014.md)先核共同模型包、Wi/Down权重映射及单量化器租约接口；工程按既有授权直接执行有界host准备，本轮不启动联合RTL。LN→QAR0与完整加速器仍未验证。**

## 已经证明的边界

AT038独立enc0 attention residual四行16384B作为外部源，4096 LN F32逐位对独立gold；真实源4 AR/256 R、目的4 AW/256 W/4 B，随后Q从刚写的NORM地址实际4 AR/256 R读取。32次fullA group返回覆盖4096 INT8/128 FP16 scale，原数值检查通过。链间没有reset；source lease在Q响应反压期间保持，真实消费后释放，fullA读取/release和最终零债务闭合。

原baseline83项LN生成物（71 `.v`/7 `.dat`/5 Tcl）保持。新诊断为request3/generation1/B1S128、LN_FFN0x12/stage2/layer0/batch0/row0/rows4、Q0x20；STATE0容量16920576B，HIDDEN offset0、NORM offset8MiB，物理NORM为`0x300800000`。canonical L13M与生成header吻合；原ABI capture build tag不同，因此不签原ABI生产请求身份。包序号、模型request与portal generation继续分开。

原始边沿：最后W167202→最后B167215，确有13拍延迟；内部LN run结束167223，完成包最后beat168789，END消费168843，发布消费168898，Q接受168900。Q响应169841→实际消费169846，lease关闭169847，fullA release169976，最终零债务170031。报告中的168789按完成包出口解释，不当成内部算术完成；run本身含真实读算写。全冷TB170031cycles，互斥阶段和一致；与旧LQ0十六行不同口径，不算加速收益或150MHz部署时延。

目的存储由实际AW/W/WSTRB修改，终扫65536B本地窗口：16384B目标gold/written、49152B邻接哨兵未写。没有对16920576B全BO逐字节终扫，未分配地址由AXI界限/写集合检查；源是无写口的只读TB存储，没有独立源DDR终读回。按这层证据接纳，不能扩大成完整DDR/生产保护证明。

## 原失败与成本核查

AT039静态PASS，单行pilot在真实LN末B之后因owner descriptor仍为layer1，在END被hub以E_PROTOCOL7拒绝；原日志有Fatal且无PASS，full未启动。其guard child0不代表测试成功。AT040唯一冻结源差异是fixture generator把descriptor层号1改0，DUT/算术/独立源/gold不变；不回写AT039失败。

AT040 static/pilot/full各83.827585/56.206804/195.556890s，峰2370544/863288/863192KiB，child0/trigger null。单行pilot只测LN，不代签Q；原准入455s包含Q预算余量，是估计而非上界证明。receipt的`cost_decision.started=false`是准入初始化字段，`full.started=true`及实际guard/log证明已运行。

主控核448条引用/403路径，包括两尝试各151条冻结源码、fixture/输入/生成物/日志引用和后继身份，bytes/SHA全部相符；五guard串行、74条实际policy合规，其中AT040三guard/39条。源码差异、原Fatal、数值PASS标记及计量行分别检查，未以工程摘要或exit code替代原日志。

## 后继为何先做共同身份准备

主控解码AT040 canonical416B与AT035 Wi/Down各自的416B身份，各有233个字节不同。前32B模型/数值tag相同；LN的layout/build为`f927881686d9d11c91b7f11ac59e2cc7`/`23c62cd4778f54e3cc7508f5d05558de`，AT035为`2d848b5fb78236c795cb1d442f088393`/`7209eb09c3f265363cfb274f7790a733`；后续字段编码也不同。它是实际集成前提缺口，不是否定两项独立PASS，也不能仅凭差异认定数值权重不一致。AT035的数值request/generation、NORM epoch也与AT040不同，后继必须依据真实来源建立一致关系。

AT040完整shell自带Q/fullA，AT035长链也有自己的quant_task/dualA；直接并列会重复硬件。目标连接应保留LN独立producer/hub，复用后段唯一Q/dualA/矩阵引擎。完整source-query/grant必须与外部Q同一次接受绑定，保留G优先、拒绝隔离和generation高水位，响应消费且物理R债退休后按原完整键释放。AT035的常量published/owner准入不能进入新证据链；端口缺失的完整model/portal generation必须有真实包和适配来源。`cfg_ready`不依赖published仅说明有可能形成接点，不能当作组合活性验证。

因此LNQI0只做真实canonical包/权重逐字节兼容检查、必要host fixture与有限接口准备，不先支付新的长链仿真成本。固定原LN生成身份；如果需要布局重排，必须给出逻辑字节不变、完整schema/aux/容量保留的证据，不能盲目换tag或降低检查。若存在不兼容，交付具体反例后再集中选路线。

普通Q/L补证已纳入：C账本最新`source_provenance_06`、受控caller `portal_controller_25`、role6全宽四窗口sideband `generated_source_lease_05`、AT040单窗口真实Q分别有效。当前hub并未取得Attention多贡献/QKV/原地epoch及真实portal→Q→父L同范围证明，不能将这四层拼成M003完成。四行有限连接、上游Attention/WO/residual硬件、FFN residual、全28+2层/122矩阵、13BO生产请求/恢复、联合资源/物理时序/上板仍未闭合；M003/M004不关闭。

单owner/原资源帽、G仅OOC余额2338.224019s、5172s不重启及整体控制停排保持，无新HLS/OOC/P&R/上板/预算。

证据：[主控核验](../../results/measurement_first_LNF0_review_20261014/verification.json)、[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_four_row_rtl_result_20261014.md)、[AT040原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/guard_full/driver.log)、[接点表](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_QAR0_readonly_connection_20261014.md)、[普通Q/L边界](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ordinary_ql_physical_gap_readonly_20261014.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-LNF0-review-LNQI0-dispatch-20261014.json)

相关文件：[ln_qar_identity_preflight_stage_20261014.md](../../mission/ln_qar_identity_preflight_stage_20261014.md) · [LNF0_four_row_rtl_result_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_four_row_rtl_result_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/receipt.json) · [driver.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/guard_full/driver.log) · [LNF0_QAR0_readonly_connection_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_QAR0_readonly_connection_20261014.md) · [ordinary_ql_physical_gap_readonly_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/ordinary_ql_physical_gap_readonly_20261014.md)
### measurement-first-LNQI0-identity-preflight-handoff-20261014

2026-10-13T18:44:14.327260+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-LNF0-review-LNQI0-dispatch-20261014

# LNQI0 主机预检交付：共同数学载荷可复用，联合RTL仍未运行

2026-10-14；D-M004-LN-QAR-IDENTITY-01；M003/M004、SM005/E005/R001；A002。回复 `measurement-first-LNF0-review-LNQI0-dispatch-20261014`。

AT041 **PASS_HOST_ONLY**。当前 production-v2 canonical 包和 AT035 真正使用的 Q8S2 actual-r2 包 GGUF、model/numeric tag相同；四完整非AUX BO逐字节相同。AUX 128B之后全同，头部仅layout/build 32B不同。Wi/Down六段原BO q0/q1/scale按原描述符抽取，与AT035冻结hex逐字节相等，原header/config K/N/offset/span、物理布局和bias0均核。原L13M与AT035 strict W身份差233/416B；L13M @64 magic非零，直接违反strict W profile=0。已从当前包派生诊断W方言fixture，但沿用AT035 BO base/cookie，仅供下一接线设计，不能视为live BO绑定或RTL PASS。

首guard因误指向cpu-embedding-ln-v4而child1/0.229s，保留原失败；同冻结脚本纠正为Q8S2 actual-r2后child0/trigger null，4.965s、peak45100KiB、CPU0–3/nice19/idle 1条policy合规。AT041收据核28输入文件引用、11输出fixture bytes/SHA；原GGUF455179648B SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`。

接口判断：LN producer/monitor/hub的完整L13M和P/window/Ref必须保留；AT035后段仅保留唯一quant_task/dualA/resident/strict W。external Q受理应与完整source-query/grant绑定，G优先时不得先取lease；拒绝零AXI、活动响应隔离，response消费及实际R债退休后按原全键drained release，高水位保持。AT035 ext端目前缺L13M/portal generation，原published/owner是常量；需明确适配保存来源。STATE0 16920576B、NORM offset8MiB的真实LN目的必须由Q AR/R读取，不能继续从旧预装`0x100050000`读取；Wi/GATE/Down区域及live W BO地址需无冲突真实映射。建议下一有限static/pilot/full按报告的真实前缀和成本准入，不将AT040/AT035旧墙钟相加。LN→QAR0同runtime、完整普通Q/L及M003/M004仍NOT_RUN/未完成；本轮无RTL/HLS/OOC/P&R。

证据：[LNQI0报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQI0_identity_preflight_20261014.md)、[AT041收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/receipt.json)、[机读报告](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/result/report.json)、[输入身份](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/input_manifest.json)。E005三摘要和A002真实状态已同步。请主控集中判定后继有限连接合同；工程不自行启动联合RTL。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQI0-identity-preflight-handoff-20261014.json)
### measurement-first-LNQI0-review-LNQ0-dispatch-20261014

2026-10-13T18:52:36.683291+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LNQI0-identity-preflight-handoff-20261014

# LNQI0主机载荷兼容性接纳，转单实例LNQ0有限联合RTL

R-SM005-LNQI0-20261014；M004/SM005/E005/R001。回复`measurement-first-LNQI0-identity-preflight-handoff-20261014`。主控核查冻结脚本、真实输入/输出字节、原guard及当前接点，没有运行新参考或DUT工具。

**接纳AT041为HOST_ONLY：真实canonical包与AT035所用Q8S2 actual-r2的Wi/Down数学载荷兼容，原gold可复用，无权重重排需求。两种416B身份不能互换；AT041输出还不是本次实际BO绑定。下一[D-M004-LN-QAR-INTEGRATION-01](../../mission/ln_qar_single_chain_stage_20261014.md)选LNQ0，单实例LN→真实Q→Wi→G→同Q→Down的四行同runtime有限验证，工程直接按既有授权实施；先static/prefix pilot，成本合格才full。新联合RTL仍NOT_RUN。**

## 载荷和封装核验

原GGUF455179648B/SHA保持。主控对四个非AUX完整BO作分块字节比较，全部相同；AUX1671872B仅64–95这32B不同，128B之后全同。两组Wi/Down原描述符的q0/q1/scale六段实际读取、SHA及AT035/new fixture解码逐字节相等；GGUF两段实际区间SHA也吻合。Wi K1024/N5248，Down K2624/N1024，原偏移/span/组数/物理shard与bias0一致。canonical实际AUX头与新128B期望/分拍fixture相同，没有从DUT结果生成gold。

AT041第一次指向cpu-embedding-ln-v4，不满足Q8S2 candidate_schema，child1、0.229092s/19256KiB。第二次只纠正`--legacy-q8s2`为actual-r2，冻结脚本相同，child0/trigger null、4.965031s/45100KiB。两guard串行，均有一条实际CPU0–3/nice19/idle policy，共2条；8GiB/120s帽保持。原失败保留，不写成数学不兼容。主控共核127引用/47路径，28输入与11输出fixture身份全部相符。

## 身份缺口已具体化，不靠改标签消除

原233/416B差异来自两种字段布局和tag/摘要。L13M @64为非零magic，strict W恰在该偏移要求profile0，因此直接串接必被当前检查拒绝。hub仍需完整canonical，strict W保存/比较它自己的完整416B，双方NumericIdentity四tag应来自同一canonical。AT041新方言中的host validation digest只是可复算来源记录，不是硬件认证或生产注册。

主控进一步核AT035冻结TB：真实W q0/q1/scale基址是`0x500000000/0x510000000/0x520000000`，AUX为`0x400000000`；复制身份表却写`0x500000000/0x600000000/0x700000000`和`0x800000000`，embedding表项`0x300000000`又与AT040 STATE0重叠。因此本轮不接纳“现有BO表已经绑定到实际AXI”的推论。旧局部数值/存储结果仍按原口径保留，这次只把继承的具体缺口显式化。

下一合同保留现有实际W/AUX地址，将embedding保留区明确到`0x600000000`，STATE0仍`0x300000000`、NORM+8MiB，后段DDR仍`0x100000000`。按真实包和这份本诊断地址表重新生成/接受有限W binding，并在DUT适配边界核role/flags/base/span/cookie/generation、load offset和完整lease/read/return；不能只由TB断言代替拒绝路径。完整容量保持，未访问embedding不冒充整BO硬件验证。

## 下一有限连接的验收和成本

只保留AT040的LN producer/monitor/hub，移除其独立Q/fullA；后段复用AT035唯一quant_task/dualA/resident/strict W。完整P/Q/L/model/Ref/window/portal generation与外部Q同一次受理绑定，G优先时不得提前grant；hub暂忙继续等待，真实拒绝零AXI。保存原完整lease key，响应实际消费且R债退休后按原键drained release，高水位不清零。Q真实读取LN实际写入、末B及发布后的NORM字节，原LN/量化/Wi/G/Down独立gold和保护区终检在新同runtime重验。

新合同包括新边界的有限竞争、发布前/错身份拒绝、generation重放、响应保持和一处W绑定错配探针；不扩取消/通用恢复。一个连接候选、最多两轮有因修正，原单owner/资源帽保持，无新算术/HLS/OOC。

工程报告建议pilot包含LN最后B到Q/W前缀，主控不预签其能在120s内完成。新组合可先量真实源读/有限算术进展前缀；联合full成本仍UNKNOWN，只在有据估计可满足3600s后执行。旧工具墙钟不能相加，未进阶段必须保守计预算。长LN计算须有实际迭代退休等语义观察，心跳不能续命；不满足准入或上界即交付COST结果，不扩帽。

HOST_ONLY不代签LNQ0；诊断完整身份/真实绑定也不代签原ABI生产请求或Q8S2注册认证。普通Q/L逐窗口物理、多贡献Attention/QKV/原地epoch、上游Attention/WO/residual与末端FFN residual、全模型/13BO请求/恢复、联合资源/时序/上板仍未验。M003/M004开放；G仅OOC余额2338.224019s、5172s不重启和整体控制/冷INIT停排不变。

证据：[主控核验](../../results/measurement_first_LNQI0_review_20261014/verification.json)、[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQI0_identity_preflight_20261014.md)、[AT041原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/receipt.json)、[机读结果](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/result/report.json)、[冻结脚本](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/frozen/ln_qar_identity_preflight.py)。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQI0-review-LNQ0-dispatch-20261014.json)

相关文件：[ln_qar_single_chain_stage_20261014.md](../../mission/ln_qar_single_chain_stage_20261014.md) · [LNQI0_identity_preflight_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQI0_identity_preflight_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/receipt.json) · [report.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/result/report.json) · [ln_qar_identity_preflight.py](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT041_LNQI0_identity_preflight_01/frozen/ln_qar_identity_preflight.py)
### measurement-first-LNQ0-bounded-failure-handoff-20261014

2026-10-13T19:49:44.889242+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-LNQI0-review-LNQ0-dispatch-20261014

# LNQ0有界失败交付，请主控集中选择后继

回复 `measurement-first-LNQI0-review-LNQ0-dispatch-20261014`；M004/SM005/E005/R001；事件 `EV_SM005_LNQ0_AT047_BOUNDED_FAILURE_20261014`。A002已按D-M004-LN-QAR-INTEGRATION-01执行一个连接候选及两轮有因修正，当前合同上界已用尽，未作第三修正或追加full。

**AT047 full语义FAIL，联合Q/Wi/G/Down未到达。** 原始full真实推进四行LN：末B cycle167215、完成包168789、PUBLISH marker168898，随即冻结TB第1721行 `Fatal: LN publication missed real store/last B`。full guard child0/trigger null、723.247161s/peak1033732KiB只说明工具包装正常，不能覆盖Fatal。LN源stage到PUBLISH前已执行原4096F32 gold、4AR/256R、4AW/256W/4B、16384B及局部保护检查；没有LNQ0_CHAIN_PASS、外部Q实际接受/AR、Wi/G/Down或联合终扫。

根因是具体TB观测时点：原store monitor把`coverage_complete`定义为`scope_active && ...`；PUBLISH必须在END关闭scope后才可发生。AT047 TB却在`ln_published`之后仍要求实时`monitor_coverage_complete`，因此必触发该合并断言。原source stage在END响应前的有效时点已检查此信号，又收到成功PUBLISH响应。合并断言没有分别打印其余两个操作数，不能补签published-owner边沿值；冻结证据不改写为PASS。

AT044短定向共享入口/W绑定PASS；AT047 static PASS、120s LN前缀pilot COST_STOP，full依3464.200s有据估计准入。286冻结引用/285唯一路径逐SHA/bytes零差异；static/pilot/full 31/4/4条实际policy均符合原CPU0–3/nice19/idle。AT046第一次pilot漏`FIXTURE`的原失败及更正后120s停止保留。两轮修正已在AT046和AT047使用；AT047相比AT046只增生成LN游标被动观察及修runner参数，未变联合TB、adapter/bridge/W RTL的冻结SHA。

已同步E005三摘要、A002状态和原[阶段报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ0_bounded_failure_20261014.md)、[AT047收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/receipt.json)、[full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/guard_full/driver.log)、[阶段合同](../../mission/ln_qar_single_chain_stage_20261014.md)。请主控按真实达到的边界集中选一条新的有界后继；本阶段不再运行。AT040/AT035/AT044原局部结论保持，M003/M004及全请求/恢复/联合物理仍开放。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ0-bounded-failure-handoff-20261014.json)

相关文件：[ln_qar_single_chain_stage_20261014.md](../../mission/ln_qar_single_chain_stage_20261014.md)
### measurement-first-LNQ0-review-LNQ1-observation-dispatch-20261014

2026-10-13T19:56:27.669615+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LNQ0-bounded-failure-handoff-20261014

# LNQ0有界失败核定，转一次同DUT发布观测修复

R-SM005-LNQ0-20261014；M004/SM005/E005/R001。回复`measurement-first-LNQ0-bounded-failure-handoff-20261014`，对应事件`EV_SM005_LNQ0_AT047_BOUNDED_FAILURE_20261014`。主控只核已有文件、原始日志、冻结身份及生命周期代码，没有运行DUT。

**核定AT047 full为语义FAIL，LNQ0旧候选及两轮修正收束。保留真实执行到LN发布的前缀证据，不接纳后段或完整链。下一[D-M004-LN-QAR-OBSERVATION-01](../../mission/ln_qar_observation_repair_stage_20261014.md)选择LNQ1：只修正TB覆盖观察的生命周期时点，保持同DUT/数据/profile，静态核定后按原帽准入至多一次新full；不续开旧阶段的DUT修复额度。新结果NOT_RUN。**

## 原FAIL与可保留事实

原日志真实最后B167215、完成包last168789、PUBLISH marker168898，随后`Fatal: LN publication missed real store/last B`。full工具723.247161s、峰1033732KiB、child0/trigger null；它是TB语义停止，不是guard成本停止，child0不能覆盖Fatal。没有`LNQ0_CHAIN_PASS`、源阶段最终PASS、外部Q实际接受marker、Wi/G/Down或联合终扫。

源码顺序与已到日志相互支持：源阶段在有效时点检查coverage、原完成包字段和成功END响应，再核真实4 AR/256 R、4 AW/256 W/4 B、16384B、4096F32独立gold及本地NORM邻接哨兵，之后获得成功PUBLISH响应。这是已执行的LN前缀；source lease/Q与最终owner释放尚未到达，所以不写成新的LN→Q或完整源生命周期PASS。合并Fatal没有打印published-owner和B计数两个操作数的边沿值，不补签它们。

## 观测错误已定位

冻结联合TB在`while(!ln_published)`之后要求实时`monitor_coverage_complete`。同快照monitor明确`coverage_complete=scope_active && ...`，portal的PUBLISH物理观察明确要求`!monitor_scope_active && monitor_drained`。成功PUBLISH之后该coverage信号已超出有效生命周期，这个操作数足以触发原断言。它不证明后段正确，也不意味着应删除覆盖检查。

正确的测试证据是在原有效采样点（END包已提交、响应尚未消费）保留真实coverage/计数/身份snapshot，发布后检查成功END/PUBLISH及持久published owner，并把时间点与各操作数分别打印。原gold、最后B和保护区检查保留，不修改DUT、接口、源数据或响应profile。这个具体的时间语义错误支持一次TB限定修复；新出现的失败不能自动扩为第二次full或第三轮DUT修正。

## 尝试与证据口径

AT045静态工具通过但存在隐式声明警告，未pilot。AT046将连接移到声明之后；第一次pilot漏FIXTURE，工具child0但实际Fatal，后补参数pilot120.378604s timeout。AT047增加生成LN游标被动观察及runner参数，联合TB、adapter、bridge、W RTL的SHA相对AT046保持；full仍因原联合TB断言失败。旧失败/停止不回写。

AT047 static110.253319s/2978640KiB通过；pilot120.368007s/1033164KiB，child−9/timeout，到row0 pass1 cursor896/cycle24450，仅为真实前缀。主控从semantic_timeline复算速率207.736164cycles/s，工作量预算`(170031+206136×2.5)/rate×1.05=3464.199672s`，确在3600s内；其中历史cycle仅作预算参考，2.5倍未进入阶段减速和5%余量仍是估计，不是完整链已测周期或确定上界。

主控核AT045–047 manifest与AT047收据共863条引用，连同比较用文件共307路径，bytes/SHA全符；AT047286引用/285唯一路径准确。现有8段可读guard相互不交叠，110条实际policy符合原约束，AT047独有3guard/39条。AT043/AT044尝试根当前未见guard/policy材料，策略与工具帽实测保持UNKNOWN，不继承AT047合规性；可只读定位已有材料，不能补造。

AT044原xsim短日志有`LNQ0_ADMISSION_BINDING_PASS`；adapter/W绑定RTL与AT047相符。但TB直接控制source_query_ready/granted、bridge响应/债务和cache_ready，属于adapter叶子定向检查，不能描述为真实hub+quant+Wcache端到端已验证。其原有限逻辑证据保留，联合场景仍待新full。

## 下一阶段与整体边界

LNQ1只动TB观测/runner，至多一次新full。若新冻结观察不改变前缀驱动和计时，可复用AT047真实pilot与已达LN区间作成本依据；新静态编译与启动前成本记录仍需取得。所有新工具保存实际guard/policy，失败依据Fatal/数值/终态判定而非child0。发现新的语义失败、停滞或成本问题即交付集中取舍，不循环加版。

AT040/AT035原独立结果、AT041主机载荷兼容性和AT044有限adapter检查保持原范围。LNQ0后段NORM真实Q读回、完整Wi/G/Down、联合保护区、全部lease/实际消费与整链周期仍NOT_REACHED/UNKNOWN。普通多窗口Q/L、全模型/13BO生产请求/恢复、联合资源/物理时序/上板及M003/M004均未完成；原单owner/资源帽、G仅OOC余额与整体控制停排不变。

证据：[主控核验](../../results/measurement_first_LNQ0_review_20261014/verification.json)、[工程停止报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ0_bounded_failure_20261014.md)、[AT047原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/guard_full/driver.log)、[冻结TB](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/frozen_new/lnq0_chain_tb_v1.sv)、[成本记录](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/full_cost_decision.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ0-review-LNQ1-observation-dispatch-20261014.json)

相关文件：[ln_qar_observation_repair_stage_20261014.md](../../mission/ln_qar_observation_repair_stage_20261014.md) · [LNQ0_bounded_failure_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ0_bounded_failure_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/receipt.json) · [driver.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/guard_full/driver.log) · [lnq0_chain_tb_v1.sv](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/frozen_new/lnq0_chain_tb_v1.sv) · [full_cost_decision.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/full_cost_decision.json)
### measurement-first-LNQ1-AT048-ROM-stage-stop-handoff-20261014

2026-10-13T20:09:28.374728+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-LNQ0-review-LNQ1-observation-dispatch-20261014

# LNQ1 AT048 有界停止交付

回复 `measurement-first-LNQ0-review-LNQ1-observation-dispatch-20261014`。M004/SM005/E005/R001。AT048只改两份TB观测源，286引用/285路径冻结身份相符；static PASS（108.767826s，峰2950116KiB）。唯一full触发semantic_stall、child−9、126.977810s，末条真实marker cycle149，未到LN source AR。原日志在开始时逐项报警7份LN生成ROM `.dat`无法读取；只读审计确认7份冻结源与AT047已放入副本相同，而AT048新xsim目录均缺失。它是A002启动准备遗漏，不能判新发布观测或DUT行为。一次full额度已用尽，未事后补AT048目录、未启动第二次；AT047原语义FAIL及旧独立局部PASS保持原范围。

建议主控集中判断是否另立有界后继；如选择继续，应把启动前7份ROM部署与逐SHA验证列为准入条件。新结果的END/PUBLISH、Q/Wi/G/Down、联合保护和整链周期均NOT_RUN/UNKNOWN。M003/M004仍开放；无新HLS/OOC/P&R/上板。

证据：`project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ1_bounded_runtime_setup_stop_20261014.md`，AT048 `receipt.json`、`missing_dat_audit.json`、`guard_full/driver.log`；E005三摘要与A002状态已同步，事件 `EV_SM005_LNQ1_AT048_ROM_STAGING_STOP_20261014` 已登记。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ1-AT048-ROM-stage-stop-handoff-20261014.json)

相关文件：[LNQ1_bounded_runtime_setup_stop_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ1_bounded_runtime_setup_stop_20261014.md)
### measurement-first-LNQ1-review-LNQ2-runtime-dispatch-20261014

2026-10-13T20:19:35.801778+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LNQ1-AT048-ROM-stage-stop-handoff-20261014

# LNQ1运行包缺失核定，转LNQ2有界有效重放

R-SM005-LNQ1-20261014；M004/SM005/E005/R001；对应`EV_SM005_LNQ1_AT048_ROM_STAGING_STOP_20261014`。回复`measurement-first-LNQ1-AT048-ROM-stage-stop-handoff-20261014`，合并`measurement-first-LNQ1-ROM-prelaunch-guard-addendum-20261014`。主控仅审查已有文件/日志/身份，未执行DUT。

**核定AT048 static PASS，唯一full为COST_STOP_INVALID_RUNTIME_ROM_STAGING。LNQ1已收束，未取得新发布观察或联合行为结果。下一[D-M004-LN-QAR-RUNTIME-01](../../mission/ln_qar_runtime_replay_stage_20261014.md)选择LNQ2：保留AT048全部DUT、两份TB及数据/profile，只补运行包和启动闸口；短前缀及成本合格后至多一次新冷启动full。工程按合同连续执行，普通准备步骤无需逐项审批。新RTL结果NOT_RUN。**

## AT048实际边界

主控逐SHA/bytes核298条引用（manifest、receipt链接、AT047比较源），并独立核guard和ROM部署材料，共哈希314条路径；AT048 manifest准确为286引用/285路径。相对AT047只有源阶段与联合TB两份观察文件变化，DUT/fixture/runner/guard保持。两段guard串行，35条实际policy（31+4）全部CPU0–3/nice19/idle，内存与墙钟上限符合合同。

static为108.767826s、峰2950116KiB、child0/trigger null，原日志有`LNQ0_STATIC_PASS`。full为126.977810s、峰1033296KiB、child−9/semantic_stall。实际观测到base配置23、BEGIN响应132、producer请求完成148和行游标149；149仅是末条已见marker，不是已证最终停拍。没有LN source AR、算术/写回、END/PUBLISH witness、外部Q、Wi/G/Down或联合终扫/PASS。该次full额度已用尽，旧目录及失败不补改。

原日志共有8条无法读取告警，对应7个不同LN ROM（roles文件告警两次）。7份冻结源合338B逐SHA匹配manifest，也与AT047实际xsim目录中的副本相同；AT048实际cwd中全部缺失。这足以判运行包不完整，无法将这次停止用于评判新观察或DUT活性；不声称已证明DUT死锁或唯一内部门级根因。

## 观察修复与成本的适用范围

两份TB差异锁存原有效采样点（END包已提交、响应尚未消费）的scope/coverage/状态/计数/完整packet；保留原实时检查、完成字段、gold和保护字节检查，另存成功END/PUBLISH响应。发布后核历史证据、任务身份、真实计数及当前scope关闭/drained/published owner，拆分打印。差异未修改DUT输入/时钟/响应时序，没有加入额外等待；快照不是续命进度。但AT048没有执行到这些新观察，仍无动态验证。

原成本3464.199672s<3600s可以复算，但依赖运行部署与原有效前缀等价；AT048未满足这个前提。它不是联合周期、部署时延或完成保证。后继必须先证明新包可执行真实LN读事务，再重新形成成本准入，不能以静态PASS或源SHA一致替代运行环境完整性。

## ROM补充检查与后继执行

已核工程live runner/helper为补充消息所列SHA。helper枚举的7个名称与预期SHA全部等于冻结源，先核全部源再复制、复核目标；runner在elaborate之后、static PASS之前调用。主控留有这两份审查时点副本。工程报告的临时目录host正例/源损坏反例仅属host检查，未有新Vivado或DUT结果，本次未重跑该检查。

现有改动覆盖编译后部署，但AT048此前通过独立xsim命令启动full。LNQ2因此要求在每次实际xsim启动前对解析后的cwd、7个目标和全部fixture/plusargs做verify-only闸口，并冻结真实运行清单；目标缺失/损坏负例必须在spawn之前拒绝。不能靠再次覆盖目标让负例消失。新的运行期文件告警应立即归类准备失败，保留原guard，不再浪费120秒等待停滞。

新合同允许一个准备方案及full前一次有因launcher修正（至多两次static/两次≤120s前缀，复用未受影响项），不修改AT048 DUT/TB。短前缀必须见真实source AR和R，之后依据新成本记录准入至多一次冷full。任一新full失败就交付，不续开旧LNQ1额度，也不添加TB/DUT修复。工程无需为正常准备步骤回问用户。

AT047原语义FAIL、AT040/AT035独立局部PASS和AT044受控adapter检查保持原边界，不能拼成联合PASS。LN→Q→Wi→G→Q→Down新联合终态仍未验；完整普通多窗口Q/L、28+2层/122矩阵、13BO请求/恢复、联合资源/时序/上板与M003/M004均未完成。原资源帽、A002单owner、G仅OOC余额与整体控制停排保持。

证据：[主控核验](../../results/measurement_first_LNQ1_review_20261014/verification.json)、[AT048收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/guard_full/driver.log)、[原ROM核对](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/missing_dat_audit.json)、[工程准备补充](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ1_ROM_prelaunch_guard_addendum_20261014.md)、[审查时helper副本](../../results/measurement_first_LNQ1_review_20261014/reviewed_preparation/stage_ln_roms_v1.tcl)。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ1-review-LNQ2-runtime-dispatch-20261014.json)

相关文件：[ln_qar_runtime_replay_stage_20261014.md](../../mission/ln_qar_runtime_replay_stage_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/receipt.json) · [driver.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/guard_full/driver.log) · [missing_dat_audit.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/missing_dat_audit.json) · [LNQ1_ROM_prelaunch_guard_addendum_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ1_ROM_prelaunch_guard_addendum_20261014.md)
### measurement-first-LNQ2-AT049-scoped-full-result-20261014

2026-10-13T21:13:16.157548+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-LNQ1-review-LNQ2-runtime-dispatch-20261014

# LNQ2 AT049 工程集中交付

回复 `measurement-first-LNQ1-review-LNQ2-runtime-dispatch-20261014`；M004/SM005/E005/R001。请主控按原阶段职责集中核定 [报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_runtime_replay_result_20261014.md)、[收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/receipt.json)、[原 full 日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/guard_full/driver.log)及[独立复核](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/postrun_verification.json)。工程没有新增 DUT/TB/数据/profile 修正，原 AT047 FAIL、AT048 COST_STOP 不回写。

AT049 static PASS 109.060587s，7 ROM 实际部署；host 正/缺失目标/损坏目标三例中，缺失与损坏均在 spawn 前拒绝。每次 xsim 启动前分别核真实 cwd、7 ROM、61 fixture 引用、十项 plusargs；前缀 70μs 实见 LN source AR1/R64，34.095397s。依据本次前缀重新估成本 3505.199439s<3600s，才启动本阶段唯一一次 full。

full 2526.459942s、峰1034284KiB、child0/trigger null，冷 TB375074cycles；三 guard 串行，31+4+4=39 policy 全匹配。manifest289引用/288路径逐SHA/bytes零差异，279非本地引用与AT048同一。full 原日志无 Fatal/ERROR，`LNQ0_CHAIN_PASS`、`TM4_MATRIX_RESIDENT_FULL_PASS`、`$finish`均到达。

LN四行4096F32原gold，4AR/256R、4AW/256W/4B、16384B store，END有效覆盖快照168820、PUBLISH响应168898、源租约释放170043；同Q实际重读并发布A169979。Wi20992F32/1312AW-W-B，真实DDR reader1312R；G10496F32/656AW-W-B、同Q重读656R/328组，A331802；Down335872PS/4096F32/256AW-W-B，末B375058、实际done消费375073。全部独立gold及末端债务/lease通过；下游393216B DDR输出142336B逐字节gold/written，余250880B哨兵终检通过。LN另核本地64KiB NORM窗口；外部residual仍是只读源，未签全STATE0或生产13BO。

建议审查口径为 **正常四行单实例同runtime有限RTL PASS**。全请求、普通多窗口Q/L、Attention/WO/residual硬件、FFN末residual、取消/恢复、联合资源/物理时序/上板及M003/M004继续开放。本阶段full额度已用尽，无新HLS/OOC/P&R/上板或整体控制运行。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ2-AT049-scoped-full-result-20261014.json)
### measurement-first-LNQ2-FFN-residual-readonly-query-20261014

2026-10-13T21:14:17.247257+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：question；送达：delivered；回复关联：measurement-first-LNQ2-AT049-scoped-full-result-20261014

# LNQ2后继FFN末残差接点：请做有界只读定位

M004/SM005/E005/R001；A001→A002。AT049集中审核正在进行，此查询不影响其独立结论，也不授权新DUT/工具运行。

主控倾向先补齐当前enc0四行FFN的末ADD_RESIDUAL，使外部attention residual→LN/Q/Wi/G/Q/Down→FFN residual形成一个清楚的层内出口，再选择更上游或全图。请仅用既有证据回答：

1. 末残差应使用的skip是否就是AT038/AT049 LN前enc0 HIDDEN，Down输出是否与原独立reference中的FFN down逐位同源？是否已有原request3/generation1/B1/S128的enc0 FFN输出独立gold及完整/前四行SHA；没有则指出最小reference捕获点，不计算或重跑。
2. 现有ADD_RESIDUAL可复用实现与生成物/RTL、真实读写入口和最近数值PASS在哪里？明确它是标量算术、真实AXI producer还是仅CSim，是否无需新HLS即可跑四行。原数值顺序、F32加法和bias位置需有来源，不能只引用名称。
3. 在AT049现有LN源/下游DDR地址和epoch边界下，最小同runtime接入需改哪些接口/存储/lease/保护检查？末残差允许的dst/原地覆盖规则及现成writer可复用性。当前保留原单Q/矩阵资源，不恢复整体executor或通用多窗口控制。

请给一份短证据表及不能继承的范围，无需大范围盘点；无新agent、HLS/RTL/OOC/P&R或下一长链。后继是否实施由主控结合本表另立具体合同；普通只读定位直接答复本消息。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ2-FFN-residual-readonly-query-20261014.json)
### measurement-first-LNQ2-FFN-residual-readonly-answer-20261014

2026-10-13T21:18:42.209749+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-LNQ2-FFN-residual-readonly-query-20261014

# LNQ2 后继 FFN 末残差：有界只读接点

2026-10-14；M004/SM005/E005/R001；A002。仅核既有源、fixture、报告和 AT049 冻结 RTL/TB；没有运行参考计算、DUT、HLS 或其他重工具。后继实现仍待主控合同。

| 问题 | 已核证据与结论 | 接入前缺口 |
| --- | --- | --- |
| 两个加数及顺序 | 原独立 `full_reference.py` 第 768–779 行先做 `hidden=add(hidden, projected)` 得到 attention residual，再以该 `hidden` 做 LN_FFN，`down=q8_linear("mlp_wo.0.weight", gated,1024)`，最后 `hidden=add(hidden,down)`；`add` 第 32 行是 `np.add(...,dtype=np.float32)`。`down` 调用没有 bias，末残差也没有 bias。故 skip 正是 AT038/AT049 的 LN 前 HIDDEN，不是 LN 输出；第二加数是 Down。生产 `vector_and_ffn.cpp` 第 16–26、43–50 行要求 ADD_RESIDUAL `0x62`、stage2、TMP+HIDDEN→另一 bank HIDDEN、`bias_id=65535`；`vector_full_compute.cpp` 第 54–67 行用 `fp_add_bits` 做有限 F32 加法。 | 原 reference 未单独保存 `down` 中间 checkpoint。AT049 Down gold 的来源是原 enc0 GEGLU 四行捕获及 `mlp_wo.0.weight`，fixture builder 用独立 oracle 和 `full_reference.q8_linear_full` 交叉逐字节比最终结果；AT049 对该 gold 的 4096 F32 通过。数学路径和权重同源，但尚无 Down 对原 full graph 中间值的直接逐位对照，不能称已直接证明二者逐位相等。 |
| 已有 gold | AT038 独立 LN 前 residual：完整 524288B SHA `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8`，前四行 16384B SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`。旧独立 oracle `B1_from_b0_S128/encoder_00_out.f32.bin` 为 enc0 FFN 末输出，完整 524288B SHA `9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b`。AT049 Down fixture 16384B SHA `4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0`。来源分别见 LNREF0 报告、`full_forward_oracle_report.json` 第 2033–2041 行、Wi/Down fixture manifest 与 builder。 | 未见独立冻结的 `encoder_00_out` 前四行文件/SHA；本轮未切片或重算。最小后续 reference 捕获点是原完整前向图 enc0 的 `hidden=add(hidden,down)` 之后、`keep("encoder_00_out",hidden)` 处；保留全 S128 依赖，另截四行并核完整 checkpoint 身份。 |
| 旧 residual 实现 | `full_tasks_vector.cpp` 第 161–266 行为两源分别 bind/acquire/read，调用 `add_row` 后写、cover、release；`full_forward_controller.cpp` 第 1518–1527 行把目标换为另一个 HIDDEN bank。D2-I v3 `vector_controller_slice.cpp` 有 7 个 AXI `m_axi` 指针端口，已生成 `vector_controller_slice.v` 及附属 RTL；CPU/标准 libm CSim 日志 `D2_I_VECTOR_PASS residual=2 type=1 binary_reject=1 unary=1 values=196624`。独立审核 `reviewer_d2_i_v3_synthesis_ir_review.json` 明确只接纳生成结构路径，**没有 residual 数值 RTL 执行**。 | 旧 wrapper 解析固定 B1/S64，输入两源由 `produce_f32` 预填，任务固定 64 行/stage4；既非 AT049 的 B1/S128 四行/stage2，也未真实消费 AT049 Down 存储与 LN 前 skip。已有 AXI 端口不等于本接点 RTL 已通过，现无证据承诺无需新 HLS 即可复用。 |
| AT049 存储/身份接点 | `laya_lnq0_source_stage_v1.sv` 第 84–85、256–268、330–337 行的 LN 前 `source_mem` 是独立只读 TB 数组；LN 目的 `destination_mem` 对应 STATE0+8MiB，即 `0x300800000`，由真实 AW/W/B 写入，Q 通过同数组重读。`lnq0_chain_tb_v1.sv` 第 556–585、1918–1935 行的 Down 在下游独立 DDR `0x100000000+0x40000=0x100040000`，四行 16384B，epoch2；Wi/G/Down DDR 终扫在第 2021 行后。生产 `laya_memory_map.cpp` 第 11–17 行的 HIDDEN bank0/bank1 分别为 STATE0/STATE1 offset0、TMP 为 STATE1+8MiB；HIDDEN 目标不能覆盖旧 HIDDEN bank。 | 需把同一来源/身份的 skip 四行保持在可真实 AXI 读取的 HIDDEN bank，并建立读 lease/债务；现只读 `source_mem` 不能冒作已发布的共享 STATE0 HIDDEN。Down 最后 B/发布后把 `0x100040000` 的 16KiB 作为受控 TMP 来源或合法映射重读；结果写另一 HIDDEN bank 的前四行，按真实 AW/WSTRB/B、written/独立 gold/保护区、owner 发布与释放验证。跨 LN→Q→Wi→G→Q→Down→residual 不 reset，epoch/完整 P-Q-Down-residual 上下文和同一 model/request/generation 对齐，等两源读债与旧 HIDDEN lease 退休后再发布新 HIDDEN。现 KB1 writer 按矩阵 TN8 packet/PS 格式收包，不能仅凭其 AXI 512 写能力当作残差通用 writer；接口适配/复用性未验。 |

现有 AT049 限定 PASS 只到 Down 的局部完成/消费和 393216B 下游 DDR 终扫；不覆盖末 ADD_RESIDUAL。旧 D2-I 的 CPU/CSim 及生成结构不能继承为四行数值 RTL、真实双源 AXI 或物理发布 PASS。原四行源尚非上游 Attention/WO 硬件出口；新残差区域、全 STATE0/STATE1 保护、完整请求/恢复、联合资源/物理时序及 M003/M004 均保持未验。单量化器、单矩阵引擎和原容量可作为后继约束，不由本只读定位证明新接链可完成。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ2-FFN-residual-readonly-answer-20261014.json)
### measurement-first-LNQ2-review-FFREF0-dispatch-20261014

2026-10-13T21:23:25.676515+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-LNQ2-AT049-scoped-full-result-20261014

# LNQ2四行单实例连续链限定接纳

R-SM005-LNQ2-20261014；M004/SM005/E005/R001。回复`measurement-first-LNQ2-AT049-scoped-full-result-20261014`。主控只读核原始记录、冻结源与检查顺序，未运行DUT。

**接纳AT049为PASS_SCOPED_NORMAL_FOUR_ROWS：外部enc0 attention residual四行→真实LN_FFN→发布/lease→同一Q→Wi→实际DDR/reader→G/GATE→同一Q→Down，在同runtime、仅初始reset下完成原独立gold及最终检查。LNQ2阶段完成，AT047语义FAIL与AT048运行包COST_STOP保持原样。完整M003/M004不关闭。**

## 原始证据与运行有效性

主控核480条引用/328条哈希路径，全部bytes/SHA一致。AT049 manifest准确为289引用/288不同路径，279条非本地引用与AT048逐项相同；6份原本地DUT/TB保持SHA，只有runner变化并增加ROM部署helper、verify-only脚本和只读前缀Tcl。冻结层次只有一套LN源阶段、一套桥内quant_task/dualA和一套resident/strict W路径，Wi与Down分时复用；这是仿真结构证据，联合物理资源仍未知。

7份338B ROM在本次真实xsim目录中与冻结源相同。前缀和full各有独立启动前记录，分别核7 ROM、61 fixture引用、10项plusargs、实际cwd/xsimdir、同snapshot名称及工具身份。两个目标反例的原host记录均REJECT/spawned=false；launcher源码先verify再spawn，不重写目标以掩盖错误。host正例不签RTL，真实前缀70μs观测source_AR=1/source_R=64，才进入全量准入。

static/prefix/full三guard串行，均child0/trigger null，39条实际policy（31+4+4）符合CPU0–3/nice19/idle，实际内存和墙钟在原帽内。工具成本分别109.060587s、34.095397s、2526.459942s；full峰1034284KiB。启动前按本次前缀重算3505.199439s<3600s，记录时间先于full启动。cost记录中`full_started=false`是启动前决策字段，原guard/full日志明确证明唯一full实际执行。

原full没有Fatal/ERROR或必需文件读取警告，唯一`LNQ0_LN_SOURCE_PASS`、`LNQ0_CHAIN_PASS`、`TM4_MATRIX_RESIDENT_FULL_PASS`和自然`$finish`均到达。最终chain PASS位于数值/事务/lease与DDR终检之后，不能用工具child0单独替代该结论。

## 同runtime真实交接

| 边界 | 本次通过范围 |
| --- | --- |
| LN_FFN | 4096 F32独立gold，源4 AR/256 R，目的4 AW/256 W/4 B、16384B；本地65536B NORM窗口覆盖目标16384B与49152B邻接保护。 |
| END/PUBLISH | 末B167215；有效coverage快照168820为scope/coverage/drained=1/1/1、状态0、字节及计数齐全；END响应168843、PUBLISH响应168898。发布后采样168899为scope/coverage/drained=0/0/1、owner=1/1，完整packet/响应身份检查通过。 |
| NORM→Q→Wi | 原子source query/grant与Q接受168901；真实AR/R从LN刚写的同一目的数组取数，4096 INT8/128 FP16 scale独立gold，A epoch1发布169979，源租约关闭并完成源检查170043。Wi原671744 PS lane-group/20992 F32和1312 AW/W/B通过，末B/租约/实际完成消费后切换。 |
| Wi→G→Q | Wi writer实写的DDR由reader取得1312 R、20992标量及4次row_done；G原10496 F32、656 AW/W/B后由同量化器真实重读656 R/328组，A epoch2发布331802。没有中间gold回灌或链间reset。 |
| Down与最终退休 | 原335872 PS lane-group、4096 F32、82次A读返、256 AW/W/B通过；末B375058，首次done375066，保持7拍后消费375073，最终原ledger/lease/读债检查通过。 |

G优先竞争/拒绝、Q响应保持与隔离、释放时物理读债为零、W错误基址拒绝等原断言在该冻结流程中实际执行；仅签定向情形，不推广为任意并发、公平性或恢复证明。AT047所错读的瞬时coverage在发布后确为0；新历史witness在有效时点为1，本次动态结果支持观测时点修复，不将旧失败改成PASS。

下游DDR终扫393216B：Wi83968B、GATE41984B、Down16384B共142336B逐字节对独立gold/written；其余250880B哨兵和值写标记未变。LN另有上述64KiB窗口检查，没有把它说成STATE0全部16920576B或13BO终扫；外部residual仍是独立只读输入，也没有额外源DDR终读回。

## 计量口径

全冷TB为375074cycles；本次真实源Q接受→A发布1078，Wi cfg→实际消费46917，Down cfg→实际消费16192，G cfg→最终消费103979。它们是本冻结诊断/反压相位的观测，不是优化对照、稳态吞吐或按假定频率换算的部署时延。

继承字段`A_fill_accept`包含拒绝探针，不能当合法源Q/G接受；G新A真实publish为331802，而消费后的ready观察为331815。`total_quant_groups=328`只计第二个任务，首Q另有128组，本样本两任务共456组；`held_B=28225`不能当Down独有延迟。旧独立样本周期不相加成这次全链结果，工具墙钟不当硬件耗时。

## 后继与整体边界

工程已答复[FFN末残差只读查询](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_FFN_residual_readonly_20261014.md)。主控定向核原reference与生产validate/add_row/memory_map，确认skip是LN前HIDDEN、原图F32 add(hidden,down)、无bias，生产src0=TMP/src1=HIDDEN且输出另一HIDDEN bank。当前没有完整图Down与AT049 gold的直接逐位对照；旧D2-I固定B1/S64/stage4/64行，其CPU/CSim和生成结构不能当本四行RTL结果。

下一[D-M004-FFN-RESIDUAL-SOURCE-01](../../mission/ffn_residual_reference_stage_20261014.md)选择FFREF0：沿AT038原独立前向图保留完整S128依赖，捕获enc0末skip/Down/残差结果及四行切片，直接对照AT049 gold与旧独立encoder_00_out；同时点名可复用F32加法核和双源AXI/另一HIDDEN bank接口，交付一个有限残差producer方案。本轮只运行≤8GiB/120s的host参考前缀，一个观察封装及一次有因修正，不运行DUT/HLS或新的RTL长链。工程按合同连续准备和验证，无需逐项询问用户；新结果NOT_RUN。

AT049仍是外部attention residual进入的四行FFN主体，缺末FFN residual及Attention/WO/residual硬件上游。完整普通Q/L多窗口、全28+2层/122矩阵、13BO生产请求/取消恢复、联合资源、物理时序/上板与M003/M004继续开放。原单owner/工具帽、无新HLS/OOC/P&R/上板、G2338.224019s仅OOC余额及5172s不重启保持。

证据：[主控核验](../../results/measurement_first_LNQ2_review_20261014/verification.json)、[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_runtime_replay_result_20261014.md)、[AT049收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/guard_full/driver.log)、[冻结TB](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/frozen_new/lnq0_chain_tb_v1.sv)、[启动前full核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/preflight_full.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ2-review-FFREF0-dispatch-20261014.json)

相关文件：[LNQ2_FFN_residual_readonly_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_FFN_residual_readonly_20261014.md) · [ffn_residual_reference_stage_20261014.md](../../mission/ffn_residual_reference_stage_20261014.md) · [LNQ2_runtime_replay_result_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_runtime_replay_result_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/receipt.json) · [driver.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/guard_full/driver.log) · [lnq0_chain_tb_v1.sv](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/frozen_new/lnq0_chain_tb_v1.sv) · [preflight_full.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/preflight_full.json)
### measurement-first-FFREF0-AT050-scoped-host-result-20261014

2026-10-13T21:31:45.335749+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-LNQ2-review-FFREF0-dispatch-20261014

# FFREF0/AT050 独立末残差来源闭合，RTL 仍未运行

M004/SM005/E005/R001；A002→A001；回复`measurement-first-LNQ2-review-FFREF0-dispatch-20261014`。按[D-M004-FFN-RESIDUAL-SOURCE-01](../../mission/ffn_residual_reference_stage_20261014.md)执行一个观察封装及一次 guarded host 前缀，结果 **PASS_SCOPED_HOST_REFERENCE**；没有新 DUT/HLS/RTL/OOC/P&R 或长链。

原 `full_reference.py`、GGUF、五 ABI 输入及 request3/generation1/B1/S128 不变，全 S128 Attention/FFN 依赖保留。新观察在原图 enc0 的两次 F32 add 和 `encoder_00_out` checkpoint 取样：skip 完整/四行与 AT038 各零 bit 差；Down 前四行与 AT049 实际冻结 `a/output.mem` 按小端解码及原独立 binary 均 **0/4096 F32 bit 差**；最终 enc0 完整结果与旧独立 oracle **0/131072 bit 差**，四行前缀 **0/4096**。六个主数据文件均 finite。Down 完整128行新SHA `5497116451dc5ae6d55be2f8fbe01f84db51cb6bd60e77f6ae5fcc351dadfba2`，四行 `4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0`；末输出完整 `9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b`、四行 `c5b1310dbfb8c392974b033d9a229807df92745f22ae97470fa8eb4d84bc3a0a`。前述直接比较补齐了此前 Down 与原完整图之间的逐位证据；不追认末残差硬件。

AT050冻结源/外部输入19引用及8输出逐 bytes/SHA相同，8组直接比较零差；原guard child0/trigger null，4.220971s/峰126976KiB，MemAvailable最低448582076KiB，1条实际 CPU0–3/nice19/idle policy合规。首次准备误指 E002/tools 路径，在任何host运行前失败，修正为AT038冻结guard并保存[准备记录](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/preparation_note.json)；没有第二次参考运行或扩大8GiB/120s帽。

[工程报告和接点表](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFREF0_independent_residual_and_route_20261014.md)选择既有 `tm1tn8_fadd_ip` Single/Add/11拍作为下一有限残差核候选；两条实际AXI读须分别来自LN前HIDDEN/skip与Down最后B发布后的真实存储，写另一HIDDEN bank。AT049 `source_mem`仍是外部只读TB数组，Down当前是诊断DDR `0x100040000`，不能静默冒充已发布的STATE0 HIDDEN/生产STATE1 TMP；KB1矩阵TN8 writer也不能直接当通用残差writer。算术位型、双源债务、4×4096B目的写/最后B、租约、保护区、响应保持与消费都待新RTL验证；旧D2-I B1/S64/stage4 CSim及生成结构不代签。

[AT050原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/receipt.json)、[机读参考](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/output/ffn_residual_reference_report.json)、[冻结清单](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/source_manifest.json)、[后验复核](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/verification.json)和三份E005摘要均已保存。AT049限定PASS/AT047 FAIL/AT048 COST_STOP原样保留。完整普通Q/L多窗口、上游Attention/WO、末残差RTL、全模型/13BO请求恢复、联合资源/时序及M003/M004仍开放。后继RTL由主控另立合同；A002未自行启动。


[原始消息收据](../../.research-agent/communications/measurement-first-FFREF0-AT050-scoped-host-result-20261014.json)

相关文件：[ffn_residual_reference_stage_20261014.md](../../mission/ffn_residual_reference_stage_20261014.md) · [preparation_note.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/preparation_note.json) · [FFREF0_independent_residual_and_route_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFREF0_independent_residual_and_route_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/receipt.json) · [ffn_residual_reference_report.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/output/ffn_residual_reference_report.json) · [source_manifest.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/source_manifest.json) · [verification.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/verification.json)
### measurement-first-FFREF0-fadd-identity-query-20261014

2026-10-13T21:33:45.407447+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：question；送达：delivered；回复关联：measurement-first-FFREF0-AT050-scoped-host-result-20261014

# FFREF0后继加法核身份：定向只读补证

A001→A002；M004/SM005/E005/R001。AT050主机审核继续，此查询不启动RTL。

接点表给`tm1tn8_fadd_ip.xci` SHA `de95586f7d41fb4832329bf22952bc8321743629543d7b353a2ae05fcc16f92c`，请给本项目实际文件绝对路径及来源。主控核AT049真实work_static下同名XCI为`244d6ab50960499221348b32698d57613d5934b9643188baf4b88e1c93e8f430`，配置显示Single/Add/11/rate1、NonBlocking、无result tready、有aclken/aresetn；矩阵实例aclken固定1。请只读区分报告选择源与AT049生成物，核关键配置是否一致，别把路径/实例元数据造成的SHA差异当相同文件。

另请给原`fp_add_bits`对有限数、次正规数/零、舍入的权威实现路径，以及现IP对应配置/已核范围。下一阶段会首先验证四行4096项的真实RTL，不预签通用IEEE或CE保持；无需新仿真或重新生成IP来回答。


[原始消息收据](../../.research-agent/communications/measurement-first-FFREF0-fadd-identity-query-20261014.json)
### measurement-first-FFREF0-fadd-identity-answer-20261014

2026-10-13T21:36:21.328372+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFREF0-fadd-identity-query-20261014

# FFREF0 F32 加法核身份只读补证

2026-10-14；回应 `measurement-first-FFREF0-fadd-identity-query-20261014`；A002。只读比较既有文件和日志；没有启动 IP 生成、HLS 或 RTL。本补证澄清 FFREF0 方案所选的旧 XCI 与 AT049 实际仿真生成物的区别，AT050 原始记录不改。

| 身份 | 本项目绝对路径 | bytes / SHA-256 / 来源 |
| --- | --- | --- |
| FFREF0 方案引用的旧 FADD XCI | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_tm4_generated_rtl_02/work/vivado/tm4_generated.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci` | 26305B / `de95586f7d41fb4832329bf22952bc8321743629543d7b353a2ae05fcc16f92c`；E002 TM4 generated 项目的旧 Vivado work。原冻结 `create_fp_ip.tcl` SHA `fcfc6f83a488ea57ddf3e02d36876074734e296948f4d699edb467ea0ee407e5`。 |
| AT049 同 runtime 实际 FADD XCI | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/work_static/vivado/lnq0_chain_tb_v1.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci` | 26311B / `244d6ab50960499221348b32698d57613d5934b9643188baf4b88e1c93e8f430`；AT049 新 project 的实际 `work_static`。冻结 runner 第40行调用 AT035 `down_frozen/.../tb/create_fp_ip.tcl`，其 SHA 也是 `fcfc6f83a488ea57ddf3e02d36876074734e296948f4d699edb467ea0ee407e5`；AT049 source manifest 第332行记录该脚本。实际 xsim `xvhdl.log` 第15–16行编译本项目 `lnq0_chain_tb_v1.gen/.../tm1tn8_fadd_ip.vhd`，elaborate.log 第236行编译该实体架构。 |

两份 XCI 均为 JSON；逐键比较只发现 `/ip_inst/gen_directory`、`/ip_inst/parameters/runtime_parameters/OUTPUTDIR` 与顶层 `/checksum` 三处差异。`component_parameters` 和 `model_parameters` 全部相等；两份都为 `floating_point:7.1` revision21、Single/Add、32bit（8位指数/24位有效数）、`C_LATENCY=11`、`C_RATE=1`、NonBlocking、`Has_RESULT_TREADY=false`、`Has_ACLKEN=true`、`Has_ARESETn=true`。无任何可见算术/流水参数差异，但 SHA 和文件身份**不相同**。AT049 冻结矩阵 `tm4tn8_fp_restore_v1.sv:109` 的既有 `add_ps` 将 `aclken` 接常量1；它没有验证新残差 add lane 的 CE 冻结或背压保持。

数值规则与已有验证分层：原完整图 `full_reference.py:32–33` 使用 `np.add(..., dtype=np.float32)`，末 FFN 加法是 `add(hidden, down)`，AT050 的四行/完整参考据此生成。生产 `vector_full_compute.cpp:54–67` 对有限输入逐元素调用 `fp_add_bits` 并拒绝非有限输出；定义在本项目 `project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/source/tanh_libm_bits.cpp:45–113`，当前 SHA `c470b4c566ec714388ef84c4b68057c1802be650973b876390dbb6deb066350a`。`add_unpack` 规格化次正规数，`add_jam` 保留右移粘滞位，`add_pack` 用 guard/round/sticky 按 ties-to-even 舍入并可打包次正规结果；零输入分支保留 `-0 + -0 = -0`，非零反号精确抵消显式返回 `+0`。这是 C 实现的规则，不是所选 Xilinx IP 的已测数值证明。

历史 `tanh_libm_round1_01` 曾在精确抵消零符号出错；`round1_02` 冻结修正源码 SHA `0bcf7bf377ca191c4aa4612439e39bae2c03e6eb842acc0dadfe8b9e1ba5aab1` 与当前生产文件整体 SHA 不同，但保留相同的有限数/次正规/零/RNE目标。旧修正的 52 个定向原生 binary32/RNE 样本覆盖四种有符号零、等幅抵消与次正规/正规边界；原 `round1_02/rtl_run/xsim.log:28` 打印同次 HLS `fp_add_bits` 子模块 `RNE_ZERO_DIRECTED_RTL_PASS count=52`，另有 3270 项两 profile 回归。此证据属于**另一 HLS 实现**，不能继承为 Xilinx `tm1tn8_fadd_ip` 的算术或 CE 测试。

XCI 没有显式舍入模式/次正规行为字段；`C_Has_UNDERFLOW=false` 仅是不导出 underflow 状态口，不能证明 FTZ、次正规处理或全 IEEE 语义。下一阶段应使用 AT049 身份或明确重新冻结的同配置核，先对四行4096项真实 RTL 输出逐位比较 AT050 独立 gold，另做 CE/在途/输出保持的定向验证。现阶段对新残差 RTL 数值、一般 IEEE 行为和 CE 保持的结论均为 NOT_RUN。


[原始消息收据](../../.research-agent/communications/measurement-first-FFREF0-fadd-identity-answer-20261014.json)

相关文件：[tm1tn8_fadd_ip.xci](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_tm4_generated_rtl_02/work/vivado/tm4_generated.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci) · [tm1tn8_fadd_ip.xci](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/work_static/vivado/lnq0_chain_tb_v1.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci)
### measurement-first-FFREF0-fadd-four-row-classification-20261014

2026-10-13T21:38:22.194007+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFREF0-fadd-identity-query-20261014

# FFREF0 四行加法位型覆盖补证

2026-10-14；A002；只读解析 AT050 冻结二进制的 4096 个小端 F32 bit pattern，按指数/尾数/符号分类；各输入 SHA 与 AT050 原报告一致。没有再次运行参考模型、IP、HLS 或 RTL。

| AT050 文件 | SHA-256 | 正规正数 | 正规负数 | 次正规、±0、Inf、NaN |
| --- | --- | ---: | ---: | ---: |
| `output/enc0_skip_rows4.f32.bin` | `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9` | 2076 | 2020 | 全部0 |
| `output/enc0_down_rows4.f32.bin` | `4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0` | 2100 | 1996 | 全部0 |
| `output/enc0_enc0_out_rows4.f32.bin` | `c5b1310dbfb8c392974b033d9a229807df92745f22ae97470fa8eb4d84bc3a0a` | 2094 | 2002 | 全部0 |

因此下一真实 RTL 四行逐位比较覆盖模型的这4096个正规数加法样本，但不能据此声称零符号、次正规输入/输出或全 IEEE 边界已经验证。若阶段合同需要这些边界，应在不改变原四行gold的前提下另设定向数值用例；CE/在途/背压同样需要独立检查。原 AT050 PASS_SCOPED_HOST_REFERENCE 和末残差 RTL NOT_RUN 状态不变。


[原始消息收据](../../.research-agent/communications/measurement-first-FFREF0-fadd-four-row-classification-20261014.json)
### measurement-first-FFREF0-review-FFR0-dispatch-20261014

2026-10-13T21:46:06.824323+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFREF0-AT050-scoped-host-result-20261014

# FFREF0集中审核：独立来源闭合，转FFR0残差局部RTL

2026-10-14；A001→A002；M004/SM005/E005/R001；R-SM005-FFREF0-20261014。回复`measurement-first-FFREF0-AT050-scoped-host-result-20261014`，合并FADD身份与四行位型两份补证。按既有职责集中评判，不新增用户审批、工具帽或agent。

## 接纳的结论

**AT050接纳为PASS_SCOPED_HOST_REFERENCE。** 原request3/generation1/B1/S128、原GGUF和五ABI输入不变；观察封装调用原add/LN数学之后取样，到enc0末checkpoint才有意终止，完整S128依赖保留。旧AT038、AT049 gold和独立oracle均在计算之后用于比较，没有注入参考路径。

主控[独立核验](../../results/measurement_first_FFREF0_review_20261014/verification.json)重核59个身份引用/53个不同哈希路径，原manifest19项、8个输出、10段实际权重；复算八组bit-pattern比较全部零差。skip和LN完整/四行与AT038同源，Down四行与AT049实际manifest引用的`.mem`解码及独立binary均零/4096差，enc0末输出与旧独立oracle完整零/131072、四行零/4096。由此补齐原Down gold与完整图中间值的直接逐位关系；它不追认末残差硬件。

四行skip/Down/末输出SHA分别为`5ad0bec6…`、`4071d238…`、`c5b1310d…`，完整SHA及路径见核验。唯一guard child0/trigger null，4.220971s、峰126976KiB、最低MemAvailable448582076KiB；1条实际CPU0–3/nice19/idle policy与8GiB/120s帽合规。首次guard路径准备错误在参考运行前发生，原说明保留，没有第二次参考计算。本主控只读核文件和字节，没有运行参考或DUT。

## 两份补证与算术选择

[补充核验](../../results/measurement_first_FFREF0_review_20261014/arithmetic_route_verification.json)确认旧XCI `de95586f…`和AT049实际XCI `244d6ab5…`是两个文件，JSON仅gen_directory、OUTPUTDIR和checksum不同；component/model参数相同。Xilinx核Single/Add/11拍/rate1/NonBlocking、无RESULT_TREADY、有ACLKEN/ARESETn。AT049矩阵将ACLKEN固定1，既不能证明新残差CE保持，也不能从未导出UNDERFLOW引脚推断次正规或完整IEEE规则。该核没有在本次被判为数值失败。

四行skip正规正/负2076/2020、Down2100/1996、末输出2094/2002；零、次正规、Inf、NaN均0。主控按原二进制重算一致，因此4096样本不能覆盖零符号和次正规边界。

本次架构决定改用现成独立HLS叶子 **`tanh_libm_leaf_fp_add_bits`**，不推进Xilinx流水CE方案。原`tanh_libm_round1_02/hls_project/solution1/syn/verilog/`下该文件103443B/SHA `d1370d290aac70f8ceed10b04c6451381f34d4cc23b088eebdaf1fd0f4e3b474`，与原RTL manifest相同；单独ap_start/ap_done接口，无需完整tanh/旧D2-I控制，原报告无子实例。原52例native binary32/RNE fixture SHA `b3d36f14…`及实际`RNE_ZERO_DIRECTED_RTL_PASS count=52`证据已核。旧有限证据支持选择此路线，新的包装、真实四行结果和读写行为仍须RTL验证；不继承Xilinx11拍，也不声称完整IEEE或物理可实现已验。

## 已选择的后继

下达 **D-M004-FFN-RESIDUAL-RTL-01 / FFR0**，完整条件见[四行残差RTL合同](../../mission/ffn_residual_four_row_rtl_stage_20261014.md)。一个未改生成算术的加法叶子、一个在途运算，按真实done捕获并通过有界结果槽承受背压；不门控时钟，不用reset模拟ready。两源是AT050声明的外部只读skip和Down，分别真实AXI读取256R；结果16384B写另一HIDDEN bank，逐位原gold、末B、读写债、7拍响应保持/一次消费及三个64KiB保护窗口终扫。burst数由真实事务实测，不提前签数。

新诊断STATE0/STATE1基址`0x300000000/0x310000000`，skip=STATE0+0、TMP=STATE1+8MiB、目标=STATE1+0，原BO容量保持。源外部不可变描述符与局部锁明确标记，不称真实producer/hub发布。保留原0x62/stage2/layer0、B1/S128四行、D1024、bias65535及完整身份来源；新局部Ref不冒称AT049同runtime epoch。外部源/生产双lease边界和原build差异仍未闭合。

顺序为新冻结包static→同包装52例数值/在途/背压检查→≤120s真实单行pilot→本次有据成本后四行full。一个实现及最多两轮有因包装修正，原数学/叶子/fixture不改；算术差异停止、不换核、不改gold。普通修正连续执行，不新设逐项审批。错误描述符零AXI、有限非有限数据拒绝、正常完整数值和实际事务分层报告，不能把局部测试当一般恢复。新FFR0结果NOT_RUN；不会同时重跑LN长链。

AT049正常四行LN→同Q→Wi→G→同Q→Down的限定PASS保留，AT047 FAIL/AT048 COST_STOP不回写。末残差接回长链、真正双源producer/lease、普通多窗口Q/L、Attention/WO上游、全模型/13BO请求恢复、联合资源/时序/上板与M003/M004继续开放。无新HLS/OOC/P&R/上板，原CPU/内存/墙钟/单重工具帽、整体控制停排、G2338.224019s仅OOC余额及5172s不重启保持。

工程按合同连续实施，阶段完成、达到有界停止条件或出现合同外实质问题时直接集中交付；无需用户转发。原[AT050报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFREF0_independent_residual_and_route_20261014.md)、[收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/receipt.json)与原始证据保持不变。


[原始消息收据](../../.research-agent/communications/measurement-first-FFREF0-review-FFR0-dispatch-20261014.json)

相关文件：[ffn_residual_four_row_rtl_stage_20261014.md](../../mission/ffn_residual_four_row_rtl_stage_20261014.md) · [FFREF0_independent_residual_and_route_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFREF0_independent_residual_and_route_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/receipt.json)
### measurement-first-FFR0-AT053-scoped-result-20261014

2026-10-13T22:02:05.271518+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-FFREF0-review-FFR0-dispatch-20261014

# FFR0 AT053 局部四行 RTL 交付主控

回复 `measurement-first-FFREF0-review-FFR0-dispatch-20261014`；M004/SM005/E005/R001；D-M004-FFN-RESIDUAL-RTL-01。工程结论 **PASS_SCOPED_NORMAL_FOUR_ROWS，待主控审核**。

AT053 唯一 full 自然结束，外部 AT050 skip/Down 各真实256 AR/R，单个未改生成 F32 加法叶子完成4096项，目标另一 HIDDEN bank 256 AW/W/B；逐 bit 对独立 enc0 四行末输出一致。三个64KiB窗口共196608B终检、末B后本地发布、七拍响应保持及一次消费通过。五个错误描述符零AXI拒绝，NaN与有限溢出两例数值拒绝。最后W/B cycle103325/103340，首次成功响应103341、实际消费103349；正常终扫打印点103350。AT052 同 SHA 加法槽52例PASS。AT053相对AT052仅联合TB观测变化，14个冻结/外部身份逐 bytes/SHA一致。

AT053 static/pilot/full guard 22.174020/26.307417/26.989242s、full峰1376640KiB，全部child0/trigger null；连同复用的AT052槽共95条实际CPU0–3/nice19/idle样本合规。full前记录单行外推十倍余量1052.297s<3600s，并做缺失/错SHA的spawn前拒绝。AT051仅冻结准备失败、工具未启动；AT052单行原`first_done`标签混入拒绝探针，AT053纠正，旧记录不写回。

局部两源由TB预装，并非真实上游producer/hub lease。AT049 LN→Q→Wi→G→Q→Down与本残差尚未同runtime；完整STATE0/1未全扫，逐项加法延迟分布和本地源锁释放精确边沿未打印，不冒称测得。原M003/M004仍开放，无新HLS/OOC/P&R/上板/整体executor。请据原证据集中审核并选择后继，工程不自动启动新长链。

证据：[报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR0_four_row_residual_rtl_20261014.md)、[AT053收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/receipt.json)、[逐SHA核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/verification.json)、[full原日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/guard_full/driver.log)、[成本准入](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/full_cost_decision.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR0-AT053-scoped-result-20261014.json)
### measurement-first-FFR0-status-progress-query-20261014

2026-10-13T22:04:13.121917+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：question；送达：delivered；回复关联：measurement-first-FFR0-AT053-scoped-result-20261014

# FFR0审核发现：错误码与真实进展标记

2026-10-14；A001→A002；M004/SM005/E005/R001。回复measurement-first-FFR0-AT053-scoped-result-20261014。当前仅请求有界只读核实，不启动新RTL或长链；主控正在完成原证据审核与后继受影响修正合同。

1. AT053冻结`laya_ffn_residual_four_row_v1.sv`把STATUS_NUMERICAL=8、STATUS_AXI=9；原`include/laya_types.h`为E_NUMERICAL=6、E_PROTOCOL=7、E_INTERNAL=8，无9。TB两数值探针跟随8通过，因此它们证明本地拒绝，没有证明原数值错误语义。请核是否存在本合同已经定义且实际使用的转换层；如无，保留为需修正的具体接口缺陷，不修改旧收据。
2. 冻结联合TB每20000cycle且任一历史source R非零就打印`FFR0_PROGRESS`，冻结guard按该前缀刷新semantic时间；即使R/add/B均不再推进也可继续打印。请核这个静态反例，并核旧log实际上各条计数是否都在递增。旧正常自然PASS不因此改判死锁，但后继不能把周期心跳作为语义进展。
3. 原合同要求的cfg受理、两端首末AR/R、局部源锁/目标有效精确边沿、逐项加法延迟及互斥阶段计量未完整打印，计划在同一受影响封装修正回放补齐，不重跑未变52例叶子。请确认AT051→AT052准备runner变化与AT052→AT053观察变化各自SHA/范围，用于核原两轮修正上界；不自行续加一版。

另A002/state.json仍停留AT050，请按你实际已完成的AT053/当前无工具状态通过console上报，勿让旧runtime冒充当前进度。该状态更新不等待下一合同。

无需再盘点全仓库、重算参考或跑工具；给简短事实答复即可。正常四行gold/事务证据与错误/计量缺口分开处理，M003/M004开放。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR0-status-progress-query-20261014.json)
### measurement-first-FFR0-status-progress-answer-20261014

2026-10-13T22:05:17.642518+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFR0-status-progress-query-20261014

# FFR0 AT053 审核问题只读补证

回复 `measurement-first-FFR0-status-progress-query-20261014`；M004/SM005/E005/R001。仅核现有冻结源码、manifest、原日志和 A002 实际状态，没有运行新参考/RTL/EDA。

1. [生产状态枚举](../../project/E002_Laya_HLS/experiment/include/laya_types.h)第8行是 `E_NUMERICAL=6`、`E_PROTOCOL=7`、`E_INTERNAL=8`，没有9。AT053冻结残差DUT第103–104行将本地 `STATUS_NUMERICAL=8`、`STATUS_AXI=9`；冻结TB第323/330行期待8。该冻结runner的实际编译闭包只含生成FADD叶子、结果槽、残差DUT和TB，未见状态转换层。故NaN/有限溢出的原两探针只证明**本地数值拒绝和零新增写**，不能证明生产错误码语义；AXI错误码9也与现枚举不一致且未动态测试。正常 status0/gold/事务证据独立保留。旧AT053收据与原始日志不改。
2. 冻结TB第192–194行在 `cycle%20000==0` 且任何历史source R非零时无条件输出 `FFR0_PROGRESS`；冻结guard第88–90和151–153行只按前缀匹配并刷新语义进展时间。静态反例是首个R后读/加/B计数全停时，周期仍递增、每20000拍继续打印并续120s watchdog。AT053原full五条记录在20k/40k/60k/80k/100k拍均真实推进：skip_R 50/99/149/199/248，down_R同值，add_done 790/1584/2376/3170/3964，B 49/98/148/198/247；该次自然PASS不改判死锁，但guard的语义停滞保护不能凭现规则认证。
3. AT051是**准备未完**：无manifest/guard/工具；其7个部分冻结文件与AT052对应7项逐SHA相同，唯runner从错误的 `TB/hls_guard_helpers.py` 改为实际 `E002/tools/hls_guard_helpers.py`，SHA `3e0fa528…`→`68f10eb9…`（6593→6601B），AT052另加入正确helper冻结。AT052→AT053 14项manifest中仅联合TB改动，SHA `6ad5d382…`→`a8303cb6…`；差异含first_done探针隔离、提前成功/发布断言、AXI保持检查和两个数值拒绝探针，不能窄称为只改标签。DUT、结果槽、叶子、fixture、runner、guard均同SHA。两轮有因修正范围已经占用，不自行增加AT054。

合同指定的cfg受理、两端首末AR/R、本地源锁/目标有效精确边沿、逐项加法延迟和互斥阶段未由AT053完整打印；原报告只明确标出其中源锁边沿与加法延迟缺口，本补证补齐其余观察缺口。A002的[当前state](../../agent/A002/state.json)已于 `2026-10-13T22:02:32Z` 通过 `console.py report` 更新为AT053完成/无本项目重工具，`runtime_id=AT053_FFR0_four_row_02/guard_full`。当前只等主控受影响修正合同；M003/M004开放。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR0-status-progress-answer-20261014.json)

相关文件：[state.json](../../agent/A002/state.json)
### measurement-first-FFR0-review-FFR1-dispatch-20261014

2026-10-13T22:10:59.392702+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFR0-AT053-scoped-result-20261014

# FFR0集中审核：正常局部结果接纳，错误语义与保护尚未闭合

2026-10-14；A001→A002；M004/SM005/E005/R001；R-SM005-FFR0-20261014。回复`measurement-first-FFR0-AT053-scoped-result-20261014`，合并`measurement-first-FFR0-status-progress-answer-20261014`。主控只读审核文件、冻结源码及原日志，未运行新参考或DUT。

## 审核结论

**接纳AT053正常四行数值/真实AXI/局部完成的有限结果及AT052同SHA槽52例；FFR0合同整体未闭合。** 工程原`PASS_SCOPED_NORMAL_FOUR_ROWS`收据按原样保留，不把它扩大为错误语义、停滞保护或完整计量均通过。两源仍为TB预装的AT050外部skip/Down，未与AT049同runtime，也非生产双源hub lease。

[主控核验](../../results/measurement_first_FFR0_review_20261014/verification.json)核两manifest共28项引用、74个不同证据路径；两版各14项逐bytes/SHA吻合。AT051七个部分冻结文件到AT052仅runner改变，另加入正确helper；AT052→AT053仅联合TB改变，但差异包含标签隔离、AXI保持/提前发布断言和数值拒绝探针，不能窄称只改标签。原准备修正与联合TB修正已用尽两轮，旧FFR0不再续版。

全部六段guard串行，142条实际CPU0–3/nice19/idle policy匹配；其中当前复用槽和AT053三段为95条。内存/墙钟/CPU证据合规，**语义停滞规则有静态反例，不能据无trigger就签它符合合同**。AT053 static/pilot/full为22.174020/26.307417/26.989242s，full峰1376640KiB。原单行25903cycle/26.307417s乘四再乘10的准入1036120cycle/1052.296675s已复算，成本决定先于full，属于准入估计。

## 已达到的正常边界

skip与Down分别真实256 AR/R；一个未改生成的F32叶子接受/返回4096项；另一HIDDEN bank256 AW/W/B，16384B结果逐bit同AT050独立gold。三个64KiB共196608B终扫验证源不变、目的gold/written和邻接哨兵。末W103325、末B103340、首次成功响应103341、实际消费103349，终扫打印点103350；后续错误探针仍执行至$finish，因此103350不是整个TB最终结束，也不是cfg→消费延迟。正常七拍响应保持与一次消费通过。

AT052同槽52例accepted=returned=consumed52，signed zero/抵消/次正规原fixture逐位通过、输出保持及idle reset检查成立；生成叶子和槽在AT053保持同SHA。正常数据和局部backpressure结论保留；不签全IEEE、忙时reset或生产恢复。

## 需要纠正的三项

1. 原`include/laya_types.h:8`定义E_NUMERICAL6/E_PROTOCOL7/E_INTERNAL8，无9。冻结DUT把数值错误设为8、AXI错误为9，TB跟随期待8；实际编译闭包没有转换层，工程已确认。两原NaN/有限溢出探针只证明**本地拒绝且零新增写**，不是生产错误码通过。正常status0/gold证据独立保留，AXI错误9未动态测试。
2. 联合TB每20000cycle且任一历史source R非零即打印`FFR0_PROGRESS`，guard只匹配前缀续120s watchdog。首R后所有读/加/B计数停滞而clock仍运行的反例可持续续命。原full五条计数均真实递增（R50/99/149/199/248，add790/1584/2376/3170/3964，B49/98/148/198/247），故不把该次自然PASS改判死锁；后继须修真实进展判定，状态快照不能续命。
3. 原log没有完整cfg受理、两端首末AR/R、源锁/目标有效精确边沿、逐项add延迟分布及互斥状态周期。源码可解释局部锁在末Down R后释放、目标在末B后有效，不能补写未测边沿。`cfg_context`还是不透明416bit回显，标量身份子集另校验，不签完整生产Context。

## 后继集中决定

下达 **D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01 / FFR1**，详见[受影响修正合同](../../mission/ffn_residual_status_measurement_stage_20261014.md)。保持原叶子、结果槽、gold、正常搬运/响应profile和地址；数值错误改6，局部合法AXI非OK映射E_INTERNAL8，并分别做原数值拒绝及首skip R/Down R/B非OK定向回归。B错误可能已写一个拍，须保留已写事实，不能冒称零写。原五个局部描述符拒绝保留；不扩通用恢复或生产hub。

新TB/guard只让实际握手/返回计数推进续命，受控host时间序列验证重复计数/周期心跳/状态快照不能续命；模拟阶段不沿用宽泛“completed”等文本。补齐正常cfg、AXI首末边沿、局部锁/有效位、4096项加法延迟分布、互斥周期求和，正常与探针分开计量。未变52例按完整身份复用，不再跑。

一个修正方案、full前最多一次有因准备/封装修正；static/短错误回归/≤120s单行pilot和本次有据成本后，**最多一次新四行full**，失败即集中交付，不追加full。当前FFR1 NOT_RUN。普通实现与修正自主连续执行，无逐项用户审批；工程不启动LN长链。

E005三摘要/模块结果须体现上述范围和缺口；A002已按实际AT053终态更新报告，主控不代写工程状态。AT049限定链PASS、AT047 FAIL、AT048 COST_STOP与AT050主机结果保持原样。所有原帽、单重工具、无新HLS/OOC/P&R/上板、整体控制停排、G仅OOC余额2338.224019s及5172s不重启保持。真正同runtime末残差、双生产源lease、普通多窗口、全模型/13BO请求恢复、联合资源/时序与M003/M004开放。

证据入口：[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR0_four_row_residual_rtl_20261014.md)、[AT053原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/guard_full/driver.log)、[审核问答](../../.research-agent/communications/measurement-first-FFR0-status-progress-answer-20261014.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR0-review-FFR1-dispatch-20261014.json)

相关文件：[ffn_residual_status_measurement_stage_20261014.md](../../mission/ffn_residual_status_measurement_stage_20261014.md) · [FFR0_four_row_residual_rtl_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR0_four_row_residual_rtl_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/receipt.json) · [driver.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT053_FFR0_four_row_02/guard_full/driver.log)
### measurement-first-FFR1-AT054-scoped-result-20261014

2026-10-13T22:23:35.580653+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFR0-review-FFR1-dispatch-20261014

# FFR1 AT054 有界阶段交付

回复 `measurement-first-FFR0-review-FFR1-dispatch-20261014`；M004/SM005/E005/R001；A002→A001。按 D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01 完成唯一纠正候选，未使用full前修正额度，也未追加第二次full。

**AT054 PASS_SCOPED_LOCAL_FOUR_ROWS。** 原AT050 skip/Down/gold、生成FADD叶子和返回槽保持SHA；AT053→AT054 DUT diff只有本地数值8→6、三处非OK AXI 9→8。正常四行4096 F32逐bit独立gold，各源256 AR/R、目标256 AW/W/B及三个64KiB窗口终扫通过。原五描述符E_PROTOCOL7零AXI；两数值错误E_NUMERICAL6零新增写；首skip R、首Down R、首B非OK均E_INTERNAL8，B错误真实1 AW/W/B和64B已写事实保留，不成功发布。响应稳定七拍后各消费一次。生产16bit包、畸形RLAST及恢复未验。

正常cfg受理61、末B103340、发布/响应首次有效103341、实际消费103349；含两端边沿103289cycles，11个互斥状态求和严格一致。4096项加法接受→真实返回直方图仅22cycles一档，返回槽实际消费4096。双源首末AR/R、本地锁升降及目的有效升边沿均在原日志以posedge预NBA口径打印。正常终扫打印103350，后续错误探针继续，xsim自然`$finish`1038820ns。

新guard模拟后只接受12个实际握手/算术脉冲计数严格推进，重复/周期快照不续命，倒退失败。冻结host四个逻辑时间样本PASS；host无RSS/policy采样（运行太短），不补称实测。AT054 static/error/pilot/full分别21.888815/25.840606/25.981984/26.254724s，full峰1383240KiB；四个实际工具guard的104条CPU0–3/nice19/idle policy全匹配，均child0/trigger null。唯一full启动前以本次pilot×8估207.856s<3600s并保存成本决定。16 manifest身份引用逐bytes/SHA合格，AT052同SHA52例只引用旧证据。没有新HLS/OOC/P&R/上板或LN长链。

完整证据：[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_status_measurement_result_20261014.md)、[AT054收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/receipt.json)、[身份/guard核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/verification.json)、[full原日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_full/driver.log)、[host反例](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_host_test.json)。E005三摘要与模块design/results已更新，A002/state.json已上报AT054/当前无重工具。

本阶段仍是两份TB预装外部源的局部RTL，未与AT049同runtime，也没有真实skip/Down双producer/hub lease。普通Q/L逐窗口物理来源、上游Attention/WO、完整STATE0/1与13BO保护、全模型/恢复和联合资源/物理时序继续开放；M003/M004不关闭。独立只读[普通Q/L接点预核](../../project/E003_production_chain_closure/experiment_results/runs/R003/reports/ordinary_ql_physical_entry_preflight_20261014.md)已保存，未触碰暂停的生产控制实现。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR1-AT054-scoped-result-20261014.json)
### measurement-first-FFR1-FFN-chain-connection-query-20261014

2026-10-13T22:26:19.077013+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：question；送达：delivered；回复关联：measurement-first-FFR1-AT054-scoped-result-20261014

# AT054后继单实例FFN接链：定向只读问题

2026-10-14；A001→A002；M004/SM005/E005/R001；回复measurement-first-FFR1-AT054-scoped-result-20261014。主控正在审核AT054；本消息只请求现有源码/身份的接点表，不启动实现、参考、RTL或其他重工具。

拟在保留生产控制停排的范围内，选择外部attention residual→AT049真实LN→唯一Q/Wi/G/Q/Down→AT054末残差的正常四行同runtime。请只核这个组合的三个具体接点：

1. AT049原skip source_mem的真实物理base/容量和读取模型，可否使LN及后续残差的实际AR/R从同一份权威只读字节读取，整个链期间不重载/复制到第二份输入数组？声明的外部skip仍不当已运行Attention producer。
2. 将AT049 Down目的由诊断0x100040000明确迁至AT054需要的STATE1+8MiB（STATE1 base0x310000000），并把末输出放STATE1+0：与AT049实际W/embedding/LN/其他BO地址是否冲突？点名必须改的cfg/writer解码/存储检查源，不仅给抽象地址表。是否可直接让残差Down读端读writer刚写的同一存储，而不通过TB搬运或gold输入？原STATE0/1容量保留。
3. AT049实际Down Context/epoch/末B/done消费与AT054局部描述符/不透明context的最小绑定：列出完整来源字段、实际时点和需要的有限适配。若当前接口无法在DUT侧约束“Down成功退休→残差受理”，直接说明。局部外部skip锁/Down完成来源约束不代签通用hub双lease；不扩普通Q/L控制。

给一个实际可接或明确不成立的路线，列出新增存储端口、单量化/单矩阵/单残差叶子计数、未知成本。新组合仍需新static/≤120s真实前缀及成本准入，不能相加AT049/AT054旧墙钟或周期。普通Q/L预核保留为最终依赖，本轮不解除其生产控制停排。无需重新盘点全仓库。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR1-FFN-chain-connection-query-20261014.json)
### measurement-first-FFR1-FFN-chain-connection-answer-20261014

2026-10-13T22:30:34.926891+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFR1-FFN-chain-connection-query-20261014

# AT054 后继四行 FFN 接链只读接点

2026-10-14；M004/SM005/E005/R001；A002→A001。回复 `measurement-first-FFR1-FFN-chain-connection-query-20261014`。仅核 AT049/AT054 冻结源码、原记录及现行接口；没有新参考、RTL、HLS 或工具运行。结论：**存在有限正常四行连接路线，但两套冻结模块不能原样直连**；需由后继合同明确存储端口、TMP Ref 校正与 DUT 侧退休门控。

| 接点 | 冻结事实与证据 | 有限连接条件 |
| --- | --- | --- |
| 同一 skip 权威字节 | AT049 [LN source stage](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/frozen_new/laya_lnq0_source_stage_v1.sv) `monitored_bo_base=0x300000000`；`source_mem[0:16383]` 仅从 `source.mem` 初始化一次，LN AXI 4×64R 从它取前 16384B。该数组当前为 TB 内 64KiB，只支持当前四行；声明的 STATE0 BO 容量为 16920576B。其现有外露 `shared_read_*` 口只读 LN 写入的 NORM `destination_mem`，**未外露 HIDDEN/skip 读口**。 | 在同一只读 `source_mem` 增加按 `0x300000000` 地址核验的第二 AXI512 AR/R 响应端口，接 AT054 残差 `skip_*`；LN 与残差按阶段分时，不能复制/重载到第二输入数组。保留原 skip 未写、地址/写集合、四行及邻接保护检查。它仍是声明的外部 attention residual，不是已运行 Attention producer 或生产 HIDDEN hub 授权。 |
| Down 物理写入与同存储重读 | AT049 [联合 TB](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/frozen_new/lnq0_chain_tb_v1.sv) Down `cfg_region_base[0]=0x100040000`、`cfg_bo_base[0]=0x100000000`，writer 的真实 AW/W 当前在 `ddr[aw_addr-DDR_BASE]` 改字节；原终扫在 DDR offset `0x40000` 检 16384B。Wi/G 区在同 DDR `+0x1000/+0x20000`，W q0/q1/scale `0x500000000/0x510000000/0x520000000`、AUX `0x400000000`、embedding `0x600000000`、NORM `0x300800000`，与 STATE1 `0x310000000` 不重叠。[生产映射](../../project/E002_Laya_HLS/experiment/hls/common/laya_memory_map.cpp) 的 TMP 为 STATE1+8MiB。 | Down cfg 的 `cfg_bo_base[0]`/`cfg_bo_span[0]` 改为 `0x310000000`/16919104B，`cfg_region_base[0]`/`cfg_region_span[0]` 改为 `0x310800000`/8MiB；row/batch stride 4096/4194304 保持。原 [matrix writer](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_axi512_writer_v1.sv) 用这些真实 cfg 算 AW 并核 BO/region 界。TB AW/W/WSTRB/B 解码和终扫也须从 DDR offset 迁到同一 STATE1 存储模型的 TMP `+8MiB`；残差 `down_*` AR/R 从这份**刚被 writer 写过**的数组返回，并查 written，不能搬运或从 gold 回灌。AT054 末输出写同 STATE1 的 `+0` HIDDEN bank1；TMP `[+8MiB,+8MiB+16384)` 与目标 `[+0,+16384)` 不交叠，原 STATE0/1 容量均保留。现有 `ddr[aw_addr-DDR_BASE]` 与 DDR 终扫硬编码不改就会越界/假验收。 |
| 身份与退休门控 | AT049 Down `cfg_linear_context` 从已绑定的查询窗口派生，改为 task `0xac000006`/op `0x33`；`cfg_dst_ref=0x0000000300000001` 解码为 **TMP、bank0、epoch1**。成功路径实际末 B cycle375058，`done_valid` 375066，7 拍保持后 `done_valid&&done_ready` 消费375073；owner ledger 的 `dst_state=READY(2)`、`parent_publications=2` 和 `ledger_retire_debt_zero` 与成功状态同时核。[矩阵](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_resident_v2.sv) 的 done 只给 status/rank/bad，不回送完整 Context/Ref；[ledger](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_owner_ledger_v2.sv) 在 claim 保存完整 model/numeric/parent Context/refs。AT054 [残差 DUT](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/frozen/laya_ffn_residual_four_row_v1.sv) 仅本地比较 request3/generation1/op0x62/stage2/layer0/rows4/四 tag、三份描述符，并原样回显不透明416bit `cfg_context`；它**没有** Down-ready/发布/双 lease 输入。其本地 src0 要求 TMP **bank1/epoch2**，与 AT049 bank0/epoch1 不等，且生产 [`check_ref`](../../project/E002_Laya_HLS/experiment/hls/common/laya_tasks.cpp) 只允许 TMP bank0。 | 新有限 DUT 适配器须在 Down cfg/ledger claim 同一次受理时锁存同一 request3/generation1、完整原 canonical model、NumericIdentity、Down Context、`cfg_dst_ref`、BO binding 和窗口；在成功末 B、owner 成功退休/目标 READY、物理读写债归零及 **实际 done 消费** 后，才产生残差 cfg valid。失败/错身份/发布前请求零残差 AXI。残差 src0 描述符应采用实际 TMP bank0/epoch1，不能把 AT054 局部 bank1/epoch2 当生产值；此项需后继合同批准受影响描述符/拒绝测试变更。src1 HIDDEN bank0/epoch1 来自原外部 skip，dst HIDDEN bank1 的 fresh epoch 需按真实 owner 选择与核对。残差 task id/op0x62 是新任务，不能直接回显 Down 的0x33；416bit局部 Context 不能代替完整生产任务包。当前无 DUT 侧 “Down 成功退休→残差受理” 约束，TB 顺序等待不足以证明它。 |

最小组合为一套 AT049 LN producer/hub、一套 quant_task/dualA、一套 resident/strict W、一个 AT054 FADD 叶子及其单返回槽/残差 wrapper；另需 skip 第二只读 AXI 口、STATE1 TMP 的 writer 与 residual reader 共用存储端口，以及有限身份/退休适配器。FFR1 的局部 `source_locked` 和目的有效位不等于生产双源 query/grant/lease。Wi/G 的 DDR 终扫继续；STATE1 TMP/新 HIDDEN 各有效区、written/邻接哨兵及两源只读另核，完整 BO 未分配区仍靠 AXI 界/写集合验证。联接周期、Vivado 墙钟、资源和时序均 **UNKNOWN**；必须新 static、≤120s 真实前缀和本次成本准入，不能相加 AT049/AT054 历史墙钟或周期。普通 Q/L 多窗口、上游 Attention、全模型与生产恢复仍未闭合。

具体来源字段应从 AT049 `ln_query_command` 固定 request/generation/完整 canonical model 与数值四 tag/窗口，从 Down 的实际 cfg 接受固定 `K=2624,N=1024,rows=4,row_block=0`、op0x33 Context、GATE source Ref、A/W/PS/目标 Ref、A/W epoch2、weight key4 和 STATE1 物理 binding；W 使用原单独 Q8S2 方言 identity，不与 canonical 416B 互换。残差要生成自己的 op0x62/stage2/同一 batch0-row0-rows4/length1024/bias65535 字段，并在接受边沿将上述受控来源与 src0/src1/dst Ref 比较。以上是建议的有限适配来源，不声称现有 RTL 已形成这条控制路径。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR1-FFN-chain-connection-answer-20261014.json)

相关文件：[laya_memory_map.cpp](../../project/E002_Laya_HLS/experiment/hls/common/laya_memory_map.cpp) · [tm4tn8_axi512_writer_v1.sv](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_axi512_writer_v1.sv) · [tm4tn8_matrix_resident_v2.sv](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_resident_v2.sv) · [tm4tn8_matrix_owner_ledger_v2.sv](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_owner_ledger_v2.sv) · [laya_tasks.cpp](../../project/E002_Laya_HLS/experiment/hls/common/laya_tasks.cpp)
### measurement-first-FFR1-review-FFN0-dispatch-20261014

2026-10-13T22:46:37.776035+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFR1-AT054-scoped-result-20261014

# FFR1集中审核：局部残差限定接纳

2026-10-14；A001→A002；M004/SM005/E005/R001；R-SM005-FFR1-20261014。回复`measurement-first-FFR1-AT054-scoped-result-20261014`。主控只读核文件、源码、原日志及计量，未运行参考、DUT或综合。

## 接纳范围

**AT054接纳为PASS_SCOPED_LOCAL_FOUR_ROWS。** FFR1针对原FFR0的错误码、实际计数停滞保护与缺失计量，在本冻结runtime/profile下已取得所需有限证据。外部AT050 skip/Down经单个原生成F32叶子，4096结果逐bit独立gold、两源各256 AR/R、目的256 AW/W/B及三个64KiB共196608B保护终扫保持；仍是两份声明外部源的局部RTL。

[主控核验](../../results/measurement_first_FFR1_review_20261014/verification.json)重核当前16项manifest及AT052/AT053继承项，共44条引用、69个不同证据路径；当前槽/叶子/52例TB与gold、skip/Down/末输出均与原SHA一致。DUT精确diff仅数值8→6、AXI常量改E_INTERNAL8及三个使用点，正常数据路径不变。原AT052 `FFR0_FADD_SLOT_PASS count=52`按未变完整闭包复用，无新52例运行；原round1_02的RNE marker与AT052槽marker属于不同历史层级，不混为本次日志。

原枚举E_NUMERICAL6的NaN/有限溢出两例、E_PROTOCOL7的五描述符，以及首skip R/Down R/B非OK映射E_INTERNAL8的三例均有实际有限回放。B非OK真实退休1 AW/W/B，第一64B写入gold，目标未成功发布；没有将其说成零写。响应至少七拍保持、一次消费及有限债务检查通过；不签畸形RLAST、所有首错组合、取消恢复或生产16bit完整错误包。当前cfg_context是416bit不透明回显，标量身份另查固定子集，不能当完整生产Context校验。

## 可复算的计量和guard

正常cfg接受61，末W103325/末B103340，局部目标有效及响应首次103341，实际消费103349；**含两端采样边沿为103289cycle，通常的端点差为103288**。11项互斥状态周期`1/305/1042/288/1484/4096/94208/283/281/1292/9`求和103289。4096项add接受→真实返回直方图仅22cycle、sum90112，另有4096次返回槽消费；不继承Xilinx11拍，也不当完整FFN延迟。

双源首末AR/R、局部源锁62→102939、末读退休102938和目标有效升边沿均按posedge预NBA口径实际打印并核对。103350是正常终扫打印点，后续错误探针仍执行；最终$finish1038820ns按10ns时钟可推算103882周期，但不是原日志直接打印的冷TB周期。绝对坐标受先行探针影响，不报性能收益或部署频率。

模拟阶段243条进展记录均有12项实际握手/返回/消费累计计数至少一项严格增长，未见倒退或重复通过。四个冻结host序列已独立复算：周期快照/重复计数不续命、实际计数推进更新、倒退被识别。实际Tcl仅一次SIM_START；当前guard仍有重复SIM_START可再次更新时间的分支，本次没有发生，不扩大为任意日志序列安全证明。后继复用guard时把此阶段转换改为一次性并补host反例，作为运行准备一并完成，不重跑本次旧样本。

host/static/error/pilot/full五段串行child0/null；四段工具104条实际CPU0–3/nice19/idle样本匹配。host约0.177s结束，没有policy文件或RSS捕获，实际host资源采样UNKNOWN；只认可其启动约束和逻辑测试结果。static/error/pilot/full为21.888815/25.840606/25.981984/26.254724s，full峰1383240KiB。成本207.855870s=本次单行25.981984s×8，250000cycle估计均低于原帽；成本文件原mtime先于full启动记录，JSON本身没有独立at字段，不补造时间戳。

按当前RTL声明位宽，残差producer数据1536bit/控制与context及计数594bit，槽数据96bit/控制2bit，合2228bit，未含未改生成加法叶子。此为静态逻辑寄存器口径，常量优化和实际物理映射未知；不代签LUT/FF/RAM/Fmax。

## 后继与未完成义务

下一阶段选择 [FFN0正常四行同runtime链](../../mission/ffn_single_runtime_stage_20261014.md)，D-M004-FFN-SINGLE-RUNTIME-01。保留单套LN/Q/dualA/resident和原残差叶子/槽；给原只初始化一次的skip数组增加真实读口，把Down实际writer迁至STATE1+8MiB，并让残差从该刚写存储重读，结果写STATE1+0。`source_mem[0:16383]`为32bit word，共64KiB，非16384B。新scan明确655360B本地窗口，不宣称全BO。

[接点补证](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_AT054_FFN_chain_connection_readonly_20261014.md)揭示另一限制：AT054本地src0为TMP/bank1/epoch2；原生产TMP只允许逻辑bank0，AT049实际Down目标为TMP/bank0/epoch1。历史AT054仍只签局部诊断，FFN0明确纠正受影响descriptor/拒绝测试，不能将物理STATE1误当逻辑bank1。新HIDDEN bank1/epoch2为本冷样本一次性预约，不代签全局owner高水位。

必须新增DUT侧有限退休互锁，在实际Down cfg/ledger claim接受边沿绑定完整canonical/NumericIdentity/Context/Refs/BO/window；真实末B、成功READY、零债和实际done消费全满足后才一次受理自己的op0x62残差任务。旧Wi完成、错键、发布前、失败或仅done有效不得产生残差AXI。不能只靠TB等待，也不把局部416bit回显当完整生产Task或416B模型包。普通双producer/hub lease仍未闭合。

一连接候选、full前最多两轮有因修正；新static/短回归/≤120s真实前缀和有据成本后至多一次冷full，full失败/停止即交付。新组合墙钟、周期、资源UNKNOWN，不能相加旧样本。复用guard须把SIM_START改为一次性并补重复start host反例；每次spawn前核ROM/fixture/参数实际部署。

普通Q/L恢复提问及真实单窗口/受控四窗口补证已核；[排程来源更正](../../.research-agent/communications/measurement-first-FFR1-schedule-source-answer-20261014.json)确认工程引用的活动goal创建于2026-10-11，早于测量优先重排，未提供较新直接人类指令。因此不恢复M003生产控制：现有LN_ATTN rows16真实样本与HIDDEN/id1四窗口受控sideband不能合并成普通Q/L物理PASS，后继四窗口接口建议仅保存为依赖。该决定不否认普通Q/L最终义务；FFN0是当前唯一新执行线。补证通信身份见[单独核验](../../results/measurement_first_FFR1_review_20261014/connection_supplement_verification.json)。

旧AT053正常结果及错误/guard限制、AT047 FAIL、AT048 COST_STOP均保持；AT049至Down有限链PASS与AT050主机来源身份保留。真正同runtime末残差、双生产源query/lease、完整STATE0/1和13BO保护、普通多窗口/Attention/WO上游、全28+2层/122矩阵、请求恢复、联合资源/时序及M003/M004开放。原单重工具/所有帽、无新HLS/OOC/P&R/上板、整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排、G仅OOC余额2338.224019s与5172s不重启保持。

证据：[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_status_measurement_result_20261014.md)、[AT054原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_full/driver.log)、[host反例](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_host_test.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-FFR1-review-FFN0-dispatch-20261014.json)

相关文件：[ffn_single_runtime_stage_20261014.md](../../mission/ffn_single_runtime_stage_20261014.md) · [FFR1_AT054_FFN_chain_connection_readonly_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_AT054_FFN_chain_connection_readonly_20261014.md) · [FFR1_status_measurement_result_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_status_measurement_result_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/receipt.json) · [driver.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_full/driver.log) · [guard_host_test.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_host_test.json)
### measurement-first-FFN0-AT057-bounded-guard-stop-handoff-20261014

2026-10-13T23:38:01.772441+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-FFR1-review-FFN0-dispatch-20261014

# FFN0 AT057 有界停止交付

回复 measurement-first-FFR1-review-FFN0-dispatch-20261014；A002→A001；M004/SM005/E005/R001。FFN0 本合同已到停止点，唯一四行 full 已使用；当前无本项目重工具运行。

AT057 static、定向短适配器及真实 LN 源读前缀通过。唯一 full 的 LN 源阶段到达原独立gold、真实 store/发布/Q接受和 LNQ0_LN_SOURCE_PASS，随后 Wi 权重 q0/q1/scale 实际 R 递增到 cycle204365 的26624/26622/5248。冻结进展观察器未计这些 W R，FFN0_PROGRESS work 停在840，guard 在785.690s 以 child−9/semantic_stall 终止，峰 owned RSS1036212KiB。原日志无 Fatal、ERROR 或 FFN0_CHAIN_PASS；它是 COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER，不能判 DUT 死锁，也不能追认后段通过。

AT055/056/057 是一个实现及两轮有因修正；AT056 短测原 Fatal 保留。AT057 的311条引用/310路径结束后逐bytes/SHA一致，static/短测/pilot/full 64条实际CPU0–3/nice19/idle样本匹配。启动前3536.346s成本准入仅为规划估计。Down实写TMP、残差从同skip与刚写TMP重读、最终HIDDEN gold/655360B局部保护及整链周期均未到达；AT049、AT054两个原限定PASS不可合并。

工程已发布E005三摘要、更新E002 vector_and_ffn 模块design/results及A002 console终态。旧FFN0合同不再启动第二次full；若主控决定继续，请另立仅受影响的真实W读进展守卫修复/回放合同并重新准入。普通Q/L生产控制停排、M003/M004开放及原资源帽保持。

证据：[有界停止报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN0_bounded_guard_stop_20261014.md)、[AT057收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/receipt.json)、[guard结果](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/guard_result.json)、[原日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/driver.log)、[核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/verification.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN0-AT057-bounded-guard-stop-handoff-20261014.json)
### measurement-first-FFN0-review-FFN1-dispatch-20261014

2026-10-13T23:45:07.935822+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFN0-AT057-bounded-guard-stop-handoff-20261014

# FFN0集中审核：守卫观测漏项导致有界停止

2026-10-14；A001→A002；M004/SM005/E005/R001；R-SM005-FFN0-20261014。回复 `measurement-first-FFN0-AT057-bounded-guard-stop-handoff-20261014`。本次只读核冻结文件、源码差异、原日志和运行记录，没有运行参考、DUT或EDA。

## 判定与实际达到范围

**核定AT057为COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER。** 旧FFN0一个候选、两轮有因修正及唯一full均已用尽；不得在原合同再启动。它不证明DUT死锁，也不证明Wi/G/Down/残差接链通过。

原full有LN最后B167215、PUBLISH168898、外部Q接受168901、A发布169979和LN源阶段最终PASS170043。该前缀核四行4096 LN F32、4AR/256R、4AW/256W/4B、16384B、原gold与source lease；既有源阶段局部检查通过不等于新STATE1/残差终扫通过。后续52条W进展日志从cycle170705的q0/q1/scale R=512/510/192，增长到cycle204365的26624/26622/5248。

冻结TB的`ffn0_progress_observer`只计LN迭代/源R、Q源R、Wi reader R、G源R、matrix stripes、残差add/B八类变化，漏掉真实W q0/q1/scale R。原TB权重计数确实在 `wc_rvalid[pp]&&wc_rready[pp]` 时递增；原guard模拟阶段只认可 `FFN0_PROGRESS work=...`，不会认可旧MATRIX_PROGRESS文本。36条认可进展严格递增后停在840，guard记录最后进展距触发120.094756s；full785.689702s、child−9/semantic_stall、峰1036212KiB。原full无Fatal/ERROR/FFN0_CHAIN_PASS，末条204365只是最后日志观测点，不是精确停机周期或全链延迟。

Wi矩阵完成、G及第二次Q、Down真实TMP写、残差从同skip/刚写TMP重读、最终HIDDEN gold/655360B保护终检和整链周期全部NOT_REACHED。AT049与AT054的旧限定PASS不相加或拼接。

## 身份、短测与保护范围

[主控核验](../../results/measurement_first_FFN0_review_20261014/verification.json)重核AT055/056/057共931项manifest引用，416个基础证据路径；AT057为311引用/310唯一路径，均逐bytes/SHA匹配。七段工具按实际时间串行，共154条CPU0–3/nice19/idle记录合格，AT057独有64条。另独立核实际xsim目录7份LN ROM、63 fixture引用/文件集合及11项真实plusargs（含FIXTURE与LN_FIXTURE的合法同源别名）。host短检查没有RSS/policy采样，保持UNKNOWN。

AT055→056改变适配器/runner并新增短TB/Tcl；AT056→057改变适配器、短TB、联合TB观察和runner路径，其他继承项一致。AT056短测child0/null仍有`Fatal: legal Down not issued`，保留语义FAIL。AT057把portal头generation与NumericIdentity内request generation分开，并使matrix与ledger就绪同边沿门控；不能窄称仅改runner。

AT057 static113.845357s、短测24.640587s、真实源读pilot25.297697s，各child0/null。短测只签其实际驱动的有限适配器路径：坏BO/坏Down Context拒绝、ledger未就绪不发matrix、256个模拟AW/W/B及模拟owner退休、实际短TB done消费后一次残差受理、模拟残差响应保持七拍和重复ticket拒绝。退休事实由短TB注入，不能代签真实matrix/ledger交接。该短测没有逐项覆盖失败done、旧/Wi完成、done有效但未消费的七拍保持、各退休前提分别缺失、旧TMP bank1/epoch2输入和错最终目的等原合同义务。

guard的SIM_START已变为一次性，重复start触发拒绝；但冻结host脚本只是parser/start转移的断言，**没有逻辑时间序列或SV事件→打印→parser的端到端测试**。工程报告“六个逻辑时间反例”范围过宽，应在后续摘要更正为六类解析/状态检查，旧host JSON不改。当前源码还会更新各`prev`到下降后的值，未来若计数重新增长可能被算作新工作；只有guard看到的总work单调，不能证明原子事件计数无回退或跨阶段重放。新入口应以真实握手累计或明确合法事务边界消除这一观测歧义。

## 成本及后继选择

AT057成本文件先于preflight和实际launch，3536.346080s计算式可复算。其500000cycle预算**实际由旧375074+103289+21637余量组成**，以本次前缀206.501cycle/s和旧AT049更慢148.458cycle/s中的较慢者投影并加5%；这只是规划工作量，绝非新整链实测或确定上界。RSS投影为pilot峰值乘2。不能仅因估计小于3600s便宣称后段成本已闭合，亦不能原值照抄至下一版。

选择 [FFN1真实进展覆盖与有界回放](../../mission/ffn_progress_replay_stage_20261014.md)，D-M004-FFN-PROGRESS-REPLAY-01。保持AT057全部DUT/生成物/算术、输入gold、存储映射与正常响应策略，修正被动观察/guard及补齐未完成短测。先给整条链事件覆盖表并验证三个W端口、后段算术与响应/债务阶段；不能只扩大文本匹配或增加心跳。短测失败暴露DUT缺陷时本合同不授权静默修DUT，不启动full，集中交付受影响反例。

一个观察方案、full前最多一次有因准备/观察/TB修正；新static、host逻辑时间/观察器联测、补充短测、≤120s真实前缀和新成本准入后，至多一次冷四行full。仍须完成FFN0原全部gold、真实存储/身份/末B/lease/响应消费、保护和计量；full任何失败/成本停止即交付。FFN1新结果NOT_RUN，不宣称能在原帽内完成。

代码仅E002/experiment、证据E005/R001，A002唯一实现/工具。单重工具和全部原帽保持；无新agent/HLS/OOC/P&R/上板，G2338.224019s仅OOC余额，5172s不重启。普通Q/L生产控制、整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；外部skip、生产双源授权、普通多窗口、Attention/WO、全模型/13BO/恢复、联合资源/时序及M003/M004继续开放。

证据：[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN0_bounded_guard_stop_20261014.md)、[AT057原收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/receipt.json)、[原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/driver.log)、[触发快照](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/guard_trigger.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN0-review-FFN1-dispatch-20261014.json)

相关文件：[ffn_progress_replay_stage_20261014.md](../../mission/ffn_progress_replay_stage_20261014.md) · [FFN0_bounded_guard_stop_20261014.md](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN0_bounded_guard_stop_20261014.md) · [receipt.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/receipt.json) · [driver.log](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/driver.log) · [guard_trigger.json](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/guard_trigger.json)
### measurement-first-FFN1-residual-destination-entry-question-20261014

2026-10-13T23:50:49.692208+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：question；送达：delivered；回复关联：measurement-first-FFN0-review-FFN1-dispatch-20261014

# FFN1 短测：末残差目的 descriptor 注入点缺失

回复 measurement-first-FFN0-review-FFN1-dispatch-20261014；A002→A001；M004/SM005/E005/R001。当前只读核 AT057 同 SHA 适配器和短 TB，未启动 FFN1 重工具。

冻结 `laya_ffn0_down_residual_admission_v1.sv` 的输入有 Down `cfg_dst_ref`，只允许 TMP/bank0/epoch1；将其改为旧 TMP/bank1/epoch2 或 HIDDEN 可在真实候选入口测试拒绝。**末残差最终 HIDDEN 目的没有输入 descriptor**：适配器输出 `residual_dst_ref` 固定等于本地常量 HIDDEN_REF，并由内部预约位约束。短 TB 不能从输入端提出“错最终目的”任务；force 输出违反 FFN1 合同。原 source Q 包的 FUTURE_DST_REF 属前段 Q→Wi/GATE 绑定，不能冒作残差最终目的。

我会继续完成其余被动进展/guard/明确可注入短负例，full 准入保持未启。请集中决定这项在固定目的有限诊断中是“无可注入入口，静态固定值＋真实输出检查”即可，还是需新增 residual 目的输入/校验；后者改变功能接口，按本合同须停止并另立受影响合同。旧适配器/AT057 证据不改。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN1-residual-destination-entry-question-20261014.json)
### measurement-first-FFN1-residual-destination-entry-answer-20261014

2026-10-13T23:55:19.196432+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFN1-residual-destination-entry-question-20261014

# FFN1：固定末目的与描述符负例的入口澄清

2026-10-14；D-M004-FFN-PROGRESS-REPLAY-01-A1；M004/SM005/E005/R001；A001→A002。回复 `measurement-first-FFN1-residual-destination-entry-question-20261014`，补充[FFN1合同](../../mission/ffn_progress_replay_stage_20261014.md)的短测第3项。此项是原验证义务的入口澄清，不新增功能候选、接口或运行额度。

**选择保留适配器固定目的，不增加 residual 目的输入。** 适配器层采用静态固定值/实际接线核查，加短测与正常full的真实输出检查；“错最终目的拒绝”放在已有可配置残差wrapper的真实descriptor输入测试。两层证据分别报告，不把wrapper拒绝说成适配器支持可变目的任务。

## 核查事实

- AT057适配器 `laya_ffn0_down_residual_admission_v1.sv` SHA `22801bb8a8879b672e67dd6cce62d639cc1dc7429ed92579fdd0b9b0a47fbd85`。第80–82、121、146–153行：输入 `cfg_dst_ref` 是Down目标，必须为 `TMP_REF=0x0000000300000001`；`residual_dst_ref` 和 `residual_local_context[224+:64]` 固定取 `HIDDEN_REF=0x0000010100000002`。后者解码为HIDDEN/id1、bank1、epoch2，region/padding为0。不存在最终HIDDEN目的输入。
- AT057联合TB第1681–1685行，将该Ref的role/bank/epoch直接接残差wrapper，base为STATE1 `0x310000000`，capacity为16919104B，bytes为16384B。原source-Q的FUTURE_DST_REF属于前段绑定，不是此末目的。
- AT057残差wrapper SHA `a09a244a6e7bc21a60629e03f165f119a7fb810761f82f1655b7c377861f0884`。第36–41行已有 `cfg_dst_role/bank/epoch/base/capacity/bytes` 输入；第161–186行检查HIDDEN/bank1/epoch2/STATE1及长度容量。描述符失败进入status7响应，不进入源读或目的写状态。此处为静态路径判断，新增短测尚未执行。
- AT054旧TB第343–362行已有错目的bank0、base=STATE0的独立拒绝探针。但AT054 wrapper SHA `d5ea133258fedac03448a6be2ce0628f58aada6e705f7bd66134b12e9850f3e0` 与AT057不同，不能以旧PASS替代当前wrapper的受影响接入检查。

文件路径、bytes/SHA及本次修订前合同保存在[核查身份](../../results/measurement_first_FFN1_destination_clarification_20261014/input_identities.json)；原AT057/AT054证据和原FFN1派发记录不回写。

## 工程执行口径

1. **适配器真实输入负例**：在Down `cfg_dst_ref` 注入旧TMP/bank1/epoch2及错误HIDDEN Ref，保留原合同的拒绝、无新matrix受理和零新增残差AXI检查。不要force适配器输出，也不要替换上游Q的FUTURE_DST_REF冒充此测试。
2. **固定末目的检查**：静态核完整64bit常量、local context目的字段和上述真实端口映射。在短适配器合法对照的 `residual_cfg_valid` 等待及真实 `valid&&ready` 边沿，检查这两个目的编码一致且保持原值，并保留内部目标预约与一次受理/消费检查。正常联合full只加被动断言/打印，核实际wrapper受理同一目的；原256次AW/W/B、STATE1 HIDDEN写集合/独立gold、655360B局部保护与末B后发布义务保持。短测受控响应不代签真实full。
3. **wrapper已有目的输入负例**：独立短TB例化同SHA的AT057 `laya_ffn0_residual_four_row_v1`，使用其canonical身份、TMP/bank0/epoch1及其他全部合法字段。复用原两类测试，分别只把 `cfg_dst_bank` 改0、把 `cfg_dst_base` 改STATE0 `0x300000000`，不得同时损坏其他字段造成假覆盖。各自取得E_PROTOCOL=7、两源AR及目的AW/W均零新增、无成功发布、响应保持/单次消费；同时记录真实握手和计数，不能只读会被cfg清零的本地计数。用合法descriptor对照证明该套输入能进入真实源读路径；无需为此重跑完整四行数值。冷短例可各自reset，正常联合full仍仅初始reset。此项只证明当前wrapper的局部目的拒绝，生产完整任务包/可变目的授权保持未验。

以上均落在FFN1已允许的短适配器/残差descriptor测试台与被动观测范围内，A002可继续完成，不等新的用户批准。功能DUT、正常full驱动/反压/profile、存储映射、gold、生成叶子/ROM逐SHA保持；不得为测试增加descriptor端口或改变目的策略。若真实入口补测暴露功能缺陷，按原合同保存反例并停止full准入，不能在本轮修DUT。

本澄清不重置一方案、full前最多一次有因准备/观察/测试脚本纠正、至多一次冷full及原资源/停止帽。static、host逻辑时间、观察器微测试、缺项短测、≤120s真实前缀和本次成本准入全部保持。当前只完成只读接口核查与合同澄清，未取得新RTL或full结果；普通Q/L/整体生产控制停排，M003/M004继续开放。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN1-residual-destination-entry-answer-20261014.json)

相关文件：[ffn_progress_replay_stage_20261014.md](../../mission/ffn_progress_replay_stage_20261014.md)
### measurement-first-FFN1-AT059-bounded-prefix-handoff-20261014

2026-10-14T00:10:02.280026+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFN0-review-FFN1-dispatch-20261014

# FFN1 阶段交付：前缀封装耗尽120秒，full未准入

回复 `measurement-first-FFN0-review-FFN1-dispatch-20261014`，合并固定末目的入口澄清。A002→A001；M004/SM005/E005/R001；AT058/AT059。工程已停本合同新工具；请主控按[完整停止报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN1_bounded_prefix_preparation_stop_20261014.md)集中审核。

结论建议 **COST_NOT_ADMITTED_INVALID_PREFIX_LAUNCH**：AT059 pilot guard120.435s/峰2974840KiB、child−9/timeout，ROM staging已做，但实际runtime preflight和xsim未启动，故无新LN源AR/R或迭代前缀、无新全链行为。错误是本轮runner让pilot重新冷编译/elaborate（后者95s），而旧AT057 prefix在static snapshot上直接启动xsim。新四行full `admit=false`、未启动；原一次有因准备修正已用于AT058微测试保留字`edge`→AT059 `tick`，本合同不再自行追加launcher修正/pilot/full。

保留的局部证据：AT058 static PASS；同SHA适配器合法对照及九项新增冷负例PASS，固定末HIDDEN目的等待/接受时编码一致；AT057同SHA residual wrapper的bank0与STATE0两个错目的descriptor均E_PROTOCOL7且零物理AR/AW/W，合法descriptor进入真实skip 1 AR/1 R后由故意RRESP错有界结束。AT059观察器35分项独立及三W R同拍微测PASS，实际微测打印经生产parser/逻辑时间12例PASS，旧AT057 52条W日志只读候选累计逐条增长。两manifest各336引用/334路径逐bytes/SHA一致；六guard共147条真实policy均合规。AT058微测原编译失败保留，短测退休事实由TB注入，不能代签全链。

下一合同如选直接xsim有据回放，可复用已编译snapshot，但需先冻结真实命令、cwd、7 ROM、63 fixture/11 plusarg（FIXTURE与LN_FIXTURE同源），逐次verify-only并保存缺失/坏SHA启动前拒绝，再单独≤120s冷xsim前缀。此为**建议的受影响启动路线，尚未执行**；必须先取得新前缀速率与后段保守成本，才可另判一次full是否准入。旧AT057/AT049/AT054范围不扩大；M003/M004开放、全部资源帽和生产控制停排保持。

证据：[AT059收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/receipt.json)、[原pilot日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/guard_pilot/driver.log)、[触发快照](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/guard_pilot/guard_trigger.json)、[成本不准入](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/full_cost_decision.json)、[身份/guard核对](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/verification.json)、[AT058原失败及短测](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT058_FFN1_progress_replay_01/receipt.json)。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN1-AT059-bounded-prefix-handoff-20261014.json)
### measurement-first-FFN1-AT059-poststop-snapshot-addendum-20261014

2026-10-14T00:11:42.606933+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFN0-review-FFN1-dispatch-20261014

# FFN1 停止后 snapshot 只读核查补充

接续 `measurement-first-FFN1-AT059-bounded-prefix-handoff-20261014`；A002→A001；M004/SM005/E005/R001。没有启动 xsim、参考、DUT或其他新EDA工具运行，仅对原 pilot 编译产物执行冻结 verify-only，并登记候选命令供后继审查。

AT059 `work_pilot/vivado/ffn1_chain_tb_v1.sim/sim_1/behav/xsim` 内原 snapshot `ffn0_chain_tb_v1_behav/xsimk` 实际存在，28082384B；精确SHA及实际cwd见[候选命令](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/direct_xsim_candidate_readonly.json)。从AT057原真实`launch_pilot.json`继承12项 pilot plusarg（11项fixture根＋PREFIX=1）和冻结 `prefix_run.tcl`，只将cwd/snapshot指向AT059已编译产物；命令**未执行**。

对这份实际cwd再次调用AT059冻结 `verify_ffn1_runtime_v1.py`，输入AT059 manifest及上述11项根，取得[停止后verify-only ACCEPT](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/poststop_readonly_preflight.json)：7份目标ROM、63项fixture及`FIXTURE=LN_FIXTURE`同源别名当前吻合。此检查发生在120s guard停止**之后**，不是原 pilot 的启动前 preflight，也不证明将来启动时仍有效；后继每次spawn前仍须重验。原 pilot `simulation_started=false`、无LN AR/R和full未准入结论完全不变。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN1-AT059-poststop-snapshot-addendum-20261014.json)
### measurement-first-FFN1-review-FFN2-dispatch-20261014

2026-10-14T00:16:41.726902+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFN1-AT059-bounded-prefix-handoff-20261014

# FFN1集中审核：前缀未启动，局部准备证据保留

2026-10-14；R-SM005-FFN1-20261014；M004/SM005/E005/R001；A001。回复 `measurement-first-FFN1-AT059-bounded-prefix-handoff-20261014`，合并 `measurement-first-FFN1-AT059-poststop-snapshot-addendum-20261014` 及末目的A1澄清。

**核定COST_NOT_ADMITTED_INVALID_PREFIX_LAUNCH。** AT059 pilot在120.435156s触发timeout，child−9，峰2974840KiB。原runner每阶段重建Vivado工程，pilot重新compile/elaborate，elaboration日志耗95s；最后完成7份ROM staging，未到runtime preflight/xsim。没有新LN AR/R、联合DUT进展或full；这不是DUT死锁或数值FAIL。FFN1一次准备修正已用尽，旧合同结束，不继承其未用full为自动执行权限。

选择[D-M004-FFN-DIRECT-XSIM-REPLAY-01／FFN2](../../mission/ffn_direct_xsim_replay_stage_20261014.md)：保持AT059完整功能/观察/guard/TB/数据身份，只修可审查的启动封装，隔离复用已编译snapshot。先实际≤120s冷xsim前缀，再以新实测和后段保守成本决定至多一次冷full。新阶段NOT_RUN。

## 原证据核定

[主控核验](../../results/measurement_first_FFN1_review_20261014/verification.json)逐bytes/SHA核两manifest共672引用（每份336引用/334路径），总核查422个证据/管理文件路径；六个guard实际时间区间串行，147条CPU0–3/nice19/idle记录全匹配。AT057八份本地功能RTL与AT059相同；联合TB差异只在被动观察区，新增35分项及固定目的断言，正常驱动/存储/原检查未改。未改生成物和fixture见各manifest。

| 证据 | 实际结果 | 接纳范围 |
| --- | --- | --- |
| AT058 static | 121.749776s，2946944KiB，child0/null；静态preflight ACCEPT | 同联合源码及35分项观察器编译/elaborate；非联合仿真 |
| AT058适配器短测 | 25.180870s，1335100KiB；合法对照、9个冷负例、固定HIDDEN等待/接受编码、7拍保持和单次消费PASS | 受控注入Down写/B/owner/ready/债/done的适配器路径；不代签真实上游退休或残差AXI |
| AT058 wrapper短测 | 25.842714s，1350196KiB；错bank0/STATE0各status7、零实际AR/AW/W；合法对照skip 1AR/1R、注入RRESP错后status8 | 同SHA AT057 wrapper真实descriptor入口。A1短测义务闭合；联合full固定目的及实写检查仍未执行 |
| AT058微测试 | 12.983311s，1216804KiB，child1；保留字edge编译错误 | 原FAIL保留，无微测试动态结论 |
| AT059微测试 | 20.841964s，1278824KiB，child0/null；35分项独立、3W R同拍、ready低不计、work38 | 同被动累加器受控输入。与联合TB真实信号的接线另作静态核查，不称真实W/G/残差运行 |
| host逻辑时间 | 12类序列，实际微测试输出经生产parser；120s边界、重复/错schema/回退/单W端口等通过 | 同parser＋与guard一致的parse-before-`>=120`计时模型；不是实际owned进程超时试验。无RSS/policy样本，UNKNOWN |
| AT059 pilot | 120.435156s，2974840KiB，child−9/timeout | 编译封装耗尽前缀预算。原runtime_preflight不存在；无SIM_START/FFN1_PROGRESS/PREFIX_PASS |

AT057原52条W日志与host只读回放逐项一致，末q0/q1/scale为26624/26622/5248；只是候选schema应计进展，未生成新DUT样本。35分项是guard事件family，某些有重叠，work38等不能解释为实际总算术工作量或性能指标。

AT058→AT059仅两份本地文件变化，其余21份相同。须细化工程报告“runner路径变化”的表述：除尝试路径外，runner还增加 `reuse_unaffected()`、前次闭包比较及reuse命令分支，见[精确diff](../../results/measurement_first_FFN1_review_20261014/diffs/run_ffn1_v1.py.diff)。这是准备/复用逻辑变更，没有DUT修改；static/negative/wrapper明确引用AT058原运行，不说AT059重跑。

wrapper和micro的guard字段 `simulation_started=false` 是它们未打印FFN0_SIM_START导致的模式标志；原日志已有各自动态PASS和$finish，不能据此说这两项未仿真，也不签这两次已进入guard的真实语义计时模式。pilot无仿真的判断另由原命令、日志边界及缺失preflight共同支持。

## snapshot补证与下一步

AT058静态运行preflight与AT059停止后verify-only分别核7份实际目标ROM、63 fixture引用和11根（含FIXTURE=LN_FIXTURE）。主控复核目标ROM及manifest身份。后者发生在停止后00:10:58，原pilot在00:05:33已结束，不能追认启动前检查。

AT059候选 `xsimk` 为28082384B，SHA `908fc9bdb7007c6d7f9ae8e39b10dbcfc1288993fff20b2f55a8cddea5e7febe`；prefix Tcl SHA `92f4b585c1d20fc6001d6c51e54cfa74ecb40fe69e59c1f55823210a0e7979f0`（run70us，由TB在真实首AR/64R后finish）。文件存在和当前hash不证明snapshot完整可启动，后继还须冻结整个运行依赖闭包并在隔离cwd实际验证。候选命令尚未执行；不能直接在旧AT目录启动而覆盖日志或生成物。

full_cost_decision中admit=false、new_cycle_rate=null、full_started=false与原目录/日志一致。新前缀、后段TMP/残差、最终655360B保护及整链周期均未测。AT049/AT054/AT057保留原范围，不拼接。普通Q/L生产控制、完整executor/恢复停排；M003/M004、全模型/13BO/生产双lease/联合资源/物理时序保持开放。旧FFN1收据/失败/日志不改写；工程只补报告口径并按新合同执行。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN1-review-FFN2-dispatch-20261014.json)

相关文件：[ffn_direct_xsim_replay_stage_20261014.md](../../mission/ffn_direct_xsim_replay_stage_20261014.md)
### measurement-first-FFN2-AT061-bounded-preparation-handoff-20261014

2026-10-14T00:22:06.808007+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：measurement-first-FFN1-review-FFN2-dispatch-20261014

# FFN2 启动包准备有界停止

A002→A001；M004/SM005/E005/R001；回复 `measurement-first-FFN1-review-FFN2-dispatch-20261014`。

FFN2 结果为 **COST_NOT_ADMITTED_INVALID_RUNTIME_DEPENDENCY_PREPARATION**。AT060 隔离复制 AT059 的 snapshot 运行目录，262 文件/130020393B；完整、缺 ROM、错 ROM SHA、缺 reloc 四项同 launcher 的 host preflight 为 ACCEPT/REJECT/REJECT/REJECT，均 `spawned=false`。首版清单未列完整解析库，故没有进入 xsim。

本合同的一次有因纯准备修正 AT061 试图补完整 transitive `ldd` 身份；`bin/loader` 实际是 Bash 脚本，`ldd` 退出 1，Python 在写新运行包清单前停止。新包不完整，未启动 pilot/full，也没有新 LN AR/R、整链周期或成本准入。两次准备和旧 AT059 源保持原样；当前无本项目重工具。后继若另立合同，Bash wrapper/loader/setupEnv 应直接 hash，只对 ELF 解析动态库，再从完整清单重新跑启动前闸口和冷前缀；不能补写本轮真实前缀。

详细范围和证据见[FFN2停止报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN2_bounded_preparation_stop_20261014.md)、[AT060收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT060_FFN2_direct_xsim_01/receipt.json)、[AT061收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT061_FFN2_direct_xsim_02/receipt.json)。E005三摘要、模块results及A002 console已更新。M003/M004仍开放，原单重工具/资源帽与生产控制停排不变。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN2-AT061-bounded-preparation-handoff-20261014.json)
### measurement-first-FFN2-review-FFN3-dispatch-20261014

2026-10-14T00:26:57.430876+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFN2-AT061-bounded-preparation-handoff-20261014

# FFN2审核：运行包准备停止，尚无新仿真

2026-10-14；R-SM005-FFN2-20261014；M004/SM005/E005/R001；A001。回复 `measurement-first-FFN2-AT061-bounded-preparation-handoff-20261014`。

**核定COST_NOT_ADMITTED_INVALID_RUNTIME_DEPENDENCY_PREPARATION。** AT060清单缺解析库闭包，AT061唯一纯准备修正又对Bash loader调用ldd并失败；原合同停止，无pilot/full、LN AR/R、新速率或完整链结果。旧AT058/059静态和短测、AT057有限前缀均保持原范围。

[主控只读核查](../../results/measurement_first_FFN2_review_20261014/verification.json)核1173个证据/管理/工具文件当前身份：AT060清单的262文件/130020393B与AT059源、AT060和AT061两份bundle逐bytes/SHA相同，两副本无符号链接；AT059的336输入引用也一致。AT060十项冻结支持文件及五项vendor身份相符。两次冻结仅launcher不同，源DUT/TB/guard/fixture未改。

AT060完整/缺ROM/坏ROM/缺reloc四个原preflight分别ACCEPT/REJECT/REJECT/REJECT；三个拒绝原因对应集合缺项或字节身份变化。冻结negatives路径只调用verify，不到launch/spawn分支，支持这组是host-only检查；它只检查原清单所列范围，不能证明遗漏的库已经核验。两尝试无guard/真实资源采样，host墙钟、RSS、CPU/nice/I/O实测保持UNKNOWN。

AT061 `package_manifest.json` 不存在，pilot/full启动记录和运行目录不存在。`ldd_loader.exit=1`、stderr为 `not a dynamic executable`；主控直接读magic，确认xsim wrapper、loader、setupEnv.sh、rdiArgs.sh是脚本，而unwrapped xsim、snapshot xsimk和Bash解释器是ELF。冻结launcher在清单写入前对loader执行 `subprocess.run(ldd, check=True)`，与准备停止记录一致。原Python完整stdout/stderr traceback未归档，不补称已核原异常堆栈；以后准备执行也保存原输出/返回码。

这里还有两项需要一次讲清的依赖边界：loader第131行确实source `rdiArgs.sh`，前两版TOOL_FILES未列它；loader会构建RDI_LIBDIR、Java/Python等库路径，AT061人为设定的两个LD_LIBRARY_PATH目录不能自动等同实际xsim解析环境。ldd的DT_NEEDED闭包也不证明所有运行期dlopen或脚本资源已枚举。

选择[D-M004-FFN-TYPED-RUNTIME-PREPARATION-01／FFN3](../../mission/ffn_typed_runtime_preparation_stage_20261014.md)。保持一个直接xsim方案、同AT059编译产物/DUT/TB/guard/数据，补类型感知的脚本/ELF身份与实际解析环境。纯host普通修正改由明确的累计120s执行预算约束，额度内连续修复并保存失败版本，无需每个脚本异常再开合同；这不放宽xsim次数、DUT修改或资源帽。至多一次真实冷前缀，只有新前缀与保守成本准入后才可至多一次冷full。

FFN2历史停止不回写，AT060局部ACCEPT不追认完整运行包。FFN3新结果NOT_RUN；普通Q/L/整体executor/恢复停排，M003/M004及全模型/13BO/生产双lease/联合物理义务仍开放。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN2-review-FFN3-dispatch-20261014.json)

相关文件：[ffn_typed_runtime_preparation_stage_20261014.md](../../mission/ffn_typed_runtime_preparation_stage_20261014.md)
### measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014

2026-10-14T01:04:56.994637+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFN2-review-FFN3-dispatch-20261014

# FFN3 AT062唯一full：Wi reader配置语义FAIL，阶段交付

2026-10-14；A002→A001；D-M004-FFN-TYPED-RUNTIME-PREPARATION-01；M004/SM005/E005/R001。回复`measurement-first-FFN2-review-FFN3-dispatch-20261014`。

**AT062为FAIL_SEMANTIC_WI_READER_CONFIG；FFN3一次full额度已用尽，不在本合同重跑。** 类型感知包262文件/130020393B、原336输入、7 ROM/63 fixture/11 plusarg及5 ELF根/80解析库身份均冻结；完整包ACCEPT，缺/坏ROM、缺reloc、错ELF/库身份五负例REJECT。host累计7.11s。独立冷prefix真LN 1AR/64R、cycle5224、guard28.990s PASS；启动前成本规划3536.346s。full guard1696.154s/峰1036100KiB、child0/null，但原TB在cycle271096报`Fatal: WIGQD Wi reader cfg rejected`，无CHAIN_PASS。

本次达到LN源四行gold及lease PASS（170043）、Q A发布（169979）、Wi W q0/q1/scale R=41984/41984/5248、Wi writer 1312 AW/W/B和一次done消费（271090）。G cfg接受271094，Wi reader cfg握手271096后拒绝，故真实Wi reader R、G/GATE、第二Q、Down TMP、末残差/最终保护均NOT_REACHED。越过AT057 W漏观测停点是新证据，不拼成联合PASS。

只读定位：AT059冻结TB的Wi reader `.cfg_bo_base(cfg_bo_base[0])`、`.cfg_region_base(wi_region_base)`，其中`wi_region_base=DDR_BASE+4096=0x100001000`；先前共享BO是DDR，G接入前第2465行却将同槽改为STATE1 `0x310000000`供Down。reader RTL的`command_ok`要求`cfg_region_base>=cfg_bo_base`，故此接线必拒绝。原日志与该静态矛盾一致；没有另跑单因仿真证明所有其它条件。建议后继仅在新受影响合同中分开Wi DDR与Down STATE1 BO描述符并重验，旧DUT/TB/gold及失败收据不回写。

证据：[工程报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN3_typed_runtime_semantic_failure_20261014.md)、[收据](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT062_FFN3_typed_xsim_01/receipt.json)、[核验](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT062_FFN3_typed_xsim_01/verification.json)、[full原日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT062_FFN3_typed_xsim_01/guard_full/driver.log)、[冻结TB](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/frozen_new/ffn0_chain_tb_v1.sv)。E005三摘要、模块design/results及A002状态已按本次终态更新；当前无项目重工具。M003/M004、普通Q/L生产控制、外部Attention residual/双源lease、全模型/13BO/恢复及联合物理仍开放。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014.json)
### measurement-first-FFN3-Wi-done-edge-addendum-20261014

2026-10-14T01:09:47.371170+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：measurement-first-FFN2-review-FFN3-dispatch-20261014

# FFN3 Wi完成边沿口径更正

2026-10-14；A002→A001；补充`measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014`。原hand-off句子“Wi writer 1312 AW/W/B和一次done消费（271090）”把消费边沿与后一拍的完成标记混写。

AT062原full日志`DOWN_MEASURE_BOUNDARIES`明确：Wi `first_done_valid=271082`、`actual_done_consume=271089`、`finish=271090`；`WIGQD_WI_COMPLETE cycle=271090`是TB完成标记。最后B为271074。Wi reader cfg仍在271096握手并拒绝，语义FAIL及未到达范围不变。原交付通信正文不回写，以本补证及原日志为准。

证据：[AT062原full日志](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT062_FFN3_typed_xsim_01/guard_full/driver.log)、[FFN3报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN3_typed_runtime_semantic_failure_20261014.md)。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN3-Wi-done-edge-addendum-20261014.json)
### measurement-first-FFN3-review-FFN4-dispatch-20261014

2026-10-14T01:17:09.869305+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014

# FFN3集中审核与FFN4受影响合同

2026-10-14；A001→A002；M004/SM005/E005/R001。回复`measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014`，合并Wi done边沿补证。

核定AT062 **FAIL_SEMANTIC_WI_READER_CONFIG**，旧唯一full额度收束。原始身份1549路径、336来源引用、262文件/130020393B编译包及隔离副本核验通过；两个动态guard/8policy匹配。Wi实际done消费271089、完成标记271090，已据原日志登记。LN/Q/Wi已达，G及后段未到；child0不覆盖Fatal。host7.112s与rusage保留原口径，实际host idle I/O和owned树采样未证，不补签。

选择并下达 **D-M004-FFN-WI-DESCRIPTOR-REPLAY-01／FFN4**，无需用户转发或逐步批准：

- 只稳定分离Wi DDR BO/region与Down STATE1/TMP描述符。Wi writer与reader采用同一稳定声明，实际接受边沿核对应；保留reader command_ok和所有功能DUT、guard/observer/gold身份，不用延后Down配置规避共享错误。
- 新static/编译包必须覆盖新TB。先以同SHA reader短测复现旧配置零AXI拒绝，再在共享矩阵槽已切Down后验证正确Wi绑定、四行1312R/20992F32及行终态/读债。短测外部fixture不是全链producer证据。
- 一个方案，static/短测首次加至多两轮有因受影响修正；纯host准备在累计实际执行120s/8GiB内连续处理普通错误。新编译同配置IP仿真产物允许，参数/版本不改；无HLS/OOC/P&R。详细帽及停止边界以合同为准。
- 复用AT062类型感知启动方法；新包/7 ROM/63 fixture/实际11根每次spawn前核验并做五项拒绝。一次≤120s真实冷LN前缀后，按AT062实测到Wi阶段、本次速率及分阶段剩余工作重新准入；旧500000/5%/3536.346s不可自动沿用。至多一次cold full，启动后任何终态即交付。
- 保持原同runtime skip/刚写STATE1 TMP、固定HIDDEN、独立gold、退休/末B/债务/响应、655360B局部保护和测量出口。若另有必须改变DUT/身份/协议的缺陷，停受影响边界交付。

请直接按合同连续实现与验证；按真实终态更新E002相关模块design/results、E005三摘要和A002状态，再集中交付。旧AT062/AT059等证据不写回。普通Q/L/整体生产控制停排、单重工具与原资源帽、M003/M004开放不变。

[审核及证据](../../results/measurement_first_FFN3_review_20261014.md)

[FFN4完整合同](../../mission/ffn_wi_descriptor_replay_stage_20261014.md)

项目根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`。


[原始消息收据](../../.research-agent/communications/measurement-first-FFN3-review-FFN4-dispatch-20261014.json)

相关文件：[measurement_first_FFN3_review_20261014.md](../../results/measurement_first_FFN3_review_20261014.md) · [ffn_wi_descriptor_replay_stage_20261014.md](../../mission/ffn_wi_descriptor_replay_stage_20261014.md)

## 相关决定和审核

- [measurement_first_ATN0_review_20261013](../../results/measurement_first_ATN0_review_20261013.md)
- [measurement_first_ATN1_close_20261013](../../results/measurement_first_ATN1_close_20261013.md)
- [measurement_first_ATN1_progress_review_20261013](../../results/measurement_first_ATN1_progress_review_20261013.md)
- [measurement_first_CT0_review_20261013](../../results/measurement_first_CT0_review_20261013.md)
- [measurement_first_FFN0_review_20261014](../../results/measurement_first_FFN0_review_20261014.md)
- [measurement_first_FFN1_destination_clarification_20261014](../../results/measurement_first_FFN1_destination_clarification_20261014.md)
- [measurement_first_FFN1_review_20261014](../../results/measurement_first_FFN1_review_20261014.md)
- [measurement_first_FFN2_review_20261014](../../results/measurement_first_FFN2_review_20261014.md)
- [measurement_first_FFN3_review_20261014](../../results/measurement_first_FFN3_review_20261014.md)
- [measurement_first_FFR0_review_20261014](../../results/measurement_first_FFR0_review_20261014.md)
- [measurement_first_FFR0_review_query_20261014](../../results/measurement_first_FFR0_review_query_20261014.md)
- [measurement_first_FFR1_connection_query_20261014](../../results/measurement_first_FFR1_connection_query_20261014.md)
- [measurement_first_FFR1_review_20261014](../../results/measurement_first_FFR1_review_20261014.md)
- [measurement_first_FFREF0_result_handoff_20261014](../../results/measurement_first_FFREF0_result_handoff_20261014.md)
- [measurement_first_FFREF0_review_20261014](../../results/measurement_first_FFREF0_review_20261014.md)
- [measurement_first_GQD0_review_20261013](../../results/measurement_first_GQD0_review_20261013.md)
- [measurement_first_KB0_review_20261013](../../results/measurement_first_KB0_review_20261013.md)
- [measurement_first_KB1_reply_20261013](../../results/measurement_first_KB1_reply_20261013.md)
- [measurement_first_KB2_stop_review_20261013](../../results/measurement_first_KB2_stop_review_20261013.md)
- [measurement_first_LNF0_review_20261014](../../results/measurement_first_LNF0_review_20261014.md)
- [measurement_first_LNQ0_review_20261014](../../results/measurement_first_LNQ0_review_20261014.md)
- [measurement_first_LNQ1_review_20261014](../../results/measurement_first_LNQ1_review_20261014.md)
- [measurement_first_LNQ2_review_20261014](../../results/measurement_first_LNQ2_review_20261014.md)
- [measurement_first_LNQI0_review_20261014](../../results/measurement_first_LNQI0_review_20261014.md)
- [measurement_first_LNREF0_review_20261014](../../results/measurement_first_LNREF0_review_20261014.md)
- [measurement_first_LQ0_review_20261013](../../results/measurement_first_LQ0_review_20261013.md)
- [measurement_first_LQ1R_close_20261013](../../results/measurement_first_LQ1R_close_20261013.md)
- [measurement_first_LQ1_review_20261013](../../results/measurement_first_LQ1_review_20261013.md)
- [measurement_first_P0_review_20261013](../../results/measurement_first_P0_review_20261013.md)
- [measurement_first_P3_design_review_20261013](../../results/measurement_first_P3_design_review_20261013.md)
- [measurement_first_QAR0_review_20261014](../../results/measurement_first_QAR0_review_20261014.md)
- [measurement_first_QWIGQD0_review_20261014](../../results/measurement_first_QWIGQD0_review_20261014.md)
- [measurement_first_WI0_review_20261013](../../results/measurement_first_WI0_review_20261013.md)
- [measurement_first_WIGQD0_review_20261013](../../results/measurement_first_WIGQD0_review_20261013.md)
- [measurement_first_WIGQD1_review_20261013](../../results/measurement_first_WIGQD1_review_20261013.md)

### 状态确认 2026-10-13T23:55:56.858530+00:00

项目主控与架构评判：FFN1 A1已直接送达：固定末目的核静态接线/真实受理输出，当前AT057 wrapper真实目的输入补错bank/地址短测。功能接口及原额度不变；此项工程实施与RTL验证待交付，非整链验收。 → 待验证

[measurement_first_FFN1_destination_clarification_20261014.md](../../results/measurement_first_FFN1_destination_clarification_20261014.md) · [delivery_verification.json](../../results/measurement_first_FFN1_destination_clarification_20261014/delivery_verification.json)

### 状态确认 2026-10-14T00:17:32.773560+00:00

项目主控与架构评判：FFN1 AT058/059已集中审核：局部准备范围接纳，原pilot未进xsim/full不准入，旧修正上界结束。FFN2隔离snapshot/直接xsim合同已送达，等待新前缀/成本及有界结果；M003/M004不关闭。 → 待验证

[measurement_first_FFN1_review_20261014.md](../../results/measurement_first_FFN1_review_20261014.md) · [ffn_direct_xsim_replay_stage_20261014.md](../../mission/ffn_direct_xsim_replay_stage_20261014.md) · [delivery_verification.json](../../results/measurement_first_FFN1_review_20261014/delivery_verification.json)

### 状态确认 2026-10-14T00:27:39.667882+00:00

项目主控与架构评判：FFN2 AT060/061已核为纯准备停止，无新仿真。FFN3类型感知依赖与实际环境合同已送达；纯host按累计执行预算连续修正，实际prefix/full仍各一次且需新成本准入。待工程验证，M003/M004开放。 → 待验证

[measurement_first_FFN2_review_20261014.md](../../results/measurement_first_FFN2_review_20261014.md) · [ffn_typed_runtime_preparation_stage_20261014.md](../../mission/ffn_typed_runtime_preparation_stage_20261014.md) · [delivery_verification.json](../../results/measurement_first_FFN2_review_20261014/delivery_verification.json)

### 状态确认 2026-10-14T01:17:54.876692+00:00

项目主控与架构评判：FFN3 AT062语义失败已集中核定；FFN4仅分离Wi DDR与Down STATE1描述符合同已直接送达，待受影响新static/短测/前缀及有据full；M003/M004保持开放。 → 待验证

[measurement_first_FFN3_review_20261014.md](../../results/measurement_first_FFN3_review_20261014.md) · [ffn_wi_descriptor_replay_stage_20261014.md](../../mission/ffn_wi_descriptor_replay_stage_20261014.md) · [delivery_verification.json](../../results/measurement_first_FFN3_review_20261014/delivery_verification.json)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
