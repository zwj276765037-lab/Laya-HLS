# E022 report_core methodology运行，旧serial后继持留

execution_state: running
verdict: inconclusive

AT020 DRC已实际完成：16689项=UTLZ-1 Error1（LUT2139515>1303680）+DPIP-2 Warning8192+DPOP-3 Warning4096+DPOP-4 Warning4352+CHECK-2 Advisory48。OOC连接检查有未执行项；report_drc命令成功不等于设计DRC通过。没有关闭或降级UTLZ错误。当前继续原可选report_methodology，guard无deadline/trigger=null，旧serial仍T。AT020最终receipt尚待真实出口；然后仅按合同安全退出/回收旧serial，并做同DCP一次opt资源诊断，不启动全父/place。

综合态core资源与setup不通过的原表/哈希见results及engineering_resource_snapshot；不是最终route结论。

最新真实AT020采样：{
  "utc": "2026-10-26T15:34:37.826340+00:00",
  "elapsed_seconds": 7874.535777437035,
  "owned_rss_kb": 21500844,
  "available_kb": 439772464,
  "owned_CPU_ticks_observed": 1118395,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}


---
Published: 2026-10-26T15:34:38.337505+00:00
Publication: P8d4e3d8f662c4e2794aa95479e4b8790
Execution state: running
Research verdict: inconclusive
Applicability: 同f849/91源/ROM/11父generic/300MHz的matrix core综合态；完整top与最终时序未验收
Evidence:
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/core_resource_diagnostic_contract.md
- project/E022_m007_full_top_physical/experiment_results/runs/R001/AT019_core_completion_engineering_audit.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/actual_AT019_core_cost.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/checkpoints/core_synth.identity.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/effective_receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/launch.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/live_status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/reports/utilization.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/reports/utilization_hierarchical.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/resource_finding.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/hold_receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/check_timing_finding.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/timing_finding.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/worst_setup_path_header.txt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/reports/timing_summary.rpt
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/source_relation.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/preparation_validation.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/drc_finding.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/drc_summary_and_resource_error.txt
