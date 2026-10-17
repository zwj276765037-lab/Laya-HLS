# Laya-HLS 目标

将真实 Laya Typed-Decisions Q8_0 微调量化模型实现为具有可核实性能改善、可部署资源预算的U55C加速器。来源：用户要求先做到计算性能与推理准确度，再考虑最终综合时序；性能同时考虑请求流水吞吐，50ms仅为远期参考。

CPU负责token Embedding、输入/请求打包、固定权重一次完整校验与会话生命周期、XRT控制/同步及结果解码。FPGA承担后续全部LayerNorm、内部EMB_TYPE、动态activation量化、Q8矩阵、Attention、GEGLU/向量、Decision/scorer/ACT及真实响应退休；不将后续LN移到CPU。U55C是PCIe加速卡，没有承担这些Host工作的独立通用CPU，Host是服务器CPU。沿用两个Llama baseline的CPU/XRT/PCIe/HBM部署框架，不能因此假定板端已通过。

## 成功标准

1. 同冻结模型完整B1/S128、28 Encoder＋2 Decision＋scorer/ACT、全部122 Q8矩阵，在当前实现身份下对独立参考验证数值/最终决策及故障后恢复。
2. 模块连接证明真实producer、缓存/lease/owner、AXI读写债务和最后B退休；分段替代覆盖必须列出没有覆盖的同runtime整图行为。
3. 同一模型/shape/反压/缓存/计量边界比较冷暖延迟、填充排空、完整请求完成间隔、有效服务及停顿，功能接通不能直接写性能改善。
4. 分别取得目标器件模块资源、联合无重复计费预算、真实物理时序与板端结果；未执行层级保持未验证。

原模型/完整shape/层数/独立gold及数值规则不改；真实模型数据、独立参考、自检断言、超时保护、原始日志与源码/输入身份必须保留。未变且已通过的测试复用原身份，只重跑受影响范围。

当前事实：旧冻结build完整CPU及真实Vitis CSim通过；多块局部RTL/OOC有范围通过，当前完整13BO物理生产连接、全图硬件和上板未通过。准确率需要冻结带标签数据集与同模型对照，几个请求逐位一致不代表数据集准确率。A6000原50ms报告口径不同，暂不计算加速比。

全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s，120s真实语义停滞保护。只管理本项目owned进程。整体OOC/P&R/专项时序未在此接入阶段启动，无U55C，不影响服务器其他项目。
