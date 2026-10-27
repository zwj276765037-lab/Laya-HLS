# E022：AT022 core_opt实际运行

execution_state: running
verdict: inconclusive

AT021在open_checkpoint完成后、任何opt调用前因将current_design.NAME误作RTL top而FAIL；434.210852844s/峰15.724281GiB的费用及冻结源保留，source_verify_after真且工具/guard已清理、锁释放。原DCP dcp.xml明确Top/Part正确。本机Vivado原生脚本使用current_fileset.TOP，已据此修正严格top断言并保存实际container NAME和fileset TOP；新Tcl SHA495573622bfaf2c7ecca61c7d05612e3dfd5da1589c41f015baf5b511428e289，guard4b6d3135...及canonical421649...不变。这是脚本API检查修复，不是硬件/方法失败，也未消耗唯一opt调用。

AT022已实际启动，当前opt调用标记存在=False，候选尚未形成。最新采样：

```json
{
  "utc": "2026-10-26T19:52:16.478039+00:00",
  "elapsed_seconds": 55.407453538966365,
  "owned_rss_kb": 4996900,
  "available_kb": 456426192,
  "owned_CPU_ticks_observed": 6142,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}
```

继续既定一次opt及独立report_core_opt资源/两条setup路径观察；无RTL/约束/数值修改，不自动facade/全父/place。主控两小时通知保持。


---
Published: 2026-10-26T19:52:16.845205+00:00
Publication: P09fce213480b4c099176ea08a66417f5
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
