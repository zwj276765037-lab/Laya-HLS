# E022 D38 flat8192 operand representation physical flow

Only matrix_engine op0/op1 representation differs from D37. Latest f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd uses64 unpacked slots each packed8192bits, static-slot writes and equivalent32bit lane slices. Full capacity/asynchronous reads/concurrency/priority/guards/reset unchanged. Exact inverse restores both prior e279 and original2147 production bytes. [Latest91-source manifest](../experiment_results/runs/R001/input/source_manifest_v3.json), [source relation](../experiment_results/runs/R001/repair_v2/source_relation.json), [v6 hierarchy configuration](../experiment_results/runs/R001/input/bottom_up_configuration_v6.json).

90other sources/ROM/parent9d877217... and11D37 generics unchanged. D37 full30 proof remains original identity, bridged only for storage representation by actual-source local comparison; no new full30 run. Same U55C/300MHz bare-kernel OOC, no invented shell constraints.

---
Published: 2026-10-25T13:08:23.729487+00:00
Publication: P13ab2de66fa841138c3937e91d5a5466
