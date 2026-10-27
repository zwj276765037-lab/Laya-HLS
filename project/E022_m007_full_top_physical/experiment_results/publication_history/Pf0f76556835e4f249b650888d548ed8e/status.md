# E022：AT023 core_opt实际运行

execution_state: running
verdict: inconclusive

AT021/AT022均在任何opt调用前因顶层身份API检查FAIL：current_design.NAME实际为checkpoint_core_synth（容器名），checkpoint会话current_fileset.TOP实际为空。两次434.210852844s和455.505928938s费用/冻结源/源码核验/清理均保留，候选无、opt总调用0。这不是硬件或方法失败。当前改为从实际report_utilization标头严格解析并核Design=laya_m007_matrix_engine_v1及Device=完整器件，结合原DCP SHA/dcp.xml绑定；解析已用AT020原报告在Tcl中验证。before同口径utilization直接复用，after边界另存实际utilization，完整端口/时钟/约束与零BB检查保持。新Tcl bda4ee1ba816bc28758d46983fe5fc19bc9da78e30175d261a4a059adaa222d5，guard4b6d3135...与canonical421649...不变；无RTL/约束/数值修改。

AT023已实际启动，当前opt调用标记存在=False，候选尚无。最新采样：

```json
{
  "utc": "2026-10-26T20:02:18.753616+00:00",
  "elapsed_seconds": 72.27059653797187,
  "owned_rss_kb": 5022176,
  "available_kb": 431468980,
  "owned_CPU_ticks_observed": 7895,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}
```

继续一次opt及独立report_core_opt资源/两条setup观察，真实结果后集中审核；无自动facade/全父/place。主控两小时通知保持。


---
Published: 2026-10-26T20:02:19.332497+00:00
Publication: P2c86e925e0e343c59b98653c920f5f9a
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
