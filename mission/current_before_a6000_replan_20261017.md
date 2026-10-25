# 当前主任务：M006 CPU–FPGA 协同高性能推理实现

updated: 2026-10-17
execution_state: paused
verdict: unassessed
document_state: ready

用户要求将新架构写为新的 Goal 和 Mission，本轮文档已完成：[Goal v5](../goal/goal.md)、[M006 合同](M006_CPU_FPGA协同高性能推理实现/contract.md)。此前暂停指令仍有效，尚未恢复工程/研究实验或派发新执行。

首版 CPU 执行 Embedding、LN、RoPE/完整 Attention、residual、final LN/type add 和 scorer/ACT；FPGA 执行完整 QKV、WO、Encoder/Decision FFN，包含量化、group32 恢复与非线性。主线权重驻 HBM，FFN 宽中间量留设备，激活接口 FP32。

实施主线为 CPU 后端/粗粒度接口 → 持续供数矩阵 → 完整 FFN → 整模/物理集成。优化包括有界预取、装载计算重叠、跨行复用、独立输出交错及恢复流水；以完整请求延迟和持续吞吐为验收，局部 PASS 或算子上板比例不能代替。

M006 不以 M003/M004/M005 全部结束为前置。M004/SM004 保持暂停、未完成/未全部审核；AT404 待审、AT405–408 暂停时证据不在本轮补签，旧 FAIL/COST_STOP 和费用不改，余额不转入。见[旧入口原文](current_before_codesign_20261017.md)及[M004 当前记录](../results/missions/M004_summary.md)。

唯一实现根仍为 project/E002_Laya_HLS/experiment。用户明确恢复后，复用现有工程/研究会话，按 M006 登记首段范围与独立预算后连续实施，不逐次请求普通修复审批。无板卡的实测项保留 NOT_RUN；本轮未运行 EDA、模型或硬件验证。
