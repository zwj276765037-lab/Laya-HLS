# GQD0：真实G→量化→KB1 Down有限接链与计量

D-M004-GQD-INTEGRATION-01；2026-10-13；M004/SM005/E005/R001。A002唯一实现、整合、工具owner；主控A001集中审核。承接测量优先计划及ATN1有限收束，直接在既有授权内执行，不增加逐项审批。

## 选择与本轮出口

下一阶段选择**一条四distinct行的真实G→GATE写入/重读→量化→共享dualA→KB1 resident Down连续链GQD0**。目标是消除Down入口的预量化fixture注入，取得真实producer交接及该边界内的数值、完成和成本证据。它是新有限集成基线，不是完整请求B0，也不是第二个Attention或其它算术优化候选。

选择有直接身份依据：原`t2_geglu_gate_quant_bridge_rtl_04`使用四行enc0 Wi输出，计算真实10496个GATE F32、328量化组并写完整dualA；AT002 KB1 Down是四行K2624/N1024。两端独立期望q.mem均21320B/SHA `7d99ba99cc3458df389add7b34483db5087f55a46cc5b29538ec363f1f4e8a76`，scale.mem均1640B/SHA `22a4b08447660550549fa4b2f509a61482e732be0dfdf0a1d43eff73989580c0`。主控与工程已分别定向核对；相同fixture只证明接点数据口径相容，不能把旧两份PASS拼成新链。

原G桥约94.855s、KB1完整Down约431.228s工具成本只用于准入参考；59975与43947cycles来自不同测试边界，不相加或相减声称新链性能。本阶段不为重新取得旧叶子数字单独重跑它们。

## 冻结来源与真实边界

G/量化侧从本项目E002副本内原bridge04冻结闭包派生：原canonical GEGLU算术、三个同步row bank、真实GATE AXI512 writer/末B、实际source读取和whole-row量化、完整dualA fill/commit/finish及身份规则。Down侧从AT002冻结闭包派生：原严格W加载/校验/完整lease、syncPS/native FP、335872 lane-group PS、KB1四pack writer及实际完成消费。算术图、数值规则、全部原容量与独立gold不变；不使用时序风险未解的LQ1/LQ1R，不重启KB2。

外部输入仅为声明的原四行Wi F32输出（20992 words）、真实Down权重/metadata、原身份配置与命令。上游Wi Q8仍未包含，允许原fixture作为该边界的输入。GATE、q/scale、PS、最终4096F32只能由链内真实DUT产生；独立gold只供比较。不得通过文件回灌、TB计算、层级poke或预装中间数据打通下游。

在**同一仿真进程、初始reset之后不在G/量化/Down之间复位**。共享一份真实物理dualA，量化写入的存储就是Down按完整身份取得并读取的存储；保留原双槽物理容量，本阶段只要求原四行单任务，不扩成双任务重叠。可以使用有限诊断driver发既有命令，原G桥TB诊断读口可作观察，但实际Down消费和lease release由真实consumer负责，不能同时由TB伪退休。

允许新增必要的有限RTL接线/仲裁/等价接口适配、driver及计量；不新建通用owner/权限/退休表，不将FullRuntime对象重新引入生成。若两份冻结接口有版本差异，逐字段说明slot/epoch、672bit numeric identity、96bit linear context、A ref、row block/group与完整key的映射，保持真实validate-before-commit和稳定返回。普通等价映射连续修复；必须改变既定身份/权威或跨分区合同的具体缺口才交主控裁定，不把所有接口工作预先升级为审批。

## 数值、流控与完成

- 对原20992个Wi输入、10496个真实GATE输出、328组d/reciprocal/q/saved-half及Down实际读出的q/scale/完整身份逐项关联原独立gold；保留完整335872 PS lane-group、4096F32与512 TN8 packet验证。量化A的有效位、ready及返回都来自真实producer，不由driver强置。
- GATE存储模型只由实际AW/W/WSTRB更新，量化从该模型的真实AR/R重读；保留原656写拍/656读拍与末B/source债务规则。Down按KB1实际256 AW/W/B、16384有效/物理字节完成。不同输出端口的交易分别计数，不能混作一个发布端点。
- 保留G桥及KB1原已声明的AXI供数/响应策略、有限返回保持和Down done7拍反压；新增连接背压遵循ready/valid与完整payload稳定，不能缩短TB延迟来制造收益。若薄接线必需引入额外等待，计入新基线并说明。
- Down只能在真实A完整且可acquire后发射；GATE末B/源读债、A/W lease、PS及Down末B/局部publication与一次实际done消费按原次序闭合。正常运行中保留原外层身份拒绝/零issue和末B不得早发布等受影响检查，不能以软件通知替代真实完成。

本阶段先取得完整normal连接证据。原未测的晚错、活动reset、全局恢复、生产13BO/唯一软件退休和双任务重叠仍列未验证，不把它们先扩成新的控制关键路径。未变叶子证据按身份继承；若连接发现真实错误，保留失败、隔离本样本、仅修受影响边界，不降低断言或gold。

## 计量与有界执行

首先给出一张有限连接/身份表，然后直接完成实现与static→≤120s pilot→有依据的四行完整run。不是先交新规划再等逐项批准。pilot用同一冻结闭包的真实前缀，明确实际到达的G、量化、A交接、Down阶段；不得用预填A让pilot看似到达下游。若120s内未到达Down，可采用原同身份Down实测成本与新上游pilot分阶段保守估计，但不能把单阶段速率线性担保整个新链；仍无法证明在帽内可承受时交有据成本停止，不加帽。

至少报告：初始reset释放→最终真实done消费的完整冷TB区间；首个实际G任务接受→最终Down消费的链区间；权重加载/验证、Wi供给、G写入、量化重读与A ready、Down cfg/首次done/实际consume及最后B的事件时间戳。计算区间不去掉真实加载/交接/排空开销；诊断读回和故意等待另列。并行阶段用事件表或明确互斥状态，不把重叠等待相加；本单任务不声明稳态吞吐或暖态收益。

完成后交付同runtime真实数据链、独立数值与末B/lease证据、新基线周期及主导成本、连接变化与新增逻辑存储账。无需再跑一个“故意fixture注入”的假基线，也不本轮追加算术改进候选；根据GQD0结果再集中决定向上接真实Wi或其它有据下一步。

只做一个接链实现，最多两轮有具体原因的受影响实现/runner修复；重复同点无新依据即停止。不改shape、表容量、精度或模型来省成本，不重启已关闭候选。当前GQD0尚NOT_RUN，旧两段证据不能预签接链成功。

## 所有权与不变约束

唯一代码根仍E002/experiment；新运行及三摘要在E005/R001。从本项目复制树显式映射/冻结旧路径，禁止写旧baseline；已有helper按原职责复用，不新增agent。A002自主串行排队，主控不运行DUT工具。

原全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB、static24GiB/1800s、RTL8GiB/3600s/40Mcycles、pilot≤120s及120s真实语义停滞保护不变。**不新开HLS/OOC/P&R/上板，不恢复整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup**。G2338.224019s仅原OOC余额，5172s组合不重启，无新预算。

ATN1作为已验有限候选保留，物理/生产接入仍未验；KB1沿本次真实链继续验证。完整28+2层/122矩阵、CPU/FPGA分工、全请求正确性/性能/恢复/联合资源与M003/M004最终目标保持，GQD0完成不能关闭总mission。

依据：[测量优先计划](hardware_measurement_replan_20261013.md)、[ATN1终态审核](../results/measurement_first_ATN1_close_20261013.md)、[接点身份核验](../results/measurement_first_ATN1_close_20261013/verification.json)、[原桥04收据](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json)、[KB1比较](../project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_comparison_20261013.md)。
