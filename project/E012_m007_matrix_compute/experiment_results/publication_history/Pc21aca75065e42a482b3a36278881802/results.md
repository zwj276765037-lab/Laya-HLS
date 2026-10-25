# E012 active results / R002 FULLN-04

Three complete prequantized M128 full-N shapes PASS on frozen AT012 build. All final outputs, every final-group pre-bias PS vector, continuous K issue per block, exact accepted W bytes, real context rotation/merged reads/overlap, final accepted debts and leases, illegal fullspan zeroAR and held-done command barrier pass.

| attempt / shape | K x N | real blocks / final F32 | MATRIX_ACCEPT to final done | cap | actual wall s |
|---|---:|---:|---:|---:|---:|
| AT014 WO |1024x1024|16 /131072|17945|18304|185.957188|
| AT015 QKV |1024x3072|48 /393216|51833|53120|462.226435|
| AT016 Wi |1024x5248|82 /671744|87839|87936|949.027829|

All have first32 output1800cycles,1024 continuous issues per block,35-cycle cross-block gap, first block accept-to-lastoutput1318/subsequent1317, peak arithmetic32/total return52. QKV uses all128 original Encoder0 norm rows; WO/Wi use16 original trajectory rows plus112 diagnostic rows. Wi checks through s81 and both logical half-column ranges. Its97cycle service margin does not authorize more pipeline delay. Per-shape MAC/complete prequantized service cycle: WO7479.394149, QKV7768.278587, Wi7830.984597. No routed clock, F32-joint or board-throughput claim.

AT017 full Down is currently running under a latest same-build full-cost gate944.863049s/request1000s, including actual Wi/WO/QKV receipts and1.35 safety. R002 remaining before Down1664.953950s. Required finite-stall/bias/error/reset/Decision variants are next; FC1/FC2 full-N remain NOT_RUN unless latest cost and remaining coverage budget permit. Automatic original queue stopped before any Wi attempt/tool, then Wi/Down were explicitly allocated within the unchanged1200s contract cap.

AT009/010 bounded QKV/FC1-bias pilots PASS at their frozen version. AT012 rebuild fixes only waiting_next counter ordering and adds directed TB/real semantic progress; AT013 current-build QKV three-block pilot PASS38.688184s with4174matrix/8290totalTBcycles. AT011 first full WO remains COST_STOP130.234845s because old TB omitted progress until completeN; no numeric/protocol Fatal. Current MATRIX_PROGRESS flushes only real256th output consumption after K math/bias acknowledgement checks. No watchdog or acceptance cap increased.

Independent AT002 original local fixtures cover8 tensors/2506752 final F32 values, all fullN original W hashes/inverse old-BO packing checks and last-group PS gold. Only actually executed scope above is PASS. Frozen R001 numeric/cache/local OOC evidence remains at R001/current_version_evidence.json; its core control differs. Full F32 quantizer integration, parent graph/global original first-error order, HBM/CDC, joint resources/routed300MHz and board remain open.


---
Published: 2026-10-21T05:55:15.493976+00:00
Publication: P3d59d59c294045b7abfddd71c18bfed8
