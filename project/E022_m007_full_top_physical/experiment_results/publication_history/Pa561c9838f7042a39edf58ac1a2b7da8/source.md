# E022 D38 flat8192 operand representation physical flow

Only matrix_engine op0/op1 representation differs from D37. Latest f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd uses64 unpacked slots each packed8192bits, static-slot writes and equivalent32bit lane slices. Full capacity/asynchronous reads/concurrency/priority/guards/reset unchanged. Exact inverse restores both prior e279 and original2147 production bytes. [Latest91-source manifest](../experiment_results/runs/R001/input/source_manifest_v3.json), [source relation](../experiment_results/runs/R001/repair_v2/source_relation.json), [v6 hierarchy configuration](../experiment_results/runs/R001/input/bottom_up_configuration_v6.json).

90other sources/ROM/parent9d877217... and11D37 generics unchanged. D37 full30 proof remains original identity, bridged only for storage representation by actual-source local comparison; no new full30 run. Same U55C/300MHz bare-kernel OOC, no invented shell constraints.

Physical supervision changed from the immutable128GiB launch guard to an actual256GiB external supervisor at2026-10-25T14:06:12.169726UTC. Production RTL/ROM/generics/XDC and time budgets are unchanged. The original Python parent/lock/subreaper is paused at its sleep boundary; Vivado continues with the same PID/start identities. A separate watchdog restores the original128GiB guard on monitor failure. No debugger/injection or global security change was used.

---
Published: 2026-10-25T15:13:03.837889+00:00
Publication: Pcca3d98e090e43cfa578615c88854a4a
