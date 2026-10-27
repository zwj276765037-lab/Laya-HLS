# E022：候选资源复核完成，两条setup观察运行

execution_state: running
verdict: inconclusive

AT024候选已独立复开并完成实际资源/层级/primitive报告：LUT2091399/FF1391977/DSP4352/BRAM、URAM0与AT023 after完全一致；190017位port/clock/XDC完整边界也与AT023 after字节相等。层级本层1899196+dot_array137930+format54273=2091399；对应降低47571/32/513，合48116，本层单独仍超器件。raw直接LUT2241625→2187052（减54573），FDRE1065764、MUXF7/8 402340/196736不变。共同导出的g_operand_slot六个名称/primitive组计数均未变：FDRE1048576，五个导出LUT组之和1058681；导出前256组不是全部513/511组，未导出组不按0处理，也不换算为combining后LUT或完整cone因果。两条setup路径观察仍待最终核验。

最新实际采样：

```json
{
  "utc": "2026-10-26T20:49:10.575731+00:00",
  "elapsed_seconds": 827.5662708779564,
  "owned_rss_kb": 17383204,
  "available_kb": 432741480,
  "owned_CPU_ticks_observed": 114551,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}
```

下一步只核global/fixed最多各1条实际路径、AT024最终收据/来源/清理及费用，交主控集中判断；不place/route，不重做opt。主控两小时通知保持。


---
Published: 2026-10-26T20:49:11.607928+00:00
Publication: P48acbd97843945a6ad243c0776c01eb1
Execution state: running
Research verdict: inconclusive
Applicability: 同f849/91源/ROM/父11generic/300MHz完整matrix core一次opt资源不通过；AT024后路径观察运行，完整top/最终物理未验收
Evidence:
- project/E022_m007_full_top_physical/experiment_results/runs/R001/AT020_core_report_completion_engineering_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/serial_exit_receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/checkpoint_top_report_identity_fix.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT022_core_opt/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_completion_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_before_resource_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/reports/after_utilization.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/checkpoints/core_opt.identity.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_launch_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/launch.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/live_status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_reopened_resource_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_post_resource_finding.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/reports/optimized_utilization.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/reports/optimized_utilization_hierarchical.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/reports/optimized_direct_name_groups.tsv
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/reports/optimized_direct_primitive_counts.tsv
