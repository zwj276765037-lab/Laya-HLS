# E022 report_core DRC运行，综合态资源及setup不通过

execution_state: running
verdict: inconclusive

AT020已实际完成Synthesized timing_summary及setup/hold各50路径报告：WNS=-1289.339ns、TNS=-301158.188ns，setup失败132577/3273333；WHS=0.065ns、THS=0、hold失败0，core周期报告3.333ns。最差n_reg[1]/C→error_col_reg[0]/CE，6091逻辑级，DataPath1292.568ns，其中logic359.024ns、工具unplaced route估计933.522ns。当前core综合态300MHz约束不通过；没有placed/routed时序结果，不能冒称最终route失败或只差报告。no_clock/unconstrained_internal_endpoints/loops均0，60880输入和112483输出未加shell I/O delay。路径报告-nets弃用各报一条critical warning，保留原日志。当前继续drc，无deadline/trigger=null，serial仍T；后继仅既定同DCP一次opt资源诊断，RTL不改。

最新真实采样：{
  "utc": "2026-10-26T14:46:01.511123+00:00",
  "elapsed_seconds": 4958.135009350022,
  "owned_rss_kb": 21432504,
  "available_kb": 431113932,
  "owned_CPU_ticks_observed": 632294,
  "last_progress_age_seconds": 0.0,
  "owned_processes": 3,
  "trigger": null,
  "maximum_seconds": null,
  "wall_time_limit_disabled": true
}


---
Published: 2026-10-26T14:46:02.325112+00:00
Publication: P97b7b03772444c5fa1e806044e2e90c0
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
