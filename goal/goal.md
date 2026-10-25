# Laya-HLS Goal：完整Attention在FPGA的高性能推理部署

revision: 9 / 2026-10-21
execution_state: paused
verdict: unassessed
primary_mission: M007

实现单U55C＋CPU上的完整Laya推理：FPGA执行全部30层Attention和驻留主干，CPU执行输入准备、Embedding/初始LN及scorer/ACT尾部。保持原模型、完整形状和严格数值语义。

以完整真实请求的正确性、持续有效算力和端到端性能为目标，交付可复现硬件、Host与CPU后端。性能目标为热请求P50≤50ms、P95≤55ms、单上下文持续≥18QPS，并与本地单张RTX A6000按相同请求边界实测比较；目标不是已实现结论。

完成须具备完整图独立验证、同版本联合资源/布线时序、真实部署和连续请求证据；局部仿真、理论峰值或诊断CPU Attention不替代整体验收。

详细架构、模块指标、接口、实施阶段与预算以[M007](../mission/M007_完整Attention高性能主干与部署闭合/contract.md)为唯一当前合同。用户2026-10-21授权新任务和GPT-6.1-Sol子智能体推进；旧M004/M006队列与原余额不自动恢复。[此前Goal v8](history/goal_v8_before_m007_20261021.md)及历史结果保留。


2026-10-22执行更新：用户明确“继续任务”，按M007现行合同恢复；此前八lane收尾暂停作为历史保留，已验范围和独立预算不重置。当前入口为mission/current.md及results/missions/M007_resume_20261022.md。


2026-10-24暂停落实：D35实际28Encoder前缀PASS、final gamma LN原断言FAIL，完整30层未通过。按用户验后暂停要求收尾，不自动修复或重跑；最新事实见mission/current.md及results/missions/M007_summary.md。

2026-10-24最新授权：用户明确同意修复并从已保存Encoder27实际输出继续分段验证。仅恢复D36 final LN/type/Decision/tail受影响范围；不重跑28层前缀，完成本段后再次暂停。此前完整kind7 FAIL和未验收状态保持。

2026-10-24 D36收尾：gamma保持修复和保存实际H的完整后缀验证通过，未重跑前28层或修复版全30层一次BEGIN；证据/预算封存、owned进程清空，本段完成后再次暂停。

2026-10-24最新用户授权D37：创建子代理运行修复版完整30层一次BEGIN，常规每小时汇报，收尾后暂停；此前分段证据保持，不预签完整图。


2026-10-25 D37收尾（北京时间）：修复版正式参数0完整30层一次BEGIN正常RTL验证通过，全部层输出/finalLN/type/544尾部逐字同原参考，实际提交/DONE/idle正常。主控独立核验已完成，预算封存、owned进程清空，按用户要求暂停。M007整体物理/部署/性能及异常全覆盖仍未验收；最新证据见results/reviews/m007_fixed30_final_review_20261024.json。
