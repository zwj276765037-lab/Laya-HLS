# E022 report_core运行，旧serial后继持留

execution_state: running
verdict: inconclusive

AT019真实core_synth PASS，elapsed 50108.013762 s，峰owned RSS172.063992GiB；520296664字节core DCP SHA a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90，只是matrix core、非完整kernel。AT020已完成util/hier/ram/clocks，Synthesized CLB LUT2139515（164.11%器件/2.377239倍完整核900000预算），FF1391977、DSP4352、BRAM/URAM0；LUT已经计combining。原层级直接逻辑1946767 LUT占90.991%，dot_array137962、format54786，不能凭BRAM0推断具体buffer根因。当前综合态资源门槛不通过，opt后资源变化仍待实际测量。UTC2026-10-26T13:51:25.492336Z仅对轻量serial3603650/start66216629发pidfd SIGSTOP，实际T；AT020 guard109263/start71064760和wrapper109276/start71064911独立session运行，没有收到信号。旧serial state保留历史running_report_core快照，独立hold_receipt记录实际持留。当前AT020处check_timing，不设deadline，trigger=null。SM012末节已授权本报告正常完成后安全退出旧serial，同SHA完整DCP一次常规opt_design，新attempt/另存候选及前后资源/primitive有界分组；不重综合/功能、不改RTL/端口/cone/时钟，不自动facade/全父/place。若opt后>器件或>900000分别集中出口。E022由A010唯一发布，root保留两小时用户通知。

最新真实AT020采样：{"utc": "2026-10-26T13:54:53.627741+00:00", "elapsed_seconds": 1890.3253350299783, "owned_rss_kb": 17512708, "available_kb": 451439712, "owned_CPU_ticks_observed": 240253, "last_progress_age_seconds": 0.0, "owned_processes": 3, "trigger": null, "maximum_seconds": null, "wall_time_limit_disabled": true}

---
Published: 2026-10-26T13:55:31.455821+00:00
Publication: Pd2d98531ab984ab6aa4a23de1b0f1584
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
