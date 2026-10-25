# E015：G-RING-TAG-15完整回归中

- execution_state: running
- verdict: unassessed
- 已验：G-only1707.625B、math11343bit、满256同地址换槽/held/完整tag债/clear同seq0/status恢复及原三块通过
- 当前：AT146完整正常运行，full rank0与inverse-row待实际终态；rank2/5仅按原AT121/122身份复用
- 原RTL启动AT146前剩575.399780435051088秒；活跃费用不提前伪报，原预算不重置/转移，每次后续长例前重核≥120秒收尾余额
- 下一步：正常真实终态后full rank0，再以当前full-size实际成本限inverse-row；完成字段/源/归档审计交A001
- 联合4KiB/父物理共享/SFU/896DSP/FFN/物理300MHz仍OPEN，无OOC


---
Published: 2026-10-22T12:09:47.073147+00:00
Publication: P0d7e6e61525144cdbfcacbc228f65747
Execution state: running
Research verdict: unassessed
Applicability: Current high8 ring G-only census and short/domain/lifecycle tests passed; full current normal/rank0/inverse-row pending; prior rank2/5 identity reuse only; joint/physical open
Evidence:
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/g_ring15_source_delta_v1.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT133_g_ring15_exact_state_census/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT134_g_ring15_full256_same_address/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT135_g_ring15_clear_same_seq0_domains/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT136_g_ring15_three_groups/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT137_g_ring15_held_three_groups/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT138_g_ring15_seq512_vs256_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT139_g_ring15_old_generation_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT140_g_ring15_wrong_epoch_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT141_g_ring15_reserved_field_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT142_g_ring15_extra_FP_before_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT143_g_ring15_matching_status8_recovery/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT144_g_ring15_normal32768_cost_pilot/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT145_g_ring15_error32768_cost_pilot/work/report.json
