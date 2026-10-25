# E012 active results / R002 FULLN-04

Four complete prequantized M128 full-N shapes PASS on frozen AT012 build. All final outputs, every final-group pre-bias PS vector, continuous K issue per block, exact accepted W bytes, real context rotation/merged reads/overlap, final accepted debts and leases, illegal fullspan zeroAR and held-done command barrier pass.

| attempt / shape | K x N | real blocks / final F32 | MATRIX_ACCEPT to final done | cap | actual wall s |
|---|---:|---:|---:|---:|---:|
| AT014 WO |1024x1024|16 /131072|17945|18304|185.957188|
| AT015 QKV |1024x3072|48 /393216|51833|53120|462.226435|
| AT016 Wi |1024x5248|82 /671744|87839|87936|949.027829|
| AT017 Down |2624x1024|16 /131072|44443|45952|487.255512|

K1024 cases have first32 output1800cycles,1024 consecutive issues/block and accept-to-lastoutput1318/1317; Down first output4298,2624 consecutive issues/block and2918/2917. All have35-cycle gap and peak arithmetic32/total return52. QKV uses all128 original Encoder0 norm rows; WO/Wi use16 original trajectory rows plus112 diagnostic rows. Wi checks through s81 and both logical half-column ranges. Its97cycle service margin does not authorize more pipeline delay. Per-shape MAC/complete prequantized service cycle: WO7479.394149, QKV7768.278587, Wi7830.984597. No routed clock, F32-joint or board-throughput claim.

AT018/019 full FC1/FC2 are tool-before-start COST_STOP/0s: latest full-cost estimates1095.992555/1437.037015s versus1177.698439s total remaining before five required bounded cases reserved600s; FC2 also exceeds single1200s. Their complete final output remains unverified.

AT022 FC1-bias finite stalls PASS48.670190s on pre-cleanup core: real IDLE ctx reuse barrier987cycles, merged response hold312cycles (all response holds348), output hold2175, logical arithmetic64 and total return84 peak,48 actual old-bias-ack/new-math-issue overlaps,32/32/32 bias events per block, coefficient identity zeroAR rejection. Shared add and PS write request conflicts were actually0 under the in-place prepass schedule.

AT023 preserves COST_STOP120.253394s: W prefetch error endpoint727accepted/727committed and real AXI/lease drain passed; no-reset recovery blocked. AT028 bounded probe preserves FAIL24.584378s despite childexit0: after real new A publication/full command/two W loads, core inactive but abort remained1. One exact new final-release priority assignment in AT029 clears only inactive abort after actual A/FP release and storage idle; final cancel status retained and no real debt forced.

AT030 corrected error→no-reset new request/gen/epoch,A_slot1,different WO source3-block recovery PASS54.936846s. AT031 repaired normal QKV3 PASS38.598017s. AT032 repaired complete WO is running; current reset and Decision-bias short cases follow. The four complete-N results above stay frozen at AT012, not migrated to the changed-core revision. Prefix stress ends before matrix-wide final release, so its exercised branch is unchanged. Later TB A-publication observation shifts peer phase (current prefixes4167matrix/first1793 versus prior4174/1800); this is not an abort-fix performance claim.

AT009/010 bounded QKV/FC1-bias pilots PASS at their frozen version. AT012 rebuild fixes only waiting_next counter ordering and adds directed TB/real semantic progress; AT013 current-build QKV three-block pilot PASS38.688184s with4174matrix/8290totalTBcycles. AT011 first full WO remains COST_STOP130.234845s because old TB omitted progress until completeN; no numeric/protocol Fatal. Current MATRIX_PROGRESS flushes only real256th output consumption after K math/bias acknowledgement checks. No watchdog or acceptance cap increased.

Independent AT002 original local fixtures cover8 tensors/2506752 final F32 values, all fullN original W hashes/inverse old-BO packing checks and last-group PS gold. Only actually executed scope above is PASS. Frozen R001 numeric/cache/local OOC evidence remains at R001/current_version_evidence.json; its core control differs. Full F32 quantizer integration, parent graph/global original first-error order, HBM/CDC, joint resources/routed300MHz and board remain open.


---
Published: 2026-10-21T06:24:05.958019+00:00
Publication: Pc21aca75065e42a482b3a36278881802
