# E022：工程诊断完成，完整顶层物理被core容量门阻塞

execution_state: blocked
verdict: inconclusive

局部判定明确：优化后core资源FAIL（LUT2091399>器件1303680及完整核预算900000）；原300MHz下所取global/fixed setup均FAIL（-1289.374ns、6090级）。完整top/P&R/最终setup-hold/平台shell/上板结果仍未验收，因此整体结论不冒充已完成原物理目标。

已完成授权的同DCP唯一opt、独立候选资源/primitive及两条setup观察、版本/费用/清理核验。AT023/024执行PASS；两次pre-opt脚本FAIL及费用保留，不当方法失败。当前没有任何owned重工具、serial、guard或排队后继，锁已释放；原/候选DCP和190017位port/clock/XDC完整边界已核。A010本轮工程任务完成。

下一步由主控集中审核实际容量/长控制链与映射证据，并定义后继架构/实现范围；A010不自动启动facade/完整parent/place/route、重做opt、重综合/功能或修改RTL。全局M007目标仍未达成，旧任务/PS候选不恢复。两小时用户通知及实际阶段收尾停表由主控负责，A010没有改动计时器。

最终收据/状态：project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_final_engineering_receipt.json 与 core_opt_diagnostic_final_state.json。


---
Published: 2026-10-26T20:59:14.009870+00:00
Publication: P1da0aeb88e96456e9da255967d19a2cd
Execution state: blocked
Research verdict: inconclusive
Applicability: 当前同f849/91源/ROM/父11generic/300MHz完整matrix core一次opt资源及bounded setup失败已实测；完整top/P&R受容量门阻塞，未代签全局目标
Evidence:
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_final_engineering_receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_final_state.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/budget_ledger.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/execution_time_policy_v2.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/checkpoints/core_synth.identity.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/checkpoints/core_opt.identity.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/AT020_core_report_completion_engineering_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/serial_exit_receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/checkpoint_top_report_identity_fix.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT022_core_opt/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_completion_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_completion_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_reopened_resource_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_post_resource_finding.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/reports/optimized_worst_setup.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/reports/optimized_fixed_baseline_setup.rpt
