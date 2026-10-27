# E022 AT015 same-source core synthesis running with user-expanded budget

execution_state: running
verdict: unassessed

AT015 actual launchUTC11:41:33.922608,PID3088949,sourcef849/source_manifest_v3/bottom_up_v6. Actual frozen guard128GiB,maximum21600s,MemAvailable>192GiB,CPU0–3,1synthesisworker,nice19/idle,project singleheavylock. Memory growth beyond old24GiB or stdout silence alone does not stop it; only current real128GiB/host-memory/wall/stall guards and tool errors apply.

New cumulative category caps:preparation1200,repair_static600,repair_rtl600,synthesis43200,implementation86400,reports3600s,total135600s. All old charges retained,including synthesis4719.634760798s; new launch synthesis remainder38480.365239202s. Old receipts and budget revisions unchanged; latest explicit user revision appended. Repair RSS24/8GiB remains unchanged and no new repair is running.

After actual core completion,continue source-bound serial facade/resident/parent realDCP assembly,complete zero-blackbox/one-root-clock utilization/internal-crosspartition STA,then opt/place/phys_opt/route and complete reports. Synthesis/link single21600s,opt/phys_opt14400s,place/route43200s,all limited by actual cumulative balance. PS diagnostic paused and no longer a prerequisite. Full FPGA resource budgets/300MHz target unchanged; larger server budget is not hardware validation.

Latest actual stage:RTL Elaboration and RTL Optimization Phase1 complete; synthesis continues. Outer elapsed2390.58s at observation,ownedRSS≈31.90GiB,CPU progressing,no guard. No mapped DCP yet.

---
Published: 2026-10-25T12:22:29.932749+00:00
Publication: P0b39695f6af345a2a2eb308ae5784548
Execution state: running
Research verdict: unassessed
Applicability: User-authorized expanded physical runtime/RSS budget; same f849 source core actual synthesis running, no complete-kernel physical result yet
Evidence:
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/source_manifest_v3.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/input/bottom_up_configuration_v6.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/repair_v2/equivalence_result.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/budget_ledger.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/expanded_budget_prelaunch_check.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/command.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/ps_diagnostic/status.json
- project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/RTL_phase1_completed.json
