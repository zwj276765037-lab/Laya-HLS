# E022 AT015 synthesis running under actual256GiB supervision

execution_state: running
verdict: unassessed

Actual external256GiB guard active since14:06:12.169726UTC; original128GiB guard is paused at sleep,retaining parent/subreaper/lock. The same Vivado process continues. Current samples are in attempts/AT015_core_synth/rss256_handoff/live_status.json; original AT015/live_status.json is intentionally frozen at handoff and is not current. A watchdog restores original128GiB supervision on failure and confirms real resumed sampling/receipt.

Latest observedUTC2026-10-25T14:08:03.914423+00:00: elapsed8789.997s,RSS113276668KiB(108.03GiB),MemAvailable365714948KiB(348.77GiB),CPUticks975934,triggerNone. RTL Optimization Phase2 completed; subsequent synthesis remains active,no mapped DCP yet.

Original conservative deadline17:41:33.917700UTC and maximum21600s are unchanged. Cumulative caps preparation1200/repair_static600/repair_rtl600/synthesis43200/implementation86400/reports3600s,all historical charges retained. MemAvailable>192GiB,CPU0–3,nice19,idleIO,synthesis1worker,project singleheavylock and300s actualCPU+file-progress guard remain. Repair RSS24/8GiB is unchanged. Future physical stages use256GiB directly in their own launched guard.

After actual core PASS,continue report_core,facade_synth/facade_link,resident_synth,parent_synth/full_link,full reports,opt/place/phys_opt/route and reports under remaining category budgets. Actual realDCP pin checks,zero blackboxes,one root clock,complete resources and all internal/crosspartition timing are still required. PS candidate remains paused. Larger server budget does not demonstrate FPGA fit or timing.

Current independent observer3214011/start62701992,session38131,monitors return safety;monitor3210585/session15673 and watchdog3210588 continue normal256GiB supervision. Original session50693 retained. Frozen_source_binding.json records actual loaded95c75 versus separately fixed futurecanonical;the oldguard live_status is not current. Before subsequent physical stages,require originalreceipt+effective receipt,all owned gone,observer exited and lock released.


---
Published: 2026-10-25T14:12:55.688306+00:00
Publication: P9d17210aa5b542cfb87a6174deef436d
Execution state: running
Research verdict: unassessed
Applicability: Same f849 production core synthesis under verified256GiB supervisory handoff; final hardware resources and timing pending
Evidence:
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/source_manifest_v3.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/bottom_up_configuration_v6.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/repair_v2/equivalence_result.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/budget_ledger.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/expanded_budget_prelaunch_check.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/ps_diagnostic/status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/RTL_phase1_completed.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/RTL_phase2_completed.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/guard_handoff_validation/test_result.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/rss256_handoff/activation.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/rss256_handoff/config.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/rss256_handoff/watchdog_ready.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/rss256_handoff/observer/ready.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/rss256_handoff/frozen_source_binding.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/guard_handoff_exception_validation/test_result.json
