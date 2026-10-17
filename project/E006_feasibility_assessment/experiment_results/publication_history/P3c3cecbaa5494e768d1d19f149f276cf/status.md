# E006 实验状态摘要

- execution_state: running；verdict: unassessed。AT073最后一次正常full已在原3600s/8GiB/40M/120s真实semantic guard下启动，preflight原236加候选22项ACCEPT；不能把成本估计当性能。
- AT065/AT070终态分别FAIL与COST_STOP；AT071短测FAIL、AT072受影响短测PASS、AT073静态与前缀PASS。旧full实际累计2796.627354s；AT073为第3/3次。
- 正常四行gold、TMP/HIDDEN保护、响应消费、独立合法反压完整样本尚未证；阶段A稳定性两样本上限已无法闭合。阶段B综合/route仍NOT_RUN；阶段C条件模型不因局部前缀更新。


---
Published: 2026-10-14T04:12:55.817519+00:00
Publication: P05adacccbd784a2e8f58004abe5c219f
Execution state: running
Research verdict: unassessed
Applicability: M005阶段A同top W接点短测PASS，AT073最后normal full运行中；整链/稳定性/物理未证
Evidence:
- project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT071_AT073_W_phase_fix_progress_20261014.md
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT071_M005_top_w_probe_01/guard_probe/driver.log
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT072_M005_top_w_phase_fix_01/guard_probe/driver.log
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT073_M005_top_normal_phase_fix_01/guard_pilot/driver.log
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT073_M005_top_normal_phase_fix_01/guard_full/launch.json
