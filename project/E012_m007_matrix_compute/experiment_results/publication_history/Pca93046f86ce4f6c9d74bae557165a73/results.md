# E012 R004 actual extraction milestone

AT001 production build PASS21.123460s; AT002 real QKV3(profile0) PASS54.743698s. AT003 profile compatibility build PASS22.072843s; AT004 same QKV3(profile1) PASS55.693950s. Both total8370/joint8357cycles, first core4920/output5983,4096real inputs/Awrites/Aacks, every final/prebias exact and1024continuous issue per block/gap35. Both passive actual issue→writeack31max and actualPSread→writeack13max; profile validity0/1 and enabled values agree. Functional numeric/controller behavior matches this actual sample.

AT005 all128 original context/WO fixture PASS0.260911s; AT006 enhanced response/error TB build PASS21.232902s (DUT unchanged). AT007 real128context WO3 PASS64.104881s with4096 actual quant/A groups; AT008 complete real128context localWO PASS290.908848s: all131072 outputs/prebias,4096 real input/quant/Awrites/Aacks,16 continuous1024-issue blocks/gap35, final actual A/W/FP/PS/DIV/quant release; joint22129cycles≤22528, first/last input3/4098, quant4182,A publish4185,handoff4189,W4192,core4920,output5983. Conservative gate394.785323s fit600 and preserved240s affected reserve. This is independent original context-file input, not actual Attention hardware supply. Future producer failed-close hook still unverified; real physicalA+quant/DIV TB source is prepared, not compiled/run. Remaining affected error/held/shape tests are pending.

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
Published: 2026-10-21T09:15:52.870920+00:00
Publication: P3d9427d929bb4d6e9c904dffafe38a86
