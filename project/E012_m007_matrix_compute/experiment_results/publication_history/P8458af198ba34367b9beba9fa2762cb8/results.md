# E012 current R003 initial evidence

AT001_a_cancel_build: actual xvlog/xelab static PASS, 4.220197207003366s; peak owned RSS 204644KiB. This elaborates the cancellation test top; it is not a functional A-cancel or F32 joint result. AT002_a_cancel_directed is queued at the unified heavy lock, no simulator launched yet. F32 testbench now supplies actual source F32 groups and compares every real quant-to-A write to frozen independent A bytes; no TB A fill or per-superblock command.

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
Published: 2026-10-21T06:54:22.562849+00:00
Publication: Pa876efdcc7e8446d818d22793929bdeb
