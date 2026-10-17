# Laya-HLS 当前概览

**工程评估与主控重规划完成；完整加速器尚未验收。下一阶段M003已定义，尚未启动。**

| 范围 | 当前结论 | 证据与限制 |
| --- | --- | --- |
| M001/E001复制 | completed / PASS_COPY_VERIFIED | 原210038文件双侧SHA及6100 links结论保留；原baseline未改 |
| 旧完整CPU/真实Vitis CSim | PASS_SCOPED | build23c62cd4，4持久请求、141点/18,094,384 F32与恢复；当前7项编译依赖变化，不能代签 |
| resident、G三bank桥、Attention v10 | PASS_SCOPED | 局部原身份；fixture输入、tile/head协议覆盖差异明确保留 |
| 当前G父、Attention OOC | COST_STOP | 无final资源/DCP；G原余2338.224019s不重置 |
| 当前完整回归、真实生产链/13BO | NOT_RUN / 证据不足 | M003优先闭合真实producer、退休/恢复与当前身份 |
| 联合fit、完整请求性能、整图RTL、准确率、P&R/Fmax、板端 | 未验证 | 无U55C；局部cycles或条件150MHz不能代签 |

[工程报告](../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)已完成交付；主控核验真实完成turn及18/18文件SHA通过。[主控判断与goal变更](controller_replanning_20261011.md)，[核验收据](controller_replanning_evidence_20261011/handoff_verification.json)。Attention两处历史文档SHA缺口作为追溯限制保留，历史数值FAIL不删除。

[goal v2](../goal/goal.md)保留完整模型、数值、吞吐、资源与部署长期目标；[M003](../mission/M003_当前身份生产链接入与回归.md)/SM003/E003将下一步收敛为当前身份→§3.9/13BO→真实Wi→G→quant→Down→安全退休/恢复→完整CPU/CSim及受影响分段RTL。唯一实现根仍是E002/experiment，E003仅为新证据容器。M002未完成，重叠连接工作不重复派发。

A002当前评估交付completed，A001当前重规划completed；均不表示新实现已运行。实际模型/强度无运行证据保持null，请求分工和单重工具预算不变。后续工程执行从M003 L0开始，本轮未启动硬件工具。

固定协作顺序：工程交付result与handoff→主控核验→更新goal/mission。当前无新增用户决策请求；常规修复不逐轮审批。
