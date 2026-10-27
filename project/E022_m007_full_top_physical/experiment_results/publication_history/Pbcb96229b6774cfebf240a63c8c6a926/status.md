# E022：AT023唯一opt_design执行前置DRC

execution_state: running
verdict: inconclusive

AT023已实际完成before全部身份/边界、资源与有界primitive报告，当前唯一一次opt_design已开始，正执行原生前置DRC。实际util资源逐项等于AT020；190017位端口名字/方向与全部RTL声明机械枚举完全匹配，missing/unexpected均0。直接primitive3910950，raw LUT2241625；g_operand_slot名称组FDRE1048576，raw LUT1058681（LUT3 491520+LUT5 475136+LUT4 49152+LUT2 32825+LUT6 10048）。mul_a/mul_b/trace_commit_data各有raw LUT6 139264。名称归组不是combining后本层LUT1946767或单一源码因果结论，原始有界样例/可用源属性保留。尚无优化后候选/资源结果，未关闭或降级UTLZ。

最新采样：

```json
{
  "utc": "2026-10-26T20:15:18.039553+00:00",
  "elapsed_seconds": 851.5584364710376,
  "owned_rss_kb": 16376212,
  "available_kb": 441578296,
  "owned_CPU_ticks_observed": 92195,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}
```

若普通opt实际返回并生成合法候选，核真实收据/完整边界/原DCP身份及清理后，只读report_core_opt资源和两条setup观察；若工具合法性检查拒绝，保留实际错误，不重复opt或压低UTLZ。主控两小时用户通知保持。


---
Published: 2026-10-26T20:15:18.405243+00:00
Publication: Pf0f76556835e4f249b650888d548ed8e
Execution state: running
Research verdict: inconclusive
Applicability: 同f849/91源/ROM/父11generic/300MHz的matrix core；完整top及最终物理时序未验收
Evidence:
- project/E022_m007_full_top_physical/experiment_results/runs/R001/AT020_core_report_completion_engineering_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/reports/methodology.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/reports/netlist_checks.tsv
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/port_declaration_accounting.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/serial_exit_receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/engineering_launch_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/launch.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/live_status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/top_identity_fix.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/top_identity_fix.patch
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT022_core_opt/engineering_launch_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT022_core_opt/launch.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT022_core_opt/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT022_core_opt/live_status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT022_core_opt/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/checkpoint_top_report_identity_fix.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/checkpoint_top_report_identity_fix.patch
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_launch_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/launch.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/live_status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_before_resource_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/opt_invoked.txt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/reports/before_design_identity.tsv
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/reports/before_direct_name_groups.tsv
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/reports/before_direct_primitive_counts.tsv
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/reports/before_ports.tsv
