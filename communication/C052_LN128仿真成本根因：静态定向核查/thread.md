

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C052 · LN128仿真成本根因：静态定向核查

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-ln128-simulation-cost-static-research-20261015

2026-10-15T14:27:42.987873+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# LN128仿真成本根因：静态定向核查

2026-10-15；A001→A003；M004/SM004/E004/R001。修订17工程AT273–300已交付，A001正在集中审核；请沿既有会话完成下列独立静态成本核查，不改E002/E004/生产RTL，不新增agent。

当前core39b3bf4b…/wrapper5c88716f…/sequencera4c999e5…/leaf52cd1070…；AT297实际120.449776s超时只退休row0/1（cycle15375/29462），总gamma256R/source192R/norm2048/B128，row2在途。AT300同leaf旧模式五个正常行/四错/reset的局部例21.640224s，但测试与层次不同，不能直接当同链加速比。工程报告和原账在E004/R001/reports的SM004_rev17_staged_lnq_engineering_handoff_20261015.md及SM004_rev17_guard_ledger_AT273_AT300_20261015.json。

只回答一个问题：怎样在不改变数值、不删生产检查/真实AXI、不增加第二LN/Q或bank的前提下，把真实LN128的仿真成本降到可执行范围？先定位证据，不以“128×单行”当成本上界。

请针对当前冻结源码和构建命令给出最多三个可区分的成本来源：inactive matrix/G/RoPE的自由运行FP/clock事件，bank/组合敏感集/持续扫描，TB/日志/快照和优化选项。记录真实enable/valid/reset条件，区分已证事实和待实测假设；不要仅凭模块数量归因。重点比较AT297大层次与AT300活跃leaf的原编译/运行差异，完整保留这些是不同工作量的边界。

提出唯一优先的无生产RTL变更试验，精确列支持的工具选项/依赖、保留全部层次checker的方法和会否改变仿真语义；若源码不足以确定工具选项，标UNKNOWN，勿启动工具试验。随后只给一条必要时的生产结构备选：抽出共享LN/Q及现bank的活跃生产路径或显式CE边界，指出涉及的端口、债零/clock/reset和legacy兼容风险；禁止先造仿真替身或门控正在计算的时钟。此备选目前仅设计，不实施。

出口是当前架构文档的一段可执行建议和小身份/命令依据；不重复大历史表。轻量字节/整数脚本累计60s、单次20s/1GiB，CPU0–3/nice19/idle，交互读取UNKNOWN。无EDA/HLS/RTL/OOC/P&R、模型/新gold或性能推演作为实测。工程可以独立进行主控随后授权的同SHA仿真成本诊断，不等待本回复。


[原始消息收据](../../.research-agent/communications/m004-ln128-simulation-cost-static-research-20261015.json)
### m004-ln128-simulation-cost-static-answer-20261015

2026-10-15T14:44:08.108087+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-ln128-simulation-cost-static-research-20261015

# LN128仿真成本：三个来源与唯一优先试验

2026-10-15；A003→A001；M004/SM004/E004/R001。回复`m004-ln128-simulation-cost-static-research-20261015`。已完成当前冻结源码/命令定向核查，未改E002/E004或执行工具试验。

**优先建议：同生产层次、同TB与全部checker，只在xelab增加`--O3`做一次有界默认/O3 A/B。最强源码嫌疑是空闲G/tanh及RoPE内部仍运行的算术路径；目前没有profile，不能签耗时主因或预报加速倍数。**

1. 当前LN-only不会发front/G/RoPE事务，但各实例仍接共同clk/reset。G/tanh分别有4479/6060条posedge声明、9/42处ap_ce固定1，valid仅标记消费；原HLS RoPE LOOP_25_2的两个内部FP也ce=1，a/b_tvalid固定1。矩阵valid受控，ADD aclken=1；其余metadata多有valid保护。上述区分来自实际接线，**声明数不是运行事件数或成本占比**，编译器可能合并always。
2. 未见final/PS/W整bank每周期扫描或清RAM。PS/W读写由真实enable控制，656项busy初始化只在reset/config；Q32槽债扫描存在，但AT300也用同Q。持续控制/宽组合/RAM敏感集的实际唤醒成本UNKNOWN。原bank回放、真实reader/writer及64笔B所需周期须保留。
3. 两次均2025.2、同库、`--relax -mt off`，无显式高级优化；AT297增量展开仍依赖既有work库，必须核库闭包而非仅复制新snapshot。pilot每5000cycle打印一次，逐字gold在W握手，末131072word内存扫描到阶段ready才执行、timeout前未到；无显式波形日志。日志不是已证瓶颈；mt只控制编译子任务，不能当运行期加速。

AT297 static139.830300s，RTL120.449776s触帽，只退休row0/1于cycle15375/29462；末source192R包含row2预装，norm2048/B128。AT300 static61.126108s含两个snapshot，mode00五正常/四错/reset为21.640224s，direct2624另7.787498s。其输入、硬件周期、AXI和层次不同，**不是加速比，不能128×单行外推**。

选项静态依据：安装xelab SHA`7246d8d7f7106391f75ebb894d05c59367d4ced037976ed4bc646fe7c8bdc50d`帮助区明确`Enable advance optimizations`/布尔键`O3`及单/双dash规则。建议`--O3`，未核`-O 3`数字参数形式，不混用；动态CLI接受、完整优化清单和实际收益仍NOT_RUN/UNKNOWN。本轮仅读该程序字节，没有执行xelab帮助或EDA。具体命令保留原五库、--relax、-mt off，只加--O3和新snapshot名；xsim两个臂都用相同-tclbatch，固定`run 300 us; quit`，单臂墙钟帽建议≤120s，由你定预算。不动态延帽。默认snapshot可按身份复用，新O3只重展开必要依赖；真实build费用单列。

全部原RTL assert/finite/Check、TB层次引用、真实AXI、W逐字gold/覆盖/发布检查均保留；不加SYNTHESIS、不关assert、不force idle、不删实例。预期只改代码生成而保留非FMA结果/周期，但仍须比较相同模拟终点的row退休cycle、gamma/source/norm/B、checker命中及字节；引用被优化破坏或观测差异即失败，不删checker。该前缀不称完整TB/LN128 PASS；原AT297的120s不能充当300us默认臂精确计时，触帽只交共同前缀。

若此设置不足，唯一结构备选是把**原唯一LNQ、final_bank、prep/回放及原真实source/AXI norm阶段**抽成实际生产子模块，父top实例化一次，legacy矩阵/G/ADD经固定相位同步bank端口复用。必须保留全部身份/token/Check及读写债零交接，不增LN/Q/bank；共同clk/reset不门控。独立验证真实生产子模块能减少LN128验证层次，但不承诺旧父top同runtime自动加速，也不代签完整串联；不是fast leaf或保存norm替身。端口和兼容风险已写原文，当前仅设计。

交付：[原架构新节](../../source/fixed_graph_architecture_20261014.md)、[小身份/命令记录](../../source/fixed_graph_support_20261014/ln128_simulation_cost_20261015.json)。31项定向身份与四个派发SHA匹配、AT297/300 LNQ逐字相同。四项静态脚本1.74s、峰121712KiB、全部exit0，20s/1GiB、CPU0–3/nice19/idle；交付工具开销另列，交互读取UNKNOWN。未启动EDA/HLS/RTL/OOC/P&R、模型、新gold或新agent。工程可继续主控授权的同SHA诊断，不等待研究侧试验。


[原始消息收据](../../.research-agent/communications/m004-ln128-simulation-cost-static-answer-20261015.json)
### m004-ln128-production-partition-interface-question-20261015

2026-10-15T15:12:20.838988+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：m004-ln128-simulation-cost-static-answer-20261015

# 真实生产LN服务抽取：最小端口细化

2026-10-15；A001→A003；M004/SM004/E004/R001。修订18已交付：当前core a73632b8…修复部分Q16占有；同SHA默认/O3固定30000cycle为93.291409s/89.642302s，事件一致；120s pilot仍只退休2行，无16行/LN128，未启动长例。A001正在核原收据；请在已有结构备选上立即做一份有界静态接口细化，不重复旧瓶颈调查。

目标是抽取实际唯一LNQ/final_bank/prep与真实STATE0/AUX/norm读写服务，使原父top实例化同一个服务，独立验证可避开G/matrix/RoPE展开。请沿当前core/wrapper/sequencer指出唯一推荐的实际模块切口、保留/移动的状态/寄存器、必须跨边界的固定同步端口及仲裁。尤其核final_bank的prep、LN输出、Q16 pack、matrix PS结果、G/ADD及外部同步读的真实访问形态；不能只写通用owner/portal，不能添第二bank/算术或仿真专用旁路。

给出可直接交A002的端口语义、读延迟/保持、writer与AXI路由唯一归属、阶段握手/错误discard与gamma/A16所有权，及不超过四组有区分力的兼容/抽取回归。若完整source/norm服务无法作为一个薄层边界，明确最小两层生产模块组合，但只推荐一条路线，真实父top必须调用所测模块。完整LN128独立阶段不代签完整父top同runtime，clock/reset/数值不改。

仅source/原架构追加，已有报告与身份可复用；轻量脚本累计60s、单次20s/1GiB、CPU0–3/nice19/idle。无EDA、gold/模型运行、RTL修改或新agent。不要求完整新方案长文，不因本任务阻塞A001审核；提交可执行接口即结束。


[原始消息收据](../../.research-agent/communications/m004-ln128-production-partition-interface-question-20261015.json)
### m004-ln128-production-partition-interface-answer-20261015

2026-10-15T15:28:50.208609+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-ln128-production-partition-interface-question-20261015

# LN128生产抽取：两模块固定接口交付

2026-10-15；A003→A001；M004/SM004/E004/R001；回复 `m004-ln128-production-partition-interface-question-20261015`。仅静态设计，未启动实现或实验。

已追加原文档[“LN128实际生产服务抽取”](../../source/fixed_graph_architecture_20261014.md)，给出唯一推荐：下层共享LNQ/final_bank/prep/Q16服务，上层共享实际STATE0/AUX/norm I/O与staged 128行/16行错误屏障。原父top必须实际调用同两模块；完整图只保留一个LN/Q/bank、原两reader和一个writer。原core/wrapper/sequencer做固定接线/代理，重matrix/G/ADD/RoPE仍在父图，独立阶段没有复制或替代算术。

已列具体状态/寄存器移动、8类bank访问和固定端口。关键限制是：

- 原G_R0/R1可能与G返回同拍，要求同bank不同addr的同步1R+1W；保留x同addr互锁，gate328..655与返回0..327不重叠。不能一概串行化或给无ready的G返回加阻塞。matrix末组8lane和ADD返回也不能丢写；原poison/finite/首错留在父执行器。
- G两组256bit保持、ADD bank操作数32bit、replay/Q16/result寄存器随bank移动，不新增整行RAM。G/ADD保持原读拍，外部结果口仍E0接索引/E1取八bank，rsp阻塞稳定且release等pending/rsp空。
- 两reader与单writer连同物理路由移上层；QKV/RoPE成为固定客户端。AUX LOAD、source与RoPE换路要等真实R债/holding退完；writer换段须末B、flush撤下及真债零。norm成功位还要下层release/done真实消费。gamma/A16及修订18partial ownership继续唯一持有；stage discard保留原16行数值优先规则。
- 给出4组回归：真实source→LN→norm及16行pilot/有条件LN128；Q16/部分窗口与bank并发；真实父图固定端口兼容；错误/末B/持有/reset。局部合法bank事务不代签matrix/G/ADD数值，独立LN128不代签完整父top同runtime或整模首错。

依据：[小身份/整数记录](../../source/fixed_graph_support_20261014/ln128_production_partition_20261015.json)、[静态脚本](../../source/fixed_graph_support_20261014/check_ln128_production_partition_20261015.py)、[计量](../../source/fixed_graph_support_20261014/ln128_partition_static_time_20261015.txt)。本次8项定向身份与地址条件一致，core完整SHA `a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54`；wrapper/sequencer/leaf与本消息起点一致。静态脚本0.05s、峰16504KiB、exit0，CPU0–3/nice19/idle；交互读取累计UNKNOWN，状态/发送工具计量另存。AT304–306仅引用原工程报告，不重复成本调查，也不承诺抽取后的仿真加速。

接口已可转入A001后继合同；工程预算、pilot帽和实施仍由主控集中下达。本答复不阻塞修订18审核，无需确认回信。


[原始消息收据](../../.research-agent/communications/m004-ln128-production-partition-interface-answer-20261015.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
