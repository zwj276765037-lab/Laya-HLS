# E022 actual serial physical execution

execution_state: running
verdict: unassessed

Current stage: core_synth complete
Current attempt: /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth

Actual core DCP verified; full-top resources and implementation remain pending.

Physical synthesis/implementation/reports have explicit null single and cumulative wall limits. 256 GiB owned RSS, MemAvailable>192 GiB, CPU0-3, nice19, idle IO, one heavy lock, one synthesis worker and the 300 s real CPU/file progress guard remain. No RTL, XDC, numeric, capacity or PS candidate change.

Actual stage receipts:
- core_synth: PASS, 50108.013761572074 s; project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/effective_receipt.json

Tool-stage completion does not establish resource fit or 300 MHz closure. Final complete linked resources and routed setup/hold/coverage reports require engineering review. No automatic retry. Controller owns two-hour user reports and timer shutdown.

---
Published: 2026-10-26T13:23:08.895881+00:00
Publication: P420a01aa2b864f5fa10265eafcfe1511
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
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/unlimited_wall_handoff/effective_receipt.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/receipt.json
