# Laya-HLS 目标

版本：v2，2026-10-11。工程评估完成并经主控核验后更新；[v1原文](history/goal_v1_pre_replanning_20261011.md)完整保留。[变更依据与任务关系](../results/controller_replanning_20261011.md)。

## 长期目标与最终验收

将真实 Laya Typed-Decisions Q8_0 微调量化模型实现为具有可核实性能改善、可部署资源预算的U55C加速器。先保证计算正确性与完整推理，再按真实请求性能和资源证据优化。50ms仍为远期参考，不是唯一硬门槛。

CPU负责token Embedding、输入/请求打包、固定权重一次完整校验与会话生命周期、XRT控制/同步及结果解码。FPGA承担后续全部LayerNorm、内部EMB_TYPE、动态activation量化、Q8矩阵、Attention、GEGLU/向量、Decision/scorer/ACT及真实响应退休；不将后续LN移到CPU。U55C为PCIe加速卡，Host是服务器CPU；沿用既有CPU/XRT/PCIe/HBM部署框架不能代替板端验证。

长期成功标准保持不变：

1. 同冻结模型完整B1/S128、28 Encoder＋2 Decision＋scorer/ACT、全部122 Q8矩阵，在当前实现身份下对独立参考验证数值、最终决策及故障后恢复。
2. 真实producer、缓存/lease/owner、AXI读写债务和最后B退休闭合。分段覆盖明确未覆盖的同runtime整图行为，不能代签整图。
3. 同模型/shape/反压/缓存/计量边界比较冷暖延迟、填充排空、完整请求完成间隔、有效服务与停顿。功能接通本身不证明性能改善。
4. 分别取得目标器件模块资源、联合无重复计费预算、真实物理时序与板端结果。所有未执行层级保持未验证。
5. 数据集准确率须冻结带标签数据集并建立同模型对照；少数请求逐位一致不能替代该结论。原A6000 50ms报告口径不同，继续不计算GPU加速比。

## 当前有效证据

[工程验收报告](../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)及其交付的18份文件已核验SHA256，完成轮次为01a129d6-a5eb-71d3-b2fa-f01e8eaac6f8；仅本轮评估completed，完整加速器NOT_ACCEPTED／证据不足。

- M001复制核对结论保留；旧build23c62cd4778f54e3cc7508f5d05558de的完整CPU/真实Vitis CSim通过。
- 当前46个生产编译依赖中7项改变，生成配置另有变化，旧完整回归不能代签当前源。
- resident Down、G三bank桥、Attention v10局部范围通过；外部Wi checkpoint、预量化A和独立局部恢复不证明同runtime真实生产整链。
- 当前G父与Attention OOC为COST_STOP，联合资源、完整请求性能及物理/上板均未验证。Attention两处历史文档SHA缺口单列保留，运行源引用匹配；不把文档缺口判为数值失败。

## 下一有界目标：M003 / SM003

在唯一E002实现副本上，建立可复现的当前build与真实输入身份，接通既有§3.9生产命令/完成通道和原13BO外层，证明由真实Wi Q8发起的Wi→G→quant→resident Down有界连续链及安全退休/恢复；稳定新身份后通过原完整CPU/实际Vitis CSim与受影响分段RTL。

具体合同见[M003](../mission/M003_当前身份生产链接入与回归.md)与[SM003](../project/missions/SM003.md)。E003仅作为本阶段新证据容器，代码仍唯一位于E002/experiment；当前planned，未启动实现或硬件工具。

本阶段通过要求新身份四持久请求、141独立检查点/18,094,384 F32及故障恢复；有界链保留原矩阵真实维度与独立gold，明确完整模型同runtime硬件覆盖缺口。它提供后续性能与资源评估所需的连接基线，不完成长期目标，也不关闭M002。

暂缓新增G/Attention OOC路线、Attention v10未验证生产补丁、LN/更宽Q8扩展、整图长RTL、整体OOC/P&R及上板。先交付真实服务计量和不重复计费的资源缺口表，再定义后继有界任务。依据：工程报告§3–§5的生产连接缺口、两项COST_STOP及TM4理想Q8约46.055Mcycles已超过40M RTL帽。

## 不变约束与协作顺序

原模型、完整shape/层数、独立gold、数值规则、错误优先级与CE/reset合同不改；真实数据、自检断言、超时保护、源码/输入身份和原始日志保留。未变且通过的证据按身份复用，只重跑受影响范围。原baseline不删、不移、不写回。

全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s、120s真实语义停滞保护。G累计OOC原余2338.224019s保留，不能因新M/E登记重置。整体OOC/P&R/专项时序、无板条件下的部署均不由本轮启动。

合作顺序固定为：工程先完成评估并交付result和校验标记→主控核验该轮次、报告/result/三摘要身份→结合历史goal/mission更新目标与任务。共享登记由主控唯一维护。工程GPT-6.1 Sol/xhigh连续实现与常规修复，GPT-6 Astra/xhigh集中评判；请求配置与实际运行证据分开，未核实实际模型保持null。取消逐轮人工审核的偏好与已有授权保留；本轮仅完成重规划，等待后续工程执行任务。
