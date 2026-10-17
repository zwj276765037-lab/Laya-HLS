# 新对话从这里开始

请在 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS` 使用 `$research-agent` 继续Laya-HLS，硬件工作遵守hardware-agent。先阅读本地AGENTS、goal/goal、mission/current、results/overview与review_queue，再读取E002三摘要。原baseline完整保留；未来只写 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment` 及本项目原生记录。

## 已经完成和仍未完成

E001完整复制与一致性核对PASS。E002只是继承当前硬件基线，**完整加速器、同runtime13BO整图RTL、资源fit、物理时序和上板未验收**。具体当前模块终态以 [阶段结果](project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md) 为准。旧冻结build23c62cd4完整CPU/CSim四请求、141点/18,094,384 F32及gamma故障恢复PASS；它不能给已改变的新working源身份代签。已知历史数值FAIL、覆盖FAIL、成本中止全部保留。

## 优先恢复的工程工作

1. 核对当前源码/输入身份及已结束工具，不将旧注册A运行状态带入新项目；按agent/model_policy与实际运行工具启动/登记负责人。
2. 按[联合设计§3.9](project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/source/design.md)接真实生产C闭包命令/完成FIFO、持久物理服务和原13BO RTL外层：实际BO基址/role/offset，AR/R及AW/W/B债务与RRESP/BRESP/最后B。
3. resident Down、G三bank桥、Attention新tile各以当前封存终态复用。外部冻结Wi checkpoint不能替代上游Wi矩阵producer；外部prequantized A/W不能替代物理缓存链。Attention保留原逐row数值首错、CE/reset及生产caller协议；保存的UNVERIFIED补丁不是已应用/通过实现。
4. G三bank功能已通过，但新父OOC成本中止，完整资源/新RAM映射仍UNKNOWN。§8.4.11为未运行的分层OOC备选，保留原累计预算，不原样加帽。Attention若新OOC终态非PASS，按其实际范围恢复，不能复用旧helper DCP代签新CE namespace。
5. 稳定接入身份后重跑受影响完整CPU/CSim及真实分段RTL，用实际pilot估成本，列整层/整图替代覆盖与缺口。以真实性能/资源账决定LN服务、更宽Q8或多请求调度，不先扩阵列再忽略存储/反馈/输出。

## 工作方式

用户取消每轮人工审核：GPT-6.1 Sol/xhigh连续实现与验证；GPT-6 Astra/xhigh在实际综合结果后集中评判和优化方案。不得默换模型。只报告实质阻塞、阶段完成或最终结束。全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s，120s真实语义停滞保护。只管理本项目owned进程。整体OOC/P&R/专项时序未在此接入阶段启动，无U55C，不影响服务器其他项目。

本项目A001–A003是未来角色登记，runtime/thread/actual_model为空；本次没有替用户创建新Desktop对话或启动新硬件实验。已有授权常规修复不用重新确认，但新对话仍须读取当前任务合同，不能将登记等同实际执行。

## 已建立的职责对话

2026-10-11已在Codex的Laya-HLS分区创建并绑定四个职责对话。后续直接从[工作对话入口](agent/work_chats.md)进入主控、工程、研究或问答，无需另建对话。上文“本次没有创建Desktop对话”仅描述之前工程复制接入阶段。当前初始化只读核对，未启动新的硬件任务。
