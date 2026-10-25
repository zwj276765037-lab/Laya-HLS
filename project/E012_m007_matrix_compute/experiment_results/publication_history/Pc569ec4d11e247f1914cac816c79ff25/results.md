# R003 current complete-F32 milestone

AT022 current-build complete F32 QKV PASS:128x1024→128x3072,393216 final values and all final-group prebias/W/A mapping checks;48 actual retired blocks. Joint F32 CMD_ACCEPT→final done56017cycles≤57344, first input3,last4098,quant last4182,A publication4185,full command handoff4189,first W4192,first real core4920,first output5983.4096 actual inputs/quant outputs/A writes/A acknowledgements, one cold full matrix command and final real debt/lease/done barrier. All blocks have1024 consecutive issues and35-cycle inter-block gap. Actual wall502.432066s; before-launch conservative651.970789s fit900s single and the remaining budget with400s directed reserve. Full WO is dispatched and not yet claimed PASS.

New DIV AT019 actual error release→idle→new epoch/actual requantization/reload→WO3 recovery PASS52.099081s. AT020 normal QKV3 PASS40.385686s, AT021 original Decision WO bias3 PASS48.016078s; timing unchanged from AT006. AT021 real coefficient configuration accept→response consumed37cycles, separately excluded from the F32 command service interval.

# R003 current functional milestones

Actual A cancellation AT003 PASS:16385 writes and16385 real acks,4 cancellations,3 publications,16481cycles,5.467847s. Partial fill/last ack holds, visible and consumed publication cancellation, cancellation priority, wrong identity/other leased slot rejection and actual preserved-other-slot read all pass. AT002 was a0cost prelaunch closure refusal for an unrelated changed parent file; A-only closure is explicit in AT003.

Actual F32 shell build AT006 PASS21.041569s. AT004 preserved static FAIL3.571521s was a missing read-only DIV credit dependency in the build list; corrected without arithmetic change. Input-byte conversion AT005/007 and original full_reference global error classification PASS; no new matrix gold.

Same AT006 compiled closure real F32 QKV3 blocks AT008 PASS51.538623s and Wi3 AT009 PASS60.749655s:4096 real inputs/quant outputs/A writes/A acks, accept-to-first/last input3/4098,quant last4182,A publication4185,full matrix handoff4189,first W4192,first real core4920,first output5983,third block retirement8357cycles. Real W/A bytes, final outputs and final-group prebias comparisons pass. This is not fullN evidence.

Original Decision WO-bias3 blocks AT011 PASS63.067031s: real handoff4189, first core4927, first output6023, third retirement8397cycles. Each block has32 actual bias reads/adds/PS writeacks;87 real old-bias-ack/new-math-issue overlaps and zero add/write request conflicts. Invalid full-span and original coefficient identity reject before input/A/DIV/W/matrix actions.

All above compiled AT006 DIV identity stays frozen when the shared owner changes working source. Explicit --compiled-sources copies exact build SV; source manifests record the observed current SHA and compiled origin separately. Later active/idle DIV gating validation requires a new build/test boundary. Current directed quant/error/recovery coverage is running; no complete F32 shape is yet claimed.

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
Published: 2026-10-21T07:43:14.267490+00:00
Publication: Pb3282412d94e45d7b9fabc1f081787b8
