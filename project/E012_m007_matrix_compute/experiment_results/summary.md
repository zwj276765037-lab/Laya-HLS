# E012 R004 final actual results

New sharedFPf450 version: AT019 build PASS20.830746s; AT020 QKV3 PASS39.327464s (joint8357); AT021 actual W1RRESP error→727issues/727PSacks drained→zero outputs→real release→no-reset new-identityWO3 PASS54.204637s; AT022 held bias/PS/output PASS48.047993s (actual hold312/ctxreuse989/output2174); AT023 original128contextWO3 PASS45.492356s. AT024 complete original128contextWO PASS203.558494s:131072 final values, joint22129cycles≤22528,4096 real inputs/quant/Awrites/Aacks,16 blocks of1024 continuous issues with35cycle gaps. All final/prebias/W/A/debt/lease checks pass. Same-build cost estimate412.265866s admitted≤600s with240s reserve. Normal passive issue→PSack31/PSfeedback13cycles. Wall times are tool costs, not a controlled speed comparison.

Old sharedFP80f version: profile0/1 QKV3 exact actual equivalence; complete original128contextWO AT008 PASS290.908848s/22129cycles/131072values. AT011 Down2, AT012 Decision WO bias3, AT013 FC2bias1, AT014 real W-error/recovery, AT015 held bias/PS/output and AT016 held last quant/Aack all PASS at frozen oldFP identity. They are not relabeled as newFP full-shape results.

Actual producer-close AT010/AT018 use real quant/DIV8/physical A cache, zero/partial117groups and same-edge input/held quant/physical Aack cases. Partial cases retire117 accepted groups and32 real Awrite/acks; AT018 observes32 real DIV vectors/pending and64/63 scalar debts at close. Three no-reset newgen recoveries each compare4096 actual quant/Awrite groups, publish and public read sample. Cancel response129bits held8cycles, front actual owner/status/quant tuple154bits held5cycles. Public slot1/preserved-slot read covers only row0..15/group0, one544B vector held5cycles; no whole-slot read claim. Original producer error cause remains parent-owned; these are control termination tests, not future G-parent error propagation.

AT025 final guarded audit PASS1.573405s verifies1981unique files, all source/input/compiled/guard/log/policy/receipt identities, exact extraction, costs and old/new boundaries. All25actual attempts PASS. One pre-dispatch orchestration SyntaxError is preserved with0experimental charge. Final charged_s: {"reference": 0.26091121695935726, "static": 102.64592235197779, "rtl": 1256.8884661240154, "ooc": 0.0}. Remaining is frozen without transfer. Full parent/global matrix original-first-error/full graph/model, OOC/route300MHz/HBM/CDC/board remain unverified.

# E012 R003 actual F32 results and bounded cost exit

| shape / actual attempt | K x N | final F32 | joint accept→done cycles | cap | wall s | MAC/joint cycle |
|---|---:|---:|---:|---:|---:|---:|
| QKV / AT022 |1024x3072|393216|56017|57344|502.432066|7188.053341|
| WO / AT023 |1024x1024|131072|22129|22528|202.893911|6065.241448|
| Down / AT030 |2624x1024|131072|55027|56576|691.560311|6250.257655|

All three complete runs compare every final F32, all final-group prebias vectors and real W/A mapping. Real inputs/quant outputs/A writes/A acks are4096 for QKV/WO and10496 for Down. Every block has K continuous issues and35-cycle inter-block gap; final real debts/leases/done barriers pass. Shared QKV/WO front: input3..4098,quant4182,A publish4185,matrix handoff4189,first W4192,first core4920,first output5983. Down: input3..10498,quant10582,A publish10585,handoff10589,W10592,core12218,output14881. These are functional cycles, not physical frequency or board throughput.

Complete Wi/FC1/FC2 are COST_STOP before launch with0fees: AT0281298.000099s, AT0321264.758345s, AT0361471.532968s conservative estimates exceed1200s single cap. Latest complete checker and1.35+10s safety are retained. Actual current pilots pass Wi3 AT02756.631640s, Down2 AT02994.939010s, FC1bias3 AT03160.554627s and FC2bias1 AT03588.922567s. FC2 AT0332block pilot remains charged COST_STOP120.323140s after real s0 retirement; original AT034 full is NOT_RUN without an attempt. Reduced1block retry stays under the original120s unknown-pilot cap; no timeout extension or fabricated run. FC1 each block has32 real bias reads/adds/acks and87 actual bias-ack/math-issue overlaps across its3block sample. FC2 one-block result is a bounded K4096 sample, not a complete matrix.

AT025 PASS60.406039s extends exact-same-DUT TB coverage to all190bits of held F32 done response for5clocks; late input NaN row127/group31/element17 wins over early half overflow, with4096 actual inputs/retirements,4095 scale and4094 inverse divisions, exactly one real A write/ack, zero W/matrix, actual cancellation/release/idle, then no-reset new-identity/source WO3 requantization/reload. Observed DIV idle clocks4203 and new-epoch handoffs1; active-leaf pause0. AT026 PASS48.603900s adds wrong request/generation/epoch/row/group/duplicate rejection then legal QKV3 retry. This response scope is the F32 adapter, not original graph Check. Exact frozen check locations: reports/current_response_and_frozen_build.md.

Current DIV AT019 release/idle/new-epoch error recovery, AT020 QKV3 and AT021 original Decision WO bias3 pass; actual coefficient-load configuration→response consumption37cycles is measured separately. Earlier AT006-DIV directed scope remains version-qualified: AT003 physical cancel (16385 writes/real acks,4cancels,3publications), AT008/009 normal QKV/Wi3, AT011 Decision bias3, AT012 failed-publication interface peer without physical A cache, AT013/014 global inverse/input error recovery, AT015 held last quant/A ack, AT016 identity/order reject, AT017 live quant reset/new-identity recovery. Older held response coverage is only its frozen TB assertions. Future producer failed-close/G integration is unverified in R003.

AT038 final immutable-evidence audit PASS_SCOPED_VERSIONED_EVIDENCE verifies2473unique files, source/fixture/compiled identities, real logs, guards/policies, actual full-cycle/output counts, same-DUT stronger-TB boundary, cost formula/pilot versions and all charges. AT037 prior audit FAIL1.420918s was an old fixed-three-block cost-schema KeyError, preserved and corrected by version-aware audit parsing; no DUT/oracle change. All earlier static failures/prelaunch NOT_RUN are preserved.

Final charged seconds: {"reference": 0.543066557002021, "static": 83.55140984200989, "rtl": 2539.2559304730676, "ooc": 0.0}. Remaining frozen seconds: {"reference": 899.456933442998, "static": 1716.44859015799, "rtl": 2260.7440695269324, "ooc": 600.0}. No budget transfer. Full graph/model, global matrix original-first-error, future producer cancellation, sole-resource parent integration, physical fit/routed300MHz/HBM/CDC/board remain open. Static extraction/resource map and conservative controller subtotal1475B (including512B telemetry) are handoff, not a joint4KiB fit claim; all inherited pipeline tag copies stay visible in the account.

# E012 / R002 versioned results and cost exit

Four complete prequantized shapes passed on frozen AT012 core; these measurements retain that identity.

| shape / attempt | K x N | final F32 | accept to final done | cap | MAC per service cycle |
|---|---:|---:|---:|---:|---:|
| QKV / AT015 |1024x3072|393216|51833|53120|7768.278587|
| WO / AT014 |1024x1024|131072|17945|18304|7479.394149|
| Wi / AT016 |1024x5248|671744|87839|87936|7830.984597|
| Down / AT017 |2624x1024|131072|44443|45952|7738.742389|

All final values and every final-group pre-bias PS vector match independent gold; every block has K consecutive issues,35cycle inter-block gap, exact accepted full W bytes and final actual debt/lease release. Per-block accept-to-lastoutput: K1024 first1318/subsequent1317; Down2918/2917. Normal peak logical arithmetic32/total return52. QKV uses all128 original Encoder0 norm rows; WO/Wi/Down retain16 original trajectory rows plus112 diagnostic rows. Wi97cycle margin does not authorize added pipeline delay. No physical frequency, F32 combined or board claim.

AT023 first prefetch-fault/new-identity test is COST_STOP120.253394s: real failure drain passed but recovery never issued. AT028 bounded FAIL24.584378s confirms inactive core abort1 after new A publication/full command/two W loads; childexit0 did not hide Fatal. The final-release priority repair preserves cancel final status and clears only inactive abort once actual A/FP release and PS idle already completed; no accepted debt is forced clear.

Current cleanup revision independently passes AT030 error→no-reset new request/gen/epoch,A_slot1,different WO data3-block recovery; AT031 normal QKV3; AT032 complete WO; AT033 live common-reset→new identity/value recovery; AT034/035 original Decision QKV/WO bias3-block samples. Current complete WO is131072 final F32,17938cycles/first1793,7482.312855 MAC/servicecycle,188.233983s. The7cycle cold difference versus prior17945/first1800 comes from later TB A-publication observation/AXI peer global phase, not a production speedup. Prior QKV/Wi/Down full-N runs are not relabeled newly executed current-core full tests.

Actual error injection has one accepted RRESP failure,727accepted/727committed math,721cycle drain and zero s1 issue/success output before complete failure retirement. Reset occurs with math32/A_read_debt2/AXI32, followed by12stale-free clocks and real reload. Each Decision bias block has32read/32add/32real PSack before output; original coefficient model binding rejects zeroAR, and actual old-bias-ack/new-math-issue overlap87events per3-block sample. Add/write request conflicts are actually0 under the chosen prepass schedule.

AT022 finite FC1-bias stress retains its pre-cleanup prefix identity; its exercised path ends before matrix-wide final release and is unchanged. It proves real IDLE ctx reuse wait987cycles, output hold2175, merged PS response hold312 (all348), peak logical arithmetic64/total return84,48old-bias-ack/new-issue overlaps and all final values. The old error cleanup failure is not hidden by this prefix proof.

FC1/FC2 full-N remain unverified: AT018/019 early cost stops reserve required short coverage; after all required coverage, AT036/037 again stop before tool launch with0fees. Conservative costs1095.992555/1437.037015s exceed actual remaining562.727058s; FC2 also exceeds single1200s. No budget transfer or original timeout extension. AT011 semantic-observability COST_STOP and all static/functional failures remain charged.

Final audit current_version_evidence.json verifies1415unique files, all frozen passed/failed attempt sources and receipt logs, exact one-addition repair boundary, component SHA/restricted phase boundary, all selected fixture/snapshot/compiled identities, guard policies and budget sums. R002 charged reference17.241009/static143.797149/RTL3037.272942/OOC0s. Full graph/F32 integration/global original first-error order, HBM/CDC, whole-array resource/routed300MHz and board remain open.


---
Published: 2026-10-21T09:55:45.716840+00:00
Publication: Pc5d6a147e71f494e9fe6166d86f35d0f
