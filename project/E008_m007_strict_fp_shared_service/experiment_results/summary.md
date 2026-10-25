# E008 results — current strict multiplier continuation

The old finite subnormal multiply defect is repaired in the current shared closure. The original AT014 failure remains unchanged. AT015–021 completed with no new failed guard and without rerunning unchanged add/div single-leaf baselines.

| Current component / evidence | Actual result | Boundary |
| --- | --- | --- |
| Strict mul AT016 |217304 native finite pairs;217477 total returned checks;II1,8enabled edges,CE/reset/pairing PASS |Directed/random sample, not exhaustive formal proof |
| Mul same-DUT OOC AT017 |459LUT(454logic/5SRL),326FF,2DSP,0BRAM/URAM,0blackbox;WNS+0.871ns/TNS0/WHS+0.056ns at3.333ns |428internal endpoints; no IO delay/route |
| Strict shared4 AT019 |4424scalar results,512mul/512add;64+64 full capacity,14reject cycles,571overlap/312independent-fire events;hold/epoch/release/reset PASS |Native finite mul inputs now include subnormal/underflow/overflow; external bank peer remains simulated |
| Strict shared256 AT020 |81920scalar results;7QK groups each128tokens with independent tag/credit/backpressure;AV32 full vectors PASS |Arithmetic service only; no real QK tree/PS feedback/head |
| Current public v1 entry AT021 |QK8/AV1/hold/epoch original compatibility test PASS |Same single v2 array; no separate arithmetic copy |

Mul critical path mb1[11]→product30/DSP A[8],2.176ns (logic0.613/estimated nets1.563),7levels.68inputs/33outputs have no delays. [OOC metrics/report/DCP hashes](runs/R001/attempts/AT017_strict_mul8_ooc_pilot/ooc_metrics.json). OOC cost88.319669904s, peak4236972KiB, exit0/null. Full-array resources cannot be accepted by multiplying this leaf result.

Original minsub×1 expected tuple is identical before/after (`000000013f80000000000001`). Old vendor actual0 in AT014; strict shared record0 is asserted1 in AT019/020. [Repair evidence](runs/R001/counterexample_repair_AT014_AT019.json). Actual frozen-model reachability of that diagnostic pair remains UNKNOWN.

Raw new logs: [mul leaf](runs/R001/attempts/AT016_strict_mul8_rtl_pilot/guard_rtl/driver.log), [shared4](runs/R001/attempts/AT019_shared_strict4_regression/guard_rtl/driver.log), [shared256](runs/R001/attempts/AT020_shared_strict256_regression/guard_rtl/driver.log), [compatibility](runs/R001/attempts/AT021_strict_shared_existing_entry/guard_rtl/driver.log). [Current six-file SHA bindings](runs/R001/current_version_evidence.json) match these exact closures.

Unchanged reviewed evidence reused: add AT002191904finite pairs/192077checks,II1/8;OOC AT003443LUT/447FF/0DSP,WNS+0.851ns. Direct div AT012191792finite/nonzero-denominator pairs/191965checks,II1/32;OOC AT0131806LUT/1594FF/0DSP,WNS+1.235ns. These were not rerun. [First-delivery version evidence](runs/R001/first_delivery_version_evidence_AT001_AT014.json) preserves old closure identities.

Historical FAIL remain charged: AT005static declaration error,AT008TB function-wait/watchdog,AT014old-mul numeric failure. Original E007 vendor add/div FAIL also remain historical. [Exact aggregate/new costs and policies](runs/R001/budget_ledger.json). All current guard processes ended. Full shared OOC, real banks/Check, QK tree/AV feedback,8divider lanes, complete head/full graph,route/board/system performance remain NOT_RUN. No overall SM008/M007 acceptance is signed by A007.
