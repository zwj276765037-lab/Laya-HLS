# 硬件进度

2026-10-11工程评估与主控核验完成；本轮未运行CPU/CSim/RTL/OOC/P&R或板卡。依据[工程验收报告](../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)和[重规划](controller_replanning_20261011.md)。

旧build完整CPU/实际CSim及resident/G/Attention局部证据按身份保留。当前源码与旧完整回归有7项编译依赖差异，真实生产cmd/rsp/13BO与同runtime Wi→G→quant→Down、安全退休/恢复尚未验证。G父与Attention新OOC为COST_STOP；联合资源、完整请求性能、整图RTL与物理/板端保持未验证。

下一阶段[M003](../mission/M003_当前身份生产链接入与回归.md)/SM003/E003 planned：身份→生产门户→真实链→恢复→稳定build完整CPU/CSim与受影响分段RTL→证据交付。代码仍在E002/experiment，E003存新阶段证据。无新增OOC或整图长RTL，G累计余2338.224019s不重置；未变叶子不重复重跑。

## 最新用户范围修订

当前总mission改为[M004完整搭建与性能优化](../mission/M004_完整Laya加速器搭建与性能优化.md)。此前M003局部连接是前置，不是总目标终点；SM004推进全模型，SM005推进完整请求性能和当前资源闭合。用户不设具体性能门槛，但要求尽量高性能与可核实优化。原记录为修订前阶段说明，新范围以[本次修订](mission_scope_revision_20261011.md)为准。硬件证据未新增，当前仍未验收。
