# E022：AT021 core_opt实际运行

execution_state: running
verdict: inconclusive

AT020已完成并核PASS执行/源码/清理/锁；当前综合态core资源及setup明确不通过。旧serial和AT020 guard已退出回收且无facade；AT021仅执行已授权的一次同DCP优化诊断，当前opt调用标记存在=False，未产生候选结果。

最新实际采样：

```json
{
  "utc": "2026-10-26T19:43:59.695481+00:00",
  "elapsed_seconds": 130.58673610899132,
  "owned_rss_kb": 6383720,
  "available_kb": 443044924,
  "owned_CPU_ticks_observed": 13660,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}
```

下一步：真实core_opt收据及候选边界/原DCP身份核验后，仅启动report_core_opt，及时上报资源部分结果和两条setup观察，再集中判断后继。无自动完整父装配/place/route；不重综合/功能，不改RTL。主控继续两小时用户通知，A010不停止计时器。


---
Published: 2026-10-26T19:44:50.370068+00:00
Publication: P8888da8aa4f5487db15dedf792ebb7ff
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
