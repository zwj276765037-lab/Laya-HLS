# E022：AT024候选只读报告实际运行

execution_state: running
verdict: inconclusive

一次opt已完成且候选合法性/完整边界/源码/清理已核。当前候选core LUT2091399仍超器件和900000预算，资源不通过。AT024于UTC20:35:22.805725真实启动，guard493551/start73656443、Vivado493764/start73656883，只复开候选做资源/primitive与global/fixed各1条setup。opt总调用保持1，无place/route或全父后继。

最新采样：

```json
{
  "utc": "2026-10-26T20:37:38.497232+00:00",
  "elapsed_seconds": 135.4806356059853,
  "owned_rss_kb": 6056312,
  "available_kb": 444334460,
  "owned_CPU_ticks_observed": 10563,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}
```

下一步核AT024实际报告/路径/版本身份/清理与全账，及时补发部分发现，再按既定资源出口交主控集中判断。原30层功能不重跑，RTL/约束/数值保持；主控两小时用户通知保持。


---
Published: 2026-10-26T20:37:39.785848+00:00
Publication: Pbcb96229b6774cfebf240a63c8c6a926
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
