# E022 D38 new storage representation, source-bound physical flow

Only matrix_engine op0/op1 representation differs from D37: unpacked64 slots with static-slot LHS writes; full dimensions, async reads, same-edge concurrency/priorities, guards and reset semantics remain. Exact inverse restores original production bytes. New engine SHA e279968ca6407bc4c96687a689ba187cd7e29c1f0e2c61a358ecf1f18c917154; 90 other sources/ROM and parent top unchanged. [New91-source closure](../experiment_results/runs/R001/input/source_manifest_v2.json), [actual-source relation](../experiment_results/runs/R001/repair/source_relation.json), [v5 partition configuration](../experiment_results/runs/R001/input/bottom_up_configuration_v5.json).

All11 valid D37 generics, U55C xcu55c-fsvh2892-2L-e,3.333333333ns bare-kernel OOC remain. Full30 D37 PASS is original source identity, bridged only for this storage change by local actual-source equivalence; no new full30 run. No real shell/IO-delay/platform uncertainty is invented.

---
Published: 2026-10-25T07:45:57.139515+00:00
Publication: P03533acd6a384546b34c09350372f4ce
