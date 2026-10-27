# E022 AT019：Technology Mapping 运行中

execution_state: running
verdict: unassessed

AT019 原日志 L3165 已完成 Timing Optimization，工具 elapsed03:19:51；L3168 已进入 Technology Mapping。采样 2026-10-26T02:49:27.109466+00:00：elapsed 12092.127328 s，owned RSS 111.176060 GiB，MemAvailable 337.534698 GiB，CPU ticks 1697366，trigger null。仍无core DCP/最终收据/最终映射资源。实际argv含 -no_timing_driven，工具仍输出该Timing标题且已向后推进；不由标题推断内部算法或最终时序。前述DSP表明确为preliminary。

同f849/91生产源与ROM、父/11generic、完整dot/format子树、原300MHzXDC保持；PS候选未应用。物理三类别单次/累计墙钟已实际null/disabled，256GiB RSS、系统余量>192GiB、CPU0-3/单锁/300s真实进展保护保持。原D37正常路径与局部四态表示桥接证据保持原范围。

已有串行continuation仍仅等待当前core实际PASS/DCP/identity/owned清理及锁释放，然后连续原定13阶段；无新core重试。最终完整真实链接资源、P&R、原300MHz setup/hold及覆盖仍待实际报告。历史AT015和旧收据/费用不回写，根负责两小时用户报告及最终停表。

---
Published: 2026-10-26T02:49:28.223736+00:00
Publication: P789e714d7fe54c69ad7fe75ad4e9f87b
Execution state: running
Research verdict: unassessed
Applicability: 同 f849 core 的有因综合策略运行；当前监督已显式取消物理单次/累计墙钟，功能与300MHz最终验收不变
Evidence:
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/source_manifest_v3.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/bottom_up_configuration_v7.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/bottom_up_flow_v7.tcl
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/strategy_v7_relation.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/no_timing_driven_support.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/strategy_v7_prelaunch_check.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/launch.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/synth_design_argv.tcllist
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/strategy_launch_evidence.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/budget_ledger.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/physical_blocker_AT015.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT018_synth_help/receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/cleanup_status_observation.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/cache_cleanup_controller_reference.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/execution_time_policy_v2.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/AT019_unlimited_guard_tests_v2/test_result.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/preflight.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/activation.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/activation_verified.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/live_status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/observer/ready.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/state.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/events.jsonl
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/launch_inputs.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/launch_verified.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_rtl_phase1.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_rtl_phase2.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_cross_boundary_start.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_mapping_report.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_timing_optimization_start.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_technology_mapping_start.json
