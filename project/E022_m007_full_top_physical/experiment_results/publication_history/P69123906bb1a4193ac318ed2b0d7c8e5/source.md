# E022 D38 complete top physical validation

Question: can the current D37-validated production kernel fit xcu55c-fsvh2892-2L-e and meet300MHz internal timing? Complete91-source/ROM closure is frozen, with original order and SHA correspondence; no RTL/TB or numerical change. Bare-kernel OOC excludes shell/package pin mapping; external IO budgets/uncertainty are not supplied.

[Protocol](protocol.md), [source manifest](../experiment_results/runs/R001/input/source_manifest.json). Actual sequence: preflight→synth→hierarchical resources/checks/DCP→opt/place/phys_opt/route→routed reports, under independent guarded budgets. A010 owns physical scripts/E022; root owns mission/review.


---
Published: 2026-10-25T06:37:19.597832+00:00
Publication: Pca6de8c2199441e98718cc1487e12753
