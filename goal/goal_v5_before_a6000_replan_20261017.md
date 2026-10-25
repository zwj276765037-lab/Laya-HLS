# Laya-HLS Goal v5：CPU–FPGA 协同的完整高性能推理

revision: 5 / 2026-10-17
document_state: ready
review_state: controller_prepared_from_user_request
execution_state: paused
verdict: unassessed
primary_mission: M006

依据用户“重新规定整个推理架构的硬件部分具体执行什么”及“写成一个新的goal和mission重点完成新架构高性能的实现”，本版替代旧 Goal 的软硬件职责与主线排程。用户提供的[CPU–FPGA 架构文档](../design_source/Laya_CPU_FPGA_Codesign_Architecture_20261017.md)作为设计依据；[Goal v4 原文](goal_v4_before_codesign_20261017.md)保留。

**本轮完成目标与任务文件。此前“先暂停，等我通知”仍约束工程和实验；本文件不声称用户逐条审定了新接口，也不自动恢复工作或继承旧实验预算。**

## 总目标

**实现一套面向 U55C 的 CPU–FPGA 协同 Laya 推理系统：保持完整模型和数值正确，使 FPGA 持续承担高收益的大矩阵及完整 FFN，交付可复现的完整请求低延迟、持续高吞吐和物理可实现性证据。**

工作的主体是生产实现、系统集成与性能优化。性能预算和测量用于指导实现；增加局部 PASS、缩短仿真耗时、完成可行性报告或提高算子上板比例，都不能代替该目标。

## 首版职责

| CPU | FPGA |
| --- | --- |
| 请求与模型管理、Embedding、embedding LN、主线所有 LN | 完整 QKV 矩阵服务 |
| RoPE、QK、mask、softmax、AV，即完整 Attention | 完整 WO 矩阵服务 |
| 所有 residual；保有权威 hidden 与 skip | Encoder 完整 FFN：Q→Wi→GEGLU→Q→Down |
| Encoder–Decision 的 final LN/type add、完整 scorer/ACT 尾部 | Decision 完整 FFN：Q→FC1+bias→ReLU→Q→FC2+bias |

硬件服务包含激活量化、INT8 点积、group32 FP32 恢复、按规定顺序累加、适用的 bias 和结果打包。CPU 提交完整矩阵/FFN，不参与 tile/group 的逐项调度。三类服务可共享矩阵引擎；FFN 宽中间量留在设备内。首版激活边界 FP32，主线权重持久驻留 HBM，再装入片上工作集。

## 性能必须从架构开始

- 按持续有效 MAC/cycle、A/W 供给带宽、FP32 恢复吞吐和真实写回速率共同选择阵列与缓冲规模；不将旧阵列尺寸、单槽容量或全局串行 FSM 固化为新设计上限。
- 支持有界预取、装载与计算重叠、权重跨行复用、独立输出交错以及充分流水。保持每个输出的数值依赖，明确在途窗口、所有权和有序提交；不继承旧“后续 tile 零读取”等限制作为默认执行规则。
- CPU 使用满足原数值规则的编译实现，采用适当 SIMD/多线程；完整请求性能计入 CPU、布局复制、DMA、同步、FPGA 和尾部。单请求延迟与多请求吞吐分别测量。
- 根据持续算力、真实带宽、资源和时序及早调整设计。正确但缺少端到端性能收益时，性能目标仍未完成。

## 保持的模型与正确性

B1/S128、28 Encoder＋2 Decision＋完整 scorer/ACT；保留原权重、全部 122 次 Q8 矩阵运算及其他模型计算，其中 120 次主线矩阵在首版 FPGA 服务内，2 次尾部 Q8 在 CPU。final18 仍为 16 个 masked logits＋2 个 ACT logits。

保留 group32 量化、规定的 FP32 中间舍入/非 FMA、归约和累加次序、非线性、mask 与逻辑首错。未经新授权不裁 token/候选、缩层、早停、近似非线性或改变精度。独立参考不随 DUT 改写；CPU 通用数学库不能默认视为等价实现。

## 完成标准

1. 交付实际可构建运行的 CPU 后端、三类 FPGA 服务、Host/XRT 调用与部署说明；完整请求和重复请求按独立参考验证，错误不发布成功结果。
2. 同版本联合实现具有资源、存储容量和物理时序证据，包含平台配套，不能仅用局部 HLS/OOC 结果推断 U55C 可部署。
3. 提供同模型、输入、数值规则及明确 CPU 核数/并发数的完整系统对照，报告单请求 P50/P95、持续 QPS 和主要瓶颈。对合理优化且数值兼容的 CPU 基线取得可重复、超过测量波动的收益；已改善和未改善的指标分别给出，不能用吞吐提升冒充单请求加速。
4. 交付实际预算与优化前后证据，包括算力利用、传输、权重工作集和资源代价。绝对延迟、倍数、频率和利用率目标尚未指定；在实现早期依据测量形成可核验的阶段指标，50ms 等历史数字不作为批准门槛。
5. 离线正确性、RTL 周期、综合/P&R 和实板测量分层交付。当前无板卡时继续完成可做的实现与离线验证，实板性能保持 NOT_RUN，整个部署/实测目标不能提前宣布完成。

## 主线与后续扩展

唯一当前主 Mission 为 [M006：CPU–FPGA 协同高性能推理实现](../mission/M006_CPU_FPGA协同高性能推理实现/contract.md)。先完成上述分工和持续供数的实际系统，再依据完整路径收益评估 LN/residual 连同 hidden 驻留迁入 FPGA，以及后续完整 Attention 迁移。可在资源与隔离明确后采用两个请求工作区重叠 CPU 与 FPGA 工作，不建设无需求的通用动态调度框架。

M004/SM004 保留暂停、未完成及未审核范围；旧代码和证据按身份复用，不要求先完成全部旧控制测试才进入 M006，也不把旧局部通过升级为新架构通过。工程唯一实现根仍为 project/E002_Laya_HLS/experiment，原始 Laya-baseline 不改。
