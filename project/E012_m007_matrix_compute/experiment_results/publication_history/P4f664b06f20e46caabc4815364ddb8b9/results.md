# E012 active results / R002 FULLN-04

R002 completeN is NOT_RUN. Independent full-local AT001/002 fixtures PASS for8 original tensors/2506752 final F32 values, with original-source full GGUF tensor hashes, independent W576 inverse/old-BO byte checks and real16-row fullN legacy-gold matches (Encoder QKV128 full real source; other112 rows diagnostics). AT002 adds every fullN last-group pre-bias PS value for cross-block commit checking. Reference charges8.068191+9.172818seconds.

AT005 joint build PASS. AT006 QKV and AT007 original FC1-bias fullN-descriptor3-block pilots PASS under120s:39.042589/45.795617seconds. Both prove ctx0->1->0, each1024 consecutive issues and8192 final values/last-group realPS acknowledgements. QKV blockaccept->lastoutput1319cycles; FC1-bias1352cycles, with32 actual bias reads/adds/writeacks each before output. Math+bias reservation peak32 and total-with-shared peak52; actual compute/output handshake overlap750/768 and mergedPSreads594/693. W-prefetch real R overlaps3872/3936. The observed cross-block gap40 would project Wi82 blocks above its87936 cap, so no fullN run or PASS is inferred.

AT008 builds ordinary control optimization (early actual-debt-safe W release, same-accepted-command W lease, A reads only guaranteed by held or actual accepted W reads; still registered W holding at issue). AT009 same-version QKV3-block recheck is active before bias recheck/full cost gate. Static failures AT003 missingTB semicolon and AT004 SV dynamic select compile error remain charged. No numerical expected value or acceptance cap changed.

R001 frozen local delivery remains [R001 evidence](runs/R001/current_version_evidence.json) and [final publication](runs/R001/final_publication.json), with its own retained FAIL/COST_STOP/budgets. Current R002 control differs, and only unchanged numeric/cache/shared modules inherit component evidence. Full graph, F32 quantizer integration, original global first-error equivalence, HBM/CDC, joint resource/300MHz route and board throughput remain open.


---
Published: 2026-10-21T05:06:33.186593+00:00
Publication: Pdbfe2c1f565a4906b67cdc115a15b0ce
