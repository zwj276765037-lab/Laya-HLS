# E022 actual results under expanded user budget

Latest production f8493b... remains unchanged with original/latest local four-state storage equivalence PASS(AT012/013,6721cycles/13442full-pool checks). D37 full30 remains original source identity plus this local bridge; new full30 rerun NOT_RUN.

All old physical attempts/costs remain immutable: AT014 actual old24GiB COST_STOP1278.032619354s,peak25454276KiB,noDCP,sourceaftertrue,ownedempty. This was a project budget guard,not host memory exhaustion or FPGA overcapacity. AT011 was separately classified controlled replan,not RSS/stall/numeric failure. Cumulative prior synthesis4719.634760798s remains charged.

User explicitly increased physical compute budget; AT015 is a NEW same-source core attempt,not a resumed checkpoint. Actual launch PID3088949/start61814704,128GiB physical RSS cap and21600s per attempt. [Actual command/guard](../experiment_results/runs/R001/attempts/AT015_core_synth/command.json), [new-budget prelaunch check](../experiment_results/runs/R001/expanded_budget_prelaunch_check.json). No completed core/full-kernel DCP or final resource report exists yet. Complete linkage,implementation and300MHz setup/hold remain NOT_RUN.

PS candidate7c292... and complete-cone extraction are preserved only as unexecuted diagnostic source. No PS compile/RTL/OOC attempt occurred and candidate is not applied. Current source_manifest_v3/bottom_up_v6,90other sources/ROM/parent/11generic/XDC remain unchanged.

---
Published: 2026-10-25T11:44:01.588863+00:00
Publication: Pc254d04e934447ffabb0b828d144a696
