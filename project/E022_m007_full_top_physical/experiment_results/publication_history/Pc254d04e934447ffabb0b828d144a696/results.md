# E022 actual local proof PASS; physical synthesis COST_STOP

Latest matrix f8493b... flat8192 representation has actual original/latest XSim four-state equivalence PASS at AT012/013:6721cycles/13442full-pool checks and all original finite coverage. Exact inverse restores original2147 and intermediatee279 bytes. [Equivalence evidence](../experiment_results/runs/R001/repair_v2/equivalence_result.json). D37 full30 remains original source identity; new full30 rerun NOT_RUN.

AT014 core synthesis stopped at the actual24GiB RSS guard after1278.032619354s. Receipt peak25454276KiB≈24.275GiB,source_verify_after=true,owned_after_cleanup=[]; independent7PID/start recheck empty, one transient policy identity UNKNOWN. First trigger mainRSS24909352KiB; stopped snapshot mainRSS24915024KiB,helper529332KiB. These are separate samples. [Raw receipt](../experiment_results/runs/R001/attempts/AT014_core_synth/receipt.json), [bounded blocker result](../experiment_results/runs/R001/physical_blocker_result.json).

Op0/op1 3D warnings were eliminated; aligned_reg32768 warning remains. Log includes engine module-done marker, but no completedRTL-elaboration/synth_design/DCP. Correction to earlier tail-only observation: absence of an engine-done line had been overstated; full log contains it. No final FF/LUT/DSP/BRAM/URAM mapping exists. No inference of device overcapacity or numerical failure is supported.

Earlier AT011 e279 was an explicit CONTROLLED_REPLAN_STOP at1736.656508570s,not RSS/stall/numeric failure; original classifications/costs/source versions remain unchanged. Other full-top/core cost stops remain separate. Full-top DCP assembly/resources/fit and actual implementation/300MHz setup/hold remain UNKNOWN/NOT_RUN.

---
Published: 2026-10-25T08:41:57.750578+00:00
Publication: P473eeb2684574b0883f66a7318bc6477
