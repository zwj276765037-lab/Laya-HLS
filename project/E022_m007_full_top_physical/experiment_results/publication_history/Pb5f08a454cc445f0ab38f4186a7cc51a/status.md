# E022 AT019 同源策略综合运行中

execution_state: running
verdict: unassessed

实际 AT019 于 2026-10-25T23:27:54.983905+00:00 启动；leader PID 3583000/start 66052093，guard PID 3582995/start 66052065，session 13521。当前 Vivado 仍在 RTL Elaboration，CPU 持续推进。最新采样 2026-10-25T23:36:38.403563+00:00：elapsed 523.3499065760989 s，owned RSS 16065404 KiB，MemAvailable 489596492 KiB，CPU ticks 54427，trigger None。

仅 core_synth 对原 f849 版本增加已验证支持的 -no_timing_driven；原 91 源码/ROM、父模块、11 个 generic、U55C/OOC/PROFILE0、完整 dot/format 子树和 300 MHz XDC 不变。没有源代码修改或 PS 候选应用。该次为无 checkpoint 的新综合。

实际单次上限 16878.966330897878 s，保守截止 2026-10-26T04:09:13.948482+00:00；256 GiB owned RSS、MemAvailable>192 GiB、CPU0-3、nice19、idle IO、单 worker、单重工具锁和 300 s 实际 CPU/文件进展守卫保持。AT015 已结束，其 live 文件仅为历史证据。

按用户授权，主控仅删除已结束 AT002/AT003/AT015 的 153 个可重建 .rtd/.tim 二进制缓存，释放 4,447,686,656 allocated bytes（4.14223 GiB）；其余 358 份旧文件前后 SHA 未变。当前 AT019、共享输入、ROM、冻结源码、日志、收据、DCP 和局部等价 xsim 快照保留。证据由主控维护于 results/reviews/m007_d38_cache_cleanup_20261026.json。

实际 core PASS 后依次 report_core、真实分区装配、完整资源、原约束 place/route/STA；各阶段继续使用实际剩余预算。当前没有 core DCP、完整资源/fit 或 300 MHz 时序结论。跳过综合内部 timing-driven 优化不能代替最终时序验收。失败或余额耗尽保留实际退出，不盲目重跑。

---
Published: 2026-10-25T23:36:57.407154+00:00
Publication: Pfe2679191865403497be570aec2fd0fc
Execution state: running
Research verdict: unassessed
Applicability: Samef849actualcore strategy retry with supported-no_timing_driven under originalremainingbudget;finalcompletekernelresources/PnR/300MHztimingpending
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
