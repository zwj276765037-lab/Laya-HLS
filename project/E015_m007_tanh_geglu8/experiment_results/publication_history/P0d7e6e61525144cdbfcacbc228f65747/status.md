# E015：G-COMPACT-14有界阶段完成，联合范围仍开放

- execution_state: completed（仅本次G紧凑控制与受影响功能/周期阶段）
- verdict: supported；G-only1963.625B≤2048B，完整原正常及rank0/2/5/7错误/实际恢复、公开身份与真实债反例通过
- applicability: 当前G math/pool compact16与build090/101–105；无parent/联合物理范围升级
- 归档：AT125 release audit PASS；最终123笔终态receipt，无非终态receipt或live owned E015 guard
- 原reference900/static1800/RTL3000/OOC1800秒累计帽不重置、不转移。最终剩余reference893.77314188299351381/static1423.02549084179918504/RTL725.332723504077894/OOC1023.92452523694374秒；保留≥120秒RTL短例/归档余额
- 异常：AT092 probe stall、AT096/100真实clear/seq0缺陷、AT119零child gate stop、AT124 audit cwd FAIL均保留/计费，修复边界见handoff；无改gold或删覆盖
- 下一边界：A001集中审核并另定父级真实物理控制复用；联合4KiB/SFU/896DSP/父FFN/Decision/物理300MHz仍OPEN，本段不再启动仿真/OOC或变共享接口


---
Published: 2026-10-22T11:03:45.432534+00:00
Publication: P97fbc5edd1134bb2ae0a2662fff6877a
Execution state: completed
Research verdict: supported
Applicability: Bounded G-COMPACT-14: current G-only15709-bit control target and affected complete original normal/rank0/2/5/7 plus actual public lifecycle/domain recovery; joint4KiB/parent/physical and wholeFFN remainOPEN
Evidence:
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT106_g_compact16_explicit_context_state_census/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT107_g_compact16_explicit_context_input_domains/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT108_g_compact16_explicit_context_seq_alias/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT111_g_compact16_old_generation_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT112_g_compact16_wrong_epoch_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT113_g_compact16_reserved_field_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT114_g_compact16_extra_FP_before_real_return/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT115_g_compact16_explicit_context_status_recovery/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT118_g_compact16_complete_original_normal/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT119_g_compact16_complete_rank0_recovery/receipt.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT120_g_compact16_complete_rank0_recovery_exact_command/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/g_compact14_source_delta_v2.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/g_stage_handoff_20261022.md
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT121_g_compact16_complete_rank2_recovery/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT122_g_compact16_complete_rank5_recovery/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT123_g_compact16_complete_inverse_row_recovery/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT125_g_compact16_final_release_audit_project_cwd/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/g_compact14_handoff_20261022.md
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/g_compact14_final_budget_20261022.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT124_g_compact16_final_release_audit/receipt.json
