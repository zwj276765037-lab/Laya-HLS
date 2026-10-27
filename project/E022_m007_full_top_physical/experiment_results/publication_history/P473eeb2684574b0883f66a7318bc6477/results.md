# E022 actual results and version boundaries

Original physical attempts AT002/003/005 remain COST_STOP; no DCP or mapped-resource result. First unpacked-slot/packed-lane e279 representation passed AT009/010 local four-state equivalence. Its AT011 actual synthesis was actively ended by controller/A014 at1736.656508570s with peak16777212KiB and continuingCPU/no swap. Actual classification CONTROLLED_REPLAN_STOP to remove remaining3D storage; raw requested_stop/COST_STOP receipt retained. This was not RSS/stall/numerical failure. Source aftercheck true/owned cleanup empty/no DCP. [Classification](../experiment_results/runs/R001/attempts/AT011_core_synth/result_classification.json).

Latest flat8192 version passed AT012 static9.696188813s/AT013 actual four-state RTL8.653027590s: same6721cycles,13442full-pool comparisons,2560event/equality cases each pool,512additional high32 format/PS collisions,64reset-all-events,192X cases,64slots/256lanes/32bits and separate actual-read64slot coverage. [Latest equivalence result](../experiment_results/runs/R001/repair_v2/equivalence_result.json), [raw log](../experiment_results/runs/R001/attempts/AT013_repair_rtl/xsim.log). Known addresses only; finite stimulus, no exhaustive values/full-core waveform claim.

AT014 latest core OOC running. Complete-kernel resources/fit/DCP assembly/implementation/setup/hold remain UNKNOWN/NOT_RUN.

---
Published: 2026-10-25T08:18:46.902386+00:00
Publication: Pd14c9115c8d94ad092eaf41409f7c6b6
